-- FireRed native metatiles, scoped to their PRIMARY/SECONDARY tileset pair.
-- These are presentation recipes, never collision or movement permissions.
-- General tree identifiers also appear in pret/pokefirered metatile_labels.h.
-- Unmapped art is kept flat; never infer a wall from a blocked floor alone.
local M={}
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
function M.of(primary,secondary,mid)
 if primary=='general' then
  if trees[mid] then return {kind='tree',root=roots[mid],ground=1} end
  if mid==2 then return {kind='sign',height=12,ground=1} end
  if mid==3 then return {kind='sign',height=12,ground=1} end
  if common[mid] then return {kind=common[mid],ground=1} end
  if secondary=='viridian_city' and viridian[mid] then return {kind=viridian[mid],ground=1} end
 end
 if secondary=='pallet_town' and pallet[mid] then
  return {kind=pallet[mid],ground=0x296,roofType=mid>=0x2A8 and 'flat' or 'gable'}
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
    col.height=32;col.front=(col.first+2)*16
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
   for a=i,j do
    local col=band[xs[a]]
    for y=col.first,col.last do
     local c=cells[xs[a]..':'..y]
     if c.column then c.column.height=h;c.column.front=front end
    end
   end
   i=j+1
  end
 end
end
return M
