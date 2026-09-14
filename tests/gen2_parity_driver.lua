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
  local rocks=V.require("Gen2Rocks")
  local drawRock=rocks.draw
  local liveRocks={}
  rocks.draw=function(c,shadow)
    local claimed=drawRock(c,shadow)
    if claimed and not shadow then liveRocks[c.sprite.def.id]=true end
    return claimed
  end
  local function key(x,y) return (y+64)*4096+x+64 end
  for _, id in ipairs({"BATTLE_ART_VOXEL_FORK", "npc_bubbles",
      "overworld_wild_spawns", "wild_skies", "crystal_animated_sprites_with_shiny_visuals"}) do
    assert(game.mods.mods[id] and game.mods.mods[id].state == "loaded", id .. " not loaded")
  end
  local travel=game.mods.mods.DRAMATIC_SKY_RIDE or game.mods.mods.free_fly
  assert(travel and travel.state=="loaded","travel companion not loaded")
  if os.getenv("CURRENT_CART_QA")=="1" then
    for _,id in ipairs({"gen1online-plus","double_battles","DRAMATIC_SKY_RIDE",
      "kanto_gear","gen3_box","gen2_modern_ui","running_shoes","modern_johto"}) do
      assert(game.mods.mods[id] and game.mods.mods[id].state=="loaded",id.." not loaded")
    end
  end
  local function checkLoader()
    for _,message in ipairs(game.mods.errors) do
      -- The cart's independently published Online+ 0.5.0 declares a Gen 1
      -- map-script registry. Record that known incompatibility explicitly;
      -- never permit unrelated loader errors or claim its casino is tested.
      assert(os.getenv("HD_SCENERY_QA")=="1" and message==
        "gen1online-plus: the map_scripts registry has no Gen 2 target; those registrations do not apply here",message)
      print("[companion incompatibility]",message)
    end
  end
  checkLoader()
  game.world.trySceneScript = function() return false end
  game.world.rollEncounter = function() return nil end
  P.setLevel("voxel",3)
  P.setLevel("tiltshift",0)
  V.require("DayNight").setting:sync("day")
  local shots = {
    {"NEW_BARK_TOWN",7,5}, {"ROUTE_29",12,6}, {"VIOLET_CITY",10,10}, {"CHERRYGROVE_CITY",21,11}, {"CHERRYGROVE_CITY",5,12,"CHERRYGROVE_coastal_rocks"},
    {"ELMS_LAB",4,4}, {"ELMS_LAB",4,9,"ELMS_LAB_entrance"}, {"PLAYERS_HOUSE_1F",3,6},
    {"CHERRYGROVE_POKECENTER_1F",4,4}, {"DARK_CAVE_VIOLET_ENTRANCE",7,15}, {"BLACKTHORN_GYM_2F",5,5},
  }
  if os.getenv("HD_SCENERY_QA")=="1" then
    for _,loc in ipairs({{"ILEX_FOREST",10,10},{"NATIONAL_PARK",15,15},
      {"ROUTE_14",10,10},{"GOLDENROD_CITY",15,15},{"BILLS_FAMILYS_HOUSE",3,5},
      {"AZALEA_MART",4,4},{"PLAYERS_HOUSE_2F",3,3}}) do shots[#shots+1]=loc end
  end
  for _, loc in ipairs(shots) do
    assert(game.world:setMap(loc[1],loc[2],loc[3],"down"))
    local Permissions=require("src.world.gen2.Permissions")
    local map=game.world.map
    if Permissions.of(map:cellCollision(loc[2],loc[3]))==Permissions.WALL then
      local found
      for radius=1,6 do
        for dy=-radius,radius do for dx=-radius,radius do
          local x,y=loc[2]+dx,loc[3]+dy
          if not found and map:inBounds(x,y)
            and Permissions.of(map:cellCollision(x,y))==Permissions.LAND then found={x,y} end
        end end
        if found then break end
      end
      assert(found,"no clear camera position")
      loc[2],loc[3]=found[1],found[2]
      assert(game.world:setMap(loc[1],loc[2],loc[3],"down"))
    end
    print("[camera]",loc[1],loc[2],loc[3])
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
    local Permissions=require("src.world.gen2.Permissions")
    assert(Permissions.of(map:cellCollision(loc[2],loc[3]))~=Permissions.WALL,"camera placed on blocked scenery")
    for _,f in ipairs(S.furniture or {}) do
      assert(f.height>0 and f.x1>f.x0 and f.z1>f.z0,"empty furniture model: "..f.id)
      if f.support>0 then assert(f.support<=8,"table too tall: "..f.id) end
      print("[furniture]",f.id,"height="..f.height,"depth="..(f.z1-f.z0))
    end
    if loc[1]=="ELMS_LAB" then
      assert(V.require("VoxelScene").groundAt(map,6,3)==6,"starter ball support differs from table")
    elseif loc[1]=="PLAYERS_HOUSE_1F" then
      assert(V.require("VoxelScene").groundAt(map,5,4)==6,"dining table support")
      assert(V.require("VoxelScene").groundAt(map,5,5)==0,"table apron incorrectly raises walkable floor")
    end
    local counts, unclaimed = {}, 0
    for cy=0,map.heightCells-1 do for cx=0,map.widthCells-1 do
      local tx,ty=cx*2,cy*2
      local s=Shapes.at(map,shapes,map:tileAt(tx,ty),tx,ty)
      counts[s.class]=(counts[s.class] or 0)+1
      if s.class=="foresttree" or s.class=="roundtree" or s.class=="tree" or s.class=="bush" or s.class=="rock" or s.class=="boulder" or s.class=="oceanrock" then
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
    assert(U.shot(game,dir.."/"..(loc[4] or loc[1])..".png"))
    if os.getenv("HD_SCENERY_QA")=="1" and loc[1]=="NEW_BARK_TOWN" then
      P.setLevel("depth_of_field",2)
      U.wait(10)
      assert(V.require("DepthOfField").lastApplied,"depth-of-field shader did not run")
      assert(U.shot(game,dir.."/NEW_BARK_depth_of_field.png"))
      P.setLevel("depth_of_field",0)
    end
  end
  checkLoader()
  assert(liveRocks.SPRITE_ROCK and liveRocks.SPRITE_BOULDER,"live rock actors did not render as models")
  rocks.draw=drawRock
  print("[parity] PASS: full cart loaded; round ownership and ledge height verified")
end
