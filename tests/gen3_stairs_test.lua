local recipes=dofile('data/gen3_stairs.lua')
local S=assert(loadfile('lib/Gen3Stairs.lua'))({data=function()return recipes end})
local function uv()return{{0,0},{1,0},{1,1},{0,1}}end
local counts={up=0,down=0}
for _,r in ipairs(recipes)do
 local cells={}
 for z=0,1 do for x=0,1 do cells[x..':'..z]={cx=x,cy=z,pair=r.pair,mid=r.rows[z+1][x+1],ts={},shape={kind='flat'}}end end
 assert(S.prepare(cells)==1,'missing complete native flight')
 local n,lo,hi=0,math.huge,-math.huge
 for _,c in pairs(cells)do S.append(c,function(p,t)
  n=n+1;for i,v in ipairs(p)do for _,k in ipairs(v)do assert(k==k and math.abs(k)<128)end;assert(t[i]);lo=math.min(lo,v[2]);hi=math.max(hi,v[2])end
 end,uv)end
 assert(n>20,'missing stair sides/treads')
 assert(r.down and lo<0 and hi==0 or not r.down and lo==0 and hi>16,'wrong flight direction')
 counts[r.down and 'down' or 'up']=counts[r.down and 'down' or 'up']+1
 for _,c in pairs(cells)do c.stairs=nil end
 cells['1:1'].mid=-1;assert(S.prepare(cells)==0,'partial artwork borrowed an unrelated tile')
end
for _,kind in ipairs({'steps','ladder'})do for _,down in ipairs({false,true})do
 local n=0;S.append({cx=0,cy=0,mid=1,ts={},shape={kind=kind,down=down}},function()n=n+1 end,uv);assert(n>10)
end end
print('PASS native staircase assemblies '..counts.up..' up / '..counts.down..' down, whole-pattern guards and ladders')
