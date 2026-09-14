-- Rocky islands keep their walkable top at the engine's ground height. The
-- drawn coastal edge becomes a sloping rock surface descending into the sea,
-- rather than a square slab with the original edge picture stretched down it.
local M={}
local edges={ [43]={w=true,n=true},[44]={n=true},[45]={e=true,n=true},
  [59]={w=true},[61]={e=true},[75]={w=true,s=true},[76]={s=true},[77]={e=true,s=true} }
local function key(x,y)return (y+64)*4096+x+64 end
function M.build(S,map)
  if not S.gen2 or (map.tileset.id~="TILESET_JOHTO" and map.tileset.id~="TILESET_JOHTO_MODERN") then return end
  local pr=map.tileset.tilesPerRow or 16
  local aw,ah=map.tileset.imageWidth or 128,map.tileset.imageHeight or 128
  S.waterGround=S.waterGround or {}
  for k,s in pairs(S.shapeAt) do
    local tile=S.tileAt[k]
    local edge=edges[tile]
    if not S.skip[k] and ((s.class=="water" and edge) or (s.class=="ground" and tile==60)) then
      local tx,ty=k%4096-64,math.floor(k/4096)-64
      S.skip[k]=true
      if edge then S.waterGround[k],S.ground[k]=true,20 end
      local function height(x,z)
        if not edge then return 0 end
        local dx=edge.w and 8-x or (edge.e and x or 0)
        local dz=edge.n and 8-z or (edge.s and z or 0)
        local d=math.sqrt(dx*dx+dz*dz)
        local rough=1+.14*math.sin((tx*8+x)*.71+(ty*8+z)*.43)
        return -3.6*(d/8)^1.1*rough
      end
      for z=0,6,2 do for x=0,6,2 do
        local a={tx*8+x,height(x,z),ty*8+z}
        local b={tx*8+x+2,height(x+2,z),ty*8+z}
        local c={tx*8+x+2,height(x+2,z+2),ty*8+z+2}
        local d={tx*8+x,height(x,z+2),ty*8+z+2}
        local sx,sy=(tx*3+x)%6+1,(ty*5+z)%6+1
        S.objectQuads[#S.objectQuads+1]={a,b,c,d,
          u=((60%pr)*8+sx+.5)/aw,v=(math.floor(60/pr)*8+sy+.5)/ah,
          shade=edge and .85 or .98,gen2ShoreRock=true}
      end end
    end
  end
end
return M
