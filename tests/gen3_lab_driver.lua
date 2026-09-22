return function(game)
 local U=dofile('tests/drivers/util.lua');local dir=assert(os.getenv('SHOT_DIR'));local version=require('src.core.GameVersion').get()
 assert(love.filesystem.getIdentity()=='source-art-'..version..'-030-qa');assert(require('src.core.Version').engine=='0.3.0')
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
 for _,case in ipairs({{'static',6,6,3,0},{'machine',4,6,6,-1.1},{'table',9,6,6,0},
  {'back_wall',6,3,6,0},{'front',6,7,7,0},{'east',6,7,7,-math.pi/2},{'back',6,7,7,math.pi},{'west',6,7,7,math.pi/2}})do
  assert(Collision.isWalkable(case[2],case[3]),'invalid camera position '..case[1])
  Player.reset(case[2],case[3],'up');C.setLevel(case[4],game);C.yaw=case[5];C.pitch=.15;U.wait(35)
  assert(C.active,'scene fell back');assert(U.shot(game,dir..'/'..case[1]..'.png'))
 end
 C.setLevel(0,game);U.wait(12);assert(not C.active);assert(U.shot(game,dir..'/native.png'))
 print('[Oak lab] PASS '..version..' complete machine, three supported balls, eight cameras and native fallback')
 love.event.quit()
end
