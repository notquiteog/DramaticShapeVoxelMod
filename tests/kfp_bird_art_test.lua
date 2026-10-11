local function data(w,h)
 local p={};local d={released=false}
 function d:getDimensions()return w,h end
 function d:getPixel(x,y)local a=p[y*w+x]or{0,0,0,0};return unpack(a)end
 function d:setPixel(x,y,...)assert(x>=0 and x<w and y>=0 and y<h);p[y*w+x]={...}end
 function d:release()self.released=true end
 return d
end
local made=0;local images={}
love={image={newImageData=data},graphics={newImage=function(d)
 made=made+1;local i={data=d};function i:setFilter(a,b)assert(a=='nearest'and b=='nearest')end
 function i:release()self.released=true end;images[#images+1]=i;return i
end}}
local src
package.loaded['src.pokemon.Sprites']={path=function(d,n,s,o)
 assert(n=='PIDGEY'and s=='front'and o.kind=='overworld');return d.path
end}
package.loaded['src.render.Assets']={imageData=function(p)
 assert(p=='native');src=data(8,8);src:setPixel(2,0,1,.5,0,1);return src
end}
local M=assert(loadfile('lib/KfpBirdArt.lua'))({require=function(n)assert(n=='Generation');return {number=function()return 2 end}end})
local d=data(8,8);d:setPixel(2,0,1,.5,0,1);local squeezed=M.squeeze(d)
local r,g,b,a=squeezed:getPixel(2,2);assert(r==1 and g==.5 and a==1)
local _,_,_,edge=squeezed:getPixel(2,0);assert(edge==0)
local game={data={path='native'}};local img=M.image(game,'pidgey','a')
assert(src.released and made==1 and M.image(game,'pidgey','a')==img)
assert(M.footing('pidgey','a')==7/8,'native transparent foot margin lost')
assert(M.image(game,'pidgey','b')~=img and made==2)
M.clear();assert(images[1].released and images[2].released)
assert(M.image(game,'pidgey','a')~=img and made==3)
print('PASS native bird resolution, centered alpha frames, bounded cache and owned-image release')
