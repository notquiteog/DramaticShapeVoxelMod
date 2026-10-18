-- A true orbit around the player's upper body: pitching changes both eye
-- and aim instead of leaving a high camera fixed while the player exits frame.
local M={}
function M.showsPlayer(camera)
 return camera.level~=6 and(camera.level~=7 or camera.boomClearance==nil or camera.boomClearance>=48)
end
function M.place(camera,x,z,ground,eyeHeight,lift,solid)
 local yaw,pitch=camera.yaw or 0,camera.pitch or 0
 local dx,dz=math.sin(yaw),-math.cos(yaw)
 local ly=-math.sin(pitch);local flat=math.cos(pitch)
 local y=ground+eyeHeight+(lift or 0)
 if camera.level==6 then
  camera.boomClearance=nil
  return {eye={x,y,z},focus={x+dx*flat*24,y+ly*24,z+dz*flat*24},fov=math.rad(62),curve=0}
 end
 local distance=75*(camera.boomZoom or 1)
 local pivot=y+4
 -- Keep the orbit above the current support plane when looking upward.
 -- This does not alter the selected pitch or any native movement/collision.
 if ly>0 then distance=math.min(distance,math.max(0,(pivot-ground-5)/ly))end
 -- The boom always extends to its full length: it never culls against
 -- walls, terrain or any other geometry. (The Gen 1/2 boom lives in
 -- ThirdPerson.lua and was changed the same way in Release 1.51.0.)
 local shoulder=4*(camera.boomZoom or 1)*(distance/math.max(1,75*(camera.boomZoom or 1)))
 local sx,sz=math.cos(yaw)*shoulder,math.sin(yaw)*shoulder
 return {eye={x-dx*flat*distance+sx,pivot-ly*distance,z-dz*flat*distance+sz},
  focus={x+dx*flat*24+sx,pivot+ly*24,z+dz*flat*24+sz},fov=math.rad(62)}
end
-- Native map cells own occupancy. Connected maps are sampled in their own
-- coordinates; unknown void blocks the boom instead of exposing map backs.
function M.obstacles(map,def,groundAt,collision,indoor)
 local cells={}
 return function(x,y,z)
  local cx,cy=math.floor(x/16),math.floor(z/16)
  local key=cx..':'..cy;local cell=cells[key]
  if not cell then
   local d,nx,ny=def,cx,cy
   local function inside(layout,a,b)return layout and a>=0 and b>=0 and a<(layout.width or 0)and b<(layout.height or 0)end
   if not inside(d and d.midLayout,nx,ny)then
    d=nil
    for _,entry in ipairs(map.world or{})do
     local ax,ay=cx-(entry.ox or 0),cy-(entry.oy or 0)
     if inside(entry.def and entry.def.midLayout,ax,ay)then d,nx,ny=entry.def,ax,ay;break end
    end
   end
   local floor=groundAt(x,z)or 0
   local blocked=not d or d.midLayout:collAt(nx,ny)~=0
   if blocked and d and collision.isSurfable(collision.behaviorOn(d,nx,ny))then blocked=false end
   cell={floor=floor,blocked=blocked,void=not d};cells[key]=cell
  end
  return cell.void or y<cell.floor+5 or cell.blocked and(indoor or y<cell.floor+64)
 end
end
return M
