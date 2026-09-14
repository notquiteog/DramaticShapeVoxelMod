-- Source-textured, faceted rocks. Terrain and live Strength/Rock Smash actors
-- share the same closed geometry; the engine still owns every actor and move.
local V=...
local M={}
local meshes={}
function M.geometry(width,height,depth,sample,seed)
  local out={}
  seed=seed or 0
  local steps,bands=9,5
  local radii={0,.58,.85,.98,1,.97}
  local levels={1,.89,.66,.36,.09,0}
  local function point(j,i)
    i=i%steps
    local a=i/steps*math.pi*2
    local radius=radii[j+1]*(.94+.06*math.sin(i*7+seed*3))
    local skew=math.sin(j*2+seed)*.035*(1-radius)
    local h=levels[j+1]
    if j>0 and j<bands then h=h+.035*math.sin(i*3+j*7+seed) end
    return {width*.5*(radius*math.cos(a)+skew),height*h,
      depth*.5*(radius*math.sin(a)-skew)}
  end
  for j=0,bands-1 do for i=0,steps-1 do
    local a,b,c,d=point(j,i),point(j,i+1),point(j+1,i+1),point(j+1,i)
    local u,v=sample((i+.5)/steps,(j+.5)/bands)
    -- Light follows each fractured plane, not a stack of latitude bands.
    local ax,ay,az=b[1]-d[1],b[2]-d[2],b[3]-d[3]
    local bx,by,bz=c[1]-a[1],c[2]-a[2],c[3]-a[3]
    local nx,ny,nz=ay*bz-az*by,az*bx-ax*bz,ax*by-ay*bx
    local norm=math.sqrt(nx*nx+ny*ny+nz*nz)
    local shade=.76+(norm>0 and .22*math.abs((nx*.35+ny*.8+nz*.48)/norm) or .2)
    out[#out+1]={a,b,c,d,u=u,v=v,shade=shade}
  end end
  for i=0,steps-1 do
    local u,v=sample((i+.5)/steps,1)
    out[#out+1]={{0,0,0},point(bands,i+1),point(bands,i),{0,0,0},u=u,v=v,shade=.65}
  end
  return out
end
function M.ground(map,cx,cy)
  local Permissions=require("src.world.gen2.Permissions")
  for y=-1,2 do for x=-1,2 do
    if (x<0 or y<0 or x>1 or y>1)
      and Permissions.isWater(map:cellCollision(cx+x,cy+y)) then return 20 end
  end end
  return 5
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
  local quads=M.geometry(size*.99,height,size*.97,function(u,v)
    if #tones>0 then
      local tone=tones[(math.floor(u*61)+math.floor(v*47)*13)%#tones+1]
      return tone[1],tone[2]
    end
    -- Keep the texture inside the stone drawing, excluding its floor rim.
    local x=math.min(size-3,2+math.floor(u*(size-4)))
    local y=math.min(size-3,2+math.floor(v*(size-4)))
    local tile=S.tileAt[key(tx+math.floor(x/8),ty+math.floor(y/8))]
    return ((tile%pr)*8+x%8+.5)/aw,(math.floor(tile/pr)*8+y%8+.5)/ah
  end,(tx*13+ty*7)%7)
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
