local Edges=assert(loadfile('lib/Gen2GroundEdges.lua'))()
local Materials=assert(loadfile('lib/Gen2Materials.lua'))({})
local count=0
local map={tileset={id='TILESET_JOHTO'}}
function map:tileAt(x,y) return (x==0 and y==-1) and 5 or 6 end
local widths={}
local function emit(c,uv,shade)
  count=count+1
  for i,p in ipairs(c) do
    assert(p[1]>=0 and p[1]<=8 and p[3]>=0 and p[3]<=1.5)
    assert(p[2]==.035 and uv[i][1]>=0 and uv[i][1]<=1)
    widths[p[3]]=true
  end
end
local function uv()return 0,1,0,1 end
Edges.append(map,0,0,0,6,emit,uv,1)
assert(count==8,'only the grass-facing edge gets a fringe')
local varied=0;for _ in pairs(widths) do varied=varied+1 end
assert(varied>5,'fringe must vary along the edge')
for _,h in ipairs({-2,6,16}) do Edges.append(map,0,0,h,6,emit,uv,1) end
Edges.append(map,0,0,0,20,emit,uv,1)
map.tileset.id='TILESET_LAB';Edges.append(map,0,0,0,6,emit,uv,1)
map.tileset.id='OVERWORLD';Edges.append(map,0,0,0,6,emit,uv,1)
assert(count==8,'water, raised surfaces, interiors and Gen 1 must be untouched')
assert(Materials.architectureKind('TILESET_JOHTO',14)=='roof')
assert(Materials.architectureKind('TILESET_JOHTO',27)=='plaster')
assert(Materials.architectureKind('TILESET_JOHTO',50)==nil,'terrain tile is not plaster')
assert(Materials.architectureKind('TILESET_LAB',6)=='furnitureWood')
assert(Materials.architectureKind('TILESET_LAB',14)==nil,'bin art is not roofing')
assert(Materials.architectureKind('OVERWORLD',14)==nil,'Gen 1 keeps its own art')
for _,kind in ipairs({'roof','plaster','furnitureWood','window','timberTrim','wallBase'}) do
  for y=0,31 do for x=0,31 do
    local r,g,b=Materials.color(kind,x,y,.6,.5,.2,1)
    assert(r>=0 and r<=1 and g>=0 and g<=1 and b>=0 and b<=1)
  end end
end
print('ground fringe bounds, variation, exclusions and material ownership passed')
assert(Materials.architectureKind('TILESET_JOHTO_MODERN',7)=='brick')
assert(Materials.architectureKind('TILESET_KANTO',7)==nil,'Johto brick must not replace Kanto art')
local r,g,b=Materials.color('paving',5,5,1,0,1,1,true)
assert(r==b and r>.97 and g==0,'scenery material replaced the native palette')
