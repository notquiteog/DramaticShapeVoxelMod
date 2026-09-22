-- Shared presentation-only room framing. Native layouts, furniture, warps and
-- collision remain authoritative. Camera-facing walls open outside the room;
-- an eye inside the room sees all four walls and a ceiling.
local V=...
local M={background={.022,.032,.046,1}}
local cache=setmetatable({},{__mode='k'})
local materials={}
local themes={
 home={{.73,.71,.61},{.37,.35,.28},{.20,.22,.22},{.91,.87,.70}},
 shop={{.67,.76,.73},{.23,.43,.43},{.13,.25,.29},{.84,.94,.88}},
 center={{.79,.77,.70},{.45,.35,.32},{.22,.27,.30},{.97,.88,.72}},
 lab={{.69,.74,.73},{.29,.40,.43},{.17,.24,.28},{.83,.94,.92}},
}
function M.profile(def,gen)
 if not def then return end
 local id=def.id or '';local ts=def.tileset or ''
 if gen==3 then
  if tonumber(def.mapType)~=8 then return end
  local pair=def.midLayout and def.midLayout.pair
  if not pair then return end
  local spec=V.require('Gen3Tilesets').resolve(pair,require('src.import.gba.versions').TILESET_PAIRS)
  if spec.primary~='building' then return end
 elseif gen==2 then
  if def.environment~='INDOOR' and def.environment~='GATE' then return end
 else
  -- Dungeon, cave and ship exteriors keep their authored enclosing geometry.
  local allowed={REDS_HOUSE_1=true,REDS_HOUSE_2=true,HOUSE=true,HOUSE_1=true,
   HOUSE_2=true,MART=true,POKECENTER=true,DOJO=true,GYM=true,CLUB=true,
   LOBBY=true,LAB=true,FACILITY=true,INTERIOR=true,GATE=true,
   FOREST_GATE=true,MUSEUM=true,BEACH_HOUSE=true}
  if not allowed[ts] then return end
 end
 local name=(id..' '..ts):upper()
 local theme=name:find('MART') and 'shop' or name:find('CENTER') and 'center' or name:find('LAB') and 'lab' or 'home'
 local unit=gen==3 and 16 or 32
 local b={0,0,def.width*unit,def.height*unit}
 if gen==3 then
  -- Native layouts include padded black cells. Do not enclose that padding.
  local x0,z0,x1,z1=def.width,def.height,0,0
  for y=0,def.height-1 do for x=0,def.width-1 do
   local mid=def.midLayout:midAt(x,y)
   if mid and mid~=0 and mid~=8 and mid~=0x1A and mid~=0x1B and mid~=0x1C then
    x0,z0,x1,z1=math.min(x0,x),math.min(z0,y),math.max(x1,x+1),math.max(z1,y+1)
   end
  end end
  if x1<=x0 or z1<=z0 then return end
  b={x0*16,z0*16,x1*16,z1*16}
 end
 return {bounds=b,height=40,theme=theme,gen=gen}
end
local function texture(theme)
 if materials[theme]then return materials[theme]end
 local data=love.image.newImageData(8,1)
 local colors=themes[theme]
 for i=1,8 do local c=colors[(i-1)%4+1];local shade=i>4 and .84 or 1
  data:setPixel(i-1,0,c[1]*shade,c[2]*shade,c[3]*shade,1)
 end
 local image=love.graphics.newImage(data);image:setFilter('nearest','nearest');data:release();materials[theme]=image;return image
end
function M.geometry(p,side,opened)
 local b,h=p.bounds,p.height;local x0,z0,x1,z1=b[1],b[2],b[3],b[4]
 local verts,indices={},{}
 local function face(points,swatch,shade)
  local n=#verts
  for _,a in ipairs(points)do verts[#verts+1]={a[1],a[2],a[3],(swatch-.5)/8,.5,shade or 1}end
  for _,k in ipairs({1,2,3,1,3,4})do indices[#indices+1]=n+k end
 end
 local function box(a,y0,c,d,y1,f,swatch)
  face({{a,y1,c},{d,y1,c},{d,y1,f},{a,y1,f}},swatch,1)
  face({{a,y1,f},{d,y1,f},{d,y0,f},{a,y0,f}},swatch,.9)
  face({{d,y1,c},{a,y1,c},{a,y0,c},{d,y0,c}},swatch,.9)
  face({{a,y1,c},{a,y1,f},{a,y0,f},{a,y0,c}},swatch,.85)
  face({{d,y1,f},{d,y1,c},{d,y0,c},{d,y0,f}},swatch,.85)
 end
 if side==5 then
  box(x0-3,-4,z0-3,x1+3,-.25,z1+3,3)
 elseif side==6 then
  face({{x0,h,z0},{x1,h,z0},{x1,h,z1},{x0,h,z1}},1)
 else
  local horizontal=side==1 or side==3
  local start,finish=horizontal and x0 or z0,horizontal and x1 or z1
  local line=side==1 and z0 or side==3 and z1 or side==2 and x1 or x0
  local outward=(side==1 or side==4)and -1 or 1
  local function part(a,y0,c,y1,swatch,depth)
   local near,far=line-outward*math.max(0,(depth or 3)-3),line+outward*(depth or 3)
   if horizontal then box(a,y0,math.min(near,far),c,y1,math.max(near,far),swatch)
   else box(math.min(near,far),y0,a,math.max(near,far),y1,c,swatch)end
  end
  if opened then
   -- A low continuous foundation presents a finished cut edge without
   -- covering sprites, the entry mat, or interaction targets.
   part(start,-3,finish,0,3)
  else
   part(start,8,finish,h-3.5,1)
   part(start,0,finish,7,2,3.3)
   part(start,7,finish,8,3,3.6)
   part(start,h-2,finish,h+1.2,3,4)
   part(start,h-3.5,finish,h-2,2,3.5)
   for _,a in ipairs({start,finish-2})do part(a,0,a+2,h,2,3.6)end
   -- Recessed luminous wall panels: narrow mullions preserve pixel-art
   -- furniture as the visual focus. Only side walls receive new windows.
   if side==2 or side==4 then
    for t=.28,.75,.44 do local c=start+(finish-start)*t
     local function panel(lo,hi,y0,y1,swatch,offset)
      local q=line-outward*offset
      face({{q,y1,lo},{q,y1,hi},{q,y0,hi},{q,y0,lo}},swatch)
     end
     panel(c-6,c+6,14,33,3,.12)
     panel(c-5,c+5,15,32,4,.18)
     panel(c-.4,c+.4,15,32,2,.25)
     panel(c-5,c+5,23,24,2,.25)
    end
   end
  end
 end
 return verts,indices
end
function M.forMap(map,gen)
 local def=map and map.def or map
 if not def then return end
 local entry=cache[def]
 if entry~=nil then return entry or nil end
 local p=M.profile(def,gen)
 if not p then cache[def]=false;return end
 p.meshes={};cache[def]=p;return p
end
function M.camera(p,angle,aspect)
 if not p then return end
 local b=p.bounds;local w,d=b[3]-b[1],b[4]-b[2]
 -- Compact rooms read as complete dioramas; large halls keep the player's
 -- scrolling camera. Free/first-person cameras never call this helper.
 if w>320 or d>256 then return end
 local a=math.max(.01,math.min(math.rad(75),angle or math.rad(35)))
 local fov=math.rad(48);local h=p.height
 local extent=math.max((w+10)*.5/math.max(.5,aspect or 1.5),(d*math.cos(a)+h*math.sin(a))*.5)
 local distance=extent/math.tan(fov*.5)+(d*math.sin(a)+h*math.cos(a))*.5+10
 local x,z=(b[1]+b[3])*.5,(b[2]+b[4])*.5
 return {eye={x,h*.35+distance*math.cos(a),z+distance*math.sin(a)},focus={x,h*.35,z},fov=fov,curve=0}
end
function M.configure(p)
 V.require('Voxel3D').interior=p
end
function M.draw(p)
 if not p then return end
 local R=V.require('Voxel3D');local eye=R.eye or {0,100,1000};local b=p.bounds
 local inside=eye[1]>b[1] and eye[1]<b[3] and eye[3]>b[2] and eye[3]<b[4] and eye[2]<p.height-.05
 local opened={not inside and eye[3]<b[2],not inside and eye[1]>b[3],not inside and eye[3]>b[4],not inside and eye[1]<b[1]}
 if not inside and not (opened[1] or opened[2] or opened[3] or opened[4])then
  -- Near-overhead cameras can project inside the footprint while still
  -- looking down from outside. Open their near wall too, without a ceiling.
  local dx,dz=(eye[1]-(b[1]+b[3])*.5)/(b[3]-b[1]),(eye[3]-(b[2]+b[4])*.5)/(b[4]-b[2])
  opened[math.abs(dx)>math.abs(dz) and (dx>0 and 2 or 4) or (dz<0 and 1 or 3)]=true
 end
 R.interiorClip(false)
 for side=1,inside and 6 or 5 do
  local key=side..':'..tostring(opened[side] or false)
  if not p.meshes[key]then local v,i=M.geometry(p,side,opened[side]);p.meshes[key]=R.newMesh(v,i)end
  R.draw(p.meshes[key],texture(p.theme))
 end
 R.interiorClip(true)
end
return M
