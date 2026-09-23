-- The staged battle's billboard textures, on Gold, Silver and Crystal.
--
-- OverworldBattle stages a fight by rendering each side's pic into its own
-- small canvas with a known anchor -- centred on `ax`, feet on `ay` -- and
-- handing those to BattleScene, which hangs them in the 3D scene as quads
-- standing on the arena's ground. Everything about that is generation
-- neutral except where the pic comes from.
--
-- The Gen 1 route cannot be reused. OverworldBattle.sideTexture drives the
-- engine's own `drawPicsLayer` with the battle's fields temporarily swapped
-- (`OFF[side]`), and reads `battle.enemy`, `battle.player`,
-- `battle.trainerPic`, `battle.showPlayerBack`. None of that exists on Gen 2:
-- Gold has no drawPicsLayer, and its battlers live under
-- `battle.sides[i].battlers` rather than on two named fields.
--
-- Gold offers something better for this particular job, though. Its battle
-- screen resolves a pic to an IMAGE through two members the compatibility
-- layer leaves in place:
--
--   screen:activeMon(side)     the live battler, "enemy" / "player"
--   screen:pic(mon, back)      -> image, trueColor, path
--
-- so the texture can be drawn directly instead of by re-entering a draw
-- layer with the screen's state bent around it. That is both simpler and
-- less invasive -- nothing on the battle is mutated and put back.
--
-- And `pic` is the right seam rather than merely a convenient one: it
-- resolves through the engine's `pokemon.sprite` hook
-- (src/ui/gen2/BattleState.lua:750), which this mod already owns. So the art
-- that lands on the billboard is the art BATTLE ART selected -- the chosen
-- generation, shiny routing and all -- exactly as on Gen 1.

local V = ...
local Generation = V.require("Generation")

local Gen2Staged = {}

-- The live Gen 2 battle screen. Found by walking the stack rather than
-- captured in a draw wrapper, because the textures are rendered from the
-- pipeline's UPDATE tick, before anything has drawn this frame.
local function screenFor(game)
  local stack = game and game.stack
  local states = stack and stack.states
  if type(states) ~= "table" then return nil end
  for i = #states, 1, -1 do
    local s = states[i]
    if type(s) == "table" and type(s.activeMon) == "function"
       and type(s.pic) == "function" then
      return s
    end
  end
  return nil
end

Gen2Staged.screenFor = screenFor
function Gen2Staged.holdsScene(game,battle)
  local screen=screenFor(game)
  return screen~=nil and screen.battle==battle
end

-- One canvas per side, kept and resized rather than reallocated per frame.
local canvases = {}

local function canvasFor(side, w, h)
  local g = love.graphics
  if not (g and g.newCanvas) then return nil end
  local held = canvases[side]
  if held and held:getWidth() >= w and held:getHeight() >= h then
    return held
  end
  local ok, canvas = pcall(g.newCanvas, w, h)
  if not ok or not canvas then return nil end
  if canvas.setFilter then pcall(canvas.setFilter, canvas, "nearest", "nearest") end
  canvases[side] = canvas
  return canvas
end

function Gen2Staged.release()
  for side, canvas in pairs(canvases) do
    if canvas and canvas.release then pcall(canvas.release, canvas) end
    canvases[side] = nil
  end
end

-- Which sides a billboard was actually drawn for this frame, so the flat
-- panel can skip exactly those mons and nothing else (lib/Gen2Battle.lua
-- reads this). Cleared at the top of every textures() pass.
Gen2Staged.drawn = {}

-- The padding the Gen 1 anchor uses, so a pic's feet sit on the ground quad
-- rather than one pixel through it.
local FOOT_PAD = 1

-- Companions own art. A staged provider may supply full-body animation
-- without replacing the original engine screen or reaching into its files.
local function picFor(game,screen,mon,back)
  local owned=V.require('NativeBattleArt').image(mon,back)
  if owned then local w,h=owned:getDimensions();return owned,w,h end
  local providers=game and game.mods and game.mods.exports
  local provider=providers and providers.crystal_animated_sprites_with_shiny_visuals
  if provider and type(provider.stagedPokemonSprite)=="function" then
    local ok,pic=pcall(provider.stagedPokemonSprite,mon,back)
    if ok and pic and pic.image and type(pic.width)=="number"
       and type(pic.height)=="number" and pic.width>0 and pic.height>0 then
      return pic.image,pic.width,pic.height,pic.quad
    end
  end
  local ok,image=pcall(screen.pic,screen,mon,back)
  if not (ok and image) then return nil end
  local sized,w,h=pcall(image.getDimensions,image)
  if sized and w and h and w>0 and h>0 then return image,w,h end
end
Gen2Staged.picFor=picFor
local function drawPic(g,image,quad,x,y)
  if quad then g.draw(image,quad,x,y) else g.draw(image,x,y) end
end

function Gen2Staged.sideTexture(game, side)
  local screen = screenFor(game)
  if not screen then return nil end
  local back = (side == "player" or side == "player2")
  local okMon, mon = pcall(screen.activeMon, screen, side)
  if not (okMon and mon) then return nil end
  local image,iw,ih,quad=picFor(game,screen,mon,back)
  if not image then return nil end

  -- A 2v2 round fields a partner beside the lead (the doubles layer keeps
  -- battle.player2 / battle.enemy2 on the battle).  Both pics compose into
  -- ONE card per side -- the same staged look the Gen 1 doubles adapter
  -- draws -- so the anchors stay one-cell honest and the flat panel skips
  -- both mons through the drawn table.
  local partner = nil
  local battle = screen.battle
  if battle and battle.doubles then
    local p2 = (side == "player" and battle.player2)
      or (side == "enemy" and battle.enemy2) or nil
    if p2 and p2 ~= mon and (p2.hp or 0) > 0 then partner = p2 end
  end
  local pimage, pquad = nil,nil
  local iw2,ih2=0,0
  if partner then
    pimage,iw2,ih2,pquad=picFor(game,screen,partner,back)
    if not pimage then iw2,ih2=0,0 end
  end

  local BattleScene = V.require("BattleScene")
  local cw = math.max(BattleScene.GB_W or 160, iw + iw2 + 2)
  local ch = math.max(BattleScene.GB_H or 144, math.max(ih, ih2) + 2)
  local ax = cw / 2
  local ay = ch - FOOT_PAD
  local canvas = canvasFor(side, cw, ch)
  if not canvas then return nil end

  local g = love.graphics
  local prev = g.getCanvas()
  local pr, pg, pb, pa = g.getColor()
  local okDraw = pcall(function()
    g.setCanvas(canvas)
    g.clear(0, 0, 0, 0)
    g.setColor(1, 1, 1, 1)
    -- centred on ax with the feet on ay, which is the anchor contract
    -- BattleScene.billboard reads (tw / 2 - ax, th - ay).  With a partner,
    -- the lead sits left of centre and the partner right of it, feet on
    -- the same ground line.
    if pimage then
      drawPic(g,image,quad,ax-iw,ay-ih)
      drawPic(g,pimage,pquad,ax,ay-ih2)
    else
      drawPic(g,image,quad,ax-iw/2,ay-ih)
    end
  end)
  g.setCanvas(prev)
  g.setColor(pr, pg, pb, pa)
  if not okDraw then return nil end

  Gen2Staged.drawn[side] = mon
  if partner then Gen2Staged.drawn[side .. "2"] = partner end
  -- The native back slot already faces up-field. Gen 1's staged front-pic
  -- mirror would turn this back sprite away from its opponents a second time.
  return { canvas = canvas, ax = ax, ay = ay, trainer = false,
    hudAnchors={
      [side]={pimage and ax-iw/2 or ax,ay-ih},
      [side..'2']=pimage and {ax+iw2/2,ay-ih2}or nil,
    },
    noMirror=back, modernFraming=true,contentWidth=iw+iw2,contentHeight=math.max(ih,ih2) }
end

-- The same shape OverworldBattle.textures returns, so BattleScene cannot tell
-- which generation built it.
function Gen2Staged.textures(game)
  if not Generation.isGen2() then return nil end
  Gen2Staged.drawn = {}
  local out = {}
  out.enemy = Gen2Staged.sideTexture(game, "enemy")
  out.player = Gen2Staged.sideTexture(game, "player")
  if not (out.enemy or out.player) then return nil end
  return out
end

return Gen2Staged
