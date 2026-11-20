"""Project-authored geometry. Run with Blender 4.1 --background --python this_file.
No extracted meshes, textures, armatures, or third-party models are inputs.
"""
import bpy, math, random, json, os, sys
from mathutils import Vector
from pathlib import Path

ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'RecoveredProject/ExportedProject/Assets/ArtOriginal'
SOURCE=ROOT/'OriginalArt/Blender'
EVIDENCE=ROOT/'Evidence/OriginalArt'
for p in (OUT/'Models', SOURCE, EVIDENCE): p.mkdir(parents=True, exist_ok=True)
random.seed(18427)
M={}
def mat(name, rgb, rough=0.85, metallic=0):
 m=bpy.data.materials.new(name); m.diffuse_color=(*rgb,1);m.use_nodes=True
 p=m.node_tree.nodes.get('Principled BSDF');p.inputs['Base Color'].default_value=(*rgb,1)
 p.inputs['Roughness'].default_value=rough;p.inputs['Metallic'].default_value=metallic;M[name]=m;return m
for n,c in {'Skin':(.57,.32,.19),'SkinLight':(.72,.44,.27),'Hair':(.12,.075,.045),
 'Oilskin':(.71,.39,.085),'OilskinLight':(.88,.57,.16),'Shirt':(.17,.29,.31),
 'Bib':(.12,.19,.23),'Boot':(.09,.105,.115),'Rubber':(.055,.062,.068),
 'Metal':(.29,.34,.35),'Eye':(.84,.85,.75),'Pupil':(.035,.042,.039),
 'Wood':(.29,.18,.11),'WoodLight':(.44,.29,.16),'Roof':(.19,.27,.29),
 'Sand':(.61,.52,.36),'Earth':(.28,.225,.17),'Rock':(.29,.32,.32),
 'RockLight':(.39,.42,.40),'Grass':(.29,.38,.16),'GrassLight':(.39,.47,.21),
 'Leaf':(.18,.29,.14),'LeafLight':(.27,.38,.17),'Bark':(.24,.16,.11),
 'Autumn':(.60,.28,.085),'AutumnLight':(.73,.43,.13),'Snow':(.77,.83,.83),
 'SnowShadow':(.51,.63,.66),'Lava':(.78,.19,.035),'Volcanic':(.16,.16,.18),
 'TropicalLeaf':(.16,.36,.25),'Water':(.15,.33,.43),'Rope':(.48,.40,.26)}.items():mat(n,c)

def clear():
 bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False)
def finish(o,name,material,bone=None):
 o.name=name
 if material:o.data.materials.append(M[material])
 bpy.context.view_layer.objects.active=o
 bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
 if bone:o.vertex_groups.new(name=bone).add(list(range(len(o.data.vertices))),1,'REPLACE')
 return o
def box(name,loc,size,material,bone=None,bevel=0):
 bpy.ops.mesh.primitive_cube_add(size=1,location=loc);o=bpy.context.object;o.scale=size
 finish(o,name,material,bone)
 if bevel:
  mod=o.modifiers.new('Small tailored edges','BEVEL');mod.width=bevel;mod.segments=1
  bpy.ops.object.modifier_apply(modifier=mod.name)
 return o
def ico(name,loc,scale,material,bone=None,sub=1):
 bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=sub,radius=1,location=loc)
 o=bpy.context.object;o.scale=scale;return finish(o,name,material,bone)
def cylinder(name,a,b,r1,r2,material,bone=None,vertices=8):
 a,b=Vector(a),Vector(b);d=b-a
 bpy.ops.mesh.primitive_cone_add(vertices=vertices,radius1=r1,radius2=r2,depth=d.length,location=(a+b)/2)
 o=bpy.context.object;o.rotation_euler=d.to_track_quat('Z','Y').to_euler()
 return finish(o,name,material,bone)
def mesh(name,v,f,material):
 data=bpy.data.meshes.new(name);data.from_pydata(v,[],f);data.update()
 o=bpy.data.objects.new(name,data);bpy.context.collection.objects.link(o);data.materials.append(M[material]);return o
def join(objects,name):
 bpy.ops.object.select_all(action='DESELECT')
 for o in objects:o.select_set(True)
 bpy.context.view_layer.objects.active=objects[0];bpy.ops.object.join();o=bpy.context.object;o.name=name
 bpy.ops.object.transform_apply(location=True,rotation=True,scale=True);return o
def export(path,objects):
 bpy.ops.object.select_all(action='DESELECT')
 for o in objects:o.select_set(True)
 bpy.context.view_layer.objects.active=objects[0]
 bpy.ops.export_scene.fbx(filepath=str(path),use_selection=True,object_types={'MESH','ARMATURE'},
  apply_unit_scale=True,axis_forward='-Z',axis_up='Y',add_leaf_bones=False,
  bake_anim=True,bake_anim_use_all_actions=True,bake_anim_use_nla_strips=False,
  mesh_smooth_type='FACE',use_mesh_modifiers=True,path_mode='AUTO')
def setup_camera(target,distance,azimuth=35,elev=24,ortho=None):
 scene=bpy.context.scene
 bpy.ops.object.camera_add();cam=bpy.context.object;cam.name='PreviewCamera'
 a=math.radians(azimuth);e=math.radians(elev)
 cam.location=Vector(target)+Vector((distance*math.sin(a)*math.cos(e),-distance*math.cos(a)*math.cos(e),distance*math.sin(e)))
 cam.rotation_euler=(Vector(target)-cam.location).to_track_quat('-Z','Y').to_euler()
 if ortho:cam.data.type='ORTHO';cam.data.ortho_scale=ortho
 cam.data.lens=50;scene.camera=cam
 for name,pos,power,size in [('Key',(8,-10,15),1700,8),('Fill',(-9,-4,8),850,10),('Rim',(2,8,13),1500,7)]:
  bpy.ops.object.light_add(type='AREA',location=pos);l=bpy.context.object;l.name=name;l.data.energy=power;l.data.shape='DISK';l.data.size=size
  l.rotation_euler=(Vector(target)-l.location).to_track_quat('-Z','Y').to_euler()
 scene.world.color=(.18,.18,.18)
 scene.render.engine='BLENDER_EEVEE';scene.eevee.use_gtao=True;scene.eevee.gtao_distance=3;scene.eevee.use_soft_shadows=True;scene.eevee.taa_render_samples=96
 scene.render.resolution_x=1100;scene.render.resolution_y=900;scene.render.resolution_percentage=100
 scene.render.image_settings.file_format='PNG';scene.view_settings.view_transform='AgX'
 scene.render.film_transparent=False
 scene.world.use_nodes=True;scene.world.node_tree.nodes['Background'].inputs[0].default_value=(.10,.14,.18,1)
 scene.world.node_tree.nodes['Background'].inputs[1].default_value=.65
def render(path):
 bpy.context.scene.render.filepath=str(path);bpy.ops.render.render(write_still=True)

def character():
 clear();parts=[]
 def collect(o):parts.append(o);return o
 collect(box('Padded torso',(0,0,1.28),(.55,.29,.54),'Oilskin','Chest',.045))
 collect(box('Bib overalls waist',(0,-.025,.94),(.43,.29,.25),'Bib','Hips',.025))
 collect(box('Bib front',(0,-.174,1.19),(.34,.028,.32),'Bib','Chest',.014))
 collect(box('Bib pocket',(0,-.196,1.18),(.23,.018,.13),'Shirt','Chest',.008))
 # Distinct shoulder straps, brass buckles, coat hem and seams.
 for s in (-1,1):
  x=s*.15
  collect(box('Overall shoulder strap',(x,-.171,1.405),(.055,.035,.22),'Bib','Chest',.008))
  collect(box('Brass strap buckle',(x,-.198,1.365),(.064,.012,.044),'OilskinLight','Chest',.005))
  collect(box('Coat hem',(s*.23,0,1.045),(.10,.32,.08),'OilskinLight','Chest',.015))
 collect(cylinder('Neck',(0,0,1.50),(0,0,1.61),.10,.095,'Skin','Head'))
 collect(ico('Angular head',(0,-.005,1.72),(.175,.145,.215),'SkinLight','Head',2))
 collect(ico('Nose',(0,-.164,1.72),(.047,.075,.052),'Skin','Head',1))
 for s in (-1,1):
  collect(ico('Ear',(s*.17,0,1.73),(.035,.032,.055),'Skin','Head',1))
  collect(box('Eye white',(s*.066,-.139,1.765),(.057,.018,.025),'Eye','Head',.004))
  collect(box('Eye pupil',(s*.065,-.151,1.764),(.018,.007,.020),'Pupil','Head',.002))
  collect(box('Eyebrow',(s*.067,-.139,1.802),(.070,.024,.017),'Hair','Head',.003))
 collect(ico('Beard chin',(0,-.047,1.595),(.14,.105,.095),'Hair','Head',1))
 collect(box('Moustache',(0,-.157,1.672),(.118,.024,.027),'Hair','Head',.007))
 collect(cylinder('Knitted watch cap',(0,.01,1.825),(0,.01,1.98),.18,.145,'Shirt','Head',10))
 collect(cylinder('Folded cap cuff',(0,.01,1.82),(0,.01,1.872),.184,.184,'Bib','Head',10))
 collect(box('Cap patch',(.07,-.163,1.852),(.06,.009,.028),'OilskinLight','Head',.003))
 # A relaxed A pose. Own rig, own segment lengths, no original bind matrices.
 for s,suffix in [(-1,'L'),(1,'R')]:
  shoulder=(s*.29,0,1.46);elbow=(s*.53,0,1.20);wrist=(s*.65,-.018,.96)
  collect(ico('Tailored shoulder '+suffix,shoulder,(.13,.13,.13),'Oilskin','ArmUpper_'+suffix,1))
  collect(ico('Sleeve elbow '+suffix,elbow,(.10,.10,.10),'Oilskin','ArmLower_'+suffix,1))
  collect(cylinder('Coat sleeve upper '+suffix,elbow,shoulder,.095,.125,'Oilskin','ArmUpper_'+suffix,8))
  collect(cylinder('Coat sleeve lower '+suffix,wrist,elbow,.075,.10,'Oilskin','ArmLower_'+suffix,8))
  collect(cylinder('Sleeve cuff '+suffix,(s*.635,-.018,.99),(s*.67,-.018,.925),.082,.08,'Shirt','ArmLower_'+suffix,8))
  collect(ico('Hand '+suffix,(s*.68,-.02,.90),(.075,.065,.105),'SkinLight','Hand_'+suffix,1))
  collect(ico('Thumb '+suffix,(s*.625,-.063,.91),(.033,.04,.058),'Skin','Hand_'+suffix,1))
  x=s*.135
  collect(cylinder('Trouser thigh '+suffix,(x,0,.56),(x,0,.99),.105,.125,'Bib','LegUpper_'+suffix,8))
  collect(cylinder('Trouser shin '+suffix,(x,.008,.17),(x,0,.57),.083,.104,'Bib','LegLower_'+suffix,8))
  collect(box('Reinforced knee '+suffix,(x,-.09,.56),(.15,.025,.13),'Shirt','LegLower_'+suffix,.018))
  collect(cylinder('Rubber boot shaft '+suffix,(x,.006,.08),(x,.006,.31),.102,.11,'Boot','Foot_'+suffix,8))
  collect(box('Boot toe '+suffix,(x,-.065,.075),(.215,.33,.13),'Boot','Foot_'+suffix,.033))
  collect(box('Boot sole '+suffix,(x,-.065,.025),(.23,.35,.045),'Rubber','Foot_'+suffix,.012))
 body=join(parts,'Fisher_Original_Skinned')
 bpy.ops.object.armature_add(enter_editmode=True,location=(0,0,0));rig=bpy.context.object;rig.name='FisherRig'
 rig.data.edit_bones.remove(rig.data.edit_bones[0])
 spec=[('Hips',(0,0,.90),(0,0,1.08),None),('Chest',(0,0,1.08),(0,0,1.50),'Hips'),('Head',(0,0,1.50),(0,0,1.94),'Chest')]
 for s,suffix in [(-1,'L'),(1,'R')]:
  spec += [('ArmUpper_'+suffix,(s*.29,0,1.46),(s*.53,0,1.20),'Chest'),('ArmLower_'+suffix,(s*.53,0,1.20),(s*.65,-.018,.96),'ArmUpper_'+suffix),('Hand_'+suffix,(s*.65,-.018,.96),(s*.70,-.02,.83),'ArmLower_'+suffix),('LegUpper_'+suffix,(s*.135,0,.99),(s*.135,0,.56),'Hips'),('LegLower_'+suffix,(s*.135,0,.56),(s*.135,0,.17),'LegUpper_'+suffix),('Foot_'+suffix,(s*.135,0,.17),(s*.135,-.20,.07),'LegLower_'+suffix)]
 for n,h,t,parent in spec:
  b=rig.data.edit_bones.new(n);b.head=h;b.tail=t
  if parent:b.parent=rig.data.edit_bones[parent]
 bpy.ops.object.mode_set(mode='OBJECT');body.parent=rig
 mod=body.modifiers.new('Fisher skeletal deformation','ARMATURE');mod.object=rig
 # Useful independently-authored animation clips for preview and retargeting.
 for action_name,frames in [('Fisher_Idle',[1,30,60]),('Fisher_Walk',[1,9,17,25,33])]:
  action=bpy.data.actions.new(action_name);rig.animation_data_create();rig.animation_data.action=action
  for frame in frames:
   phase=(frame-1)/(frames[-1]-1)*math.tau
   for pb in rig.pose.bones:
    pb.rotation_mode='XYZ';pb.rotation_euler=(0,0,0)
    if action_name.endswith('Walk'):
     sign=1 if pb.name.endswith('_L') else -1
     if 'LegUpper' in pb.name:pb.rotation_euler.x=math.sin(phase)*.43*sign
     if 'LegLower' in pb.name:pb.rotation_euler.x=max(0,-math.sin(phase)*sign)*.48
     if 'ArmUpper' in pb.name:pb.rotation_euler.x=-math.sin(phase)*.24*sign
    elif pb.name=='Chest':pb.rotation_euler.x=math.sin(phase)*.018
    pb.keyframe_insert('rotation_euler',frame=frame)
 rig.animation_data.action=None
 for pb in rig.pose.bones:pb.rotation_euler=(0,0,0)
 bpy.context.scene.frame_set(1)
 export(OUT/'Models/Fisher_Original.fbx',[rig,body])
 # JSON is own geometry, useful for deterministic rig adaptation without copying old meshes.
 bones=[{'name':n,'head':h,'tail':t,'parent':p} for n,h,t,p in spec]
 (OUT/'fisher-authored-rig.json').write_text(json.dumps({'bones':bones,'heightMetres':1.98,'front':'Blender -Y; FBX Unity +Z'},indent=2),encoding='utf8')
 box('Preview floor',(0,0,-.055),(200,200,.05),'Rock')
 setup_camera((0,0,1.03),4.6,27,12,2.7)
 bpy.ops.wm.save_as_mainfile(filepath=str(SOURCE/'Fisher_Original.blend'))
 render(EVIDENCE/'fisher-front.png')
 setup_camera((0,0,1.03),4.6,155,12,2.7);render(EVIDENCE/'fisher-back.png')
 return {'name':'Fisher_Original','vertices':len(body.data.vertices),'triangles':sum(len(p.vertices)-2 for p in body.data.polygons),'bones':len(spec),'clips':['Fisher_Idle','Fisher_Walk']}

BIOMES={
 'Harbour':('Grass','GrassLight','Rock','Leaf','LeafLight'),
 'Autumn':('Grass','AutumnLight','Rock','Autumn','AutumnLight'),
 'Snow':('Snow','SnowShadow','Rock','Leaf','Snow'),
 'Volcanic':('Volcanic','Rock','Volcanic','Volcanic','Autumn'),
 'Tropical':('Grass','GrassLight','RockLight','TropicalLeaf','LeafLight')}
def island(kind,seed):
 clear();random.seed(seed);groups={};placement=[]
 def group(name,fn):
  before=set(bpy.context.scene.objects);fn();objects=[o for o in bpy.context.scene.objects if o not in before and o.type=='MESH']
  if objects:groups[name]=join(objects,name)
 base,light,rock,leaf,leaf2=BIOMES[kind]
 rx,ry={'Harbour':(25,20),'Autumn':(27,21),'Snow':(24,23),'Volcanic':(27,21),'Tropical':(29,19)}[kind]
 N=64; rings=[(0,2.7),(.18,3.1),(.38,2.4),(.61,1.55),(.79,.85),(.92,.18),(1.,-.5),(1.03,-2.1),(.81,-4)]
 def radius(a):return 1+.09*math.sin(a*3+seed*.07)+.06*math.cos(a*5+seed*.11)+.025*math.sin(a*11)
 def height(x,y):
  r=math.sqrt((x/rx)**2+(y/ry)**2)
  h=max(.15,2.7*(1-min(1,r)**1.7))+.7*math.sin(x*.13)*math.cos(y*.17)*max(0,1-r)
  return h
 verts=[];faces=[]
 for j,(r,z) in enumerate(rings):
  for i in range(N):
   a=i/N*math.tau;rr=r*radius(a);x=math.cos(a)*rx*rr;y=math.sin(a)*ry*rr
   if j==0:x,y=0,0
   zz=z+(random.uniform(-.12,.12) if j not in (0,6,7,8) else 0)
   if j in (1,2,3):zz=height(x,y)
   verts.append((x,y,zz))
 for j in range(len(rings)-1):
  for i in range(N):
   a=j*N+i;b=j*N+(i+1)%N;c=(j+1)*N+i;d=(j+1)*N+(i+1)%N
   if j==0:faces.append((a,c,d))
   elif (i+j)%2:faces.extend([(a,c,b),(b,c,d)])
   else:faces.extend([(a,c,d),(a,d,b)])
 terrain=mesh('Terrain_'+kind,verts,faces,base)
 for material in [light,'Sand','Earth',rock]:terrain.data.materials.append(M[material])
 for p in terrain.data.polygons:
  z=p.center.z # recalculated below
 terrain.data.update()
 for p in terrain.data.polygons:
  z=sum(verts[i][2] for i in p.vertices)/len(p.vertices)
  # Keep seeded prop placement unchanged while removing per-triangle color noise.
  if z>=.75:random.random()
  p.material_index=2 if -.65<z<.75 else (3 if z<-.65 else 0)
  p.use_smooth=z>=.75
 groups['Terrain']=terrain
 def pine(x,y,z,size):
  cylinder('Tapered trunk',(x,y,z),(x+.12*size,y,z+size),.15*size,.055*size,'Bark',vertices=7)
  for j in range(5):
   h=z+size*(.30+j*.13);r=size*(.37-j*.052)
   # irregular branch tier silhouette, double ring underside, ridged surface
   v=[];f=[];n=9
   for k,(rad,dz) in enumerate([(r,0),(r*.78,.18*size),(r*.20,.55*size)]):
    for i in range(n):
     a=i/n*math.tau+j*.55;rr=rad*(.80 if i%2 else 1.08)
     v.append((x+math.cos(a)*rr,y+math.sin(a)*rr,h+dz+(.05*size if i%2 else 0)))
   for k in range(2):
    for i in range(n):f.append((k*n+i,k*n+(i+1)%n,(k+1)*n+(i+1)%n,(k+1)*n+i))
   o=mesh('Needle branch tier',v,f,leaf if j%2 else leaf2)
 def palm(x,y,z,size):
  pts=[(x+size*.15*(i/5)**2,y,z+size*i/5) for i in range(6)]
  for a,b in zip(pts,pts[1:]):cylinder('Palm trunk',a,b,size*.055,size*.047,'WoodLight',vertices=7)
  top=Vector(pts[-1])
  for i in range(7):
   a=i/7*math.tau;direction=Vector((math.cos(a),math.sin(a),0));side=Vector((-math.sin(a),math.cos(a),0))
   v=[]
   for j in range(5):
    t=j/4;mid=top+direction*(t*size*.70)+Vector((0,0,math.sin(t*math.pi)*size*.20-t*size*.28));w=math.sin(t*math.pi)*size*.13
    v.extend([mid+side*w,mid+Vector((0,0,.06*size)),mid-side*w])
   f=[]
   for j in range(4):
    for k in (0,1):f.extend([(j*3+k,(j+1)*3+k,j*3+k+1),((j+1)*3+k,(j+1)*3+k+1,j*3+k+1)])
   mesh('Palm frond',[tuple(vv) for vv in v],f,leaf if i%2 else leaf2)
 def vegetation():
  for i in range(48 if kind!='Volcanic' else 9):
   a=random.uniform(0,math.tau);r=random.uniform(.30,.78);x=math.cos(a)*rx*r;y=math.sin(a)*ry*r
   if y<-4 and abs(x)<6:continue
   z=height(x,y)-.05;s=random.uniform(3.2,5.5)
   if kind=='Volcanic':
    cylinder('Dead weathered trunk',(x,y,z),(x+.15,y,z+s),s*.10,.03,'Bark',vertices=6)
    for j in range(3):
     a=j*2.1;cylinder('Dead branch',(x,y,z+s*(.4+j*.14)),(x+math.cos(a)*s*.3,y+math.sin(a)*s*.3,z+s*(.6+j*.14)),s*.045,.02,'Bark',vertices=5)
   elif kind=='Tropical':palm(x,y,z,s)
   else:pine(x,y,z,s)
   placement.append({'type':'tree','x':x,'y':z,'z':-y,'height':s})
  for i in range(58):
   a=random.uniform(0,math.tau);r=random.uniform(.28,.91);x=math.cos(a)*rx*r;y=math.sin(a)*ry*r;z=height(x,y)
   if y<-6 and abs(x)<5:continue
   if i%3==0:
    ico('Faceted shore boulder',(x,y,z+.18),(random.uniform(.5,1.6),random.uniform(.6,1.2),random.uniform(.4,1.2)),rock,sub=1)
   elif kind not in ('Snow','Volcanic'):
    for j in range(4):
     a2=random.uniform(0,math.tau);h=random.uniform(.30,.7)
     mesh('Grass blade',[(x-.08,y,z),(x+.08,y,z),(x+math.cos(a2)*.25,y+math.sin(a2)*.25,z+h)],[(0,1,2)],light)
 group('VegetationAndRocks',vegetation)
 def cabin():
  x,y,z=-4,-1,2.6
  box('Cabin footing',(x,y,z-.18),(5.3,4.3,.4),rock,bevel=.08)
  for i in range(17):
   xx=x-2.4+i*.3
   box('Rear vertical weatherboard',(xx,y+1.9,z+1.5),(.285,.16,3),'WoodLight' if i%3 else 'Wood',bevel=.018)
   if i not in (7,8,9):box('Front weatherboard',(xx,y-1.9,z+1.5),(.285,.16,3),'Wood',bevel=.012)
  for s in (-1,1):
   for i in range(13):box('Side weatherboard',(x+s*2.5,y-1.8+i*.3,z+1.5),(.16,.285,3),'WoodLight' if i%3 else 'Wood',bevel=.01)
   o=box('Standing seam roof',(x+s*1.45,y,z+3.2),(3.25,4.6,.16),'Roof',bevel=.035);o.rotation_euler.y=s*math.radians(25)
   for i in range(8):
    o=box('Roof seam',(x+s*1.45,y-2.1+i*.6,z+3.30),(3.25,.035,.035),'Metal');o.rotation_euler.y=s*math.radians(25)
  box('Door lintel',(x,y-2.01,z+2.46),(1.1,.22,.16),'WoodLight',bevel=.02)
  for s in (-1,1):box('Door jamb',(x+s*.55,y-2.01,z+1.2),(.13,.22,2.55),'WoodLight',bevel=.015)
  box('Small window glass',(x-1.48,y-2.00,z+1.8),(1.0,.04,.75),'Shirt')
  for dx in (-.54,0,.54):box('Window upright',(x-1.48+dx,y-2.05,z+1.8),(.055,.06,.85),'WoodLight')
  for dz in (-.42,.42):box('Window sill',(x-1.48,y-2.05,z+1.8+dz),(1.15,.08,.07),'WoodLight')
  cylinder('Chimney',(x+1.5,y+.9,z+2.8),(x+1.5,y+.9,z+4.0),.14,.14,'Metal',vertices=8)
  box('Chimney cap',(x+1.5,y+.9,z+4.02),(.5,.5,.08),'Metal',bevel=.015)
 group('HarbourCabin',cabin)
 def dock():
  for i in range(45):box('Dock plank',(0,-14.8-i*.36,1.1),(2.6,.34,.14),'WoodLight' if i%4 else 'Wood',bevel=.018)
  for side in (-1,1):
   for i in range(6):
    y=-15-i*2.8;cylinder('Pier pile',(side*1.5,y,-2),(side*1.5,y,1.7),.14,.12,'Wood',vertices=7)
    cylinder('Pile rope',(side*1.5,y,1.40),(side*1.5,y,1.52),.17,.17,'Rope',vertices=8)
   box('Dock structural beam',(side*1.,-22.8,.82),(.19,17,.25),'Wood')
  # Rope handrails, rusted cleats and ladder make the dock recognizable at eye level.
  for side in (-1,1):
   for i in range(5):cylinder('Dock rope rail',(side*1.5,-15-i*2.8,1.52),(side*1.5,-15-(i+1)*2.8,1.52),.028,.028,'Rope',vertices=5)
  for z in (.3,.6,.9):cylinder('Dock ladder rung',(1.4,-28,z),(2.1,-28,z),.035,.035,'Metal',vertices=6)
  for x in (1.4,2.1):cylinder('Dock ladder rail',(x,-28,-.3),(x,-28,1.4),.04,.04,'Metal',vertices=6)
 group('FishingDock',dock)
 def props():
  for x,y in [(2,-5),(3.2,-5.1),(-2,-6),(3,-3)]:
   z=height(x,y)
   box('Fishing crate',(x,y,z+.45),(.9,.85,.9),'Wood',bevel=.035)
   for zz in (z+.1,z+.78):box('Crate bracing',(x,y-.44,zz),(1.0,.06,.09),'WoodLight')
   ob=box('Diagonal crate bracing',(x,y-.47,z+.45),(1.05,.065,.10),'WoodLight');ob.rotation_euler.y=.65
  for x,y in [(2,-8),(-2,-5)]:
   z=height(x,y);cylinder('Harbour lamp post',(x,y,z),(x,y,z+2.5),.07,.06,'Metal',vertices=8)
   box('Lantern cage',(x,y,z+2.5),(.3,.3,.42),'Metal',bevel=.04)
   box('Lantern glass',(x,y-.157,z+2.5),(.20,.015,.27),'OilskinLight',bevel=.02)
  if kind=='Volcanic':
   for i in range(4):ico('Basalt outcrop',(7+i*.6,7,4+i*.7),(3-i*.4,3-i*.4,2.5),'Volcanic',sub=1)
   for i in range(5):box('Lava fissure',(7+math.sin(i)*.5,4+i*.65,3.1+i*.08),(.16,.9,.03),'Lava')
 group('HarbourProps',props)
 export(OUT/('Models/Island_'+kind+'_Original.fbx'),list(groups.values()))
 stats={'name':kind,'seed':seed,'vertices':sum(len(o.data.vertices) for o in groups.values()),'triangles':sum(sum(len(p.vertices)-2 for p in o.data.polygons) for o in groups.values()),'groups':list(groups),'treePositions':placement,'terrainFootprintMetres':[55,46],'dockTopMetres':1.07}
 (OUT/('island-'+kind.lower()+'-placement.json')).write_text(json.dumps({'trees':placement},indent=2),encoding='utf8')
 # Keep water and lighting out of exported model; preview only.
 box('Preview ocean',(0,0,-.65),(300,300,.10),'Water')
 setup_camera((0,-4,2),77,33,32,76)
 # Island requires sunlight, area lights above are used for the close character.
 bpy.ops.object.light_add(type='SUN',rotation=(.45,-.4,-.6));bpy.context.object.data.energy=2.0;bpy.context.object.data.angle=.08
 bpy.ops.wm.save_as_mainfile(filepath=str(SOURCE/('Island_'+kind+'_Original.blend')))
 render(EVIDENCE/('island-'+kind.lower()+'.png'))
 return stats

report={'authoring':'Project-created Blender geometry, no extracted assets used as mesh/texture/rig inputs','blender':bpy.app.version_string,'character':character(),'islands':[]}
for i,kind in enumerate(BIOMES):report['islands'].append(island(kind,18427+i*13))
(EVIDENCE/'authored-models.json').write_text(json.dumps(report,indent=2),encoding='utf8')
(OUT/'authored-palette.json').write_text(json.dumps({'colors':[{'name':n,'r':m.diffuse_color[0],'g':m.diffuse_color[1],'b':m.diffuse_color[2]} for n,m in M.items()]},indent=2),encoding='utf8')
(OUT/'SOURCE.txt').write_text('Project-authored replacement art. Source: OriginalRecovery/Tools/author_original_art.py and OriginalRecovery/OriginalArt/Blender. No original-game geometry, textures, rigs or third-party models were imported into these meshes. Materials are flat project-created colors. Existing game code, other scene objects and referenced assets retain their independent licensing status.\n',encoding='utf8')
print('ORIGINAL_ART_AUTHORING_COMPLETE', flush=True)
