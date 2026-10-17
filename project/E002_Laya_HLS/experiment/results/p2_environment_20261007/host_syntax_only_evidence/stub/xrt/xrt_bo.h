#pragma once
#include <cstdint>
#include <cstddef>
#include "xrt_device.h"
enum xclBOSyncDirection { XCL_BO_SYNC_BO_TO_DEVICE, XCL_BO_SYNC_BO_FROM_DEVICE };
namespace xrt { class bo { public: bo(device&, std::size_t, int) {} template<class T> T map() { return {}; } void sync(xclBOSyncDirection,std::size_t,std::size_t) {} void read(void*,std::size_t,std::size_t) {} }; }
