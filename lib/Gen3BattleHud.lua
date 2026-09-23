-- Window-resolution status cards. The native battle still calls its own HUD
-- at the correct intro/withdrawal moments; capture those calls, then paint only
-- those cards after the complete frame. Never bake modern text into an attack.
local V=...
local Theme=V.require('BattleTheme')
local Mode=V.require('ModernBattleUI')
local M={cards={},drawn=0}
local Bounds=V.require('SpriteHeadBounds')
function M.install(stage)
 local Health=require('src.core.game3.battle.healthbox')
 local Anim=require('src.core.game3.battle.anim')
 local Battle=require('src.core.game3.battle')
 local State=require('src.core.game3.battle.state')
 local Status=require('src.core.game3.summary_data')
 local Ui=require('src.core.game3.battle.ui')
 local Moves=require('src.core.game3.battle.moves')
 local Types=require('src.core.game3.battle.types')
 local Strings=require('src.core.Strings')
 local Coords=require('src.core.game3.battle.anim_coords')
 local Pokemon=require('src.core.game3.pokemon')
 local original,input=Health.draw,Ui.handleInput
 Ui.handleInput=function(keys)
  if Mode.enabled() and stage.active and Ui._mode=='menu' and M.menu and M.menu.mode=='menu' and keys and keys.wasPressed then
   local swap={up='left',down='right',left='up',right='down'}
   local proxy=setmetatable({},{__index=keys})
   proxy.wasPressed=function(_,key)return keys:wasPressed(swap[key]or key)end
   return input(proxy)
  end
  return input(keys)
 end
 local capturing=false
 function M.reset()M.cards={};M.menu=nil;M.covered=false;capturing=false end
 function M.begin()M.reset();capturing=Mode.enabled() end
 function M.finish()
  capturing=false
  if not stage.active or not Mode.enabled() then return end
  for _,name in ipairs({'bag_menu','party_menu','summary_menu','help_system'})do
   local owner=package.loaded['src.ui.game3.'..name]
   if owner and owner.isOpen and owner.isOpen()then M.covered=true;return end
  end
  if Battle._phase~='command' or not Battle._st or Battle._st.safari then return end
  local mode=Ui._mode
  if mode~='menu' and mode~='moves' and mode~='target' then return end
  local Message=package.loaded['src.ui.game3.message']
  if Message and Message.open then return end
  local st=Battle._st;local id=Ui.activeBattler()
  local battler=id==0 and st.player or st.battlers and st.battlers[id]
  if not battler or not battler.mon then return end
  M.menu={mode=mode,index=mode=='menu' and Ui._menuIndex or Ui._moveIndex,entries={}}
  if mode=='menu' then
   for i,key in ipairs({'FIGHT','ITEMS','PKMN','RUN'})do M.menu.entries[i]={name=Strings(key),kind=({'fight','bag','pokemon','run'})[i]}end
  else
   for i=1,4 do
    local move=battler.mon.moves and battler.mon.moves[i]
    local def=move and Moves.get(move)
    M.menu.entries[i]={name=def and Moves.displayName(move) or '-',
     detail=def and (Strings(Types.get(def.type) or 'NORMAL')..'  '..tostring(battler.mon.pp and battler.mon.pp[i]or 0)..' PP')or ''}
   end
   if mode=='target' then
    local target=Ui.targetCursor();local b=st.battlers and st.battlers[target]
    M.menu.target=b and State.displayName(b)or ''
   end
  end
  -- Only command screens have their native bottom strip replaced. Messages,
  -- attack frames, party/bag, evolution and special prompts keep their owner.
  local G=love.graphics;G.push('all');G.origin();G.setShader();G.setScissor()
  G.setBlendMode('replace','premultiplied');G.setColor(0,0,0,0)
  G.rectangle('fill',0,112,240,48);G.pop()
 end
 Health.draw=function(side,battler,opts)
  local st=Battle._st
  if not capturing or not stage.active or not st or st.safari or not battler then
   return original(side,battler,opts)
  end
  local id=type(side)=='number' and side or side=='player' and 0 or 1
  local key=id==0 and 'player' or id==1 and 'enemy' or id
  local anim=Anim.stage and Anim.stage()
  local hb=anim and anim.healthbox and (anim.healthbox[id] or anim.healthbox[key])
  if hb and hb.visible==false then return end
  -- Preserve native level-up palette flashes until the high-resolution HUD
  -- has an equivalent effect, rather than silently dropping that feedback.
  if hb and hb.levelUpBlend then return original(side,battler,opts)end
  local mon=battler.mon or {}
  local _,hp,maxHp=Anim.displayHpRatio(side,battler)
  local p=Anim.present and Anim.present(side)
  local status=Status.statusAilment({status=battler.status or mon.status or mon.status1,hp=mon.hp})
  local sp=battler.species or Pokemon.speciesOf(mon)
  local pic=Ui.battlerPic(id,battler,sp)
  local bounds=Bounds.get(pic and pic.image)
  local cx,cy=Ui.battlerSpriteCenter(id,sp,Coords.coords(st,id))
  local scale=p and p.scale or 1
  local sx,sy=scale*(p and p.sx or 1),scale*(p and p.sy or 1)
  local angle=p and p.rotation or 0
  local head=math.min((bounds[2]-32)*sy,(bounds[4]-32)*sy)
  if angle~=0 then head=-math.abs(math.sin(angle)*32*sx)-math.abs(math.cos(angle)*32*sy)end
  local r=require('src.render.Renderer'):frameRects()
  local anchor={r.uox+(cx+(p and p.ox or 0))*r.Ux,
   r.uoy+(cy+(p and p.oy or 0)+Ui.bounceOffset('mon',id)+head)*r.Uy}
  M.cards[id]={anchor=anchor,name=State.displayName(battler),level=p and p.displayLevel or mon.level or 1,
   hp=math.max(0,math.floor(hp or mon.hp or 0)),maximum=math.max(1,math.floor(maxHp or mon.maxHp or 1)),
   status=({'SLP','PSN','BRN','FRZ','PAR','PSN'})[status],gender=mon.gender,
   caught=id%2==1 and Health.shouldShowCaughtMarker(st,battler),
   exp=id%2==0 and Anim.displayExpRatio(side,battler) or nil,
   ox=((hb and hb.ox)or 0)+((opts and opts.ox)or 0),oy=((hb and hb.oy)or 0)+((opts and opts.oy)or 0)}
 end
 local function paint()
  local G=love.graphics;local w,h=G.getDimensions();local k=Theme.scale(w,h)
  G.origin();G.scale(k);w,h=w/k,h/k
  local function label(value,x,y,width)return Theme.text(value,x,y,width)end
  local items={}
  for id=0,3 do local c=M.cards[id];if c then
   items[#items+1]={id=id,x=c.anchor[1]/k,y=c.anchor[2]/k,w=76,h=id%2==0 and 27 or 22}
  end end
  local layout=Theme.layoutStatusCards(items,w,h)
  for id=0,3 do local c=M.cards[id];if c then
   local ally=id%2==0
   local cardH=ally and 27 or 22
   local x,y=layout[id].x,layout[id].y
   Theme.statusCard(x,y,76,cardH,c.anchor[1]/k,Ui._mode=='target' and Ui.targetCursor()==id)
   label(c.name,x+3,y+2,49);label('Lv.'..c.level,x+53,y+2,21)
   label(c.status or 'HP',x+3,y+11,19)
   local fraction=math.min(1,c.hp/c.maximum)
   G.setColor(.20,.27,.29,1);G.rectangle('fill',x+24,y+12,48,3,1,1)
   G.setColor(Theme.hpColor(fraction));G.rectangle('fill',x+24,y+12,48*fraction,3,1,1)
   if ally then
    label(c.hp..' / '..c.maximum,x+24,y+16,48)
    G.setColor(.24,.57,.81,1);G.rectangle('fill',x+3,y+25,70*math.max(0,math.min(1,c.exp or 0)),1)
   end
  end end
  if M.menu then
   local x,y=w-168,h-62
   local title=M.menu.target and ('TARGET: '..M.menu.target)or nil
   if title then label(title,x+4,y-10,152)end
   Theme.commandHub(x+82,y+29)
   for i,entry in ipairs(M.menu.entries)do
    local pos=M.menu.mode=='menu' and ({1,3,2,4})[i]or i
    local bx,by=x+3+(pos-1)%2*82,y+3+math.floor((pos-1)/2)*30
    local chosen=M.menu.index==i
    Theme.button(bx,by,76,22,entry.kind,chosen,pos%2==0)
    Theme.text(entry.name,bx+5,by+(entry.detail and 2 or 5),66,{1,1,.96,1},not entry.detail)
    if entry.detail then Theme.text(entry.detail,bx+3,by+12,70,{1,1,.96,1})end
   end
  end
 end
 V.mod.hooks:wrap('render.hud',function(inner,game,viewport)
  local result=inner(game,viewport)
  if stage.active and not M.covered and Battle.isActive() and (next(M.cards)~=nil or M.menu) then
   local G=love.graphics;G.push('all');G.setShader();G.setScissor()
   local ok,err=pcall(paint);G.pop()
   if not ok then error(err,0)end
   M.drawn=M.drawn+1
  end
  return result
 end)
 return function()Health.draw=original;Ui.handleInput=input;M.reset()end
end
return M
