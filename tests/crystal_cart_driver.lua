-- Real-engine integration checks, disposable Crystal identity only.
return function(game)
  local U=dofile("tests/drivers/util.lua")
  local Screens=require("src.ui.Screens")
  local Runtime=require("src.mods.Runtime")
  local Mon=require("src.battle.gen2.Mon")
  local P=require("src.render.Pipelines")
  local dir=assert(os.getenv("SHOT_DIR"))
  local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib
  for _,id in ipairs({"overworld_wild_spawns","BATTLE_ART_VOXEL_FORK",
    "free_fly","gen2_modern_ui","gen3_box","modern_johto","npc_bubbles",
    "running_shoes","wild_skies","crystal_animated_sprites_with_shiny_visuals"}) do
    assert(game.mods.mods[id] and game.mods.mods[id].state=="loaded",id.." not loaded")
  end
  game.world.trySceneScript=function()return false end
  game.world.rollEncounter=function()return nil end
  game.save.party={Mon.new(game.data,"CYNDAQUIL",15),Mon.new(game.data,"TOTODILE",12)}
  assert(game.world:setMap("PLAYERS_HOUSE_1F",3,6,"right"))
  P.setLevel("voxel",3);P.setLevel("tiltshift",0)
  U.wait(180)
  local function speed(held)
    return Runtime.call("movement.speed",function(frames)return frames end,16,
      {player=game.world.player,input={isDown=function(_,b)return held and b=="b" end}})
  end
  assert(speed(false)==16,"walking speed changed without B")
  assert(speed(true)<16,"Running Shoes did not accelerate a Crystal step")
  local phases={}
  for i=1,25 do
    game.input.state.right=true
    game.input.pressQueue[#game.input.pressQueue+1]="right"
    U.wait(1)
    local p=game.world.player
    local _,_,_,_,phase=p:pose()
    phases[phase]=true
  end
  game.input.state.right=false
  assert(phases[0] and (phases[1] or phases[2]),"Free Fly froze the walk pose")
  print("[cart] running speed and Free Fly walk phases PASS")
  local start=Screens.push(game,"Gen2StartMenu")
  U.wait(90);assert(U.shot(game,dir.."/start-menu.png"));game.stack:pop()
  local pc=Screens.push(game,"Gen2PcMenu",{bills=true})
  local boxes
  for _,row in ipairs(pc.entries) do if row.label=="BOXES" then boxes=row end end
  assert(boxes and boxes.onSelect,"Gen 3 Boxes missing from Crystal storage PC")
  U.wait(90);assert(U.shot(game,dir.."/pc-menu.png"))
  boxes.onSelect();U.wait(100)
  assert(game.stack:top().screenId=="Gen3Box","storage row opened the wrong screen")
  assert(U.shot(game,dir.."/gen3-boxes.png"))
  U.hold(game,"b",2);U.wait(60)
  print("[cart] after box B",game.stack:top().screenId)
  assert(U.shot(game,dir.."/boxes-back.png"))
  assert(game.stack:top()==pc,"B did not return from boxes to PC")
  game.stack:pop()
  Screens.push(game,"Gen2SummaryMenu",{mon=game.save.party[1],party=game.save.party,index=1})
  U.wait(90);assert(U.shot(game,dir.."/summary.png"));game.stack:pop()
  -- Optional balance feature: verify its real hook and restore the default.
  local previous=game.mods.modOptions.modern_johto
  game.mods.modOptions.modern_johto={split=true,ai=false}
  local types=game.data.type_chart.types
  local c={moveId="BITE",opts={moveType="DARK",types=types}}
  local changed=Runtime.call("battle.damage",function(ctx)return ctx end,c)
  assert(changed~=c and changed.opts.types.DARK.category=="physical","Modern Johto split did not apply")
  assert(c.opts.types.DARK.category~="physical","split mutated the shared type record")
  game.mods.modOptions.modern_johto=previous
  assert(#game.mods.errors==0,"mod runtime errors")
  print("[cart] PASS: eleven mods; modern menus, native PC entry, boxes/back, summary, optional split")
end
