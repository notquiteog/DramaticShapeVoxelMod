-- One native three-cell exit arch. Its centre is a true aperture, not rock
-- painted over the warp approach. Closed union faces have one surface owner.
local V=...
local Union=V and V.require('Gen3BoxUnion')or dofile((os.getenv('DS_MOD_PATH')or'.')..'/lib/Gen3BoxUnion.lua')
local M={}
M.recipes={{name='hoenn_navel_exit_arch',pair='general__navel_rock',primary='general',family='rse',caveInterior=true,
 rows={{0x258,0x259,0x25A}},blockedRows={[1]=true},kind='cavePortal',ground=0x201}}
function M.append(p,emit,uvFor)
 local x,z=p.cx*16,p.cy*16;local uv=assert(uvFor(p.ts,0x219));local cap=assert(uvFor(p.ts,0x211))
 local boxes={
  {lo={x,-.025,z},hi={x+16,28,z+16},uv=uv},
  {lo={x+16,24,z},hi={x+32,28,z+16},uv=uv},
  {lo={x+32,-.025,z},hi={x+48,28,z+16},uv=uv}}
 Union.append(boxes,function(q,t,shade)
  if q[1][2]==28 and q[2][2]==28 and q[3][2]==28 and q[4][2]==28 then t=cap end
  emit(q,t,shade)
 end)
end
return M
