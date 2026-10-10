-- Authored solid tree families matching the native GB/GBA drawings. Coordinates
-- are normalized by drawing width and visible height; collision is untouched.
local M={}
local function oval(x,y,z,cx,cy,cz,rx,ry,rz)
 return ((x-cx)/rx)^2+((y-cy)/ry)^2+((z-cz)/rz)^2<=1
end
local skirts={{.13,.49},{.22,.5},{.34,.39},{.43,.43},{.54,.30},{.62,.34},{.74,.21},{.8,.23},{.98,0}}
local function radius(y)
 for i=2,#skirts do
  local a,b=skirts[i-1],skirts[i]
  if y>=a[1] and y<=b[1]then
   local t=(y-a[1])/(b[1]-a[1]);return a[2]+(b[2]-a[2])*t
  end
 end
end
function M.part(family,x,y,z)
 local radial=x*x+z*z
 if family=='conifer' then
  -- A pointed leader and tiered skirts, with needles low around the stem.
  local r=radius(y)
  if r and radial<=r*r then return 'foliage' end
  if y>=0 and y<.45 and radial<(.065+.045*math.max(0,1-y/.13))^2 then return 'wood' end
 elseif family=='tiered' then
  -- Viridian's tall tree has a round top, broad upper crown, narrow waist
  -- and spreading lower branches. It is not the General conifer enlarged.
  if oval(x,y,z,0,.875,0,.25,.125,.25)
   or oval(x,y,z,0,.68,0,.44,.19,.44)
   or oval(x,y,z,-.25,.65,.03,.24,.14,.29)
   or oval(x,y,z,.25,.65,-.03,.24,.14,.29)
   or oval(x,y,z,0,.43,0,.31,.15,.31)
   or oval(x,y,z,0,.245,0,.49,.145,.49)then return 'foliage' end
  if y>=0 and y<.64 and radial<(.06+.055*math.max(0,1-y/.13))^2 then return 'wood' end
 elseif family=='broad' or family=='mossdeep' then
  -- Ilex/Park: one wide low crown over a visibly flared, branching trunk.
  if oval(x,y,z,-.18,.76,.02,.32,.23,.45)
   or oval(x,y,z,.18,.76,-.02,.32,.23,.45)
   or oval(x,y,z,0,.82,0,.40,.17,.49)then return 'foliage' end
  local r=.095+(family=='mossdeep' and .05 or .11)*math.max(0,1-y/.3)
  if y>=0 and y<.8 and radial<r*r then return 'wood' end
  if y>.28 and y<.74 then
   local branch=(y-.28)*.42
   if math.abs(math.abs(x)-branch)<.065 and math.abs(z)<.065
    or math.abs(math.abs(z)-branch)<.065 and math.abs(x)<.065 then return 'wood' end
  end
 elseif family=='round' then
  -- Crystal's Kanto border trees are compact rounded crowns, not pines.
  if oval(x,y,z,0,.51,0,.49,.47,.49)then return 'foliage' end
  if y>=0 and y<.35 and radial<.065^2 then return 'wood' end
 elseif family=='sapling' then
  if oval(x,y,z,0,.63,0,.34,.36,.34)
   or oval(x,y,z,-.24,.47,0,.23,.23,.29)
   or oval(x,y,z,.24,.47,0,.23,.23,.29)then return 'foliage' end
  if y>=0 and y<.62 and radial<(.065+.04*math.max(0,1-y/.13))^2 then return 'wood' end
 end
end
return M
