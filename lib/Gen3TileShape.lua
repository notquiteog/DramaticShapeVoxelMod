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
function M.of(primary,secondary,mid)
 if primary=='general' then
  if trees[mid] then return {kind='tree',root=roots[mid],ground=1} end
  if mid==2 then return {kind='sign',height=12,ground=1} end
  if mid==3 then return {kind='sign',height=12,ground=1} end
 end
 if secondary=='pallet_town' and pallet[mid] then return {kind=pallet[mid],ground=0x296} end
 return {kind='flat'}
end
-- Convert a vertical building strip into one wall and an arched roof.
-- The visible artwork's rows stay in order; no duplicate folded furniture.
function M.column(cells,index)
 local c=cells[index];if not c or (c.shape.kind~='roof' and c.shape.kind~='wall') then return end
 local y=c.cy;local first,last=y,y
 while cells[c.cx..':'..(first-1)] do
  local n=cells[c.cx..':'..(first-1)]
  if n.pair~=c.pair or (n.shape.kind~='roof' and n.shape.kind~='wall') then break end
  first=first-1
 end
 while cells[c.cx..':'..(last+1)] do
  local n=cells[c.cx..':'..(last+1)]
  if n.pair~=c.pair or (n.shape.kind~='roof' and n.shape.kind~='wall') then break end
  last=last+1
 end
 local roofs,walls=0,0
 for row=first,last do local a=cells[c.cx..':'..row];if a.shape.kind=='roof' then roofs=roofs+1 else walls=walls+1 end end
 if roofs==0 or walls==0 then return end
 return {first=first,last=last,roofs=roofs,walls=walls,front=(last+1)*16,back=first*16,height=walls*16}
end
return M
