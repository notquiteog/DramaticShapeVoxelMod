-- Native three-cell cave arches. Their centre is a true aperture, not rock
-- painted over the warp approach. Closed union faces have one surface owner.
local V=...
local Union=V and V.require('Gen3BoxUnion')or dofile((os.getenv('DS_MOD_PATH')or'.')..'/lib/Gen3BoxUnion.lua')
local M={}
M.recipes={{name='hoenn_navel_exit_arch',pair='general__navel_rock',primary='general',family='rse',caveInterior=true,
 rows={{0x258,0x259,0x25A}},blockedRows={[1]=true},kind='cavePortal',ground=0x201},
 {name='hoenn_seafloor_north_arch',pair='general__pacifidlog',primary='general',family='rse',caveInterior=true,
 rows={{0x290,0x291,0x292}},collisionRows={{7,114,7}},kind='cavePortal',ground=0x279,portalSide=0x281,portalCap=0x279,passThroughNorth=true},
 {name='hoenn_seafloor_south_arch',pair='general__pacifidlog',primary='general',family='rse',caveInterior=true,
 rows={{0x298,0x299,0x29A}},blockedRows={[1]=true},kind='cavePortal',ground=0x279,portalSide=0x281,portalCap=0x279},
 {name='hoenn_seafloor_south_arch_rs',pair='general__pacifidlog',primary='general',family='rse',caveInterior=true,
 rows={{0x298,0x299,0x271}},blockedRows={[1]=true},kind='cavePortal',ground=0x279,portalSide=0x281,portalCap=0x279}}
function M.prepare(cells)
 for _,c in pairs(cells)do local p=c.prop
  if p and p.recipe.passThroughNorth and c.cx==p.cx+1 and c.cy==p.cy then
   local back=cells[c.cx..':'..(c.cy-1)]
   if back and back.pair==p.pair and back.mid==0x289 and back.collision==7 and not(back.prop or back.stairs or back.civic)then
    -- The native header is directly behind the warp cell. Clear its centre
    -- from the rock mass and extend only the lintel through that blocked cell.
    back.shape={kind='flat'};back.prop=p;p.tunnelBack=16
    if p.cy==1 then p.boundaryPlane=0 end
   end
  end
  if p and(p.recipe.name=='hoenn_seafloor_south_arch'or p.recipe.name=='hoenn_seafloor_south_arch_rs')
   and not cells[(p.cx+1)..':'..(p.cy+1)]then p.boundaryPlane=(p.cy+1)*16 end
 end
end
function M.boundaryPassages(def)
 local out={};local d=def.midLayout
 if not d or d.pair~='general__pacifidlog'then return out end
 local function cell(x,y,mid,coll)local c=d:cellAt(x,y);return c and c.mid==mid and c.coll==coll end
 for _,w in ipairs(def.warps or{})do local x,y=w.x,w.y
  if y==1 and cell(x-1,y,0x290,7)and cell(x,y,0x291,114)and cell(x+1,y,0x292,7)and cell(x,0,0x289,7)then
   out[#out+1]={side=1,x*16,(x+1)*16,0,24}
  elseif y==def.height-2 and cell(x-1,y+1,0x298,7)and cell(x,y+1,0x299,7)
   and(cell(x+1,y+1,0x29A,7)or cell(x+1,y+1,0x271,7))and(cell(x,y,0x295,114)or cell(x,y,0x296,114))then
   out[#out+1]={side=3,x*16,(x+1)*16,0,24}
  end
 end
 return out
end
function M.append(p,emit,uvFor)
 local x,z=p.cx*16,p.cy*16;local uv=assert(uvFor(p.ts,p.recipe and p.recipe.portalSide or 0x219));local cap=assert(uvFor(p.ts,p.recipe and p.recipe.portalCap or 0x211))
 local boxes={
  {lo={x,-.025,z},hi={x+16,28,z+16},uv=uv},
  {lo={x+16,24,z},hi={x+32,28,z+16},uv=uv},
  {lo={x+32,-.025,z},hi={x+48,28,z+16},uv=uv}}
 if p.tunnelBack then boxes[#boxes+1]={lo={x+16,24,z-p.tunnelBack},hi={x+32,28,z},uv=uv}end
 Union.append(boxes,function(q,t,shade)
  if p.boundaryPlane then local contact=true;for _,v in ipairs(q)do if math.abs(v[3]-p.boundaryPlane)>1e-7 then contact=false;break end end
   if contact then return end -- the joined outer rock shell owns this face
  end
  if q[1][2]==28 and q[2][2]==28 and q[3][2]==28 and q[4][2]==28 then t=cap end
  emit(q,t,shade)
 end)
end
return M
