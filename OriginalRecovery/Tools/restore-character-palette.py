from pathlib import Path
root=Path(__file__).resolve().parents[1];out=root/'RecoveredProject/ExportedProject/Assets/Shader'
p=out/'Shader Graphs_CharacterShader.shader';s=p.read_text(encoding='utf-8-sig')
if 'Recovery character palette' not in s:
 s=s.replace('sampler2D _Colors;', '// Recovery character palette: original customization vectors store palette UVs, not RGB.\n float4 _SkinColor,_PrimaryColor,_SecondColor,_ThirdColor;sampler2D _Colors;')
 s=s.replace('float3 c=tex2D(_Colors,i.uv).rgb;', '''float3 c=tex2D(_Colors,i.uv).rgb;
 float skin=step(.75,c.r)*step(.55,c.g)*(1-step(.15,c.b));
 float2 skinUV=dot(_SkinColor.xy,_SkinColor.xy)>.0001?frac(_SkinColor.xy):float2(.97,.27);
 c=lerp(c,tex2D(_Colors,skinUV).rgb,skin);
 if(_PrimaryColor.z>.5&&c.r>.8&&c.g<.15&&c.b<.15)c=tex2D(_Colors,frac(_PrimaryColor.xy)).rgb;
 if(_SecondColor.z>.5&&c.g>.8&&c.r<.15&&c.b<.15)c=tex2D(_Colors,frac(_SecondColor.xy)).rgb;
 if(_ThirdColor.z>.5&&c.b>.8&&c.r<.15&&c.g<.15)c=tex2D(_Colors,frac(_ThirdColor.xy)).rgb;''')
 p.write_text(s,encoding='utf-8')
p=out/'Shader Graphs_SkyboxShader.shader';s=p.read_text(encoding='utf-8-sig').replace('o.dir=mul(unity_ObjectToWorld,p).xyz-_WorldSpaceCameraPos','o.dir=mul((float3x3)unity_ObjectToWorld,p.xyz)');p.write_text(s,encoding='utf-8')
print('Character palette UV controls and skybox camera-relative direction restored')
