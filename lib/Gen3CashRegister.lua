-- A closed west-facing till: the clerk stands left of the native L counter.
-- Cash drawer, sloping key bed, upright display and rear case are separate solids.
local M={}
function M.append(p,source,openBox,sample,emit)
 local x,z=p.cx*16,p.cy*16
 local function B(l,b,n,r,h,f,mat)
  openBox(x+l,b,z+n,x+r,h,z+f,mat)
  emit({{x+l,b,z+f},{x+r,b,z+f},{x+r,b,z+n},{x+l,b,z+n}},mat,.65)
 end
 local light,dark,edge=sample(11,18),sample(5,21),sample(2,28)
 B(.5,0,17,15.5,6.5,31.5,edge);B(.2,6.5,17,15.8,7.5,31.8,light)
 B(2,7.5,18,14,9.5,30,light)
 -- Clerk-facing drawer and its narrow handle, closed around the underside.
 B(1.7,7.8,19,2,9.2,29,dark);B(1.4,8.35,22,1.7,8.8,26,light)
 B(10,9.5,18,14,17,30,light)
 B(9.7,12,20,10,16,28,dark)
 source(3,10,8,8,{x+9.68,16,z+28},{x+9.68,16,z+20},{x+9.68,12,z+20},{x+9.68,12,z+28})
 -- The key bed slopes down toward the clerk, rather than wrapping the whole
 -- sprite over a block. End plates and underside close the wedge completely.
 local a,b,n,f=3,10,19,29
 emit({{x+a,9.5,z+f},{x+b,9.5,z+f},{x+b,13,z+f},{x+a,10,z+f}},light,.85)
 emit({{x+b,9.5,z+n},{x+a,9.5,z+n},{x+a,10,z+n},{x+b,13,z+n}},light,.8)
 emit({{x+a,9.5,z+n},{x+a,9.5,z+f},{x+a,10,z+f},{x+a,10,z+n}},light,.8)
 emit({{x+b,9.5,z+f},{x+b,9.5,z+n},{x+b,13,z+n},{x+b,13,z+f}},light,.8)
 emit({{x+a,9.5,z+f},{x+b,9.5,z+f},{x+b,9.5,z+n},{x+a,9.5,z+n}},dark,.65)
 source(2,15,10,10,{x+a,10.02,z+f},{x+b,13.02,z+f},{x+b,13.02,z+n},{x+a,10.02,z+n})
 -- Individually raised native-colored keys retain depth at eye level.
 for row=0,2 do for col=0,2 do
  local u=3.8+row*1.8;local q=20+col*2.8;local h=10+(u-3)*3/7
  B(u,h,q,u+1.15,h+.3,q+1.8,sample(3+col*2,17+row*2))
 end end
end
return M
