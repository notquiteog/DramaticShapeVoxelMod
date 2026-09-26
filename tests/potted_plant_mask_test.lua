local Plant=assert(loadfile('lib/Gen2Planter.lua'))()
local function floor(x,y)
 if (x+y)%2==0 then return .95,.7,.85,1 end
 return 1,1,1,1
end
local function source(x,y)
 local r,g,b,a=floor(x,y)
 if y<12 then r,g,b=.7,.7,.65 end
 if x>=5 and x<=10 and y>=2 and y<=11 then r,g,b=.2,.65,.25 end
 if x>=4 and x<=11 and y>=15 and y<=22 then r,g,b=.3,.3,.3 end
 -- Enclosed pale glaze shares a background colour but belongs to the pot.
 if x==7 and y==18 then r,g,b=1,1,1 end
 return r,g,b,a,(x+.5)/16,(y+.5)/24
end
local cutout=Plant.cutout(16,24,source,floor)
local function alpha(x,y)local _,_,_,a=cutout(x,y);return a end
assert(alpha(0,3)==0 and alpha(3,5)==0,'wallpaper remains attached')
assert(alpha(0,14)==0 and alpha(15,15)==0,'checker floor remains attached')
assert(alpha(7,6)==1,'green leaf erased')
assert(alpha(7,18)==1,'enclosed glaze erased')
local model=Plant.fromDrawing(16,24,cutout)
assert(#model>0 and #model<=280)
for _,q in ipairs(model)do for i=1,4 do
 assert(q[i][1]>=0 and q[i][1]<=16 and q[i][3]>=0 and q[i][3]<=24)
end end
print('PASS plant wall/floor cutout, enclosed highlights and solid model bounds')
