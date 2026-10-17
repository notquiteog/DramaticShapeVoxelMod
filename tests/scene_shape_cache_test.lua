local Cache=dofile('lib/SceneShapeCache.lua')
local calls=0
local native={kind='tree',rows={{1,2},{3,4}}}
local classify=Cache.new(function(p,s,mid,b,c)calls=calls+1;if mid==0 then return nil end;return native end)
local a=classify('general','town',1,nil,0);a.kind='flat';a.rows[1][1]=99
local b=classify('general','town',1,nil,0)
assert(calls==1 and b.kind=='tree'and b.rows[1][1]==1 and native.rows[1][1]==1,'cell preparation poisoned shared recipes')
classify('general','town',1,nil,7);classify('general','town',1,0,0)
classify('general','town',1,nil,nil);classify('general','town',1,nil,false)
classify('general','town',2,nil,0);classify('general','route',1,nil,0)
classify('interior','town',1,nil,0);assert(calls==8,'classification inputs aliased')
assert(classify(nil,nil,0)==nil and classify(nil,nil,0)==nil and calls==9,'absent results are not cached')
local version='firered'
package.loaded['src.core.GameVersion']={get=function()return version end,generation=function()return 3 end}
package.loaded['src.core.game3.collision']={isSurfable=function(b)return b==0x10 end}
local V,modules={},{}
function V.require(n)if not modules[n]then modules[n]=assert(loadfile('lib/'..n..'.lua'))(V)end;return modules[n]end
function V.data(n)return dofile('data/'..n..'.lua')end
modules.Generation={version=function()return version end,number=function()return 3 end}
local Shape=V.require('Gen3TileShape')
local function equal(a,b)
 assert(type(a)==type(b))
 if type(a)~='table'then assert(a==b);return end
 for k,v in pairs(a)do equal(v,b[k])end
 for k in pairs(b)do assert(a[k]~=nil)end
end
local count=0
for _,edition in ipairs{'firered','leafgreen','ruby','sapphire','emerald'}do
 version=edition;local sample=Cache.new(Shape.of)
 for _,pair in ipairs{{'general','pallet_town'},{'general','petalburg'},{'building','pokemon_center'}}do
  for mid=0,1023 do for _,collision in ipairs{0,7}do
   local behavior=mid%3==0 and 0x10 or nil
   local expected=Shape.of(pair[1],pair[2],mid,behavior,collision)
   equal(expected,sample(pair[1],pair[2],mid,behavior,collision))
   equal(expected,sample(pair[1],pair[2],mid,behavior,collision));count=count+1
  end end
 end
end
print('PASS build-local classification, mutable-copy isolation, all inputs and '..count..' native classifications across five editions')
