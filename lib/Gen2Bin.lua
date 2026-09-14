-- A tapered metal bin with a thick rim, recessed interior and closed base.
-- Sample neutral tones from its own source drawing, never bookshelf stripes.
local M={}
function M.build(t,data,perRow,aw,ah)
 local tones={}
 for ry,row in ipairs(t.tiles) do for rx,tile in ipairs(row) do
  for y=0,7 do for x=0,7 do
   local sx,sy=tile%perRow*8+x,math.floor(tile/perRow)*8+y
   local r,g,b,a=data:getPixel(sx,sy)
   if a>0 then tones[#tones+1]={value=(r+g+b)/3,u=(sx+.5)/aw,v=(sy+.5)/ah} end
  end end
 end end
 table.sort(tones,function(a,b)return a.value<b.value end)
 local function tone(f)return tones[math.max(1,math.floor(#tones*f))] end
 local dark,metal,light=tone(.05),tone(.50),tone(.85)
 local quads={}
 local function q(a,b,c,d,color,shade)
  local uv={color.u,color.v}
  quads[#quads+1]={a,b,c,d,uv={uv,uv,uv,uv},shade=shade or 1}
 end
 local function p(radius,y,i)
  local a=i*math.pi/5
  return {8+radius*math.cos(a),y,8+radius*math.sin(a)}
 end
 for i=0,9 do
  local j=i+1
  q(p(4.3,0,i),p(4.3,0,j),p(5.8,10,j),p(5.8,10,i),metal,.78+.16*math.cos(i*math.pi/5))
  q(p(5.8,10,i),p(5.8,10,j),p(4.8,10,j),p(4.8,10,i),light)
  q(p(4.8,10,i),p(4.8,10,j),p(3.5,2,j),p(3.5,2,i),dark,.65)
  q({8,2,8},p(3.5,2,i),p(3.5,2,j),{8,2,8},dark,.55)
  q({8,0,8},p(4.3,0,j),p(4.3,0,i),{8,0,8},metal,.6)
 end
 return quads
end
return M
