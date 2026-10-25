// Generated from schema.json; do not edit.
// Host/SV wire contract only; XRT register mapping NOT_BOUND.
#pragma once
#include <array>
#include <cstdint>
namespace laya::m007 {
inline constexpr char SCHEMA_SHA256[] = "c3d8d192e26cc249a07818f73f2926181965fd460faa5ea140b28d689517d24c";
inline constexpr unsigned SCHEMA_VERSION = 1;
inline constexpr std::uint64_t MAGIC_LE = 0x0000374d4159414cULL;
inline constexpr unsigned METADATA_BYTES = 512;
inline constexpr unsigned TOKENS = 128;
inline constexpr unsigned HIDDEN = 1024;
inline constexpr unsigned MARKER_SLOTS = 16;
inline constexpr unsigned H0_BYTES = 524288;
inline constexpr unsigned TAIL_ROWS = 17;
inline constexpr unsigned TAIL_BYTES = 69632;
inline constexpr unsigned TAIL_ELEMENTS = 17408;
inline constexpr unsigned ADDRESS_ALIGNMENT = 64;
inline constexpr unsigned REQUEST = 1;
inline constexpr unsigned TAIL_READY = 2;
inline constexpr unsigned QTYPE_CHOICE = 0;
inline constexpr unsigned QTYPE_SCORE = 1;
inline constexpr unsigned QTYPE_NOUL = 2;
inline constexpr unsigned NOUL_CANDIDATES = 2;
inline constexpr unsigned OFF_MAGIC = 0;
inline constexpr unsigned OFF_VERSION = 8;
inline constexpr unsigned OFF_METADATA_BYTES = 10;
inline constexpr unsigned OFF_KIND = 12;
inline constexpr unsigned OFF_REQUEST_ID = 16;
inline constexpr unsigned OFF_GENERATION = 24;
inline constexpr unsigned OFF_QTYPE = 28;
inline constexpr unsigned OFF_CANDIDATE_COUNT = 32;
inline constexpr unsigned OFF_STATUS = 36;
inline constexpr unsigned OFF_COMPLETED_ELEMENTS = 40;
inline constexpr unsigned OFF_RESERVED0 = 44;
inline constexpr unsigned OFF_H0_ADDRESS = 48;
inline constexpr unsigned OFF_H0_SPAN = 56;
inline constexpr unsigned OFF_TAIL_ADDRESS = 64;
inline constexpr unsigned OFF_TAIL_SPAN = 72;
inline constexpr unsigned OFF_MODEL = 80;
inline constexpr unsigned OFF_GRAPH = 112;
inline constexpr unsigned OFF_NUMERIC = 144;
inline constexpr unsigned OFF_LAYOUT = 176;
inline constexpr unsigned OFF_BUILD = 208;
inline constexpr unsigned OFF_ATTENTION_MASK = 240;
inline constexpr unsigned OFF_MARKERS = 368;
inline constexpr unsigned OFF_MARKER_MASK = 432;
inline constexpr unsigned OFF_RESERVED1 = 448;
using Metadata = std::array<std::uint8_t, METADATA_BYTES>;
static_assert(H0_BYTES == TOKENS * HIDDEN * 4);
static_assert(TAIL_BYTES == TAIL_ROWS * HIDDEN * 4);
} // namespace laya::m007
