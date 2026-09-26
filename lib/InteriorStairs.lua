-- Front-facing Mansion stairs. Their four horizontal source bands are
-- north/south treads, unlike the side-view Red/Ship east/west artwork.
-- Source pixels provide every material; the cell remains a floor-level
-- warp for actors. Geometry and claims are deliberately separate.
local Stairs = {}
local function key(x,z) return (z+64)*4096+x+64 end
local function bands(a,b)
  local out={};local at=a
  while at<b do
    local nextEdge=math.min(b,(math.floor(at/8)+1)*8)
    out[#out+1]={at,nextEdge};at=nextEdge
  end
  return out
end
function Stairs.build(S,map,data,cx,cy,s)
  assert(s.class=="stair_n" or s.class=="stair_down_n","interior stair direction")
  local down=s.class=="stair_down_n"
  local h=s.h or 16
  local rise=h/4 -- Full-storey stairs and short native cave terraces share four treads.
  local mx,mz=cx*16,cy*16
  local perRow=map.tileset.tilesPerRow or 16
  local aw,ah=map.tileset.imageWidth or 128,map.tileset.imageHeight or 48
  local quads=S.objectQuads
  local function vertex(x,y,z)return{mx+x,y,mz+z}end
  local function put(points,coords,shade,role)
    local q={points[1],points[2],points[3],points[4],uv={},shade=shade}
    do
      -- Shared public drawings need not occupy adjacent atlas tiles.
      -- Select the source tile from this face's center, keeping an edge
      -- at pixel 8/16 inside that same tile instead of jumping to its neighbor.
      local ax,ay=0,0
      for i=1,4 do ax=ax+coords[i][1]/4;ay=ay+coords[i][2]/4 end
      local bx,by=math.floor(ax/8),math.floor(ay/8)
      local tile=S.tileAt[key(cx*2+bx,cy*2+by)]
      q.stairSourceTile=tile
      for i=1,4 do
        local x=math.max(.05,math.min(7.95,coords[i][1]-bx*8))
        local y=math.max(.05,math.min(7.95,coords[i][2]-by*8))
        q.uv[i]={((tile%perRow)*8+x)/aw,(math.floor(tile/perRow)*8+y)/ah}
      end
    end
    -- Diagnostic roles do not participate in batching or material selection.
    q.interiorStairRole=role
    quads[#quads+1]=q
  end
  local function material(points,x,y,shade,role)
    local c={x+.5,y+.5}
    put(points,{c,c,c,c},shade,role)
  end
  local function horizontal(y,z0,z1,role)
    for _,xb in ipairs(bands(0,16))do for _,zb in ipairs(bands(z0,z1))do
      local x0,x1,z0,z1=xb[1],xb[2],zb[1],zb[2]
      -- The original horizontal source band lands once on its own tread.
      put({vertex(x0,y,z0),vertex(x1,y,z0),vertex(x1,y,z1),vertex(x0,y,z1)},
          {{x0,z0},{x1,z0},{x1,z1},{x0,z1}},down and .8 or 1,role)
    end end
  end
  local function zface(z,y0,y1,front,x,y,shade,role)
    for _,xb in ipairs(bands(0,16))do for _,yb in ipairs(bands(y0,y1))do
      local x0,x1,a,b=xb[1],xb[2],yb[1],yb[2]
      local p=front and{vertex(x0,a,z),vertex(x1,a,z),vertex(x1,b,z),vertex(x0,b,z)}
                    or{vertex(x1,a,z),vertex(x0,a,z),vertex(x0,b,z),vertex(x1,b,z)}
      material(p,x,y,shade,role)
    end end
  end
  local function sides(z0,z1,y0,y1)
    for _,zb in ipairs(bands(z0,z1))do for _,yb in ipairs(bands(y0,y1))do
      local a,b,c,d=zb[1],zb[2],yb[1],yb[2]
      local west={vertex(0,c,a),vertex(0,c,b),vertex(0,d,b),vertex(0,d,a)}
      local east={vertex(16,c,b),vertex(16,c,a),vertex(16,d,a),vertex(16,d,b)}
      if down then west={west[2],west[1],west[4],west[3]};east={east[2],east[1],east[4],east[3]}end
      local sx,sy=down and 1 or 14,down and 8 or 1
      material(west,sx,sy,.78,down and"well-west"or"side-west")
      material(east,sx,sy,.68,down and"well-east"or"side-east")
    end end
  end
  local nativeHouse=map.tileset.id=='TILESET_PLAYERS_HOUSE' or map.tileset.id=='TILESET_PLAYERS_ROOM'
  if nativeHouse then
    -- A shallow descending flight keeps individual treads visible from a
    -- normal eye at its approach. A 45-degree drop in one cell occluded
    -- every step behind the next riser and read as one blank ramp.
    if down then h=math.min(h,8);rise=h/4 end
    -- Crystal's four drawn treads become separate solid steps. Keep the
    -- original light wood and shaded risers, not a stretched black outline
    -- through the whole height of each step. The original cell still owns
    -- the warp; ascending geometry never raises actor collision/support.
    for band=0,3 do
      local z0,z1=band*4,(band+1)*4
      local height=(down and -1 or 1)*(h-band*rise)
      local sy=down and 13 or z0+2
      material({vertex(1,height,z0),vertex(15,height,z0),vertex(15,height,z1),vertex(1,height,z1)},3,sy,1,'house-tread')
      local bottom=down and height+rise or height-rise
      material({vertex(1,bottom,z1),vertex(15,bottom,z1),vertex(15,height,z1),vertex(1,height,z1)},13,down and 10 or 7,.82,'house-riser')
      material({vertex(1,height-.35,z1),vertex(15,height-.35,z1),vertex(15,height,z1),vertex(1,height,z1)},0,0,.8,'house-nosing')
      sides(z0,z1,down and height or 0,down and 0 or height)
      -- Solid side caps connect each tread to its supporting side panels.
      for _,span in ipairs({{0,1},{15,16}})do
        local y=down and 0 or height+.7
        material({vertex(span[1],y,z0),vertex(span[2],y,z0),vertex(span[2],y,z1),vertex(span[1],y,z1)},13,7,.9,'house-stringer')
        local base=down and height or 0
        for _,x in ipairs(span)do
          material({vertex(x,base,z0),vertex(x,base,z1),vertex(x,y,z1),vertex(x,y,z0)},13,7,.78,'house-stringer-side')
        end
        for _,z in ipairs({z0,z1})do
          material({vertex(span[1],base,z),vertex(span[2],base,z),vertex(span[2],y,z),vertex(span[1],y,z)},13,7,.82,'house-stringer-end')
        end
      end
    end
    zface(0,down and -h or 0,down and 0 or h,down,13,7,.7,'house-back')
    return
  end
  for band=0,3 do
    local z0,z1=band*4,(band+1)*4
    local height=h-band*rise
    if down then
      horizontal(-height,z0,z1,"tread-down")
      sides(z0,z1,-height,0)
      -- Each drop continues the actual shade of its own source tread.
      zface(z1,-height,-height+rise,false,7,z0+2,.82,"riser-down")
    else
      horizontal(height,z0,z1,"tread-up")
      sides(z0,z1,0,height)
      -- The drawn black edge stays one pixel tall; the recessed riser
      -- continues the original shaded right edge instead of a stretched
      -- copy of all four tread drawings.
      zface(z1,height-rise,height-1,true,14,1,.82,"riser-up")
      zface(z1,height-1,height,true,0,4,.82,"edge-up")
    end
  end
  if down then
    -- Dark far opening closes the pit; no floor sheet plugs the cell.
    zface(0,-h,0,true,7,1,.2,"well-end")
  else
    zface(0,0,h,false,14,1,.68,"back-up")
  end
end
return Stairs
