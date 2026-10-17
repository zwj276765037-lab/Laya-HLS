#pragma once
#include "laya_tasks.h"
#include <cstdlib>
#include <iostream>
namespace test {
template<class T> inline void require(const T& pass,const char* what){
  if(!static_cast<bool>(pass)){std::cerr<<"CONTRACT_FAIL "<<what<<'\n';std::exit(1);}
}
inline laya::BufferRef ref(laya::Buffer id,uint8_t bank=0,uint32_t epoch=1){return {id,bank,epoch};}
inline laya::TaskContext ctx(laya::Op op,uint8_t stage,uint8_t layer=255,laya::RowSpace space=laya::RowSpace::TOKEN,uint16_t row0=0,uint8_t rows=1){return {1,op,stage,layer,0,space,row0,rows};}
}
