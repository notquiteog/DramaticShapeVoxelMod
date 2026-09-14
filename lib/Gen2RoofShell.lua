-- Match the existing pitched roof exactly, then seal the exposed space above
-- the facade. No new footprint, collision or building-height decisions.
local M={}
function M.corners(run,tx,ty,heightAt)
  local mid=run.extent/2
  local function height(d)
    local t=d<=mid and d/mid or (run.extent-d)/(run.extent-mid)
    return run.h+run.rise*math.max(0,math.min(1,t))
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
-- Thin overlapping courses follow the sealed roof plane. The original
-- plane remains underneath; side/end caps close each raised tile lip.
function M.courses(c,tx,ty,emit,uvRect,tile,west,east)
  local x,z=tx*8,ty*8
  local u0,u1,v0,v1=uvRect(tile,0,8)
  local downSouth=c[1]+c[2]<=c[3]+c[4]
  local function height(t,right)
    local n,south=right and c[3] or c[4],right and c[2] or c[1]
    return n+(south-n)*t
  end
  for row=0,3 do
    local a,b=row/4,(row+1)/4
    local liftA,liftB=downSouth and 0 or .28,downSouth and .28 or 0
    local an,bn=height(a,false),height(b,false)
    local ae,be=height(a,true),height(b,true)
    local A,B,C,D={x,an+liftA,z+a*8},{x+8,ae+liftA,z+a*8},
      {x+8,be+liftB,z+b*8},{x,bn+liftB,z+b*8}
    local va,vb=v0+(v1-v0)*a,v0+(v1-v0)*b
    emit({D,C,B,A},{{u0,vb},{u1,vb},{u1,va},{u0,va}},.97)
    local t=downSouth and b or a
    local p,q=downSouth and D or A,downSouth and C or B
    local vv=downSouth and vb or va
    emit({{x,height(t,false),z+t*8},{x+8,height(t,true),z+t*8},q,p},
      {{u0,vv},{u1,vv},{u1,vv},{u0,vv}},.68)
    if west then emit({{x,an,z+a*8},{x,bn,z+b*8},D,A},
      {{u0,va},{u0,vb},{u0,vb},{u0,va}},.78) end
    if east then emit({{x+8,be,z+b*8},{x+8,ae,z+a*8},B,C},
      {{u1,vb},{u1,va},{u1,va},{u1,vb}},.78) end
  end
end
return M
