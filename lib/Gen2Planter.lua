-- Rounded pots with overlapping broad leaf planes. Positions are local to the
-- complete source drawing; every colour comes from that plant's own atlas.
local M={}
function M.build(t,data,perRow,aw,ah)
 local width,height=#t.tiles[1]*8,#t.tiles*8
 local leaf,pot={},{}
 for y=0,height-1 do for x=0,width-1 do
  local tile=t.tiles[math.floor(y/8)+1][math.floor(x/8)+1]
  local ax,ay=tile%perRow*8+x%8,math.floor(tile/perRow)*8+y%8
  local r,g,b,a=data:getPixel(ax,ay)
  local tone=(r+g+b)/3
  if a>.5 and tone>.12 and tone<.83 then
   local group=y<height-8 and leaf or pot
   group[#group+1]={(ax+.5)/aw,(ay+.5)/ah,tone}
  end
 end end
 if #leaf==0 then leaf=pot end
 if #pot==0 then pot=leaf end
 if #leaf==0 then return {} end
 table.sort(pot,function(a,b)return a[3]<b[3] end)
 local function shade(group,n)return group[(n-1)%#group+1] end
 local out={}
 local function q(a,b,c,d,uv,light)
  out[#out+1]={a,b,c,d,uv={{uv[1],uv[2]},{uv[1],uv[2]},
    {uv[1],uv[2]},{uv[1],uv[2]}},shade=light or 1}
 end
 local cx,cz=width*.5,height-8
 local radius=math.min(4.8,width*.32)
 local function p(r,y,i)
  local a=i*math.pi/5
  return {cx+r*math.cos(a),y,cz+r*math.sin(a)}
 end
 for i=0,9 do
  local n=i+1
  q(p(radius*.72,0,i),p(radius*.72,0,n),p(radius,6,n),p(radius,6,i),shade(pot,math.ceil(#pot*.6)),.82+i%3*.06)
  q(p(radius,6,i),p(radius,6,n),p(radius*.80,6,n),p(radius*.80,6,i),shade(pot,math.ceil(#pot*.85)),1)
  q({cx,5.6,cz},p(radius*.8,5.6,i),p(radius*.8,5.6,n),{cx,5.6,cz},pot[1],.6)
  q({cx,0,cz},p(radius*.72,0,n),p(radius*.72,0,i),{cx,0,cz},pot[1],.7)
 end
 local rise=height<=16 and 9 or 21
 local stemTop=6+rise*.72
 for i=0,3 do
  local a,b=i*math.pi/2,(i+1)*math.pi/2
  q({cx+math.cos(a)*.45,5.6,cz+math.sin(a)*.45},
    {cx+math.cos(b)*.45,5.6,cz+math.sin(b)*.45},
    {cx+math.cos(b)*.22,stemTop,cz+math.sin(b)*.22},
    {cx+math.cos(a)*.22,stemTop,cz+math.sin(a)*.22},pot[1],.8)
 end
 for i=1,18 do
  local a=i*2.39996323
  local dx,dz=math.cos(a),math.sin(a)
  local spread=math.min(width*.45,6.8)*(.65+(i%3)*.16)
  local base=6+(i%6)*rise*.13
  local tip=base+rise*(.27+(i%4)*.05)
  local half=1.7+(i%3)*.3
  q({cx,base,cz},
    {cx+dx*spread*.48-dz*half,tip,cz+dz*spread*.48+dx*half},
    {cx+dx*spread,tip-rise*.13,cz+dz*spread},
    {cx+dx*spread*.48+dz*half,tip+.15,cz+dz*spread*.48-dx*half},
    shade(leaf,i*7),.78+(i%4)*.065)
 end
 return out
end
return M
