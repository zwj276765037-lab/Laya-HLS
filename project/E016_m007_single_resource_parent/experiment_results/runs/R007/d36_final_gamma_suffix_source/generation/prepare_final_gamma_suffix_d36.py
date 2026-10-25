#!/usr/bin/env python3
"""D36 source-only suffix entry, diagnostics, and old/fixed gamma closures."""
from pathlib import Path
import difflib, hashlib, json, shutil, time

ROOT=Path(__file__).resolve().parents[3]
R=ROOT/'project/E016_m007_single_resource_parent/experiment_results/runs/R007'
S=ROOT/'project/E016_m007_single_resource_parent/experiment_source'
M=ROOT/'project/E002_Laya_HLS/experiment/vivado/module_design/forward_controller'
OUT=R/'d36_final_gamma_suffix_source'
BASE_MANIFEST=R/'prepared/fullgraph_kind6_public_abi_v4/source_manifest.json'

def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def rel(p):return str(p.relative_to(ROOT))
def dump(p,d):p.parent.mkdir(parents=True,exist_ok=True);p.write_text(json.dumps(d,indent=2)+'\n')
def swap(t,a,b):assert t.count(a)==1,(a[:100],t.count(a));return t.replace(a,b,1)
def freeze(p,t):
 p.parent.mkdir(parents=True,exist_ok=True)
 if p.exists():assert p.read_text()==t,rel(p)
 else:p.write_text(t)

def main():
 start=time.monotonic();manifest=json.loads(BASE_MANIFEST.read_text())
 old_parent=next(ROOT/x['path']for x in manifest['compile_sources']if x['path'].endswith('/laya_m007_single_parent_v3.sv'))
 old_tb=ROOT/manifest['source'];p0=old_parent.read_text();t0=old_tb.read_text()
 assert sha(old_parent)=='7b0d0c6dbdf85c4e41db28fedc8f48edb763b6c21c3d668f2d3fa886c4cc3714'
 assert sha(old_tb)=='86629840d80ea5867957489def3040fcd116a2cb3b15c1f9e4f75ac7dafd99b8'
 parameter=" parameter bit VERIFY_POST_ENCODER27_H=1'b0,\n"
 anchor=' parameter logic[255:0]PLATFORM_MANIFEST_SHA256=0\n'
 entry_old='''    E_H_READY:if(h_load_success_valid&&resident_retired)begin
     active_epoch_offset<=layer_offset(layer_index,0);
     if(layer_index==0)begin active_epoch_offset<=layer_offset(layer_index,1);state<=C_A0_AR;end
     else state<=P_OWNER;
    end'''
 entry_new='''    E_H_READY:if(h_load_success_valid&&resident_retired)begin
     if(VERIFY_POST_ENCODER27_H&&kind==7)begin
      layer_index<=27;active_epoch_offset<=448;state<=N_OWNER;
     end else begin
      active_epoch_offset<=layer_offset(layer_index,0);
      if(layer_index==0)begin active_epoch_offset<=layer_offset(layer_index,1);state<=C_A0_AR;end
      else state<=P_OWNER;
     end
    end'''
 p_old=swap(swap(p0,anchor,parameter+anchor),entry_old,entry_new)
 gamma_old='assign v2_resident_ln_use_gamma=state==N_START;'
 gamma_new='assign v2_resident_ln_use_gamma=state==N_START||state==N_RUN;'
 p_fixed=swap(p_old,gamma_old,gamma_new)
 assert p_fixed.replace(gamma_new,gamma_old,1)==p_old
 assert p_old.replace(parameter,'',1).replace(entry_new,entry_old,1)==p0
 # Existing public ports and kind/layer validation are byte-identical.
 assert p0[p0.index(')(\n'):p0.index(' localparam')]==p_fixed[p_fixed.index(')(\n'):p_fixed.index(' localparam')]
 changes=[]
 def change(a,b):changes.append((a,b))
 change('module m007_fullgraph_binary_tb;','module m007_fullgraph_binary_tb #(parameter bit VERIFY_POST_ENCODER27_H=1\'b0);')
 change('laya_m007_single_parent_v3 #(','laya_m007_single_parent_v3 #(.VERIFY_POST_ENCODER27_H(VERIFY_POST_ENCODER27_H),')
 change('string data_dir,rope_dir,original_dir,export_path,meta_path;','string data_dir,rope_dir,original_dir,export_path,meta_path,post_encoder27_h_path;\n integer suffix_entries=0,actual_head_successes=0,ln_accepted_commands=0,gamma_accepted_commands=0,ordinary_accepted_commands=0;\n integer final_norm_fd=0,type_add_fd=0;')
 change('if(kind_run==7&&ri!=catalog_runtime)$fatal(1,"once-BEGIN catalog order");','if(VERIFY_POST_ENCODER27_H)begin if(ri!=112+catalog_runtime)$fatal(1,"segmented suffix catalog order");end\n    else if(kind_run==7&&ri!=catalog_runtime)$fatal(1,"once-BEGIN catalog order");')
 change('if(kind_run==7&&gl>0&&!layer_complete_seen[gl-1])$fatal(1,"layer handoff before actual previous endpoint");','if(kind_run==7&&gl>0&&!layer_complete_seen[gl-1]&&!(VERIFY_POST_ENCODER27_H&&gl==28))$fatal(1,"layer handoff before actual previous endpoint");')
 normal_output='if(out_data!==tail_gold[exports]||layers_completed!=30||final_norm_count!=4096||type_count!=4096)$fatal(1,"original Decision1 gather/CLS and fullgraph prerequisites");'
 change(normal_output,'if(VERIFY_POST_ENCODER27_H)begin if(out_data!==tail_gold[exports]||layers_completed!=2||final_norm_count!=4096||type_count!=4096)$fatal(1,"original Decision1 gather/CLS and segmented suffix prerequisites");end\n    else '+normal_output)
 normal_coverage='if(kind_run==7&&(commands!=1||catalog_runtime!=120||catalog_seen!={120{1\'b1}}||matrix_commands!=120||layers_completed!=30||attention_layers!=30||ln_commands!=60||vector_commands!=61||g_commands!=28||tail_commits!=1||tail_writes!=544))$fatal(1,"once-BEGIN original30 graph coverage and real tail commit");'
 suffix_coverage='''if(kind_run==7&&(suffix_entries!=1||commands!=1||h_count!=4096||catalog_runtime!=8||catalog_seen!==({120{1'b1}}<<112)||matrix_commands!=8||layers_completed!=2||layer_complete_seen!==30'h30000000||attention_layers!=2||actual_head_successes!=32||ln_commands!=5||ln_accepted_commands!=5||gamma_accepted_commands!=1||ordinary_accepted_commands!=4||vector_commands!=5||g_commands!=0||final_norm_count!=4096||final_norm_seen!={4096{1'b1}}||type_count!=4096||type_H_seen!={4096{1'b1}}||tail_commits!=1||tail_writes!=544))$fatal(1,"segmented suffix actual coverage and real tail commit");'''
 change(normal_coverage,'if(!VERIFY_POST_ENCODER27_H)begin '+normal_coverage+'end\n    else '+suffix_coverage)
 predicate='kind_run!=7||final_norm_seen[a]||dut.active_epoch_offset!=448||dut.resident.p_q_wr_data!==checkpoint_gold[28*4096+a]'
 fatal='if('+predicate+')$fatal(1,"original final gamma LN checkpoint");'
 diagnostic='''if('''+predicate+''')begin
     integer first_bad_lane;first_bad_lane=-1;
     for(int lane=0;lane<32;lane++)if(first_bad_lane<0&&dut.resident.p_q_wr_data[32*lane+:32]!==checkpoint_gold[28*4096+a][32*lane+:32])first_bad_lane=lane;
     $display("M007_FINAL_GAMMA_DIAG addr=%0d kind_bad=%0d duplicate=%0d offset_bad=%0d data_bad=%0d kind=%0d offset=%0d first_bad_lane=%0d parent_gamma=%0d provider_gamma=%0d actual=%h expected=%h cycle=%0d",a,kind_run!=7,final_norm_seen[a],dut.active_epoch_offset!=448,dut.resident.p_q_wr_data!==checkpoint_gold[28*4096+a],kind_run,dut.active_epoch_offset,first_bad_lane,dut.v2_resident_ln_use_gamma,dut.resident.p_ln_cmd_gamma,dut.resident.p_q_wr_data,checkpoint_gold[28*4096+a],cycle);$fflush();
     $fatal(1,"original final gamma LN checkpoint");
    end'''
 change(fatal,diagnostic)
 change('final_norm_seen[a]=1;final_norm_count++;progress(32,"FINAL_NORM");','''final_norm_seen[a]=1;final_norm_count++;progress(32,"FINAL_NORM");
    if(VERIFY_POST_ENCODER27_H)begin
     if($fseek(final_norm_fd,128*a,0))$fatal(1,"actual final norm capture seek");
     for(int j=0;j<128;j++)$fwrite(final_norm_fd,"%c",dut.resident.p_q_wr_data[j/4][8*(j%4)+:8]);
     if(final_norm_count==4096)$fflush(final_norm_fd);
    end''')
 change('type_H_seen[a]=1;type_count++;progress(32,"TYPE_H");','''type_H_seen[a]=1;type_count++;progress(32,"TYPE_H");
     if(VERIFY_POST_ENCODER27_H)begin
      if($fseek(type_add_fd,128*a,0))$fatal(1,"actual type capture seek");
      for(int j=0;j<128;j++)$fwrite(type_add_fd,"%c",dut.resident.vector_h_wr_data[j/4][8*(j%4)+:8]);
      if(type_count==4096)$fflush(type_add_fd);
     end''')
 observations='''   if(VERIFY_POST_ENCODER27_H&&parent_state==33&&dut.h_load_success_valid&&dut.resident_retired)begin
    if(suffix_entries!=0||kind_run!=7||h_count!=4096||dut.inputs_accepted!=4096||!model_committed||matrix_commands!=0||layers_completed!=0||ln_commands!=0||vector_commands!=0||catalog_runtime!=0)$fatal(1,"suffix entry without real setup/H/quiet qualification");
    suffix_entries++;
    $display("M007_SEGMENTED_SUFFIX_ENTRY input_groups=%0d resident_retired=%0d scratch_retired=%0d weight_idle=%0d source_qualified=%0d prefix_replayed=0 cycle=%0d",h_count,dut.resident_retired,dut.v2_scratch_retired,weight_idle,dut.v2_resident_ln_source_qualified,cycle);$fflush();
   end
   if(dut.resident.joint.layer.h_done_valid&&dut.resident.joint.layer.h_done_ready)begin
    if(dut.resident.joint.layer.h_done_status!=0)$fatal(1,"actual head unsuccessful");
    actual_head_successes++;
   end
   if(dut.resident.p_ln_cmd_valid&&dut.resident.p_ln_cmd_ready)begin
    ln_accepted_commands++;
    if(dut.resident.p_ln_cmd_gamma)gamma_accepted_commands++;else ordinary_accepted_commands++;
    $display("M007_LN_COMMAND global=%0d state=%0d epoch=%0d gamma=%0d rows=%0d cycle=%0d",gl,parent_state,dut.resident.p_ln_cmd_epoch,dut.resident.p_ln_cmd_gamma,dut.resident.p_ln_cmd_rows,cycle);$fflush();
   end
   if(dut.v2_resident_ln_done_valid&&dut.v2_resident_ln_done_ready&&dut.v2_resident_ln_done_kind==0&&dut.v2_resident_ln_done_status==0&&dut.v2_resident_ln_issued_vectors==4096&&dut.v2_resident_ln_written_vectors==4096)begin
    $display("M007_RESIDENT_LN_SUCCESS global=%0d state=%0d epoch=%0d issued=%0d written=%0d cycle=%0d",gl,parent_state,dut.operation_epoch,dut.v2_resident_ln_issued_vectors,dut.v2_resident_ln_written_vectors,cycle);$fflush();
   end
'''
 change("   integer gl;gl=int'(dut.layer_index);\n","   integer gl;gl=int'(dut.layer_index);\n"+observations)
 change('  if(kind_run==7)$readmemh({original_dir,"/initial_H.hex"},initial_h);','''  if(VERIFY_POST_ENCODER27_H)begin
   if(kind_run!=7||decision_local!=0||!$value$plusargs("POST_ENCODER27_H=%s",post_encoder27_h_path))$fatal(1,"segmented suffix requires kind7/local0 and saved actual H path");
   $readmemh(post_encoder27_h_path,initial_h);
   $display("M007_SEGMENTED_SUFFIX_INPUT source=actual_layer27 prefix_replayed=0 path=%s",post_encoder27_h_path);$fflush();
  end else if(kind_run==7)$readmemh({original_dir,"/initial_H.hex"},initial_h);''')
 marker='  $display("HARDWARE_AGENT_SIM_PASS M007_FULLGRAPH_BINARY kind=%0d layers=%0d matrix=%0d outputs=%0d actual_tail_commit=%0d",kind_run,layers_completed,matrix_commands,exports,tail_commits);$fflush();$finish;'
 change(marker,'''  if(VERIFY_POST_ENCODER27_H)$display("HARDWARE_AGENT_SIM_PASS M007_SEGMENTED_SUFFIX layers=%0d matrix=%0d heads=%0d LN=%0d vector=%0d outputs=%0d actual_tail_commit=%0d",layers_completed,matrix_commands,actual_head_successes,ln_commands,vector_commands,exports,tail_commits);
  else '''+marker.strip().replace('$fflush();$finish;','')+'''$fflush();$finish;''')
 input_open='  input_fd=$fopen({export_path,".H0.bin"},"wb");output_fd=$fopen({export_path,".output.bin"},"wb");if(!input_fd||!output_fd)$fatal(1,"actual public capture open");'
 change(input_open,input_open+'''
  if(VERIFY_POST_ENCODER27_H)begin
   final_norm_fd=$fopen({export_path,".final_norm.f32.bin"},"wb");type_add_fd=$fopen({export_path,".type_add.f32.bin"},"wb");
   if(!final_norm_fd||!type_add_fd)$fatal(1,"actual suffix capture open");
  end''')
 close_original='  $fflush(output_fd);$fclose(input_fd);$fclose(output_fd);receipt_fd='
 change(close_original,'  if(VERIFY_POST_ENCODER27_H)begin $fflush(final_norm_fd);$fflush(type_add_fd);$fclose(final_norm_fd);$fclose(type_add_fd);end\n'+close_original)
 # Retain the existing receipt and append an explicit, non-fullgraph scope record.
 receipt='$fclose(receipt_fd);\n  $display("HARDWARE_AGENT_SIM_PASS'
 # The terminal transformation above changes the next line, so use a standalone insertion.
 receipt_line='  $fdisplay(receipt_fd,"kind=%0d layer=%0d request=%0d generation=%0d source_epoch=%0d input_bytes=524288 output_bytes=%0d BEGIN=1 layers=%0d matrices=%0d LN=%0d vector=%0d GEGLU=%0d tail_commits=%0d done_consumed=1 cycles=%0d",kind_run,decision_local,cmd_request,cmd_generation,cmd_epoch,128*exports,layers_completed,matrix_commands,ln_commands,vector_commands,g_commands,tail_commits,cycle);$fclose(receipt_fd);'
 change(receipt_line,receipt_line.replace('$fclose(receipt_fd);','if(VERIFY_POST_ENCODER27_H)$fdisplay(receipt_fd,"scope=SEGMENTED_SUFFIX original_prefix_replayed=0 actual_input=encoder27 actual_heads=%0d actual_gamma_commands=%0d",actual_head_successes,gamma_accepted_commands);$fclose(receipt_fd);'))
 t=t0
 for a,b in changes:t=swap(t,a,b)
 inverse=t
 for a,b in reversed(changes):inverse=swap(inverse,b,a)
 assert inverse==t0
 # Keep current files protected against edits by another author.
 for path,old,new in [(M/'rtl/laya_m007_single_parent_v3.sv',p0,p_fixed),(M/'tb/m007_fullgraph_binary_tb.sv',t0,t)]:
  assert path.read_text()in(old,new),rel(path)
  path.write_text(new)
 # Canonical parent source generator carries the same approved two edits.
 control=S/'fullmodel_parent_control_r007.svpart';c=control.read_text()
 if gamma_old in c:c=swap(c,gamma_old,gamma_new)
 if entry_old in c:c=swap(c,entry_old,entry_new)
 assert gamma_new in c and entry_new in c;control.write_text(c)
 compose=S/'compose_fullmodel_parent_r007.py';c=compose.read_text()
 if parameter not in c:c=swap(c,anchor,parameter+anchor)
 compose.write_text(c)
 # This explicit generator becomes the source entry; don't let the old generator
 # silently overwrite the D36 verification interface with its historical body.
 generator=S/'prepare_fullgraph_binary_checker_r007.py';g=generator.read_text();old_main="if __name__=='__main__':main()";new_main="if __name__=='__main__':\n from prepare_final_gamma_suffix_d36 import main as prepare_d36\n prepare_d36()"
 if old_main in g:g=swap(g,old_main,new_main)
 assert new_main in g;generator.write_text(g)
 common=OUT/'common/m007_fullgraph_binary_tb.sv';po=OUT/'old/laya_m007_single_parent_v3.sv';pf=OUT/'fixed/laya_m007_single_parent_v3.sv'
 freeze(common,t);freeze(po,p_old);freeze(pf,p_fixed)
 for path in [Path(__file__),control,compose,generator]:freeze(OUT/'generation'/path.name,path.read_text())
 for name,a,b in [('gamma_only',p_old,p_fixed),('verification_entry_old_parent',p0,p_old),('suffix_tb',t0,t)]:
  freeze(OUT/(name+'.patch'),''.join(difflib.unified_diff(a.splitlines(True),b.splitlines(True),fromfile='old/'+name,tofile='new/'+name)))
 raw=ROOT/'project/E021_m007_compiled_rtl_validation/experiment_results/runs/R003/attempts/AT001_original30_kind7/work/actual_fullgraph.layer27.f32.bin';hexfile=ROOT/'project/E021_m007_compiled_rtl_validation/experiment_results/runs/R004/frozen_input/encoder27.actual.group32.hex'
 assert raw.stat().st_size==524288 and sha(raw)=='964be7a3b198234aa78643f9dda0d538af70f04a31b2a71b8b652f17710f9f38'
 lines=hexfile.read_text().splitlines();assert len(lines)==4096 and all(len(x)==256 for x in lines)
 assert b''.join(int(x,16).to_bytes(128,'little')for x in lines)==raw.read_bytes()
 for flavor,parent in [('old',po),('fixed',pf)]:
  rows=[]
  for row in manifest['compile_sources']:
   assert sha(ROOT/row['path'])==row['sha256'],row['path']
   path=common if row['path']==rel(old_tb)else parent if row['path']==rel(old_parent)else ROOT/row['path']
   rows.append({'path':rel(path),'sha256':sha(path)})
  result={'schema':'m007-d36-saved-actual-suffix-source-v1','status':'SOURCE_PREPARED_NOT_COMPILED_NOT_RUN','variant':flavor,'top':'m007_fullgraph_binary_tb','top_parameter':{'VERIFY_POST_ENCODER27_H':1},'formal_default_parameter':0,'compile_sources':rows,'compile_source_count':len(rows),'ROM_initialization_files':manifest['ROM_initialization_files'],'top_source':rel(common),'top_sha256':sha(common),'parent_source':rel(parent),'parent_sha256':sha(parent),'previous_original_parent':rel(old_parent),'previous_original_parent_sha256':sha(old_parent),'previous_original_TB':rel(old_tb),'previous_original_TB_sha256':sha(old_tb),'only_old_fixed_difference':'use_gamma=(N_START) versus (N_START||N_RUN)','default0_behavior':'original public ports/kind5/6/7 validation and route unchanged except fixed gamma hold; added TB logging is read-only','input_plusarg':'POST_ENCODER27_H='+str(hexfile),'input_actual_raw':{'path':rel(raw),'bytes':524288,'sha256':sha(raw)},'input_hex':{'path':rel(hexfile),'sha256':sha(hexfile),'groups':4096,'bits':1024,'roundtrip_actual_bytes_equal':True},'coverage':'SEGMENTED_SUFFIX; actual2layers/8matrices/32heads/5LN/5VECTOR/544tail, no prefix counter preload, not a repaired once-BEGIN30layer run','required_marker':'HARDWARE_AGENT_SIM_PASS M007_SEGMENTED_SUFFIX layers=2 matrix=8 heads=32 LN=5 vector=5 outputs=544 actual_tail_commit=1','planned_early_stop_anchor':'M007_RESIDENT_LN_SUCCESS global=28 state=85; require independent finalLN/type capture complete, then classify planned prefix stop, not successDONE','no_HDL_STOP_plusarg':True}
  dump(OUT/(flavor+'_source_manifest.json'),result)
 audit={'schema':'m007-d36-gamma-suffix-source-audit-v1','status':'PASS_SOURCE_TRANSFORM_AND_INTEGER_INPUT_ONLY','inverse_parent_default0_except_gamma':True,'old_fixed_one_expression_only':True,'inverse_all_TB_edits_reconstructs866':True,'public_port_block_byte_equal':True,'all_94_original_source_identities_checked':True,'unchanged_dependencies':92,'original_composite_gamma_predicate_retained_exactly':predicate,'default_original_fullgraph_coverage_assertion_retained_exactly':normal_coverage,'actual_H_roundtrip_bytes_equal':True,'old_bug_not_yet_runtime_reproduced':True,'fixed_RTL_NOT_RUN':True,'wall_s':time.monotonic()-start,'old_parent_sha256':sha(po),'fixed_parent_sha256':sha(pf),'common_TB_sha256':sha(common),'old_source_manifest_sha256':sha(OUT/'old_source_manifest.json'),'fixed_source_manifest_sha256':sha(OUT/'fixed_source_manifest.json')}
 dump(OUT/'source_audit.json',audit)
 print(json.dumps(audit,indent=2))


if __name__=='__main__':main()
