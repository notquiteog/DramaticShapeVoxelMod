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
  local layers={{0,.60,-2,12,13,0},{-5,.53,1,9,10,-.24},
    {5,.56,2,9,10,.24},{0,.81,0,8,9,0},
    {0,.61,-3,10,12,.12}}
  if family=='conifer' then
    layers={{0,.58,2,11,17,0},{-1,.59,-2,10,16,-.22}}
  end
  if shrub then
    h,spread=8*(.94+phase*.12),1
    layers={{0,.51,2,7.3,4,0},{0,.52,-1.5,6.8,4,-.22},
      {-.5,.55,0,6.3,3.8,.25}}
  end
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
        cz+uz*dx+math.cos(a)*bow-hh*dy*.42,u,vv,.96}
    end
    for _,i in ipairs({1,2,3,1,3,4}) do indices[#indices+1]=k+i end
    q=q+1
    end
  end
  return q
end
return M
