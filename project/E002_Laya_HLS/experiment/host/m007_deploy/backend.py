"""Explicit backend boundary. No production device implementation is available."""
from .contract import Request


class BackendNotRun(RuntimeError):
    status = "NOT_RUN"


class XRTBackend:
    status = "NOT_RUN"
    reason = "M007 xclbin, register mapping, BO group_id and real TAIL_READY transport are not bound"

    def execute(self, request: Request, h0: bytes):
        request.validate()
        if len(h0) != request.h0_span:
            raise ValueError("H0 frame length")
        raise BackendNotRun(self.reason)
