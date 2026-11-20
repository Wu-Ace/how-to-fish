from pathlib import Path
import hashlib,json
p=Path('OriginalRecovery/Builds/OriginalRuntime/How to Fish_Data/globalgamemanagers')
original=Path(r'E:/SteamLibrary/steamapps/common/How to Fish/How to Fish/How to Fish_Data/globalgamemanagers').read_bytes()
changes=[];data=original
for a,b in [(b'Dazed Games',b'FishRecover'),(b'How to Fish',b'FishRecover')]:
 assert len(a)==len(b) and data.count(a)>=1,(a,data.count(a))
 changes.append({'old':a.decode(),'new':b.decode(),'offset':data.index(a)})
 data=data.replace(a,b)
p.write_bytes(data)
Path('OriginalRecovery/Evidence/native-settings-isolation.json').write_text(json.dumps({'originalSha256':hashlib.sha256(original).hexdigest(),'patchedSha256':hashlib.sha256(data).hexdigest(),'sameLength':len(original)==len(data),'changes':changes},indent=2))
print('Native Unity product/company isolation patched with constant byte length')

