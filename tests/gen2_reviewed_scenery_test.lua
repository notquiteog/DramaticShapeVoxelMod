-- Contract checks for the reviewed scenery added after the source-atlas audit.
local Resolve=assert(loadfile('lib/Gen2FurnitureTemplates.lua'))()
local specs=assert(loadfile('data/gen2_depth_furniture.lua'))()
local families={TILESET_ELITE_FOUR_ROOM=true,TILESET_CHAMPIONS_ROOM=true,TILESET_PORT=true,TILESET_TOWER=true,TILESET_CAVE=true,TILESET_DARK_CAVE=true,TILESET_ICE_PATH=true}
local ts={blocks={}}
for block=1,128 do ts.blocks[block]={};for i=1,16 do ts.blocks[block][i]=block*16+i end end
local count=0
for family in pairs(families)do
 for _,spec in ipairs(specs[family])do
  local recipe=assert(Resolve.resolve(ts,spec));local width,height=spec.crop[3]*8,spec.crop[4]*8
  assert(recipe.groundAligned and recipe.support==0,'scenery should rest on the actual ground')
  for _,part in ipairs(recipe.parts)do
   assert(part.x[1]>=0 and part.x[2]<width,'part outside reviewed artwork width')
   assert(part.top[1]>=0 and part.top[2]<height,'cap outside source drawing')
   assert(part.facade[1]>=0 and part.facade[2]<height,'facade outside source drawing')
   assert(part.z>=0 and part.z+part.depth<=height,'model footprint escapes complete object')
   assert((part.rise or 0)>=0,'negative scenery elevation')
  end
  if spec.kind=='boulder'then assert(recipe.parts[1].silhouette,'rounded source silhouette must be retained')end
  if spec.kind=='orb_plinth'then assert(#recipe.parts==2 and recipe.parts[2].silhouette,'orb and pedestal must stay separate')end
  count=count+1
 end
end
assert(count==15,'reviewed inventory changed; repeat original-map collision audit')
print('PASS 15 reviewed scenery recipes, bounded parts and source silhouettes')
