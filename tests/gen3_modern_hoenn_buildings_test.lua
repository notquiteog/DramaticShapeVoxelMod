local released={};local adapters={};local doors={};local modules={SceneryModels={releaseBatches=function(parts)for _,p in ipairs(parts)do released[p]=true end end},Gen3ImportedGymNotices={build=function(c,n,p)return p,nil,3 end,floor=function(c)return c.notice end}}
local definitions={{'petalburg_city_gym','Gen3ImportedGyms','Gen3GymDoors','importedGymDoors','oras_hoenn_gym'},{'oldale_mart','Gen3ImportedMarts','Gen3MartDoors','importedMartDoors','oras_oldale_mart'},{'oldale_house','Gen3ImportedOldaleHomes','Gen3OldaleDoors','importedOldaleDoors','oras_oldale_home_northwest'}}
local fault
for _,f in ipairs(definitions)do
 modules[f[2]]={build=function(g,c,n,p)
  p[#p+1]={created=true};g[f[4]]={};g.importedHoenn={model=f[5]}
  if fault=='throw'then error('provider upload interrupted')end
  if fault=='partial'then g[f[4]]=nil end
  return fault~='false','source rejected'
 end}
 modules[f[3]]={release=function(g)g[f[4]]=nil end,draw=function(g,a,d)d('mesh','image');return true end,ownsDoor=function(g,x,y)return x==g.cx+1 and y==g.cy+3 end}
end
local V={require=function(n)return assert(modules[n],n)end};local M=assert(loadfile('lib/Gen3ModernHoennBuildings.lua'))(V)
for _,f in ipairs(definitions)do
 local g={cx=2,cy=4,custom={family='rse',name=f[1]}};local sentinel={};local parts={sentinel}
 assert(M.build(g,{},function()end,parts));assert(g.modernHoennBuilding==f[1]and #parts==2)
 assert(M.ownsDoor(g,3,7)and not M.ownsDoor(g,4,7));local draws=0;assert(M.draw(g,{},function()draws=draws+1 end)and draws==1)
 M.release(g);assert(not g.importedHoenn and not g[f[4]]and not g.modernHoennBuilding);assert(not M.ownsDoor(g,3,7)and not M.draw(g,{},function()end))
 for _,mode in ipairs{'throw','partial','false'}do
  fault=mode;local before=#parts;local ok,err=M.build(g,{},function()end,parts)
  assert(not ok and err and #parts==before and parts[1]==sentinel and not released[sentinel]);assert(not g.importedHoenn and not g[f[4]]and not M.ownsDoor(g,3,7))
 end;fault=nil
end
assert(not M.build({custom={family='rse',name='unreviewed'}},{},function()end,{}))
local parts={};local result,err,n=M.prepare({},function()end,parts);assert(result==parts and n==3 and M.ground({notice=1})==1)
print('PASS reviewed Hoenn dispatch, closed/animated door ownership, exact release, exception/incomplete/source-failure atomic rollback and paired notice API')
