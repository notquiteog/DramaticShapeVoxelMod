local V,modules={},{}
function V.require(n)if not modules[n]then modules[n]=assert(loadfile('lib/'..n..'.lua'))(V)end;return modules[n]end
local G=V.require('Gen3RouteGates');local R=V.require('Gen3RouteRooms')
local faces=0
for _,r in ipairs(G.recipes)do
 local g={cx=0,cy=0,width=#r.rows[1],depth=#r.rows,custom=r}
 local profile=G.profile(g);assert(profile.w==128 and profile.h==g.depth*16)
 G.append(g,function(v,uv)
  faces=faces+1;local l,n,f,rr,h=1e9,1e9,-1e9,-1e9,-1e9
  for _,q in ipairs(v)do assert(q[1]>=0 and q[1]<=128 and q[3]>=0 and q[3]<=g.depth*16,r.name..' escapes footprint');l=math.min(l,q[1]);rr=math.max(rr,q[1]);n=math.min(n,q[3]);f=math.max(f,q[3]);h=math.max(h,q[2])end
  for _,t in ipairs(uv)do assert(t[1]>=0 and t[1]<=1 and t[2]>=0 and t[2]<=1,'invalid source UV')end
  if h>1 then for y=1,#r.rows do for x=1,#r.rows[y]do
   if r.permissions[y][x]==0 then assert(l>=(x-1)*16+15.99 or rr<=(x-1)*16+.01 or n>=(y-1)*16+15.99 or f<=(y-1)*16+.01,r.name..' covers walking cell '..x..':'..y)end
  end end end
 end)
 if r.forward or r.east then local x=r.east and 4 or 3;assert(G.doorSurface(g,x,g.depth-1),'native door lost');assert(not G.doorSurface(g,0,g.depth-1),'door claimed wall')end
end
assert(faces>100)
local drawings=0
for _,r in ipairs(R.recipes)do if r.kind~='plant'then
 local w,d=#r.rows[1]*16,#r.rows*16
 local function bounds(v)
  R.attach({homeWall=15.84,cy=0,recipe=r},v)
  local l,n,f,rr,h=1e9,1e9,-1e9,-1e9,-1e9
  for _,q in ipairs(v)do assert(q[1]>=0 and q[1]<=w and q[3]>=0 and q[3]<=d,r.name..' escapes drawing');l=math.min(l,q[1]);rr=math.max(rr,q[1]);n=math.min(n,q[3]);f=math.max(f,q[3]);h=math.max(h,q[2])end
  if r.walkablePad then assert(h<1,'walking seat/mat became solid')
  elseif h>1 then for y,row in ipairs(r.collisionRows)do for x,c in ipairs(row)do if c==0 then assert(l>=(x-1)*16+15.99 or rr<=(x-1)*16+.01 or n>=(y-1)*16+15.99 or f<=(y-1)*16+.01,r.name..' blocks native lane')end end end end
 end
 assert(R.draw(r.design,{sample=function()return{}end,box=function(l,b,n,rr,h,f)bounds({{l,b,n},{rr,h,f}})end,
  source=function(x,y,ww,hh,a,b,c,d)assert(x>=0 and y>=0 and x+ww<=w and y+hh<=#r.rows*16,'source outside drawing');bounds({a,b,c,d})end}))
 drawings=drawings+1
end end
local changed=false
local header={8,0x287,0x298,0x299,0x287,0x287,0x288,0x289,0x28a,0x287,0x287,0x298,0x299,0x287,8}
local def={width=15,height=12,midLayout={midAt=function(_,x,y)return y==0 and header[x+1]or y==11 and 8 or 0x281 end,collAt=function(_,x,y)return(y==0 or y==11)and 7 or y==1 and(x==7 and(changed and 0 or 114)or 7)or 0 end}}
local plan=assert(R.profile(def,'house'));assert(plan.north<16 and plan.south==176 and plan.northDoorRows==1)
changed=true;assert(not R.profile(def,'house'),'custom north walking lane enclosed');assert(not R.profile(def,'player_house'),'foreign atlas claimed')
print('PASS 3 complete native gate exteriors, '..faces..' closed faces, '..drawings..' route fixture drawings and walking-lane/header fallbacks')
package.loaded['src.core.GameVersion']={get=function()return'firered'end}
local F=V.require('Gen3Furniture')
for _,r in ipairs(R.recipes)do
 local cells={}
 for y,row in ipairs(r.rows)do for x,m in ipairs(row)do cells[(x-1)..':'..(y-1)]={cx=x-1,cy=y-1,mid=m,collision=r.collisionRows[y][x],pair='house',primary='building',secondary='house',ts={}}end end
 local props=F.extract(cells);assert(#props==1 and props[1].recipe==r,r.name..' complete source ownership')
 for _,c in pairs(cells)do c.prop=nil end;cells['0:0'].collision=r.collisionRows[1][1]==0 and 7 or 0
 for _,p in ipairs(F.extract(cells))do assert(p.recipe~=r,r.name..' ignored changed walking permissions')end
end
print('PASS all 8 native route fixture recipes own complete drawings and stand down for changed walking permissions')
local Civic=V.require('Gen3Civic')
for _,r in ipairs(G.recipes)do
 local cells={}
 for y,row in ipairs(r.rows)do for x,m in ipairs(row)do cells[(x-1)..':'..(y-1)]={cx=x-1,cy=y-1,mid=m,collision=r.permissions[y][x],pair='viridian_outdoor',primary='general',ts={},shape={kind='flat'}}end end
 local gates=Civic.prepare(cells,{},G.recipes);assert(#gates==1 and gates[1].custom==r,r.name..' complete native exterior ownership')
 if r.reverse then assert(not cells['0:0'].civic and not cells['7:0'].civic,'approach fence cells stolen');assert(Civic.ground(cells['3:0'])==0x179,'native blue entrance apron lost')end
 for _,c in pairs(cells)do c.civic=nil end
 cells['0:1'].collision=0
 assert(#Civic.prepare(cells,{},G.recipes)==0,r.name..' ignored a changed native exterior walking lane')
end
print('PASS Civic integration guards every exterior source cell/permission and preserves reverse approach fences/apron')
