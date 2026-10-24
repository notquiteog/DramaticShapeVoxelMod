local mods={SceneryModelData={},SaffronDojoData=dofile('lib/SaffronDojoData.lua'),ModelInstances={},BuildBudget={check=function()end}}
local V={mod={read=function()return nil end}};V.require=function(n)return assert(mods[n],n)end
mods.SharedModelMesh=dofile('lib/SharedModelMesh.lua')
local S=assert(loadfile('lib/SceneryModels.lua'))(V);mods.SceneryModels=S;local G=assert(loadfile('lib/Gen3ImportedGyms.lua'))(V);mods.Gen3ImportedGyms=G
local H=assert(loadfile('lib/Gen3ImportedSaffronDojo.lua'))(V);local D=dofile('lib/Gen3SaffronDojoEntrance.lua')
local rows={{816,817,799,817,799,818},{824,825,825,825,825,826},{832,833,833,833,833,834},{821,822,823,811,812,827},{829,830,831,819,820,835}}
for _,closed in ipairs{false,true}do
 local g={kind='gym',cx=37,cy=8,width=6,depth=5,pair='general__rom_082d4b9c',groundHeight=0};local cells={};local region={def={id=closed and'FR_SAFFRON_CITY_CONNECTION'or'FR_SAFFRON_CITY'},x=closed and 10 or 0,y=closed and 7 or 0}
 for y,row in ipairs(rows)do for x,mid in ipairs(row)do local perm=y==5 and(x>=3 and x<=5 and(x==4 and 113 or 7)or 0)or 7;cells[(g.cx+x-1)..':'..(g.cy+y-1)]={civic=g,pair=g.pair,mid=mid,base=y==5 and(x==4 or perm==0)and 16 or 0,collision=perm,region=region}end end
 assert(H.eligible(g,cells));local c=cells['37:9'];c.base=1;assert(not H.eligible(g,cells));c.base=0;c.boundary=true;assert(not H.eligible(g,cells));c.boundary=nil
 local door=cells['40:12'];door.collision=7;assert(not H.eligible(g,cells),'exact original doorway permission only');door.collision=113
 region.def.id='FR_CERULEAN_CITY';assert(not H.eligible(g,cells));region.def.id=closed and'FR_SAFFRON_CITY_CONNECTION'or'FR_SAFFRON_CITY'
 assert(H.register());local parts,fit=assert(S.vertices(H.id,{width=96,depth=64,padding=.25,groundInset=.05,anchor='door',targetX=56,targetZ=49}));assert(G.clearance(g,cells,parts));assert(fit.bounds[4]-fit.bounds[1]>69 and fit.bounds[6]-fit.bounds[3]>53 and fit.anchors.door[1]==56 and fit.anchors.door[3]==49)
 local names={};for _,p in ipairs(parts)do names[p.name]=true;assert(p.role~='source_shading'and p.role~='ground_shadow'and p.role~='source_door')end
 for _,n in ipairs{'authored_rear_plaster_wall','authored_rear_plinth','authored_rear_eave_returns','authored_cross_roof_soffit','authored_closed_foundation'}do assert(names[n],n)end
 assert(not H.build(g,cells,function()error('missing image before upload')end,{}));assert(not D.ownsDoor(g,40,12))
 local original=S.buildBatches;S.buildBatches=function(p,_,o)assert(p[1].y==0 and p[1].z==144);return o.parts end
 assert(H.build(g,cells,function()end,{}));assert(D.ownsDoor(g,40,12)and not D.ownsDoor(g,39,12));assert(D.draw(g)and not D.draw({}));S.buildBatches=original
end
print('PASS exact Saffron Dojo city/connection projection, triangle mask, original open portal, source closure/inset and missing-image fallback')
