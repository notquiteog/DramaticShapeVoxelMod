-- Authored four-pixel weatherboard courses: face, sloped lip and underside.
-- Source palette swatches colour actual relief; no facade doors/windows are
-- stretched around the unseen sides. The closed wall shell remains behind it.
local M={}
function M.side(x,z0,z1,h0,h1,sign,uv,emit)
 local function at(z)return h0+(h1-h0)*(z-z0)/(z1-z0)end
 for y=0,math.max(h0,h1)-.01,4 do
  local a,b=z0,z1
  if h0<y then a=z0+(z1-z0)*(y-h0)/(h1-h0)end
  if h1<y then b=z0+(z1-z0)*(y-h0)/(h1-h0)end
  if b>a then
   local ta,tb=math.min(y+3.9,at(a)),math.min(y+3.9,at(b));local outer=x+sign*.24
   local fa,fb=math.max(y,ta-.25),math.max(y,tb-.25)
   emit({{outer,fa,a},{outer,fb,b},{outer,y,b},{outer,y,a}},uv,.86)
   emit({{x,ta,a},{x,tb,b},{outer,fb,b},{outer,fa,a}},uv,1)
   emit({{outer,y,a},{outer,y,b},{x,y,b},{x,y,a}},uv,.66)
  end
 end
end
function M.back(x0,x1,z,height,uv,emit)
 -- The same plank recipe rotated a quarter turn, preserving course heights.
 M.side(-z,x0,x1,height,height,1,uv,function(p,t,s)
  local q={};for i,v in ipairs(p)do q[i]={v[3],v[2],-v[1]}end;emit(q,t,s)
 end)
end
return M
