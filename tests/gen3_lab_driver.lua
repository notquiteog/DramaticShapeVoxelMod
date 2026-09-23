return function(game)
 local U=dofile('tests/drivers/util.lua');local dir=assert(os.getenv('SHOT_DIR'));local version=require('src.core.GameVersion').get()
 local identity=love.filesystem.getIdentity()
 assert(identity=='source-art-'..version..'-031-qa' or identity=='test-round-'..version..'-qa','use isolated0.3.1 QA profile')
 assert(require('src.core.Version').engine=='0.3.1')
 love.window.setMode(1600,900,{resizable=true})
 game:_handleBootAction({action='new_game',start={map='FR_OAKS_LAB',x=6,y=6,facing='up'}})
 local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib;local C=V.require('Gen3Integration');local Player=require('src.core.game3.player')
 local Collision=require('src.core.game3.collision');local Objects=require('src.core.game3.objects');local F=V.require('Gen3Furniture')
 local Map=require('src.core.game3.map');local def=Map.currentDef();local pair=def.midLayout.pair;local cells={}
 for y=0,def.height-1 do for x=0,def.width-1 do cells[x..':'..y]={cx=x,cy=y,mid=def.midLayout:midAt(x,y),primary='building',secondary='lab',pair=pair}end end
 local props=F.extract(cells);local machine=0;for _,p in ipairs(props)do if p.recipe.name=='lab_pokemon_machine'then machine=machine+1 end end
 assert(machine==1,'native machine not assembled')
 local balls=0
 for _,eo in ipairs(Objects.forDraw())do if eo.graphicsId==92 then assert(F.support(cells,92,eo.px,eo.py)>9);balls=balls+1 end end
 assert(balls==3,'starter fixture missing balls')
 -- Disposable fresh fixture: reproduce the screenshot's two actors on the
 -- native walkable apron. No player save or source collision is modified.
 assert(Objects.showObject(8),'native rival template missing')
 Objects.setObjectXY(8,10,5);Objects.turnObject(8,'up');Objects.freeze(8)
 for _,x in ipairs({8,9,10})do
  assert(not Collision.isWalkable(x,4) and Collision.isWalkable(x,5),'native starter table footprint changed')
 end
 local rival=assert(Objects.find(8));assert(rival.graphicsId==72 or rival.def.graphicsId==72,'wrong rival fixture')
 for _,case in ipairs({{'approach15',2,0},{'approach35',3,0},{'approach50',4,0},{'approach70',5,0},
  {'approach_front',7,0},{'approach_east',7,-math.pi/2},{'approach_rear',7,math.pi},{'approach_west',7,math.pi/2}})do
  Player.reset(8,5,'up');C.setLevel(case[2],game);C.yaw=case[3];C.pitch=.15;U.wait(35)
  assert(C.active,'approach scene fell back')
  assert(Player.cellX==8 and Player.cellY==5 and rival.cellX==10 and rival.cellY==5,'approach fixture moved')
  assert(U.shot(game,dir..'/'..case[1]..'.png'))
 end
 for _,case in ipairs({{'static',6,6,3,0},{'machine',4,6,6,-1.1},{'table',9,6,6,0},
  {'back_wall',6,3,6,0},{'front',6,7,7,0},{'east',6,7,7,-math.pi/2},{'back',6,7,7,math.pi},{'west',6,7,7,math.pi/2}})do
  assert(Collision.isWalkable(case[2],case[3]),'invalid camera position '..case[1])
  Player.reset(case[2],case[3],'up');C.setLevel(case[4],game);C.yaw=case[5];C.pitch=.15;U.wait(35)
  assert(C.active,'scene fell back');assert(U.shot(game,dir..'/'..case[1]..'.png'))
 end
 C.setLevel(0,game);U.wait(12);assert(not C.active);assert(U.shot(game,dir..'/native.png'))
 print('[Oak lab] CAPTURED '..version..' player(8,5), rival(10,5), starter table, machine, sixteen cameras and native fallback; inspect images for visual pass')
 love.event.quit()
end
