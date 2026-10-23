local modules={SceneryModelData=dofile('lib/SceneryModelData.lua'),HGSSCenterData=dofile('lib/HGSSCenterData.lua'),ModelInstances={},BuildBudget={check=function()end}}
local V={mod={read=function()return nil end}};V.require=function(n)return assert(modules[n],n)end
modules.SharedModelMesh=dofile('lib/SharedModelMesh.lua')
local S=assert(loadfile('lib/SceneryModels.lua'))(V);modules.SceneryModels=S
local C=assert(loadfile('lib/Gen3ImportedKantoCenters.lua'))(V)
local function fixture(depth,header)
 local rows={{0x48,0x49,0x4a,0x4b,0x187},{0x50,0x51,0x52,0x53,0x18f},{0x58,0x59,0x5a,0x5b,0x197},{0x60,0x61,0x62,0x186,0x19f}}
 if depth==5 then table.insert(rows,1,header or{0x17b,0x17c,0x17d,0x17e,0x17f})end
 if header and header[1]==0x2fc then rows[5][1],rows[5][5]=0x2df,0x307 end
 local g={cx=7,cy=9,kind='center',width=5,depth=depth,pair='outdoor',rows=rows,groundHeight=3}
 local cells={};for y,row in ipairs(rows)do for x,mid in ipairs(row)do cells[(g.cx+x-1)..':'..(g.cy+y-1)]={civic=g,primary='general',pair=g.pair,mid=mid,base=3,collision=depth==5 and y==1 and 0 or(y==depth and(x<3 and 0x82 or x==3 and 0x71 or 7)or 7)}end end
 return g,cells
end
assert(C.register());local g,cells=fixture(5);assert(C.eligible(g,cells))
local key=g.cx..':'..g.cy;local c=cells[key]
c.collision=7;assert(not C.eligible(g,cells),'mixed header permissions');c.collision=0
c.base=4;assert(not C.eligible(g,cells));c.base=3
c.mid=0;assert(not C.eligible(g,cells));c.mid=g.rows[1][1]
c.boundary='water';assert(not C.eligible(g,cells));c.boundary=nil
g.custom={family='rse'};assert(not C.eligible(g,cells));g.custom=nil
local door=cells[(g.cx+2)..':'..(g.cy+4)];door.collision=7;assert(not C.eligible(g,cells),'connection preview without real door');door.collision=0x71
g.stageHidden=true;assert(not C.eligible(g,cells));g.stageHidden=nil
assert(not C.build(g,cells,function()error('unexpected upload without PNG')end,{}));assert(not g.importedKantoCenter)
local old=S.buildBatches;S.buildBatches=function(placements,_,opts)
 local p=assert(placements[1]);local parts,fit=assert(S.vertices(p.model,p.fit));assert(p.y==3)
 assert(math.abs(fit.anchors.door[1]-40)<1e-6 and math.abs(fit.anchors.door[3]-51)<1e-6)
 local shade,foundation,sourceDoor=false,false,false
 for _,part in ipairs(parts)do
  shade=shade or part.alphaMode=='blend' and math.abs(part.opacity-.2903226)<1e-6
  foundation=foundation or part.name=='authored_closed_foundation';sourceDoor=sourceDoor or part.role=='source_door'
  for _,v in ipairs(part.vertices)do assert(v[1]>=.25-1e-6 and v[1]<=79.75+1e-6 and v[3]>=.25-1e-6 and v[3]<=63.75+1e-6 and v[2]>=0)end
 end
 assert(shade and foundation and sourceDoor);assert(fit.bounds[4]-fit.bounds[1]>74,'source footprint shrank')
 return opts.parts
end
for _,args in ipairs{{4},{5},{5,{0x2fc,0x2fd,0x2fe,0x306,0x2ff}}}do
 g,cells=fixture(unpack(args));assert(C.eligible(g,cells));assert(C.build(g,cells,function()end,{}))
 local d=assert(C.doorSurface(g,g.cx+2,g.cy+g.depth-1));assert(d.base==3 and d.w==14 and d.h==16)
 assert(math.abs((d.vertices[1][1]+d.vertices[2][1])/2-g.cx*16-40)<1e-6)
 assert(d.vertices[1][2]>d.vertices[4][2]);assert(not C.doorSurface(g,g.cx+3,g.cy+g.depth-1))
 if g.depth==5 then for x=0,4 do cells[(g.cx+x)..':'..g.cy].collision=7 end;assert(C.eligible(g,cells))end
end
g,cells=fixture(5,{0x29d,0x29e,0x29f,0x2a8,0x17f})
for x=0,4 do cells[(g.cx+x)..':'..g.cy].collision=x==4 and 0 or 7 end
assert(C.eligible(g,cells));cells[g.cx..':'..g.cy].collision=0;assert(not C.eligible(g,cells),'Lavender header changed');
g,cells=fixture(5,{0x282,0x283,0x284,0x285,0x286})
for x=0,4 do cells[(g.cx+x)..':'..g.cy].collision=0x29 end
assert(not C.eligible(g,cells),'water header requires its own native ground review')
S.buildBatches=old
print('PASS FR/LG Center exact source/permission/height guards, blocked rectangle, source alpha, rigid portal, short-map/Saffron variants and upload fallback')
