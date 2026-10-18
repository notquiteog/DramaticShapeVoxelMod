-- Thickness below native walking decks. Source rows and permissions establish
-- ownership; bridge tops and engine collision/layers stay unchanged.
local M={}
local rows={{0x2ee,0x2ce,0x2e5,0x2e6,0x2ef},{0x2cd,0x2ce,0x2e5,0x2e6,0x2cf}}
local swatches=setmetatable({},{__mode='k'})
function M.material(c,uv)
 local ts,mid=c.ts,c.bridge.material
 local old=swatches[ts]
 if not old or old.source~=ts.imageData or old.over~=ts.overImageData then
  old={source=ts.imageData,over=ts.overImageData,points={}};swatches[ts]=old
 end
 local p=old.points[mid]
 if not p then
  p={4.5,8.5};local best=-math.huge;local slot=ts.midToSlot and ts.midToSlot[mid]
  if slot and ts.imageData then for y=2,13 do for x=2,13 do
   local px,py=slot%ts.cols*16+x,math.floor(slot/ts.cols)*16+y
   local r,g,b,a=ts.imageData:getPixel(px,py)
   if ts.overImageData then local rr,gg,bb,aa=ts.overImageData:getPixel(px,py)
    r,g,b,a=rr*aa+r*(1-aa),gg*aa+g*(1-aa),bb*aa+b*(1-aa),aa+a*(1-aa)
   end
   -- Native pale/yellow boards, excluding the bright green space between
   -- Fortree's slats. Keep texel centres to avoid nearest-filter flicker.
   local score=r+g+b-((x-8)^2+(y-8)^2)*.001
   if a>.99 and r>=g-.04 and g>=b-.04 and score>best then best=score;p={x+.5,y+.5}end
  end end end
  old.points[mid]=p
 end
 local t={uv[1][1]+(uv[2][1]-uv[1][1])*p[1]/16,uv[1][2]+(uv[3][2]-uv[1][2])*p[2]/16}
 return {t,t,t,t}
end
function M.prepare(cells)
 local count=0
 for _,c in pairs(cells)do
  if c.primary=='general' and c.secondary=='fortree' and c.behavior==0x178 and c.collision==0 then
   c.bridge={depth=2.5,material=c.mid};count=count+1
  elseif c.primary=='general' and c.pair=='general__rom_082d4af4' then
   for _,row in ipairs(rows)do if c.mid==row[1]then
    local parts,match={},true
    for i,mid in ipairs(row)do
     local n=cells[(c.cx+i-1)..':'..c.cy]
     if not n or n.pair~=c.pair or n.mid~=mid or n.collision~=((i==1 or i==5)and 7 or 0)then match=false end
     parts[i]=n
    end
    if match then for i,n in ipairs(parts)do
     n.bridge={depth=3,material=row[3],edge=i==1 and 'left'or i==5 and 'right'or nil};count=count+1
    end end
   end end
  end
 end
 return count
end
function M.append(cells,c,emit,uvFor)
 local g=c.bridge;if not g then return end
 local x,z=c.cx*16,c.cy*16;local top=c.base or 0;local bottom=top-g.depth
 local uv=assert(uvFor(c.ts,g.material));local tex=M.material(c,uv)
 -- A closed underside is required even when no crossing is proved beneath.
 emit({{x,bottom,z+16},{x+16,bottom,z+16},{x+16,bottom,z},{x,bottom,z}},tex,.62)
 for _,d in ipairs{{-1,0},{1,0},{0,-1},{0,1}}do
  local n=cells[(c.cx+d[1])..':'..(c.cy+d[2])]
  if not n or not n.bridge or math.abs((n.base or 0)-top)>.01 then
   local a,b=x+(d[1]>0 and 16 or 0),z+(d[2]>0 and 16 or 0)
   local r,f=a+(d[1]==0 and 16 or 0),b+(d[2]==0 and 16 or 0)
   emit({{a,top,b},{r,top,f},{r,bottom,f},{a,bottom,b}},tex,.8)
  end
 end
 if g.edge then
  -- The source rail is wholly inside its native blocked side tile.
  local left=g.edge=='left';local a=x+(left and 12 or 0);local b=a+4
  local function box(n,f,h)
   emit({{a,top+h,n},{b,top+h,n},{b,top+h,f},{a,top+h,f}},tex,1)
   emit({{a,top+h,f},{b,top+h,f},{b,top,f},{a,top,f}},tex,.8)
   emit({{b,top+h,n},{a,top+h,n},{a,top,n},{b,top,n}},tex,.72)
   emit({{a,top+h,n},{a,top+h,f},{a,top,f},{a,top,n}},tex,.78)
   emit({{b,top+h,f},{b,top+h,n},{b,top,n},{b,top,f}},tex,.88)
  end
  box(z,z+16,3);box(z+6,z+10,8)
 end
 return true
end
return M
