-- Authored Kanto First Person interior dressing, opt-in. Pendant vertices,
-- poster sizes/hash and original sheets derive from payload_ceiling v28.
-- Placement adapts to our single native shell, never changes collision.
local V=...
local M={}
local cache=setmetatable({},{__mode='k'});local images={};local white
local function quad(v,i,a,b,c,d,u0,u1,shade)
 local n=#v
 for k,p in ipairs({a,b,c,d})do v[#v+1]={p[1],p[2],p[3],(k==1 or k==4)and u0 or u1,k<=2 and 0 or 1,shade or 1}end
 for _,k in ipairs({1,2,3,1,3,4})do i[#i+1]=n+k end
end
local function hash01(a,b,c)local s=math.sin(a*127.1+b*311.7+c*74.7)*43758.5453123;return s-math.floor(s)end
function M.pendant(x,z,h)
 local v,i={},{};local top=h-.6;local bulb=top-6
 local function q(a,b,c,d,s)quad(v,i,a,b,c,d,.5,.5,s)end
 q({x-3.4,h-.15,z+3.4},{x+3.4,h-.15,z+3.4},{x+3.4,h-.15,z-3.4},{x-3.4,h-.15,z-3.4},.58)
 q({x-.6,top,z},{x+.6,top,z},{x+.6,bulb,z},{x-.6,bulb,z},.30)
 q({x,top,z-.6},{x,top,z+.6},{x,bulb,z+.6},{x,bulb,z-.6},.30)
 q({x-5,bulb-3.5,z},{x+5,bulb-3.5,z},{x+1.4,bulb,z},{x-1.4,bulb,z},1)
 q({x,bulb-3.5,z-5},{x,bulb-3.5,z+5},{x,bulb,z+1.4},{x,bulb,z-1.4},1)
 return v,i
end
local function rockAt(p,cx,cy)return p.height-(2+hash01(cx,cy,241)*9)end
function M.rockCeiling(p)
 local v,i={},{};local b=p.bounds
 -- Original per-cell KFP relief panels with skirts up to higher neighbours.
 for z=b[2],b[4]-1,16 do for x=b[1],b[3]-1,16 do
  local cx,cy=math.floor(x/16),math.floor(z/16);local y=rockAt(p,cx,cy)
  local xr,zr=math.min(x+16,b[3]),math.min(z+16,b[4])
  quad(v,i,{x,y,zr},{xr,y,zr},{xr,y,z},{x,y,z},.0625,.0625,.52+hash01(cx,cy,263)*.22)
  local sides={{rockAt(p,cx,cy+1),x,zr,xr,zr},{rockAt(p,cx,cy-1),xr,z,x,z},
   {rockAt(p,cx+1,cy),xr,zr,xr,z},{rockAt(p,cx-1,cy),x,z,x,zr}}
  for _,s in ipairs(sides)do if s[1]>y then
   quad(v,i,{s[2],s[1],s[3]},{s[4],s[1],s[5]},{s[4],y,s[5]},{s[2],y,s[3]},.0625,.0625,.44)
  end end
 end end
 return v,i
end
function M.stalactites(p)
 local v,i={},{};local b=p.bounds
 -- Exact four-sided KFP spikes/hash, attached to the existing cave ceiling.
 -- Ground spikes are intentionally not put on native walkable cells.
 for z=b[2]+16,b[4]-16,16 do for x=b[1]+16,b[3]-16,16 do
  local cx,cy=math.floor(x/16),math.floor(z/16)
  if math.floor(hash01(cx,cy,269)*5)==0 and #v<4096 then
   local px,pz=x+4+hash01(cx,cy,251)*8,z+4+hash01(cy,cx,257)*8
   local w=2.2;local roof=rockAt(p,cx,cy);local bottom=roof-(5+hash01(cx,cy,271)*10)
   local corners={{px-w,pz+w,px+w,pz+w},{px+w,pz-w,px-w,pz-w},
    {px+w,pz+w,px+w,pz-w},{px-w,pz-w,px-w,pz+w}}
   local shades={.86,.58,.74,.66}
   for j,c in ipairs(corners)do quad(v,i,{c[1],roof,c[2]},{c[3],roof,c[4]},
    {px,bottom,pz},{px,bottom,pz},.0625,.0625,shades[j])end
  end
 end end
 return v,i
end
function M.beams(p)
 local v,i={},{};local b,h=p.bounds,p.height
 if p.cave or p.theme=='shop'or p.theme=='center'then return v,i end
 local along=(b[3]-b[1])>=(b[4]-b[2]);local start,finish=along and b[2]or b[1],along and b[4]or b[3]
 -- Original 2.2px drop/1.6px half-width, every fourth cell. Continuous
 -- runs merge the upstream per-cell quads without changing their silhouette.
 for at=start+40,finish-8,64 do
  local function q(a,c,d,e,s)quad(v,i,a,c,d,e,.0625,.0625,s)end
  if along then
   q({b[1],h-2.2,at+1.6},{b[3],h-2.2,at+1.6},{b[3],h-2.2,at-1.6},{b[1],h-2.2,at-1.6},.30)
   q({b[1],h,at+1.6},{b[3],h,at+1.6},{b[3],h-2.2,at+1.6},{b[1],h-2.2,at+1.6},.26)
   q({b[3],h,at-1.6},{b[1],h,at-1.6},{b[1],h-2.2,at-1.6},{b[3],h-2.2,at-1.6},.22)
  else
   q({at-1.6,h-2.2,b[2]},{at-1.6,h-2.2,b[4]},{at+1.6,h-2.2,b[4]},{at+1.6,h-2.2,b[2]},.30)
   q({at+1.6,h,b[2]},{at+1.6,h,b[4]},{at+1.6,h-2.2,b[4]},{at+1.6,h-2.2,b[2]},.26)
   q({at-1.6,h,b[4]},{at-1.6,h,b[2]},{at-1.6,h-2.2,b[2]},{at-1.6,h-2.2,b[4]},.22)
  end
 end
 return v,i
end
function M.posters(p,side,frames,windows)
 local v,i={},{};local b=p.bounds;local horizontal=side==1 or side==3
 if side==1 and p.northFront then return v,i end -- a recessed staircase is not a flat wall
 local start,finish=horizontal and b[1]or b[2],horizontal and b[3]or b[4]
 for at=start+24,finish-16,64 do
  local blocked=false
  for _,q in ipairs(p.doorways and p.doorways[side]or{})do if at>q[1]-16 and at<q[2]+16 then blocked=true end end
  local pane=side~=3 and math.floor(hash01(at,side,151)*2)==0
  if not blocked and (windows==nil or pane==windows)then
   local frame=math.floor(hash01(at,side,137)*frames)%frames
   local half=windows and 5 or 16*.5*.62;local y=p.height-9;local halfH=windows and 5.6 or half;local y0,y1=y-halfH,y+halfH
   local line=side==1 and b[2]+.05 or side==3 and b[4]-.05 or side==2 and b[3]-.05 or b[1]+.05
   if horizontal then quad(v,i,{at-half,y1,line},{at+half,y1,line},{at+half,y0,line},{at-half,y0,line},frame/frames,(frame+1)/frames)
   else quad(v,i,{line,y1,at-half},{line,y1,at+half},{line,y0,at+half},{line,y0,at-half},frame/frames,(frame+1)/frames)end
  end
 end
 return v,i
end
local function image(theme)
 local file=theme=='center'and'posters-pokecenter.png'or theme=='shop'and'posters-pokemart.png'or'posters.png'
 if not images[file]then
  local img=assert(V.mod.assets:image('vendor/kanto-first-person/'..file))
  img:setFilter('nearest','nearest');images[file]=img
 end
 return images[file]
end
local paneImage
local function windowImage()
 if paneImage then return paneImage end
 -- Original authored 12x14 KFP frame, cross mullion and pane highlights.
 local W,H=12,14;local d=love.image.newImageData(W,H)
 for y=0,H-1 do for x=0,W-1 do
  if x==0 or y==0 or x==W-1 or y==H-1 or x==math.floor(W/2)or y==math.floor(H/2)then d:setPixel(x,y,.24,.18,.14,1)
  else local t=y/H;local r,g,b=.52+.10*(1-t),.72+.08*(1-t),.88
   if (x+y)%7==0 then r,g,b=.78,.88,.96 end;d:setPixel(x,y,r,g,b,1)
  end
 end end
 paneImage=love.graphics.newImage(d);paneImage:setFilter('nearest','nearest');d:release();return paneImage
end
function M.draw(p,opened,ceiling,nativeMaterial)
 if not V.require('KfpInterior').dressing:get()then return end
 local R=V.require('Voxel3D');local entry=cache[p]
 local key=tostring(p.height)..':'..tostring(p.recessSignature)
 if entry and entry.key~=key then for _,mesh in pairs(entry.meshes)do mesh:release()end;entry=nil end
 if p.cave then
  if not entry then
   local v,i=M.stalactites(p);entry={key=key,meshes={}};if #v>0 then entry.meshes[1]=R.newMesh(v,i)end
   v,i=M.rockCeiling(p);if #v>0 then entry.meshes[2]=R.newMesh(v,i)end;cache[p]=entry
  end
  if ceiling then for _,mesh in pairs(entry.meshes)do R.draw(mesh,nativeMaterial)end end
  return
 end
 local sheet=image(p.theme)
 if not entry then
  entry={key=key,meshes={}};cache[p]=entry
  for side=1,4 do
   local v,i=M.posters(p,side,sheet:getWidth()/16,false);if #v>0 then entry.meshes[side]=R.newMesh(v,i)end
   v,i=M.posters(p,side,1,true);if #v>0 then entry.meshes[side+5]=R.newMesh(v,i)end
  end
  local bv,bi=M.beams(p);if #bv>0 then entry.meshes[10]=R.newMesh(bv,bi)end
  -- Original pendant mesh only hangs from an actual ceiling, with enough
  -- clearance above characters. Never synthesize a floor obstacle or pool.
  if p.height>=40 then local b=p.bounds;local v,i=M.pendant((b[1]+b[3])/2,(b[2]+b[4])/2,p.height);entry.meshes[5]=R.newMesh(v,i)end
 end
 for side=1,4 do if not opened[side]then
  if entry.meshes[side]then R.draw(entry.meshes[side],sheet)end
  if entry.meshes[side+5]then R.draw(entry.meshes[side+5],windowImage())end
 end end
 if ceiling and entry.meshes[10]then R.draw(entry.meshes[10],nativeMaterial)end
 if ceiling and entry.meshes[5]then
  if not white then local d=love.image.newImageData(1,1);d:setPixel(0,0,1,1,1,1);white=love.graphics.newImage(d);d:release()end
  R.draw(entry.meshes[5],white)
 end
end
local lightCache=setmetatable({},{__mode='k'});local glow
function M.lightGeometry(p)
 local v,i={},{};local b=p.bounds
 local function q(a,c,d,e)
  local xmin,xmax=math.min(a[1],c[1],d[1],e[1]),math.max(a[1],c[1],d[1],e[1])
  local zmin,zmax=math.min(a[3],c[3],d[3],e[3]),math.max(a[3],c[3],d[3],e[3])
  for _,hole in ipairs(p.openings or{})do if xmin<hole[3]and xmax>hole[1]and zmin<hole[4]and zmax>hole[2]then return end end
  for _,point in ipairs({a,c,d,e})do point[1]=math.max(b[1],math.min(b[3],point[1]));point[3]=math.max(b[2],math.min(b[4],point[3]))end
  quad(v,i,a,c,d,e,0,1,1)
 end
 -- KFP's 30px narrowing doorway wedge, normalized for native double doors.
 for side,doors in ipairs(p.doorways or{})do for _,door in ipairs(doors)do
  local lo,hi=door[1]+1,door[2]-1;local inset=math.min(2,(hi-lo)/4);local y=.9
  if side==1 then q({lo,y,b[2]},{hi,y,b[2]},{hi-inset,y,b[2]+30},{lo+inset,y,b[2]+30})
  elseif side==3 then q({lo,y,b[4]},{hi,y,b[4]},{hi-inset,y,b[4]-30},{lo+inset,y,b[4]-30})
  elseif side==2 then q({b[3],y,lo},{b[3],y,hi},{b[3]-30,y,hi-inset},{b[3]-30,y,lo+inset})
  else q({b[1],y,lo},{b[1],y,hi},{b[1]+30,y,hi-inset},{b[1]+30,y,lo+inset})end
 end end
 if p.height>=40 then local x,z=(b[1]+b[3])/2,(b[2]+b[4])/2
  q({x-22,.8,z+22},{x+22,.8,z+22},{x+22,.8,z-22},{x-22,.8,z-22})end
 return v,i
end
-- Call after terrain while world depth/projection are active. withEffect
-- restores shader, blending and depth and never writes decorative depth.
function M.drawLights(p)
 if not p or p.cave or not V.require('KfpInterior').dressing:get()then return end
 local R=V.require('Voxel3D');local entry=lightCache[p]
 local key=tostring(p.height)..':'..tostring(p.recessSignature)..':'..tostring(p.openingSignature)
 if entry and entry.key~=key then entry.mesh:release();entry=nil end
 if not entry then local v,i=M.lightGeometry(p);if #v==0 then return end
  entry={key=key,mesh=R.newMesh(v,i)};lightCache[p]=entry end
 if not glow then
  local d=love.image.newImageData(32,32)
  for y=0,31 do for x=0,31 do
   local edge=math.max(0,1-((x-15.5)/16)^2-((y-15.5)/16)^2)
   d:setPixel(x,y,1,.92,.72,edge*edge*.12)
  end end
  glow=love.graphics.newImage(d);glow:setFilter('linear','linear');d:release()
 end
 R.withEffect('add',function()R.draw(entry.mesh,glow)end)
end
return M
