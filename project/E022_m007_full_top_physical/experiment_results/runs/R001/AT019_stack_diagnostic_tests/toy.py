import ctypes,time
ctypes.CDLL(None).prctl(0x59616d61,ctypes.c_ulong(-1).value,0,0,0)
while True:time.sleep(.02)
