-- Reviewed laboratory headers and native fixtures. Presentation only: engine
-- collision, interaction cells, scripts and HD-2D actors remain authoritative.
local M={recipes={}}
local profiles={
 oak_lab={header={0x29d,0x6d,0x6d,0x6e,0x69,0x69,0x28d,0x28d,0x98,0x6b,0x6c,0x6b,0x6c},floor=0x289,wall={0x69,0x69,single=true}},
 ['building__lab']={header={0x210,0x211,0x208,0x212,0x213,0x208,0x208,0x209,0x209,0x208,0x208,0x208,0x208},floor=0x202,wall={0x208,0x20a}},
}
function M.profile(def,pair)
 local p=profiles[pair];local l=def and def.midLayout
 if not(p and l and l.midAt and l.collAt and def.width==#p.header and def.height)then return end
 for x,m in ipairs(p.header)do if l:midAt(x-1,0)~=m or l:collAt(x-1,0)~=7 then return end end
 local found=false;for y=2,def.height-1 do for x=0,def.width-1 do if l:midAt(x,y)==p.floor then found=true end end end
 if not found then return end
 local south=def.height*16
 if pair=='oak_lab'then
  -- The final native drawing row contains only black sprite padding and
  -- the mat's perspective footer. It is outside the playable room.
  local footer={[8]=true,[0x298]=true,[0x299]=true,[0x29a]=true};local padded=true
  for x=0,def.width-1 do if not footer[l:midAt(x,def.height-1)]or l:collAt(x,def.height-1)~=7 then padded=false;break end end
  if padded then south=south-16 end
 end
 return {north=15.8,south=south,floor=p.floor,wall=p.wall}
end
local function add(name,rows,design,permissions,extra)
 local r={name=name,pair='building__lab',primary='building',family='rse',kind='designed',ground=0x202,rows=rows,design=design,collisionRows=permissions}
 for k,v in pairs(extra or{})do r[k]=v end;M.recipes[#M.recipes+1]=r
end
for _,mid in ipairs{0x20c,0x20d}do
 add('birch_wall_note_'..mid,{{0x209},{mid}},'em_lab_wall_note',{{7},{7}},{claimCells={['1:1']=true}})
end
for _,mid in ipairs{0x241,0x239,0x249}do
 add('birch_native_seat_'..mid,{{mid}},'em_lab_seat_pad',{{0}},{walkablePad=true})
end
M.recipes[#M.recipes+1]={name='oak_native_exit_mat',pair='oak_lab',primary='building',kind='designed',design='fr_lab_exit_mat',ground=0x289,
 rows={{0x290,0x291,0x292},{0x298,0x299,0x29a}},collisionRows={{0,114,0},{7,7,7}},walkablePad=true}
function M.attach(p,vertices)
 if not(p.researchWall and p.cy==0)then return end
 local shift
 if p.recipe.name=='lab_wall_display'then shift=p.researchWall-30.7+.12
 elseif p.recipe.design=='em_lab_wall_note'then shift=p.researchWall-31.92+.12 end
 if shift then for _,q in ipairs(vertices)do q[3]=q[3]+shift end end
end
local permissions={
 ['birch_books']={{7,7},{7,7},{7,0}},
 ['birch_computer']={{7,7},{7,7},{0,0}},
 ['birch_east_book_stacks']={{7},{7},{7}},
 ['birch_east_small_desk']={{7},{0}},
 ['birch_emerald_book_stack_562']={{7}},
 ['birch_emerald_book_stack_666']={{7}},
 ['birch_floor_plant']={{7}},
 ['birch_free_books']={{0,0},{7,7},{7,7}},
 ['birch_free_books_end']={{0,0},{7,7},{7,7}},
 ['birch_machine']={{7,7},{7,7},{0,0}},
 ['birch_plant']={{7},{7}},
 ['birch_research_desk']={{7,7,7,7},{0,0,0,0}},
 ['birch_server']={{0},{7},{0}},
 ['birch_side_cupboard']={{0},{7}},
 ['birch_south_book_stacks']={{7},{7}},
 ['birch_south_workstation']={{7},{7},{7}},
 ['birch_southeast_workstation']={{7},{7},{7}},
 ['birch_starter_desk']={{0,0},{7,7}},
 ['lab_aquarium']={{7},{7}},
 ['lab_books_left']={{7},{0}},
 ['lab_books_right']={{7},{0}},
 ['lab_books_free_left']={{0},{7},{0}},
 ['lab_books_free_corner']={{0},{7},{0}},
 ['lab_books_free_right']={{0},{7},{0}},
 ['lab_complete_books']={{7,7},{0,0}},
 ['lab_computer']={{7,7},{0,0}},
 ['lab_free_books']={{0,0},{7,7},{0,0}},
 ['lab_plant_left']={{0},{7}},
 ['lab_plant_right']={{0},{7}},
 ['lab_pokedex_desk']={{7,7},{0,0}},
 ['lab_pokemon_machine']={{0,0},{7,7},{7,7}},
 ['lab_server']={{7},{7},{0}},
 ['lab_side_terminal']={{7}},
 ['lab_terminal']={{7},{7},{0}},
 ['lab_wall_display']={{7},{130}},
 ['lab_work_table']={{7,7,7},{0,0,0}},
}
function M.permissions(r,pair)
 if pair=='oak_lab'or pair=='building__lab'then return permissions[r.name]or r.collisionRows end
end
function M.install(recipes)
 for _,r in ipairs(recipes)do
  if r.name=='lab_aquarium'then r.design='fr_lab_aquarium'
  elseif r.name=='lab_pokedex_desk'then r.design='fr_lab_pokedex_desk';r.supportOffset=0;r.supportRows=1
  elseif r.name=='lab_work_table'then r.design='fr_lab_starter_table';r.footprintDepth=15;r.supportOffset=0;r.h=9.6
  elseif r.name=='birch_free_books'or r.name=='birch_free_books_end'then r.design='em_lab_free_books'
  end
 end
 for _,r in ipairs(M.recipes)do recipes[#recipes+1]=r end
end
return M
