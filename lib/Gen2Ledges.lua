-- Rounded earth mounds, including turns. Grass rolls down toward the inside;
-- the outward, unjumpable face retains its source dirt texture and height.
local Gen2Ledges={}
local function key(x,y) return (y+64)*4096+x+64 end
local edges={
  [43]={w=true,n=true},[44]={n=true},[45]={e=true,n=true},
  [59]={w=true},[61]={e=true},[75]={w=true,s=true},
  [76]={s=true},[77]={e=true,s=true},
}
function Gen2Ledges.height(x,z,edge)
  local distance=8
  if edge.w then distance=math.min(distance,x) end
  if edge.e then distance=math.min(distance,8-x) end
  if edge.n then distance=math.min(distance,z) end
  if edge.s then distance=math.min(distance,8-z) end
  local t=math.max(0,math.min(1,1-distance/3))
  return 6*t*t*(3-2*t)
end
function Gen2Ledges.build(S,map)
  if not S.gen2 or (map.tileset.id~="TILESET_JOHTO" and map.tileset.id~="TILESET_JOHTO_MODERN") then return end
  local pr=map.tileset.tilesPerRow or 16
  local aw,ah=map.tileset.imageWidth or 128,map.tileset.imageHeight or 128
  local cells={}
  for k,s in pairs(S.shapeAt) do
    if s.class=="ledge" and not S.skip[k] then
      local tx=(k%4096)-64
      local ty=math.floor(k/4096)-64
      local tile=S.tileAt[k]
      local edge=edges[tile]
      S.skip[k],S.ground[k]=true,5
      if edge then
        for z=0,7 do for x=0,7 do
          if (edge.w and x<3) or (edge.e and x>=5)
            or (edge.n and z<3) or (edge.s and z>=5) then
            cells[(ty*8+z)..":"..(tx*8+x)]={x=tx*8+x,z=ty*8+z,tile=tile,sx=x,sz=z,edge=edge}
          end
        end end
      end
    end
  end
  local function quad(a,b,c,d,tile,sx,sy,shade)
    S.objectQuads[#S.objectQuads+1]={a,b,c,d,
      u=((tile%pr)*8+sx+.5)/aw,
      v=(math.floor(tile/pr)*8+sy+.5)/ah,shade=shade,gen2Ledge=true}
  end
  for _,c in pairs(cells) do
    local x,z=c.x,c.z
    local function height(px,pz)
      return Gen2Ledges.height(c.sx+px-x,c.sz+pz-z,c.edge)
    end
    -- A shared smooth profile replaces the flat bar. Its inner edge meets
    -- the grass at zero; the outer face still shows the original dirt art.
    quad({x,height(x,z),z},{x+1,height(x+1,z),z},
      {x+1,height(x+1,z+1),z+1},{x,height(x,z+1),z+1},5,c.sx,c.sz,1)
    for _,d in ipairs({{0,1},{0,-1},{-1,0},{1,0}}) do
      if not cells[(z+d[2])..":"..(x+d[1])] then
        for y=0,5 do
          local a,b
          if d[2]==1 then a,b={x,y,z+1},{x+1,y,z+1}
          elseif d[2]==-1 then a,b={x+1,y,z},{x,y,z}
          elseif d[1]==-1 then a,b={x,y,z},{x,y,z+1}
          else a,b={x+1,y,z+1},{x+1,y,z} end
          local ha,hb=height(a[1],a[3]),height(b[1],b[3])
          if ha>y or hb>y then
            a[2],b[2]=math.min(y,ha),math.min(y,hb)
            quad(a,b,{b[1],math.min(y+1,hb),b[3]},
              {a[1],math.min(y+1,ha),a[3]},c.tile,c.sx,7-y,.85)
          end
        end
      end
    end
  end
end
return Gen2Ledges
