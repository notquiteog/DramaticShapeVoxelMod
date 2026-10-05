-- Capture-only filled plasma volume; deterministic world geometry for both eyes.
-- The authoritative projectile clock and gameplay state are never modified.
local P = {}
local PI = math.pi
local SLICES, SIDES = 32, 20
local COLS, ROWS = 12, 16
P.VERTEX_COUNT = (SLICES+1)*(SIDES+1)
P.TRIANGLE_COUNT = SLICES*SIDES*2
P.SUBJECT_VERTEX_COUNT = (COLS+1)*(ROWS+1)
local function clamp(x) return math.max(0,math.min(1,x or 0)) end
local function ease(x) x=clamp(x);return x*x*x*(x*(x*6-15)+10) end
local function norm(x,y,z)
  local l=math.sqrt(x*x+y*y+z*z)
  if l<1e-8 then return 0,1,0 end
  return x/l,y/l,z/l
end
-- Per-event styles remain small deviations of the same opaque filled volume.
local STYLES={{side=.045,lift=.025,wave=1.15,speed=.92},
  {side=-.040,lift=.018,wave=2.0,speed=1.05},
  {side=.025,lift=-.020,wave=1.45,speed=1.14}}
function P.pose(projectile,timer,source,mouth,width,height,yaw,variation)
  timer=tonumber(timer) or 0
  local start=tonumber(projectile.CAPTURE_INTAKE_START) or .77
  local absorb=tonumber(projectile.CAPTURE_ABSORB_SEC) or 1.32
  local hold=tonumber(projectile.CAPTURE_HOLD_SEC) or .15
  local finish=tonumber(projectile.CAPTURE_SUCK_SEC) or 2.325
  if timer<start or timer>=finish then return nil end
  local pull=ease((timer-absorb-hold)/math.max(.01,finish-absorb-hold))
  local p={timer=timer,source=source,mouth=mouth,yaw=yaw or 0,
    width=math.max(4,math.min(64,width or 16)),
    height=math.max(4,math.min(64,height or 16)),
    reach=ease((timer-start)/.20),
    convert=ease((timer-start-.13)/math.max(.01,absorb-start-.13)),
    pull=pull,fade=1-ease((pull-.97)/.03)}
  p.wrap=p.convert -- legacy button cue only; there are no wrapping strands.
  p.rx,p.rz=math.cos(p.yaw),-math.sin(p.yaw)
  p.fx,p.fz=math.sin(p.yaw),math.cos(p.yaw)
  p.variation=math.max(0,math.floor(tonumber(variation) or 0))
  if p.variation>0 then
    p.style=STYLES[(p.variation-1)%#STYLES+1]
    p.phase=(p.variation*.61803398875%1)*PI*2
    local dx,dy,dz=mouth[1]-source[1],mouth[2]-source[2],mouth[3]-source[3]
    local distance=math.sqrt(dx*dx+dy*dy+dz*dz)
    -- Near-touching balls need a compact bend, with no distance threshold pop.
    p.nearScale=ease(distance/math.max(p.width,p.height))
    p.distanceBlend=clamp(distance/math.max(p.width,p.height)/3)
    p.angleBlend=(dx*p.rx+dz*p.rz)/math.max(.001,distance)
    p.heightBlend=dy/math.max(.001,distance)
  end
  return p
end
-- The mass follows a single broad bend; all endpoints converge exactly.
function P.center(p,t)
  t=clamp(t)
  local bow=math.sin(PI*t)
  local side=math.sin(t*PI*1.4)*p.width*.12*bow
  local lift=p.height*.13*bow
  if p.style then
    local amount=.30+.70*p.distanceBlend
    side=side*(.65+.35*p.distanceBlend)
      +p.width*(p.style.side*math.sin(t*PI*p.style.wave)+p.angleBlend*.025)*bow*amount
    lift=lift*(.70+.30*p.distanceBlend)
      +p.height*(p.style.lift-p.heightBlend*.02)*bow*amount
    side,lift=side*p.nearScale,lift*p.nearScale
  end
  return p.source[1]+(p.mouth[1]-p.source[1])*t+p.rx*side,
    p.source[2]+(p.mouth[2]-p.source[2])*t+lift,
    p.source[3]+(p.mouth[3]-p.source[3])*t+p.rz*side
end
local function topology(cols,rows)
  local vertices,indices={},{}
  for i=1,(cols+1)*(rows+1) do vertices[i]={0,0,0,0,0,1} end
  for row=0,rows-1 do for col=0,cols-1 do
    local a=row*(cols+1)+col+1
    local b=a+1;local c=b+cols+1;local d=a+cols+1
    local k=#indices
    indices[k+1],indices[k+2],indices[k+3]=a,b,c
    indices[k+4],indices[k+5],indices[k+6]=a,c,d
  end end
  return vertices,indices
end
function P.newGeometry() return topology(SIDES,SLICES) end
-- Closed, filled breakout pulse. Broad traveling lobes, no orbiting strands.
-- Reuses the bounded volume topology; radius is controlled by failure timing.
function P.updateBurst(vertices,timer,core)
  local radius=.075*math.max(0,math.min(1,core or 0))
  for row=0,SLICES do
    local u=row/SLICES;local latitude=PI*u
    for side=0,SIDES do
      local v=side/SIDES;local a=v*2*PI
      local ring=math.sin(latitude)
      local lobe=1+ring*(.13*math.sin(a*3+latitude*4-timer*8)
        +.06*math.sin(a*5-latitude*3+timer*5))
      local r=radius*lobe
      local p=vertices[row*(SIDES+1)+side+1]
      p[1],p[2],p[3]=r*ring*math.cos(a),radius*(1+math.cos(latitude)),r*ring*math.sin(a)
      p[4],p[5],p[6]=v,u,1
    end
  end
  return #vertices
end
-- Closed rounded funnel: one contiguous surface, not overlapping ribbons.
-- Radius disturbances are large slow lobes, never independent orbiting lines.
function P.update(vertices,p)
  local cx,cy,cz=P.center(p,p.pull)
  local dx,dy,dz=cx-p.mouth[1],cy-p.mouth[2],cz-p.mouth[3]
  local tx,ty,tz=norm(dx,dy,dz)
  local nx,ny,nz=norm(-p.fz*ty,p.fz*tx-p.fx*tz,p.fx*ty)
  local bx,by,bz=norm(ty*nz-tz*ny,tz*nx-tx*nz,tx*ny-ty*nx)
  local shrink=(1-p.pull)^.72*p.fade
  local size=math.min(p.width,p.height)
  local flowing=math.sin(PI*p.pull)
  local tail=size*(.10+.50*flowing)*shrink*p.convert
  -- The converted silhouette supplies the body mass. The connector broadens
  -- during the drain, without placing a second round blob over its face.
  local breadth=size*(.055+.20*p.convert+.30*flowing)*shrink
  local reach=p.reach
  local clock=p.timer*(p.style and p.style.speed or 1)
  local phase=p.phase or 0
  local motion=p.style and (.65+.35*p.distanceBlend)*p.nearScale or 1
  for slice=0,SLICES do
    local u=slice/SLICES
    local s=u*reach
    -- The visible source sits inside the wide part, before the rounded tail.
    local longitudinal=s/.76
    local envelope=math.sin(PI*s)
    local bend=(math.sin(s*PI*1.65-clock*3.4+phase)*size*.070
      +math.sin(s*PI*3.8+clock*2.6-phase)*size*.025)*envelope*shrink*motion
    local x=p.mouth[1]+dx*math.min(1,longitudinal)+tx*tail*math.max(0,(s-.76)/.24)+nx*bend
    local y=p.mouth[2]+dy*math.min(1,longitudinal)+ty*tail*math.max(0,(s-.76)/.24)+ny*bend
    local z=p.mouth[3]+dz*math.min(1,longitudinal)+tz*tail*math.max(0,(s-.76)/.24)+nz*bend
    local neck=.12*ease(u/.34)
    local shoulder=.88*ease((u-.25)/.49)
    local cap=1-ease((u-.78)/.22)
    local radius=breadth*(neck+shoulder)*cap*reach*math.max(0,math.min(3,p.volumeScale or 1))
    for side=0,SIDES do
      local v=side/SIDES;local a=v*PI*2
      local lobe=1+.14*math.sin(a*3-s*9+clock*3.5+phase)
        +.065*math.sin(a*5+s*15-clock*4.2-phase)
      local r=radius*lobe
      local xx,yy=math.cos(a)*r,math.sin(a)*r*.62
      local vert=vertices[slice*(SIDES+1)+side+1]
      vert[1],vert[2],vert[3]=x+nx*xx+bx*yy,y+ny*xx+by*yy,z+nz*xx+bz*yy
      vert[4],vert[5],vert[6]=u,v,1
    end
  end
  return #vertices
end
-- Native card UVs and anchors are sampled, not recreated from species guesses.
-- Each grid vertex retains immutable local position/UV data.
function P.newSubjectGeometry(corners)
  local vertices,indices=topology(COLS,ROWS)
  local rest={}
  for row=0,ROWS do for col=0,COLS do
    local u,v=col/COLS,row/ROWS
    local i=row*(COLS+1)+col+1
    local r={}
    for k=1,6 do
      local bottom=corners[1][k]*(1-u)+corners[2][k]*u
      local top=corners[4][k]*(1-u)+corners[3][k]*u
      r[k]=bottom*(1-v)+top*v
      vertices[i][k]=r[k]
    end
    rest[i]=r
  end end
  return vertices,indices,rest
end
-- The leading side drains first while the trailing body remains broad.
-- This is deliberately non-affine: the silhouette stretches into the flow,
-- rather than shrinking/rotating a rigid card. No deformation before intake.
function P.subjectPoint(p,x,y,z)
  local ox,oy,oz=x-p.source[1],y-p.source[2],z-p.source[3]
  local ax,ay,az=norm(p.mouth[1]-p.source[1],p.mouth[2]-p.source[2],p.mouth[3]-p.source[3])
  local lead=math.max(-1,math.min(1,(ox*ax+oy*ay+oz*az)/math.max(2,math.max(p.width,p.height)*.5)))
  local t=clamp(p.pull+math.sin(PI*p.pull)*lead*.30)
  local cx,cy,cz=P.center(p,t)
  local remain=(1-t)^1.9
  local ripple=math.sin(PI*t)*math.sin(lead*4.3-p.timer*4)*p.width*.025
  return cx+ox*remain+p.rx*ripple,cy+oy*remain,cz+oz*remain+p.rz*ripple
end
function P.updateSubject(vertices,rest,p,model)
  for i,r in ipairs(rest) do
    local x=model[1]*r[1]+model[2]*r[2]+model[3]*r[3]+model[4]
    local y=model[5]*r[1]+model[6]*r[2]+model[7]*r[3]+model[8]
    local z=model[9]*r[1]+model[10]*r[2]+model[11]*r[3]+model[12]
    local v=vertices[i]
    v[1],v[2],v[3]=P.subjectPoint(p,x,y,z)
    v[4],v[5],v[6]=r[4],r[5],r[6]
  end
  return #vertices
end
return P
