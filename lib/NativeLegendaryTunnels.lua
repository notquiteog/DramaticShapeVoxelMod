-- Shared optional tunnel kit; native stairs/warps and collision stay authoritative.
local V=...
local M={}
local ids={FR_UNDERGROUND_PATH_NORTH_SOUTH_TUNNEL=true,FR_UNDERGROUND_PATH_EAST_WEST_TUNNEL=true}
function M.geometry(cells,id)
 if not ids[id]or V.require('CommunityVisuals').tunnels:get()~='n64memory'then return end
 local Source=V.require('UndergroundRoom');local vs,ix,claims={},{},{}
 local function append(a,b,transform)
  local n=#vs;for _,p in ipairs(a)do if transform then transform(p)end;vs[#vs+1]=p end
  for _,i in ipairs(b)do ix[#ix+1]=n+i end
 end
 local floors,walls=0,0
 for key,c in pairs(cells)do
  local col=c.column
  if c.collision==0 and c.shape.kind=='flat'and not c.stairs and not c.prop and not c.civic then
   local r={floor={},stairs={},walls={}}
   for dy=0,8,8 do for dx=0,8,8 do r.floor[#r.floor+1]={x=c.cx*16+dx,z=c.cy*16+dy}end end
   local a,b=Source.geometry(r);append(a,b,function(p)p[2]=p[2]+(c.base or 0)end);floors=floors+1
  elseif col and col.indoor and c.cy==col.last and not col.stageHidden then
   local solid=true
   for y=col.first,col.last do local n=cells[c.cx..':'..y]
    if not n or n.collision~=7 or n.prop or n.stairs then solid=false;break end
   end
   if solid then
    local r={walls={{x=c.cx*16,z=0,side='north'},{x=c.cx*16+8,z=0,side='north'}},minX=c.cx*16,maxX=(c.cx+1)*16,minZ=0,maxZ=8}
    local a,b=Source.geometry(r,'north')
    append(a,b,function(p)
     p[1]=math.max(c.cx*16,math.min((c.cx+1)*16,p[1]))
     p[2]=(c.base or 0)+math.max(0,math.min(48,p[2]))*col.height/48
     p[3]=col.back+math.max(0,math.min(1,(p[3]+1)/10))*(col.front-col.back)
    end)
    for y=col.first,col.last do claims[c.cx..':'..y]=true end;walls=walls+1
   end
  elseif c.collision==7 and not c.stairs and not c.prop and not c.stageHidden then
   -- Native tunnel side strips are flat source art, not indoor columns.
   -- Only their boundary against real floor receives a closed wall. Keep
   -- every protrusion inside the blocked cell, including lamps and trim.
   for _,edge in ipairs{{1,0,'west'},{-1,0,'east'},{0,1,'north'},{0,-1,'south'}}do
    local n=cells[(c.cx+edge[1])..':'..(c.cy+edge[2])]
    if n and n.collision==0 and not n.stairs then
     local r={walls={{x=0,z=0,side=edge[3]}},minX=0,maxX=8,minZ=0,maxZ=8}
     local a,b=Source.geometry(r,edge[3]);local lo,hi={1e9,1e9,1e9},{-1e9,-1e9,-1e9}
     for _,p in ipairs(a)do for j=1,3 do lo[j]=math.min(lo[j],p[j]);hi[j]=math.max(hi[j],p[j])end end
     append(a,b,function(p)
      local u,w=(p[1]-lo[1])/(hi[1]-lo[1]),(p[3]-lo[3])/(hi[3]-lo[3])
      p[1]=c.cx*16+(edge[1]==1 and 12+u*4 or edge[1]==-1 and u*4 or u*16)
      p[3]=c.cy*16+(edge[2]==1 and 12+w*4 or edge[2]==-1 and w*4 or w*16)
      p[2]=(c.base or 0)+(p[2]-lo[2])/(hi[2]-lo[2])*40
     end)
     claims[key]=true;walls=walls+1
    end
   end
  end
 end
 if #vs==0 then return end
 return vs,ix,claims,{floors=floors,walls=walls}
end
function M.build(cells,id)
 local vs,ix,claims,counts=M.geometry(cells,id);if not vs then return end
 local d=love.image.newImageData(16,1)
 for i,c in ipairs(V.require('UndergroundRoom').palette())do d:setPixel(i-1,0,c[1],c[2],c[3],1)end
 local image=love.graphics.newImage(d);image:setFilter('nearest','nearest');d:release()
 return {mesh=V.require('Voxel3D').newMesh(vs,ix),image=image,claims=claims,counts=counts}
end
return M
