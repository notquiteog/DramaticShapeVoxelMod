return function(game)
 local U=dofile('tests/drivers/util.lua')
 local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib
 local P=require('src.render.Pipelines')
 assert(game.world:setMap('NEW_BARK_TOWN',7,5,'down'))
 P.setLevel('voxel',3)
 game.world.trySceneScript=function()return false end
 local wild=game.mods.exports.overworld_wild_spawns.logic
 local tracked={}
 local function sample(e,label,dt)
  if type(e.px)~='number' or type(e.py)~='number' then return end
  local t=tracked[e]
  if not t then t={label=label,x=e.px,y=e.py,maxSpeed=0,distance=0,moves=0};tracked[e]=t;return end
  local distance=math.sqrt((e.px-t.x)^2+(e.py-t.y)^2)
  if distance>0 then
   local speed=distance/math.max(dt,.001)
   if speed>t.maxSpeed then t.maxSpeed=speed;t.jump=distance end
   t.distance=t.distance+distance;t.moves=t.moves+1
  end
  t.x,t.y=e.px,e.py
 end
 local last=love.timer.getTime()
 for _=1,1200 do
  U.wait(1)
  local now=love.timer.getTime();local dt=now-last;last=now
  for _,e in pairs(wild.entities) do sample(e,'wild:'..tostring(e.speciesId or e.species)..':'..tostring(e.behavior),dt) end
  for _,e in ipairs(game.world.entities) do
   sample(e,(e.wildSkiesFlyer and 'sky:' or 'npc:')..tostring(e.species or (e.sprite and e.sprite.def and e.sprite.def.id) or e.id),dt)
  end
 end
 for _,t in pairs(tracked) do print('[motion]',t.label,'max px/s',t.maxSpeed,'max jump',t.jump,'distance',t.distance,'moving frames',t.moves) end
 assert(U.shot(game,assert(os.getenv('SHOT_DIR'))..'/NEW_BARK_spawn_motion.png'))
end
