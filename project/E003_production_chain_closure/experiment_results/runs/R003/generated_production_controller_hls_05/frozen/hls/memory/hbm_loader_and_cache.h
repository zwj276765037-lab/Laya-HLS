#pragma once
#include "laya_memory_map.h"
#include <vector>

namespace laya::hbm_loader_and_cache {
struct MemTransfer {uint32_t task_id=0;uint16_t segment=0;bool write=false;Bo bo=Bo::IO;uint32_t offset=0,byte_count=0;BufferRef cache;uint32_t cache_offset=0;bool last_segment=false;};
Check validate(const LoadTask&,uint16_t B,uint16_t S);
Check segment(const MemTransfer&,uint32_t bo_capacity,uint32_t cache_capacity,std::vector<MemTransfer>&);
}
