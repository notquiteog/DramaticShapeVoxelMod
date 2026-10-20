-- Gen 3 does not yet dispatch input.pointer. Read the public LOVE touch
-- snapshot without replacing engine callbacks. A touch belongs to the native
-- overlay/menu or this gesture for its entire life, even if it crosses a pad.
local M={}
function M.new()
 local state={points={}}
 function state:update(touch,overlay,mode,width,height,look,pinch)
  local ok,ids=pcall(function()return touch and touch.getTouches and touch.getTouches()or{}end)
  if not ok then self.points={};self.mode=nil;return end
  local active,free={},{}
  local changed=mode~=self.mode
  for _,id in ipairs(ids)do
   local found,x,y=pcall(touch.getPosition,id)
   if found then
    local previous=self.points[id]
    local claimed=previous and previous.claimed
    if not previous then
     local blocked=overlay and overlay.touches and overlay.touches[id]
     if not blocked and overlay and overlay.active~=false and overlay.enabled~=false and overlay.hitTest then
      local hit,value=pcall(overlay.hitTest,overlay,x,y)
      blocked=not hit or value~=nil
     end
     claimed=mode~=nil and not blocked
    end
    if mode==nil then claimed=false end
    local p={x=x,y=y,claimed=claimed}
    active[id]=p
    if claimed then free[#free+1]={id=id,p=p,old=not changed and previous or nil}end
   end
  end
  -- A pinch never also turns the camera. Both fingers must be the same pair
  -- as last frame; lifting one reseats the survivor without a look jump.
  if #free>=2 and pinch then
   local a,b=free[1],free[2]
   local gap=math.sqrt((a.p.x-b.p.x)^2+(a.p.y-b.p.y)^2)
   if self.pair and self.pair[a.id] and self.pair[b.id] and a.old and b.old then
    local old=math.sqrt((a.old.x-b.old.x)^2+(a.old.y-b.old.y)^2)
    if old>=16 and gap>=16 then pinch(gap/old)end
   end
   self.pair={[a.id]=true,[b.id]=true}
  else
   local a=free[1]
   if a and a.old and not self.pair and look then
    look((a.p.x-a.old.x)/math.max(320,width or 1280),
      (a.p.y-a.old.y)/math.max(240,height or 720))
   end
   self.pair=nil
  end
  self.points,self.mode=active,mode
 end
 return state
end
return M
