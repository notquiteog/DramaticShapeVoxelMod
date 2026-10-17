-- Complete native header families, not map-name guesses. Unknown/custom
-- headers keep their existing renderer; aliases can reuse the reviewed pair.
local M={}
local generic={};for _,m in ipairs{0x205,0x206,0x207,0x268,0x269,0x26e,0x26f,0x286,0x287,0x279,0x27a,0x230,0x278}do generic[m]=true end
local starting={};for _,m in ipairs{0x26e,0x21e,0x21f,0x217,0x252,0x254,0x250,0x256,0x287,0x227,0x20b,0x20c,0x20d,0x208,0x20a,0x20f,0x251}do starting[m]=true end
function M.profile(def,pair)
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
 if p.homeWall and p.cy==0 and attached[p.recipe.design]then
  local shift=p.homeWall-16+.12
  for _,q in ipairs(vertices)do q[3]=q[3]+shift end
 end
end
return M
