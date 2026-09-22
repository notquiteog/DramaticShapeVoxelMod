local B=dofile('lib/BoundaryScenery.lua')
local rs={{id='coast',x=0,y=0,w=10,h=10},{id='route',x=10,y=2,w=5,h=5}}
local function sample(r,x,y)
 return {id=r.id,x=x,y=y,biome=x==0 and 'water' or y==0 and 'mountain' or x==9 and 'forest' or nil}
end
local a,real=B.resolve(rs,10,3,sample)
assert(real and a.id=='route','synthetic fill covered actual connected map')
a,real=B.resolve(rs,-10,5,sample);assert(not real and a.biome=='water')
a=B.resolve(rs,5,-10,sample);assert(a.biome=='mountain')
a=B.resolve(rs,11,9,sample);assert(a.biome=='forest')
local before=B.resolve(rs,5,-10,sample)
assert(B.resolve(rs,5,-10,sample)==before,'stable boundary selection changed')
local x,y,u,v=B.bounds(rs,2);assert(x==-2 and y==-2 and u==17 and v==12)
local value='auto'
local V={require=function(n)assert(n=='ModSetting');return {new=function(_,_,values,labels,index)
 assert(values[1]=='auto' and values[5]==false and labels[1]=='AUTO' and index==1)
 return {get=function()return value end}
end}end}
package.loaded['src.core.Platform']={detect=function()return {mobile=true}end}
local D=assert(loadfile('lib/RenderDistance.lua'))(V)
assert(D.radius()==256)
package.loaded['src.core.Platform'].detect=function()return {}end
assert(D.radius()==512)
value=16;assert(D.radius()==256);value=32;assert(D.radius()==512);value=64;assert(D.radius()==1024)
value=false;assert(D.radius()==nil)
local f=D.haze({.6,.7,.8},1000);assert(f.start>0 and f.density>0 and f.color[1]==.6)
assert(1-math.exp(-f.density*((1000-96)-f.start))>.99,'finite edge not hidden in haze')
local rect=D.haze({.6,.7,.8},nil,{10,0,20},{-100,-300,900,200})
assert(rect.bounds[3]==900 and rect.origin[3]==20 and rect.start<1)
assert(1-math.exp(-rect.density*(1-rect.start))>.99,'FULL rectangle edge not hidden')
print('PASS real neighbors first, coast/mountain/forest perimeters, stable placement, all distance choices and horizon fade')
