local data=dofile('lib/SceneryModelData.lua')
local modules={SceneryModelData=data,ModelInstances={},BuildBudget={check=function()end}}
local V={mod={read=function()return nil end}};V.require=function(n)return assert(modules[n],n)end
local S=assert(loadfile('lib/SceneryModels.lua'))(V);modules.SceneryModels=S
local C=assert(loadfile('lib/Gen3ImportedCenters.lua'))(V)
local sourceX=data.oras_pokemon_center.parts[1].vertices[1][1]
assert(C.register());assert(data.oras_pokemon_center.parts[1].vertices[1][1]==sourceX)
local info=S.info(C.id);assert(info.parts==8 and info.anchors.door[1]<0)
local g={cx=5,cy=13,width=4,depth=4,kind='center',custom={family='rse',centerRoof=true}}
local cells={};for y=0,3 do for x=0,3 do cells[(g.cx+x)..':'..(g.cy+y)]={civic=g,base=0,collision=y==0 and 0 or(y==3 and x==1 and 113 or 7)}end end
assert(C.eligible(g,cells))
for _,permission in ipairs{7,41}do
 for x=0,3 do cells[(g.cx+x)..':'..g.cy].collision=permission end
 assert(C.eligible(g,cells))
end
cells['5:13'].collision=0;assert(not C.eligible(g,cells),'mixed rear row')
for x=0,3 do cells[(g.cx+x)..':'..g.cy].collision=0 end
local key='8:15';cells[key].collision=0;assert(not C.eligible(g,cells));cells[key].collision=7
cells[key].base=1;assert(not C.eligible(g,cells));cells[key].base=0
cells[key].collision=nil;assert(not C.eligible(g,cells));cells[key].collision=7
g.custom.family='frlg';assert(not C.eligible(g,cells));g.custom.family='rse'
g.stageHidden=true;assert(not C.eligible(g,cells));g.stageHidden=nil
local before={};assert(not C.build(g,cells,function()error('unexpected GPU upload')end,before));assert(not g.importedCenter and #before==0)
local build=S.buildBatches;S.buildBatches=function(placements,_,opts)
 local p=assert(placements[1]);local parts,fit=assert(S.vertices(p.model,p.fit))
 assert(math.abs(p.x+fit.anchors.door[1]-(g.cx*16+24))<1e-6)
 for _,part in ipairs(parts)do for _,v in ipairs(part.vertices)do
  assert(v[1]>=.25-1e-6 and v[1]<=63.75+1e-6 and v[3]>=.25-1e-6 and v[3]<=47.75+1e-6)
 end end
 return opts.parts
end
assert(C.build(g,cells,function()end,{}))
local d=assert(C.doorSurface(g,6,16));assert(not C.doorSurface(g,7,16))
assert(math.abs((d.vertices[1][1]+d.vertices[2][1])/2-104)<1e-6)
assert(d.vertices[4][2]==0 and d.base==0)
assert(C.shift(-.5)==-.5 and C.shift(.5)==.5)
assert(math.abs(C.shift(.1)-C.shift(-.1)-.2)<1e-6,'arched doorway was stretched')
assert(math.abs(C.shift(.4)-.4)<1e-6,'display panel was stretched')
S.buildBatches=build
print('PASS native collision/height guards, bounded source adaptation, rigid door/display, exact warp alignment and missing-resource fallback')
