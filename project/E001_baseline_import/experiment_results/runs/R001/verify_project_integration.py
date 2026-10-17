#!/usr/bin/env python3
import hashlib,json,pathlib,re,datetime
N=pathlib.Path('/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS')
D=N/'project/E002_Laya_HLS/experiment'
errors=[];checked_links=0;docs=[]
reg=json.loads((N/'.research-agent/project.json').read_text())
for kind,rows in reg['records'].items():
 for i,row in rows.items():
  if not (N/row['path']).exists():errors.append({'record':i,'error':'missing_record_path'})
for p in N.rglob('*.md'):
 if p.is_relative_to(D) or 'publication_history' in p.parts:continue
 docs.append(p)
 text=p.read_text()
 if '待定义' in text:errors.append({'path':str(p.relative_to(N)),'error':'unfilled_template'})
 for target in re.findall(r'\]\(([^)]+)\)',text):
  target=target.strip('<>')
  if '://' in target or target.startswith('#'):continue
  target=target.split('#',1)[0]
  if not target:continue
  q=pathlib.Path(target) if target.startswith('/') else p.parent/target
  checked_links+=1
  if not q.exists():errors.append({'path':str(p.relative_to(N)),'target':target,'error':'broken_native_document_link'})
for aid in ['A001','A002','A003']:
 s=json.loads((N/f'agent/{aid}/state.json').read_text())
 if s['execution_state']!='planned' or any(s.get(k) for k in ['actual_model','actual_effort','runtime_id','thread_id']):errors.append({'agent':aid,'error':'false_runtime_state'})
receipt=json.loads((N/'project/E001_baseline_import/experiment_results/runs/R001/copy_receipt.json').read_text())
if receipt['status']!='PASS_COPY_VERIFIED' or receipt['errors']:errors.append({'error':'copy_not_pass'})
links=json.loads((N/'project/E001_baseline_import/experiment_results/runs/R001/symlink_mapping.json').read_text())
for item in links:
 p=D/item['path']
 if not p.is_symlink() or not p.exists() or not p.resolve().is_relative_to(D):errors.append({'path':item['path'],'error':'copied_link_not_internal_and_valid'})
for e,execution,verdict in [('E001','completed','supported'),('E002','planned','unassessed')]:
 er=reg['records']['experiment'][e]['path']
 payload=json.loads((N/er/'experiment_results/import_publication.json').read_text())
 if (payload['execution_state'],payload['verdict'])!=(execution,verdict):errors.append({'experiment':e,'error':'wrong_scope_verdict'})
out={'status':'PASS_NATIVE_PROJECT_INTEGRATION' if not errors else 'FAIL_NATIVE_PROJECT_INTEGRATION','timestamp':datetime.datetime.now(datetime.timezone.utc).isoformat(),'native_markdown_files':len(docs),'native_links_checked':checked_links,'copied_internal_symlinks_verified':len(links),'registered_counts':{k:len(v) for k,v in reg['records'].items()},'copy_status':receipt['status'],'new_agents_launched':False,'new_hardware_validation_run':False,'source_baseline_preserved':pathlib.Path(receipt['source']).is_dir(),'errors':errors}
(N/'results/project_integration_receipt.json').write_text(json.dumps(out,ensure_ascii=False,indent=2)+'\n')
with (N/'results/native_documents_sha256.jsonl').open('w') as f:
 for p in sorted(docs):f.write(json.dumps({'path':str(p.relative_to(N)),'sha256':hashlib.sha256(p.read_bytes()).hexdigest()},ensure_ascii=False)+'\n')
print(json.dumps(out,ensure_ascii=False))
if errors:raise SystemExit(2)
