local V=...
local M={}
function M.build(t,data,perRow,aw,ah)
 local out={}
 local function tex(x,y)
  local id=t.tiles[math.floor(y/8)+1][math.floor(x/8)+1]
  return {(id%perRow*8+x%8+.5)/aw,(math.floor(id/perRow)*8+y%8+.5)/ah}
 end
 local function emit(p,uv,shade)p.uv=uv;p.shade=shade or 1;out[#out+1]=p end
 local function sample(x,y)local uv=tex(x,y);return {uv,uv,uv,uv}end
 local function box(l,b,n,r,h,s,uv)
  emit({{l,h,n},{l,h,s},{r,h,s},{r,h,n}},uv)
  emit({{l,b,s},{l,b,n},{r,b,n},{r,b,s}},uv,.65)
  emit({{l,b,s},{r,b,s},{r,h,s},{l,h,s}},uv,.86)
  emit({{r,b,n},{l,b,n},{l,h,n},{r,h,n}},uv,.72)
  emit({{l,b,n},{l,b,s},{l,h,s},{l,h,n}},uv,.76)
  emit({{r,b,s},{r,b,n},{r,h,n},{r,h,s}},uv,.8)
 end
 local function source(sx,sy,sw,sh,a,b,c,d)
  local function p(u,v)local q={};for i=1,3 do q[i]=(a[i]*(1-u)+b[i]*u)*(1-v)+(d[i]*(1-u)+c[i]*u)*v end;return q end
  for y=sy,sy+sh-1 do for x=sx,sx+sw-1 do
   local u,v=(x-sx)/sw,(y-sy)/sh;local uv=tex(x,y)
   emit({p(u,v),p(u+1/sw,v),p(u+1/sw,v+1/sh),p(u,v+1/sh)},{uv,uv,uv,uv})
  end end
 end
 if t.design=='wall' then
  local f=t.wallFront
  box(0,t.wallLow,f-.25,8,t.wallHigh,f,sample(1,1))
  -- Preserve the original wallpaper as one continuous thin face.
  source(0,0,8,8,{0,t.wallHigh,f+.01},{8,t.wallHigh,f+.01},{8,t.wallLow,f+.01},{0,t.wallLow,f+.01})
 else assert(V.require('InteriorFurniture').draw(t.design,{source=source,sample=sample,box=box}),'unknown interior model '..t.design)end
 return out
end
-- Fill only the north-wall backing in reviewed rooms. Claiming a whole
-- computer or kitchen drawing must not punch a blank patch in its wallpaper.
function M.backing(S,map,perRow,aw,ah)
 local tile=({TILESET_PLAYERS_HOUSE=17,TILESET_PLAYERS_ROOM=2,TILESET_LAB=17,TILESET_POKECENTER=2})[map.tileset.id]
 if not tile then return end
 local uv={{(tile%perRow*8+.05)/aw,(math.floor(tile/perRow)*8+.05)/ah},
  {(tile%perRow*8+7.95)/aw,(math.floor(tile/perRow)*8+.05)/ah},
  {(tile%perRow*8+7.95)/aw,(math.floor(tile/perRow)*8+7.95)/ah},
  {(tile%perRow*8+.05)/aw,(math.floor(tile/perRow)*8+7.95)/ah}}
 for x=0,map.def.width*32-8,8 do
  S.objectQuads[#S.objectQuads+1]={{x,24,15.9},{x+8,24,15.9},{x+8,0,15.9},{x,0,15.9},uv=uv,shade=1,own=true}
 end
end
return M
