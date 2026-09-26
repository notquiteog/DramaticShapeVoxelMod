-- Isolated native driver: artificial 135px traversal measures rebuild stalls.
-- This is a rendering benchmark, not collision or gameplay validation.
return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'))
 local update=game.update;game.update=function(self,dt)return require('src.mods.Runtime').call('core.update',update,self,dt)end
 local U=dofile('tests/drivers/util.lua');love.window.setMode(2560,1440,{vsync=0,fullscreen=true,fullscreentype='desktop'})
 print('[perf renderer]',love.graphics.getRendererInfo())
 local V=assert(game.mods.exports.BATTLE_ART_VOXEL_FORK).lib
 local C,Scene,Shadow=V.require('Gen3Integration'),V.require('Gen3Scene'),V.require('ShadowMap')
 local shadowSetting=V.require('Shadows').setting
 V.require('AntiAlias').setting:sync(0);V.require('SpatialUpscale').setting:sync(1)
 V.require('RenderDistance').setting:sync('auto');V.require('CommunityVisuals').treeDetail:sync('balanced')
 V.require('TreePresentation').art:sync('modeled');V.require('Gen3SceneOptions').tilt:sync(0)
 local timings={};local lastStats={}
 local function wrap(obj,key,label)
  local fn=obj[key];if type(fn)~='function'then return end
  obj[key]=function(...)local t=love.timer.getTime();local r=fn(...);timings[label]=(timings[label]or 0)+love.timer.getTime()-t;return r end
 end
 wrap(love,'update','update');wrap(love,'draw','draw');wrap(love.graphics,'present','present')
 local Present=require('src.core.PresentSync')
 wrap(Present,'waitBeforePresent','pacing');wrap(Present,'notePresent','notePresent');wrap(Present,'applyFixedStepPeriod','fixedStep')
 local oldDraw=love.draw;love.draw=function(...)local r=oldDraw(...);lastStats=love.graphics.getStats();return r end
 local shadowCalls,shadowTime,shadowStart,sceneTime,sceneCalls=0,0,nil,0,0
 local begin,finish,draw=Shadow.begin,Shadow.finish,Scene.draw
 Shadow.begin=function(...)local t=love.timer.getTime();local ok=begin(...);if ok then shadowStart=t;shadowCalls=shadowCalls+1 end;return ok end
 Shadow.finish=function(...)local r=finish(...);if shadowStart then shadowTime=shadowTime+love.timer.getTime()-shadowStart;shadowStart=nil end;return r end
 Scene.draw=function(...)local t=love.timer.getTime();local r=draw(...);sceneTime=sceneTime+love.timer.getTime()-t;sceneCalls=sceneCalls+1;return r end
 game:_handleBootAction({action='new_game',start={map='FR_VIRIDIAN_FOREST',x=10,y=20,facing='up'}})
 C.setLevel(7,game);C.yaw=.8;C.pitch=.25;U.wait(120)
 local Player=require('src.core.game3.player')
 local startX,startY=Player.px,Player.py
 for _,moving in ipairs({false,true})do
  local samples={};local count=Scene.builds;local last=love.timer.getTime()
  for i=1,180 do
   if moving then Player.px=startX+i*.75 end
   C.yaw=.8+i*.003
   U.wait(1);local now=love.timer.getTime();samples[i]=(now-last)*1000;last=now
  end
  table.sort(samples);local sum=0;for _,t in ipairs(samples)do sum=sum+t end
  print(string.format('[perf walking] move=%s mean=%.2f p95=%.2f max=%.2f rebuilds=%d render=%dx%d',tostring(moving),sum/#samples,samples[171],samples[180],Scene.builds-count,Scene.renderWidth,Scene.renderHeight))
 end
 Player.px,Player.py=startX,startY
 U.shot(game,os.getenv('SHOT_DIR')..'/forest-performance.png')
 love.event.quit()
end
