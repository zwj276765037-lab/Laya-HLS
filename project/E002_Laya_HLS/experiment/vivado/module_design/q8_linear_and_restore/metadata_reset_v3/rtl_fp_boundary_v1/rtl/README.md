# RTL location

This workspace maintains no copied or modified DUT RTL. The seven generated `metadata_reset_v3` outer Verilog wrappers and their actual simulation VHDL are read from the accepted HLS output tree and byte-bound in [the source packet](../source/source_packet.json). The only new SystemVerilog is the isolated seven-instance testbench in `tb/`.
