-- Source-textured, faceted rocks. Terrain and live Strength/Rock Smash actors
-- share the same closed geometry; the engine still owns every actor and move.
local V=...
local M={}
local meshes={}
local function variation(seed,salt)
  return (math.sin(seed*12.9898+salt*78.233)*43758.5453)%1
end
function M.geometry(width,height,depth,sample,seed)
  local out={}
  seed=seed or 0
  local steps,bands=7+math.floor(variation(seed,1)*3),5
  local radii={0,.55,.87,1,1,.98}
  local levels={1,.86,.59,.28,.07,0}
  local angle=variation(seed,2)*math.pi*2
  local peakX,peakZ=(variation(seed,3)-.5)*.25,(variation(seed,4)-.5)*.25
  local function point(j,i)
    i=i%steps
    local a=i/steps*math.pi*2+angle
    -- Each radial seam keeps its own irregular footprint from top to base.
    -- The off-centre crest and broad fractured shoulders avoid round balls.
    local radius=radii[j+1]*(.76+variation(seed,i+10)*.24)
    local h=levels[j+1]
    if j>0 and j<bands then h=h+.045*math.sin(i*3+j*7+seed) end
    return {width*.5*(radius*math.cos(a)+peakX*(1-radius)),height*h,
      depth*.5*(radius*math.sin(a)+peakZ*(1-radius))}
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
function M.ground(map,cx,cy,span,S)
  local Permissions=require("src.world.gen2.Permissions")
  span=span or 2
  local land,water={},{}
  local function key(x,y)return (y+64)*4096+x+64 end
  for radius=1,3 do
    for y=-radius,span+radius-1 do for x=-radius,span+radius-1 do
      local gx,gy=cx+x,cy+y
      if (x<0 or y<0 or x>=span or y>=span)
        and (not map.inBounds or map:inBounds(gx,gy)) then
        local c=map:cellCollision(gx,gy)
        local wet=Permissions.isWater(c)
        if wet or Permissions.of(c)==Permissions.LAND then
          for dy=0,1 do for dx=0,1 do
            local tx,ty=gx*2+dx,gy*2+dy
            local tile=map:tileAt(tx,ty)
            local shape=S and S.shapeAt[key(tx,ty)]
            if tile and tile~=0 and (not shape or shape.class==(wet and 'water' or 'ground')) then
              local votes=wet and water or land
              votes[tile]=(votes[tile] or 0)+1
            end
          end end
        end
      end
    end end
    local function best(votes)
      local tile,n
      for t,count in pairs(votes) do if not n or count>n or (count==n and t<tile) then tile,n=t,count end end
      return tile
    end
    -- An adjacent land surface takes priority over incidental nearby water.
    -- No hard-coded grass/stone tile may turn into an unrelated square pad.
    local dry=best(land);if dry then return dry,false end
    local wet=best(water);if wet then return wet,true end
  end
  return false,false
end
function M.shoreLayout(tx,ty)
  local seed=math.floor(variation(tx*31+ty*73,8)*32)
  local width=5.0+variation(seed,21)*2.9
  local depth=4.7+variation(seed,22)*3.2
  return {seed=seed,width=width,depth=depth,height=2.0+variation(seed,23)*2.6,
    x=(variation(seed,24)-.5)*(8-width),z=(variation(seed,25)-.5)*(8-depth)}
end
function M.shoreClusterLayout(cx,cy)
  local seed=math.floor(variation(cx*31+cy*73,8)*32)
  local out={seed=seed}
  local angle=variation(seed,30)*math.pi*2
  for i,p in ipairs({{-3,-2,10.4,8.7},{4,-3,7.2,6.1},{0,4,8.1,6.6},{4,4,3.6,4.0}}) do
    if i<4 or variation(seed,31)>.45 then
      local w=p[3]*(.88+variation(seed,i+32)*.12)
      local d=p[4]*(.88+variation(seed,i+36)*.12)
      local x,z=p[1]*math.cos(angle)-p[2]*math.sin(angle),p[1]*math.sin(angle)+p[2]*math.cos(angle)
      x=x+(variation(seed,i+40)-.5)*1.6;z=z+(variation(seed,i+44)-.5)*1.6
      out[#out+1]={seed=seed*5+i,width=w,depth=d,height=(i==4 and 1.2 or 2.2)+variation(seed,i+48)*2,
        x=math.max(-8+w/2,math.min(8-w/2,x)),z=math.max(-8+d/2,math.min(8-d/2,z))}
    end
  end
  return out
end
function M.terrain(S,map,tx,ty,size,height,customLayout)
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
  local layout=customLayout or (size==8 and M.shoreLayout(tx,ty))
  local seed=layout and layout.seed or math.floor(variation(tx*31+ty*73,8)*32)
  local quads=M.geometry(layout and layout.width or size*.99,
    layout and layout.height or height,layout and layout.depth or size*.97,function(u,v)
    if #tones>0 then
      local tone=tones[(math.floor(u*61)+math.floor(v*47)*13)%#tones+1]
      return tone[1],tone[2]
    end
    -- Keep the texture inside the stone drawing, excluding its floor rim.
    local x=math.min(size-3,2+math.floor(u*(size-4)))
    local y=math.min(size-3,2+math.floor(v*(size-4)))
    local tile=S.tileAt[key(tx+math.floor(x/8),ty+math.floor(y/8))]
    return ((tile%pr)*8+x%8+.5)/aw,(math.floor(tile/pr)*8+y%8+.5)/ah
  end,seed)
  -- Small source patches retain the stone's grain on each facet instead of
  -- turning a few sampled highlights into broad metallic-looking bands.
  for _,q in ipairs(quads) do
    if layout then for i=1,4 do q[i][1]=q[i][1]+layout.x;q[i][3]=q[i][3]+layout.z end end
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
