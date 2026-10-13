return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'))
 local U=dofile('tests/drivers/util.lua');local R=require('src.mods.Runtime');local old=game.update
 game.update=function(self,dt)return R.call('core.update',old,self,dt)end
 game:_handleBootAction({action='new_game',start={map='FR_FUCHSIA_CITY',x=10,y=16,facing='up'}})
 local Space=require('src.core.game3.scripting.space');Space.runOnFrame=function()end;local vm=Space.getVm();if vm then vm:halt(true)end
 require('src.ui.game3.message').reset()
 local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib;local Map=require('src.core.game3.map');local Player=require('src.core.game3.player')
 local Collision=require('src.core.game3.collision');local Types=V.require('Gen3Tilesets');local Shapes=V.require('Gen3TileShape')
 local def=Map.currentDef();local spec=Types.resolve(def.midLayout.pair,require('src.import.gba.versions').TILESET_PAIRS)
 local target
 for y=0,def.height-4 do for x=0,def.width-1 do local mid=def.midLayout:midAt(x,y)
  if not target and Shapes.of(spec.primary,spec.secondary,mid).kind=='fence' and Collision.isWalkable(x,y+3) and not Collision.warpAt(x,y+3)then target={x=x,y=y,mid=mid}end
 end end
 assert(target);Player.reset(target.x,target.y+3,'up')
 local used=0;local F=V.require('NativeLegendaryFence');local append=F.append
 function F.append(...)local ok=append(...);if ok then used=used+1 end;return ok end
 local C=V.require('CommunityVisuals');local I=V.require('Gen3Integration');C.courtyards:setIndex(2,game);I.setLevel(3,game);V.require('Gen3Scene').invalidate()
 for i=1,1800 do U.wait(1);if used>0 then break end end;assert(used>0,'no modeled native fence consumer')
 U.wait(90);assert(U.shot(game,os.getenv('SHOT_DIR')..'/legendary.png'))
 I.setLevel(6,game);U.wait(50);assert(U.shot(game,os.getenv('SHOT_DIR')..'/first-person.png'))
 I.setLevel(3,game);C.courtyards:setIndex(1,game);V.require('TreePresentation').changed('communityCourtyards');used=0;U.wait(120)
 assert(used==0 and def.midLayout:midAt(target.x,target.y)==target.mid,'OFF/map ownership')
 assert(U.shot(game,os.getenv('SHOT_DIR')..'/native.png'));print('[PASS native Legendary fences]',target.x,target.y);love.event.quit()
end
