local M=assert(loadfile('lib/Gen3EarlyProps.lua'))()
assert(#M.recipes==4)
for _,ed in ipairs{'emerald','ruby','sapphire'}do for _,r in ipairs(M.recipes)do assert(M.active(r,ed))end end
for _,ed in ipairs{'firered','leafgreen','yellow','third_party'}do for _,r in ipairs(M.recipes)do assert(not M.active(r,ed))end end
local uv={{0,0},{1,0},{1,1},{0,1}}
local function sampler()return uv end
for _,r in ipairs(M.recipes)do
 local faces,top,north,sourceCount=0,0,1e9,0
 local function emit(v,t)
  faces=faces+1;for i,q in ipairs(v)do
   assert(q[1]>=32 and q[1]<=48,'fixture escaped source width')
   assert(q[3]>=48 and q[3]<=48+#r.rows*16,'fixture escaped source depth')
   top=math.max(top,q[2]);north=math.min(north,q[3]);assert(q[2]>=0)
   assert(t[i][1]>=0 and t[i][1]<=1 and t[i][2]>=0 and t[i][2]<=1)
  end
 end
 local function box(a,b,c,d,e,f,t)
  emit({{a,b,c},{d,b,c},{d,e,f},{a,e,f}},t)
 end
 local function source(sx,sy,w,h,a,b,c,d)
  sourceCount=sourceCount+1
  assert(sx>=0 and sx+w<=16 and sy>=0 and sy+h<=#r.rows*16,'UV escaped native art')
  emit({a,b,c,d},uv)
 end
 assert(M.append({cx=2,cy=3,recipe=r,ts={}},source,box,sampler,emit,function()return uv end))
 assert(faces>=3 and (sourceCount>0 or r.variant=='gardenTroughs'))
 if r.variant=='gymNotice'then
  assert(north>=64,'notice intruded into walkable upper drawing')
  assert(top==27 and r.collisionRows[1][1]==0 and r.collisionRows[2][1]==7)
 elseif r.variant=='gardenTroughs'then assert(top==4.4 and r.collisionRows[1][1]==7)
 else assert(top<1 and r.collisionRows[1][1]==7,'berry soil became an actor-sized obstacle')end
end
assert(not M.append({recipe={kind='plant'}},nil,nil,nil,nil))
print('PASS three-edition source fixtures, closed notice depth, continuous native lettering, blocked footprint and shallow actor-independent berry soil')

for _,ed in ipairs{'emerald','ruby','sapphire'}do
 for _,mid in ipairs{0x164,0x165,0x16c,0x16d}do
  local q=assert(M.shape('general','petalburg',mid,7,ed));assert(q.height==16 and q.ground==0x170)
  assert(not M.shape('general','petalburg',mid,0,ed))
  assert(not M.shape('general','fortree',mid,7,ed))
 end
end
for _,mid in ipairs{0x150,0x151,0x158,0x159,0x175,0x176,0x17d,0x17e}do
 assert(not M.shape('general','petalburg',mid,7,'emerald'),'complete sea-rock owner was overridden')
end
print('PASS normal-height shoreline corners, native water underlay and complete sea-rock ownership')
local edition='emerald';package.loaded['src.core.GameVersion']={get=function()return edition end}
local V,modules={},{};function V.require(n)if not modules[n]then modules[n]=assert(loadfile('lib/'..n..'.lua'))(V)end;return modules[n]end
local F=V.require('Gen3Furniture')
for _,ed in ipairs{'emerald','ruby','sapphire'}do edition=ed
 for _,r in ipairs(M.recipes)do
  local function cells()
   local out={};for y,row in ipairs(r.rows)do for x,mid in ipairs(row)do
    out[(x-1)..':'..(y-1)]={cx=x-1,cy=y-1,mid=mid,collision=r.collisionRows[y][x],primary='general',secondary='petalburg',pair='general__petalburg',ts={}}
   end end;return out
  end
  local c=cells();local p=F.extract(c);assert(#p==1 and p[1].recipe.name==r.name,r.name..' native source ownership lost in '..ed)
  c=cells();c['0:0'].collision=r.collisionRows[1][1]==7 and 0 or 7
  for _,q in ipairs(F.extract(c))do assert(q.recipe.name~=r.name,r.name..' changed native walkability ignored')end
  c=cells();c['0:0'].collision=nil;for _,q in ipairs(F.extract(c))do assert(q.recipe.name~=r.name,r.name..' missing native permissions ignored')end
  c=cells();c['0:0'].mid=0x777;assert(#F.extract(c)==0,r.name..' unknown source claimed')
  c=cells();for _,q in pairs(c)do q.pair='general__fortree';q.secondary='fortree'end
  for _,q in ipairs(F.extract(c))do assert(q.recipe.name~=r.name,r.name..' escaped source tileset')end
 end
end
print('PASS twelve native field fixtures and custom-permission/source/tileset fallbacks')
do
 local r=M.recipes[1];assert(r.variant=='gardenTroughs')
 local greenCards=0
 local ts={cols=16,midToSlot={[7]=7,[1]=1},imageData={getPixel=function(_,x,y)
  if x==7*16+3 and(y==1 or y==10)then return .4,.8,.1,1 end
  return .2,.6,.4,1
 end}}
 assert(M.append({cx=0,cy=0,recipe=r,ts=ts},function()end,function()end,function()return uv end,function(v)
  if v[1][2]>=5 then greenCards=greenCards+1
   for _,q in ipairs(v)do assert(q[1]>=0 and q[1]<=16 and q[3]>=0 and q[3]<=16)end
   assert(v[1][3]==v[2][3]and v[2][3]==v[3][3],'HD-2D greenery grew a volume')
  end
 end,function()return uv end))
 assert(greenCards==4,'native garden foliage cards were missing or ground pixels retained')
end
print('PASS separate closed garden troughs and two-sided native HD-2D foliage cards')
