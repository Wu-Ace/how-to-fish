from pathlib import Path
root=Path(__file__).resolve().parents[1]
for name,ancestor in [('Manta','Fish'),('BowheadWhale','Fish'),('Piranha','Fish'),('Spidercrab','Creature')]:
 for base in [root/'GameSource',root/'RecoveredProject/ExportedProject/Assets/Scripts/Assembly-CSharp']:
  p=base/(name+'.cs');s=p.read_text(encoding='utf-8-sig');s=s.replace('(('+ancestor+')this).Awake();','// Preserve the original nonvirtual ancestor call; the intermediate base only guards network initialization.\n\t\tbase.Awake();');p.write_text(s,encoding='utf-8')
print('Repaired four decompiled virtual ancestor Awake calls')
