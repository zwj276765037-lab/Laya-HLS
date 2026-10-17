#!/usr/bin/env python3
"""Make a short, real-connected W-cache probe from the M005 top TB."""

import argparse
from pathlib import Path


ANCHOR = "    repeat(16)tick();\n"
OBS_ANCHOR = "  task automatic tick;"
OBSERVER = """  always @(posedge clk) if(rst_n && $test$plusargs("W_PROBE"))begin
    for(int pp=0;pp<3;pp++)begin
      if(wc_arvalid[pp] && wc_arready[pp])
        $display("M005_W_PROBE_AR cycle=%0d port=%0d addr=%h len=%0d ready=%b active=%b left=%0d",
          cycle,pp,wc_araddr[pp],wc_arlen[pp],wc_arready[pp],q_active[pp],q_left[pp]);
      if(wc_rvalid[pp] && wc_rready[pp] &&
          (q_beats[pp]<2 || q_beats[pp]==63 || q_beats[pp]==64 || wc_rlast[pp]))
        $display("M005_W_PROBE_R cycle=%0d port=%0d beat=%0d last=%b resp=%b active=%b left=%0d",
          cycle,pp,q_beats[pp]+1,wc_rlast[pp],wc_rresp[pp],q_active[pp],q_left[pp]);
    end
    if(wc_aux_arvalid && wc_aux_arready)
      $display("M005_W_PROBE_AUX_AR cycle=%0d addr=%h len=%0d",cycle,wc_aux_araddr,wc_aux_arlen);
    if(wc_aux_rvalid && wc_aux_rready && (aux_left==1 || aux_index<2))
      $display("M005_W_PROBE_AUX_R cycle=%0d last=%b resp=%b left=%0d",
        cycle,wc_aux_rlast,wc_aux_rresp,aux_left);
  end
"""
PROBE = """    if($test$plusargs("W_PROBE"))begin
      wc_load_slot=0;wc_load_epoch=1;wc_load_k=1024;wc_load_n=5248;
      wc_load_weight_key=3;wc_load_model_identity=model[0];
      wc_load_expected_aux_header=header[0];
      wc_load_aux_base=64'h400000000;wc_load_bias_base=0;wc_load_bias_bytes=0;
      for(int pp=0;pp<3;pp++)begin
        wc_load_base[pp]=64'h500000000+64'(pp)*64'h10000000+config_words[3+pp];
        wc_load_bytes[pp]=32'(config_words[6+pp]);
      end
      @(negedge clk);wc_request_valid=1;
      @(posedge clk);while(!wc_request_ready)@(posedge clk);#1;
      if(wc_request_reject || wc_load_reject)
        $fatal(1,"M005 W probe binding rejected");
      @(negedge clk);wc_request_valid=0;
      while(q_beats[0]<128 || q_beats[1]<128 || q_beats[2]<32)begin
        tick();
        if(cycle%16==0)
          $display("M005_W_PROBE_STATE cycle=%0d ar=%b ready=%b rvalid=%b rready=%b active=%b%b%b left=%0d,%0d,%0d q=%0d,%0d,%0d aux=%0d/%0d wstate=%0d error=%b reject=%b",
            cycle,wc_arvalid,wc_arready,wc_rvalid,wc_rready,
            q_active[0],q_active[1],q_active[2],
            q_left[0],q_left[1],q_left[2],
            q_beats[0],q_beats[1],q_beats[2],
            aux_active,aux_left,wc_slot_state[0],wc_load_error,wc_load_reject);
        if(cycle>3000)$fatal(1,"M005 W probe bounded stop");
      end
      $display("M005_W_PROBE_PASS cycle=%0d W_R=%0d,%0d,%0d",cycle,
        q_beats[0],q_beats[1],q_beats[2]);
      $finish;
    end
"""


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--normal-tb", type=Path, required=True)
    parser.add_argument("--out", type=Path, required=True)
    args = parser.parse_args()
    source = args.normal_tb.read_text()
    if source.count(ANCHOR) != 1:
        raise ValueError("normal TB short-probe insertion anchor changed")
    if source.count(OBS_ANCHOR) != 1:
        raise ValueError("normal TB observer insertion anchor changed")
    updated = source.replace(ANCHOR, ANCHOR + PROBE, 1)
    updated = updated.replace(OBS_ANCHOR, OBSERVER + OBS_ANCHOR, 1)
    args.out.write_text(updated)
    print("M005_W_PROBE_TB_READY")


if __name__ == "__main__":
    main()
