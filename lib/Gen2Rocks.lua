-- Source-textured, faceted rocks. Terrain and live Strength/Rock Smash actors
-- share the same closed geometry; the engine still owns every actor and move.
local V=...
local M={}
local meshes={}
function M.geometry(width,height,depth,sample)
  local out={}
  local steps,bands=12,7
  local function point(j,i)
    i=i%steps
    local t=(j/bands)*math.pi*.72
    local a=i/steps*math.pi*2
    local radius=math.sin(t)
    local jitter=1+.045*math.sin(i*7+j*3)
    return {width*.5*radius*math.cos(a)*jitter,
      math.max(0,height*(math.cos(t)-math.cos(math.pi*.72))/(1-math.cos(math.pi*.72))),
      depth*.5*radius*math.sin(a)*jitter}
  end
  for j=0,bands-1 do for i=0,steps-1 do
    local a,b,c,d=point(j,i),point(j,i+1),point(j+1,i+1),point(j+1,i)
    local u,v=sample((i+.5)/steps,(j+.5)/bands)
    out[#out+1]={a,b,c,d,u=u,v=v,shade=.82+.16*(1-j/bands)+.05*math.sin(i/steps*math.pi*2)}
  end end
  for i=0,steps-1 do
    local u,v=sample((i+.5)/steps,1)
    out[#out+1]={{0,0,0},point(bands,i+1),point(bands,i),{0,0,0},u=u,v=v,shade=.65}
  end
  return out
end
function M.terrain(S,map,tx,ty,size,height)
  local pr=map.tileset.tilesPerRow or 16
  local aw,ah=map.tileset.imageWidth or 128,map.tileset.imageHeight or 128
  local function key(x,y)return (y+64)*4096+x+64 end
  local data=require("src.render.Assets").imageData(map.tileset.image)
  local donor=size==32 and 60 or S.tileAt[key(tx,ty)]
  local tones={}
  for y=1,6 do for x=1,6 do
    local ax,ay=(donor%pr)*8+x,math.floor(donor/pr)*8+y
    local r,g,b,a=data:getPixel(ax,ay)
    if a>.5 and math.min(r,g,b)>.1 then
      tones[#tones+1]={(ax+.5)/aw,(ay+.5)/ah}
    end
  end end
  data:release()
  local quads=M.geometry(size*.88,height,size*.78,function(u,v)
    if #tones>0 then
      local tone=tones[(math.floor(u*61)+math.floor(v*47)*13)%#tones+1]
      return tone[1],tone[2]
    end
    -- Keep the texture inside the stone drawing, excluding its floor rim.
    local x=math.min(size-3,2+math.floor(u*(size-4)))
    local y=math.min(size-3,2+math.floor(v*(size-4)))
    local tile=S.tileAt[key(tx+math.floor(x/8),ty+math.floor(y/8))]
    return ((tile%pr)*8+x%8+.5)/aw,(math.floor(tile/pr)*8+y%8+.5)/ah
  end)
  -- Small source patches retain the stone's grain on each facet instead of
  -- turning a few sampled highlights into broad metallic-looking bands.
  for _,q in ipairs(quads) do
    local du,dv=1/aw,1/ah
    q.uv={{q.u-du,q.v+dv},{q.u+du,q.v+dv},
          {q.u+du,q.v-dv},{q.u-du,q.v-dv}}
  end
  return quads
end
function M.accepts(c)
  local map=c and c.state and c.state.map
  local d=c and c.sprite and c.sprite.def
  return map and type(map.cellCollision)=="function" and d and not d.trueColor
    and not d.walker and (d.frameWidth or 16)==16 and (d.frameHeight or 16)==16
    and ((d.id=="SPRITE_BOULDER" and d.image=="assets/generated/sprites/boulder.png")
      or (d.id=="SPRITE_ROCK" and d.image=="assets/generated/sprites/rock.png"))
end
function M.draw(c,shadow)
  if not M.accepts(c) then return false end
  local d=c.sprite.def
  local mesh=meshes[d.image]
  local tex=c.sprite:resolveImage()
  if not mesh then
    local iw,ih=tex:getDimensions()
    local data=require("src.render.Assets").imageData(d.image)
    local tones={}
    for y=2,13 do for x=2,13 do
      local r,g,b,a=data:getPixel(x,y)
      if a>.5 and r<.83 and r>.1 then tones[#tones+1]={(x+.5)/iw,(y+.5)/ih} end
    end end
    data:release()
    if #tones==0 then return false end
    local q=M.geometry(d.id=="SPRITE_BOULDER" and 14 or 12,
      d.id=="SPRITE_BOULDER" and 12 or 9,12,function(u,v)
        local t=tones[(math.floor(u*61)+math.floor(v*47)*13)%#tones+1]
        return t[1],t[2]
      end)
    local verts,indices={},{}
    for _,face in ipairs(q) do
      local n=#verts
      for i=1,4 do local p=face[i];verts[#verts+1]={p[1],p[2],p[3],face.u,face.v,face.shade} end
      for _,i in ipairs({1,2,3,1,3,4}) do indices[#indices+1]=n+i end
    end
    mesh=V.require("Voxel3D").newMesh(verts,indices);meshes[d.image]=mesh
  end
  if c.colors then tex=V.require("TerrainAtlas").forSprite(d.image,c.colors) or tex end
  local transform=V.require("ItemPokeballs").transform(c,not shadow)
  if shadow then shadow.draw(mesh,tex,transform)
  else V.require("Voxel3D").draw(mesh,tex,transform) end
  return true
end
function M.invalidate()
  for _,mesh in pairs(meshes) do mesh:release() end
  meshes={}
end
return M
