-- Shared authored Rocket wall kit, fitted only into native solid columns.
local V=...
local M={}
function M.enabled(id)
 local which=id=='FR_ROCKET_HIDEOUT_ELEVATOR'and'elevator'or tostring(id):match('^FR_ROCKET_HIDEOUT_B[1-4]F$')and'rocket'
 return which and V.require('CommunityVisuals')[which]:get()=='n64memory'and which or false
end
function M.prepare(cells,id)
 if M.enabled(id)~='elevator'then return end
 local rows={{0x2eb,0x2e8,0x2e8,0x2e8,0x2ec},{0x2f3,0x2f0,0x2f0,0x2f0,0x2f4},{0x2fb,0x2f8,0x2f8,0x2f8,0x2fc}}
 for y,row in ipairs(rows)do for x,mid in ipairs(row)do
  local c=cells[(x-1)..':'..(y-1)]
  if not c or c.mid~=mid or c.collision~=7 then return end
 end end
 for y,row in ipairs(rows)do for x in ipairs(row)do local c=cells[(x-1)..':'..(y-1)];c.shape={kind='roomWall',ground=0x2f6}end end
end
function M.geometry(cells,id)
 local which=M.enabled(id);if not which then return end
 local Source=V.require('RocketRoom');local vertices,indices,claims={},{},{}
 for key,c in pairs(cells)do
  local col=c.column
  local solid=col and true or false
  if col then for y=col.first,col.last do local n=cells[c.cx..':'..y];if not n or n.collision~=7 or n.prop then solid=false;break end end end
  if solid and col.indoor and c.cy==col.last and not col.stageHidden then
   local layout={walls={{x=c.cx*16,z=0,side='north'},{x=c.cx*16+8,z=0,side='north'}},
    minX=c.cx*16,maxX=c.cx*16+16,minZ=0,maxZ=8,elevator=which=='elevator',nativeElevator=which=='elevator'}
   local vs,ix=Source.geometry(layout,'north');local offset=#vertices
   for _,p in ipairs(vs)do
    -- Includes pipes, ribs and wall base: nothing protrudes into floor cells.
    p[1]=c.cx*16+math.max(0,math.min(16,p[1]-c.cx*16))
    p[2]=(c.base or 0)+p[2]*col.height/56
    p[3]=col.back+math.max(0,math.min(1,(p[3]+1)/11))*(col.front-col.back)
    vertices[#vertices+1]=p
   end
   for _,i in ipairs(ix)do indices[#indices+1]=i+offset end
   for y=col.first,col.last do claims[c.cx..':'..y]=true end
  end
 end
 if #vertices==0 then return end
 return vertices,indices,claims
end
function M.build(cells,id)
 local vertices,indices,claims=M.geometry(cells,id);if not vertices then return end
 local mesh=V.require('Voxel3D').newMesh(vertices,indices)
 local d=love.image.newImageData(16,1)
 for i,c in ipairs(V.require('RocketRoom').palette())do d:setPixel(i-1,0,c[1],c[2],c[3],1)end
 local image=love.graphics.newImage(d);image:setFilter('nearest','nearest');d:release()
 return {mesh=mesh,image=image,claims=claims}
end
return M
