local modules={}
local V={require=function(n)return assert(modules[n],n)end}
local calls,failAt,uploaded,released=0,nil,{},{}
local Models={limits={placements=4096}}
modules.SceneryModels=Models
function Models.buildBatches(list,upload,opts)
 calls=calls+1;assert(#list<=4096,'native forest bypassed upload bound')
 if calls==failAt then return nil,'texture/upload failed'end
 local part={count=#list,id=calls};opts.parts[#opts.parts+1]=part
 for _,p in ipairs(list)do uploaded[#uploaded+1]=p end
 return opts.parts
end
function Models.releaseBatches(parts)for _,p in ipairs(parts)do released[#released+1]=p end end
local T=assert(loadfile('lib/ImportedTrees.lua'))(V)
local list={}
for i=1,8193 do local source={mid=i,collision=7,base=6};local paired={}
 list[i]={source=source,sources={paired},treeInfo={index=i}}
end
T.gen3Placements=function()return list end
local prior={existing=true};local dest={prior}
local result,err,count=T.buildGen3({},function()end,dest,{region='hoenn'})
assert(result==dest and not err and count==8193 and calls==3 and #uploaded==8193)
assert(dest[1]==prior and dest[2].count==4096 and dest[3].count==4096 and dest[4].count==1)
for i,p in ipairs(list)do
 assert(uploaded[i]==p and p.source.importedTree==p.treeInfo and p.sources[1].importedTree==p.treeInfo)
 assert(p.source.mid==i and p.source.collision==7 and p.source.base==6)
 p.source.importedTree=nil;p.sources[1].importedTree=nil
end
calls,failAt,uploaded,released=0,3,{},{}
dest={prior};result,err,count=T.buildGen3({},function()end,dest)
assert(not result and err=='texture/upload failed'and count==8193 and #dest==1 and dest[1]==prior)
assert(#released==2 and released[1].id==2 and released[2].id==1)
for _,p in ipairs(list)do assert(not p.source.importedTree and not p.sources[1].importedTree,'partial upload hid native tree')end
calls,failAt,uploaded,released=0,nil,{},{}
list={};assert(T.buildGen3({},function()end,{}));assert(calls==1)
print('PASS forests above4096/8192: bounded uploads, complete ownership, exact ordering, atomic late failure and caller resource preservation')
