#include "host_session_policy.h"
#include "laya_model_layout_generated.h"

#include <atomic>
#include <filesystem>
#include <stdexcept>
#include <utility>

namespace laya::host {
namespace {

constexpr unsigned kModelPorts[5] = {0, 2, 3, 4, 5};
constexpr const char* kModelFiles[5] = {
    "embedding.bin", "w_q0.bin", "w_q1.bin", "w_scale.bin", "aux.bin"};
constexpr unsigned kWorkspacePorts[7] = {6, 7, 8, 9, 10, 11, 12};
constexpr uint64_t kWorkspaceBytes[7] = {
    32ull << 20, 32ull << 20, 16ull << 20, 16ull << 20,
    48ull << 20, 24ull << 20, 16ull << 20};
constexpr uint64_t kIoBytes = 32768;
constexpr Tag kFe067Build = {0xfe, 0x06, 0x7c, 0x8a, 0xa0, 0x62, 0x7a, 0xd7,
                            0x70, 0x09, 0x6f, 0x97, 0x21, 0x39, 0x46, 0x45};
static_assert(uint64_t(full::kFullModelBoSizes[0]) +
                  full::kFullModelBoSizes[1] + full::kFullModelBoSizes[2] +
                  full::kFullModelBoSizes[3] + full::kFullModelBoSizes[4] ==
              448923648ull);

bool finite_bits(uint32_t bits) { return (bits & 0x7f800000u) != 0x7f800000u; }

Outcome outcome(OutcomeCode code, std::string message, Check check = ok()) {
  Outcome value;
  value.code = code;
  value.check = check;
  value.message = std::move(message);
  return value;
}

}  // namespace

struct Session::RetainedBackend {
  explicit RetainedBackend(std::unique_ptr<EventBackend> value)
      : value(std::move(value)) {}
  std::unique_ptr<EventBackend> value;
  RetainedBackend* next = nullptr;
};

Identity fe067_identity() {
  Identity out;
  for (unsigned i = 0; i < 16; ++i) {
    out.model[i] = full::kFullModelTag[i];
    out.numeric[i] = full::kFullNumericTag[i];
    out.layout[i] = full::kFullLayoutTag[i];
    out.build[i] = full::kFullBuildTag[i];
  }
  if (out.build != kFe067Build)
    throw std::logic_error("generated model package is not fe067");
  return out;
}

std::array<uint64_t, kPortCount> fe067_port_sizes() {
  return {full::kFullModelBoSizes[0], kIoBytes,
          full::kFullModelBoSizes[1], full::kFullModelBoSizes[2],
          full::kFullModelBoSizes[3], full::kFullModelBoSizes[4],
          kWorkspaceBytes[0], kWorkspaceBytes[1], kWorkspaceBytes[2],
          kWorkspaceBytes[3], kWorkspaceBytes[4], kWorkspaceBytes[5],
          kWorkspaceBytes[6]};
}

Session::Session(std::unique_ptr<EventBackend> backend)
    : retained_(std::make_unique<RetainedBackend>(std::move(backend))) {
  if (!retained_->value) throw std::invalid_argument("null event backend");
}

Session::~Session() noexcept { close(); }

EventBackend& Session::backend() noexcept { return *retained_->value; }

bool Session::initialize(const Attestation& attestation, std::string* error) {
  std::lock_guard<std::mutex> lock(mutex_);
  if (state_ != State::Cold) {
    if (error) *error = "session initialization is not Cold";
    return false;
  }
  try {
    const Identity expected = fe067_identity();
    const std::filesystem::path package(attestation.package_dir);
    if (package.filename() != "model-attention-rtl-repair-20261008" ||
        attestation.identity.model != expected.model ||
        attestation.identity.numeric != expected.numeric ||
        attestation.identity.layout != expected.layout ||
        attestation.identity.build != expected.build ||
        !attestation.manifest_verified ||
        !attestation.five_model_sha_verified ||
        !attestation.aux_header_verified ||
        !attestation.xclbin_sha_verified) {
      if (error) *error = "fe067 package attestation is incomplete";
      return false;
    }

    const auto sizes = fe067_port_sizes();
    for (unsigned i = 0; i < kPortCount; ++i)
      backend().allocate(i, sizes[i], backend().group_id(i));
    for (unsigned i = 0; i < 5; ++i)
      backend().upload_model(kModelPorts[i], kModelFiles[i],
                             sizes[kModelPorts[i]]);
    state_ = State::Ready;
    return true;
  } catch (const std::exception& ex) {
    state_ = State::Poisoned;
    if (error) *error = ex.what();
    return false;
  } catch (...) {
    state_ = State::Poisoned;
    if (error) *error = "unknown initialization failure";
    return false;
  }
}

void Session::finish(State next, bool quiescent) noexcept {
  bool should_close = false;
  {
    std::lock_guard<std::mutex> lock(mutex_);
    state_ = next;
    device_quiescent_ = quiescent;
    should_close = close_requested_;
  }
  if (should_close) close();
}

Outcome Session::run(const std::vector<uint8_t>& frame,
                     uint32_t timeout_ms) {
  {
    std::lock_guard<std::mutex> lock(mutex_);
    if (state_ == State::InFlight) return outcome(OutcomeCode::Busy, "InFlight");
    if (state_ != State::Ready)
      return outcome(OutcomeCode::Unavailable, "session is not Ready");
  }
  if (!timeout_ms)
    return outcome(OutcomeCode::PreflightRejected, "zero timeout");
  Request request;
  const Identity expected = fe067_identity();
  const Check parsed = parse_request(frame, request, &expected);
  if (!parsed)
    return outcome(OutcomeCode::PreflightRejected, "request ABI rejected", parsed);
  if (frame.size() != request.frame_bytes)
    return outcome(OutcomeCode::PreflightRejected, "request has trailing bytes",
                   {Status::E_BUFFER, detail(1, 16, 8), UINT64_MAX});
  {
    std::lock_guard<std::mutex> lock(mutex_);
    if (state_ == State::InFlight) return outcome(OutcomeCode::Busy, "InFlight");
    if (state_ != State::Ready)
      return outcome(OutcomeCode::Unavailable, "session is not Ready");
    if (has_submitted_ &&
        (request.generation < last_generation_ ||
         (request.generation == last_generation_ &&
          request.request_id <= last_request_id_)))
      return outcome(OutcomeCode::PreflightRejected,
                     "submitted identity is stale or exhausted",
                     {Status::E_PROTOCOL, detail(1, 24, 4), UINT64_MAX});
    state_ = State::InFlight;
  }

  const auto sizes = fe067_port_sizes();
  try {
    for (unsigned i = 0; i < 7; ++i) {
      backend().clear(kWorkspacePorts[i], kWorkspaceBytes[i]);
      backend().sync_h2d(kWorkspacePorts[i], 0, kWorkspaceBytes[i]);
    }
    backend().clear(kIoPort, kIoBytes);
    backend().write_request(frame.data(), frame.size());
    backend().sync_h2d(kIoPort, 0, sizes[kIoPort]);
  } catch (const std::exception& ex) {
    finish(State::Poisoned, true);
    return outcome(OutcomeCode::DeviceFault,
                   std::string("prestart backend failure: ") + ex.what());
  } catch (...) {
    finish(State::Poisoned, true);
    return outcome(OutcomeCode::DeviceFault, "unknown prestart backend failure");
  }

  // start() can submit and then throw. Consume the supplied identity and move
  // device ownership before crossing that call boundary.
  {
    std::lock_guard<std::mutex> lock(mutex_);
    has_submitted_ = true;
    last_generation_ = request.generation;
    last_request_id_ = request.request_id;
    device_quiescent_ = false;
  }
  try {
    backend().start();
    const WaitState waited = backend().wait(timeout_ms);
    if (waited == WaitState::Timeout) {
      bool terminal = false;
      try {
        const AbortState aborted = backend().abort();
        terminal = aborted == AbortState::Completed ||
                   aborted == AbortState::Aborted;
      } catch (...) {
        finish(State::Poisoned, false);
        return outcome(OutcomeCode::Timeout,
                       "timeout; abort threw with unknown ownership");
      }
      finish(State::Poisoned, terminal);
      return outcome(OutcomeCode::Timeout,
                     terminal ? "timeout; abort reached terminal state"
                              : "timeout; abort did not prove terminal state");
    }
    if (waited != WaitState::Completed) {
      finish(State::Poisoned, waited == WaitState::TerminalError);
      return outcome(OutcomeCode::DeviceFault,
                     waited == WaitState::TerminalError
                         ? "terminal device error" : "unknown wait state");
    }
    {
      std::lock_guard<std::mutex> lock(mutex_);
      device_quiescent_ = true;
    }
    backend().sync_d2h(kIoPort, kResultOffset, kResultBytes);
    auto bytes = backend().read_result(kResultOffset, kResultBytes);
    diagnostic_result_ = bytes;
    if (bytes.size() != kResultBytes) {
      finish(State::Poisoned, true);
      return outcome(OutcomeCode::InvalidResult,
                     "result is not exactly 384 bytes",
                     {Status::E_ABI, detail(1, 12, 8), UINT64_MAX});
    }
    Result result;
    const Check decoded = decode_result(bytes, result, &expected);
    if (!decoded) {
      finish(State::Poisoned, true);
      return outcome(OutcomeCode::InvalidResult, "result ABI rejected", decoded);
    }
    if (result.request_id != request.request_id ||
        result.generation != request.generation ||
        result.batch != request.batch || result.seq_len != request.seq_len) {
      finish(State::Poisoned, true);
      return outcome(OutcomeCode::InvalidResult,
                     "result identity or shape differs from request",
                     {Status::E_PROTOCOL, detail(1, 24, 4), UINT64_MAX});
    }
    if (result.status == Status::OK) {
      for (unsigned i = 0; i < 16u * result.batch; ++i)
        if (!finite_bits(result.candidate_bits[i])) {
          finish(State::Poisoned, true);
          return outcome(OutcomeCode::InvalidResult,
                         "nonfinite candidate output",
                         {Status::E_NUMERICAL, detail(3, 1, 4), i});
        }
      for (unsigned i = 0; i < 2u * result.batch; ++i)
        if (!finite_bits(result.act_bits[i])) {
          finish(State::Poisoned, true);
          return outcome(OutcomeCode::InvalidResult,
                         "nonfinite act output",
                         {Status::E_NUMERICAL, detail(3, 2, 4), i});
        }
    }
    finish(State::Ready, true);
    Outcome delivered = outcome(result.status == Status::OK ? OutcomeCode::Ok
                                                            : OutcomeCode::ErrorFrame,
                                result.status == Status::OK
                                    ? "validated OK frame"
                                    : "validated nonOK frame");
    delivered.result = result;
    delivered.has_result = true;
    return delivered;
  } catch (const std::exception& ex) {
    bool terminal;
    {
      std::lock_guard<std::mutex> lock(mutex_);
      terminal = device_quiescent_;
    }
    finish(State::Poisoned, terminal);
    return outcome(OutcomeCode::DeviceFault,
                   std::string("submitted backend failure: ") + ex.what());
  } catch (...) {
    bool terminal;
    {
      std::lock_guard<std::mutex> lock(mutex_);
      terminal = device_quiescent_;
    }
    finish(State::Poisoned, terminal);
    return outcome(OutcomeCode::DeviceFault,
                   "unknown submitted backend failure");
  }
}

void Session::close() noexcept {
  std::unique_ptr<RetainedBackend> node;
  bool terminal;
  {
    std::lock_guard<std::mutex> lock(mutex_);
    if (state_ == State::Closed) return;
    if (state_ == State::InFlight) {
      close_requested_ = true;
      return;
    }
    terminal = device_quiescent_;
    state_ = State::Closed;
    node = std::move(retained_);
  }
  if (!node) return;
  if (terminal) {
    node->value->release_all();
  } else {
    // A backend with unconfirmed device ownership is intentionally retained
    // for the process lifetime. No destructor or BO release is issued.
    static std::atomic<RetainedBackend*> head{nullptr};
    RetainedBackend* raw = node.release();
    RetainedBackend* old = head.load(std::memory_order_relaxed);
    do { raw->next = old; }
    while (!head.compare_exchange_weak(old, raw,
                                       std::memory_order_release,
                                       std::memory_order_relaxed));
  }
}

State Session::state() const noexcept {
  std::lock_guard<std::mutex> lock(mutex_);
  return state_;
}

bool Session::device_quiescent() const noexcept {
  std::lock_guard<std::mutex> lock(mutex_);
  return device_quiescent_;
}

const std::vector<uint8_t>& Session::diagnostic_result() const noexcept {
  return diagnostic_result_;
}

}  // namespace laya::host
