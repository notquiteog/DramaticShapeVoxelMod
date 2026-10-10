local A=dofile('lib/ArchitecturalDetails.lua')
for _,style in ipairs({'gable','barrel','hipped_barrel'})do
 local p={w=64,back=2,front=63,wall=26,roofEnd=40}
 local function uv(...)return {...}end
 local source={};A.roof(p,style,11,uv,function(v,t)source[#source+1]=t end,{})
 p.roofBack=16;local n=0;local soffit=false
 A.roof(p,style,11,uv,function(v,t)
  n=n+1
  for _,q in ipairs(v)do assert(q[3]>=14.5 and q[3]<=64.5,style..' rear overhang')end
  -- Every source sample remains unchanged after only the world rear changes.
  -- Hipped shoulder uses its new slope length but retains native endpoints.
  if style~='hipped_barrel' then for i,a in ipairs(t)do assert(a==source[n][i],style..' cropped source art')end end
  if v[1][2]==24.8 and v[2][2]==24.8 and v[3][2]==24.8 and v[4][2]==24.8 then soffit=true end
 end,{})
 assert(n==#source and soffit,style..' open underside')
end
print('Pitched/barrel rear eaves bounded to moved wall, source UVs preserved, undersides closed PASS')
