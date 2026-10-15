-- Reviewed regional drawings. Only complete blocked rectangles receive solid
-- trees; projected crowns never acquire a trunk on a native walking cell.
-- Source identifiers only: pixels always come from the active native atlas.
local M={}
local function set(ids)local t={};for _,id in ipairs(ids)do t[id]=true end;return t end
local berry=set{0x288,0x289,0x28a,0x290,0x291,0x292,0x298,0x299,0x29a,0x2a0,0x2a1,0x2a2,0x2a3,0x2a4,0x2a5}
local safari=set{0x2f5,0x2f6,0x2f7,0x2fc,0x2fd,0x2fe,0x2ff,0x304,0x305,0x306,0x307,0x30b,0x30c,0x30d,0x30e,0x30f,
 0x318,0x319,0x31a,0x320,0x321,0x322,0x323,0x325,0x326,0x327}
local fallarbor=set{0x204,0x205,0x206,0x207,0x20c,0x20d,0x20e,0x20f,0x26b,0x26c,0x26d,0x26e,0x273,0x274,0x275,0x276}
local ash=set{0x2c0,0x2c1,0x2c2,0x2c3,0x2c4,0x2c5,0x2c6,0x2c7,0x2c8,0x2c9,0x2ca,0x2cb,0x2cc,0x2cd,0x2ce,0x2cf}
local berryRows={{0x288,0x289,0x28a},{0x290,0x291,0x292},{0x2a0,0x2a1,0x2a2},{0x2a3,0x2a4,0x2a5}}
local safariRows={{0x2f5,0x2f6,0x2f7},{0x2fd,0x2fe,0x2ff},{0x305,0x306,0x307},{0x30d,0x30e,0x30f}}
local function eligible(c,root,ids)
 return c and c.primary=='general' and c.pair==root.pair and c.secondary==root.secondary
  and c.collision==7 and not c.boundary and not c.regionalTree and ids[c.mid]
end
local function rectangle(cells,root,ids,x,y,w,d)
 for yy=y,y+d-1 do for xx=x,x+w-1 do
  if not eligible(cells[xx..':'..yy],root,ids)then return false end
 end end
 return true
end
local function nextIs(cells,c,mid,dx)
 local n=cells[(c.cx+(dx or 1))..':'..c.cy]
 return n and n.pair==c.pair and n.mid==mid
end
local function place(cells,root,ids,x,y,w,d,rows,family,ground,palette,trim)
 if not rectangle(cells,root,ids,x,y,w,d)then return false end
 local bounds={x*16,y*16,(x+w)*16,(y+d)*16}
 for yy=y,y+d-1 do for xx=x,x+w-1 do
  local c=cells[xx..':'..yy]
  c.regionalTree=root
  c.shape={kind='tree',root=c==root,ground=ground,treeFamily=family,treeRows=rows,treeTrim=trim or 0,treePalette=palette,
   treeGroundColors=true,modelWidth=w*16-.04,modelDepth=d*16-.04,
   anchorX=(x+w/2-root.cx)*16,anchorZ=(y+d/2-root.cy)*16,treeBounds=bounds}
 end end
 return true
end
function M.prepare(cells,edition)
 local hoenn=edition=='emerald' or edition=='ruby' or edition=='sapphire'
 if not hoenn and edition~='firered' and edition~='leafgreen' then return 0 end
 local list={};for _,c in pairs(cells)do list[#list+1]=c end
 table.sort(list,function(a,b)if a.cy~=b.cy then return a.cy<b.cy end;return a.cx<b.cx end)
 local count=0
 for _,c in ipairs(list)do if c.primary=='general' and c.collision==7 and not c.boundary and not c.regionalTree then
  local x,y=c.cx,c.cy;local made=false
  if not hoenn and c.secondary=='rom_082d5004' and (c.mid==0x289 or c.mid==0x299)then
   -- Dense overlapping crowns repeat every two rows; the isolated tree's
   -- lower crown adds a third. Neither extends across the forest's aisles.
   local below=cells[x..':'..(y+2)]
   local depth=below and below.mid==0x2a1 and 3 or 2
   made=place(cells,c,berry,x-1,y,3,depth,berryRows,'broad',1,'gold',16)
  elseif not hoenn and c.secondary=='rom_082d4b54' then
   -- Water/cliff composite 31B/31C/324 remain untouched. 319 is the
   -- unmodeled northern overlapping crown, 2FE the exposed lower drawing.
   if c.mid==0x319 then made=place(cells,c,safari,x-1,y,3,2,safariRows,'broad',1)
   elseif c.mid==0x2fe then
    made=place(cells,c,safari,x-1,y,3,3,safariRows,'broad',1)
     or place(cells,c,safari,x-1,y,3,2,safariRows,'broad',1)
   end
  elseif hoenn and c.secondary=='fallarbor' and
   (c.mid==0x26d and nextIs(cells,c,0x26e) or c.mid==0x20c and nextIs(cells,c,0x20d)
    or c.mid==0x20e and nextIs(cells,c,0x20f))then
   local red=c.mid==0x20e
   local rows=red and {{0x206,0x207},{0x20e,0x20f}} or {{0x204,0x205},{0x20c,0x20d}}
   local ground=red and 0x279 or 0x218
   made=place(cells,c,fallarbor,x,y-1,2,2,rows,'sapling',ground)
    or place(cells,c,fallarbor,x,y,2,1,rows,'sapling',ground)
  elseif hoenn and c.secondary=='lavaridge' then
   if c.mid==0x2c9 and nextIs(cells,c,0x2c8,-1) and nextIs(cells,c,0x2ca) then
    made=place(cells,c,ash,x-1,y,3,1,{{0x2c0,0x2c1,0x2c2},{0x2c8,0x2c9,0x2ca}},'ash',0x271)
   elseif c.mid==0x2cc or c.mid==0x2cd or c.mid==0x2ce then
    made=place(cells,c,ash,x,y,1,1,{{0x2c4},{0x2cc}},'ash',0x271)
   end
  end
  if made then count=count+1 end
 end end
 -- Remove only verified projected cap artwork above a modeled trunk. Its
 -- ground stays native and it remains walkable; no ownership or collision edit.
 for _,c in ipairs(list)do
  if not hoenn and c.secondary=='rom_082d5004' and c.mid>=0x2a3 and c.mid<=0x2a5 then
   local above=cells[c.cx..':'..(c.cy-1)]
   if above and above.pair==c.pair and above.regionalTree then c.shape={kind='tree',ground=1,root=false}end
  elseif hoenn and c.secondary=='fallarbor' and c.mid>=0x204 and c.mid<=0x207 then
   local below=cells[c.cx..':'..(c.cy+1)]
   if below and below.pair==c.pair and below.regionalTree then c.shape={kind='tree',ground=below.shape.ground,root=false}end
  end
  if hoenn then
  if c.secondary=='lavaridge' and c.mid==0x2c4 and c.collision==0 then
   local root=cells[c.cx..':'..(c.cy+1)]
   if root and root.pair==c.pair and root.regionalTree then c.shape={kind='tree',ground=0x271,root=false}end
  end
  end
 end
 return count
end
return M
