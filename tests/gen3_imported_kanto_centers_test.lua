local modules={SceneryModelData=dofile('lib/SceneryModelData.lua'),HGSSCenterData=dofile('lib/HGSSCenterData.lua'),Voxel3D={withSceneryMaterial=function(opacity,fn)assert(opacity==.8709677);fn()end},ModelInstances={},BuildBudget={check=function()end}}
local V={mod={read=function()return nil end}};V.require=function(n)return assert(modules[n],n)end
local S=assert(loadfile('lib/SceneryModels.lua'))(V);modules.SceneryModels=S
modules.Gen3ImportedGyms=assert(loadfile('lib/Gen3ImportedGyms.lua'))(V)
local D=assert(loadfile('lib/Gen3KantoCenterDoors.lua'))(V);modules.Gen3KantoCenterDoors=D
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
local old,image=S.buildBatches,S.image;local live=0
S.image=function()return{}end
local function mesh()live=live+1;return{setTexture=function()end,release=function()live=live-1 end}end
S.buildBatches=function(placements,_,opts)
 local p=assert(placements[1]);local parts,fit=assert(S.vertices(p.model,p.fit));assert(p.y==3)
 assert(math.abs(fit.anchors.door[1]-40)<1e-6 and math.abs(fit.anchors.door[3]-51)<1e-6)
 local foundation=false
 for _,part in ipairs(parts)do
  assert(part.role~='source_door','static body cannot retain glass');if part.role=='ground_shadow'then assert(part.lightingOnly,'shadow slot must never draw')end
  foundation=foundation or part.name=='authored_closed_foundation'
  for _,v in ipairs(part.vertices)do assert(v[1]>=.25-1e-6 and v[1]<=79.75+1e-6 and v[3]>=.25-1e-6 and v[3]<=63.75+1e-6 and v[2]>=-.05)end
 end
 assert(foundation);assert(fit.bounds[4]-fit.bounds[1]>74,'source footprint shrank');return opts.parts
end
for _,args in ipairs{{4},{5},{5,{0x2fc,0x2fd,0x2fe,0x306,0x2ff}}}do
 g,cells=fixture(unpack(args));assert(C.eligible(g,cells));assert(C.build(g,cells,mesh,{}));assert(live==6)
 local fit=g.importedKantoCenter;assert(D.ownsDoor(g,g.cx+2,g.cy+g.depth-1));assert(not D.ownsDoor(g,g.cx+3,g.cy+g.depth-1))
 for state=0,2 do
  local parts=assert(D.geometry(g,fit,state));assert(#parts==2)
  local n=0;for i,p in ipairs(parts)do
   n=n+#p.indices/3;assert(p.opacity==.8709677 and p.alphaMode=='blend')
   for _,v in ipairs(p.vertices)do assert(v[4]>=((i-1)/2)and v[4]<=i/2,'leaf UVs must retain exact source image half')end
   local lp={vertices={},indices=p.indices};for _,v in ipairs(p.vertices)do lp.vertices[#lp.vertices+1]={v[1]-g.cx*16,v[2],v[3]-(g.cy+g.depth-4)*16}end;assert(D.clearance(g,cells,{lp}))
  end;assert(n==4)
 end
 local drawn=0;assert(D.draw(g,{x=g.cx+2,y=g.cy+g.depth-1,frame=2},function()drawn=drawn+1 end));assert(drawn==2)
 local before=cells[g.cx..':'..(g.cy+g.depth-1)].collision;assert(before==130)
 D.release(g);assert(live==0 and cells[g.cx..':'..(g.cy+g.depth-1)].collision==130)
 local calls=0;assert(not D.build(g,fit,function()calls=calls+1;if calls==2 then return nil end;return mesh()end,cells));assert(live==0,'late source upload must release first leaf')
 if g.depth==5 then for x=0,4 do cells[(g.cx+x)..':'..g.cy].collision=7 end;assert(C.eligible(g,cells))end
end
g,cells=fixture(5,{0x29d,0x29e,0x29f,0x2a8,0x17f})
for x=0,4 do cells[(g.cx+x)..':'..g.cy].collision=x==4 and 0 or 7 end
assert(C.eligible(g,cells));cells[g.cx..':'..g.cy].collision=0;assert(not C.eligible(g,cells),'Lavender header changed');
g,cells=fixture(5,{0x282,0x283,0x284,0x285,0x286})
for x=0,4 do cells[(g.cx+x)..':'..g.cy].collision=0x29 end
assert(not C.eligible(g,cells),'water header requires its own native ground review')
g,cells=fixture(5,{0x282,0x283,0x284,0x285,0x286})
local region={def={id='FR_VERMILION_CITY'},x=g.cx-13,y=g.cy-2}
for _,c in pairs(cells)do c.region=region end
for x=0,4 do cells[(g.cx+x)..':'..g.cy].collision=0x29 end
assert(C.eligible(g,cells),'exact Vermilion water-composite header');assert(C.build(g,cells,mesh,{}));D.release(g);assert(live==0)
region.def.id='FR_PEWTER_CITY';assert(not C.eligible(g,cells),'water exception cannot escape actual original map')
g,cells=fixture(5,{0x2fc,0x2fd,0x2fe,0x306,0x2ff});region={def={id='FR_SAFFRON_CITY_CONNECTION'},x=g.cx-12,y=g.cy-27}
for _,c in pairs(cells)do c.region=region end
cells[(g.cx+2)..':'..(g.cy+4)].collision=7
assert(C.eligible(g,cells),'exact blocked-door native connection projection');assert(C.build(g,cells,mesh,{}));D.release(g);assert(live==0)
region.def.id='FR_SAFFRON_CITY';assert(not C.eligible(g,cells),'projection cannot erase a real city doorway')
g,cells=fixture(5);S.buildBatches=function()return nil,'late body upload'end;local ok,why=C.build(g,cells,mesh,{});assert(not ok and why=='late body upload'and live==0 and not g.importedKantoCenterDoors)
S.buildBatches,S.image=old,image
print('PASS FR/LG Center exact native guards, source-filled closed body without duplicate glass/shadow, bounded split-source sliding poses, alpha/UV preservation and atomic fallback')
