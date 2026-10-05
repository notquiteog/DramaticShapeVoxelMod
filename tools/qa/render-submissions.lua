-- Isolated 180-frame submission census, not an FPS benchmark. Companion actors
-- remain live; compare actual sends to requests within the same sample.
return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'))
 local U=dofile('tests/drivers/util.lua');local v=require('src.core.GameVersion').get()
 local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib
 local update=game.update;game.update=function(self,dt)self.input:reset();return require('src.mods.Runtime').call('core.update',update,self,dt)end
 love.window.setMode(2560,1440,{vsync=0})
 if v=='yellow'then
  game.stack:clear();game.stack:push(require('src.world.OverworldController'),'VIRIDIAN_FOREST',10,20,'up')
 elseif v=='crystal'then
  game.world.noWildEncounters=true;game.world.trySceneScript=function()return false end;game.world.rollEncounter=function()return nil end
  assert(game.world:setMap('ILEX_FOREST',10,20,'up'));game.world.vm=nil;game.world.textbox=nil
 else
  game:_handleBootAction({action='new_game',start={map=v=='emerald'and'EM_PETALBURG_WOODS'or'FR_VIRIDIAN_FOREST',x=10,y=20,facing='up'}})
  require('src.ui.game3.map_preview_screen').reset()
 end
 V.require('VoxelGrid').set(false,game)
 if v=='yellow'or v=='crystal'then require('src.render.Pipelines').setLevel('voxel',3)else V.require('Gen3Integration').setLevel(3,game)end
 V.require('Shadows').setting:sync('high');U.wait(160)
 local sh=love.graphics.newShader('vec4 effect(vec4 c, Image t, vec2 uv, vec2 xy){return c*Texel(t,uv);}')
 local methods=getmetatable(sh).__index;local send=methods.send;local count=0
 methods.send=function(self,name,...)if name=='model'or name=='sunModel'then count=count+1 end;return send(self,name,...)end
 local requests=0
 for _,entry in ipairs{{V.require('Voxel3D'),2},{V.require('ShadowMap'),1}}do
  local obj,mult=entry[1],entry[2];local draw=obj.draw
  obj.draw=function(mesh,...)if mesh then requests=requests+mult end;return draw(mesh,...)end
 end
 local old=love.draw;local elapsed,frames=0,0
 love.draw=function(...)local t=love.timer.getTime();local r=old(...);elapsed=elapsed+love.timer.getTime()-t;frames=frames+1;return r end
 U.wait(180)
 methods.send=send;love.draw=old
 print('[render-perf]',v,'frames',frames,'drawCPUms',elapsed*1000/math.max(1,frames),'matrixSends',count,'matrixRequests',requests)
 U.shot(game,os.getenv('SHOT_DIR')..'/forest.png');love.event.quit()
end
