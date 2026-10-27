#!/usr/bin/env python3
"""Independent last-resort confirmation for an already-loaded handoff guard."""
import json
import os
from pathlib import Path
import signal
import sys
import time
import handoff_guard_d38 as h

def observe(config):
    c = h.read(config); out = Path(c['output'])
    gp, gs = c['guard_pid'], c['guard_start']
    leader = c['leader']; known = {leader:c['leader_start']}
    wd = h.read(out/'watchdog_ready.json')
    observer = out/'observer'; observer.mkdir(exist_ok=True)
    h.dump(observer/'ready.json', {'utc':h.now(),'pid':os.getpid(),'start':h.owned.process_start(os.getpid()),
        'monitor_pid':c['monitor_pid'],'monitor_start':c['monitor_start'],'watchdog_pid':wd['pid'],
        'scope':'observe current supervision; confirm safe return or stop verified owned workload on supervision failure',
        'wall_time_limit_disabled':h.deadline(c) is None})
    fallback_epoch = None; confirmation_deadline = None
    deadline = h.deadline(c)
    while True:
        try:
            heartbeat = h.read(out/'heartbeat.json')
            known.update({int(k):v for k,v in heartbeat.get('known',{}).items()})
        except (FileNotFoundError,json.JSONDecodeError): pass
        items = h.owned.owned_processes(h.owned.process_table(),leader,known)
        active = {p:x for p,x in items.items() if not x['state'].startswith('Z')}
        original = h.state(gp,gs)
        try: end = h.read(out/'handoff_end.json')
        except (FileNotFoundError,json.JSONDecodeError): end = None
        monitor_alive = h.state(c['monitor_pid'],c['monitor_start']) is not None
        watchdog_alive = h.state(wd['pid'],wd['start']) is not None
        receipt = Path(c['attempt'])/'receipt.json'; sample = Path(c['attempt'])/'live_status.json'
        if receipt.exists() and not active:
            h.dump(observer/'completed.json',{'utc':h.now(),'reason':'original_receipt_and_no_active_owned',
                'original_receipt':str(receipt),'remaining_zombies_for_original_parent':[x for x in items.values()]})
            return
        abnormal = not monitor_alive or not watchdog_alive or original is None or (end and end.get('reason'))
        if abnormal and fallback_epoch is None:
            fallback_epoch = time.time(); confirmation_deadline = time.monotonic()+60
            if deadline is None:
                stopped=h.stop_unlimited_fallback(c,observer,known,
                    'unlimited_supervision_component_missing_or_failed')
                h.send(gp,gs,signal.SIGCONT)
                h.dump(observer/'fallback_owned_cleanup.json',{'utc':h.now(),
                    'reason':'unlimited_supervision_component_missing_or_failed',
                    'known_owned_identities':known,'active_owned_at_stop':list(stopped.values()),
                    'old_wall_limit_not_reactivated':True})
                return
            resumed = h.send(gp,gs,signal.SIGCONT)
            h.dump(observer/'fallback_started.json',{'utc':h.now(),'original_guard_resumed':resumed,
                'monitor_alive':monitor_alive,'watchdog_alive':watchdog_alive,'handoff_end':end,
                'effective_cap_if_original_confirmed_GiB':c.get('old_cap_gib',128)})
        if fallback_epoch is not None:
            if receipt.exists() or (sample.exists() and sample.stat().st_mtime >= fallback_epoch):
                h.dump(observer/'fallback_confirmed.json',{'utc':h.now(),'evidence':str(receipt if receipt.exists() else sample),
                    'effective_cap_GiB':c.get('old_cap_gib',128),'known_owned_identities':known})
                return
            rss = sum(x['rss_kb'] for x in items.values())
            protect = (rss >= c['rss_limit_kb'] or h.owned.mem_available_kb() <= c['minimum_available_kb']
                       or (deadline is not None and time.time() >= deadline))
            if original is None or time.monotonic() >= confirmation_deadline or protect:
                reason = 'original_guard_missing' if original is None else 'fallback_unconfirmed_or_protection_triggered'
                h.owned.OUT=observer
                if active: h.owned.stop_and_kill(leader,known,items,{'utc':h.now(),'reason':reason})
                h.send(gp,gs,signal.SIGCONT)
                h.dump(observer/'fallback_owned_cleanup.json',{'utc':h.now(),'reason':reason,
                    'known_owned_identities':known,'active_owned_at_stop':list(active.values())})
                return
        h.dump(observer/'live_status.json',{'utc':h.now(),'monitor_alive':monitor_alive,'watchdog_alive':watchdog_alive,
            'original_guard_state':original,'active_owned':len(active),'fallback_confirmation_pending':fallback_epoch is not None})
        time.sleep(.5)

if __name__=='__main__': observe(Path(sys.argv[1]))
