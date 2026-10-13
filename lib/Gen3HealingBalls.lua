-- Reinterpret the public native heal draw canvas as six closed tray balls.
-- The engine owns placement timing, party count, palette pulses and teardown.
local M={}
local retry=setmetatable({},{__mode="k"})
function M.rows(data,column)
 local last=-1
 -- Disjoint strips avoid the native 8px sprites' 2px horizontal overlap.
 for y=4,21 do for x=10+column*7,13+column*7 do
  local _,_,_,a=data:getPixel(x,y)
  if a>.1 then last=math.max(last,y)end
 end end
 return math.max(0,math.min(3,math.floor((last-6)/4)))
end
function M.append(data,x,y,z,emit)
 local count=0
 for col=0,1 do
  local rows=M.rows(data,col)
  -- Sample the last visible ball: later rows overlap earlier pixels in the
  -- native projection, but all balls share the same animated palette.
  local sx,sy=13+col*6,4+(rows-1)*4
  local function pixel(px,py)
   local u,v=(px+.5)/32,(py+.5)/24
   return {{u,v},{u,v},{u,v},{u,v}}
  end
  for row=0,rows-1 do
   count=count+1
   local cx,cy,cz=x+11.72+col*7.33,y+1.6,z+14.35+row*3.77
   local function point(a,b)
    local r=1.6*math.cos(b)
    return {cx+r*math.cos(a),cy+1.6*math.sin(b),cz+r*math.sin(a)}
   end
   for lat=0,5 do
    local lo=-math.pi/2+lat*math.pi/6;local hi=lo+math.pi/6
    local texture=pixel(sx,sy+(lat>=3 and 2 or 5))
    for lon=0,7 do
     local a=lon*math.pi/4;local b=a+math.pi/4
     emit({point(a,hi),point(b,hi),point(b,lo),point(a,lo)},texture,.9)
    end
   end
  end
 end
 return count
end
function M.canvas(canvas,x,y,z,emit)
 local now=love and love.timer and love.timer.getTime()or os.clock()
 if retry[canvas]and now<retry[canvas]then return false end
 local ok,data=pcall(canvas.newImageData,canvas)
 if not ok or not data then retry[canvas]=now+1;return false end
 retry[canvas]=nil
 M.append(data,x,y,z,emit);data:release()
 return true
end
return M
