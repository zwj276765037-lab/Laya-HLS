#!/usr/bin/env python3
import pathlib,struct,json,hashlib
R=pathlib.Path(__file__).resolve().parent
P=R.parents[2]/'model/quantized/gguf/mys/laya-typed-decisions-GGUF/Q8_0/laya_typed_decisions_q8_0.gguf'
def main():
 f=P.open('rb')
 def read(fmt):return struct.unpack('<'+fmt,f.read(struct.calcsize('<'+fmt)))[0]
 def string():return f.read(read('Q')).decode('utf-8')
 formats={0:'B',1:'b',2:'H',3:'h',4:'I',5:'i',6:'f',7:'?',10:'Q',11:'q',12:'d'}
 def value(t):
  if t==8:return string()
  if t==9:
   a,n=read('I'),read('Q')
   for i in range(n):value(a)
   return {'array_dtype':a,'length':n}
  return read(formats[t])
 assert f.read(4)==b'GGUF';version=read('I');nt,nk=read('Q'),read('Q');kv={};kvhash={}
 for i in range(nk):
  key=string();t=read('I');start=f.tell();v=value(t);end=f.tell();f.seek(start);h=hashlib.sha256(f.read(end-start)).hexdigest();kvhash[key]=h;kv[key]=v
 tensors=[]
 for i in range(nt):
  name=string();nd=read('I');dims=[read('Q') for j in range(nd)];typ=read('I');off=read('Q');tensors.append({'name':name,'ggml_ne':dims,'ggml_type_id':typ,'relative_data_offset':off})
 align=kv.get('general.alignment',32);base=(f.tell()+align-1)//align*align
 for x in tensors:x['absolute_file_offset']=base+x['relative_data_offset']
 selected={k:{'value':v,'raw_metadata_sha256':kvhash[k]} for k,v in kv.items() if k.startswith('tokenizer.') and not isinstance(v,dict)}
 out={'gguf_version':version,'data_offset':base,'tokenizer_metadata':selected,'tokenizer_array_identities':{k:{**kv[k],'raw_metadata_sha256':kvhash[k]} for k in kv if k.startswith('tokenizer.') and isinstance(kv[k],dict)},'tensors':tensors}
 (R/'runs/typed_q8_ref_20261005/gguf_inventory.json').write_text(json.dumps(out,ensure_ascii=False,indent=2)+'\n')
 print(nt,nk,base)
if __name__=='__main__':main()
