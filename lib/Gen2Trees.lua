-- Compact broadleaf trees for dense Crystal borders. Uses the existing
-- CommunityFlora bark/leaf materials, batching, shadows and cache ownership.
local Trees = {}
function Trees.family(seed,lift)
  if lift<=4 then return "shrub" end
  return ({"broadleaf","conifer","spreading"})[seed%3+1]
end
function Trees.append(tv,ti,tq,cv,ci,cq,x,y,z,lift,seed,dv,di,dq)
  local function quad(verts,indices,n,a,b,c,d,shade)
    local k=#verts
    for j,p in ipairs({a,b,c,d}) do
      local uv=({{0,1},{1,1},{1,0},{0,0}})[j]
      verts[#verts+1]={p[1],p[2],p[3],uv[1],uv[2],shade}
    end
    for _,v in ipairs({1,2,3,1,3,4}) do indices[#indices+1]=k+v end
    return n+1
  end
  local bush=lift<=4
  local family=Trees.family(seed,lift)
  dq=dq or 0
  local height=bush and 13 or (lift==20 and 40 or (lift>=17 and 33 or 28))
  local angle=(seed%97)/97*math.pi*2
  local leanX,leanZ=math.cos(angle)*.8,math.sin(angle)*.8
  local function ring(radius,h,lean)
    local r={}
    for i=0,5 do
      local a=i*math.pi/3+angle
      r[i+1]={x+math.cos(a)*radius+leanX*lean,y+h,z+math.sin(a)*radius+leanZ*lean}
    end
    return r
  end
  local rings={ring(2.4,0,0),ring(1.35,3,.15),ring(.95,height*.52,1),ring(.32,height*.77,1.5)}
  for j=1,3 do for i=1,6 do
    local n=i%6+1
    tq=quad(tv,ti,tq,rings[j][i],rings[j][n],rings[j+1][n],rings[j+1][i],.78+.17*math.cos(i*math.pi/3))
  end end
  -- Overlapping, tapered six-sided leaf lobes have real top and underside
  -- surfaces. Unlike flat crossed sheets they stay full from a flying camera.
  local lobes={{0,.76,0,7.3,7.5},{-4.5,.61,-1,5.4,5.7},
    {4.1,.64,1.3,5.5,5.8},{.3,.63,-4.6,5.6,5.6},
    {-1,.60,4.2,5.7,5.8},{-1.1,.90,-.5,5,3.3}}
  if family=="conifer" then
    lobes={{0,.42,0,8.8,5.2},{.1,.58,0,7.1,5.4},
      {-.3,.73,.2,5.4,4.9},{0,.87,0,3.6,4.6}}
  elseif family=="spreading" then
    lobes={{0,.65,0,8.2,6.3},{-5.8,.56,-.8,6.2,5.2},
      {5.6,.60,1.6,6,5.5},{.7,.59,-5.2,6.7,5.4},
      {-1.8,.53,4.8,6.4,5.4},{-1.2,.82,-.5,6.2,4.3}}
  end
  for l,b in ipairs(lobes) do
    local shrink=bush and .65 or (lift==20 and 1.4 or 1)
    local cx,cy,cz=x+b[1]*shrink+leanX,y+height*b[2],z+b[3]*shrink+leanZ
    local rx,ry=b[4]*shrink,b[5]*(bush and .47 or 1)
    local rs={}
    for j=0,3 do
      local radii=family=="conifer" and {.52,1,.56,.02} or {.32,1,.87,.12}
      local ys={-.83,-.20,.42,1}
      rs[j+1]={}
      for i=0,5 do
        local a=i*math.pi/3+angle+l*.43
        local r=rx*radii[j+1]*(.93+.07*math.sin(i*9+l*3+seed))
        rs[j+1][i+1]={cx+math.cos(a)*r,cy+ry*ys[j+1],cz+math.sin(a)*r*.91}
      end
    end
    for j=1,3 do for i=1,6 do
      local n=i%6+1
      cq=quad(cv,ci,cq,rs[j][i],rs[j][n],rs[j+1][n],rs[j+1][i],
        (.66+j*.095)*(.93+.07*math.cos(i*math.pi/3+angle)))
    end end
    -- Fine leaf sprays overlap the lobe shoulders. Each three-plane bunch
    -- uses the existing alpha-cutout leaf artwork, so the silhouette is
    -- foliage rather than the edges of the underlying low-poly hull.
    if dv and di then
      for j=1,8 do
        local a=j*math.pi/4+angle+l*.31
        local ly=cy+ry*(j%2==0 and .33 or -.03)
        local lx,lz=cx+math.cos(a)*rx*.86,cz+math.sin(a)*rx*.79
        local size=(bush and 1.9 or 3.0)*(family=="conifer" and .9 or 1)
        for plane=0,2 do
          local pa=a+plane*math.pi/3
          local ux,uz=math.cos(pa)*size,math.sin(pa)*size
          local vx,vy,vz=-math.sin(pa)*size*.32,size*.9,math.cos(pa)*size*.32
          dq=quad(dv,di,dq,{lx-ux-vx,ly-vy,lz-uz-vz},{lx+ux-vx,ly-vy,lz+uz-vz},
            {lx+ux+vx,ly+vy,lz+uz+vz},{lx-ux+vx,ly+vy,lz-uz+vz},.96)
        end
      end
    end
    for i=2,5 do
      cq=quad(cv,ci,cq,rs[4][1],rs[4][i],rs[4][i+1],rs[4][1],.98)
      cq=quad(cv,ci,cq,rs[1][1],rs[1][i+1],rs[1][i],rs[1][1],.62)
    end
  end
  return tq,cq,dq
end
return Trees
