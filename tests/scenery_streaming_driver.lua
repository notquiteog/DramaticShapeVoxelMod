-- Isolated native driver: artificial 135px traversal measures rebuild stalls.
-- This is a rendering benchmark, not collision or gameplay validation.
return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'))
 local update=game.update;game.update=function(self,dt)return require('src.mods.Runtime').call('core.update',update,self,dt)end
 local U=dofile('tests/drivers/util.lua');love.window.setMode(2560,1440,{vsync=0,fullscreen=true,fullscreentype='desktop'})
 print('[perf renderer]',love.graphics.getRendererInfo())
 local V=assert(game.mods.exports.BATTLE_ART_VOXEL_FORK).lib
 local C,Scene=V.require('Gen3Integration'),V.require('Gen3Scene')
 V.require('AntiAlias').setting:sync(0);V.require('SpatialUpscale').setting:sync(1)
 V.require('RenderDistance').setting:sync('auto');V.require('CommunityVisuals').treeDetail:sync('balanced')
 V.require('TreePresentation').art:sync('modeled');V.require('Gen3SceneOptions').tilt:sync(0)
 game:_handleBootAction({action='new_game',start={map='FR_VIRIDIAN_FOREST',x=10,y=20,facing='up'}})
 require('src.ui.game3.map_preview_screen').reset()
 C.setLevel(7,game);C.yaw=.8;C.pitch=.25;U.wait(120)
 local Player=require('src.core.game3.player')
 local startX,startY=Player.px,Player.py
 for _,moving in ipairs({false,true})do
  local samples={};local count=Scene.builds;local last=love.timer.getTime()
  for i=1,210 do
   if moving then Player.px=startX+math.min(i,180)*.75 end
   C.yaw=.8+i*.003
   U.wait(1);local now=love.timer.getTime();samples[i]=(now-last)*1000;last=now
  end
  table.sort(samples);local sum=0;for _,t in ipairs(samples)do sum=sum+t end
  print(string.format('[perf walking] move=%s mean=%.2f p95=%.2f max=%.2f rebuilds=%d render=%dx%d',tostring(moving),sum/#samples,samples[math.ceil(#samples*.95)],samples[#samples],Scene.builds-count,Scene.renderWidth,Scene.renderHeight))
 end
 print('[streaming stats]',Scene.streaming and Scene.streaming.completed,Scene.streaming and Scene.streaming.cancelled,Scene.streaming and Scene.streaming.maxStreamSlice)
 Player.px,Player.py=startX,startY
 U.wait(40)
 U.shot(game,os.getenv('SHOT_DIR')..'/forest-performance.png')
 love.event.quit()
end
