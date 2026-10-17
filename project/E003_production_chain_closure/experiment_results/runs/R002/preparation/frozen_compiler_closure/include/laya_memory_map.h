#pragma once
#include "laya_tasks.h"
#include <array>
#include <cstdint>

namespace laya {
struct Span { Bo bo=Bo::IO;uint32_t base=0,bytes=0; };
struct Address { Bo bo=Bo::IO;uint32_t offset=0; };
struct Q8Descriptor { std::array<uint32_t,2> q_base{},q_span{};uint32_t scale_base=0,scale_span=0;uint16_t K=0,N=0; };
Check span(BufferRef,uint8_t region,Span&);
Check byte_address(BufferRef,uint8_t region,uint64_t relative,uint32_t size,Address&);
Check f32_address(BufferRef,uint8_t region,uint8_t batch,uint16_t row,uint16_t col,uint16_t B,uint16_t S,Address&);
Check qkv_address(uint8_t plane,uint8_t batch,uint8_t head,uint16_t token,uint8_t d,uint16_t B,uint16_t S,Address&);
Check marker_token_row(uint32_t marker,uint8_t batch,uint16_t S,uint16_t& physical_row);
Check q8_weight_addresses(const Q8Descriptor&,uint16_t n,uint16_t k,Address& q,Address& scale);
}
