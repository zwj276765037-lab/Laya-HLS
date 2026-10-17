#include "result_status.h"

namespace laya::result_status {
Check encode_contract(const Result& r,std::array<uint8_t,kResultBytes>& out){return encode_result(r,out);}
}
