-- Presentation-only native battle consumers. Bag/party/summary keep their
-- own chrome and input; these preferences never hide an unrelated menu.
local V=...
local M={drawing=false}
local UI=V.require('UiBackplates')
M.ui=UI
M.scale=V.require('ModSetting').new('hudScale','HUD SCALE',{'scaled','og'},{'SCALED','OG'})
M.settings={UI.battleUi,UI.hudColor,UI.textboxFill,M.scale}
function M.covered()
 for _,name in ipairs({'bag_menu','party_menu','summary_menu','help_system','pokedex'})do
  local menu=package.loaded['src.ui.game3.'..name]
  if menu and menu.isOpen and menu.isOpen()then return true end
 end
 return false
end
function M.install(stage)
 local Chrome=require('src.ui.game3.battle_chrome')
 local Font=require('src.ui.game3.frlg_font')
 local Message=require('src.ui.game3.message')
 local panel,text,message=Chrome.drawPanel,Font.draw,Message.drawText
 local function active()return M.drawing and stage.active and not M.covered()end
 Chrome.drawPanel=function(mode,...)
  if not active()then return panel(mode,...)end
  if UI.uiHidden('text')then return end
  local fill=UI.textboxFillStyle()
  if not fill then return end
  local G=love.graphics;G.push('all');G.setShader();G.setColor(unpack(fill))
  G.rectangle('fill',0,112,240,48)
  G.setColor(UI.textboxUsesWhiteInk() and .55 or .25, .55,.55,fill[4])
  G.rectangle('line',.5,112.5,239,47);G.pop()
 end
 Font.draw=function(value,x,y,opts,...)
  if active()and y and y>=112 then
   if UI.uiHidden('text')then return 0,x,y end
   local copy={};for key,v in pairs(opts or {})do copy[key]=v end
   copy.colors=UI.textboxUsesWhiteInk()and Font.COLOR.WHITE or Font.COLOR.NORMAL
   return text(value,x,y,copy,...)
  end
  return text(value,x,y,opts,...)
 end
 Message.drawText=function(...)
  if active() and Message._frame=='battle' and UI.uiHidden('text')then return end
  return message(...)
 end
 return function()Chrome.drawPanel=panel;Font.draw=text;Message.drawText=message;M.drawing=false end
end
function M.hudScale(w,h)
 if M.scale:get()=='og'then return math.max(1,math.min(w/240,h/160))end
 return V.require('BattleTheme').scale(w,h)
end
function M.ink()return UI.hudUsesColor()and {.19,.21,.20,1}or{.96,.98,1,1}end
function M.card(...)
 local Theme=V.require('BattleTheme')
 local paper=Theme.paper
 if not UI.hudUsesColor()then Theme.paper={.07,.10,.13,.96}end
 local ok,err=pcall(Theme.statusCard,...);Theme.paper=paper
 if not ok then error(err,0)end
end
return M
