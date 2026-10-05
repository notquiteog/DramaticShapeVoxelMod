local V,mods={},{}
function V.require(n)if not mods[n]then mods[n]=assert(loadfile('lib/'..n..'.lua'))(V)end;return mods[n]end
local S=V.require('Gen3CarvedStatue')
local reads=0
local ts={cols=1,rows=2,midToSlot={[1]=0,[2]=1},imageData={}}
function ts.imageData:getPixel(x,y)
 reads=reads+1
 if x>=3 and x<=12 and y<24 then
  if x==7 and y==10 then return .9,.9,.9,1 end -- enclosed highlight equals background
  return .2,.5,.3,1
 end
 return .9,.9,.9,1
end
local function uv()return{{0,0},{1,0},{1,1},{0,1}}end
local p={cx=0,cy=0,ts=ts,recipe={rows={{1},{2}}}}
local count,top=0,0
local function emit(vs)
 count=count+1
 for _,v in ipairs(vs)do
  assert(v[1]>=0 and v[1]<=16 and v[3]>=17 and v[3]<=31,'sculpture escaped blocked base')
  if v[2]>5 then assert(v[1]>=3 and v[1]<=13,'background became sculpture')end
  top=math.max(top,v[2])
 end
end
local function box(l,b,n,r,h,s)emit{{l,b,n},{r,h,s}}end
S.append(p,emit,uv,box,uv)
assert(count>20 and top==30,'native silhouette or plinth missing')
local before=reads;S.append(p,emit,uv,box,uv);assert(reads==before,'rebuilt cached native sculpture')
print('PASS opaque native sculpture background removal, closed bounds and atlas cache')

-- The ground-floor version has checker pixels not present on that row's
-- edges. Its reviewed floor palette removes those connected pixels too.
local floorTs={cols=1,rows=3,midToSlot={[1]=0,[2]=1,[3]=2},imageData={}}
function floorTs.imageData:getPixel(x,y)
 if y>=32 then if x%2==0 then return .9,.9,.9,1 else return .8,.8,.2,1 end end
 if x==1 or x==2 then return .8,.8,.2,1 end
 return ts.imageData:getPixel(x,y)
end
p.ts=floorTs;p.recipe.backgroundMids={3}
S.append(p,emit,uv,box,uv)
print('PASS patterned-floor sculpture excludes connected floor without deleting enclosed highlights')
