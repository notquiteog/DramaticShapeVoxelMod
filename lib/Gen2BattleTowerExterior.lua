-- Crystal's complete glass landmark. Native projected roof/facade/entrance
-- bands become distinct closed volumes; source map, collisions and warps stay
-- authoritative. Partial/replaced drawings decline this specialized model.
local M={}
local function key(x,y)return(y+64)*4096+x+64 end
local rows={
 {192,193,193,193,193,193,194,131,132,133,134,132,139,197,193,193,193,193,193,198},
 {199,200,0,0,0,0,201,147,148,149,150,148,156,202,0,0,0,0,203,204},
 {158,174,196,196,196,196,206,131,132,133,134,132,139,207,195,195,195,195,175,157},
 {128,158,205,205,205,205,205,147,148,149,150,148,156,205,205,205,205,205,157,140},
}
for i=1,6 do
 rows[#rows+1]={158,128,129,141,141,141,130,131,132,133,134,132,139,129,141,141,141,130,140,157}
 rows[#rows+1]={128,158,144,145,145,145,146,147,148,149,150,148,156,144,145,145,145,146,157,140}
end
rows[17]={128,128,129,141,167,160,0,161,162,163,164,162,165,0,166,168,141,143,140,140}
rows[18]={187,128,129,141,169,176,177,178,178,178,178,178,178,179,180,170,142,143,140,191}
rows[19]={6,187,188,189,171,159,208,185,181,182,181,182,185,211,173,172,189,190,191,6}
rows[20]={6,6,6,6,6,6,209,186,183,184,183,184,186,210,6,6,6,6,6,6}
M.drawing=rows
function M.matches(map)
 if map.id~='BATTLE_TOWER_OUTSIDE' or map.tileset.id~='TILESET_BATTLE_TOWER_OUTSIDE' then return false end
 for y,row in ipairs(rows)do for x,tile in ipairs(row)do if map:tileAt(x+7,y-1)~=tile then return false end end end
 -- Refuse a replacement map that moved a walking lane through the body.
 for y=0,8 do for x=4,13 do if map:isWalkable(x,y)then return false end end end
 if map:isWalkable(7,9) or map:isWalkable(10,9) or not map:isWalkable(8,9) or not map:isWalkable(9,9)then return false end
 return true
end
function M.geometry(map)
 local out={};local ts=map.tileset
 local per,aw,ah=ts.tilesPerRow or 16,ts.imageWidth or 128,ts.imageHeight or 128
 local function uv(tile,solid)
  local x,y=tile%per*8,math.floor(tile/per)*8
  if solid then local t={(x+4.5)/aw,(y+4.5)/ah};return{t,t,t,t}end
  return{{(x+.03)/aw,(y+.03)/ah},{(x+7.97)/aw,(y+.03)/ah},{(x+7.97)/aw,(y+7.97)/ah},{(x+.03)/aw,(y+7.97)/ah}}
 end
 local function q(p,tile,shade,solid,role)
  for _,v in ipairs(p)do v[1]=v[1]+64 end
  p.uv=uv(tile,solid);p.shade=shade or 1;p.battleTowerRole=role;out[#out+1]=p
 end
 local function front(l,r,z,b,h,tile,shade,role)
  q({{l,h,z},{r,h,z},{r,b,z},{l,b,z}},tile,shade,false,role)
 end
 local function box(l,b,n,r,h,s,tile,role)
  q({{l,h,n},{l,h,s},{r,h,s},{r,h,n}},tile,1,true,role)
  q({{l,b,s},{l,b,n},{r,b,n},{r,b,s}},tile,.65,true,role)
  q({{l,b,s},{r,b,s},{r,h,s},{l,h,s}},tile,.88,true,role)
  q({{r,b,n},{l,b,n},{l,h,n},{r,h,n}},tile,.72,true,role)
  q({{l,b,n},{l,b,s},{l,h,s},{l,h,n}},tile,.78,true,role)
  q({{r,b,s},{r,b,n},{r,h,n},{r,h,s}},tile,.8,true,role)
 end
 -- Six complete window-storey bands and the original lower facade. All
 -- vertical source bands retain their order; none are printed on the roof.
 for by=0,13 do for bx=0,19 do if bx<7 or bx>12 then
  front(bx*8,bx*8+8,144,104-by*8,112-by*8,rows[by+5][bx+1],1,'wing-front')
 end end end
 -- Native glass and structural trim continue around both sides and rear.
 -- These are new unseen views of the same materials, never mirrored doors.
 for by=0,13 do
  local hi,lo=112-by*8,104-by*8
  for z=0,136,8 do
   local pane=by%2==0 and 141 or 145
   local tile=(z==0 or z==136) and (by%2==0 and 158 or 128) or pane
   q({{0,hi,z},{0,hi,z+8},{0,lo,z+8},{0,lo,z}},tile,.78,false,'wing-side')
   q({{160,hi,z+8},{160,hi,z},{160,lo,z},{160,lo,z+8}},tile,.84,false,'wing-side')
  end
  for x=0,152,8 do
   local tile=(x==0 or x==152 or x%40==0) and 128 or (by%2==0 and 141 or 145)
   q({{x+8,hi,0},{x,hi,0},{x,lo,0},{x+8,lo,0}},tile,.72,false,'wing-back')
  end
 end
 -- Closed base and a shallow pink-edged, pale flat roof. The taller central
 -- shaft passes through this roof; reflections belong on vertical glass.
 local function roof(x,z)return 112+math.min(4,x,160-x,z,144-z)end
 for z=0,136,8 do for x=0,152,8 do
  q({{x,roof(x,z+8),z+8},{x+8,roof(x+8,z+8),z+8},{x+8,roof(x+8,z),z},{x,roof(x,z),z}},
   (x==0 or x==152 or z==0 or z==136) and 193 or 0,1,true,'wing-roof')
  q({{x,0,z},{x+8,0,z},{x+8,0,z+8},{x,0,z+8}},128,.6,true,'wing-base')
 end end
 -- Eight native bands wrap a chamfered projecting central glass shaft.
 for row=0,15 do
  local hi,lo=152-row*8,144-row*8
  q({{56,hi,144},{64,hi,152},{64,lo,152},{56,lo,144}},rows[row+1][8],.86,false,'shaft-glass')
  for col=8,11 do front(col*8,col*8+8,152,lo,hi,rows[row+1][col+1],1,'shaft-glass')end
  q({{96,hi,152},{104,hi,144},{104,lo,144},{96,lo,152}},rows[row+1][13],.9,false,'shaft-glass')
  for z=128,136,8 do
   q({{56,hi,z},{56,hi,z+8},{56,lo,z+8},{56,lo,z}},row%2==0 and 132 or 148,.78,false,'shaft-side')
   q({{104,hi,z+8},{104,hi,z},{104,lo,z},{104,lo,z+8}},row%2==0 and 132 or 148,.82,false,'shaft-side')
  end
  for x=56,96,8 do q({{x+8,hi,128},{x,hi,128},{x,lo,128},{x+8,lo,128}},row%2==0 and 132 or 148,.72,false,'shaft-back')end
 end
 local rim={{56,128},{104,128},{104,144},{96,152},{64,152},{56,144}}
 for i,a in ipairs(rim)do local b=rim[i%#rim+1]
  q({{80,152,140},{a[1],152,a[2]},{b[1],152,b[2]},{80,152,140}},131,1,true,'shaft-cap')
  q({{80,24,140},{b[1],24,b[2]},{a[1],24,a[2]},{80,24,140}},0,.65,true,'shaft-base')
 end
 -- Complete portico. Only the two native blocked side cells carry low
 -- geometry. Yellow entrance panes stand behind the two floor-level warps.
 for _,range in ipairs({{48,64,6},{96,112,12}})do
  box(range[1],0,144,range[2],18,159.9,185,'entry-pier')
  for col=0,1 do for row=0,1 do
   front(range[1]+col*8,range[1]+col*8+8,159.92,row==0 and 9 or 0,row==0 and 18 or 9,
    rows[19+row][range[3]+col+1],1,'entry-pier-art')
  end end
 end
 box(48,18,144,112,24,160,0,'entry-canopy')
 for col=6,13 do front(col*8,col*8+8,160.002,18,24,rows[18][col+1],1,'entry-canopy-art')end
 box(64,0,143.5,96,18,143.9,185,'entry-door-back')
 for row=0,1 do for col=8,11 do
  front(col*8,col*8+8,143.92,8-row*8,16-row*8,rows[19+row][col+1],1,'entry-glass')
 end end
 return out
end
function M.build(S,map)
 if not M.matches(map)then return false end
 for y=0,19 do for x=8,27 do if S.skip[key(x,y)]then return false end end end
 local quads=M.geometry(map)
 for _,q in ipairs(quads)do S.objectQuads[#S.objectQuads+1]=q end
 for y=0,19 do for x=8,27 do S.skip[key(x,y)]=true;S.ground[key(x,y)]=6 end end
 S.exteriors=S.exteriors or {};S.exteriors[#S.exteriors+1]={x=8,y=0,width=20,depth=20,style='battle_tower',height=152}
 S.gen2BattleTower={quads=#quads,height=152,wingHeight=112}
 return true
end
return M
