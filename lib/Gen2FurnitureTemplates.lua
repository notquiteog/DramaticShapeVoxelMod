-- Resolve a reviewed whole-object crop against the live Crystal metatiles.
local M={}
function M.resolve(ts,spec)
 local block=ts.blocks and ts.blocks[spec.block+1]
 local floor=ts.blocks and ts.blocks[spec.groundBlock+1]
 if not block or not floor then return nil end
 local crop=spec.crop
 local x,y,w,h=crop[1],crop[2],crop[3],crop[4]
 if x<0 or y<0 or w<=0 or h<=0 or x+w>4 or y+h>4 then return nil end
 local tiles,ground={},{}
 for dy=0,h-1 do
  tiles[dy+1]={}
  for dx=0,w-1 do tiles[dy+1][dx+1]=block[(y+dy)*4+x+dx+1] end
 end
 for dy=0,3 do
  ground[dy+1]={}
  for dx=0,3 do ground[dy+1][dx+1]=floor[dy*4+dx+1] end
 end
 local floorTiles,hasObject={},false
 for _,row in ipairs(ground) do for _,tile in ipairs(row) do floorTiles[tile]=true end end
 for _,row in ipairs(tiles) do for _,tile in ipairs(row) do
  if not floorTiles[tile] then hasObject=true end
 end end
 if not hasObject then return nil end
 local width,height=w*8,h*8
 local t={id=spec.id,tiles=tiles,groundTiles=ground,groundAligned=true,
  panes=false,roofRows=0,roofBack=0,roofFront=0,roofCycle={0,0},
  slab=0,frontEave=0,support=0,parts={}}
 local function upright(x0,x1,t0,t1,f0,f1,z,depth,rise)
  return {kind='upright',x={x0,x1},top={t0,t1},facade={f0,f1},
   z=z,depth=depth,rise=rise,stretch=true}
 end
 local kind=spec.kind
 if kind=='bench' or kind=='bin' then t.model=kind;return t end
 if kind=='planter' then t.model='planter';return t end
 if kind=='boulder' then
  -- The source's rounded upper outline becomes the real plan silhouette;
  -- its shaded lower band folds down once instead of repeating as a wall.
  local rock=upright(0,width-1,0,height-8,height-7,height-1,2,height-4)
  rock.silhouette=true;rock.topFront=height-8
  t.parts={rock}
 elseif kind=='orb_plinth' then
  -- Separate the round cap from its square pedestal. Both use their own
  -- complete drawn bands and keep a shallow footprint inside the source.
  local pedestal=upright(1,width-2,16,18,19,height-1,height-12,10)
  local orb=upright(0,width-1,0,8,9,15,height-14,12,height-19)
  orb.silhouette=true;orb.topFront=8
  t.parts={pedestal,orb}
 elseif kind=='monument' then
  local plinth=upright(1,width-2,height-8,height-6,height-5,height-1,height-14,13)
  local body=upright(0,width-1,0,5,6,height-9,height-13,11,5)
  body.silhouette=true
  t.parts={plinth,body}
 elseif kind=='bicycle' then
  -- Keep both wheels and the frame in a narrow display rack; the floor
  -- between the wheels is cut away by the complete drawing's source mask.
  local bike=upright(0,width-1,0,2,3,height-1,5,6)
  bike.silhouette=true
  t.parts={bike}
 elseif kind=='bed' or kind=='table' then
  t.support=6
  t.parts={upright(0,width-1,0,height-5,height-4,height-2,0,height,3),
   {kind='upright',x={0,width-1},top={height-1,height-1},
    facade={height-3,height-1},z=2,depth=height-4,
    supports={fromRow=height-3,zones={
     {x={2,4},z={2,4}},{x={width-5,width-3},z={2,4}},
     {x={2,4},z={height-5,height-3}},
     {x={width-5,width-3},z={height-5,height-3}}}}}}
 elseif kind=='seat' then
  t.support=5
  t.parts={upright(1,width-2,0,height-6,height-5,height-1,1,height-2)}
 elseif kind=='console' then
  t.support=8
  t.parts={upright(0,width-1,0,height-9,height-8,height-1,0,math.min(height,20))}
 elseif kind=='statue' then
  t.parts={upright(1,width-2,0,2,3,height-1,math.max(1,height-14),12)}
 else -- cabinets and terminals stand up once, on a shallow footprint
  local depth=kind=='cabinet' and 12 or 14
  t.parts={upright(0,width-1,0,4,5,height-1,math.max(0,height-depth),depth)}
 end
 return t
end
return M
