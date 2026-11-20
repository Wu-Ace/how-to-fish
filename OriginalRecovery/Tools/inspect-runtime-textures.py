import sys
from pathlib import Path
sys.path.insert(0,r'E:/TT Gaming/needle haystack/tools/python')
import UnityPy
root=Path(__file__).resolve().parents[1]
data=root/'Builds/EditorRebuilt/HowToFishRecovered_Data'
for p in data.glob('*.assets'):
 env=UnityPy.load(str(p))
 for obj in env.objects:
  if obj.type.name!='Texture2D':continue
  d=obj.read();name=d.m_Name
  if 'Atlas' not in name and name!='Colors':continue
  try:print(p.name,name,d.m_Width,d.m_Height,d.m_TextureFormat,d.image.getextrema())
  except Exception as e:print(name,str(e)[:100])
