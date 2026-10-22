-- Native R/S/E secret-base rooms: six reviewed palettes, four layouts each.
-- Layout, collision, warps, decoration edits and actors remain engine-owned.
local M={}
local families={secret_base_red_cave=true,secret_base_blue_cave=true,
 secret_base_brown_cave=true,secret_base_yellow_cave=true,
 secret_base_shrub=true,secret_base_tree=true}
local walls={}
for _,n in ipairs{0x201,0x202,0x203,0x205,0x207,0x209,0x20b,0x20d,0x20f,0x210,0x211,0x212,0x213}do walls[n]=true end
function M.family(primary,secondary)return primary=='secret_base'and families[secondary]or false end
function M.supports(def,spec)
 return def and tonumber(def.mapType)==9 and spec and M.family(spec.primary,spec.secondary)or false
end
function M.shape(primary,secondary,mid,behavior,collision)
 if not M.family(primary,secondary)then return end
 if walls[mid]and collision==7 then
  return{kind='caveWall',height=32,ground=0x20a,cap=0x210,side=0x202,secretBase=true}
 elseif collision==7 and(mid==0x220 or mid==0x20c or mid==0x222 or mid==0x223)then
  return{kind='secretBaseProp',secretBase=mid==0x220 and'pc'or mid==0x20c and'door'or'pit',ground=0x20a}
 end
 -- Native removable/walkable stones, mats and user decorations must retain
 -- their original surface/clearance; a blocked permission alone is no recipe.
 return{kind='flat',reviewedSurface=(mid==0x20a and collision==0 or mid==0x204 and collision==0x72)or nil}
end
function M.profile(def,spec)
 if not M.supports(def,spec)then return end
 return{bounds={0,0,def.width*16,def.height*16},height=32,theme='cave',gen=3,
  cave=true,secretBase=true,nativeWallFinish=true,noInteriorTrim=true}
end
function M.openings(cells)
 local out={}
 for _,c in pairs(cells)do if c.shape and c.shape.kind=='secretBaseProp'and c.shape.secretBase=='pit'then
  out[#out+1]={c.cx*16,c.cy*16,(c.cx+1)*16,(c.cy+1)*16}
 end end
 table.sort(out,function(a,b)return a[2]==b[2]and a[1]<b[1]or a[2]<b[2]end)
 return out
end
local masks=setmetatable({},{__mode='k'})
local function pitMask(c)
 local cache=masks[c.ts];if not cache then cache={};masks[c.ts]=cache end
 if cache[c.mid]then return cache[c.mid]end
 local ts=c.ts;local slot=ts.midToSlot[c.mid];local x0,y0=slot%ts.cols*16,math.floor(slot/ts.cols)*16
 local mask={}
 for y=0,15 do for x=0,15 do
  local r,g,b,a=ts.imageData:getPixel(x0+x,y0+y)
  if ts.overImageData then local rr,gg,bb,aa=ts.overImageData:getPixel(x0+x,y0+y);r,g,b=rr*aa+r*(1-aa),gg*aa+g*(1-aa),bb*aa+b*(1-aa)end
  -- The source hole is neutral charcoal, unlike the coloured earth/leaf rim.
  if a>.5 and math.max(r,g,b)<.23 and math.max(r,g,b)-math.min(r,g,b)<.06 then mask[y*16+x]=true end
 end end
 cache[c.mid]=mask;return mask
end
function M.append(cells,c,emit,uvFor)
 local shape=c.shape;if not shape or shape.kind~='secretBaseProp'then return false end
 local x,z=c.cx*16,c.cy*16;local uv=assert(uvFor(c.ts,c.mid))
 local function crop(u,sx,sy,w,h)
  local du,dv=u[2][1]-u[1][1],u[3][2]-u[1][2]
  return{{u[1][1]+du*sx/16,u[1][2]+dv*sy/16},{u[1][1]+du*(sx+w)/16,u[1][2]+dv*sy/16},
   {u[1][1]+du*(sx+w)/16,u[1][2]+dv*(sy+h)/16},{u[1][1]+du*sx/16,u[1][2]+dv*(sy+h)/16}}
 end
 local function solid(sx,sy)local a=crop(uv,sx,sy,0,0)[1];return{a,a,a,a}end
 local function face(points,t,shade)
  local p={};for _,a in ipairs(points)do p[#p+1]={x+a[1],a[2],z+a[3]}end;emit(p,t,shade or 1)
 end
 local function plane(t,y)face({{0,y or 0,0},{16,y or 0,0},{16,y or 0,16},{0,y or 0,16}},t)end
 local function box(a,y0,b,d,y1,e,t)
  face({{a,y1,b},{d,y1,b},{d,y1,e},{a,y1,e}},t,.95)
  face({{a,y1,e},{d,y1,e},{d,y0,e},{a,y0,e}},t,.85)
  face({{d,y1,b},{a,y1,b},{a,y0,b},{d,y0,b}},t,.8)
  face({{a,y1,b},{a,y1,e},{a,y0,e},{a,y0,b}},t,.8)
  face({{d,y1,e},{d,y1,b},{d,y0,b},{d,y0,e}},t,.8)
  face({{a,y0,e},{d,y0,e},{d,y0,b},{a,y0,b}},t,.7)
 end
 if shape.secretBase=='pc'then
  plane(assert(uvFor(c.ts,0x20a)))
  local grey,dark=solid(3,7),solid(4,4)
  box(3,0,7,13,7,13,grey);box(2,8,3,14,19,8,grey)
  face({{2,19,8.02},{14,19,8.02},{14,9,8.02},{2,9,8.02}},crop(uv,2,1,12,8))
  box(2,6,8,14,7,14,dark)
  face({{2,9,8},{14,9,8},{14,7,14},{2,7,14}},crop(uv,2,10,12,4))
 elseif shape.secretBase=='door'then
  plane(uv)
  local side=assert(uvFor(c.ts,0x202))
  box(0,0,0,2,32,16,side);box(14,0,0,16,32,16,side);box(2,24,0,14,32,16,side)
 elseif shape.secretBase=='pit'then
  local mask=pitMask(c);local black=solid(8,12)
  local function hole(px,py)
   if px>=0 and px<16 and py>=0 and py<16 then return mask[py*16+px]end
   local nx,ny=c.cx+(px<0 and-1 or px>=16 and 1 or 0),c.cy+(py<0 and-1 or py>=16 and 1 or 0)
   local n=cells[nx..':'..ny]
   return n and n.shape and n.shape.kind=='secretBaseProp'and n.shape.secretBase=='pit'and pitMask(n)[(py%16)*16+(px%16)]
  end
  for py=0,15 do for px=0,15 do
   if mask[py*16+px]then
    face({{px,-8,py},{px+1,-8,py},{px+1,-8,py+1},{px,-8,py+1}},black,.6)
    for _,d in ipairs{{0,-1},{1,0},{0,1},{-1,0}}do if not hole(px+d[1],py+d[2])then
     local a,b,e,f=px,py,px+1,py+1
     local line=d[1]==1 and{{e,0,b},{e,0,f},{e,-8,f},{e,-8,b}}
      or d[1]==-1 and{{a,0,f},{a,0,b},{a,-8,b},{a,-8,f}}
      or d[2]==1 and{{e,0,f},{a,0,f},{a,-8,f},{e,-8,f}}
      or{{a,0,b},{e,0,b},{e,-8,b},{a,-8,b}}
     face(line,black,.75)
    end end
   else
    face({{px,0,py},{px+1,0,py},{px+1,0,py+1},{px,0,py+1}},crop(uv,px,py,1,1))
   end
  end end
 end
 return true
end
return M
