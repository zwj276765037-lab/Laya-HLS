#!/usr/bin/env python3
"""Generate independent named-field checks for the packed 13BO wrapper."""
import json
from pathlib import Path

MODULE=Path(__file__).resolve().parents[1]
spec=json.loads((MODULE/'tb/laya_axi_13bo_ports_v1.json').read_text())
ports=spec['ports']
text='''`timescale 1ns/1ps
module laya_axi_13bo_owner_tb_v1;
'''
text+=''.join(f'  logic {w} {n};\n'.replace('logic  ','logic ') for _,w,n in ports)
text+='  laya_axi_13bo_owner_v1 dut(\n'+',\n'.join('    .'+n for _,_,n in ports)+'\n  );\n'
text+='''  initial clk=0;always #5 clk=~clk;
  int cycles=0,transactions=0;
  task automatic tick;@(posedge clk);#1;endtask
  always @(posedge clk)begin
    cycles++;if(cycles>3000)$fatal(1,"13BO owner cycle cap");
    if(rst_n)for(int bo=0;bo<13;bo++)begin
      if(owner_arready[bo][!selected_owner[bo]] || owner_awready[bo][!selected_owner[bo]] ||
         owner_wready[bo][!selected_owner[bo]] || owner_rvalid[bo][!selected_owner[bo]] ||
         owner_bvalid[bo][!selected_owner[bo]])$fatal(1,"13BO cross-owner leakage bo=%0d",bo);
'''
for ch,fields in spec['payloads'].items():
    fields=fields+(['len'] if ch in ('ar','aw') else ['last'] if ch in ('w','r') else [])
    check='memory_'+ch+'valid[bo]' if ch in ('ar','aw','w') else 'owner_'+ch+'valid[bo][selected_owner[bo]]'
    for field in fields:
        text+=f'      if({check} && memory_{ch}{field}[bo]!==owner_{ch}{field}[bo][selected_owner[bo]])\n'
        text+=f'        $fatal(1,"named {ch}{field} mismatch bo=%0d",bo);\n'
text+='''    end
  end
  initial begin
'''
for direction,_,name in ports:
    if direction=='input' and name!='clk':
        text+=f'    {name}=0;\n'
text+='''    memory_arready='1;memory_awready='1;memory_wready='1;
    repeat(5)tick();@(negedge clk);rst_n=1;repeat(3)tick();
    for(int bo=0;bo<13;bo++)begin
      for(int src=0;src<2;src++)begin
        @(negedge clk);desired_owner[bo]=1'(src);
        repeat(3)tick();if(selected_owner[bo]!=src || !debt_zero[bo])$fatal(1,"13BO idle selection bo=%0d",bo);
        @(negedge clk);
'''
for ch in ('ar','aw'):
    text+=f"        owner_{ch}addr[bo][src]=64'h8123456789000000+64'(bo*4096+src*64+"+('128' if ch=='aw' else '0')+');\n'
    text+=f'        owner_{ch}len[bo][src]=0;\n'
    for field in spec['payloads'][ch]:
        if field=='addr':continue
        width=spec['field_widths'][field]
        text+=f"        owner_{ch}{field}[bo][src]={width}'(bo*7+src*11+"+str(len(field)+len(ch))+');\n'
text+='''        owner_wdata[bo][src]=32'hf0123456^32'(bo*67+src*31);
        owner_wstrb[bo][src]=4'(bo+src+1);owner_wid[bo][src]=1'(bo);owner_wuser[bo][src]=1'(src);
        owner_wlast[bo][src]=1;owner_arvalid[bo][src]=1;owner_awvalid[bo][src]=1;owner_wvalid[bo][src]=1;
        #1;if(!owner_arready[bo][src] || !owner_awready[bo][src] || !owner_wready[bo][src])$fatal(1,"13BO admission readiness");
        tick();@(negedge clk);owner_arvalid[bo][src]=0;owner_awvalid[bo][src]=0;owner_wvalid[bo][src]=0;
        desired_owner[bo]=!1'(src);
        memory_rdata[bo]=32'h98765432^32'(bo*127+src*7);memory_rresp[bo]=2'(bo+src);
        memory_rid[bo]=1'(src);memory_ruser[bo]=!1'(src);memory_rlast[bo]=1;memory_rvalid[bo]=1;
        memory_bresp[bo]=2'(bo+src+1);memory_bid[bo]=!1'(src);memory_buser[bo]=1'(src);memory_bvalid[bo]=1;
        repeat(5)begin tick();if(selected_owner[bo]!=src || debt_zero[bo] || memory_rready[bo] || memory_bready[bo])$fatal(1,"13BO held response debt bo=%0d",bo);end
        @(negedge clk);owner_rready[bo][src]=1;owner_bready[bo][src]=1;
        tick();@(negedge clk);memory_rvalid[bo]=0;memory_bvalid[bo]=0;owner_rready[bo][src]=0;owner_bready[bo][src]=0;
        repeat(4)tick();if(selected_owner[bo]!=!1'(src) || !debt_zero[bo] || protocol_error[bo])$fatal(1,"13BO safe return bo=%0d",bo);
        transactions++;
      end
      if(accepted_ar[bo]!=2 || returned_r[bo]!=2 || accepted_aw[bo]!=2 || accepted_w[bo]!=2 || returned_b[bo]!=2)
        $fatal(1,"13BO counter coverage bo=%0d",bo);
    end
    if(selected_owner!=0 || debt_zero!='1 || protocol_error!=0 || transactions!=26)$fatal(1,"13BO final state");
    $display("FULL_CURRENT_13BO_OWNER_PASS BOs=13 owners=2 transactions=26 named_fields=45 AR=26 R=26 AW=26 W=26 B=26 held_R_B=26 all_ID_USER_LOCK_REGION_RESP=1 cycles=%0d",cycles);$finish;
  end
endmodule
'''
(MODULE/'tb/laya_axi_13bo_owner_tb_v1.sv').write_text(text)
print('FULL_CURRENT_13BO_OWNER_TB_GENERATED named_fields=45 roles=13')
