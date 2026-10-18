-- Predict one connected-map entry without changing the native active world.
-- All inputs are public map definitions; no warps, collision or scripts run.
local M={}
local function size(def)local l=def and def.midLayout;if l then return l.width,l.height end end
local directions={up='north',down='south',left='west',right='east'}
-- A twelve-cell overlap amortizes a complete scene rebuild while running.
-- The extra strip is behind the configured distance fade; the player's full
-- requested radius stays inside the snapshot throughout its window.
local windowStep=12
function M.window(px,pz,radius)
 local x,z=math.floor(px/(16*windowStep))*windowStep,math.floor(pz/(16*windowStep))*windowStep
 return x-radius,z-radius,x+radius+windowStep,z+radius+windowStep
end
-- Native crossings briefly leave the player one cell outside the new map.
-- Keep an already-complete return scene through that interpolation only.
function M.interpolating(def,px,pz)
 local w,h=size(def);if not w then return false end
 local x,z=px/16,pz/16
 return (x>=-1 and x<0 or x>=w and x<w+1)and z>=0 and z<h
  or (z>=-1 and z<0 or z>=h and z<h+1)and x>=0 and x<w
end
function M.entry(def,connections,maps,px,pz,reach,heading)
 local w,h=size(def);if not w then return end
 local x,z=px/16,pz/16
 local best,distance,preferred
 local toward=directions[heading] or heading
 for _,n in ipairs(connections)do
  local target=maps[n.map];local tw,th=size(target);local off=n.offset or 0
  if tw then
   local d,tx,tz
   if n.dir=='north' and x>=off and x<off+tw then d,tx,tz=z,x-off,th-1
   elseif n.dir=='south' and x>=off and x<off+tw then d,tx,tz=h-1-z,x-off,0
   elseif n.dir=='west' and z>=off and z<off+th then d,tx,tz=x,tw-1,z-off
   elseif n.dir=='east' and z>=off and z<off+th then d,tx,tz=w-1-x,0,z-off end
   local facing=n.dir==toward
   if d and d>=0 and d<=(reach or 24)and(not distance or facing and not preferred or facing==preferred and d<distance)then
    best={id=n.map,def=target,px=tx*16,pz=tz*16,distance=d};distance=d;preferred=facing
   end
  end
 end
 return best
end
-- Match native worldMidAt's primary/direct-direction/world/border precedence.
function M.sample(def,direct,world,x,y)
 local l=def.midLayout;local w,h=l.width,l.height;local pair=l.pair or def.pair
 if x>=0 and y>=0 and x<w and y<h then return l:midAt(x,y),pair end
 local function from(dir)
  for _,n in ipairs(direct)do if n.dir==dir then
   local a=n.def.midLayout;local xx,yy=x,y;local off=n.offset or 0
   if dir=='north'then xx,yy=x-off,a.height+y
   elseif dir=='south'then xx,yy=x-off,y-h
   elseif dir=='west'then xx,yy=a.width+x,y-off
   else xx,yy=x-w,y-off end
   if xx>=0 and yy>=0 and xx<a.width and yy<a.height then return a:midAt(xx,yy),a.pair or pair end
  end end
 end
 if y<0 or y>=h then local mid,p=from(y<0 and'north'or'south');if mid~=nil then return mid,p end end
 if x<0 or x>=w then local mid,p=from(x<0 and'west'or'east');if mid~=nil then return mid,p end end
 for _,r in ipairs(world)do
  local a=r.def.midLayout;local xx,yy=x-r.ox,y-r.oy
  if r.def~=def and xx>=0 and yy>=0 and xx<a.width and yy<a.height then return a:midAt(xx,yy),a.pair or pair end
 end
 return l:midAt(x,y),pair,true
end
-- Native connections interpolate across the outside edge before settling in
-- its first cell. Adjacent quantized windows are safe to retain while the next
-- window streams, but never reuse another map, changed atlas or distant warp.
function M.accept(candidate,req)
 if candidate.sceneDef~=req.def or not candidate.distance then return false end
 local d=candidate.distance;local b=d.bounds
 if d.radius~=req.radius or d.full~=(not req.budget)then return false end
 if b[3]-b[1]~=req.x1-req.x0 or b[4]-b[2]~=req.z1-req.z0 then return false end
 local want={req.x0,req.z0,req.x1,req.z1}
 for i=1,4 do if math.abs(b[i]-want[i])>windowStep then return false end end
 local function content(key)return key and key:match('^[^;]*;[^;]*;[^;]*;[^;]*;(.*)$')end
 local a=content(candidate.terrainKey)
 return a~=nil and a==content(req.key)
end
return M
