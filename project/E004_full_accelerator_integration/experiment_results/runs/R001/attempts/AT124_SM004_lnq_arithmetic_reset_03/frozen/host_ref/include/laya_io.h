#pragma once
#include "laya_types.h"
#include <array>
#include <vector>

namespace laya {
using Tag=std::array<uint8_t,16>;
struct Identity { Tag model{},numeric{},layout{},build{}; };
struct Directory { uint16_t tensor_id=0;uint8_t dtype=0,rank=0;uint32_t offset=0,byte_length=0;uint16_t dim0=0,dim1=0;uint32_t stride0=0,stride1=0,element_count=0; };
struct Request { uint64_t request_id=0,generation=0;uint16_t batch=0,seq_len=0;Identity identity{};std::array<Directory,5> dirs{};std::array<std::vector<uint8_t>,5> tensor{};uint32_t frame_bytes=0; };
struct Result { Status status=Status::OK;uint64_t request_id=0,generation=0;Identity identity{};uint16_t batch=0,seq_len=0;uint32_t flags=0,error_detail=0;uint16_t error_stage=0,error_operator=0;std::array<uint32_t,32> candidate_bits{};std::array<uint32_t,4> act_bits{};uint64_t prewrite_cycles=0,tasks_retired=0,accepted_input_elements=0,committed_output_elements=0,first_bad_element=UINT64_MAX;uint32_t error_task_id=0,counter_scope=0; };
uint16_t read_u16(const uint8_t*,size_t);uint32_t read_u32(const uint8_t*,size_t);uint64_t read_u64(const uint8_t*,size_t);
void write_u16(uint8_t*,size_t,uint16_t);void write_u32(uint8_t*,size_t,uint32_t);void write_u64(uint8_t*,size_t,uint64_t);
bool zero_tag(const Tag&);
Check parse_request(const std::vector<uint8_t>&,Request&,const Identity* expected=nullptr);
Check encode_request(const Request&,std::vector<uint8_t>&,const Identity* expected=nullptr);
Check decode_result(const std::vector<uint8_t>&,Result&,const Identity* expected=nullptr);
Check encode_result(const Result&,std::array<uint8_t,kResultBytes>&);
Check validate_result(const Result&);
}
