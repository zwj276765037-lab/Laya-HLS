#pragma once

#include "laya_io.h"

#include <array>
#include <cstddef>
#include <cstdint>
#include <memory>
#include <mutex>
#include <string>
#include <vector>

namespace laya::host {

constexpr unsigned kPortCount = 13;
constexpr unsigned kIoPort = 1;

enum class State { Cold, Ready, InFlight, Poisoned, Closed };
enum class WaitState { Completed, Timeout, TerminalError, Unknown };
enum class AbortState { Completed, Aborted, Nonterminal, Unknown };
enum class OutcomeCode {
  Ok, ErrorFrame, PreflightRejected, Busy, InvalidResult, Timeout,
  DeviceFault, Unavailable
};

// A future XRT adapter must perform these checks against real files and the
// loaded xclbin. The portable core only checks the supplied attestation.
struct Attestation {
  std::string package_dir;
  Identity identity{};
  bool manifest_verified = false;
  bool five_model_sha_verified = false;
  bool aux_header_verified = false;
  bool xclbin_sha_verified = false;
};

struct Outcome {
  OutcomeCode code = OutcomeCode::Unavailable;
  Check check = ok();
  Result result{};
  bool has_result = false;
  std::string message;
};

// Methods record protocol events in the CPU backend. A real implementation
// must bind group_id to kernel metadata, make upload_model verify/upload/sync
// the named package file, and preserve BO ownership until a proven terminal.
class EventBackend {
 public:
  virtual ~EventBackend() = default;
  virtual unsigned group_id(unsigned arg_index) = 0;
  virtual void allocate(unsigned arg_index, uint64_t bytes, unsigned group) = 0;
  virtual void upload_model(unsigned arg_index, const char* file,
                            uint64_t bytes) = 0;
  virtual void clear(unsigned arg_index, uint64_t bytes) = 0;
  virtual void write_request(const uint8_t* bytes, size_t count) = 0;
  virtual void sync_h2d(unsigned arg_index, uint64_t offset,
                        uint64_t bytes) = 0;
  virtual void start() = 0;
  virtual WaitState wait(uint32_t timeout_ms) = 0;
  virtual AbortState abort() = 0;
  virtual void sync_d2h(unsigned arg_index, uint64_t offset,
                        uint64_t bytes) = 0;
  virtual std::vector<uint8_t> read_result(uint64_t offset,
                                           uint64_t bytes) = 0;
  virtual void release_all() noexcept = 0;
};

Identity fe067_identity();
std::array<uint64_t, kPortCount> fe067_port_sizes();

class Session {
 public:
  explicit Session(std::unique_ptr<EventBackend> backend);
  ~Session() noexcept;
  Session(const Session&) = delete;
  Session& operator=(const Session&) = delete;

  bool initialize(const Attestation& attestation, std::string* error = nullptr);
  Outcome run(const std::vector<uint8_t>& frame, uint32_t timeout_ms);
  void close() noexcept;
  State state() const noexcept;
  bool device_quiescent() const noexcept;
  const std::vector<uint8_t>& diagnostic_result() const noexcept;

 private:
  struct RetainedBackend;
  void finish(State next, bool device_quiescent) noexcept;
  EventBackend& backend() noexcept;

  std::unique_ptr<RetainedBackend> retained_;
  mutable std::mutex mutex_;
  State state_ = State::Cold;
  bool device_quiescent_ = true;
  bool close_requested_ = false;
  bool has_submitted_ = false;
  uint64_t last_generation_ = 0;
  uint64_t last_request_id_ = 0;
  std::vector<uint8_t> diagnostic_result_;
};

}  // namespace laya::host
