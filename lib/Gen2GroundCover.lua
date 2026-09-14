-- Sparse, low meadow blades; authored encounter grass and paths stay intact.
local M={}
local grass={TILESET_JOHTO=5,TILESET_JOHTO_MODERN=5,TILESET_FOREST=5,
  TILESET_PARK=1,TILESET_KANTO=44,TILESET_BATTLE_TOWER_OUTSIDE=5}
function M.append(map,x,z,h,tile,emit,uvRect,shade)
  if h~=0 or tile~=grass[map.tileset.id] then return end
  local function rand(s)
    local n=math.sin(x*12.9898+z*78.233+s*31.13)*43758.5453
    return n-math.floor(n)
  end
  if rand(1)>.23 then return end
  local cx,cz=x+2+rand(2)*4,z+2+rand(3)*4
  local u0,u1,v0,v1=uvRect(tile,0,8)
  for i=1,5 do
    local a=rand(i+10)*math.pi*2
    local dx,dz=math.cos(a),math.sin(a)
    local bx,bz=cx+dx*.65,cz+dz*.65
    local height=.65+rand(i+20)*1.3
    local half=.16+rand(i+30)*.12
    -- A bent tapered blade is two triangles, bounded within its grass tile.
    emit({{bx-dz*half,.025,bz+dx*half},{bx+dz*half,.025,bz-dx*half},
      {bx+dx*.6,height,bz+dz*.6},{bx+dx*.32,height*.65,bz+dz*.32}},
      {{u0,v1},{u1,v1},{u1,v0},{u0,v0}},shade)
  end
end
return M
