from pathlib import Path
p=Path(__file__).resolve().parents[1]/'RecoverySource/RecoveryVerification.cs'
s=p.read_text(encoding='utf-8-sig').replace('.Drop(p,true,true)', '.Drop(true)')
s=s.replace('x.Tool is FishingRod','x is FishingRod').replace('(bool)x.Weapon','x is Weapon').replace('(bool)x.Creature','x is Creature')
s=s.replace('x=>x.Weapon)', 'x=>x is Weapon)').replace('x=>x.Creature&&x.Creature.BossType==BossType.None','x=>x is Creature c&&c.BossType==BossType.None').replace('x=>x.Creature&&x.Creature.BossType==BossType.Boss','x=>x is Creature c&&c.BossType==BossType.Boss')
s=s.replace('var kb=InputSystem.AddDevice', 'InputSystem.settings.backgroundBehavior=InputSettings.BackgroundBehavior.IgnoreFocus;GameInfo.Input.ActivateInput();GameInfo.Input.actions.Enable();var kb=InputSystem.AddDevice')
s=s.replace('PlayerCamera.ToggleMouse(false);var start', 'PlayerCamera.ToggleMouse(false);yield return null;File.AppendAllText(Path.Combine(folder,"input-context.txt"),"focus="+Application.isFocused+" map="+GameInfo.Input.currentActionMap+" moveEnabled="+GameInfo.Input.actions["PlayerMove"].enabled+" devices="+kb.enabled+","+mouse.enabled+"\\n");var start')
s=s.replace('if(p.Dying.IsDead){Check(false,"Player died before "+g.id);break;}', 'if(p.Dying.IsDead){Server.Instance.ResurrectPlayer(p,p.Dying.DeadPlayer);yield return new WaitForSecondsRealtime(1);p.Vitals.Heal(100);Check(!p.Dying.IsDead,"Fixture resurrected after destructive gifts");}')
s=s.replace('p.Vitals._syncedHealth.Value=70;p.Vitals._syncedFullness.Value=70;', 'p.Vitals._syncedHealth.Value=70;p.Vitals._syncedFullness.Value=70;p.Vitals._syncedFire.Value=0;p.Vitals._syncedPoison.Value=0;Server.Instance.TeleportPlayer(p,SpawnManager.MainSpawnPos,SpawnManager.MainSpawnRot);yield return new WaitForSecondsRealtime(.2f);')
s=s.replace('yield return new WaitForSecondsRealtime(3);yield return ReadState();', 'if(p.Dying.IsDead){Server.Instance.ResurrectPlayer(p,p.Dying.DeadPlayer);yield return new WaitForSecondsRealtime(1);}yield return new WaitForSecondsRealtime(3);yield return ReadState();')
p.write_text(s,encoding='utf-8')
