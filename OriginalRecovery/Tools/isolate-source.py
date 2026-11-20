from pathlib import Path
import re,shutil,json
base=Path('OriginalRecovery');root=base/'GameSource';backup=base/'Evidence/SourceOriginals';changes=[]
def method(s,signature,body):
 start=s.index(signature);a=s.index('{',start);depth=1;i=a+1
 while depth:
  if s[i]=='{':depth+=1
  elif s[i]=='}':depth-=1
  i+=1
 return s[:a+1]+'\n'+body+'\n\t'+s[i-1:]
for p in root.rglob('*.cs'):
 s=p.read_text(encoding='utf-8-sig');t=s
 t=t.replace('Application.persistentDataPath','RecoveryIsolation.PersistentDataPath').replace('PlayerPrefs.','RecoveryPrefs.')
 t=t.replace('SteamUser.GetSteamID()','RecoveryPlatform.GetSteamID()').replace('SteamFriends.GetPersonaName()','RecoveryPlatform.GetPersonaName()').replace('SteamFriends.GetFriendPersonaName(','RecoveryPlatform.GetFriendPersonaName(').replace('SteamUtils.GetSteamUILanguage()','RecoveryPlatform.GetLanguage()')
 if p.name=='SteamManager.cs':
  t=method(t,'private void Awake()', '\t\tSetter.SetSingleInstance(ref _instance, this);\n\t\t_netMan.ServerManager.OnRemoteConnectionState += OnRemoteConnectionState;')
  t=method(t,'private void Start()', '\t\t// Local recovery uses the original offline transport.')
  t=t.replace('SteamAPI.Shutdown();','// Steam API is not initialized by local recovery.')
  t=method(t,'public static void CreateLobby()', '\t\tConnectionManager.Instance.CreateOfflineLobby();')
 if p.name=='ConnectionManager.cs':t=t.replace('Callback<LobbyEnter_t>.Create(OnLobbyEntered);','// Offline recovery does not subscribe to Steam callbacks.')
 if p.name=='ButtonManager.cs':t=t.replace('private bool _useSteam = true;', 'private bool _useSteam = false;')
 if p.name=='AchievementManager.cs':
  t=method(t,'private static void UnlockAchievement(string achievementName)', '\t\tRecoveryPrefs.SetInt("achievement:" + achievementName, 1);')
  t=method(t,'private static bool HasAchievement(string achievementName)', '\t\treturn RecoveryPrefs.GetInt("achievement:" + achievementName, 0) != 0;')
  t=method(t,'public static void ToggleAllAchievements(bool unlocked)', '\t\tforeach (var f in typeof(AchievementManager).GetFields(System.Reflection.BindingFlags.Static|System.Reflection.BindingFlags.NonPublic))\n\t\t\tif (f.IsLiteral && f.FieldType == typeof(string)) RecoveryPrefs.SetInt("achievement:" + (string)f.GetRawConstantValue(), unlocked ? 1 : 0);')
 if s!=t:
  b=backup/p.relative_to(root);b.parent.mkdir(parents=True,exist_ok=True)
  if not b.exists():shutil.copy2(p,b)
  p.write_text(t,encoding='utf8');changes.append(str(p.relative_to(root)))
(base/'Evidence/isolation-changes.json').write_text(json.dumps(changes,indent=2),encoding='utf8')
print('Isolated',len(changes),'original source files')
