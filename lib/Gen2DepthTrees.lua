-- Illustrated crown layers occupy real positions, receive/cast light and
-- occlude actors. No opaque voxel canopy remains in this presentation.
local M={}
function M.append(v,indices,q,x,y,z,lift,seed,family)
  local bush=lift<=4
  local shrub=lift==3
  local h=bush and 13 or (lift==20 and 42 or 34)
  local spread=bush and .46 or (lift==20 and 1.18 or 1)
  local phase=(math.sin(seed*12.9898)*43758.5453)%1
  h=h*(.92+phase*.14)
  -- Cut trees keep the sapling trunk and crown silhouette. Headbutt shrubs
  -- spread along the ground, with the foliage itself providing their depth.
  if bush and not shrub then family='broadleaf' end
  local col=(family=='conifer' or family=='shrub') and 1 or 0
  local row=(family=='spreading' or family=='shrub') and 1 or 0
  -- One connected crown: low lateral lobes nest into the central foliage.
  -- Do not perch a miniature complete tree above it; its tip reads as a tuft.
  local layers={{0,.56,-1,12,13,0},{-4,.51,1,9,10,-.24},
    {4,.53,2,9,10,.24}}
  if family=='conifer' then
    layers={{0,.58,2,11,17,0},{0,.48,-2,8,12,-.22}}
  end
  if shrub then
    h,spread=8*(.94+phase*.12),1
    layers={{0,.51,2,7.3,4,0},{0,.52,-1.5,6.8,4,-.22},
      {-.5,.55,0,6.3,3.8,.25}}
  end
  -- Each illustrated lobe turns around its own centre. The enclosing cheeks
  -- and cap below are untagged and remain fixed, so the tree never swivels.
  for _,l in ipairs(layers) do
    local cx,cy,cz=x+l[1]*spread,y+h*l[2],z+l[3]*spread
    local w,hh=l[4]*spread,l[5]*((bush and not shrub) and .42 or 1)
    local a=l[6]+(phase-.5)*.16
    local ux,uz=math.cos(a)*w,math.sin(a)*w
    -- Bow each illustrated layer around a shallow crown. This adds real
    -- depth without the perpendicular sheets that read as spiky crosses.
    for strip=0,3 do
    local k=#v
    local left,right=-1+strip*.5,-.5+strip*.5
    for _,p in ipairs({{left,-1},{right,-1},{right,1},{left,1}}) do
      -- Slight rearward lean exposes the illustrated top at a high camera.
      local dx,dy=p[1],p[2]
      local u=(col+.01+(dx+1)*.49)*.5
      local vv=(row+.01+(1-dy)*.49)*.5
      if shrub then vv=.686+(1-dy)*.13 end
      local bow=(1-dx*dx)*w*.30
      v[#v+1]={cx+ux*dx-math.sin(a)*bow,cy+hh*dy,
        cz+uz*dx+math.cos(a)*bow-hh*dy*.42,u,vv,.96,cx,cz,1}
    end
    for _,i in ipairs({1,2,3,1,3,4}) do indices[#indices+1]=k+i end
    q=q+1
    end
  end
  -- Curved leaf cheeks fill the east/west silhouette during free camera
  -- rotation. These sit on the crown boundary, rather than crossing through
  -- its centre. Crop out the illustrated trunk so side views keep one trunk.
  local sideW=shrub and 5.8 or (bush and 4.0 or 10*spread)
  local sideD=shrub and 3.2 or (bush and 3.0 or 7.5*spread)
  local low=shrub and 1 or h*.36
  local high=shrub and 7.4 or h*.84
  for _,side in ipairs({-1,1}) do for strip=0,3 do
    local k=#v
    local left,right=-1+strip*.5,-.5+strip*.5
    for _,p in ipairs({{left,0},{right,0},{right,1},{left,1}}) do
      local d,t=p[1],p[2]
      local bow=math.sqrt(math.max(0,1-d*d))
      local radius=sideW*(.55+.45*bow)*(t==1 and .70 or 1)
      local u=(col+.02+(d+1)*.48)*.5
      local vv=(row+.02+(1-t)*.64)*.5
      if shrub then vv=.686+(1-t)*.26 end
      v[#v+1]={x+side*radius,y+low+(high-low)*t,z+d*sideD,u,vv,.93,0,0,0}
    end
    for _,i in ipairs({1,2,3,1,3,4}) do indices[#indices+1]=k+i end
    q=q+1
  end end
  -- A rounded crown joins the shoulder to the apex. The old near-flat
  -- rectangular cap made a razor-like horizontal lip in ground-level views.
  -- Two eight-sided rings keep the same total budget as the old tuft layers.
  local capY=shrub and 4.0 or h*.60
  local rise=shrub and 2.6 or h*.19
  local capW=shrub and 6.5 or (bush and 4.2 or 9*spread)
  local capD=shrub and 3.4 or (bush and 2.8 or 6*spread)
  for ring=1,2 do for sector=0,7 do
    local k=#v
    local outer=ring==1 and 1 or .55
    local inner=ring==1 and .55 or 0
    local a,b=sector*math.pi/4,(sector+1)*math.pi/4
    for _,p in ipairs({{a,outer},{b,outer},{b,inner},{a,inner}}) do
      local dx,dz=math.cos(p[1])*p[2],math.sin(p[1])*p[2]
      local dome=math.sqrt(math.max(0,1-p[2]*p[2]))
      -- Sample the dense interior foliage, not the complete tree silhouette.
      -- The cap nests below the billboards instead of wearing a second tree.
      local u=(col+.20+(dx+1)*.30)*.5
      local vv=(row+.24+(dz+1)*.18)*.5
      if shrub then vv=.686+(dz+1)*.13 end
      v[#v+1]={x+dx*capW,y+capY+dome*rise,z+dz*capD,u,vv,
        .94+.06*dome,0,0,0}
    end
    for _,i in ipairs({1,2,3,1,3,4}) do indices[#indices+1]=k+i end
    q=q+1
  end end
  return q
end
return M
