local V,modules={},{}
function V.require(n)
 if not modules[n]then modules[n]=assert(loadfile('lib/'..n..'.lua'))(V)end
 return modules[n]
end
modules.BuildBudget={tick=function()end,check=function()end}
modules.TreePresentation={props={get=function()return 'modeled'end}}
local O=V.require('Gen3Outdoor');local hull=V.require('VoxelHull');local build=hull.build;local calls=0
hull.build=function(...)calls=calls+1;return build(...)end
local source={getPixel=function(_,x,y)
 if x>=16 and x%16>=2 and x%16<14 and y>=2 and y<15 then return .1,.5,.1,1 end
 return .2,.7,.3,1
end}
local ts={cols=2,rows=1,midToSlot={[0]=0,[1]=1},imageData=source}
local uv={{.5,0},{1,0},{1,1},{.5,1}}
local function mesh(cx,cy,cache,atlas)
 local out={}
 local c={cx=cx,cy=cy,mid=1,ts=atlas or ts,shape={kind='shrub',ground=0}}
 O.plant(c,function(p,t,shade)
  for i,v in ipairs(p)do out[#out+1]=table.concat({v[1]-cx*16,v[2],v[3]-cy*16,t[i][1],t[i][2],shade},',')end
 end,uv,cache)
 return table.concat(out,';')
end
local expected=mesh(0,0);assert(#expected>0)
local cache={};assert(mesh(0,0,cache)==expected and calls==2)
for i=1,20 do assert(mesh(i,-i,cache)==expected,'shared shrub recipe changed model or source UVs')end
assert(calls==2,'identical shrub remeshed for every placement')
assert(mesh(0,0,{})==expected and calls==3,'new build retained stale recipe')
local other={cols=2,rows=1,midToSlot=ts.midToSlot,imageData=source}
assert(mesh(0,0,cache,other)==expected and calls==4,'provider identities shared recipe')
print('PASS exact translated shrub geometry/materials, one hull per build/art/provider, fresh-build invalidation')
