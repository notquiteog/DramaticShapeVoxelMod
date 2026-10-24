local released={};local adapters={};local doors={};local modules={SceneryModels={releaseBatches=function(parts)for _,p in ipairs(parts)do released[p]=true end end},Gen3ImportedGymNotices={build=function(c,n,p)return p,nil,3 end,floor=function(c)return c.notice end,ownsProp=function(p)return p.notice==true end}}
local definitions={{'littleroot_player_house','Gen3ImportedLittlerootHomes','Gen3LittlerootDoors','importedLittlerootDoors','oras_littleroot_home_west',3,'littlerootHomes',4},{'littleroot_rival_house','Gen3ImportedLittlerootHomes','Gen3LittlerootDoors','importedLittlerootDoors','oras_littleroot_home_east',1,'littlerootHomes',4},{'petalburg_city_gym','Gen3ImportedGyms','Gen3GymDoors','importedGymDoors','oras_hoenn_gym',1,'hoennGyms'},{'oldale_mart','Gen3ImportedMarts','Gen3MartDoors','importedMartDoors','oras_oldale_mart',1,'hoennMarts'},{'oldale_house','Gen3ImportedOldaleHomes','Gen3OldaleDoors','importedOldaleDoors','oras_oldale_home_northwest',1,'oldaleHomes'},{'petalburg_city_wide_home','Gen3ImportedPetalburgHomes','Gen3PetalburgDoors','importedPetalburgDoors','oras_petalburg_home_wide',2,'petalburgHomes'},{'rustboro_small_tan','Gen3ImportedRustboroHomes','Gen3RustboroDoors','importedRustboroDoors','oras_rustboro_cutters',2,'rustboroHomes',4},{'rustboro_devon_corporation','Gen3ImportedDevon','Gen3DevonDoors','importedDevonDoors','oras_rustboro_devon',4,'rustboroDevon',8},{'slateport_city_mart','Gen3ImportedSlateportMart','Gen3SlateportMartDoors','importedMartDoors','oras_slateport_mart',1,'hoennMarts',3},{'slateport_oceanic_museum','Gen3ImportedSlateportMuseum','Gen3MuseumDoors','importedMuseumDoors','oras_slateport_museum',2,'hoennMuseums',4},{'slateport_harbor','Gen3ImportedSlateportHarbor','Gen3HarborDoors','importedHarborDoors','oras_slateport_harbor',3,'hoennHarbors',5}}
local byName={};for _,f in ipairs(definitions)do byName[f[1]]=f end
local fault
for _,f in ipairs(definitions)do
 modules[f[2]]={build=function(g,c,n,p)
  local f=byName[g.custom.name]
  p[#p+1]={created=true};g[f[4]]={};g.importedHoenn={model=f[5]}
  if fault=='throw'then error('provider upload interrupted')end
  if fault=='partial'then g[f[4]]=nil end
  return fault~='false','source rejected'
 end}
 modules[f[3]]={release=function(g)local f=byName[g.custom.name];g[f[4]]=nil end,draw=function(g,a,d)d('mesh','image');return true end,ownsDoor=function(g,x,y)local f=byName[g.custom.name];return x==g.cx+f[6] and y==g.cy+(f[8]or 3) end}
end
local V={require=function(n)return assert(modules[n],n)end};local M=assert(loadfile('lib/Gen3ModernHoennBuildings.lua'))(V)
for _,f in ipairs(definitions)do
 local g={cx=2,cy=4,custom={family='rse',name=f[1]}};local sentinel={};local parts={sentinel}
 assert(M.build(g,{},function()end,parts));assert(g.modernHoennBuilding==f[1]and M.kind(g)==f[7]and #parts==2)
 assert(M.ownsDoor(g,2+f[6],4+(f[8]or 3))and not M.ownsDoor(g,3+f[6],4+(f[8]or 3)));local draws=0;assert(M.draw(g,{},function()draws=draws+1 end)and draws==1)
 M.release(g);assert(not g.importedHoenn and not g[f[4]]and not g.modernHoennBuilding and not M.kind(g));assert(not M.ownsDoor(g,2+f[6],4+(f[8]or 3))and not M.draw(g,{},function()end))
 for _,mode in ipairs{'throw','partial','false'}do
  fault=mode;local before=#parts;local ok,err=M.build(g,{},function()end,parts)
  assert(not ok and err and #parts==before and parts[1]==sentinel and not released[sentinel]);assert(not g.importedHoenn and not g[f[4]]and not M.ownsDoor(g,2+f[6],4+(f[8]or 3)))
 end;fault=nil
end
assert(not M.build({custom={family='rse',name='unreviewed'}},{},function()end,{}))
assert(M.ownsProp({notice=true})and not M.ownsProp({}))
local parts={};local result,err,n=M.prepare({},function()end,parts);assert(result==parts and n==3 and M.ground({notice=1})==1)
print('PASS reviewed Hoenn dispatch, closed/animated door ownership, exact release, exception/incomplete/source-failure atomic rollback and paired notice API')
