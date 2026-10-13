-- Shared Legendary fence detailing, cropped to one native blocked fence cell.
local V=...
local M={}
function M.append(c,emit,body,capTexture)
 local s=c.shape
 if not(s and s.kind=='fence'and c.collision==7 and V.require('CommunityVisuals').customCourtyards())then return false end
 local x,z=c.cx*16,c.cy*16;local vertical=s.axis and not s.turn
 local center=vertical and s.axis or 8
 local stop=s.stop
 -- Cells own half of each neighboring bay; never bridge a walkable opening.
 local function point(a,y,b)
  a=math.max(0,math.min(16,a));b=math.max(6.4,math.min(9.6,b))
  if vertical then return{x+center+(b-8),y,z+a}end
  return{x+a,y,z+b}
 end
 local function quad(a,b,d,e,shade,metal)
  emit({point(unpack(a)),point(unpack(b)),point(unpack(d)),point(unpack(e))},metal and capTexture or body,shade)
 end
 local function box(a,y,b,A,Y,B,metal)
  if A<=0 or a>=16 then return end
  if stop then
   local lo=stop=='south'and 8 or 0;local hi=stop=='south'and 16 or 8
   -- Keep the centered post at an endpoint; clip only projecting rail bays.
   if A-a>3 then a=math.max(a,lo);A=math.min(A,hi);if A<=a then return end end
  end
  quad({a,y,B},{A,y,B},{A,Y,B},{a,Y,B},.89,metal)
  quad({A,y,b},{a,y,b},{a,Y,b},{A,Y,b},.76,metal)
  quad({a,Y,b},{A,Y,b},{A,Y,B},{a,Y,B},.97,metal)
  quad({a,y,b},{a,y,B},{a,Y,B},{a,Y,b},.78,metal)
  quad({A,y,B},{A,y,b},{A,Y,b},{A,Y,B},.86,metal)
  quad({a,y,b},{A,y,b},{A,y,B},{a,y,B},.70,metal)
 end
 local function cap(a,b)
  box(a-1.4,10,b-1.4,a+1.4,10.3,b+1.4,true)
  local low={{a-1.4,10.3,b-1.4},{a+1.4,10.3,b-1.4},{a+1.4,10.3,b+1.4},{a-1.4,10.3,b+1.4}}
  local high={{a-.95,10.75,b-.95},{a+.95,10.75,b-.95},{a+.95,10.75,b+.95},{a-.95,10.75,b+.95}}
  for i=1,4 do local j=i%4+1;quad(low[i],low[j],high[j],high[i],.9)end
  quad(high[1],high[2],high[3],high[4],1)
 end
 local Kit=V.require('LegendaryFenceKit')
 Kit.node(box,cap,8,8,true,false)
 -- Neighbor post lies outside this cell; only the approaching rail half emits.
 Kit.node(box,function()end,-8,8,true,false)
 if s.turn then
  -- Preserve the original bend inside its cell rather than inventing a link.
  local original=vertical;vertical=true;center=s.axis
  stop=s.turn=='north'and'north'or'south'
  Kit.node(box,function()end,8,8,true,false);Kit.node(box,function()end,-8,8,true,false)
  vertical=original
 end
 return true
end
return M
