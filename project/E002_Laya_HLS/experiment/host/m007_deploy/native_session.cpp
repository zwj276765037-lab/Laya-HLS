// Persistent native CPU contract. No Attention, XRT, Python arithmetic or gold.
#define M007_FRONTEND_LIBRARY
#include "native_frontend.cpp"
#include "laya_full_numeric.h"
#include "laya_numeric.h"
#include <array>
#include <atomic>
#include <cfenv>
#include <chrono>
#include <condition_variable>
#include <functional>
#include <immintrin.h>
#include <map>
#include <memory>
#include <mutex>
#include <thread>
#include <unistd.h>

namespace {
using Clock = std::chrono::steady_clock;
uint64_t ns(Clock::time_point t) {
    return std::chrono::duration_cast<std::chrono::nanoseconds>(Clock::now()-t).count();
}
void finite(float x, const char* name) {
    if (!std::isfinite(x)) throw Failure("NUMERIC_ERROR", name);
}
void checked(laya::Check c, const char* name) {
    if (!c) throw Failure("NUMERIC_ERROR", name);
}
struct FloatEnvironment {
    fenv_t saved;
    unsigned mxcsr;
    FloatEnvironment() : mxcsr(_mm_getcsr()) {
        if (fegetenv(&saved) != 0)throw Failure("FENV_ERROR", "cannot save thread environment");
        if (fesetround(FE_TONEAREST) != 0) {
            fesetenv(&saved);_mm_setcsr(mxcsr);
            throw Failure("FENV_ERROR", "cannot set thread RNE");
        }
        unsigned desired = _mm_getcsr();
        desired &= ~((3u<<13) | (1u<<15) | (1u<<6));
        _mm_setcsr(desired);
        if (fegetround() != FE_TONEAREST || (_mm_getcsr() & ((3u<<13)|(1u<<15)|(1u<<6)))) {
            fesetenv(&saved);_mm_setcsr(mxcsr);
            throw Failure("FENV_ERROR", "RNE/gradual underflow not active");
        }
    }
    ~FloatEnvironment() { fesetenv(&saved); _mm_setcsr(mxcsr); }
};
struct CallerAffinity {
    cpu_set_t saved;
    CallerAffinity() {
        if(pthread_getaffinity_np(pthread_self(),sizeof(saved),&saved))throw Failure("RESOURCE_ERROR","caller affinity query");
        cpu_set_t only;CPU_ZERO(&only);CPU_SET(0,&only);
        if(!CPU_ISSET(0,&saved)||pthread_setaffinity_np(pthread_self(),sizeof(only),&only))
            throw Failure("RESOURCE_ERROR","caller requires authorized CPU0");
    }
    ~CallerAffinity(){pthread_setaffinity_np(pthread_self(),sizeof(saved),&saved);}
};

// A persistent pool. Each worker handles independent rows/outputs. Reductions
// within an output always retain the frozen K/group order.
class Pool {
    std::mutex mutex;
    std::condition_variable changed, complete;
    std::array<std::thread,3> workers;
    std::function<void(unsigned)> job;
    uint64_t generation=0;
    unsigned remaining=0;
    bool stop=false;
    std::exception_ptr error;
public:
    Pool() {
        for (unsigned i=0;i<3;++i) workers[i]=std::thread([this,i] {
            cpu_set_t set; CPU_ZERO(&set); CPU_SET(i+1,&set);
            const int pin = pthread_setaffinity_np(pthread_self(),sizeof(set),&set);
            uint64_t seen=0;
            std::unique_lock<std::mutex> lock(mutex);
            for (;;) {
                changed.wait(lock,[&]{return stop||generation!=seen;});
                if(stop) return;
                seen=generation;
                auto current=job;
                lock.unlock();
                try {
                    if(pin) throw Failure("RESOURCE_ERROR","worker affinity failed");
                    FloatEnvironment environment;
                    current(i+1);
                } catch (...) {
                    std::lock_guard<std::mutex> guard(mutex);
                    if(!error) error=std::current_exception();
                }
                lock.lock();
                if(--remaining==0) complete.notify_one();
            }
        });
    }
    ~Pool() {
        {std::lock_guard<std::mutex> lock(mutex);stop=true;++generation;}
        changed.notify_all();
        for(auto& worker:workers)worker.join();
    }
    void run(std::function<void(unsigned)> function) {
        {std::lock_guard<std::mutex> lock(mutex);job=std::move(function);remaining=3;error=nullptr;++generation;}
        changed.notify_all();
        try { FloatEnvironment environment; job(0); }
        catch (...) {std::lock_guard<std::mutex> lock(mutex);if(!error)error=std::current_exception();}
        std::unique_lock<std::mutex> lock(mutex);
        complete.wait(lock,[&]{return remaining==0;});
        if(error)std::rethrow_exception(error);
    }
};

uint32_t u32(const uint8_t* p) {uint32_t v;std::memcpy(&v,p,4);return v;}
uint64_t u64(const uint8_t* p) {uint64_t v;std::memcpy(&v,p,8);return v;}
struct QWeights {
    unsigned N,K,G,blocks;
    std::vector<int8_t> packed;
    std::vector<float> scale;
    std::vector<int32_t> correction;
    QWeights(const std::vector<uint8_t>& raw,unsigned n,unsigned k):N(n),K(k),G(k/32),blocks((n+15)/16),
        packed(blocks*G*8*64,0),scale(blocks*G*16,0),correction(blocks*G*16,0) {
        if(raw.size()!=n*G*34)throw Failure("IDENTITY_ERROR","Q8 span");
        for(unsigned out=0;out<N;++out)for(unsigned g=0;g<G;++g) {
            const auto* block=raw.data()+(out*G+g)*34;
            uint16_t h;std::memcpy(&h,block,2);
            float s=laya::numeric_half_to_f32(h);finite(s,"Q8 weight scale");
            if(s<0)throw Failure("NUMERIC_ERROR","negative Q8 scale");
            const unsigned base=((out/16)*G+g)*16+out%16;
            scale[base]=s;
            int sum=0;
            for(unsigned k0=0;k0<32;++k0) {
                int8_t v;std::memcpy(&v,block+2+k0,1);
                if(v==-128)throw Failure("NUMERIC_ERROR","Q8 weight domain");
                packed[(((out/16)*G+g)*8+k0/4)*64+(out%16)*4+k0%4]=v;
                sum+=v;
            }
            correction[base]=128*sum;
        }
    }
};

void finite16(__m512 value,const char* name) {
    const auto exponent=_mm512_and_si512(_mm512_castps_si512(value),_mm512_set1_epi32(0x7f800000));
    if(_mm512_cmpeq_epi32_mask(exponent,_mm512_set1_epi32(0x7f800000)))
        throw Failure("NUMERIC_ERROR",name);
}
__m512i dot_group16(const int8_t* q,const int8_t* packed,const int32_t* correction) {
    __m512i dots=_mm512_setzero_si512();
    for(unsigned quad=0;quad<8;++quad) {
        uint32_t activation;std::memcpy(&activation,q+quad*4,4);
        activation^=0x80808080u;
        const auto weights=_mm512_loadu_si512(packed+quad*64);
        dots=_mm512_dpbusd_epi32(dots,_mm512_set1_epi32(activation),weights);
    }
    return _mm512_sub_epi32(dots,_mm512_loadu_si512(correction));
}
// Same adjacent binary tree as the original leaf. SIMD combines independent
// adjacent pairs at each level; it never reassociates one reduction.
float adjacent1024(float* tree) {
    const auto even=_mm512_setr_epi32(0,2,4,6,8,10,12,14,16,18,20,22,24,26,28,30);
    const auto odd=_mm512_setr_epi32(1,3,5,7,9,11,13,15,17,19,21,23,25,27,29,31);
    unsigned width=1024;
    for(;width>=32;width/=2)for(unsigned i=0;i<width/2;i+=16) {
        const auto a=_mm512_loadu_ps(tree+2*i),b=_mm512_loadu_ps(tree+2*i+16);
        const auto sum=_mm512_add_ps(_mm512_permutex2var_ps(a,even,b),_mm512_permutex2var_ps(a,odd,b));
        finite16(sum,"LN adjacent sum");_mm512_storeu_ps(tree+i,sum);
    }
    for(;width>1;width/=2)for(unsigned i=0;i<width/2;++i) {tree[i]=tree[2*i]+tree[2*i+1];finite(tree[i],"LN tree");}
    return tree[0];
}
void strict_ln(const float* x,const float* gamma,float* y) {
    alignas(64) float tree[1024];
    for(unsigned i=0;i<1024;i+=16) {const auto v=_mm512_loadu_ps(x+i);finite16(v,"LN input");_mm512_store_ps(tree+i,v);}
    const float mean=adjacent1024(tree)/1024.0f;finite(mean,"LN mean");
    for(unsigned i=0;i<1024;i+=16) {
        const auto delta=_mm512_sub_ps(_mm512_loadu_ps(x+i),_mm512_set1_ps(mean));finite16(delta,"LN delta");
        const auto square=_mm512_mul_ps(delta,delta);finite16(square,"LN square");_mm512_store_ps(tree+i,square);
    }
    const float variance=adjacent1024(tree)/1024.0f;finite(variance,"LN variance");
    if(variance<0)throw Failure("NUMERIC_ERROR","LN negative variance");
    const float shifted=variance+laya::numeric_bits_f32(0x3727c5acu);finite(shifted,"LN shifted");
    const float root=::sqrtf(shifted);finite(root,"LN sqrt");
    if(root<=0)throw Failure("NUMERIC_ERROR","LN sqrt domain");
    const float inverse=1.0f/root;finite(inverse,"LN inverse");
    for(unsigned i=0;i<1024;i+=16) {
        const auto delta=_mm512_sub_ps(_mm512_loadu_ps(x+i),_mm512_set1_ps(mean));finite16(delta,"LN output delta");
        auto value=_mm512_mul_ps(delta,_mm512_set1_ps(inverse));finite16(value,"LN norm");
        if(gamma) {const auto g=_mm512_loadu_ps(gamma+i);finite16(g,"LN gamma");value=_mm512_mul_ps(value,g);finite16(value,"LN gamma product");}
        _mm512_storeu_ps(y+i,value);
    }
}
void quant(const float* x,unsigned K,int8_t* q,float* scales) {
    for(unsigned g=0;g<K/32;++g) {
        float maximum=0;
        for(unsigned k=0;k<32;++k) {finite(x[g*32+k],"quant input");maximum=std::max(maximum,std::fabs(x[g*32+k]));}
        const float d=maximum/127.0f;
        const float inverse=d==0.0f?0.0f:1.0f/d;
        finite(d,"quant d");finite(inverse,"quant inverse");
        const uint16_t half=laya::numeric_f32_to_half_rne(d);
        scales[g]=laya::numeric_half_to_f32(half);finite(scales[g],"quant half");
        for(unsigned k=0;k<32;++k) {
            const float product=x[g*32+k]*inverse;finite(product,"quant product");
            const float rounded=::roundf(product);
            if(rounded < -127 || rounded > 127)throw Failure("NUMERIC_ERROR","quant range");
            q[g*32+k]=static_cast<int8_t>(rounded);
        }
    }
}
void qlinear(const float* x,const QWeights& w,const float* bias,float* y) {
    alignas(32) int8_t q[1024];float scale[32];
    quant(x,w.K,q,scale);
    for(unsigned block=0;block<w.blocks;++block) {
        __m512 acc=_mm512_setzero_ps();
        for(unsigned g=0;g<w.G;++g) {
            // U8(A+128)*S8(W), exact 128*sum(W) compensation, non-saturating.
            const auto dots=dot_group16(q+g*32,w.packed.data()+(block*w.G+g)*8*64,
                                      w.correction.data()+(block*w.G+g)*16);
            const auto product=_mm512_mul_ps(_mm512_set1_ps(scale[g]),_mm512_loadu_ps(w.scale.data()+(block*w.G+g)*16));
            finite16(product,"q8 scales product");
            const auto restored=_mm512_mul_ps(product,_mm512_cvtepi32_ps(dots));finite16(restored,"q8 restored");
            acc=_mm512_add_ps(acc,restored);finite16(acc,"q8 accumulator");
        }
        alignas(64) float bias_lanes[16]={},result[16];
        const unsigned count=std::min(16u,w.N-block*16);
        std::memcpy(bias_lanes,bias+block*16,count*4);
        const auto biased=_mm512_add_ps(acc,_mm512_load_ps(bias_lanes));finite16(biased,"q8 bias");
        _mm512_store_ps(result,biased);std::memcpy(y+block*16,result,count*4);
    }
}
float gelu(float x) {
    finite(x,"GELU input");
    const float u=0.044715f*x;const float v=u*x;const float w=1.0f+v;
    const float t=0.7978845608028654f*x;const float z=t*w;
    finite(u,"GELU u");finite(v,"GELU v");finite(w,"GELU w");finite(t,"GELU t");finite(z,"GELU z");
    const float h=::tanhf(z);const float r=1.0f+h;const float s=0.5f*x;const float y=s*r;
    finite(h,"GELU h");finite(y,"GELU output");return y;
}

struct Session {
    Frontend frontend;
    Pool pool;
    std::vector<uint8_t> embedding;
    std::vector<float> gamma,baked,scorer_bias,scorer_w,scorer_b,act_bias,act2_bias,act_w;
    std::unique_ptr<QWeights> scorer,act2;
    // General full-vocabulary post-LN row cache, valid only in this model Session.
    std::vector<float> row_cache;
    std::vector<uint8_t> valid;
    std::array<uint8_t,160> identity;
    std::map<std::pair<uint64_t,uint32_t>,std::array<uint8_t,512>> pending;
    std::map<uint64_t,uint32_t> used;
    std::vector<float> h0;
    std::map<std::string,std::vector<float>> checkpoints;
    std::string response,error;
    uint64_t cache_hits=0,cache_misses=0;
    uint64_t cache_fill_ns=0,cache_initialized_rows=0;
    uint64_t prepare_ns=0,ln_ns=0,scorer_ns=0,act_ns=0,finish_ns=0;
    std::mutex api_mutex;

    std::vector<uint8_t> tensor(int fd,const JsonValue& table,const char* name,unsigned bytes) {
        const auto& span=member(table,name);const auto& off=member(span,"offset");
        if(!off.is_number()||off.n<0||std::floor(off.n)!=off.n ||
           integer(member(span,"bytes"),"tensor bytes")!=static_cast<int>(bytes))
            throw Failure("IDENTITY_ERROR","tensor inventory span");
        std::vector<uint8_t> data(bytes);size_t done=0;
        while(done<bytes) {
            const ssize_t count=pread(fd,data.data()+done,bytes-done,static_cast<off_t>(off.n)+done);
            if(count<=0)throw Failure("IDENTITY_ERROR","short model tensor read");
            done+=count;
        }
        return data;
    }
    std::vector<float> f32(int fd,const JsonValue& table,const char* name,unsigned count) {
        const auto data=tensor(fd,table,name,count*4);std::vector<float> out(count);
        std::memcpy(out.data(),data.data(),data.size());for(float v:out)finite(v,"F32 model weight");return out;
    }
    Session(const JsonValue& config,int fd,const uint8_t* id):frontend(member(config,"frontend")),
        row_cache(50368ull*1024),valid(50368,0),h0(128*1024) {
        std::memcpy(identity.data(),id,160);
        const auto& table=member(config,"tensors");
        embedding=tensor(fd,table,"tok_emb.weight",50368*1088);
        gamma=f32(fd,table,"emb_norm_w",1024);
        baked=f32(fd,table,"linear_120_baked_bias",1024);
        scorer_bias=f32(fd,table,"scorer_fc1.bias",1024);
        scorer_w=f32(fd,table,"scorer_fc2.weight",1024);scorer_b=f32(fd,table,"scorer_fc2.bias",1);
        scorer=std::make_unique<QWeights>(tensor(fd,table,"scorer_fc1.weight",1024*1088),1024,1024);
        act2=std::make_unique<QWeights>(tensor(fd,table,"act_fc2.weight",2*8*34),2,256);
        act_bias=f32(fd,table,"act_fc1.bias",256);act2_bias=f32(fd,table,"act_fc2.bias",2);
        const auto half=tensor(fd,table,"act_fc1.weight",256*1028*2);
        act_w.resize(256*1028);
        // Expand F16 exactly once, transpose only independent output lanes.
        for(unsigned n=0;n<256;++n)for(unsigned k=0;k<1028;++k) {
            uint16_t bits;std::memcpy(&bits,half.data()+(n*1028+k)*2,2);
            const float v=laya::numeric_half_to_f32(bits);finite(v,"ACT F16 model weight");
            act_w[k*256+n]=v;
        }
        const auto mode=member(config,"cache_mode").s;
        if(mode!="full"&&mode!="lazy")throw Failure("IDENTITY_ERROR","cache mode must be full/lazy");
        if(mode=="full") {
            const auto fill_start=Clock::now();
            pool.run([&](unsigned worker) {
                float raw[1024];
                for(unsigned token=worker;token<50368;token+=4) {
                    checked(laya::full::embedding_row(embedding.data()+token*1088,raw),"full cache embedding");
                    strict_ln(raw,gamma.data(),row_cache.data()+token*1024);
                }
            });
            std::fill(valid.begin(),valid.end(),1);
            cache_initialized_rows=50368;cache_fill_ns=ns(fill_start);
        }
        // Original GPT2 tokenizer builds its static regex on the first nonempty
        // call. Finish that model-independent setup before Session is ready.
        // Discard the result; no request/sequence or answer cache is introduced.
        (void)frontend.tokenizer.encode("a",0,false,false);
    }
    std::pair<uint64_t,uint32_t> validate_request(const uint8_t* request) {
        const uint8_t magic[8]={'L','A','Y','A','M','7',0,0};
        if(std::memcmp(request,magic,8)||request[8]!=1||request[9]!=0||request[10]!=0||request[11]!=2||
           u32(request+12)!=1 || std::memcmp(request+80,identity.data(),160))
            throw Failure("IDENTITY_ERROR","request wire/schema/Session identity");
        const unsigned type=u32(request+28),count=u32(request+32);
        if(type>2||count<1||count>16||(type==2&&count!=2))throw Failure("CANDIDATE_ERROR","request qtype/count");
        if(u32(request+36)||u32(request+40)||u32(request+44))throw Failure("FRAME_ERROR","request status/reserved");
        const uint64_t a=u64(request+48),al=u64(request+56),b=u64(request+64),bl=u64(request+72);
        if(al!=524288||bl!=69632||a%64||b%64||a>UINT64_MAX-al||b>UINT64_MAX-bl||
           !(a+al<=b||b+bl<=a))throw Failure("FRAME_ERROR","request address/span");
        for(unsigned i=448;i<512;++i)if(request[i])throw Failure("FRAME_ERROR","request reserved bytes");
        unsigned active=0,attention=0;
        for(unsigned i=0;i<128;++i) {if(request[240+i]>1)throw Failure("FRAME_ERROR","attention mask");attention+=request[240+i];}
        for(unsigned i=0;i<16;++i) {
            const auto m=request[432+i];const int32_t pos=static_cast<int32_t>(u32(request+368+i*4));
            if(m>1||(!m&&pos!=0)||(m&&(pos<0||pos>=128||!request[240+pos])))throw Failure("FRAME_ERROR","marker domain");
            active+=m;
        }
        if(!attention||active!=count)throw Failure("FRAME_ERROR","request mask/count");
        return {u64(request+16),u32(request+24)};
    }
    void prepare(const int32_t* ids,const uint8_t* request,float* output) {
        const auto start=Clock::now();auto key=validate_request(request);
        if(pending.size()>=64||pending.count(key)||(used.count(key.first)&&key.second<=used[key.first]))
            throw Failure("IDENTITY_ERROR","duplicate/stale request generation or pending capacity");
        std::vector<unsigned> misses;
        for(unsigned row=0;row<128;++row) {
            const int id=ids[row];if(id<0||id>=50368)throw Failure("TOKEN_ERROR","token outside vocabulary");
            if(!valid[id]&&std::find(misses.begin(),misses.end(),unsigned(id))==misses.end())misses.push_back(id);
        }
        if(!misses.empty())pool.run([&](unsigned worker) {
            float raw[1024];
            for(unsigned i=worker;i<misses.size();i+=4) {
                const unsigned token=misses[i];
                checked(laya::full::embedding_row(embedding.data()+token*1088,raw),"embedding");
                strict_ln(raw,gamma.data(),row_cache.data()+token*1024);
            }
        });
        for(unsigned token:misses)valid[token]=1;
        cache_misses+=misses.size();cache_hits+=128-misses.size();
        for(unsigned row=0;row<128;++row)std::memcpy(h0.data()+row*1024,row_cache.data()+ids[row]*1024,4096);
        std::array<uint8_t,512> bytes;std::memcpy(bytes.data(),request,512);
        pending.emplace(key,bytes);used[key.first]=key.second;
        std::memcpy(output,h0.data(),h0.size()*4);prepare_ns=ns(start);
    }
    void keep(const char* name,const float* x,size_t count) {checkpoints[name]=std::vector<float>(x,x+count);}
    void finish(const uint8_t* request,const float* tail,float* output,bool trace) {
        checkpoints.clear();
        const auto start=Clock::now();auto key=validate_request(request);
        const auto entry=pending.find(key);
        if(entry==pending.end()||std::memcmp(entry->second.data(),request,512))
            throw Failure("IDENTITY_ERROR","finish is not the same prepared request/generation");
        for(unsigned i=0;i<17*1024;++i)finite(tail[i],"tail input");
        float norm[16][1024],baked_out[16][1024],hidden[16][1024],candidate[16],masked[16],prob[1024],stats[4];
        auto phase=Clock::now();
        pool.run([&](unsigned worker) {for(unsigned row=worker;row<16;row+=4) {
            strict_ln(tail+row*1024,nullptr,norm[row]);
        }});ln_ns=ns(phase);phase=Clock::now();
        pool.run([&](unsigned worker) {for(unsigned row=worker;row<16;row+=4) {
            qlinear(norm[row],*scorer,baked.data(),baked_out[row]);
            for(unsigned n=0;n<1024;++n) {const float z=baked_out[row][n]+scorer_bias[n];finite(z,"scorer second bias");hidden[row][n]=gelu(z);}
            checked(laya::full::fp_scorer_row(hidden[row],scorer_w.data(),scorer_b[0],candidate[row]),"scorer FP FC2");
        }});scorer_ns=ns(phase);
        checked(laya::full::candidate_mask(candidate,request+432,masked),"candidate mask");
        checked(laya::full::softmax_row(masked,16,prob),"candidate softmax");
        checked(laya::full::candidate_stats(prob,u32(request+32),stats),"candidate stats");
        phase=Clock::now();
        float input[1028],act_dot[256]={},act_hidden[256],act[2],logits[18];
        checked(laya::full::concat_act_row(tail+16*1024,stats,input),"raw CLS concat");
        // SIMD only across independent output n; every output sees K ascending.
        for(unsigned k=0;k<1028;++k)for(unsigned n=0;n<256;n+=16) {
            const auto product=_mm512_mul_ps(_mm512_set1_ps(input[k]),_mm512_loadu_ps(act_w.data()+k*256+n));finite16(product,"ACT product");
            const auto acc=_mm512_add_ps(_mm512_loadu_ps(act_dot+n),product);finite16(acc,"ACT accumulator");
            _mm512_storeu_ps(act_dot+n,acc);
        }
        for(unsigned n=0;n<256;++n) {const float z=act_dot[n]+act_bias[n];finite(z,"ACT bias");act_hidden[n]=gelu(z);}
        qlinear(act_hidden,*act2,act2_bias.data(),act);act_ns=ns(phase);
        std::memcpy(logits,masked,16*4);std::memcpy(logits+16,act,2*4);
        if(trace) {
            keep("marker_gather",tail,16*1024);keep("marker_norm",norm[0],16*1024);
            keep("scorer_fc1_baked",baked_out[0],16*1024);keep("scorer_post_bias_gelu",hidden[0],16*1024);
            keep("candidate_raw",candidate,16);keep("candidate_masked",masked,16);keep("candidate_prob",prob,16);
            keep("stats",stats,4);keep("act_input",input,1028);keep("act_dot",act_dot,256);
            keep("act_hidden",act_hidden,256);keep("act_logits",act,2);keep("final18",logits,18);keep("raw_cls",tail+16*1024,1024);
        }
        std::memcpy(output,logits,18*4);pending.erase(entry);finish_ns=ns(start);
    }
};

thread_local std::string global_error;
template<class Function> int invoke(Session* s,Function fn) {
    try {std::lock_guard<std::mutex> lock(s->api_mutex);CallerAffinity affinity;FloatEnvironment environment;fn();s->error.clear();return 0;}
    catch(const Failure& e){s->error=e.code+": "+e.what();return 1;}
    catch(const std::exception& e){s->error=std::string("NATIVE_ERROR: ")+e.what();return 1;}
}
}

#pragma GCC visibility push(default)
extern "C" {
void* m007_create(const char* config,int fd,const uint8_t* identity) {
    try {CallerAffinity affinity;FloatEnvironment environment;auto s=new Session(laya::JsonParser::parse_string(config),fd,identity);global_error.clear();return s;}
    catch(const std::exception& e){global_error=e.what();return nullptr;}
}
void m007_destroy(void* handle){delete static_cast<Session*>(handle);}
const char* m007_error(void* handle){return handle?static_cast<Session*>(handle)->error.c_str():global_error.c_str();}
int m007_json(void* handle,const char* command,const char** response){auto* s=static_cast<Session*>(handle);return invoke(s,[&] {
    const auto value=laya::JsonParser::parse_string(command);const auto op=member(value,"op").s;
    const auto result=op=="encode"?s->frontend.encode(value):op=="decode"?s->frontend.decode(value):throw Failure("JSON_ERROR","unknown operation");
    s->response=laya::json_dumps(result);*response=s->response.c_str();});}
int m007_prepare(void* handle,const int32_t* ids,const uint8_t* request,float* output){auto* s=static_cast<Session*>(handle);return invoke(s,[&]{s->prepare(ids,request,output);});}
int m007_finish(void* handle,const uint8_t* request,const float* tail,float* output,int trace){auto* s=static_cast<Session*>(handle);return invoke(s,[&]{s->finish(request,tail,output,trace!=0);});}
int m007_cancel(void* handle,const uint8_t* request){auto* s=static_cast<Session*>(handle);return invoke(s,[&]{const auto key=s->validate_request(request);const auto it=s->pending.find(key);if(it==s->pending.end()||std::memcmp(it->second.data(),request,512))throw Failure("IDENTITY_ERROR","cancel request mismatch");s->pending.erase(it);});}
size_t m007_checkpoint(void* handle,const char* name,float* output,size_t capacity){auto* s=static_cast<Session*>(handle);const auto it=s->checkpoints.find(name);if(it==s->checkpoints.end())return 0;const auto count=it->second.size();if(output&&capacity>=count)std::memcpy(output,it->second.data(),count*4);return count;}
void m007_metrics(void* handle,uint64_t* values){auto* s=static_cast<Session*>(handle);values[0]=s->cache_hits;values[1]=s->cache_misses;values[2]=s->prepare_ns;values[3]=s->ln_ns;values[4]=s->scorer_ns;values[5]=s->act_ns;values[6]=s->finish_ns;values[7]=s->pending.size();}
void m007_cache_info(void* handle,uint64_t* values){auto* s=static_cast<Session*>(handle);values[0]=s->cache_initialized_rows;values[1]=s->cache_fill_ns;}
int m007_fenv(unsigned* values){values[0]=fegetround();values[1]=_mm_getcsr();return 0;}
// Diagnostic of the exact same dot primitive, also covering signed -128 even
// though production Q8-F activation/weight validation rejects that value.
void m007_dot32_diagnostic(const int8_t* activation,const int8_t* weights,int32_t* output) {
    alignas(64) int8_t packed[8*64];alignas(64) int32_t correction[16];
    for(unsigned n=0;n<16;++n) {
        int sum=0;
        for(unsigned k=0;k<32;++k) {const int8_t w=weights[n*32+k];sum+=w;packed[(k/4)*64+n*4+k%4]=w;}
        correction[n]=128*sum;
    }
    _mm512_storeu_si512(output,dot_group16(activation,packed,correction));
}
}
#pragma GCC visibility pop
