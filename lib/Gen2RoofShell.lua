-- Match the existing pitched roof exactly, then seal the exposed space above
-- the facade. No new footprint, collision or building-height decisions.
local M={}
local function face(emit,p,uv,shade,reverse)
  if reverse then p={p[4],p[3],p[2],p[1]};uv={uv[4],uv[3],uv[2],uv[1]} end
  emit(p,uv,shade)
end
function M.corners(run,tx,ty,heightAt)
  local mid=run.extent/2
  local function height(d)
    local t=d<=mid and d/mid or (run.extent-d)/(run.extent-mid)
    t=math.max(0,math.min(1,t))
    -- A restrained kawara profile: flatter at the eaves, steeper near the
    -- ridge. Keep the original facade and peak; adjoining cells share it.
    return run.h+run.rise*(.65*t+.35*t*t)
  end
  local south,north=height(run.front-ty),height(run.front-ty+1)
  local c={south,south,north,north} -- SW, SE, NE, NW
  if heightAt(tx-1,ty)<run.h then
    c[1],c[4]=math.max(run.h,south-8),math.max(run.h,north-8)
  end
  if heightAt(tx+1,ty)<run.h then
    c[2],c[3]=math.max(run.h,south-8),math.max(run.h,north-8)
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
-- Concave pans and raised rolled seams follow the sealed roof plane. Their
-- overlap lips are real geometry, so the finish also reads at eye level.
function M.courses(c,tx,ty,emit,uvRect,tile,west,east)
  local x,z=tx*8,ty*8
  local u0,u1,v0,v1=uvRect(tile,0,8)
  local downSouth=c[1]+c[2]<=c[3]+c[4]
  local function height(t,u)
    local n,south=c[4]+(c[3]-c[4])*u,c[1]+(c[2]-c[1])*u
    return n+(south-n)*t
  end
  local rib={.42,.10,.025,.10,.42}
  local function uv(u,t)return {u0+(u1-u0)*u,v0+(v1-v0)*t} end
  for row=0,3 do
    local a,b=row/4,(row+1)/4
    local liftA,liftB=downSouth and .015 or .20,downSouth and .20 or .015
    for col=0,7 do
      local u,v=col/8,(col+1)/8
      local ra,rb=rib[col%4+1],rib[col%4+2]
      local A,B={x+u*8,height(a,u)+liftA+ra,z+a*8},
        {x+v*8,height(a,v)+liftA+rb,z+a*8}
      local C,D={x+v*8,height(b,v)+liftB+rb,z+b*8},
        {x+u*8,height(b,u)+liftB+ra,z+b*8}
      emit({D,C,B,A},{uv(u,b),uv(v,b),uv(v,a),uv(u,a)},.96)
      local t=downSouth and b or a
      local p,q=downSouth and D or A,downSouth and C or B
      face(emit,{{x+u*8,height(t,u),z+t*8},{x+v*8,height(t,v),z+t*8},q,p},
        {uv(u,t),uv(v,t),uv(v,t),uv(u,t)},.72,not downSouth)
      if west and col==0 then emit({{x,height(a,0),z+a*8},
        {x,height(b,0),z+b*8},D,A},{uv(0,a),uv(0,b),uv(0,b),uv(0,a)},.78) end
      if east and col==7 then emit({{x+8,height(b,1),z+b*8},
        {x+8,height(a,1),z+a*8},B,C},{uv(1,b),uv(1,a),uv(1,a),uv(1,b)},.78) end
    end
  end
end

-- Modest projecting eaves with a dark closed soffit. Never emit an internal
-- eave where roofs meet; the original facade and collision remain in place.
function M.trim(run,tx,ty,c,runAt,emit,uvRect,tile)
  local x,z=tx*8,ty*8
  local u0,u1,v0,v1=uvRect(tile,0,8)
  local uv={{u0,v1},{u1,v1},{u1,v0},{u0,v0}}
  for _,side in ipairs({{0,-1,4,3,z},{0,1,1,2,z+8}}) do
    local other=runAt(tx,ty+side[2])
    if not (other and other.rise>0) then
      local a,b=c[side[3]],c[side[4]]
      local edge,out=side[5],side[5]+side[2]*.9
      local A,B,C,D={x,a+.42,edge},{x+8,b+.42,edge},
        {x+8,b+.58,out},{x,a+.58,out}
      local E,F,G,H={x,a-.25,edge},{x+8,b-.25,edge},
        {x+8,b-.09,out},{x,a-.09,out}
      local reverse=side[2]<0
      face(emit,{D,C,B,A},uv,.90,reverse);face(emit,{E,F,G,H},uv,.48,reverse)
      face(emit,{H,G,C,D},uv,.67,reverse)
      -- Closed end grain only at exposed ends, never between roof cells.
      local w,e=runAt(tx-1,ty),runAt(tx+1,ty)
      if not (w and w.rise>0 and w.h==run.h) then face(emit,{E,H,D,A},uv,.60,reverse) end
      if not (e and e.rise>0 and e.h==run.h) then face(emit,{G,F,B,C},uv,.60,reverse) end
    end
  end
  -- One rounded ridge cap per column. The south half owns the ridge seam,
  -- including odd-depth roofs where it falls inside a cell.
  local mid=run.extent/2
  local d=run.front-ty
  if d<mid and d+1>=mid then
    local t=d+1-mid
    local za=z+t*8
    local left=c[4]+(c[1]-c[4])*t
    local right=c[3]+(c[2]-c[3])*t
    local section={{-1.15,.18},{-.95,.75},{-.5,1.12},{0,1.24},
      {.5,1.12},{.95,.75},{1.15,.18}}
    for i=1,#section-1 do
      local a,b=section[i],section[i+1]
      emit({{x,left+b[2],za+b[1]},{x+8,right+b[2],za+b[1]},
        {x+8,right+a[2],za+a[1]},{x,left+a[2],za+a[1]}},uv,.88)
    end
    for _,edge in ipairs({{tx-1,x,left},{tx+1,x+8,right}}) do
      local other=runAt(edge[1],ty)
      if not (other and other.rise==run.rise and other.h==run.h
        and other.front==run.front and other.extent==run.extent) then
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
