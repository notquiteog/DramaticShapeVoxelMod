local V,cache={},{}
function V.require(n)
 if not cache[n]then cache[n]=assert(loadfile('lib/'..n..'.lua'))(V)end
 return cache[n]
end
cache.BuildBudget={check=function()end}
local mode,custom='modeled',false
cache.TreePresentation={props={get=function()return mode end}}
cache.CommunityVisuals={customSigns=function()return custom end}
local S=V.require('SceneryModels');local G=V.require('Gen3SceneryModels')
local function sign(x,coll,kind)
 return{cx=x,cy=4,base=13,mid=2,collision=coll,primary='general',shape={kind=kind or'sign'}}
end
local cells={a=sign(1,130),b=sign(2,7),walk=sign(3,0),flower=sign(4,130,'flowers'),
 edge=sign(5,130),stage=sign(6,130)}
cells.edge.boundary='ground';cells.stage.stageHidden=true
local placements=G.placements(cells);assert(#placements==2 and placements[1].x==16 and placements[2].x==32)
mode='cards';assert(#G.placements(cells)==0);mode='modeled'
custom=true;assert(#G.placements(cells)==0,'optional native sign override replaced');custom=false
local original=S.buildBatches;local unavailable=true
S.buildBatches=function(list,upload,options)
 assert(#list==2 and type(upload)=='function')
 if unavailable then return nil,'unavailable'end
 return options.parts
end
assert(not G.build(cells,function()end,{})and not cells.a.importedSign,'native sign removed on asset failure')
unavailable=false;local owned={};local out,_,count=G.build(cells,function()end,owned)
assert(out==owned and count==2 and cells.a.importedSign and not cells.walk.importedSign)
S.buildBatches=original
local uv={{.1,.2},{.5,.2},{.5,.6},{.1,.6}}
local a,i=G.face(cells.a,uv);assert(#a==6 and #i==6)
for _,p in ipairs(a)do
 assert(p[1]>16 and p[1]<32 and p[3]>64 and p[3]<80,'message escaped native sign square')
 assert(p[2]>13 and p[2]<29,'native local ground ignored')
 assert(p[4]>=.1 and p[4]<=.5 and p[5]>=.2 and p[5]<=.6,'native message outside actual atlas')
end
local first=a[1][1];a[1][1]=-10000
assert(G.face(cells.a,uv)[1][1]==first,'overlay mutated shared source geometry')
assert(cells.a.mid==2 and cells.a.collision==130 and cells.a.base==13)
assert(not G.face(cells.flower,uv),'HD-2D flower converted')
print('PASS native blocked sign eligibility, source fit, actual message topology, regional UV and source immutability, custom/failure standdown')
