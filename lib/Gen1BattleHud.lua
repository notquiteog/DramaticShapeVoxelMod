-- Read native battlers and projected sprite heads; never alter turn/input state.
-- Paint once on the window plane, after attack effects have been composited.
local V=...
local Theme=V.require('BattleTheme')
local Mode=V.require('ModernBattleUI')
local Stage=V.require('OverworldBattle')
local M={drawn=0,cards={}}
local slots={'player','enemy','player2','enemy2'}
function M.active(battle)
  return Mode.enabled() and battle and Stage.battle()==battle and Stage.shot()
    and not battle.safari and not battle.demo and not battle.blankForAskName
end
local function commands(b)
  return b:bottomUIVisible() and (b.phase=='menu' or b.phase=='moveSelect')
end
local function paint(b)
  local G=love.graphics
  local width,height=G.getDimensions();local scale=Theme.scale(width,height)
  G.origin();G.scale(scale);width,height=width/scale,height/scale
  local shot=Stage.shot();local r=require('src.render.Renderer'):frameRects()
  local items,mons={},{}
  M.cards={}
  if not b.fieldCleared and b:statusHUDVisible() and (b.introSlide or 0)==0 then
    for i,slot in ipairs(slots)do
      local ally=i%2==1;local mon=b[slot]
      local p=shot.heads and shot.heads[slot]
      local visible=mon and mon.mon and not mon.fainted and p
      if ally then visible=visible and not b.showPlayerBack and not b.sendingOut
      else visible=visible and not b.showEnemyTrainer and not b.enemySendingOut
        and not b.enemyHudPending and not b.introBalls
        and not b:growInScale(mon) end
      if visible then
        local id=i-1
        items[#items+1]={id=id,x=(r.vux+p[1]*r.vuw)/scale,
          y=(r.vuy+p[2]*r.vuh)/scale,w=76,h=ally and 27 or 22}
        mons[id]=mon;M.cards[slot]=mon
      end
    end
  end
  local layout=Theme.layoutStatusCards(items,width,height)
  for _,item in ipairs(items)do
    local mon=mons[item.id];local ally=item.id%2==0
    local card=layout[item.id];local x,y=card.x,card.y
    local maximum=math.max(1,mon.mon.stats and mon.mon.stats.hp or mon.mon.maxHp or 1)
    local hp=math.max(0,math.min(maximum,math.floor(mon.shownHP or mon.mon.hp or 0)))
    Theme.statusCard(x,y,76,item.h,item.x,b.__dbAimBattler==mon or b.__dbSwitchAim==mon)
    Theme.text(mon.name or mon.mon.nickname or mon.mon.species,x+3,y+2,49)
    Theme.text('Lv.'..tostring(mon.mon.level or 1),x+53,y+2,21)
    local status=mon.shownStatus and b:statusLabel({status=mon.shownStatus}) or 'HP'
    Theme.text(status,x+3,y+11,19)
    G.setColor(.20,.27,.29,1);G.rectangle('fill',x+24,y+12,48,3,1,1)
    G.setColor(Theme.hpColor(hp/maximum));G.rectangle('fill',x+24,y+12,48*hp/maximum,3,1,1)
    if ally then Theme.text(hp..' / '..maximum,x+24,y+16,48)end
  end
  if not commands(b)then return end
  local x,y=width-168,height-62
  if b.phase=='menu' then
    Theme.commandHub(x+82,y+29)
    for i,label in ipairs({'FIGHT','PKMN','ITEMS','RUN'})do
      local bx,by=x+3+(i-1)%2*82,y+3+math.floor((i-1)/2)*30
      Theme.button(bx,by,76,22,({'fight','pokemon','bag','run'})[i],b.menuIndex==i,i%2==0)
      Theme.text(label,bx+5,by+5,66,{1,1,.96,1},true)
    end
  else
    -- Preserve the native move navigation: vertical normally, grid in wide mode.
    local grid=b.moveGridNavigation and b:moveGridNavigation()
    Theme.panel(x+2,y+2,160,58)
    for i,move in ipairs(b.player.curMoves or {})do
      local def=b.data.moves[move.id] or {}
      local bx=x+6+(grid and (i-1)%2*78 or 0)
      local by=y+5+(grid and math.floor((i-1)/2)*26 or (i-1)*12)
      local w=grid and 73 or 150
      if b.moveIndex==i then G.setColor(.14,.39,.34,1);G.rectangle('fill',bx-1,by-1,w,grid and 23 or 11)end
      local color=b.moveIndex==i and {1,1,1,1}or Theme.ink
      Theme.text((b.moveSwapIndex==i and '> ' or '')..(def.name or move.id),bx,by,grid and 71 or 101,color)
      Theme.text(tostring(move.pp or 0)..' PP',grid and bx or bx+105,grid and by+11 or by,43,color)
    end
  end
end
function M.install()
  V.mod.hooks:wrap('battle.presentation.suppress_native.v1',function(next,request)
    if request and M.active(request.battle)then
      if request.surface=='hud' then return true end
      if request.surface=='text' and commands(request.battle)then return true end
    end
    return next(request)
  end)
  V.mod.hooks:wrap('render.hud',function(next,game,viewport)
    local result=next(game,viewport)
    local battle=game.stack and game.stack:top()
    if M.active(battle)then
      local G=love.graphics;G.push('all');G.setShader();G.setScissor()
      local ok,err=pcall(paint,battle);G.pop()
      if not ok then error(err,0)end
      M.drawn=M.drawn+1
    else M.cards={}end
    return result
  end)
end
return M
