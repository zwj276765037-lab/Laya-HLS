#!/usr/bin/env python3
"""Retain the original TANH checker and add three-version CE equivalence."""
from pathlib import Path
import hashlib
import json

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[6]
RUN = ROOT / 'project/E015_m007_tanh_geglu8/experiment_results/runs/R002'


def main():
    original = HERE / 'm007_tanh8_tb.sv'
    text = original.read_text().replace('module m007_tanh8_tb;', 'module m007_tanh_ce_tb;')

    def replace(before, after):
        nonlocal text
        assert text.count(before) == 1, (before, text.count(before))
        text = text.replace(before, after)

    declarations = '''
 logic [1:0] ce_lease_ready,ce_release_ready,ce_active,ce_draining,ce_ir,ce_ov,ce_reject,ce_fault;
 logic [1:0][63:0] ce_rrid;logic [1:0][31:0] ce_gen,ce_epoch;
 logic [1:0][2:0] ce_phase;logic [1:0][1:0] ce_reject_code;
 logic [1:0][95:0] ce_tag;logic [1:0][7:0] ce_mask;
 logic [1:0][7:0][31:0] ce_y,ce_status;logic [1:0][8:0] ce_pending,ce_flight;
 int ce_idle_cycles=0,ce_active_cycles=0,ce_pending_empty_pipe_cycles=0;
 int ce_first_stage=0,ce_middle_stage=0,ce_last_stage=0,ce_valid_events=0;
 int core_accepted=0,core_returned=0,core_cycles[0:MAXQ-1],core_latency_checks=0,ce_wall=0;
'''
    for index, name, force in ((0, 'forced_dut', 1), (1, 'auto_dut', 0)):
        declarations += f'''
 laya_m007_tanh8_v2 #(.FORCE_CORE_CE({force})) {name}(.clk,.rst_n,
  .lease_valid,.lease_ready(ce_lease_ready[{index}]),.lease_request_id(rid),.lease_generation(generation),.lease_epoch(epoch),.lease_phase,
  .release_valid,.release_ready(ce_release_ready[{index}]),.release_phase(3'd1),.release_epoch(epoch),.phase_debt_clear(debt_clear),
  .lease_active(ce_active[{index}]),.draining(ce_draining[{index}]),.rsp_request_id(ce_rrid[{index}]),.rsp_generation(ce_gen[{index}]),.rsp_epoch(ce_epoch[{index}]),.rsp_phase(ce_phase[{index}]),
  .req_valid(iv),.req_ready(ce_ir[{index}]),.req_mode(mode),.req_request_id(req_rid),.req_generation(req_gen),.req_epoch,.req_phase,.req_tag(tag),.req_mask(mask),.req_x(x),
  .reject_valid(ce_reject[{index}]),.reject_code(ce_reject_code[{index}]),.rsp_valid(ce_ov[{index}]),.rsp_ready(ready),.rsp_tag(ce_tag[{index}]),.rsp_mask(ce_mask[{index}]),.rsp_data(ce_y[{index}]),.rsp_status(ce_status[{index}]),
  .pending_vectors(ce_pending[{index}]),.in_flight_vectors(ce_flight[{index}]),.protocol_fault(ce_fault[{index}]));
'''
    monitor = '''
 task automatic idle_noise(input int clocks);
  iv=0;lease_valid=0;release_valid=0;mask=8'hff;
  repeat(clocks)begin
   @(negedge clk);
   for(int lane=0;lane<8;lane++)x[lane]=32'(wall*32'h13579bdf)^32'(lane*32'hdeadbeef);
   #0.001;if(auto_dut.core_ce||!auto_dut.all_token_empty||active||pending||flight)$fatal(1,"CE_IDLE_NOT_FROZEN");
  end
 endtask
 for(genvar lane=0;lane<8;lane++)begin:ce_token_monitor
  always @(posedge clk)if(rst_n)begin
   if(dut.tanh_lane[lane].core.valid_pipe!==auto_dut.tanh_lane[lane].core.valid_pipe||
      dut.tanh_lane[lane].core.valid_pipe!==forced_dut.tanh_lane[lane].core.valid_pipe)$fatal(1,"CE_TOKEN_ALIGNMENT lane=%0d",lane);
  end
  logic[63:0]idle_sample;
  always @(posedge clk)if(rst_n&&!auto_dut.core_ce)begin
   idle_sample={auto_dut.tanh_lane[lane].core.input_bits,auto_dut.tanh_lane[lane].core.selected_result};
   #0.001;if({auto_dut.tanh_lane[lane].core.input_bits,auto_dut.tanh_lane[lane].core.selected_result}!==idle_sample)$fatal(1,"CE_IDLE_DATA_CHANGED lane=%0d",lane);
  end
 end
 always @(posedge clk)begin:ce_equivalence
  ce_wall++;
  if(!rst_n)begin
   core_accepted=0;core_returned=0;
   if(!auto_dut.core_ce)$fatal(1,"CE_RESET_DISABLED");
  end else begin
   for(int variant=0;variant<2;variant++)begin
    if({lease_ready,release_ready,active,draining,ir,ov,reject_valid,reject_code,fault,pending,flight,rrid,rgen,repoch,rphase}!==
       {ce_lease_ready[variant],ce_release_ready[variant],ce_active[variant],ce_draining[variant],ce_ir[variant],ce_ov[variant],ce_reject[variant],ce_reject_code[variant],ce_fault[variant],ce_pending[variant],ce_flight[variant],ce_rrid[variant],ce_gen[variant],ce_epoch[variant],ce_phase[variant]})$fatal(1,"CE_PUBLIC_CONTROL variant=%0d phase=%0d",variant,phase);
    if(ov&&{y,status,ot,om}!=={ce_y[variant],ce_status[variant],ce_tag[variant],ce_mask[variant]})$fatal(1,"CE_VALID_RESPONSE variant=%0d phase=%0d",variant,phase);
   end
   if(!forced_dut.core_ce)$fatal(1,"CE_FORCED_ONE");
   if((active||pending!=0||flight!=0||!auto_dut.all_token_empty||fault||(lease_valid&&lease_ready)||(iv&&ir))&&!auto_dut.core_ce)$fatal(1,"CE_REQUIRED_WAKE");
   if(active)ce_active_cycles++;if(!auto_dut.core_ce)ce_idle_cycles++;
   if(pending!=0&&auto_dut.all_token_empty)begin if(!auto_dut.core_ce)$fatal(1,"CE_PENDING_EMPTY_PIPE");ce_pending_empty_pipe_cycles++;end
   if(auto_dut.core_token_empty!==~{|auto_dut.tanh_lane[7].core.valid_pipe,|auto_dut.tanh_lane[6].core.valid_pipe,|auto_dut.tanh_lane[5].core.valid_pipe,|auto_dut.tanh_lane[4].core.valid_pipe,|auto_dut.tanh_lane[3].core.valid_pipe,|auto_dut.tanh_lane[2].core.valid_pipe,|auto_dut.tanh_lane[1].core.valid_pipe,|auto_dut.tanh_lane[0].core.valid_pipe})$fatal(1,"CE_TOKEN_EMPTY_FULL_VIEW");
   if(auto_dut.tanh_lane[0].core.valid_pipe[0])ce_first_stage++;
   if(auto_dut.tanh_lane[0].core.valid_pipe[75])ce_middle_stage++;
   if(auto_dut.tanh_lane[0].core.valid_pipe[151])ce_last_stage++;
   if(iv&&ir)begin core_cycles[core_accepted]=ce_wall;core_accepted++;end
   if(dut.core_valid[0])begin
    if(core_returned>=core_accepted||ce_wall-core_cycles[core_returned]!=152)$fatal(1,"CE_CORE_TOKEN_LATENCY observed=%0d",ce_wall-core_cycles[core_returned]);
    core_returned++;core_latency_checks++;
   end
   if(ov)ce_valid_events++;
  end
 end
'''
    replace(' task automatic lease;', declarations + monitor + '\n task automatic lease;')
    replace('ref_id[lane]=base+lane;mask[lane]=base+lane<limit;x[lane]=mask[lane]?vectors[base+lane][95:64]:32\'b0;',
            'ref_id[lane]=phase==1?(base+lane<384?total_count-390+base+lane:base+lane-384):base+lane;mask[lane]=base+lane<limit;x[lane]=mask[lane]?vectors[ref_id[lane]][95:64]:32\'b0;')
    replace('repeat(5)@(negedge clk);rst_n=1;lease();',
            'repeat(5)@(negedge clk);rst_n=1;idle_noise(128);rst_n=0;repeat(3)@(negedge clk);rst_n=1;idle_noise(64);lease();')
    ending = '''
  idle_noise(192);generation++;epoch++;lease();phase=4;
  for(int i=0;i<8;i++)begin send(8*i,total_count);@(negedge clk);iv=0;repeat(3*(i+1))@(negedge clk);end
  @(negedge clk);iv=0;wait(returned==73);repeat(3)@(negedge clk);
  release_valid=1;wait(!active);@(negedge clk);release_valid=0;idle_noise(64);progress();
  if(ce_idle_cycles<448||ce_first_stage==0||ce_middle_stage==0||ce_last_stage==0||ce_pending_empty_pipe_cycles<17||core_latency_checks==0||core_returned!=core_accepted)$fatal(1,"CE_COVERAGE");
  $display("TANH_CE_EQUIVALENCE_PASS idle_ce0=%0d active_ce1=%0d pending_empty_pipe=%0d first=%0d middle=%0d last=%0d valid_events=%0d core152_checks=%0d wrapper_consume_latency=%0d no_reset_newgen8=1 boundary384=1",ce_idle_cycles,ce_active_cycles,ce_pending_empty_pipe_cycles,ce_first_stage,ce_middle_stage,ce_last_stage,ce_valid_events,core_latency_checks,first_latency);
'''
    replace('  if(fault||pending||flight||checked!=count+2566)', ending + '  if(fault||pending||flight||checked!=count+2630)')
    text = text.replace('expected=%0d",fault,pending,flight,checked,count+2566)',
                        'expected=%0d",fault,pending,flight,checked,count+2630)')
    (HERE / 'm007_tanh_ce_tb.sv').write_text(text)
    RUN.mkdir(parents=True, exist_ok=True)
    (RUN / 'ce26_TB_preparation_v1.json').write_text(json.dumps({
        'status': 'PREPARED_NOT_COMPILED', 'baseline_TB_sha256': hashlib.sha256(original.read_bytes()).hexdigest(),
        'generated_TB_sha256': hashlib.sha256(text.encode()).hexdigest(),
        'reference': 'Original corner384/real prefix/nonfinite6 fixture records; no new numerical gold',
        'variants': ['v1', 'v2 FORCE_CORE_CE=1', 'v2 FORCE_CORE_CE=0'],
        'core_latency_cycles': 152, 'expected_public_consume_latency_cycles': 153,
        'protocol_fault_injection': 'NOT_RUN: no public input can directly corrupt identical alignment/credit state',
    }, indent=2) + '\n')
    print('Prepared original-checker three-version public equivalence TB')


if __name__ == '__main__':
    main()
