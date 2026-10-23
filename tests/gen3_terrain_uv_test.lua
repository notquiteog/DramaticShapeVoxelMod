-- Independent per-vertex source formula: optimized shared scalar UVs must
-- retain exact coordinate arithmetic, emitted ownership, order and shading.
local T=dofile('lib/Gen3Terrain.lua')
local cap={{.123456,.234567},{.17349,.234567},{.17349,.298765},{.123456,.298765}}
local side={{.318765,.412345},{.398765,.412345},{.398765,.543219},{.318765,.543219}}
local count=0
for case=1,300 do
 local c={cx=case%19-9,cy=case%13-6,shape={height=8+case%5*8,cap=1,side=2}}
 local x,z=c.cx*16,c.cy*16
 local function height(_,wx,wz)
  local ix,iz=(wx-x)/4,(wz-z)/4
  if ix<=1 and iz<=1 then return case%2==0 and 0 or 12 end
  return ((ix*7+iz*11+case*13)%39-3)*.7
 end
 local out={}
 T.append({},c,function(v,uv,shade)out[#out+1]={v,uv,shade}end,
  function(_,tile)return tile==1 and cap or side end,height)
 assert(#out==16,'nonflat topology changed')
 local owned={}
 for iz=0,3 do for ix=0,3 do
  local q=out[iz*4+ix+1]
  local coords={{ix*4,iz*4},{ix*4+4,iz*4},{ix*4+4,iz*4+4},{ix*4,iz*4+4}}
  local h={}
  for i,p in ipairs(coords)do h[i]=height(nil,x+p[1],z+p[2])end
  local flat=h[1]==h[2]and h[2]==h[3]and h[3]==h[4]and h[1]~=0
  local alongZ=math.abs(h[1]-h[2])+math.abs(h[4]-h[3])>math.abs(h[1]-h[4])+math.abs(h[2]-h[3])
  assert(q[3]==(flat and 1 or .84))
  for i,p in ipairs(coords)do
   local u,v
   if flat then
    u=cap[1][1]+(cap[2][1]-cap[1][1])*p[1]/16
    v=cap[1][2]+(cap[3][2]-cap[1][2])*p[2]/16
   else
    u=side[1][1]+((alongZ and p[2]or p[1])/16)*(side[2][1]-side[1][1])
    v=side[1][2]+(1-math.max(0,math.min(1,h[i]/c.shape.height)))*(side[3][2]-side[1][2])
   end
   assert(q[1][i][1]==x+p[1]and q[1][i][2]==h[i]and q[1][i][3]==z+p[2])
   assert(q[2][i][1]==u and q[2][i][2]==v,'source UV arithmetic changed')
   assert(not owned[q[1][i]]and not owned[q[2][i]],'emitted rows unexpectedly aliased')
   owned[q[1][i]],owned[q[2][i]]=true,true
   count=count+1
  end
 end end
end
print('PASS '..count..' exact emitted vertices/UVs, fresh table ownership, both side tangents, flat/zero cells, clamped heights and negative coordinates')
