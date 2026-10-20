-- Isolated native Cut/Surf callbacks and source-data preservation. The QA
-- fixture invokes already-authorized move payloads; it does not test HM gates.
return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'),'isolated QA profile required')
 local U=dofile('tests/drivers/util.lua');local ed=require('src.core.GameVersion').get()
 local prefix=({ruby='RU_',sapphire='SA_',emerald='EM_'})[ed]or'FR_'
 local hoenn=prefix~='FR_';local dir=assert(os.getenv('SHOT_DIR'))
 local update=game.update
 game.update=function(self,dt)return require('src.mods.Runtime').call('core.update',update,self,dt)end
 game:_handleBootAction({action='new_game',start={map=prefix..(hoenn and'OLDALE_TOWN'or'PALLET_TOWN'),x=10,y=9,facing='down'}})
 U.wait(3)
 local V=assert(game.mods.exports.BATTLE_ART_VOXEL_FORK).lib
 local Cam,Scene,W=V.require('Gen3Integration'),V.require('Gen3Scene'),V.require('Gen3Water')
 local Map,P,Col,Field=require('src.core.game3.map'),require('src.core.game3.player'),require('src.core.game3.collision'),require('src.core.game3.field')
 local Shapes,Pairs=V.require('Gen3TileShape'),V.require('Gen3Tilesets')
 V.require('RenderDistance').setting:sync(16);V.require('DayNight').setting:sync('day')
 V.require('Water').setting:sync('full');V.require('TreePresentation').props:sync('modeled')
 print('[GPU]',love.graphics.getRendererInfo())
 local function digest(def)
  local out={};for y=0,def.height-1 do for x=0,def.width-1 do local c=def.midLayout:cellAt(x,y);out[#out+1]=table.concat({c.mid,c.coll,c.elev},':')end end
  return love.data.encode('string','hex',love.data.hash('sha256',table.concat(out,';')))
 end
 local function settle(def)
  local stable,last=0
  for _=1,1800 do U.wait(1);local s=Scene.streaming
   if Scene.sceneDef==def and s.started+s.promoted==s.completed+s.cancelled and last==s.started then stable=stable+1 else stable=0 end
   last=s.started;if stable>=8 then break end
  end
  assert(stable>=8,'scene still streaming');assert(Cam.active and Cam.recovery.failures==0,'renderer recovered to native')
 end
 local function load(id,x,y,facing)
  Cam.setLevel(0,game);assert(Map.load(nil,game,id,{x=x,y=y,facing=facing or'down'}))
  require('src.ui.game3.map_preview_screen').dismiss();require('src.ui.game3.map_name_popup').dismiss()
  P.reset(x,y,facing or'down');game.input:reset();Scene.invalidate();Cam.setLevel(3,game);settle(Map.currentDef())
  return Map.currentDef()
 end
 local function shot(name)assert(U.shot(game,dir..'/'..name..'.png'))end
 -- Choose an actual native grass tile which the engine's own Cut mapping
 -- supports, rather than inventing a tile ID or changing collision.
 local def=load(prefix..(hoenn and'ROUTE104'or'ROUTE_1'),10,12)
 local layout=def.midLayout;local spec=Pairs.resolve(layout.pair,require('src.import.gba.versions').TILESET_PAIRS)
 local behaviors=require('src.core.game3.scripting.interaction_scripts').behaviors[layout.pair]
 local moves=require('src.core.game3.field_moves');local candidate
 for y=2,def.height-3 do for x=2,def.width-3 do
  local c=layout:cellAt(x,y)
  if not candidate and moves.CUT_GRASS_METATILES[c.mid]and Col.isGrass(x,y)and Col.isWalkable(x,y)
   and Shapes.of(spec.primary,spec.secondary,c.mid,behaviors[c.mid],c.coll).kind=='grass'then candidate={x,y,c.mid}end
 end end
 assert(candidate,'no native Cut grass fixture')
 P.reset(candidate[1],candidate[2],'down');Scene.invalidate();settle(def)
 local before=Scene.performanceSnapshot().grass.placements;assert(before>0,'no imported native grass')
 shot('grass-before-native-Cut')
 Field.executeFieldMove({action='cut_grass',mon={species=1,nickname='QA'}})
 for _=1,600 do U.wait(1);if not Field.locked then break end end
 assert(not Field.locked and layout:midAt(candidate[1],candidate[2])~=candidate[3],'native Cut did not finish')
 settle(def);local after=Scene.performanceSnapshot().grass.placements
 assert(after<before,'native Cut left imported tufts behind');shot('grass-after-native-Cut')
 local cutDigest=digest(def)
 V.require('TreePresentation').props:sync('cards');Scene.invalidate();settle(def)
 assert(Scene.performanceSnapshot().grass.placements==0,'cards option retained imported grass');shot('grass-native-cards')
 V.require('TreePresentation').props:sync('modeled');Scene.invalidate();settle(def)
 assert(Scene.performanceSnapshot().grass.placements==after and digest(def)==cutDigest,'presentation option changed native Cut data')
 print('[NATIVE CUT]',ed,candidate[1],candidate[2],before,after,cutDigest)
 -- Find a genuine dry landing adjacent to native water. The original move
 -- callback performs the hop, animation, collision updates and surf state.
 def=load(prefix..(hoenn and'ROUTE103'or'PALLET_TOWN'),10,14)
 local dirs={{0,-1,'up','down',0},{1,0,'right','left',math.pi/2},{0,1,'down','up',math.pi},{-1,0,'left','right',math.pi*1.5}}
 local shore
 for y=2,def.height-3 do for x=2,def.width-3 do
  if not shore and Col.isWalkable(x,y)and not Col.isWater(x,y)and not Col.warpAt(x,y)and not require('src.core.game3.objects').at(x,y)then
   for _,d in ipairs(dirs)do if Col.isWater(x+d[1],y+d[2])and not shore then shore={x=x,y=y,d=d}end end
  end
 end end
 assert(shore,'no native shore fixture');local d=shore.d
 P.reset(shore.x,shore.y,d[3]);Scene.invalidate();settle(def);local native=digest(def)
 local wx,wz=(shore.x+d[1])*16+8,(shore.y+d[2])*16+8
 local land=Scene.groundAt(shore.x*16+8,shore.y*16+8,P.currentElevation)
 local water=Scene.groundAt(wx,wz,P.currentElevation)
 assert(land-water>1,'water remains flush with ground')
 assert(Scene.performanceSnapshot().water.banks>0,'shore has no vertical bank faces')
 Cam.yaw=d[5];shot('shore-before-Surf')
 Field.executeFieldMove({action='surf',mon={species=7,nickname='QA'}})
 for _=1,600 do U.wait(1);if not Field.locked then break end end
 assert(not Field.locked and P.surfing and P.cellX==shore.x+d[1]and P.cellY==shore.y+d[2],'native Surf hop failed')
 settle(def);assert(math.abs(Scene.groundAt(P.px+8,P.py+8,P.currentElevation)-water)<1e-6,'surfer not supported by actual water plane')
 shot('native-Surf');Cam.setLevel(6,game);Cam.yaw=d[5];Cam.pitch=.12;U.wait(15);shot('native-Surf-first-person')
 assert(digest(def)==native,'presentation changed native shore data')
 print('[NATIVE SURF]',ed,shore.x,shore.y,'land',land,'water',water,'gap',land-water,native)
 assert(#game.mods:status().errors==0,table.concat(game.mods:status().errors,';'))
 print('[IMPORTED SCENERY] PASS',ed);love.event.quit()
end
