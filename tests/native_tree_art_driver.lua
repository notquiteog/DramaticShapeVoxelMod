return function(game)
 local U=dofile('tests/drivers/util.lua');local dir=assert(os.getenv('SHOT_DIR'))
 local version=require('src.core.GameVersion').get()
 assert(love.filesystem.getIdentity()=='source-art-'..version..'-030-qa')
 assert(require('src.core.Version').engine=='0.3.0')
 love.window.setMode(1600,900,{resizable=true})
 game:_handleBootAction({action='new_game',start={map='FR_PALLET_TOWN',x=10,y=9,facing='up'}})
 local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib;local C=V.require('Gen3Integration')
 local Native=V.require('NativeTreeArt');local Map=require('src.core.game3.map');local Tiles=require('src.core.game3.tileset_native')
 for _,case in ipairs({{'FR_PALLET_TOWN',10,9,36},{'FR_VIRIDIAN_FOREST',29,6,676}})do
  Map.load(nil,game,case[1],{x=case[2],y=case[3],facing='up'})
  U.wait(250)
  local ts=Tiles.get(Map.currentDef().midLayout.pair);local forest=case[4]==676
  local rows=forest and {{1,641,1},{648,649,650},{656,657,658},{672,673,674},{675,676,677}} or {{14,15},{28,29},{36,37}}
  for _,row in ipairs(rows)do for _,mid in ipairs(row)do assert(ts.midToSlot[mid],'missing source tree metatile '..mid..' in '..case[1])end end
  local card=assert(Native.gen3({ts=ts,mid=case[4],shape={ground=1,spacing=forest and 3 or nil}}))
  local img=Native.image();local iw,ih=img:getDimensions()
  local canvas=love.graphics.newCanvas(card.w*8,card.h*8)
  love.graphics.push('all');love.graphics.setCanvas(canvas);love.graphics.origin();love.graphics.setShader();love.graphics.clear(.35,.35,.35,1);love.graphics.setColor(1,1,1)
  local q=love.graphics.newQuad(card.u0*iw,card.v0*ih,card.w,card.h,iw,ih)
  love.graphics.draw(img,q,0,0,0,8,8);love.graphics.pop()
  local data=canvas:newImageData();local png=data:encode('png');local f=assert(io.open(dir..'/'..case[1]..'_cutout.png','wb'));f:write(png:getString());f:close()
  q:release();canvas:release();data:release()
  for _,level in ipairs({0,3,7,6})do C.setLevel(level,game);C.yaw=.55;C.pitch=.15;U.wait(45)
   assert((level==0)==not C.active);assert(U.shot(game,dir..'/'..case[1]..'_'..level..'.png'))
  end
 end
 print('[original trees] PASS '..version..' complete source tiles, native cutouts and static/free-camera views')
 love.event.quit()
end
