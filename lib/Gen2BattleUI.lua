-- Native Gen2 presentation consumers. The native battle state continues to
-- own commands, text timing, HP animation and all input.
local V=...
local M={}
local UI=V.require('UiBackplates')
local Mode=V.require('ModernBattleUI')
local Stage=V.require('OverworldBattle')
local Theme=V.require('BattleTheme')
local screen
local function active(state)
 return state and Stage.enabled() and Stage.shot() and not state.tutorial
end
local function modern(state)
 if not active(state) or not Mode.enabled() then return false end
 if not Stage.shot().heads then return false end
 -- A native doubles companion may already draw all four battlers. Leave
 -- its ownership intact; it reads the same public modernUIEnabled export.
 return not (state.battle and state.battle.doubles)
end
function M.backplate(state,x,y,w,h)
 if UI.uiHidden('hud') or modern(state) then return true end
 if UI.hudUsesColor() then return false end
 local g=love.graphics;g.push('all');g.setShader();g.setColor(.06,.08,.1,.94)
 g.rectangle('fill',x*8,y*8,w*8,h*8);g.setColor(.55,.65,.72,1)
 g.rectangle('line',x*8+.5,y*8+.5,w*8-1,h*8-1);g.pop()
 return true
end
local function scopedText(fn,dark,fill,...)
 local Chrome=require('src.ui.gen2.Chrome')
 local Font=require('src.render.Font')
 local g=love.graphics
 local prior={box=Chrome.box,printThrough=Chrome.printThrough,
  printRightThrough=Chrome.printRightThrough,cursorThrough=Chrome.cursorThrough}
 local palette=dark and {{0,0,0},{0,0,0},{0,0,0},{255,255,255}} or Chrome.DEFAULT_BOX_PALETTE
 local function glyphs(text,px,py)
  local pal,draw,finish=Chrome.paletteGlyphs(palette,false,true)
  if not pal then return prior.printThrough(text,px/8,py/8,palette)end
  local pen=px
  for _,code in ipairs(Font.encode(text))do draw(code,pen,py);pen=pen+Font.advanceOf(code)end
  finish();return pen-px
 end
 Chrome.printThrough=function(text,x,y)return glyphs(text,x*8,y*8)end
 Chrome.printRightThrough=function(text,x,y)return glyphs(text,x*8-Font.width(text),y*8)end
 Chrome.cursorThrough=function(x,y,_,_,hollow)
  local pal,draw,finish=Chrome.paletteGlyphs(palette,false,true)
  if pal then draw(hollow and Chrome.CURSOR_HOLLOW or Chrome.CURSOR,x*8,y*8);finish()end
 end
 if fill~=nil then Chrome.box=function(x,y,w,h)
  g.push('all');g.setShader()
  if fill~=false then g.setColor(unpack(fill));g.rectangle('fill',x*8,y*8,w*8,h*8)end
  if fill~=false then g.setColor(dark and .85 or .12,dark and .9 or .12,dark and .95 or .12,1)
   g.rectangle('line',x*8+.5,y*8+.5,w*8-1,h*8-1)end
  g.pop()
 end end
 g.push('all')
 local result={pcall(fn,...)}
 for key,value in pairs(prior)do Chrome[key]=value end
 g.pop()
 if not result[1]then error(result[2],0)end
 return unpack(result,2)
end
function M.install()
 local State=require('src.ui.gen2.BattleState')
 local saved={}
 local function wrap(key,fn)
  local original=State[key]
  if type(original)~='function' then return end
  saved[key]=original;State[key]=function(self,...)return fn(original,self,...)end
 end
 for _,key in ipairs({'drawEnemyHud','drawPlayerHud'})do wrap(key,function(original,self,...)
  if not active(self) then return original(self,...)end
  screen=self
  if UI.uiHidden('hud') or modern(self) then return end
  if not UI.hudUsesColor()then return scopedText(original,true,nil,self,...)end
  return original(self,...)
 end)end
 wrap('drawBottom',function(original,self,...)
  if not active(self)then return original(self,...)end
  screen=self
  if UI.uiHidden('text')then return end
  if modern(self) and (self.phase=='menu' or self.phase=='moves')then return end
  local mode=UI.textboxMode()
  if mode=='WHITE'then return original(self,...)end
  return scopedText(original,true,UI.textboxFillStyle() or false,self,...)
 end)
 local function paint(state)
  local g=love.graphics;local w,h=g.getDimensions()
  local k=Theme.scale(w,h)
  if Stage.hudScaleSetting:get()=='og'then k=math.min(w/320,h/288)end
  g.origin();g.scale(k);w,h=w/k,h/k
  local shot=Stage.shot();local rect=require('src.render.Renderer'):frameRects()
  local items,mons={},{}
  if not UI.uiHidden('hud') and state:statusHUDVisible()then
   for i,side in ipairs({'player','enemy'})do
    local mon=state:activeMon(side)
    local head=shot.heads and shot.heads[side]
    local visible=side=='player' and state.showPlayerHud or side=='enemy' and state.showEnemyHud
    if mon and head and visible and not state:hudCleared(side)then
     items[#items+1]={id=i,x=(rect.vux+head[1]*rect.vuw)/k,y=(rect.vuy+head[2]*rect.vuh)/k,w=76,h=side=='player' and 27 or 22}
     mons[i]={mon=mon,side=side}
    end
   end
  end
  local layout=Theme.layoutStatusCards(items,w,h)
  local ink=UI.hudUsesColor() and {.08,.1,.12,1} or {1,1,.96,1}
  for _,item in ipairs(items)do
   local entry=mons[item.id];local mon,side=entry.mon,entry.side
   local p=layout[item.id];local x,y=p.x,p.y
   Theme.statusCard(x,y,76,item.h,item.x,false)
   -- COLOR has its own light card so black ink remains readable.
   if UI.hudUsesColor()then g.setColor(.9,.95,.94,.96);g.rectangle('fill',x+1,y+1,74,item.h-2,2,2)end
   Theme.text(state:name(mon),x+3,y+2,49,ink)
   Theme.text('Lv.'..tostring(mon.level or 1),x+53,y+2,21,ink)
   Theme.text(state:statusTag(mon,side) or 'HP',x+3,y+11,19,ink)
   local maximum=math.max(1,mon.maxHp or (mon.stats and mon.stats.hp)or 1)
   local hp=math.max(0,math.min(maximum,state:hudHp(mon,side)))
   g.setColor(.2,.27,.29,1);g.rectangle('fill',x+24,y+12,48,3,1,1)
   g.setColor(Theme.hpColor(hp/maximum));g.rectangle('fill',x+24,y+12,48*hp/maximum,3,1,1)
   if side=='player'then Theme.text(hp..' / '..maximum,x+24,y+16,48,ink)end
  end
  if UI.uiHidden('text') or not state:bottomUIVisible()then return end
  local entries,index={}
  if state.phase=='menu'then
   index=state.menuIndex
   for i,label in ipairs(state:menuLabels())do entries[i]={name=label,kind=({'fight','bag','pokemon','run'})[i]}end
  elseif state.phase=='moves'then
   index=state.moveIndex
   for i,move in ipairs(state:playerMoves())do
    local def=state.game and state.game.data and state.game.data.moves and state.game.data.moves[move.id]
    entries[i]={name=def and def.name or tostring(move.id),detail=tostring(move.pp or 0)..' PP'}
   end
  else return end
  local moveMenu=state.phase=='moves'
  local x,y=w-168,h-(moveMenu and 110 or 62)
  if not moveMenu then Theme.commandHub(x+82,y+29)end
  for i,entry in ipairs(entries)do
   local bx=moveMenu and x+3 or x+3+(i-1)%2*82
   local by=moveMenu and y+3+(i-1)*26 or y+3+math.floor((i-1)/2)*30
   local width=moveMenu and 158 or 76
   Theme.button(bx,by,width,22,entry.kind,index==i,i%2==0)
   Theme.text(entry.name,bx+5,by+(entry.detail and 2 or 5),width-10,{1,1,.96,1},not entry.detail)
   if entry.detail then Theme.text(entry.detail,bx+3,by+12,width-6,{1,1,.96,1})end
  end
 end
 V.mod.hooks:wrap('render.hud',function(next,game,viewport)
  local result=next(game,viewport)
  local top=game and game.stack and game.stack.top and game.stack:top()
  if screen and top==screen and modern(screen)then
   local g=love.graphics;g.push('all');g.setShader();g.setScissor()
   local ok,err=pcall(paint,screen);g.pop();if not ok then error(err,0)end
  end
  return result
 end)
 return function()for key,fn in pairs(saved)do State[key]=fn end;screen=nil end
end
return M
