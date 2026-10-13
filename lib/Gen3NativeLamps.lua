-- Native Rustboro's two-cell blue-gray lantern post. The upper metatile is
-- projection over walkable paving; every modeled volume stays on its base cell.
local M={ground=0x2BB,top=0x212,bottom=0x21A}
function M.prepare(cells)
 local ok,GV=pcall(require,'src.core.GameVersion');local edition=ok and GV.get() or 'emerald'
 local out={}
 for _,c in pairs(cells)do
  local b=cells[c.cx..':'..(c.cy+1)]
  if c.pair=='general__rustboro' and (c.mid==M.top or c.mid==0x213) and c.collision==0
   and b and b.pair==c.pair and (b.mid==M.bottom or c.mid==0x213 and b.mid==0x21B) and b.collision==7
   and not c.civic and not b.civic and not c.prop and not b.prop then
   local g={top=c.mid,edition=edition,cx=c.cx,cy=b.cy,pair=c.pair,ts=c.ts,width=1,depth=1,groundHeight=b.base or 0}
   c.nativeLamp=g;b.nativeLamp=g;c.nativeLampGround=c.mid==0x213 and 0x2C3 or M.ground;b.nativeLampGround=b.mid==0x21B and 0x2C3 or M.ground;out[#out+1]=g
  end
 end
 return out
end
function M.append(g,emit,uvFor)
 local source=assert(uvFor(g.ts,g.top or M.top))
 local function pixel(px,py)
  local u=source[1][1]+(source[2][1]-source[1][1])*(px+.5)/16
  local v=source[1][2]+(source[3][2]-source[1][2])*(py+.5)/16
  return {{u,v},{u,v},{u,v},{u,v}}
 end
 local rs=g.edition=='ruby' or g.edition=='sapphire'
 local dark,metal,glass=rs and pixel(9,1) or pixel(6,3),rs and pixel(8,1) or pixel(5,5),pixel(8,rs and 5 or 9)
 local x,z=g.cx*16+8,g.cy*16+8
 -- Octagonal rings close all sides, including undersides. A square body with
 -- clipped corners follows the original cap, collar and splayed plinth.
 local shape={{-1,-.55},{-.55,-1},{.55,-1},{1,-.55},{1,.55},{.55,1},{-.55,1},{-1,.55}}
 local function ring(y0,r0,y1,r1,uv,lit)
  for i,a in ipairs(shape)do local b=shape[i%8+1]
   local shade=.82+.16*(i/8)
   emit({{x+a[1]*r1,y1,z+a[2]*r1},{x+b[1]*r1,y1,z+b[2]*r1},
    {x+b[1]*r0,y0,z+b[2]*r0},{x+a[1]*r0,y0,z+a[2]*r0}},uv,shade+(lit and 64 or 0))
  end
 end
 -- One continuous profile seals the object without coplanar internal caps.
 local profile={{0,3,dark},{1.3,3,dark},{3.5,1.7,metal},{3.5,1.45,metal},
  {18.6,1.45,metal},{18.6,2.3,dark},{20,2.3,dark},{21,3.1,metal},
  {21,rs and 2 or 2.6,metal}}
 local head=rs and {{23,3.7,glass,true},{26,4,glass,true},{28.5,2.5,glass,true},{30.5,1,metal}}
  or {{26.5,3.3,glass,true},{26.5,3.9,dark},{27.5,3.9,dark},{30.5,1,metal}}
 for _,q in ipairs(head)do profile[#profile+1]=q end
 profile[#profile+1]={30.5,.65,dark};profile[#profile+1]={32,.15,dark}
 for i=2,#profile do local a,b=profile[i-1],profile[i];ring(a[1],a[2],b[1],b[2],b[3],b[4])end
 for i,a in ipairs(shape)do local b=shape[i%8+1]
  emit({{x,32,z},{x+a[1]*.15,32,z+a[2]*.15},{x+b[1]*.15,32,z+b[2]*.15},{x,32,z}},dark,1)
  emit({{x,0,z},{x+b[1]*3,0,z+b[2]*3},{x+a[1]*3,0,z+a[2]*3},{x,0,z}},dark,.7)
 end
 if rs then return end
 -- Thin ribs follow the widening glass corners instead of intersecting it.
 for _,q in ipairs(shape)do
  local low,high={},{}
  for _,d in ipairs({{-.15,-.15},{.15,-.15},{.15,.15},{-.15,.15}})do
   low[#low+1]={x+q[1]*2.64+d[1],21,z+q[2]*2.64+d[2]}
   high[#high+1]={x+q[1]*3.34+d[1],26.5,z+q[2]*3.34+d[2]}
  end
  for i=1,4 do local j=i%4+1;emit({high[i],high[j],low[j],low[i]},dark,.85)end
  emit(high,dark,1);emit({low[4],low[3],low[2],low[1]},dark,.7)
 end
end
-- One full-surround lamp per physical fixture, independent of pane directions.
function M.lights(g)
 return {{g.cx*16+8,(g.groundHeight or 0)+24,g.cy*16+8,42,0,0}}
end
return M
