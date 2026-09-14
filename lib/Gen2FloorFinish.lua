-- World-aligned 16px floor panels for reviewed interior floor drawings.
-- Spare atlas slots are derived only; source tile IDs and collision stay exact.
local M={}
local profiles={
 TILESET_PLAYERS_HOUSE={tile=1,kind='wood'},
 TILESET_PLAYERS_ROOM={tile=1,kind='wood'},
 TILESET_HOUSE={tile=1,kind='wood'},
 TILESET_LAB={tile=16,kind='tile',color={.70,.72,.68}},
 TILESET_MART={tile=72,kind='tile',color={.73,.72,.65}},
 TILESET_POKECENTER={tile=17,kind='tile',color={.73,.73,.70}},
 TILESET_TRADITIONAL_HOUSE={block=4,kind='tatami'},
 TILESET_FACILITY={block=3,kind='tile',color={.54,.59,.60}},
 TILESET_RADIO_TOWER={block=1,kind='tile',color={.67,.68,.65}},
 TILESET_GAME_CORNER={block=1,kind='tile',color={.66,.67,.63}},
 TILESET_TRAIN_STATION={block=3,kind='tile',color={.57,.63,.66}},
 TILESET_BATTLE_TOWER_INSIDE={block=1,kind='tile',color={.69,.64,.61}},
 TILESET_MANSION={block=3,kind='carpet',color={.47,.40,.29}},
 TILESET_LIGHTHOUSE={block=4,kind='wood'},
 TILESET_GATE={block=1,kind='tile',color={.66,.69,.66}},
 TILESET_POKECOM_CENTER={block=1,kind='tile',color={.61,.67,.73}},
}
M.profiles=profiles
local cache=setmetatable({},{__mode='k'})
function M.forTileset(ts)
 if cache[ts]~=nil then return cache[ts] or nil end
 local profile=profiles[ts.id]
 if not profile then cache[ts]=false;return nil end
 local source={}
 if profile.tile then source[profile.tile]=true else
  local block=ts.blocks and ts.blocks[profile.block+1]
  if not block then return nil end
  for _,tile in ipairs(block) do source[tile]=true end
 end
 local used={}
 for _,block in pairs(ts.blocks or {}) do for _,tile in ipairs(block) do used[tile]=true end end
 for _,frame in ipairs(ts.anim and ts.anim.frames or {}) do
  if frame.tile then used[frame.tile]=true end
 end
 local slots={}
 local capacity=(ts.tilesPerRow or 16)*math.floor((ts.imageHeight or 128)/8)
 -- 96..127 is the existing timber swatch pool; leave it untouched.
 for tile=128,capacity-1 do
  if not used[tile] then slots[#slots+1]=tile;if #slots==4 then break end end
 end
 -- Some interior atlases use almost the entire upper bank (Mansion has
 -- only three free slots). Unused lower-bank art is equally safe, except
 -- the separately reserved timber range and the native animation slots.
 if #slots<4 then
  for tile=0,math.min(95,capacity-1) do
   if not used[tile] and tile~=3 and tile~=20 then
    slots[#slots+1]=tile;if #slots==4 then break end
   end
  end
 end
 if #slots<4 then cache[ts]=false;return nil end
 local finish={profile=profile,source=source,slots=slots,quadrants={}}
 for i,tile in ipairs(slots) do finish.quadrants[tile]=i-1 end
 cache[ts]=finish;return finish
end
function M.tile(map,tile,x,z,h)
 if h~=0 then return tile end
 local f=M.forTileset(map.tileset)
 if not f or not f.source[tile] then return tile end
 return f.slots[(math.floor(z/8)%2)*2+math.floor(x/8)%2+1]
end
function M.color(f,quadrant,x,y)
 x=x+(quadrant%2)*32;y=y+math.floor(quadrant/2)*32
 local p=f.profile
 local n=(math.sin(math.floor(x/2)*12.9+math.floor(y/2)*78.2)*43758.5)%1-.5
 if p.kind=='wood' then
  local row=math.floor(y/16)
  local seam=y%16==0 or (x+(row%2)*32)%64==0
  local v=seam and -.075 or math.sin(x*.21+math.sin(y*.4))*.009+n*.01
  return .48+v,.34+v*.8,.22+v*.55
 elseif p.kind=='tatami' then
  local edge=x<2 or y<2
  local v=edge and -.10 or (x%4==0 and -.025 or n*.012)
  return .48+v,.50+v,.31+v*.6
 else
  local c=p.color
  local seam=p.kind=='tile' and (x==0 or y==0)
  local v=seam and -.055 or n*.008
  return c[1]+v,c[2]+v,c[3]+v
 end
end
return M
