-- Hoenn L checkout: the back-left two source cells are the clerk aisle.
local M={}
function M.append(p,source,box,sample,emit)
 local x,z=p.cx*16,p.cy*16
 local shell,glass=sample(7,29),sample(7,20)
 local function closed(a,n,c,f)
  box(x+a,0,z+n,x+c,7,z+f,shell)
  emit({{x+a,0,z+f},{x+c,0,z+f},{x+c,0,z+n},{x+a,0,z+n}},shell,.65)
 end
 closed(0,17,48,31);closed(33,0,48,17)
 source(0,16,48,8,{x,7.03,z+17},{x+48,7.03,z+17},{x+48,7.03,z+27},{x,7.03,z+27})
 source(0,24,48,8,{x,7,z+31.02},{x+48,7,z+31.02},{x+48,0,z+31.02},{x,0,z+31.02})
 source(32,0,16,16,{x+33,7.03,z},{x+48,7.03,z},{x+48,7.03,z+17},{x+33,7.03,z+17})
 -- Closed rear glazing/panel strips keep the service side finished.
 box(x+.5,6.8,z+17,x+32.5,7.6,z+18,glass)
 box(x+33,6.8,z+.5,x+34,7.6,z+17,glass)
end
return M
