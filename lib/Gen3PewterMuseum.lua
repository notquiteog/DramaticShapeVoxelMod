-- Pewter Museum: native main hall, lower east wing and projecting entrance.
local M={}
function M.doorSurface(g,tx,ty)
 local dx,dy=tx-g.cx,ty-g.cy
 local a,b,top,bottom,front
 if dx==5 and dy==6 then a,b,top,bottom,front=80,96,96,112,110.05
 elseif dx==13 and dy==4 then a,b,top,bottom,front=208,224,64,80,78.05 else return end
 local x,z=g.cx*16,g.cy*16
 return {w=16,h=16,sourceX=x+a,sourceY=z+top,base=g.groundHeight or 0,
  vertices={{x+a,24,z+front},{x+b,24,z+front},{x+b,0,z+front},{x+a,0,z+front}}}
end
function M.append(g,p,emit)
 local x,z=g.cx*16,g.cy*16
 local function uv(a,b,c,d)return {{a/516,b/112},{c/516,b/112},{c/516,d/112},{a/516,d/112}}end
 local function sw(a,b)return uv(a+.5,b+.5,a+.5,b+.5)end
 local wall,stone,roof,dark=sw(10,74),sw(5,66),sw(30,35),sw(10,30)
 local function face(v,t,s)local out={};for i,q in ipairs(v)do out[i]={x+q[1],q[2],z+q[3]}end;emit(out,t,s or 1)end
 local function box(a,b,n,c,h,f,t)
  face({{a,h,f},{c,h,f},{c,b,f},{a,b,f}},t)
  face({{c,h,n},{a,h,n},{a,b,n},{c,b,n}},t,.8)
  face({{a,h,n},{a,h,f},{a,b,f},{a,b,n}},t,.82)
  face({{c,h,f},{c,h,n},{c,b,n},{c,b,f}},t,.9)
  face({{a,h,n},{c,h,n},{c,h,f},{a,h,f}},t)
  face({{a,b,f},{c,b,f},{c,b,n},{a,b,n}},t,.65)
 end
 local function front(a,b,low,high,depth,sx,sy,ex,ey)
  face({{a,high,depth},{b,high,depth},{b,low,depth},{a,low,depth}},uv(sx+.03,sy+.03,ex-.03,ey-.03))
 end
 box(2,0,10,174,40,95,wall)
 front(2,174,0,40,95.03,2,64,174,96)
 -- Lower wing starts south of the native walkable roof projection.
 box(176,0,34,208,24,79,wall);box(224,0,34,254,24,79,wall)
 box(208,24,34,224,25,79,stone);box(208,0,34,224,24,35,wall)
 front(176,208,0,24,79.03,176,64,208,80)
 front(224,254,0,24,79.03,224,64,254,80)
 front(208,224,0,24,78.05,208,64,224,80)
 for _,xx in ipairs({208,224})do box(xx-.2,0,78,xx+.2,24,79,stone)end
 -- Closed pitched roofs; source coordinates retain the original stripe rows.
 local function band(v)
  face(v,stone)
  local bottom={};for i,q in ipairs(v)do bottom[i]={q[1],q[2]-1,q[3]}end
  face({bottom[4],bottom[3],bottom[2],bottom[1]},stone,.65)
  for i,a in ipairs(v)do local j=i%4+1;face({a,v[j],bottom[j],bottom[i]},stone,.85)end
 end
 local function pitched(a,b,back,frontZ,eave,ridge,sx,sy,ex,ey)
  local mid=(back+frontZ)/2
  face({{a,eave,back},{b,eave,back},{b,ridge,mid},{a,ridge,mid}},uv(sx,sy,ex,(sy+ey)/2))
  face({{a,ridge,mid},{b,ridge,mid},{b,eave,frontZ},{a,eave,frontZ}},uv(sx,(sy+ey)/2,ex,ey))
  face({{a,eave,frontZ},{a,ridge,mid},{a,eave,back},{a,eave,back}},roof,.8)
  face({{b,eave,back},{b,ridge,mid},{b,eave,frontZ},{b,eave,frontZ}},roof,.9)
  face({{a,eave,frontZ},{b,eave,frontZ},{b,eave,back},{a,eave,back}},stone,.65)
  box(a,eave-2,frontZ-1,b,eave,frontZ,stone)
  box(a,eave-2,back,b,eave,back+1,stone)
  box(a,ridge-.2,mid-.8,b,ridge+1,mid+.8,stone)
  for _,xx in ipairs({a,b-2})do
   band({{xx,eave+1,back},{xx+2,eave+1,back},{xx+2,ridge+1,mid},{xx,ridge+1,mid}})
   band({{xx,ridge+1,mid},{xx+2,ridge+1,mid},{xx+2,eave+1,frontZ},{xx,eave+1,frontZ}})
  end
 end
 pitched(0,176,8,96,40,64,0,8,176,64)
 pitched(176,256,32,80,24,42,176,16,256,64)
 -- Projecting entrance piers, glass fossil panel and clear recessed portal.
 box(64,0,92,80,56,111,wall);box(96,0,92,112,56,111,wall)
 box(80,24,92,96,56,111,wall)
 front(64,80,0,56,111.03,64,64,80,112)
 front(96,112,0,56,111.03,96,64,112,112)
 front(80,96,24,56,111.03,80,64,96,96)
 front(80,96,0,24,110.05,80,96,96,112)
 box(64,56,92,112,58,111,stone)
 box(80,24,110,96,25,111,stone)
 for _,xx in ipairs({80,96})do box(xx-.25,0,110,xx+.25,24,111,stone)end
 -- Repeat the native window and pier vocabulary on real side/rear walls.
 local function window(a,b,c,d,high)
  face({{a,high,b},{c,high,d},{c,high-18,d},{a,high-18,b}},uv(16,68,24,92),.88)
 end
 for zz=20,72,20 do window(1.97,zz,1.97,zz+8,30)end
 for _,zz in ipairs({20,84})do window(174.03,zz+8,174.03,zz,30)end
 for _,xx in ipairs({8,24,40,56,120,136,152,168})do
  box(xx,0,94.8,xx+1.2,40,95.6,wall)
  box(xx-.5,38,94.7,xx+1.7,40,95.7,stone)
 end
 for xx=12,156,24 do window(xx+8,9.97,xx,9.97,30)end
 for zz=44,64,20 do window(254.03,zz+8,254.03,zz,21)end
 for xx=184,240,24 do window(xx+8,33.97,xx,33.97,21)end
 for xx=8,168,16 do box(xx,0,9.7,xx+2,40,10.1,stone)end
 for zz=16,84,16 do box(1.7,0,zz,2.1,40,zz+2,stone)end
end
return M
