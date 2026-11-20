import struct,json
from pathlib import Path
for path in [Path('OriginalRecovery/Builds/OriginalRuntime/How to Fish.exe'),Path('OriginalRecovery/Builds/OriginalRuntime/UnityPlayer.dll')]:
 d=path.read_bytes(); pe=struct.unpack_from('<I',d,0x3c)[0];count=struct.unpack_from('<H',d,pe+6)[0];opt=pe+24;size=struct.unpack_from('<H',d,pe+20)[0];sections=[]
 for i in range(count):
  off=opt+size+i*40;name=d[off:off+8].rstrip(b'\0').decode();vs,va,raw,ptr=struct.unpack_from('<IIII',d,off+8);sections.append((name,va,max(vs,raw),ptr))
 def rva(n):
  for _,va,sz,ptr in sections:
   if va<=n<va+sz:return ptr+n-va
  return n
 imp=struct.unpack_from('<I',d,opt+120)[0];pos=rva(imp);imports=[]
 while any(d[pos:pos+20]):
  nr=struct.unpack_from('<I',d,pos+12)[0];o=rva(nr);imports.append(d[o:d.index(b'\0',o)].decode());pos+=20
 print(path.name,sections,imports)
