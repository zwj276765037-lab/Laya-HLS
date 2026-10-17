set depth_list {
  {att_out 4100}
  {att_out_r 1}
  {aux 128}
  {aux_r 1}
  {fixture 786432}
  {fixture_r 1}
  {io 32768}
  {io_r 1}
  {observed 256}
  {observed_r 1}
  {qkv0 10240064}
  {qkv0_r 1}
  {qkv1 10240064}
  {qkv1_r 1}
}
set trans_depth {
  {att_out_r { 4100 } att_out}
  {aux_r { 128 } aux}
  {fixture_r { 786432 } fixture}
  {io_r { 32768 } io}
  {observed_r { 256 } observed}
  {qkv0_r { 10240064 } qkv0}
  {qkv1_r { 10240064 } qkv1}
}
set containsVLA 0
set trans_num 1
