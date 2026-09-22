-- Visual QA against the real Crystal cart; collision-aware camera locations.
return function(game)
 local U=dofile('tests/drivers/util.lua')
 local V=assert(game.mods.exports.BATTLE_ART_VOXEL_FORK).lib
 local P=require('src.render.Pipelines')
 local Map=require('src.world.gen2.Map')
 local Permission=require('src.world.gen2.Permissions')
 local M,S,F=V.require('ChunkMesher'),V.require('VoxelState'),V.require('FirstPerson')
 local dir=assert(os.getenv('SHOT_DIR'))
 assert(require('src.core.Version').engine=='0.2.73')
 assert(love.filesystem.getIdentity()=='battle-art-crossgen-qa','refusing a non-QA identity')
 love.window.setMode(1920,1080,{resizable=true})
 V.require('DayNight').setting:sync('day')
 game.world.trySceneScript=function()return false end
 game.world.rollEncounter=function()return nil end
 local ids={'NEW_BARK_TOWN','ECRUTEAK_CITY','GOLDENROD_CITY','OLIVINE_CITY','CELADON_CITY'}
 if os.getenv('QA_ROOF_MAPS') then
  ids={};for id in os.getenv('QA_ROOF_MAPS'):gmatch('[^,]+') do ids[#ids+1]=id end
  assert(#ids>0,'empty roof map selection')
 end
 for _,id in ipairs(ids) do
  local def=assert(game.world.maps[id])
  local map=Map.new(def,assert(game.world.tilesets[def.tileset]))
  local structures=V.require('Structures').forMap(map)
  if id=='GOLDENROD_CITY' then
   local function runAt(x,y)return assert(structures.runs[(y+64)*4096+x+64])end
   for _,y in ipairs({40,44,48})do
    local r=runAt(12,y);assert(r.north==y and r.front==y+3 and r.h==16,'stacked houses merged')
   end
   local r=runAt(32,38)
   assert(r.front>=43,'roof-coloured facade bricks split after a window')
  end
  local target,best
  for k,run in pairs(structures.runs) do
   local x=k%4096-64
   if run.rise>0 then
    local score=(x*.5-map.widthCells*.5)^2+((run.front+1)*.5-map.heightCells*.45)^2
    if not best or score<best then target={x=x*.5,y=(run.front+1)*.5};best=score end
   end
  end
  assert(target,'no roof found: '..id)
  local px,py,dist
  for cy=1,map.heightCells-2 do for cx=1,map.widthCells-2 do
   if Permission.of(map:cellCollision(cx,cy))==Permission.LAND and not map._warpAt[cy*1024+cx] then
    local d=(cx-target.x)^2+(cy-target.y-4)^2
    if not dist or d<dist then px,py,dist=cx,cy,d end
   end
  end end
  assert(px,'no safe camera: '..id)
  game.stack:clear();assert(game.world:setMap(id,px,py,'up'))
  P.setLevel('voxel',3);U.wait(120)
  for _=1,2400 do if M.pending()==0 and S.ready then break end U.wait(1) end
  assert(M.pending()==0 and S.ready,'roof build stalled: '..id)
  game.stack:clear()
  print('[roof view]',id,px,py,'target',target.x,target.y)
  for _,level in ipairs({2,3,5}) do
   P.setLevel('voxel',level);U.wait(10)
   assert(not V.require('Voxel3D').canopyFacing,'static foliage changed')
   assert(U.shot(game,dir..'/'..id..'_static_'..level..'.png'))
  end
  for _,level in ipairs({6,7}) do
   P.setLevel('voxel',level);U.wait(25)
   assert(F.engaged() and F.driving())
   for i,yaw in ipairs({math.pi,math.pi*.75,math.pi*1.25}) do
    F.lookBy(yaw-F.yaw,-.12-F.pitch);U.wait(8)
    assert(V.require('Voxel3D').canopyFacing,'free-camera foliage changed')
    assert(U.shot(game,dir..'/'..id..'_free_'..level..'_'..i..'.png'))
   end
  end
 end
 print('[roof views] PASS',#ids,'towns, three static angles and six free-camera views each')
 love.event.quit()
end
