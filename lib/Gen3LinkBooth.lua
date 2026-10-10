-- RS privacy booths: full-height partition, separate desk and clear warp lane.
local M={}
function M.append(p,source,box,sample,emit)
 local openBox=box
 box=function(a,b,n,c,h,f,t)
  openBox(a,b,n,c,h,f,t)
  emit({{a,b,f},{c,b,f},{c,b,n},{a,b,n}},t,.65)
 end
 local x,z=p.cx*16,p.cy*16;local wall=sample(5,18);local orange=sample(2,40);local trim=sample(3,72)
 -- Every low part stays on the partition's five blocked native cells.
 box(x+3,0,z+16,x+13,30,z+78,orange)
 box(x+4,1,z+17,x+12,28,z+77,wall)
 box(x+2,28,z+16,x+14,31,z+79,wall)
 box(x+3,0,z+72,x+13,3,z+78,trim)
 if p.recipe.kind=='rsLinkPartition' then return end
 local cream,edge=sample(21,39),sample(19,53)
 -- Desk front and side gate occupy only their blocked counter row. Behind
 -- them, both the clerk cell and the right-hand portal approach remain open.
 box(x+16,0,z+57,x+32,5,z+63,edge)
 box(x+16,5,z+56,x+32,7,z+63,cream)
 source(16,38,16,12,{x+16,7.03,z+56},{x+32,7.03,z+56},{x+32,7.03,z+63},{x+16,7.03,z+63})
 source(16,50,16,10,{x+16,5,z+63.02},{x+32,5,z+63.02},{x+32,0,z+63.02},{x+16,0,z+63.02})
 box(x+32,0,z+53,x+47,5,z+62,edge)
 box(x+32,5,z+53,x+47,7,z+62,cream)
 -- Native service symbol and doorway lintel stay above actor headroom.
 box(x+14,28,z+16,x+48,33,z+18,orange)
 box(x+16,0,z+16,x+32,28,z+18,orange)
 source(16,0,16,32,{x+16,33,z+18.03},{x+32,33,z+18.03},{x+32,1,z+18.03},{x+16,1,z+18.03})
 -- Portal art sits behind the native warp approach, never across its center.
 source(32,0,16,32,{x+32,33,z+18.03},{x+48,33,z+18.03},{x+48,1,z+18.03},{x+32,1,z+18.03})
end
return M
