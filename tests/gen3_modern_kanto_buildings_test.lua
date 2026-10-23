local calls={};local modules={}
local V={require=function(n)return assert(modules[n],n)end}
for _,q in ipairs{{'saffronBlocks','Gen3ImportedSaffronBlocks',false,'importedSaffronBlock'},{'lavenderNameRater','Gen3ImportedLavenderNameRater','Gen3LavenderTentEntrance','importedLavenderNameRater'},{'lavenderHouses','Gen3ImportedLavenderHouses','Gen3LavenderHouseDoors','importedLavenderHouse'},{'viridianFlowerHouses','Gen3ImportedViridianFlowerHouses','Gen3ViridianFlowerHouseDoors','importedViridianFlowerHouse'},{'pewterHouses','Gen3ImportedPewterHouses','Gen3PewterHouseDoors','importedPewterHouse'},{'hgssGyms','Gen3ImportedHGSSGyms','Gen3HGSSGymDoors','importedHGSSGym'}}do
 local kind,building,doors,marker=unpack(q)
 modules[building]={eligible=function(g)return g.candidate==kind end,build=function(g,_,_,parts)
  if g.missing then return false,'source image unavailable'end;g[marker]={};g.door=kind~='saffronBlocks';parts[#parts+1]=kind;return true
 end,chimney=kind=='pewterHouses'and function()return{y=42}end or nil,doorSurface=function()return marker end}
 if kind=='saffronBlocks'then modules[building].doorSurface=nil end
 if doors then modules[doors]={draw=function(g,anim,draw)calls[#calls+1]={kind,anim};draw();return true end,release=function(g)g.door=nil end,ownsDoor=function(g,x,y)return g.door and x==3 and y==4 or false end}end
end
local M=assert(loadfile('lib/Gen3ModernKantoBuildings.lua'))(V)
local absent={};assert(not M.build(absent,{},function()error('unknown source upload')end,{}));assert(not M.kind(absent)and not M.draw(absent,{},function()end)and not M.release(absent)and not M.ownsDoor(absent,3,4))
for _,kind in ipairs{'saffronBlocks','lavenderNameRater','lavenderHouses','viridianFlowerHouses','pewterHouses','hgssGyms'}do
 local g={candidate=kind,missing=true};local parts={'existing'};local ok,err=M.build(g,{},function()end,parts);assert(not ok and err=='source image unavailable'and #parts==1 and not M.kind(g),'source failure must retain native fallback')
 g.missing=nil;local result,which=M.build(g,{},function()end,parts);assert(result and which==kind and M.kind(g)==kind and #parts==2)
 assert(M.ownsDoor(g,3,4)==(kind~='saffronBlocks')and not M.ownsDoor(g,4,4));local drawn=0;assert(M.draw(g,{frame=2},function()drawn=drawn+1 end)and drawn==(kind=='saffronBlocks'and 0 or 1))
 assert((M.chimney(g)~=nil)==(kind=='pewterHouses'));assert((M.doorSurface(g,3,4)~=nil)==(kind~='saffronBlocks'));assert(M.release(g)and not M.ownsDoor(g,3,4)and not M.kind(g))
end
print('PASS standalone Kanto dispatcher exact child eligibility, atomic fallback, source-door routing, chimney and teardown')
