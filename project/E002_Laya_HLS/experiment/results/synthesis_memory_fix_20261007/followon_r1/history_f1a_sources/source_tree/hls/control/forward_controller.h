#pragma once
#include "laya_memory_map.h"
#include <array>
#include <map>
#include <vector>

namespace laya {
struct BufferKey {Buffer id;uint8_t bank,region;bool operator<(const BufferKey& o)const{return std::array<unsigned,3>{unsigned(id),bank,region}<std::array<unsigned,3>{unsigned(o.id),o.bank,o.region};}};
struct BufferRecord {CacheState state=CacheState::FREE;uint32_t epoch=0,next_epoch=0;Content content=Content::UNDEFINED;std::vector<bool> covered;uint8_t readers=0;std::array<uint8_t,3> type_readers{};bool drained=false;uint8_t type_bits=0;};
class ForwardController {
 public:
  Check accept_task(uint32_t task_id);
  Check retire_task(const TaskDone&,uint32_t elements,OutputUnit unit);
  Check reserve(BufferRef,uint8_t region,uint16_t rows,Content);
  Check cover(BufferRef,uint8_t region,uint16_t first,uint16_t count);
  Check publish(BufferRef,uint8_t region,bool responses_drained);
  Check acquire_read(BufferRef,uint8_t region,Content expected);
  Check release_read(BufferRef,uint8_t region);
  Check acquire_type_read(BufferRef,uint8_t type_id);
  Check release_type_read(BufferRef,uint8_t type_id);
  Check validate_inputs(const LinearTask&)const;
  Check validate_inputs(const QKTask&)const;
  Check validate_inputs(const AVTask&)const;
  Check release_storage(BufferRef,uint8_t region);
  Check begin_inplace(BufferRef old_ref,BufferRef new_ref,uint8_t region,uint16_t rows,Content);
  Check publish_inplace(BufferRef new_ref,uint8_t region,bool responses_drained);
  Check type_row(BufferRef,uint8_t type_id);
  bool type_valid(BufferRef,uint8_t type_id)const;
  bool ready(BufferRef,uint8_t region)const;
  void reset();
 private:
  std::map<BufferKey,BufferRecord> records_;
  uint32_t active_=0,last_task_=0;
  BufferRecord* find(BufferRef,uint8_t);
  const BufferRecord* find(BufferRef,uint8_t)const;
  bool alias_busy(Buffer)const;
  Check expect_ready(BufferRef,uint8_t region,Content expected)const;
};
}
