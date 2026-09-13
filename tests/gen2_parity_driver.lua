-- Full-cart visual/geometry regression. Run from the engine directory with
-- POKEPORT_VERSION=crystal, POKEPORT_DRIVER=<this file>, a disposable
-- POKEPORT_IDENTITY containing imported Crystal data, and SHOT_DIR.
-- Uses real maps and all installed companions. No saves or gameplay code are
-- changed by the mod; scene/encounter suppression below is harness-only.
return function(game)
  local U = dofile("tests/drivers/util.lua")
  local P = require("src.render.Pipelines")
  local exports = assert(game.mods.exports.BATTLE_ART_VOXEL_FORK)
  local V = exports.lib
  local Shapes, Structures = V.require("TileShape"), V.require("Structures")
  local Mesher, Voxel = V.require("ChunkMesher"), V.require("VoxelState")
  local dir = assert(os.getenv("SHOT_DIR"), "SHOT_DIR required")
  local function key(x,y) return (y+64)*4096+x+64 end
  for _, id in ipairs({"BATTLE_ART_VOXEL_FORK", "free_fly", "npc_bubbles",
      "overworld_wild_spawns", "wild_skies", "crystal_animated_sprites_with_shiny_visuals"}) do
    assert(game.mods.mods[id] and game.mods.mods[id].state == "loaded", id .. " not loaded")
  end
  assert(#game.mods.errors == 0, "loader errors")
  game.world.trySceneScript = function() return false end
  game.world.rollEncounter = function() return nil end
  P.setLevel("voxel",3)
  P.setLevel("tiltshift",0)
  V.require("DayNight").setting:sync("day")
  local shots = {
    {"NEW_BARK_TOWN",7,5}, {"ROUTE_29",12,6}, {"VIOLET_CITY",10,10},
    {"ELMS_LAB",5,4}, {"PLAYERS_HOUSE_1F",3,3},
    {"CHERRYGROVE_POKECENTER_1F",4,4}, {"DARK_CAVE_VIOLET_ENTRANCE",8,4},
  }
  for _, loc in ipairs(shots) do
    assert(game.world:setMap(loc[1],loc[2],loc[3],"down"))
    U.wait(10)
    local settled = false
    for _=1,2400 do
      if Mesher.pending()==0 and Voxel.ready then settled=true break end
      U.wait(1)
    end
    assert(settled, "mesh did not settle: "..loc[1])
    U.wait(140)
    local map = game.world.map
    local shapes, S = Shapes.forMap(map), Structures.forMap(map)
    local counts, unclaimed = {}, 0
    for cy=0,map.heightCells-1 do for cx=0,map.widthCells-1 do
      local tx,ty=cx*2,cy*2
      local s=Shapes.at(map,shapes,map:tileAt(tx,ty),tx,ty)
      counts[s.class]=(counts[s.class] or 0)+1
      if s.class=="tree" or s.class=="bush" or s.class=="rock" then
        if not S.skip[key(tx,ty)] then unclaimed=unclaimed+1 end
      elseif s.class=="ledge" then
        assert(s.h==6, "oversized ledge: "..loc[1])
      end
    end end
    local report={}
    for k,n in pairs(counts) do report[#report+1]=k.."="..n end
    table.sort(report)
    print("[parity]",loc[1],table.concat(report," "),"roundStamps="..#S.roundStamps,"unclaimed="..unclaimed)
    assert(unclaimed==0,"unclaimed round scenery on "..loc[1])
    assert(U.shot(game,dir.."/"..loc[1]..".png"))
  end
  assert(#game.mods.errors == 0, "loader errors at end")
  print("[parity] PASS: full cart loaded; round ownership and ledge height verified")
end
