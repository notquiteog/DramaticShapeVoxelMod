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
return M
