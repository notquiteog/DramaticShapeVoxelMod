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
local Palette = require("src.render.GbcPalette")

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
local function picFor(game,screen,mon,back,static)
  local owned=V.require('NativeBattleArt').image(mon,back)
  if owned then local w,h=owned:getDimensions();return owned,w,h,nil,true,nil,true end
  local providers=game and game.mods and game.mods.exports
  local provider=V.crystalSpritesActive and V.mod.exports.crystalSprites
    or (providers and providers.crystal_animated_sprites_with_shiny_visuals)
  if provider and type(provider.stagedPokemonSprite)=="function" then
    local ok,pic=pcall(provider.stagedPokemonSprite,mon,back)
    if ok and pic and pic.image and type(pic.width)=="number"
       and type(pic.height)=="number" and pic.width>0 and pic.height>0 then
      return pic.image,pic.width,pic.height,pic.quad,nil,pic.groundY,pic.trueColor~=false
    end
  end
  local ok,image,trueColor=pcall(screen.pic,screen,mon,back)
  if not (ok and image) then return nil end
  if not static and not back and screen.frontAnimFrame then
    local sheet,quad,size=screen:frontAnimFrame(mon)
    if sheet and quad and type(size)=='number'and size>0 then
      local _,h=image:getDimensions()
      local feet=V.require('BattleSpriteFooting').bounds(image)[4]+size-h
      return sheet,size,size,quad,nil,feet,trueColor
    end
  end
  local sized,w,h=pcall(image.getDimensions,image)
  if sized and w and h and w>0 and h>0 then return image,w,h,nil,nil,nil,trueColor end
end
Gen2Staged.picFor=picFor
local function drawPic(g,image,quad,x,y,scale)
  scale=scale or 1
  if quad then g.draw(image,quad,x,y,0,scale,scale) else g.draw(image,x,y,0,scale,scale) end
end
local RESIZE_TILES={[0]=6,[1]=4,[2]=2,[3]=7,[4]=5,[5]=3}
-- Read native picture state; never leave a full-size world body behind a
-- hidden/withdrawn mon. Composite native effects keep their original painter.
local function poseFor(screen,side,mon,back)
  -- Supported Legendary intake already owns hiding/shrinking this enemy.
  -- Its world card must survive the native box-clear until the 3D beat ends.
  if side=='enemy'and V.require('Gen2Capture').active(screen,screen.anim)then return 1,0,nil,0,false end
  if screen.picBoxCleared and screen:picBoxCleared(side)then return end
  if screen.isUnderground and screen:isUnderground(side,mon)
    and not(screen.vanishAnim and screen.vanishAnim==screen.anim)then return end
  local sink=screen.faintSink and screen:faintSink(side)or 0
  local anim=screen.animPicState and screen:animPicState(side)
  local substitute=mon.volatile and (tonumber(mon.volatile.substitute)or 0)>0
  if anim and anim.pic~=nil then substitute=anim.pic=='substitute'end
  if anim and anim.lifted then return end
  local scale=anim and RESIZE_TILES[anim.size]
  scale=scale and scale/(back and 6 or 7)or 1
  local slide=anim and anim.slide or 0
  if screen.battle and screen.battle.doubles and(scale~=1 or slide~=0 or sink>0 or substitute)then return end
  return scale,slide,anim and anim.shade,sink,substitute
end

function Gen2Staged.sideTexture(game, side)
  Gen2Staged.drawn[side],Gen2Staged.drawn[side.."2"]=nil,nil
  local screen = screenFor(game)
  if not screen then return nil end
  local back = (side == "player" or side == "player2")
  if (back and screen.showPlayerTrainer) or (not back and screen.showEnemyTrainer)then return nil end
  -- The native back slot remains the owner in OG UI mode. Leaving this side
  -- out of drawn lets Gen2Battle's ordinary drawPic run exactly once.
  if back and V.require('BattleArt').backPlacementSetting:get()=='ui' then return nil end
  local okMon, mon = pcall(screen.activeMon, screen, side)
  if not (okMon and mon) then return nil end
  local poseScale,poseSlide,poseShade,poseSink,dollUp=poseFor(screen,side,mon,back)
  if not poseScale then return nil end
  local image,iw,ih,quad,selectedArt,groundY,trueColor=picFor(game,screen,mon,back,poseSink>0)
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
  local pimage, pquad,pground,ptrueColor = nil,nil,nil,nil
  local iw2,ih2=0,0
  if partner then
    local selected
    pimage,iw2,ih2,pquad,selected,pground,ptrueColor=picFor(game,screen,partner,back)
    if not pimage then iw2,ih2=0,0 end
  end

  local Foot=V.require('BattleSpriteFooting')
  local box=Foot.bounds(image,quad)
  local pbox=pimage and Foot.bounds(pimage,pquad)
  local Art=V.require('BattleArt')
  local metric=Art.metrics and Art.metrics(image)
  local pm=pimage and Art.metrics and Art.metrics(pimage)
  groundY=groundY or (metric and metric.y1+1) or box[4]
  pground=pground or (pm and pm.y1+1) or (pbox and pbox[4])
  local sinkPixels=poseSink
  if poseSink>0 then
    -- Selected world frames may be larger than the original fitted UI slot.
    -- Convert the native pixel clock through that public slot's actual scale.
    local ok,native,_,path=pcall(screen.pic,screen,mon,back)
    if ok and native then
      local _,nh=native:getDimensions()
      local scale=screen.picScale and screen:picScale(path,mon,back)or 1
      if nh>0 and scale>0 then sinkPixels=poseSink*ih/(nh*scale)end
    end
  end
  local doll,dollQuad,dollWidth,dollGround
  if dollUp then
    if not screen.substituteDoll then return nil end
    doll,dollQuad=screen:substituteDoll(back)
    if not(doll and dollQuad and dollQuad.getViewport)then return nil end
    local _,_,w=dollQuad:getViewport();dollWidth=w
    dollGround=Foot.bounds(doll,dollQuad)[4]
  end
  local BattleScene = V.require("BattleScene")
  local cw = math.max(BattleScene.GB_W or 160, iw + iw2 + 2)
  local ch = math.max(BattleScene.GB_H or 144, math.max(ih, ih2) + 2)
  local ax = cw / 2
  local ay = ch - FOOT_PAD
  local canvas = canvasFor(side, cw, ch)
  if not canvas then return nil end

  local function paint(mon,colored,fn)
    local colors=screen.palettes and screen.cachedMonColors and screen:cachedMonColors(mon.species,mon.shiny)
    if screen.introGrayscale and screen:introGrayscale()then colors=require('src.world.gen2.Palettes').BLACKOUT end
    if colors and poseShade then colors=Palette.remap(colors,poseShade)end
    if colors and not(colored and Palette.mode=='gbc')and Palette.available()then return Palette.with(colors,fn)end
    return fn()
  end
  local g = love.graphics
  local prev = g.getCanvas()
  local pr, pg, pb, pa = g.getColor()
  local sx,sy,sw,sh
  if poseSink>0 then
    if not(g.getScissor and g.setScissor)then return nil end
    sx,sy,sw,sh=g.getScissor()
  end
  local okDraw = pcall(function()
    g.setCanvas(canvas)
    g.clear(0, 0, 0, 0)
    g.setColor(1, 1, 1, 1)
    -- centred on ax with the feet on ay, which is the anchor contract
    -- BattleScene.billboard reads (tw / 2 - ax, th - ay).  With a partner,
    -- the lead sits left of centre and the partner right of it, feet on
    -- the same ground line.
    if pimage then
      paint(mon,trueColor,function()drawPic(g,image,quad,ax-iw,ay-groundY)end)
      paint(partner,ptrueColor,function()drawPic(g,pimage,pquad,ax,ay-pground)end)
    elseif doll then
      -- The native 16px doll keeps its own facing and indexed species colors;
      -- the actor card retains the mon's bounds, so it is not inflated to a mon.
      paint(mon,false,function()drawPic(g,doll,dollQuad,ax-dollWidth/2+poseSlide,ay-dollGround)end)
    else
      -- Match native sinking rows while clipping at the world's fixed ground
      -- line. A fully sunk transparent card still owns the native flat slot.
      if poseSink>0 then g.setScissor(0,0,cw,ay)end
      paint(mon,trueColor,function()drawPic(g,image,quad,ax-iw*poseScale/2+poseSlide,ay-groundY*poseScale+sinkPixels,poseScale)end)
    end
  end)
  g.setCanvas(prev)
  if poseSink>0 then
    if sx then g.setScissor(sx,sy,sw,sh)else g.setScissor()end
  end
  g.setColor(pr, pg, pb, pa)
  if not okDraw then return nil end

  Gen2Staged.drawn[side] = mon
  if partner then Gen2Staged.drawn[side .. "2"] = partner end
  -- The native back slot already faces up-field. Gen 1's staged front-pic
  -- mirror would turn this back sprite away from its opponents a second time.
  return { canvas = canvas, ax = ax, ay = ay, trainer = false,
    hudAnchors={
      [side]={pimage and ax-iw/2 or ax,ay-groundY+box[2]},
      [side..'2']=pimage and {ax+iw2/2,ay-pground+pbox[2]}or nil,
    },
    noMirror=back and not (selectedArt and V.require('BattleArt').playerSide()=='front'
      and V.require('BattleArt').flipsPlayerFront()),
    modernFraming=true,contentWidth=iw+iw2,contentHeight=math.max(ih,ih2) }
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
