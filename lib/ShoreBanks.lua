-- Vertical bank closure on the exact original land/water tile boundary.
-- The land top, source cells, collision and native bridge underpass remain
-- authoritative. Vertices are absolute world coordinates; do not lift twice.
local M={}
local directions={{-1,0},{1,0},{0,-1},{0,1}}
local function wet(c)
 local s=c and c.shape
 return s and(s.kind=='water'or s.kind=='rock'and(s.seaRock or s.wetRock))
end
function M.skipRiser(c,n)return wet(n)or false end
function M.material(c)
 local s=c.shape
 return s.retaining or s.ground or((s.kind=='ground'or s.kind=='flat'or s.kind=='interiorFloor')and c.mid or nil)
end
function M.edges(cells,c,surface)
 if not c or not c.shape or wet(c)or c.bridge or c.stairs or c.shape.kind=='steps'
  or c.shape.kind=='ladder'or c.floor and c.floor.underpass then return{}end
 local out={};local x,z=c.cx*16,c.cy*16;local top=c.base or 0
 for _,d in ipairs(directions)do
  local n=cells[(c.cx+d[1])..':'..(c.cy+d[2])]
  if wet(n)and not n.bridge and not(n.floor and n.floor.underpass)then
   local bottom=surface(n)
   if type(bottom)=='number'and bottom<top-.001 then
    local ax,az=x+(d[1]>0 and 16 or 0),z+(d[2]>0 and 16 or 0)
    local bx,bz=ax+(d[1]==0 and 16 or 0),az+(d[2]==0 and 16 or 0)
    out[#out+1]={vertices={{ax,bottom,az},{bx,bottom,bz},{bx,top,bz},{ax,top,az}},
     direction=d,top=top,bottom=bottom,land=c,water=n}
   end
  end
 end
 return out
end
-- material(c,edge) optionally supplies a reviewed native land/retaining donor.
-- No water artwork or a claimed prop facade is substituted for missing soil.
function M.append(cells,c,emit,uvFor,surface,material)
 local edges=M.edges(cells,c,surface);local count=0
 for _,edge in ipairs(edges)do
  local mid=material and material(c,edge)or M.material(c)
  local uv=mid and uvFor(c.ts,mid)
  if uv then emit(edge.vertices,uv,.78);count=count+1 end
 end
 return count
end
return M
