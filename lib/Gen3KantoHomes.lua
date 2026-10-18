-- Exact native Kanto home/school drawings. No imported pixels or map-name
-- assumptions: a changed header or permission keeps its existing renderer.
local M={recipes={}}
local header={};for _,id in ipairs{8,0x20,0x21,0x22,0x2b,0x2c,0x2d,0x2e,0x2f,0x96,0x9c,0x9d,0x184,0x287}do header[id]=true end
local schoolHeader={};for _,id in ipairs{0x283,0x284,0x285,0x286,0x287,0x2a0,0x2a1}do schoolHeader[id]=true end
function M.profile(def,pair)
 local l=def and def.midLayout;if not(l and l.midAt and l.collAt)then return end
 local school=pair=='building__rom_082d4f5c'
 if not school and pair~='player_house'and pair~='house'then return end
 local allowed=school and schoolHeader or header;local floor=school and 0x29e or 1;local found=false;local bedroom=false
 for x=0,def.width-1 do
  local mid=l:midAt(x,0);if not allowed[mid]or l:collAt(x,0)~=7 then return end
  bedroom=bedroom or mid==0x287
 end
 for y=2,def.height-1 do for x=0,def.width-1 do if l:midAt(x,y)==floor then found=true end end end
 if not found then return end
 return {north=school and 15.8 or bedroom and 15.8 or 18.8,floor=floor,
  wall=school and{0x2a0,0x2a8,column=0}or{0x20,0x28},kanto=true}
end
local function add(name,pair,rows,design,ground,permissions,extra)
 local r={name=name,pair=pair,rows=rows,kind='designed',design=design,ground=ground or 1,collisionRows=permissions}
 for k,v in pairs(extra or{})do r[k]=v end;M.recipes[#M.recipes+1]=r
end
for _,pair in ipairs{'player_house','house'}do
 add('kanto_window_'..pair,pair,{{0x21,0x22},{0x29,0x2a}},'fr_home_window',1,{{7,7},{7,7}})
 add('kanto_note_'..pair,pair,{{0x96},{0x9e}},'fr_home_note',1,{{7},{7}})
 add('kanto_map_'..pair,pair,{{0x9c,0x9d},{0xa4,0xa5}},'fr_home_map',1,{{7,7},{7,7}})
 for _,q in ipairs{{'back',0x4b},{'front',0x4e}}do
  add('kanto_seat_'..pair..'_'..q[1],pair,{{q[2]}},'fr_home_seat',0x45,{{0}},
   {kind='chair',walkablePad=true,seat={height=4.8,hips=4,z=9}})
 end
end
local school='building__rom_082d4f5c'
add('school_windows',school,{{0x285,0x286,0x286,0x287},{0x28d,0x28e,0x28e,0x28f},{0x295,0x296,0x296,0x297}},'fr_school_windows',0x29e,{{7,7,7,7},{7,7,7,7},{0,0,0,0}})
add('school_board',school,{{0x283,0x284},{0x28b,0x28c},{0x293,0x294}},'fr_school_board',0x29e,{{7,7},{7,7},{0,0}})
add('school_map',school,{{0x2a0,0x2a1},{0x2a8,0x2a9},{0x295,0x296}},'fr_school_map',0x29e,{{7,7},{7,7},{0,0}})
add('school_books',school,{{0x2a1,0x2a1},{0x29b,0x29c},{0x2a3,0x2a4}},'fr_school_books',0x29e,{{7,7},{7,7},{7,7}})
add('school_teacher_desk',school,{{0x291,0x292},{0x299,0x29a}},'fr_school_desk',0x29e,{{0,0},{7,7}})
add('school_seat',school,{{0x288},{0x290}},'fr_school_seat',0x29e,{{0},{0}},{walkablePad=true})
for _,q in ipairs{{0x281,0x289},{0x282,0x28a}}do
 add('school_plant_'..q[1],school,{{q[1]},{q[2]}},nil,0x29e,{{0},{7}},{kind='plant',h=24,cutout=true})
end
local attached={fr_home_window=true,fr_home_note=true,fr_home_map=true,fr_wall_picture=true,fr_school_windows=true,fr_school_board=true,fr_school_map=true}
function M.attach(p,vertices)
 if not(p.homeWall and p.cy==0)then return end
 local relocate=attached[p.recipe.design]
 if p.recipe.design=='fr_living_tv'then
  relocate=true;for _,q in ipairs(vertices)do if q[2]<22 then relocate=false;break end end
  if relocate then for _,q in ipairs(vertices)do q[3]=q[3]+p.homeWall-23.85+.12 end;return end
 end
 if relocate then for _,q in ipairs(vertices)do q[3]=q[3]+p.homeWall-31.92+.12 end end
end
local permissions={
 ['cabinet@house']={{{7},{0}}},
 ['cabinet@player_house']={{{7},{0}}},
 ['chair_back@house']={{{0}}},
 ['chair_back@player_house']={{{0}}},
 ['chair_front@house']={{{0}}},
 ['chair_front@player_house']={{{0}}},
 ['checked_table@house']={{{7,7},{7,7}}},
 ['checked_table@player_house']={{{7,7},{7,7}}},
 ['common_house_plant@house']={{{0},{7}}},
 ['house_left_plant@player_house']={{{0},{7}}},
 ['house_plant@player_house']={{{0},{7}}},
 ['house_right_plant@player_house']={{{0},{7}}},
 ['kitchen_sink_hob@house']={{{7,7},{0,0}}},
 ['kitchen_sink_hob@player_house']={{{7,7},{0,0}}},
 ['living_cupboard@player_house']={{{7,7},{7,7},{0,0}}},
 ['living_television@player_house']={{{7},{7},{0}}},
 ['neighbor_house_left_plant@house']={{{0},{7}}},
 ['neighbor_house_plant@house']={{{0},{7}}},
 ['neighbor_house_right_plant@house']={{{0},{7}}},
 ['neighbor_living_cupboard@house']={{{7,7},{7,7},{0,0}}},
 ['neighbor_living_television@house']={{{7},{7},{0}}},
 ['neighbor_room_television@house']={{{7,7},{7,7},{0,0}}},
 ['neighbor_wall_picture@house']={{{7},{7}}},
 ['room_bed@player_house']={{{0,0,0},{0,0,0},{0,7,0}}},
 ['room_computer@player_house']={{{7,7},{7,7},{0,0}}},
 ['room_console@player_house']={{{7},{7},{0}}},
 ['room_dresser@player_house']={{{7},{0}}},
 ['room_television@player_house']={{{7,7},{7,7},{0,0}}},
 ['television@house']={{{7,7},{0,0}}},
 ['television@player_house']={{{7,7},{0,0}}},
}
function M.permissions(r,pair)
 if pair~='house'and pair~='player_house'then return r.collisionRows end
 local patterns=permissions[r.name..'@'..pair];return patterns and patterns[1]or r.collisionRows
end
function M.install(recipes)
 -- These complete drawings are shared with Celadon's roof room. Keep one
 -- owner per drawing so a legacy deeper model cannot win a name-order tie.
 for i=#recipes,1,-1 do
  if recipes[i].name:match('^roof_room_')then table.remove(recipes,i)end
 end
 for _,r in ipairs(M.recipes)do recipes[#recipes+1]=r end
end
return M
