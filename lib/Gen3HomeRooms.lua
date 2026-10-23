-- Complete native header families, not map-name guesses. Unknown/custom
-- headers keep their existing renderer; aliases can reuse the reviewed pair.
local V=...
local M={}
local Route=V and V.require('Gen3RouteRooms')or dofile((os.getenv('DS_MOD_PATH')or'.')..'/lib/Gen3RouteRooms.lua')
local Kanto
local function kanto()
 if not Kanto then Kanto=V and V.require('Gen3KantoHomes')or dofile((os.getenv('DS_MOD_PATH')or'.')..'/lib/Gen3KantoHomes.lua')end
 return Kanto
end
local generic={};for _,m in ipairs{0x205,0x206,0x207,0x268,0x269,0x26e,0x26f,0x286,0x287,0x279,0x27a,0x230,0x278}do generic[m]=true end
local starting={};for _,m in ipairs{0x26e,0x21e,0x21f,0x217,0x252,0x254,0x250,0x256,0x287,0x227,0x20b,0x20c,0x20d,0x208,0x20a,0x20f,0x251}do starting[m]=true end
function M.profile(def,pair)
 local route=Route.profile(def,pair);if route then return route end
 if pair=='player_house'or pair=='house'or pair=='building__rom_082d4f5c'then return kanto().profile(def,pair)end
 local layout=def and def.midLayout
 if not(layout and layout.midAt and layout.collAt and def.width and def.height)then return end
 local permitted,floor,wall,north
 if pair=='building__generic_building'then permitted=generic;floor=0x223;wall={0x205,0x20d};north=15.8
 elseif pair=='building__brendans_mays_house'then
  permitted=starting;floor=0x201;wall={0x26e,0x26e,single=true,singleHeight=12}
  -- Downstairs kitchen cases begin at z=29; upstairs desk cases at z=17.
  -- Match these real backs rather than enclosing an extra empty floor strip.
  north=15.8;for x=0,def.width-1 do if layout:midAt(x,0)==0x21f then north=27.8;break end end
 else return end
 local found=false
 for x=0,def.width-1 do if not permitted[layout:midAt(x,0)]or layout:collAt(x,0)~=7 then return end end
 for y=2,def.height-1 do for x=0,def.width-1 do if layout:midAt(x,y)==floor then found=true end end end
 if not found then return end
 return {north=north,floor=floor,wall=wall,stairs=pair=='building__brendans_mays_house'}
end
local attached={em_start_high_window=true,em_start_window=true,em_start_picture=true,em_start_clock=true,em_home_window=true,em_home_picture=true}
function M.attach(p,vertices)
 Route.attach(p,vertices)
 kanto().attach(p,vertices)
 if p.homeWall and p.cy==0 and attached[p.recipe.design]then
  local shift=p.homeWall-16+.12
  for _,q in ipairs(vertices)do q[3]=q[3]+shift end
 end
end
-- Native header columns have their own front/side/back surfaces in front of
-- the room shell. Subtract the same stair aperture from every column face;
-- moving a new frame flush without this cut leaves wallpaper over its trim.
function M.stairWallFace(profile,q,uv,shade,emit)
 local doors=profile and profile.homeFinish and profile.homeFinish.stairs and profile.doorways and profile.doorways[1]
 if not doors or #doors==0 then emit(q,uv,shade);return end
 local lo,hi={math.huge,math.huge,math.huge},{-math.huge,-math.huge,-math.huge}
 for _,v in ipairs(q)do for k=1,3 do lo[k]=math.min(lo[k],v[k]);hi[k]=math.max(hi[k],v[k])end end
 local axes={};for k=1,3 do if hi[k]-lo[k]>1e-7 then axes[#axes+1]=k end end
 assert(#axes==2,'native wall face must be an axis-aligned quad')
 local cuts={{lo[1],hi[1]},{lo[2],hi[2]},{lo[3],hi[3]}}
 local height=math.min(30,profile.height-4)
 for _,door in ipairs(doors)do for _,x in ipairs(door)do if x>lo[1]and x<hi[1]then cuts[1][#cuts[1]+1]=x end end end
 if height>lo[2]and height<hi[2]then cuts[2][#cuts[2]+1]=height end
 for _,a in ipairs(axes)do table.sort(cuts[a])end
 local a,b=axes[1],axes[2]
 for i=1,#cuts[a]-1 do for j=1,#cuts[b]-1 do
  local lower,upper={lo[1],lo[2],lo[3]},{hi[1],hi[2],hi[3]}
  lower[a],upper[a]=cuts[a][i],cuts[a][i+1];lower[b],upper[b]=cuts[b][j],cuts[b][j+1]
  local x,y=(lower[1]+upper[1])/2,(lower[2]+upper[2])/2
  local hole=false
  for _,door in ipairs(doors)do if x>=door[1]-1e-7 and x<=door[2]+1e-7 and y<height-1e-7 then hole=true;break end end
  if not hole and upper[a]-lower[a]>1e-7 and upper[b]-lower[b]>1e-7 then
   local vertices,tex={},{}
   for _,original in ipairs(q)do
    local v={lo[1],lo[2],lo[3]}
    for _,axis in ipairs(axes)do v[axis]=math.abs(original[axis]-lo[axis])<1e-7 and lower[axis]or upper[axis]end
    local u,t=0,0
    for k,corner in ipairs(q)do
     local weight=1
     for _,axis in ipairs(axes)do local f=(v[axis]-lo[axis])/(hi[axis]-lo[axis]);weight=weight*(math.abs(corner[axis]-lo[axis])<1e-7 and 1-f or f)end
     u=u+uv[k][1]*weight;t=t+uv[k][2]*weight
    end
    vertices[#vertices+1]=v;tex[#tex+1]={u,t}
   end
   emit(vertices,tex,shade)
  end
 end end
end
return M
