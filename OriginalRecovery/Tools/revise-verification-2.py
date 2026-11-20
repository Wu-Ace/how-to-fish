from pathlib import Path
p=Path(__file__).resolve().parents[1]/'RecoverySource/RecoveryVerification.cs'
s=p.read_text(encoding='utf-8')
start=s.index(' foreach(byte id in new byte[]')
end=s.index(' OnlineIslandManager.ToggleTeleportPlayers(true);OnlineIslandManager.Instance.SpawnIsland(0);',start)
islands=s[start:end]
islands=islands.replace('Island.CurIsland.gameObject.scene.buildIndex!=id+1','!SceneManager.GetSceneByBuildIndex(id+1).isLoaded').replace('Island.CurIsland&&Island.CurIsland.gameObject.scene.buildIndex==id+1','SceneManager.GetSceneByBuildIndex(id+1).isLoaded')
islands=islands.replace('yield return new WaitForSecondsRealtime(.3f);yield return Capture', 'yield return new WaitForSecondsRealtime(2);yield return Capture')
s=s[:start]+s[end:]
where=s.index(' for(int i=0;i<GiftCatalog.All.Count;')
s=s[:where]+islands+' OnlineIslandManager.ToggleTeleportPlayers(true);OnlineIslandManager.Instance.SpawnIsland(0);yield return new WaitForSecondsRealtime(4);\n'+s[where:]
s=s.replace('if(g.id.StartsWith("weapon/"))', 'if(g.id=="chaos/random_skin")Give(GameInfo.ItemWithSkinsforCommands.FirstOrDefault());else if(g.id.StartsWith("weapon/"))')
p.write_text(s,encoding='utf-8')
