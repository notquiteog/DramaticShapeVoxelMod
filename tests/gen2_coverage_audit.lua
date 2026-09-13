-- Read-only census of an imported Crystal cache. Run from the engine root:
-- luajit <mod>/tests/gen2_coverage_audit.lua <import>/data/generated <mod> <out>
-- Reports generic solids separately: a classified box is not an authored model,
-- and generic solids include genuine room walls as well as unfinished props.
local input,modRoot,out=assert(arg[1]),assert(arg[2]),assert(arg[3])
local maps=dofile(input..'/maps.lua')
local sets=dofile(input..'/tilesets.lua')
local recipes=dofile(modRoot..'/data/gen2_furniture.lua')
local Map=require('src.world.gen2.Map')
local V={require=function(name)
  assert(name=='Generation',name);return {isGen2=function()return true end}
end}
local Shape=assert(loadfile(modRoot..'/lib/Gen2TileShape.lua'))(V)
local summary,unresolved={},{}
local totalMaps,totalObjects,totalGeneric=0,0,0
for id,def in pairs(maps) do
  local map=Map.new(def,assert(sets[def.tileset]))
  local set=def.tileset
  local row=summary[set] or {maps=0,objects=0,generic=0,cells=0,recipes=0}
  summary[set]=row;row.maps=row.maps+1;totalMaps=totalMaps+1
  local covered={}
  for _,recipe in ipairs(recipes[set] or {}) do
    local h,w=#recipe.tiles,#recipe.tiles[1]
    for ty=0,def.height*4-h do for tx=0,def.width*4-w do
      if map:tileAt(tx,ty)==recipe.tiles[1][1] then
        local match=true
        for y=1,h do for x=1,w do
          if map:tileAt(tx+x-1,ty+y-1)~=recipe.tiles[y][x] then match=false end
        end end
        if match then
          row.objects=row.objects+1;totalObjects=totalObjects+1
          for y=0,h-1 do for x=0,w-1 do covered[(ty+y)*4096+tx+x]=true end end
        end
      end
    end end
  end
  for cy=0,map.heightCells-1 do for cx=0,map.widthCells-1 do
    row.cells=row.cells+1
    local t0,t1=map:tileAt(cx*2,cy*2),map:tileAt(cx*2,cy*2+1)
    local class=Shape.classAt(map,cx,cy,Shape.paletteOf(map.tileset,t0),Shape.paletteOf(map.tileset,t1))
    if (class=='wall' or class=='counter') and not covered[cy*2*4096+cx*2] then
      row.generic=row.generic+1;totalGeneric=totalGeneric+1
      local tiles={}
      for y=0,1 do for x=0,1 do tiles[#tiles+1]=map:tileAt(cx*2+x,cy*2+y) end end
      local key=set..'\t'..table.concat(tiles,',')
      local u=unresolved[key] or {count=0,map=id,x=cx,y=cy,class=class}
      unresolved[key]=u;u.count=u.count+1
    end
  end end
end
local ids={};for id in pairs(summary) do ids[#ids+1]=id end;table.sort(ids)
local f=assert(io.open(out..'/coverage.tsv','w'))
f:write('tileset\tmaps\tcells\tmatched furniture\tgeneric solid cells\n')
for _,id in ipairs(ids) do local r=summary[id];f:write(id,'\t',r.maps,'\t',r.cells,'\t',r.objects,'\t',r.generic,'\n') end
f:close()
local pending={};for key,r in pairs(unresolved) do pending[#pending+1]={key=key,r=r} end
table.sort(pending,function(a,b) if a.r.count==b.r.count then return a.key<b.key end return a.r.count>b.r.count end)
f=assert(io.open(out..'/generic-solids.tsv','w'))
f:write('tileset\ttile drawing\tcells\texample map\tx\ty\tclass\n')
for _,p in ipairs(pending) do local r=p.r;f:write(p.key,'\t',r.count,'\t',r.map,'\t',r.x,'\t',r.y,'\t',r.class,'\n') end
f:close()
print(('Audited %d maps / %d tilesets: %d whole furniture matches; %d generic solid cells (%d distinct drawings, including walls)'):format(totalMaps,#ids,totalObjects,totalGeneric,#pending))
