-- FireRed native metatiles, scoped to their PRIMARY/SECONDARY tileset pair.
-- These are presentation recipes, never collision or movement permissions.
-- General tree identifiers also appear in pret/pokefirered metatile_labels.h.
-- Unmapped art is kept flat; never infer a wall from a blocked floor alone.
local V=...
local M={}
local profiles=V and V.require('Gen3InteriorProfiles') or dofile((os.getenv('DS_MOD_PATH') or '.')..'/lib/Gen3InteriorProfiles.lua')
local trees={ [0x00A]=true,[0x00B]=true,[0x00C]=true,[0x00E]=true,[0x00F]=true,[0x013]=true }
for _,start in ipairs({0x014,0x01C,0x024}) do for i=0,3 do trees[start+i]=true end end
local roots={ [0x014]=true,[0x016]=true,[0x024]=true,[0x026]=true }
local roof={0x281,0x282,0x283,0x289,0x28A,0x28B,0x291,0x292,0x293,0x294,
 0x2A8,0x2A9,0x2B0,0x2B1,0x2B3,0x2B4,0x2B5,0x2BD,0x2B8,0x2B9,0x2BB,0x2BC}
local wall={0x298,0x299,0x29A,0x29B,0x29C,0x2A0,0x2A1,0x2A2,0x2A3,0x2A4,
 0x2C0,0x2C1,0x2C2,0x2C3,0x2C4,0x2C5,0x2C8,0x2C9,0x2CB,0x2CC,0x2CD,0x2AC,0x2D0,0x2D8}
local pallet={};for _,id in ipairs(roof)do pallet[id]='roof' end
for _,id in ipairs(wall)do pallet[id]='wall' end
local common,viridian,room={},{},{}
local function add(t,kind,ids)for _,id in ipairs(ids)do t[id]=kind end end
-- Shared General metatiles: Mart, Pokemon Center and the broad civic roof.
-- Confirmed against the engine's composited under/over atlas and map layout.
add(common,'roof',{0x28,0x29,0x2A,0x2B,0x2C,0x2D,0x2F,0x30,0x31,0x32,0x33,
 0x34,0x35,0x36,0x37,0x38,0x39,0x3A,0x3B,0x48,0x49,0x4A,0x4B,
 0x50,0x51,0x52,0x53,0x58,0x59,0x5A,0x5B,0x187,0x188,
 0x141,0x142,0x143,0x149,0x14A,0x14B})
add(common,'wall',{0x40,0x41,0x44,0x45,0x46,0x5C,0x5D,0x5E,0x60,0x61,0x62,
 0x63,0x64,0x65,0x186,0x189,0x18A,0x197,0x198,0x199,0x19F,
 0x150,0x151,0x152,0x153,0x154,0x156,0x158,0x159,0x15A,0x15B,0x15C,0x15E})
add(viridian,'roof',{0x280,0x281,0x282,0x283,0x284,0x288,0x289,0x28A,0x28B,0x28C,
 0x290,0x291,0x292,0x293,0x294,0x2AD,0x2AE,0x2AF})
add(viridian,'wall',{0x298,0x299,0x29A,0x29B,0x29C,0x29D,0x29E,0x2A0,0x2A1,0x2A2,0x2A3,0x2A4,0x2A5,0x2A6,0x2A7})
add(room,'roomWall',{0x20,0x21,0x22,0x28,0x29,0x2A,0x2B,0x2C,0x2D,0x2E,0x2F,
 0x96,0xA6,0xA8,0xAA,0xB4,0xB5,0xC0,0xC1,0xD8,0xD9,
 0x109,0x111,0x119,0x121,0x169,0x171})
local fences={}
local function fence(mid,wood,axis,turn,stop)
 fences[mid]={kind='fence',ground=1,wood=wood,axis=axis,turn=turn,stop=stop}
end
fence(0xE6,true);fence(0xE7,false)
fence(0xE8,true,4,'south');fence(0xE9,true,12,'south')
fence(0xEC,false,4,'south');fence(0xED,false,12,'south')
fence(0xF0,true,4);fence(0xF1,true,12)
fence(0xF2,true,12,nil,true);fence(0xF3,true,4,nil,true)
fence(0xF4,false,4);fence(0xF5,false,12)
fence(0xFC,false,4,'north');fence(0xFD,false,12,'north')
-- Standalone metal endpoints use the opposite hand to their source neighbour.
fence(0xEE,false,4,nil,true);fence(0xEF,false,12,nil,true)
local localProps={
 pallet_town={
  [0x284]={kind='fence',ground=0x285,axis=4,turn='south'},
  [0x287]={kind='fence',ground=0x285,axis=4,turn='south'},
 },
 rom_082d4b54={
  [0x296]={kind='sign',height=12,ground=1},
  [0x308]={kind='fence',ground=0x300,wood=true,material=0x308},
  [0x309]={kind='fence',ground=0x301,wood=true,material=0x308},
  [0x30A]={kind='fence',ground=0x302,wood=true,material=0x308},
 },
 rom_082d4b9c={
  [0x33C]={kind='sign',height=12,ground=0x2E9},
 },
}
local ledges={
 [0x87]={ground=1},[0x97]={ground=0xDC},
 [0xB0]={ground=1,left=true},[0xB1]={ground=1,right=true},
 [0xC0]={ground=0xDC,left=true},[0xC1]={ground=0xDC,right=true},
 [0xC8]={ground=0xDC,left=true},[0xC9]={ground=0xDC,right=true},
}
for _,s in pairs(ledges)do s.kind='ledge' end
-- Native General mountain cap, cliff-face and rounded corner drawings.
-- These are independent of jumpable grass ledges and walkable sand/paths.
local cliffs={}
for _,mid in ipairs({104,105,106,107,108,109,112,113,114,115,117,120,121,122,123,124,125,178,179,180,181,186,187})do cliffs[mid]=true end
local plants={ [4]={kind='flowers',ground=1,height=6},[5]={kind='shrub',ground=1,height=10},
 [0xD]={kind='grass',ground=1,height=4} }
-- Reviewed surfaces are intentionally flat, not missing scenery models.
local surfaces={}
for _,id in ipairs({1,8,9,0x10,0x11,0xD3,0xD4,0xD5,0xDB,0xDC,0xDD,0xE3,0xE4,0xE5,0xD0,0xE0,0x102,0x103,0x104,0x105,0x114,0x115,0x119,0x11C,0x11D,0x125,0x126,0x12A,0x12B,0x12C,0x12D,0x12E,0x130,0x131,0x1D0,0x1D1,0x1D2,0x1D4,0x1D8,0x1D9,0x1DA})do surfaces[id]=true end
-- Viridian Forest uses a separate three-cell tree drawing in its secondary
-- tileset. The trunk metatile owns one model; all canopy cells keep ground.
local forestTrees={}
for _,mid in ipairs({641,648,649,650,654,655,656,657,658,662,664,665,666,670,672,673,674,675,676,677})do forestTrees[mid]=true end
-- Rock wall art shared by the five reviewed cave palettes. Collision is a
-- veto on raised geometry, not the source of its identity: ladders, holes and
-- walkable copies of the cap remain at the native floor level.
local caveWalls={}
for _,id in ipairs({0x288,0x289,0x28A,0x28B,0x28C,0x28E,0x28F,0x290,0x291,0x292,
 0x295,0x298,0x299,0x29A,0x29B,0x29C,0x29D,0x29E,0x29F,0x2A0,0x2A1,0x2A2,0x2A3,0x2A4,0x2A5,0x2A6,0x2A7,
 0x2C3,0x2C4,0x2C5,0x2C6,0x2C7,0x2CE,0x2CF,0x2D7,0x2DF,0x2E3,0x2E4,0x2E5,0x2E6,0x2E7,
 0x2EA,0x2EB,0x2EC,0x2ED,0x2EE,0x2EF,0x2F0,0x2F1})do caveWalls[id]=true end
local caves={rom_082d4bfc=true,rom_082d4df4=true,rom_082d4e0c=true,rom_082d4e24=true,rom_082d501c=true}
local gymWalls={}
for _,id in ipairs({0x280,0x281,0x282,0x286,0x287,0x288,0x28A,0x290,0x291,0x292,
 0x2C1,0x2C5,0x2C6,0x2C7,0x2CD,0x2CE,0x2CF})do gymWalls[id]=true end
function M.of(primary,secondary,mid,behavior,collision)
 -- The native behavior table identifies actual surfable pixels independently
 -- of edition-specific metatile IDs. Keep their original animated artwork.
 if behavior and require('src.core.game3.collision').isSurfable(behavior) then
  return {kind='water',reviewedSurface=true,behavior=behavior}
 end
 if primary=='general' and caves[secondary] and mid>=0x280 then
  if mid==0x282 or mid==0x283 then return {kind='rock',ground=0x281,height=mid==0x282 and 14 or 10} end
  if collision==7 and caveWalls[mid] then
   return {kind='caveWall',height=28,ground=0x281,cap=0x291,side=0x299}
  end
  -- Only known floor/warp artwork is reviewed here. Unlisted cave drawings
  -- remain visible and stay in the coverage backlog.
  local floor=collision~=7 and (mid==0x281 or mid==0x291 or mid>=0x2D0 and mid<=0x305)
  return {kind='flat',reviewedSurface=floor or nil}
 end
 if primary=='building' and profiles[secondary] and (profiles[secondary].surfaces or {})[mid] then
  return {kind='flat',reviewedSurface=true}
 end
 if primary=='building' and profiles[secondary] and profiles[secondary].walls[mid] and collision==7 then
  return {kind='roomWall',ground=profiles[secondary].floor}
 end
 if primary=='building' and secondary=='pewter_gym' then
  if gymWalls[mid] then return {kind='roomWall',ground=mid>=0x2C0 and 0x2C0 or 0x294} end
  if mid==0x2A2 or mid==0x2A3 or mid==0x2A4 then return {kind='rock',ground=0x294,height=14} end
 end
 if primary=='general' and (secondary=='rom_082d4dc4' or secondary=='viridian_forest') and forestTrees[mid] then
  return {kind='tree',ground=1,root=mid==676,spacing=3,anchorX=8,anchorZ=8,treeScale=1.5}
 end
 if primary=='general' then
  if localProps[secondary] and localProps[secondary][mid] then return localProps[secondary][mid]end
  if cliffs[mid] then return {kind='cliff',height=32,ground=1}end
  if fences[mid] or ledges[mid] or plants[mid] then return fences[mid] or ledges[mid] or plants[mid] end
  if trees[mid] then return {kind='tree',root=roots[mid],ground=1} end
  if mid==2 then return {kind='sign',height=12,ground=1} end
  if mid==3 then return {kind='sign',height=12,ground=1} end
  if surfaces[mid] then return {kind='flat',reviewedSurface=true} end
  if common[mid] then return {kind=common[mid],ground=1} end
  if secondary=='viridian_city' and viridian[mid] then return {kind=viridian[mid],ground=1} end
 end
 if secondary=='pallet_town' and pallet[mid] then
  return {kind=pallet[mid],ground=0x296,roofType=mid>=0x2A8 and 'flat' or 'gable'}
 end
 if primary=='building' and (secondary=='pokemon_center' or secondary=='rom_082d4bcc')then
  local corners=secondary=='pokemon_center' and {0x2A0,0x2A8,0x2B0,0x2B8,0x2A6,0x2AE,0x2B6,0x2BE,0x2A1,0x2A2}
   or {0x290,0x291,0x298,0x299,0x2A0,0x2A1,0x2BD,0x2BE}
  for _,tile in ipairs(corners)do if mid==tile then return {kind='interiorFloor',ground=0x281}end end
  if secondary=='pokemon_center' and mid==0x284 or secondary=='rom_082d4bcc' and (mid==0x285 or mid==0x286)then
   return {kind='roomWall',ground=0x281}
  end
 end
 if primary=='building' and secondary=='lab' then
  if mid>=0x68 and mid<=0x6E then return {kind='roomWall',ground=0x289} end
  if mid==0x289 then return {kind='flat',reviewedSurface=true} end
 end
 if primary=='building' and room[mid] then return {kind=room[mid],ground=1} end
 return {kind='flat'}
end
-- Convert a vertical building strip into a facade and its roof profile.
-- The visible artwork's rows stay in order; no duplicate folded furniture.
function M.column(cells,index)
 local c=cells[index];if not c then return end
 local indoor=c.shape.kind=='roomWall'
 local function member(n)return n and not n.prop and n.pair==c.pair and
  (indoor and n.shape.kind=='roomWall' or not indoor and (n.shape.kind=='roof' or n.shape.kind=='wall'))end
 if not member(c) then return end
 local y=c.cy;local first,last=y,y
 while cells[c.cx..':'..(first-1)] do
  local n=cells[c.cx..':'..(first-1)]
  if not member(n) or (not indoor and n.shape.kind=='wall' and cells[c.cx..':'..first].shape.kind=='roof') then break end
  first=first-1
 end
 while cells[c.cx..':'..(last+1)] do
  local n=cells[c.cx..':'..(last+1)]
  if not member(n) or (not indoor and n.shape.kind=='roof' and cells[c.cx..':'..last].shape.kind=='wall') then break end
  last=last+1
 end
 local roofs,walls=0,0
 for row=first,last do local a=cells[c.cx..':'..row];if a.shape.kind=='roof' then roofs=roofs+1 else walls=walls+1 end end
 if not indoor and (roofs==0 or walls==0) then return end
 local top=cells[c.cx..':'..first]
 return {first=first,last=last,roofs=roofs,walls=walls,front=(last+1)*16,back=first*16,height=math.min(walls*16,indoor and 32 or 64),indoor=indoor,
  roofType=top.shape.roofType or 'gable',
  roofInset=top.secondary=='pallet_town' and (top.shape.roofType=='flat' and 12 or 8) or 0}
end
function M.layout(cells)
 local bands={}
 for key,c in pairs(cells)do
  local col=M.column(cells,key)
  c.column=col
  if col then
   if col.indoor then
    -- The north wall is one two-row drawing even when a cabinet consumes
    -- the lower row. Do not stretch its remaining cornice to a whole wall
    -- or move it a cell behind the neighboring window.
    if col.first<=1 and col.last<=1 then col.first=0;col.last=1;col.walls=2 end
    col.height=32;col.front=(col.last+1)*16;col.back=col.front-4
   else
    local k=c.pair..':'..col.first..':'..col.roofType
    local band=bands[k] or {};bands[k]=band
    band[c.cx]=col
   end
  end
 end
 -- Door rows and asymmetric edge trim are artwork, not extra storeys.
 -- Adjoining columns with the same roof edge share an eave and ridge.
 for _,band in pairs(bands)do
  local xs={};for x in pairs(band)do xs[#xs+1]=x end;table.sort(xs)
  local i=1
  while i<=#xs do
   local j=i
   while j<#xs and xs[j+1]==xs[j]+1 do j=j+1 end
   local votes,h,n,front={},0,0,0
   for a=i,j do local col=band[xs[a]]
    votes[col.height]=(votes[col.height] or 0)+1
    if votes[col.height]>n or (votes[col.height]==n and col.height>h)then h,n=col.height,votes[col.height] end
    front=math.max(front,col.front)
   end
   local group={left=xs[i]*16,right=(xs[j]+1)*16,front=front,back=math.huge}
   for a=i,j do group.back=math.min(group.back,band[xs[a]].back)end
   for a=i,j do
    local col=band[xs[a]]
    for y=col.first,col.last do
     local c=cells[xs[a]..':'..y]
     if c.column then c.column.height=h;c.column.front=front;c.column.group=group end
    end
   end
   i=j+1
  end
 end
end
return M
