#!/usr/bin/env python3
"""Static source reversal and independent single-credit observer protocol model."""
import argparse
import ctypes
import hashlib
import json
import os
from pathlib import Path
import re
import resource
import time


def sha(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()


def main():
    start = time.monotonic()
    ap = argparse.ArgumentParser()
    ap.add_argument('--root', type=Path, required=True)
    ap.add_argument('--out', type=Path, required=True)
    a = ap.parse_args()
    root, out = a.root.resolve(), a.out.resolve()
    out.mkdir(parents=True, exist_ok=False)
    resource.setrlimit(resource.RLIMIT_AS, (1024 ** 3, 1024 ** 3))
    affinity = sorted(os.sched_getaffinity(0))
    nice = os.getpriority(os.PRIO_PROCESS, 0)
    io = ctypes.CDLL(None).syscall(252, 1, 0)
    available = int(next(x.split()[1] for x in Path('/proc/meminfo').read_text().splitlines() if x.startswith('MemAvailable:')))
    assert affinity and set(affinity) <= set(range(4)) and nice == 19 and io >> 13 == 3
    assert available > 192 * 1024 * 1024
    r = root / 'project/E016_m007_single_resource_parent/experiment_results/runs/R007'
    m = root / 'project/E002_Laya_HLS/experiment/vivado/module_design/forward_controller'
    versions = []
    for name, old, expected in [('m007_fullmodel_encoder_1d_tb.sv', r/'prepared/encoder_1d_residual_pack_v2/frozen/m007_fullmodel_encoder_1d_tb.sv', '172d301937532841baaa938e45eb2f48913b7821b60bb6776671ba52f6d5d555'), ('m007_fullmodel_encoder_binary_tb.sv', r/'prepared/binary_encoder_residual_pack_v2/frozen/m007_fullmodel_encoder_binary_tb.sv', '246c2d6a17d3fa2a916eb9ea5ac66cf2ff21b83a3efab14c634d0fe97c208790')]:
        new = m/'tb'/name
        before, after = old.read_text(), new.read_text()
        assert sha(old) == expected
        rd = next(x for x in before.splitlines(True) if 'if(dut.c_rd_valid&&dut.c_rd_ready)begin if(ctx_owned||' in x)
        rsp = next(x for x in before.splitlines(True) if 'if(dut.c_rsp_valid&&dut.c_rsp_ready)begin int q,h,half;' in x)
        assert before.count(rd+rsp) == 1 and after.count(rsp+rd) == 1
        assert after.replace(rsp+rd, rd+rsp, 1) == before
        versions.append({'source': str(new.relative_to(root)), 'sha256': sha(new), 'previous_source': str(old.relative_to(root)), 'previous_sha256': sha(old), 'only_two_original_if_blocks_reordered': True, 'all_predicates_payload_checks_clocks_delays_gold_loads_and_peer_text_preserved': True})
    adapter = m/'rtl/laya_m007_context_quant_adapter_v1.sv'
    text = adapter.read_text()
    assert '(!pending||(rsp_fire&&matching))' in text
    assert 'if(rd_fire)begin pending<=1;pending_coordinate<=accepted_reads[11:0];accepted_reads<=accepted_reads+1;end' in text
    assert 'else if(rsp_fire)pending<=0;' in text

    def observe(state, response=None, read=None, old_order=False):
        owned, pending, reads, responses = state
        for action in (('read', 'response') if old_order else ('response', 'read')):
            if action == 'response' and response is not None:
                tag, payload = response
                assert owned and tag == pending, 'response without its old credit/tag'
                assert payload == tuple(32*pending+k for k in range(32)), 'wrong protocol payload'
                owned = False
                responses += 1
            if action == 'read' and read is not None:
                tag, query, head, half, generation = read
                assert not owned, 'multiple live credits'
                assert (tag, query, head, half, generation) == (reads, reads//32, (reads%32)//2, reads%2, 7), 'request identity/order'
                pending, owned, reads = reads, True, reads+1
        return owned, pending, reads, responses

    def request(n):
        return n, n//32, (n%32)//2, n%2, 7

    def response(n):
        return n, tuple(32*n+k for k in range(32))

    # Contract-derived synthetic protocol tokens, not model arithmetic or RTL.
    state = (False, 0, 0, 0)
    producer_pending = None
    accepted = retired = overlaps = stalls = 0
    first_old_failure = None
    for cycle in range(100000):
        out_ready, read_ready = cycle%7 != 3, cycle%5 != 2
        rsp = response(producer_pending[0]) if producer_pending is not None and cycle >= producer_pending[1] and out_ready else None
        can_read = accepted < 4096 and read_ready and (producer_pending is None or rsp is not None)
        rd = request(accepted) if can_read else None
        if rsp is not None and rd is not None:
            overlaps += 1
            if first_old_failure is None:
                try:
                    observe(state, rsp, rd, old_order=True)
                except AssertionError as error:
                    first_old_failure = {'cycle': cycle, 'old_pending': state[1], 'new_read': accepted, 'reason': str(error)}
        state = observe(state, rsp, rd)
        if rsp is not None:
            retired += 1
            producer_pending = None
        if rd is not None:
            producer_pending = accepted, cycle+2
            accepted += 1
        if producer_pending is not None and rsp is None:
            stalls += 1
        assert int(state[0]) == accepted-retired and 0 <= accepted-retired <= 1
        if retired == 4096:
            break
    assert accepted == retired == 4096 and not state[0] and overlaps > 0 and first_old_failure
    negatives = [
        ('response_without_credit', (False,0,0,0), response(0), None),
        ('request_without_retiring_live_credit', (True,0,1,0), None, request(1)),
        ('wrong_old_response_tag', (True,0,1,0), response(1), request(1)),
        ('wrong_response_payload', (True,0,1,0), (0, (0,)*32), None),
        ('skipped_request_tag', (False,0,1,1), None, request(2)),
        ('wrong_query', (False,0,0,0), None, (0,1,0,0,7)),
        ('wrong_head', (False,0,0,0), None, (0,0,1,0,7)),
        ('wrong_half', (False,0,0,0), None, (0,0,0,1,7)),
        ('wrong_generation', (False,0,0,0), None, (0,0,0,0,8)),
        ('overlap_wrong_new_identity', (True,0,1,0), response(0), request(2)),
    ]
    rejected = []
    for name, initial, rsp, rd in negatives:
        try:
            observe(initial, rsp, rd)
        except AssertionError:
            rejected.append(name)
        else:
            raise AssertionError('negative accepted: '+name)
    result = {'schema':'m007-r007-context-credit-observer-static-audit-v1', 'status':'PASS_STATIC_SOURCE_AND_PROTOCOL_MODEL_ONLY', 'versions':versions, 'adapter_sha256':sha(adapter), 'adapter_contract':'One outstanding read credit with legal same-edge matching old-response retirement/new-request replacement; generation unchanged, sequential query/head/half coordinates.', 'protocol_trace':{'synthetic_tokens_not_model_values':True,'accepted_reads':accepted,'responses_checked':retired,'concurrent_response_request_edges':overlaps,'held_pending_cycles':stalls,'cycles':cycle+1,'max_credit':1,'old_checker_first_false_failure':first_old_failure,'final_credit':int(state[0]),'negative_cases_rejected':rejected}, 'production_RTL_or_gold_changed':False, 'SV_compile_or_RTL_or_floating_model_run':False, 'scope_limit':'Static exact source reversal plus independent credit protocol model only. Does not establish corrected full-Encoder runtime PASS; actual A012 successor execution remains necessary. AT033 original failure and old frozen sources remain untouched.', 'resource_policy_self':{'affinity':affinity,'nice':nice,'ioprio_class':io>>13,'initial_MemAvailable_KiB':available,'max_RSS_KiB':resource.getrusage(resource.RUSAGE_SELF).ru_maxrss,'address_space_limit_B':1024**3}, 'wall_s':time.monotonic()-start}
    (out/'context_credit_audit.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps({k:result[k]for k in ['status','protocol_trace','resource_policy_self','wall_s']}))


if __name__ == '__main__':
    main()
