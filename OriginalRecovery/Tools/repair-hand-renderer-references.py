from pathlib import Path
import re,json
root=Path(__file__).resolve().parents[1];assets=root/'RecoveredProject/ExportedProject/Assets';backup=root/'Evidence/PrefabOriginals';backup.mkdir(exist_ok=True);changes=[]
for p in assets.rglob('*.prefab'):
 if p.name not in ('PlayerHolder.prefab','PlayerHolderBackup.prefab'):continue
 text=p.read_text(encoding='utf-8-sig')
 if '_handModelRight:' not in text and '_handModelLeft:' not in text:continue
 docs={int(m[2]):(int(m[1]),m[3]) for m in re.finditer(r'--- !u!(\d+) &(\d+)\n(.*?)(?=\n--- !u!|\Z)',text,re.S)}
 renderers={};children={}
 for fid,(kind,doc) in docs.items():
  go=re.search(r'm_GameObject: \{fileID: (\d+)',doc)
  if kind in (23,137) and go:renderers.setdefault(int(go[1]),[]).append(fid)
  if kind==4:
   parent=re.search(r'm_Father: \{fileID: (\d+)',doc)
   if parent:children.setdefault(int(parent[1]),[]).append(fid)
 def find_renderer(tid):
  kind,doc=docs.get(tid,(0,''));go=re.search(r'm_GameObject: \{fileID: (\d+)',doc)
  if go and int(go[1]) in renderers:return renderers[int(go[1])][0]
  for child in children.get(tid,[]):
   found=find_renderer(child)
   if found:return found
 def fix(m):
  old=int(m[2]);kind,_=docs.get(old,(0,''))
  if kind!=4:return m[0]
  new=find_renderer(old)
  if not new:raise RuntimeError('No hand renderer at '+str(p)+' '+str(old))
  changes.append({'prefab':p.relative_to(assets).as_posix(),'field':m[1],'oldTransform':old,'renderer':new})
  return m[1]+': {fileID: '+str(new)+'}'
 result=re.sub(r'(_handModel(?:Right|Left)): \{fileID: (\d+)\}',fix,text)
 if result!=text:
  b=backup/p.relative_to(assets);b.parent.mkdir(parents=True,exist_ok=True)
  if not b.exists():b.write_text(text,encoding='utf-8')
  p.write_text(result,encoding='utf-8')
(root/'Evidence/hand-renderer-references.json').write_text(json.dumps(changes,indent=2),encoding='utf-8')
print('Original hand Transform-to-Renderer reference repairs:',len(changes))
