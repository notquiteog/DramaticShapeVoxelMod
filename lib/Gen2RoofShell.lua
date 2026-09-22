-- Match the existing pitched roof exactly, then seal the exposed space above
-- the facade. No new footprint, collision or building-height decisions.
local V=...
local M={}
local Eaves=V and V.require('RoofEaves') or assert(loadfile('lib/RoofEaves.lua'))()
local function face(emit,p,uv,shade,reverse)
  if reverse then p={p[4],p[3],p[2],p[1]};uv={uv[4],uv[3],uv[2],uv[1]} end
  emit(p,uv,shade)
end
function M.corners(run,tx,ty,heightAt)
  local extent=run.roofExtent or run.extent
  local mid=extent/2
  local function height(d)
    local t=d<=mid and d/mid or (extent-d)/(extent-mid)
    t=math.max(0,math.min(1,t))
    -- Straight roof planes keep the source silhouette legible. The old
    -- nonlinear bow plus deep corrugation made ordinary houses look melted.
    return run.h+run.rise*t
  end
  local south,north=height((run.roofFront or run.front)-ty),height((run.roofFront or run.front)-ty+1)
  local c={south,south,north,north} -- SW, SE, NE, NW
  if heightAt(tx-1,ty)<run.h then
    c[1],c[4]=math.max(run.h,south-3),math.max(run.h,north-3)
  end
  if heightAt(tx+1,ty)<run.h then
    c[2],c[3]=math.max(run.h,south-3),math.max(run.h,north-3)
  end
  return c
end
function M.append(run,tx,ty,c,runAt,heightAt,emit,uvRect,tile)
  local x,z=tx*8,ty*8
  local p={{x,z+8},{x+8,z+8},{x+8,z},{x,z}}
  -- Corner pair, neighbor offset and the corresponding neighbor corners.
  local edges={{1,2,0,1,4,3},{2,3,1,0,1,4},
               {3,4,0,-1,2,1},{4,1,-1,0,3,2}}
  local u0,u1,v0,v1=uvRect(tile,0,8)
  for _,e in ipairs(edges) do
    local a,b=e[1],e[2]
    local nx,nz=tx+e[3],ty+e[4]
    local other=runAt(nx,nz)
    local loA,loB=heightAt(nx,nz),heightAt(nx,nz)
    if other and other.rise>0 then
      local n=M.corners(other,nx,nz,heightAt)
      loA,loB=n[e[5]],n[e[6]]
    end
    loA=math.min(c[a],math.max(run.h,loA))
    loB=math.min(c[b],math.max(run.h,loB))
    if c[a]>loA+.001 or c[b]>loB+.001 then
      emit({{p[a][1],loA,p[a][2]},{p[b][1],loB,p[b][2]},
        {p[b][1],c[b],p[b][2]},{p[a][1],c[a],p[a][2]}},
        {{u0,v1},{u1,v1},{u1,v0},{u0,v0}},.86)
    end
  end
end
-- Thin overlapping tile courses. Fine joints live in the material; broad
-- corrugated ribs must not distort the entire roof into repeated waves.
function M.courses(c,tx,ty,emit,uvRect,tile,west,east)
  local x,z=tx*8,ty*8
  local u0,u1,v0,v1=uvRect(tile,0,8)
  local downSouth=c[1]+c[2]<=c[3]+c[4]
  local function height(t,u)
    local n,s=c[4]+(c[3]-c[4])*u,c[1]+(c[2]-c[1])*u
    return n+(s-n)*t
  end
  local function uv(u,t)return {u0+(u1-u0)*u,v0+(v1-v0)*t}end
  for row=0,3 do
    local a,b=row/4,(row+1)/4
    local la,lb=downSouth and .02 or .12,downSouth and .12 or .02
    local A,B={x,height(a,0)+la,z+a*8},{x+8,height(a,1)+la,z+a*8}
    local C,D={x+8,height(b,1)+lb,z+b*8},{x,height(b,0)+lb,z+b*8}
    emit({D,C,B,A},{uv(0,b),uv(1,b),uv(1,a),uv(0,a)},.96)
    local t=downSouth and b or a
    local p,q=downSouth and D or A,downSouth and C or B
    face(emit,{{x,height(t,0),z+t*8},{x+8,height(t,1),z+t*8},q,p},
      {uv(0,t),uv(1,t),uv(1,t),uv(0,t)},.82,not downSouth)
    if west then emit({{x,height(a,0),z+a*8},{x,height(b,0),z+b*8},D,A},
      {uv(0,a),uv(0,b),uv(0,b),uv(0,a)},.82)end
    if east then emit({{x+8,height(b,1),z+b*8},{x+8,height(a,1),z+a*8},B,C},
      {uv(1,b),uv(1,a),uv(1,a),uv(1,b)},.82)end
  end
end

-- Modest projecting eaves with a dark closed soffit. Never emit an internal
-- eave where roofs meet; the original facade and collision remain in place.
function M.trim(run,tx,ty,c,runAt,emit,uvRect,tile)
  local x,z=tx*8,ty*8
  local u0,u1,v0,v1=uvRect(tile,0,8)
  local uv={{u0,v1},{u1,v1},{u1,v0},{u0,v0}}
  local points={{x,c[1],z+8},{x+8,c[2],z+8},{x+8,c[3],z},{x,c[4],z}}
  for _,e in ipairs({{0,1,1,2},{1,0,2,3},{0,-1,3,4},{-1,0,4,1}})do
    local other=runAt(tx+e[1],ty+e[2])
    if not (other and other.rise>0 and other.h==run.h) then
      Eaves.edge(points[e[3]],points[e[4]],e[1]*1.5,e[2]*1.5,uv,emit,.5)
    end
  end
  -- One rounded ridge cap per column. The south half owns the ridge seam,
  -- including odd-depth roofs where it falls inside a cell.
  local extent=run.roofExtent or run.extent
  local mid=extent/2
  local d=(run.roofFront or run.front)-ty
  if d<mid and d+1>=mid then
    local t=d+1-mid
    local za=z+t*8
    local left=c[4]+(c[1]-c[4])*t
    local right=c[3]+(c[2]-c[3])*t
    local section={{-.65,.08},{-.45,.30},{0,.45},{.45,.30},{.65,.08}}
    for i=1,#section-1 do
      local a,b=section[i],section[i+1]
      emit({{x,left+b[2],za+b[1]},{x+8,right+b[2],za+b[1]},
        {x+8,right+a[2],za+a[1]},{x,left+a[2],za+a[1]}},uv,.88)
    end
    for _,edge in ipairs({{tx-1,x,left},{tx+1,x+8,right}}) do
      local other=runAt(edge[1],ty)
      if not (other and other.rise==run.rise and other.h==run.h
        and (other.roofFront or other.front)==(run.roofFront or run.front)
        and (other.roofExtent or other.extent)==(run.roofExtent or run.extent)) then
        for i=1,#section-1 do
          local a,b=section[i],section[i+1]
          face(emit,{{edge[2],edge[3],za+a[1]},{edge[2],edge[3],za+b[1]},
            {edge[2],edge[3]+b[2],za+b[1]},{edge[2],edge[3]+a[2],za+a[1]}},uv,.74,edge[1]>tx)
        end
      end
    end
  end
end
return M
