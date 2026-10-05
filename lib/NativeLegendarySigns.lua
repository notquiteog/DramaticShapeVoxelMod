-- Gen1's low, chamfered wayfinder silhouette with the native sign face.
-- Original art stays the default; the optional frame stays inside its cell.
local V=...
local M={}
function M.draw(c,emit,uv)
 if not V.require('CommunityVisuals').customSigns()then return false end
 local x,z=c.cx*16+8,c.cy*16+12
 local function tex(px,py)
  local u=uv[1][1]+(uv[2][1]-uv[1][1])*px/16
  local v=uv[1][2]+(uv[3][2]-uv[1][2])*py/16
  return {{u,v},{u,v},{u,v},{u,v}}
 end
 local trim=tex(3,3)
 local G=V.require('CityMesh').new({trim[1][1],trim[1][2]})
 G.box(-1.2,0,-2.25,1.2,6,-.95,nil,1)
 G.box(-1.7,0,-2.5,1.7,.75,-.7,nil,.92)
 G.box(-7.25,12.76,-2.8,7.25,13.4,-.2,nil,1)
 local rim={{-6,5.15},{6,5.15},{6.75,5.9},{6.75,12.1},{6,12.85},{-6,12.85},{-6.75,12.1},{-6.75,5.9}}
 for i,a in ipairs(rim)do
  local b= rim[i%8+1]
  G.face({a[1],a[2],-2.55},{b[1],b[2],-2.55},{b[1],b[2],-1},{a[1],a[2],-1},nil,.85)
  for _,face in ipairs{{-2.55,false},{-1,true}}do
   local p,q={a[1],a[2],face[1]},{b[1],b[2],face[1]}
   if face[2]then p,q=q,p end
   G.face({0,9,face[1]},p,q,q,nil,1)
  end
 end
 for _,q in ipairs(G.out)do
  local p={};for _,v in ipairs(q)do p[#p+1]={x+v[1],v[2],z+v[3]}end
  local shade=q.shade or 1
  if type(shade)=='table'then shade=(shade[1]+shade[2]+shade[3]+shade[4])/4 end
  emit(p,trim,shade)
 end
 local function t(px,py)return {uv[1][1]+(uv[2][1]-uv[1][1])*px/16,uv[1][2]+(uv[3][2]-uv[1][2])*py/16}end
 emit({{x-5.85,11.95,z-.96},{x+5.85,11.95,z-.96},{x+5.85,6.15,z-.96},{x-5.85,6.15,z-.96}},
  {t(1,2),t(15,2),t(15,12),t(1,12)},1)
 return true
end
return M
