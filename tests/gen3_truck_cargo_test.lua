local edition='emerald'
package.loaded['src.core.GameVersion']={get=function()return edition end,generation=function()return 3 end}
local V,cache={},{}
function V.require(n)if not cache[n]then cache[n]=assert(loadfile('lib/'..n..'.lua'))(V)end;return cache[n]end
local T,H,F=V.require('Gen3TruckCargo'),V.require('Gen3Hoenn'),V.require('Gen3Furniture')
local recipe
for _,r in ipairs(H.recipes)do if r.name=='hoenn_truck_cargo'then recipe=r end end
assert(recipe)
local blocked={'11111','10000','10000','11100','11111'}
local closed={[0x208]=0x20d,[0x210]=0x215,[0x218]=0x21d}
local function cells(shut)
 local out={}
 for y,row in ipairs(recipe.rows)do for x,mid in ipairs(row)do
  if shut then mid=closed[mid]or mid end
  out[(x-1)..':'..(y-1)]={cx=x-1,cy=y-1,mid=mid,pair=recipe.pair,primary='general',
   secondary='inside_of_truck',ts={},collision=blocked[y]:sub(x,x)=='1'and 7 or 0}
 end end
 return out
end
for _,ed in ipairs{'ruby','sapphire','emerald'}do
 edition=ed
 for _,shut in ipairs{true,false}do
  local source=cells(shut);local actual={}
  for k,c in pairs(source)do actual[k]={c.mid,c.collision}end
  local props=F.extract(source)
  assert(#props==1 and props[1].recipe==recipe,ed..' lost '..(shut and 'closed' or 'open')..' cargo')
  local claimed=0
  for k,c in pairs(source)do
   assert(c.mid==actual[k][1] and c.collision==actual[k][2],'changed native art/permissions')
   local own=blocked[c.cy+1]:sub(c.cx+1,c.cx+1)=='1'
   assert((c.prop~=nil)==own,'cargo claimed walking floor/exit or lost its blocked base')
   if own then claimed=claimed+1 end
  end
  assert(claimed==15)
  for y=1,3 do assert(not source['4:'..y].prop,'native exit consumed by cargo')end
  local damaged=cells(shut);damaged['0:2'].collision=0
  assert(#F.extract(damaged)==0,'cargo ignored changed walking clearance')
  damaged=cells(shut);damaged['4:2'].mid=1
  assert(#F.extract(damaged)==0,'unrelated door accepted as truck')
 end
 -- Each native tile can update separately; incomplete door updates must not
 -- make the unrelated, static cargo disappear for a frame.
 local transitioning=cells(false);transitioning['4:1'].mid=0x20d
 assert(#F.extract(transitioning)==1)
end
for _,ed in ipairs{'firered','leafgreen'}do edition=ed;assert(#F.extract(cells(true))==0,'truck art leaked to Kanto')end
assert(T.matches(recipe,0x20d,0x208))
for _,other in ipairs{{name=recipe.name,pair='building__generic_building',family='rse'},
 {name='other',pair=recipe.pair,family='rse',primary='general',design='em_truck_cargo'}}do
 assert(not T.matches(other,0x20d,0x208),'truck aliases leaked to another recipe')
end
assert(not T.matches(recipe,0x215,0x208),'wrong closed-door row accepted')
local def={midLayout={pair=T.pair}}
for _,ed in ipairs{'ruby','sapphire','emerald'}do assert(T.eligible(113,def,ed))end
assert(not T.eligible(113,def,'firered') and not T.eligible(1,def,'emerald'))
assert(not T.eligible(113,{midLayout={pair='building__generic_building'}},'emerald'))

local image={getDimensions=function()return 16,16 end}
local spr={image=image,frameCount=1,quads={[0]={getViewport=function()return 0,0,16,16 end}}}
local vertices,indices=T.geometry(spr,0)
assert(#vertices==24 and #indices==36,'box lost a physical face')
local edges={}
local function point(i)local p=vertices[i];return p[1]..','..p[2]..','..p[3]end
for i=1,#indices,3 do for j=0,2 do
 local a,b=point(indices[i+j]),point(indices[i+(j+1)%3]);if a>b then a,b=b,a end
 local edge=a..'/'..b;edges[edge]=(edges[edge]or 0)+1
end end
for _,count in pairs(edges)do assert(count==2,'open or doubled crate edge')end
for _,p in ipairs(vertices)do
 assert(p[1]>=-7 and p[1]<=7 and p[3]>=-7 and p[3]<=7 and p[2]>=0 and p[2]<=10)
 assert(p[4]>1/16 and p[4]<15/16 and p[5]>0 and p[5]<15/16,'UV sampled outer background')
end
assert(not T.geometry(spr,1),'unreviewed frame substituted')
assert(not T.geometry({image=image,frameCount=2,quads=spr.quads},0),'unreviewed sheet substituted')

edition='emerald'
package.loaded['src.core.game3.map']={currentDef=function()return def end}
local style='modern';cache.VisualStyles={hd2d=function(category)assert(category=='props');return style=='hd2d'end}
local uploads,releases,refuse=0,0,false
cache.Voxel3D={newMesh=function(v,i)
 uploads=uploads+1;if refuse then return nil end
 return {release=function()releases=releases+1 end}
end}
cache.Mat4=dofile('lib/Mat4.lua');cache.Water={CAST_RAISE=.05}
local draws={}
local function draw(mesh,texture,model,other,caster)draws[#draws+1]={model=model,caster=caster}end
cache.ShadowMap={snug=function(m)return m end,draw=draw}
-- x/height here are actor()'s native x+raiseX and support-raiseY. No native
-- object mutation or camera rotation is involved in this prop's placement.
assert(T.draw(113,3,16,9,spr,0,draw,nil));assert(uploads==1)
assert(draws[1].model[4]==11 and draws[1].model[8]==9 and draws[1].model[12]==24)
assert(T.draw(113,1,16,12,spr,0,draw,nil));assert(uploads==1,'animated offsets rebuilt mesh')
assert(draws[2].model[4]==9 and draws[2].model[8]==12)
local opaque=function(...)draw(...)end
assert(T.draw(113,3,16,9,spr,0,opaque,5))
assert(draws[3].model[8]==1.05 and draws[3].model[6]==-1 and draws[3].caster[8]==9)
style='hd2d';assert(not T.draw(113,3,16,9,spr,0,opaque,nil)and #draws==3)
style='voxel';assert(T.draw(113,3,16,9,spr,0,opaque,nil))
def.midLayout.pair='building__generic_building';assert(not T.draw(113,0,0,0,spr,0,opaque,nil))
def.midLayout.pair=T.pair;edition='firered';assert(not T.draw(113,0,0,0,spr,0,opaque,nil))
edition='emerald';T.clear();assert(releases==1)
refuse=true;assert(not T.draw(113,0,0,0,spr,0,opaque,nil),'upload failure suppressed native sprite fallback')
refuse=false;assert(T.draw(113,0,0,0,spr,0,opaque,nil),'failed source was permanently cached')
T.clear();assert(releases==2)
print('PASS RSE closed/open truck cargo, native exits/clearance, closed six-face moving props and source/style failure fallback')
