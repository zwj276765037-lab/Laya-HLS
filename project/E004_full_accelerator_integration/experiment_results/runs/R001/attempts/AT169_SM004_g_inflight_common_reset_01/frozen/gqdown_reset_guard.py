#!/usr/bin/env python3
"""Use the existing FFR1 resource guard with an explicit DUT reset epoch."""

import ffr1_guard


_progress_decision = ffr1_guard.progress_decision


def reset_aware_progress_decision(previous, line):
    # The top-level reset test emits this only after latching real in-flight
    # work.  Its FFR1 counters legitimately restart from zero afterwards.
    if line.startswith("GQDOWN_RESET_PRE phase="):
        return None, True, False
    return _progress_decision(previous, line)


ffr1_guard.progress_decision = reset_aware_progress_decision


if __name__ == "__main__":
    ffr1_guard.main()
