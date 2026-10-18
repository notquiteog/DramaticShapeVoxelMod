-- Complete native Kanto gate fixtures. Source art is read from the live atlas;
-- map names, actors, native collision, scripts and warps are never replaced.
local M={recipes={}}
local header={8,0x287,0x298,0x299,0x287,0x287,0x288,0x289,0x28a,0x287,0x287,0x298,0x299,0x287,8}
function M.profile(def,pair)
 local l=def and def.midLayout
 if pair~='house'or not(l and l.midAt and l.collAt)or def.width~=#header then return end
 for x,m in ipairs(header)do if l:midAt(x-1,0)~=m or l:collAt(x-1,0)~=7 then return end end
 -- A source header alone cannot authorize enclosing a custom walking lane.
 for x=1,13 do if l:collAt(x,1)~=(x==7 and 114 or 7)then return end end
 local floor=false;for y=2,def.height-1 do for x=1,13 do if l:midAt(x,y)==0x281 then floor=true end end end
 if not floor then return end
 local footer={[8]=true,[0x2cd]=true,[0x2ce]=true,[0x2cf]=true};local padded=true
 for x=0,def.width-1 do if not footer[l:midAt(x,def.height-1)]or l:collAt(x,def.height-1)~=7 then padded=false;break end end
 return{north=15.8,floor=0x281,wall={0x287,0x28f},kanto=true,routeGate=true,northDoorRows=1,south=(def.height-(padded and 1 or 0))*16}
end
local function add(name,rows,design,permissions,extra)
 local r={name='route_gate_'..name,pair='house',primary='building',rows=rows,kind='designed',design='fr_route_'..design,ground=0x281,collisionRows=permissions}
 for k,v in pairs(extra or{})do r[k]=v end
 if r.kind=='plant'then r.design=nil end
 M.recipes[#M.recipes+1]=r
end
add('window',{{0x298,0x299},{0x2a0,0x2a1},{0x282,0x282}},'window',{{7,7},{7,7},{0,0}})
add('glass_table',{{0x2d6,0x2d7},{0x2de,0x2df}},'glass_table',{{7,7},{7,7}})
for _,mid in ipairs{0x2e6,0x2e7}do add('seat_'..mid,{{mid}},'seat',{{0}},{walkablePad=true})end
for _,q in ipairs{{0x2ea,0x2f1,7},{0x2e9,0x2f1,0},{0x2e8,0x2f0,0}}do
 add('plant_'..q[1],{{q[1]},{q[2]}},'plant',{{q[3]},{7}},{kind='plant',h=24,cutout=true})
end
-- Trim the padded black footer while carrying the complete red mat into the
-- final native walking row. The full source context protects custom layouts.
add('exit_mat',{{0x2c5,0x2c6,0x2c7},{0x2cd,0x2ce,0x2cf}},'exit_mat',{{0,114,0},{7,7,7}},{walkablePad=true})
function M.install(recipes)
 -- Reviewed permission-aware drawings replace the former unguarded aliases.
 for i=#recipes,1,-1 do local r=recipes[i]
  if r.pair=='house'and(r.name=='gate_plant_744'or r.name=='gate_plant_745')then table.remove(recipes,i)end
 end
 for _,r in ipairs(M.recipes)do recipes[#recipes+1]=r end
end
function M.attach(p,vertices)
 if p.homeWall and p.cy==0 and p.recipe.design=='fr_route_window'then
  for _,q in ipairs(vertices)do q[3]=q[3]+p.homeWall-31.92+.12 end
 end
end
function M.draw(id,A)
 local B,S,T=A.box,A.source,A.sample
 local function top(r,l,n,rr,s,h)S(r[1],r[2],r[3],r[4],{l,h,n},{rr,h,n},{rr,h,s},{l,h,s})end
 if id=='fr_route_window'then
  local rim=T(3,11);local dark=T(4,16)
  B(1,12,31.92,31,29,32.25,dark)
  B(1,12,32.25,2,29,32.55,rim);B(30,12,32.25,31,29,32.55,rim)
  B(1,28,32.25,31,29,32.55,rim);B(1,12,32.25,31,13,32.7,rim)
  S(2,10,28,14,{2,28,32.3},{30,28,32.3},{30,13,32.3},{2,13,32.3})
  B(15.7,13,32.3,16.3,28,32.55,rim)
 elseif id=='fr_route_glass_table'then
  local rim,dark=T(4,3),T(1,23);local glass=T(14,12)
  -- Four visible supports, a closed underside, rounded/chamfered corners,
  -- and the source's continuous blue glass reflected across the tabletop.
  for _,x in ipairs{4,25}do for _,z in ipairs{4,25}do B(x,0,z,x+3,10,z+3,dark)end end
  B(4,9,1,28,11,31,rim);B(1,9,4,31,11,28,rim)
  B(4,10,3,28,11.4,29,glass);B(3,10,4,29,11.4,28,glass)
  top({4,3,24,25},4,3,28,29,11.42)
 elseif id=='fr_route_seat'then
  -- Native stools are fully walkable: retain their cushion as a low pad.
  B(3,0,3,13,.6,14,T(1,12));top({3,3,10,10},3,3,13,14,.62)
 elseif id=='fr_route_exit_mat'then
  B(10,0,.2,38,.1,15.8,T(14,8));top({10,4,28,16},10,.2,38,15.8,.12)
 else return false end
 return true
end
function M.append(p,source,box,sample,emit)
 if not(p.recipe.design and p.recipe.design:match('^fr_route_'))or p.recipe.kind=='plant'then return false end
 local x,z=p.cx*16,p.cy*16
 local function point(q)return{x+q[1],q[2],z+q[3]}end
 return M.draw(p.recipe.design,{sample=sample,
  box=function(l,b,n,r,h,f,uv)box(x+l,b,z+n,x+r,h,z+f,uv);emit({{x+l,b,z+f},{x+r,b,z+f},{x+r,b,z+n},{x+l,b,z+n}},uv,.65)end,
  source=function(sx,sy,w,h,a,b,c,d)source(sx,sy,w,h,point(a),point(b),point(c),point(d))end})
end
return M
