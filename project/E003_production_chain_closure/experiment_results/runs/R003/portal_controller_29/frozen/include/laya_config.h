#pragma once
#include <cstdint>

namespace laya {
constexpr uint16_t kAbiMajor = 1, kAbiMinor = 0;
constexpr uint32_t kRequestHeaderBytes = 128, kDirectoryBytes = 32;
constexpr uint32_t kRequestPayloadOffset = 320, kRequestLimit = 16384;
constexpr uint32_t kResultOffset = 16384, kResultCapacity = 4096, kResultBytes = 384;
constexpr uint16_t kHidden = 1024, kHeads = 16, kHeadDim = 64;
constexpr uint16_t kGroup = 32, kTileRows = 16, kTileCols = 8;
constexpr uint16_t kCandidates = 16, kVocab = 50368;
constexpr uint8_t kBoCount = 13;
constexpr uint32_t kMaxEpoch = 0xfffffffeu;
static_assert(sizeof(uint8_t)==1 && sizeof(uint16_t)==2 && sizeof(uint32_t)==4 && sizeof(uint64_t)==8, "fixed integer widths required");
}
