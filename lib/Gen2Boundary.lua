-- Crystal perimeter scenery built from native edge donors and the SAME tree
-- builders/material providers used inside the map. No gameplay cells change.
local V=...
local M={counts={}}
local Select=V.require('BoundaryScenery')
local Distance=V.require('RenderDistance')
local R=V.require('Voxel3D')
local cache={}
function M.enabled(map)
 return V.require('Generation').isGen2() and map and map.def and
  (map.def.environment=='TOWN' or map.def.environment=='ROUTE' or map.def.environment=='FOREST' or map.tileset and map.tileset.id=='TILESET_FOREST')
end
function M.clear()
 for _,b in pairs(cache.batches or {})do if b.mesh then b.mesh:release()end end
 for _,k in ipairs({'wood','leaves'})do if cache[k]then cache[k]:release()end end
 cache={}
end
local function sample(r,x,y)
 local map=r.map;local ts=map.tileset
 local Class=V.require('Gen2TileShape')
 local t1,t2=map:tileAt(x*2,y*2),map:tileAt(x*2,y*2+1)
 local p1,p2=Class.paletteOf(ts,t1),Class.paletteOf(ts,t2)
 local kind=Class.classAt(map,x,y,p1,p2)
 local johto=ts.id=='TILESET_JOHTO' or ts.id=='TILESET_JOHTO_MODERN'
 local rockLip=johto and kind=='ledge' and (t1==43 or t1==44 or t1==45 or t1==59 or t1==60 or t1==61 or t1==75 or t1==76 or t1==77)
 local biome=kind=='water' and 'water' or
  ((kind=='tree' or kind=='foresttree' or kind=='roundtree') and 'forest') or
  ((rockLip or kind=='cliff' or kind=='wall' and p1~=7 and p2~=7 and p1~=2 and p2~=2)and 'mountain')or nil
 return {map=map,x=x,y=y,biome=biome,kind=kind}
end
local function quad(b,p,uv,shade)
 local base=#b.v
 for i,a in ipairs(p)do b.v[#b.v+1]={a[1],a[2],a[3],uv[i][1],uv[i][2],shade or 1}end
 for _,i in ipairs({1,2,3,1,3,4})do b.i[#b.i+1]=base+i end
end
local function tileUV(map,tile)
 local ts=map.tileset;local pr=ts.tilesPerRow or 16
 local w,h=ts.imageWidth or pr*8,ts.imageHeight or 128
 local x,y=(tile%pr)*8,math.floor(tile/pr)*8
 return {{(x+.02)/w,(y+.02)/h},{(x+7.98)/w,(y+.02)/h},
  {(x+7.98)/w,(y+7.98)/h},{(x+.02)/w,(y+7.98)/h}}
end
local function regions(state)
 local rs={}
 local function add(map,x,y)
  rs[#rs+1]={map=map,x=x/16,y=y/16,w=map.def.width*2,h=map.def.height*2}
 end
 add(state.map,0,0)
 for _,n in ipairs(state.neighbors or {})do if n.map then add(n.map,n.ox or 0,n.oy or 0)end end
 return rs
end
function M.haze(state,cx,cz,color)
 if not M.enabled(state and state.map) then return end
 local p=state.player
 if p and p.px and p.py then cx,cz=p.px+8,p.py+8 end
 local bounds
 if not Distance.radius()then
  local x0,y0,x1,y1=Select.bounds(regions(state),16)
  bounds={x0*16,y0*16,(x1+1)*16,(y1+1)*16}
 end
 return Distance.haze(color,nil,{cx,0,cz},bounds)
end
function M.draw(state,cx,cz,vw,vh,atlasFor,drawMesh)
 if not M.enabled(state and state.map)then return false end
 local p=state.player
 if p and p.px and p.py then cx,cz=p.px+8,p.py+8 end
 local draw=drawMesh or R.draw
 M.map=state.map
 local rs=regions(state)
 local radius=Distance.radius();local cells=radius and radius/16 or 64
 local bx,bz=math.floor(cx/96)*6,math.floor(cz/96)*6
 local x0,y0,x1,y1=bx-cells,bz-cells,bx+cells+6,bz+cells+6
 if not radius then x0,y0,x1,y1=Select.bounds(rs,16)end
 local flat=V.require('TreePresentation').flat()
 local parts={x0,y0,x1,y1,tostring(flat)}
 for _,r in ipairs(rs)do parts[#parts+1]=tostring(r.map)..':'..r.x..':'..r.y end
 local key=table.concat(parts,';')
 if cache.key~=key then
  M.clear();M.builds=(M.builds or 0)+1;cache.key=key;cache.batches={};M.counts={forest=0,water=0,mountain=0,ground=0}
  local wood,wi,leaves,li={},{},{},{}
  local Trees=V.require('Gen2Trees');local Leaves=V.require('Gen2DepthTrees')
  for y=y0,y1 do for x=x0,x1 do
   local _,_,_,real=Select.owner(rs,x,y)
   if not real then
    local donor=Select.resolve(rs,x,y,sample)
    if donor then
     local map=donor.map;local biome=donor.biome or 'ground'
     local b=cache.batches[map]
     if not b then b={v={},i={}};cache.batches[map]=b end
     M.counts[biome]=M.counts[biome]+1
     local h=biome=='water' and -2 or biome=='mountain' and 16 or 0
     for dz=0,1 do for dx=0,1 do
      local tile
      if biome=='forest' or biome=='ground' and donor.kind~='ground' then tile=V.require('Gen2DepthGrass').groundTile(map)or 5
      else tile=map:tileAt(donor.x*2+dx,donor.y*2+dz)end
      local xx,zz=x*16+dx*8,y*16+dz*8
      local uv=tileUV(map,tile)
      quad(b,{{xx,h,zz},{xx+8,h,zz},{xx+8,h,zz+8},{xx,h,zz+8}},uv)
      if biome=='mountain' then
       -- Closed cliff walls around the raised block, including edges exposed
       -- when a neighboring boundary segment changes to water or forest.
       for _,q in ipairs({{{xx,0,zz},{xx,h,zz},{xx+8,h,zz},{xx+8,0,zz}},
        {{xx+8,0,zz+8},{xx+8,h,zz+8},{xx,h,zz+8},{xx,0,zz+8}},
        {{xx,0,zz+8},{xx,h,zz+8},{xx,h,zz},{xx,0,zz}},
        {{xx+8,0,zz},{xx+8,h,zz},{xx+8,h,zz+8},{xx+8,0,zz+8}}})do quad(b,q,uv,.82)end
      end
     end end
     local wide=donor.kind=='foresttree'
     local round=donor.kind=='roundtree'
     if biome=='forest' and (not wide or x%2==0) and (round or y%2==0) then
      -- Match the interior builder's footprint and height, including Johto's
      -- narrow two-cell drawing versus Ilex's broad four-cell tree.
      local lift=wide and 20 or ((not round and (x*13+y*7)%3==0)and 17 or 10)
      local seed=x*31+(round and y or y+1)*17
      local tx,tz=x*16+(wide and 16 or 8),y*16+(round and 8 or wide and 16 or 24)
      local _,_,_,occupied=Select.owner(rs,math.floor(tx/16),math.floor(tz/16))
      if not occupied then
       local append=flat and Trees.appendFlatTrunk or Trees.appendTrunk
       append(wood,wi,0,tx,0,tz,lift,seed)
       Leaves.append(leaves,li,0,tx,0,tz,lift,seed,Trees.family(seed,lift),flat)
      end
     end
    end
   end
  end end
  for _,b in pairs(cache.batches)do b.mesh=R.newMesh(b.v,b.i);b.v,b.i=nil,nil end
  cache.wood=R.newMesh(wood,wi);cache.leaves=R.newMesh(leaves,li)
 end
 for map,b in pairs(cache.batches)do
  local atlas=atlasFor and atlasFor(map)or V.require('TerrainAtlas').forMap(map)
  if b.mesh and atlas then draw(b.mesh,atlas,nil)end
 end
 local bark,leaf=V.require('CommunityFlora').crystalTreeMaterials()
 if cache.wood and bark then draw(cache.wood,bark,nil)end
 if cache.leaves and leaf then draw(cache.leaves,leaf,nil)end
 return true
end
return M
