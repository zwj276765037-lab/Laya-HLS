#include "laya_generated_provenance_ledger.h"
#include "laya_model_layout_generated.h"

#include <cstdlib>
#include <iostream>

using namespace laya;

namespace {

unsigned checks = 0;

void require(bool condition, const char* message) {
  ++checks;
  if (!condition) {
    std::cerr << "FULL_CURRENT_GENERATED_PROVENANCE_LEDGER_FAIL "
              << message << '\n';
    std::exit(1);
  }
}

void expect(Check actual, Status expected, const char* message) {
  if (actual.code != expected) {
    std::cerr << "FULL_CURRENT_GENERATED_PROVENANCE_LEDGER_STATUS actual="
              << unsigned(actual.code) << " expected=" << unsigned(expected)
              << " detail=" << actual.detail
              << " bad_element=" << actual.bad_element << '\n';
    require(false, message);
  }
  ++checks;
}

NumericIdentity identity(uint64_t request_id) {
  NumericIdentity result;
  result.request_id = request_id;
  result.generation = 73;
  result.B = 1;
  result.S = 64;
  for (unsigned i = 0; i < 16; ++i) {
    result.model_tag[i] = full::kFullModelTag[i];
    result.numeric_tag[i] = full::kFullNumericTag[i];
    result.layout_tag[i] = full::kFullLayoutTag[i];
    result.build_tag[i] = full::kFullBuildTag[i];
  }
  return result;
}

std::array<uint8_t, 416> model_identity() {
  portal::ModelBinding model;
  expect(portal::build_l13m_model_binding(model), Status::OK,
         "build canonical L13M");
  return model.identity;
}

provenance::OwnerDescriptor ordinary_descriptor(uint32_t epoch) {
  provenance::OwnerDescriptor descriptor;
  descriptor.target_ref = {Buffer::HIDDEN, 0, epoch};
  descriptor.stage = 2;
  descriptor.layer = 0;
  descriptor.batch = 255;
  descriptor.row_space = RowSpace::TOKEN;
  descriptor.rows = 64;
  descriptor.width = 1024;
  descriptor.content = Content::F32;
  descriptor.role = Bo::STATE0;
  descriptor.bo_span = 17ull * 1024 * 1024;
  descriptor.owner_base_offset = 0;
  descriptor.row_stride = 4096;
  descriptor.batch_stride = 4ull * 1024 * 1024;
  descriptor.owner_extent_span = 64ull * 4096;
  return descriptor;
}

provenance::OwnerDescriptor qkv_descriptor(uint8_t bank, uint32_t epoch) {
  provenance::OwnerDescriptor descriptor;
  descriptor.target_ref = {Buffer::QKV, bank, epoch};
  descriptor.stage = 2;
  descriptor.layer = 0;
  descriptor.batch = 255;
  descriptor.row_space = RowSpace::TOKEN;
  descriptor.rows = 64;
  descriptor.width = 64;
  descriptor.content = Content::QKV_RAW;
  descriptor.layout = 1;
  descriptor.role = bank ? Bo::QKV1 : Bo::QKV0;
  descriptor.bo_span = 12ull * 1024 * 1024;
  descriptor.owner_base_offset = 0;
  descriptor.row_stride = 64ull * 4;
  descriptor.batch_stride = 8ull * 1024 * 64 * 4;
  descriptor.head_stride = 1024ull * 64 * 4;
  descriptor.plane_stride = 2ull * 8 * 1024 * 64 * 4;
  descriptor.owner_extent_span = 2 * descriptor.plane_stride +
      7 * descriptor.head_stride + 63 * descriptor.row_stride + 64 * 4;
  return descriptor;
}

provenance::Request owner_event(provenance::Action action, uint64_t sequence,
                                const NumericIdentity& id,
                                const provenance::OwnerDescriptor& first,
                                const provenance::OwnerDescriptor* second = nullptr) {
  provenance::Request request;
  request.action = action;
  request.event_seq = sequence;
  request.identity = id;
  request.model_identity = model_identity();
  request.descriptor_count = second ? 2 : 1;
  request.descriptor[0] = first;
  if (second) request.descriptor[1] = *second;
  return request;
}

provenance::Request begin_event(uint64_t sequence, uint32_t task_id,
                                const NumericIdentity& id,
                                const provenance::OwnerDescriptor& descriptor) {
  provenance::Request request = owner_event(
      provenance::Action::CLAIM, sequence, id, descriptor);
  request.action = provenance::Action::BEGIN;
  request.origin_seq = sequence;
  request.context = {task_id, Op::LN_ATTN, 2, 0, 0,
                     RowSpace::TOKEN, 0, 16};
  request.expected_unit = OutputUnit::F32;
  request.expected_elements = 16 * 1024;
  request.geometry[0].first_offset = descriptor.owner_base_offset;
  request.geometry[0].segment_bytes = 4096;
  request.geometry[0].row_count = 16;
  request.geometry[0].repeat_count = 1;
  request.geometry[0].row_step = 4096;
  request.geometry[0].total_write_bytes = 16ull * 4096;
  request.geometry[0].component = provenance::Component::FULL_WIDTH;
  request.geometry[0].head = 255;
  return request;
}

provenance::Request end_event(const provenance::Request& begin,
                              uint64_t sequence, Status status = Status::OK,
                              uint64_t issued = 16ull * 4096) {
  provenance::Request request = begin;
  request.action = provenance::Action::END;
  request.event_seq = sequence;
  request.origin_seq = begin.event_seq;
  request.reported_status = status;
  request.reported_unit = status == Status::OK ? OutputUnit::F32 :
                                                 OutputUnit::NONE;
  request.reported_elements = status == Status::OK ?
                              begin.expected_elements : 0;
  request.reported_error_detail = status == Status::OK ? 0 :
                                  laya::detail(7, uint8_t(begin.context.op), 7);
  request.reported_bad_element = status == Status::OK ? 0 : 19;
  request.issued_store_bytes[0] = issued;
  return request;
}

provenance::PhysicalObservation physical(uint64_t observed = 0,
                                          bool coverage = true) {
  provenance::PhysicalObservation result;
  result.observed_store_bytes[0] = observed;
  result.coverage_complete = coverage;
  return result;
}

unsigned active_owners(const provenance::LedgerState& ledger) {
  unsigned count = 0;
  for (const provenance::LedgerOwner& owner : ledger.owner)
    if (owner.occupied && owner.active) ++count;
  return count;
}

} // namespace

int main() {
  using namespace laya::provenance;
  LedgerState ledger;
  Response response;
  const NumericIdentity first_id = identity(901);
  const OwnerDescriptor epoch1 = ordinary_descriptor(1);

  Request claim = owner_event(Action::CLAIM, 1, first_id, epoch1);
  expect(ledger_handle(ledger, claim, physical(), response), Status::OK,
         "CLAIM owner");
  require(active_owners(ledger) == 1 && ledger.last_event_seq == 1,
          "CLAIM installs one owner");

  Request begin = begin_event(2, 1, first_id, epoch1);
  expect(ledger_handle(ledger, begin, physical(), response), Status::OK,
         "BEGIN owner task");
  require(ledger.scope_active && response.scope_active,
          "BEGIN installs active scope");
  Request end = end_event(begin, 3);
  expect(ledger_handle(ledger, end, physical(16ull * 4096), response),
         Status::OK, "END owner task");
  require(!ledger.scope_active && response.output_elements == 16 * 1024 &&
              response.unit == OutputUnit::F32,
          "END retires successful task");

  Request publish = owner_event(Action::PUBLISH, 4, first_id, epoch1);
  expect(ledger_handle(ledger, publish, physical(0, false), response),
         Status::E_BUFFER, "incomplete PUBLISH rejected");
  require(!ledger.owner[0].published && ledger.last_event_seq == 4,
          "failed PUBLISH consumes sequence without publication");
  publish.event_seq = 5;
  expect(ledger_handle(ledger, publish, physical(), response), Status::OK,
         "complete PUBLISH accepted");
  require(ledger.owner[0].published && response.owner_published,
          "PUBLISH records owner state");
  expect(ledger_handle(ledger, publish, physical(), response),
         Status::E_PROTOCOL, "event sequence replay rejected");
  require(ledger.last_event_seq == 5 && ledger.owner[0].published,
          "replay does not mutate owner");

  Request release = owner_event(Action::RELEASE, 6, first_id, epoch1);
  expect(ledger_handle(ledger, release, physical(), response), Status::OK,
         "RELEASE published owner");
  require(!ledger.owner[0].active && ledger.owner[0].max_epoch == 1,
          "RELEASE preserves epoch high-water");

  const OwnerDescriptor epoch2 = ordinary_descriptor(2);
  claim = owner_event(Action::CLAIM, 7, first_id, epoch2);
  expect(ledger_handle(ledger, claim, physical(), response), Status::OK,
         "higher epoch CLAIM after RELEASE");
  Request wrong = begin_event(8, 2, first_id, ordinary_descriptor(3));
  expect(ledger_handle(ledger, wrong, physical(), response), Status::E_BUFFER,
         "BEGIN wrong descriptor rejected");
  require(!ledger.scope_active, "wrong descriptor does not install scope");

  Request overlapping = begin_event(9, 2, first_id, epoch2);
  overlapping.geometry[0].row_step = 4;
  expect(ledger_handle(ledger, overlapping, physical(), response),
         Status::E_PROTOCOL, "overlapping geometry rejected");
  require(!ledger.scope_active && ledger.last_event_seq == 9,
          "overlap consumes sequence without scope");

  begin = begin_event(10, 2, first_id, epoch2);
  expect(ledger_handle(ledger, begin, physical(), response), Status::OK,
         "second BEGIN accepted");
  Request bad_end = end_event(begin, 11);
  bad_end.origin_seq = begin.event_seq - 1;
  expect(ledger_handle(ledger, bad_end, physical(16ull * 4096), response),
         Status::E_PROTOCOL, "bad END origin rejected");
  require(ledger.scope_active && response.scope_active,
          "bad END origin retains active scope");

  Request mismatched_end = end_event(begin, 12);
  expect(ledger_handle(ledger, mismatched_end, physical(0), response),
         Status::E_PROTOCOL, "unretired END store count rejected");
  require(ledger.scope_active, "store mismatch retains active scope");

  Request failed_end = end_event(begin, 13, Status::E_NUMERICAL, 4096);
  expect(ledger_handle(ledger, failed_end, physical(4096, false), response),
         Status::E_NUMERICAL, "drained logical failure closes once");
  require(!ledger.scope_active && ledger.owner[0].invalid,
          "failed END invalidates owner and closes scope");
  failed_end.event_seq = 14;
  expect(ledger_handle(ledger, failed_end, physical(4096, false), response),
         Status::E_PROTOCOL, "closed END cannot retire twice");

  Request invalidate = owner_event(Action::INVALIDATE, 15, first_id, epoch2);
  expect(ledger_handle(ledger, invalidate, physical(), response), Status::OK,
         "INVALIDATE failed owner");
  require(!ledger.owner[0].active, "INVALIDATE frees active identity");

  const NumericIdentity recovery_id = identity(902);
  const OwnerDescriptor epoch3 = ordinary_descriptor(3);
  claim = owner_event(Action::CLAIM, 16, recovery_id, epoch3);
  claim.model_identity[0] ^= 1;
  expect(ledger_handle(ledger, claim, physical(), response), Status::E_MODEL,
         "mutated model identity rejected");
  require(ledger.last_event_seq == 16 && !ledger.owner[0].active,
          "model rejection consumes fresh sequence without owner");
  claim.model_identity = model_identity();
  expect(ledger_handle(ledger, claim, physical(), response),
         Status::E_PROTOCOL, "model-rejected sequence cannot be replayed");
  claim.event_seq = 17;
  expect(ledger_handle(ledger, claim, physical(), response), Status::OK,
         "same-session higher request recovers");
  begin = begin_event(18, 1, recovery_id, epoch3);
  expect(ledger_handle(ledger, begin, physical(), response), Status::OK,
         "new NumericIdentity has independent typed high-water");
  end = end_event(begin, 19);
  expect(ledger_handle(ledger, end, physical(16ull * 4096), response),
         Status::OK, "recovery END accepted");

  LedgerState qkv_ledger;
  const OwnerDescriptor qkv0 = qkv_descriptor(0, 1);
  const OwnerDescriptor qkv1 = qkv_descriptor(1, 1);
  Request qkv_claim = owner_event(Action::CLAIM, 1, first_id, qkv0, &qkv1);
  expect(ledger_handle(qkv_ledger, qkv_claim, physical(), response),
         Status::OK, "atomic QKV pair CLAIM");
  require(active_owners(qkv_ledger) == 2,
          "QKV pair CLAIM installs both owners");

  Request malformed_pair = owner_event(Action::CLAIM, 2, first_id,
                                       qkv0, &qkv0);
  expect(ledger_handle(qkv_ledger, malformed_pair, physical(), response),
         Status::E_PROTOCOL, "duplicate-bank QKV pair rejected");
  require(active_owners(qkv_ledger) == 2,
          "bad QKV pair leaves prior pair unchanged");

  Request qkv_publish = owner_event(Action::PUBLISH, 3, first_id,
                                    qkv0, &qkv1);
  expect(ledger_handle(qkv_ledger, qkv_publish, physical(), response),
         Status::OK, "atomic QKV pair PUBLISH");
  qkv_ledger.owner[1].invalid = true;
  Request qkv_release = owner_event(Action::RELEASE, 4, first_id,
                                    qkv0, &qkv1);
  expect(ledger_handle(qkv_ledger, qkv_release, physical(), response),
         Status::E_BUFFER, "inconsistent QKV RELEASE rejected atomically");
  require(qkv_ledger.owner[0].active && qkv_ledger.owner[0].published,
          "failed QKV RELEASE does not mutate first owner");
  qkv_ledger.owner[1].invalid = false;
  qkv_release.event_seq = 5;
  expect(ledger_handle(qkv_ledger, qkv_release, physical(), response),
         Status::OK, "consistent QKV RELEASE accepted");
  require(active_owners(qkv_ledger) == 0,
          "QKV RELEASE frees both owners");

  LedgerState qkv_invalidate_ledger;
  expect(ledger_handle(qkv_invalidate_ledger, qkv_claim, physical(), response),
         Status::OK, "QKV pair CLAIM before INVALIDATE");
  Request qkv_invalidate = owner_event(Action::INVALIDATE, 2, first_id,
                                       qkv0, &qkv1);
  expect(ledger_handle(qkv_invalidate_ledger, qkv_invalidate,
                       physical(), response),
         Status::OK, "atomic QKV pair INVALIDATE");
  require(active_owners(qkv_invalidate_ledger) == 0 &&
              qkv_invalidate_ledger.owner[0].invalid &&
              qkv_invalidate_ledger.owner[1].invalid,
          "QKV INVALIDATE marks both owners");

  std::cout << "FULL_CURRENT_GENERATED_PROVENANCE_LEDGER_PASS checks="
            << checks
            << " replay=1 scope_retention=2 failed_end_once=1"
            << " same_session_recovery=1 qkv_atomic=1\n";
  return 0;
}
