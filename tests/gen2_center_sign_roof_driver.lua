return function(game)
 local U=dofile('tests/drivers/util.lua')
 local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib
 local P=require('src.render.Pipelines')
 local M,S=V.require('ChunkMesher'),V.require('VoxelState')
 local dir=assert(os.getenv('SHOT_DIR'))
 game.world.trySceneScript=function()return false end
 game.world.rollEncounter=function()return nil end
 V.require('DayNight').setting:sync('day')
 game.mods.modOptions.overworld_wild_spawns.catch_hud_size=0
 love.window.setMode(2560,1440,{resizable=true})
 for _,row in ipairs({{'CHERRYGROVE_POKECENTER_1F',5,3},{'GOLDENROD_POKECENTER_1F',5,3},{'NEW_BARK_TOWN',7,5}}) do
  assert(game.world:setMap(row[1],row[2],row[3],'up'));P.setLevel('voxel',3)
  U.wait(5)
  for _=1,2400 do if M.pending()==0 and S.ready then break end U.wait(1) end
  assert(M.pending()==0 and S.ready)
  local structures=V.require('Structures').forMap(game.world.map)
  if row[1]=='CHERRYGROVE_POKECENTER_1F' then
   local found=false
   for _,f in ipairs(structures.furniture or {}) do if f.id=='crystal_center_healer' then
    print('[center bed]',f.height,f.x0,f.x1,f.z0,f.z1)
    assert(f.height<=8 and f.z1-f.z0>=30,'Center bed still upright');found=true
   end end
   assert(found,'Center bed recipe not placed')
  end
  if row[1]=='NEW_BARK_TOWN' then
   local signs={}
   for _,q in ipairs(structures.objectQuads) do if q.visualObjectId and q.visualObjectId:find('signpost',1,true) then
    local b=signs[q.visualObjectId] or {minZ=math.huge,maxZ=-math.huge,minY=math.huge,maxY=-math.huge}
    signs[q.visualObjectId]=b
    for i=1,4 do b.minZ=math.min(b.minZ,q[i][3]);b.maxZ=math.max(b.maxZ,q[i][3]);b.minY=math.min(b.minY,q[i][2]);b.maxY=math.max(b.maxY,q[i][2]) end
   end end
   local n=0;for id,b in pairs(signs) do
    assert(b.maxZ-b.minZ<=2.01,'sign lettering detached in depth: '..id)
    assert(b.maxY-b.minY>=12,'sign lost its upright board: '..id);n=n+1
   end
   assert(n>=3,'native signs were not checked');print('[signs]',n,'boards remain coplanar')
  end
  U.wait(60);assert(U.shot(game,dir..'/'..row[1]..'.png'))
  if row[1]=='NEW_BARK_TOWN' then
   P.setLevel('voxel',2);U.wait(30);assert(U.shot(game,dir..'/roof_high.png'))
   P.setLevel('voxel',5);U.wait(30);assert(U.shot(game,dir..'/roof_low.png'))
  end
 end
 print('[center signs roofs] PASS: placed horizontal bed, coplanar signs and roof views')
 love.event.quit()
end
