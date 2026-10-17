#include "forward_controller.h"
#include <cstdlib>
#include <iostream>
using namespace laya;
unsigned count=0;
template<class T> void need(T x){++count;if(!bool(x)){std::cerr<<"RESET_REVIEW_FAIL check="<<count<<'\n';std::exit(1);}}
int main(){
 ForwardController f;
 BufferRef old{Buffer::SCORE_PROB,0,1},pending{Buffer::SCORE_PROB,0,2},fresh{Buffer::SCORE_PROB,0,3};
 need(f.reserve(old,0,1,Content::SCORE));
 need(f.cover(old,0,0,1));
 need(f.publish(old,0,true));
 need(f.begin_inplace(old,pending,0,1,Content::PROB));
 f.reset();
 need(!f.reserve(old,0,1,Content::SCORE));
 need(!f.reserve(pending,0,1,Content::SCORE));
 need(f.reserve(fresh,0,1,Content::SCORE));
 need(f.cover(fresh,0,0,1));
 need(f.publish(fresh,0,true));
 need(!f.acquire_read(old,0,Content::SCORE));
 need(!f.acquire_read(pending,0,Content::SCORE));
 need(f.acquire_read(fresh,0,Content::SCORE));
 std::cout<<"ASTRA_RESET_PROBE_PASS checks="<<count<<'\n';
}
