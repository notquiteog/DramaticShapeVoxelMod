local T=dofile('lib/Gen2BattleTowerExterior.lua')
local function key(x,y)return(y+64)*4096+x+64 end
local map={id='BATTLE_TOWER_OUTSIDE',tileset={id='TILESET_BATTLE_TOWER_OUTSIDE',tilesPerRow=16,imageWidth=128,imageHeight=128}}
function map:tileAt(x,y)return T.drawing[y+1] and T.drawing[y+1][x-7] or 6 end
function map:isWalkable(x,y)return not(x>=4 and x<=13 and y>=0 and y<=8 or y==9 and(x==7 or x==10))end
assert(T.matches(map))
local S={skip={},ground={},objectQuads={}}
assert(T.build(S,map));assert(S.gen2BattleTower.height==152 and S.gen2BattleTower.wingHeight==112)
local roles={}
for _,f in ipairs(S.objectQuads)do
 roles[f.battleTowerRole]=(roles[f.battleTowerRole]or 0)+1
 local x,z,minY=0,0,math.huge
 for _,p in ipairs(f)do
  assert(p[1]>=64 and p[1]<=224 and p[3]>=0 and p[3]<=160.01 and p[2]>=0 and p[2]<=152)
  x=x+p[1]/4;z=z+p[3]/4;minY=math.min(minY,p[2])
 end
 if minY<18 then
  if f.battleTowerRole:match('^entry%-pier') then
   if x<=128 then x=math.max(112.00001,math.min(127.99999,x)) else x=math.max(160.00001,math.min(175.99999,x)) end
  end
  x=math.max(64.00001,math.min(223.99999,x));if z==144 then z=z-.00001 end
  assert(not map:isWalkable(math.floor(x/16),math.floor(z/16)),'low solid face occupies a native walking/warp cell: '..f.battleTowerRole)
 end
 for _,uv in ipairs(f.uv)do assert(uv[1]>=0 and uv[1]<1 and uv[2]>=0 and uv[2]<1)end
end
assert(roles['wing-front']==196 and roles['shaft-glass']==96 and roles['entry-glass']==8,'original facade bands lost')
for _,r in ipairs({'wing-back','wing-side','wing-roof','wing-base','shaft-back','shaft-cap','shaft-base','entry-canopy'})do assert(roles[r],r..' not closed')end
for y=0,19 do for x=8,27 do assert(S.skip[key(x,y)] and S.ground[key(x,y)]==6)end end
local old=map.tileAt;function map:tileAt(x,y)if x==10 and y==6 then return 0 end return old(self,x,y)end
local partial={skip={},ground={},objectQuads={}};assert(not T.build(partial,map) and #partial.objectQuads==0,'partial source drawing claimed')
print('PASS Crystal Tower: complete source bands, sealed roof/back/base and clear native entry lanes')
