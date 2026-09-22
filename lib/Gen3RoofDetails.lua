-- FireRed building-specific roof treatment. Native art supplies the materials;
-- grass outside the Pallet roof silhouette stays on the ground, and the lab's
-- chimney is a separate solid object above its flat roof.
local M={}
local baked={}
function M.sideVisible(cells,c,dx)
 local n=cells[(c.cx+dx)..':'..c.cy]
 local a,b=c.column,n and n.column
 if not b or n.pair~=c.pair then return true end
 -- A building is one shell, not a row of boxes. Internal dividers became
 -- visible as fins when transparent source grass exposed the roof's back.
 for _,field in ipairs({'height','front','back','roofType','roofInset','roofs'})do
  if a[field]~=b[field] then return true end
 end
 return false
end
function M.height(column,z)
 if column.roofType=='flat' then return column.height end
 local back=column.back+(column.front-column.back)*(column.roofInset or 0)/(column.roofs*16)
 local t=(z-back)/(column.front-back)
 -- Straight gable faces and vertical gable ends. No automatic barrel curve
 -- or hipped sides: those need a building profile that actually calls for it.
 return column.height+13*(1-math.abs(2*t-1))
end
function M.prepare(cells)
 local chimneys={}
 for _,c in pairs(cells)do
  if c.secondary=='pallet_town' and c.mid==0x2BD then
   local rows={{0x2BD,0x2B5},{0x2B3,0x2B4},{0x2BB,0x2BC}}
   local match=true;local parts={}
   for y,row in ipairs(rows)do for x,mid in ipairs(row)do
    local n=cells[(c.cx+x-1)..':'..(c.cy+y-1)]
    if not n or n.pair~=c.pair or n.mid~=mid or not n.column or n.column.roofType~='flat' then match=false end
    parts[#parts+1]={cell=n,row=y}
   end end
   if match then
    for _,p in ipairs(parts)do p.cell.roofMid=({0x2A9,0x2B1,0x2B9})[p.row] end
    chimneys[#chimneys+1]={cx=c.cx,cy=c.cy,ts=c.ts,pair=c.pair,height=c.column.height}
   end
  end
 end
 return chimneys
end
function M.image(ts,secondary,shapeOf)
 local old=baked[ts.pair];if old and old.ts==ts then return old.image end
 if not ts.imageData then return nil end
 local data=ts.imageData:clone()
 for mid,slot in pairs(ts.midToSlot)do
  if shapeOf('general',secondary,mid).kind=='roof' then
   local x0,y0=slot%ts.cols*16,math.floor(slot/ts.cols)*16
   for y=0,15 do for x=0,15 do
    local r,g,b,a=ts.imageData:getPixel(x0+x,y0+y)
    if ts.overImageData then
     local rr,gg,bb,aa=ts.overImageData:getPixel(x0+x,y0+y)
     r,g,b,a=rr*aa+r*(1-aa),gg*aa+g*(1-aa),bb*aa+b*(1-aa),aa+a*(1-aa)
    end
    -- Pallet's roof art is salmon/grey, its background mint. Scope this to
    -- these reviewed roof cells: a green Viridian roof is never cut away.
    if (secondary=='pallet_town' or mid<0x280) and g>r+.035 and g>b+.02 then a=0 end
    data:setPixel(x0+x,y0+y,r,g,b,a)
   end end
  end
 end
 local image=love.graphics.newImage(data);image:setFilter('nearest','nearest');data:release()
 if old then old.image:release()end
 baked[ts.pair]={ts=ts,image=image};return image
end
function M.appendChimney(p,emit,uvFor)
 local x,z,y=p.cx*16+3,p.cy*16+22,p.height
 local art=uvFor(p.ts,0x2B3)
 local function sample(uv,px,py)
  local u=uv[1][1]+(uv[2][1]-uv[1][1])*px/16
  local v=uv[1][2]+(uv[3][2]-uv[1][2])*py/16
  return {{u,v},{u,v},{u,v},{u,v}}
 end
 local brick,dark=sample(art,4,7),sample(art,13,7)
 local function box(x0,z0,x1,z1,bottom,top,uv,shade)
  emit({{x0,top,z0},{x1,top,z0},{x1,top,z1},{x0,top,z1}},uv,shade)
  emit({{x0,top,z1},{x1,top,z1},{x1,bottom,z1},{x0,bottom,z1}},uv,shade*.84)
  emit({{x1,top,z0},{x0,top,z0},{x0,bottom,z0},{x1,bottom,z0}},uv,shade*.75)
  emit({{x0,top,z0},{x0,top,z1},{x0,bottom,z1},{x0,bottom,z0}},uv,shade*.78)
  emit({{x1,top,z1},{x1,top,z0},{x1,bottom,z0},{x1,bottom,z1}},uv,shade*.88)
 end
 box(x,z,x+15,z+16,y,y+17,brick,1)
 -- Raised brick courses and a cap around a recessed dark flue.
 for h=4,16,4 do box(x-.15,z-.15,x+15.15,z+16.15,y+h-.45,y+h,brick,.78)end
 box(x-1,z-1,x+16,z+2,y+17,y+20,brick,1)
 box(x-1,z+14,x+16,z+17,y+17,y+20,brick,1)
 box(x-1,z+2,x+2,z+14,y+17,y+20,brick,1)
 box(x+13,z+2,x+16,z+14,y+17,y+20,brick,1)
 emit({{x+2,y+17.1,z+2},{x+13,y+17.1,z+2},{x+13,y+17.1,z+14},{x+2,y+17.1,z+14}},dark,.28)
end
function M.release()
 for _,p in pairs(baked)do p.image:release()end;baked={}
end
return M
