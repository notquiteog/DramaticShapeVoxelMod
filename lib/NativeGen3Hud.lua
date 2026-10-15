local V=...
local M={}
local Layer=V.require('NativeHudLayer')
local Options=V.require('Gen3BattleOptions')
local Mode=V.require('ModernBattleUI')
local Health=require('src.core.game3.battle.healthbox')
local Battle=require('src.core.game3.battle')
local Anim=require('src.core.game3.battle.anim')
local Chrome=require('src.ui.game3.battle_chrome')
local Renderer=require('src.render.Renderer')
local Version=require('src.core.GameVersion')
-- FRLG's native healthbox fixes these three text/paper colours in its public
-- drawing implementation; unlike Hoenn its baked manifest omits the palette.
local frlgPalette={0,8+8*32+8*1024,31+31*32+27*1024,27+26*32+22*1024}
function M.draw(original,stage,side,battler,opts)
 if not(stage.active and Options.drawing and Mode.providerEnabled())or Options.covered()then return original(side,battler,opts)end
 local st=(opts and opts.st)or Battle._st
 if not st or not battler then return original(side,battler,opts)end
 local id=type(side)=='number'and side or side=='player'and 0 or 1
 local center=Health.center(st,id)
 if not center then return original(side,battler,opts)end
 local scale=Layer.scale(Options.scale:get(),Renderer:frameRects())
 local animation=Anim.stage();local boxes=animation and animation.healthbox
 local box=boxes and(boxes[id]or boxes[id%2==0 and'player'or'enemy'])
 local pal
 -- The engine's level-up flash must keep its original palette feedback.
 if not Options.ui.hudUsesColor()and not(box and box.levelUpBlend)then
  pal=Chrome.manifest().healthboxPal
  local version=Version.get()
  if not pal and(version=='firered'or version=='leafgreen')then pal=frlgPalette end
 end
 return Layer.draw('gen3',240,160,scale,id%2==0 and 240 or 0,center.y-16,pal,original,side,battler,opts)
end
return M
