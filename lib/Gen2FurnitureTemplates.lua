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
 local t={id=spec.id,tiles=tiles,groundTiles=ground,groundAligned=true,
  panes=false,roofRows=0,roofBack=0,roofFront=0,roofCycle={0,0},
  slab=0,frontEave=0,support=0,parts={}}
 local kind=spec.kind
 if kind=='boulder' or kind=='statue' or kind=='monument' or kind=='orb_plinth' or kind=='bicycle' then
  t.model='native_rock';t.modelDepth=kind=='bicycle' and 3 or nil
  t.modelShape=kind=='boulder' and 'rock' or nil;return t
 end
 if kind=='cabinet' or kind=='machine' or kind=='seat' or kind=='bed' or kind=='table' or kind=='console' then
  t.design='gb_native_'..kind
  if spec.id:find('slots') then t.design='gb_native_machine' end
  t.support=(kind=='table' or kind=='bed') and 6 or kind=='seat' and 4 or 0
  return t
 end
 if kind=='bench' or kind=='bin' then t.model=kind;return t end
 if kind=='planter' then t.model='planter';return t end
 return nil -- Unknown semantics must not silently become a generic cabinet.
end
return M
