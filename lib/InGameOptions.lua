-- Native options adapters. Each mod ships its own copy and supplies only its
-- own public schema; no other mod or private manager implementation is needed.
local M={}
function M.install(mod,schema,title,categories,liveSettings)
 local active=true
 local function rows(game)
  local out={}
  for _,s in ipairs(schema)do
   local live=liveSettings and liveSettings[s.key]
   if live and not s.readOnly then
    -- Use the same live setting rows as Gen1, including preset overlays and
    -- switching a manually edited child back to CUSTOM.
    local row=live:row();local step=row.step
    row.id=mod.id..':'..s.key
    row.step=function(g,dir)
     g=g or game
     local result=step(g,dir)
     require('src.mods.Runtime').emit('mod.options_changed',
      {mod=mod.id,key=s.key,value=live.values[live:read()]})
     return result
    end
    out[#out+1]=row
   elseif s.pipeline then
    -- GB render pipelines already own their value and save bucket. Reuse
    -- that owner instead of creating a second, disconnected mod preference.
    local P=require('src.render.Pipelines')
    out[#out+1]={id='pipeline:'..s.pipeline,label=s.label,
     value=function()return P.levelLabel(s.pipeline,P.level(s.pipeline))end,
     step=function(g,dir)
      g=g or game;P.cycle(s.pipeline,dir or 1)
      P.syncOptions(g and ((g.save and g.save.options)or g.options))
      if g and g.writeOptions then g:writeOptions()end
      return true
     end}
   elseif s.type=='toggle' or s.type=='choice' or s.type=='number' then
    local choices=s.choices or {{'OFF',false},{'ON',true}}
    local function index()
     local value=mod.options:get(s.key)
     if value==nil then value=s.default end
     for i,c in ipairs(choices)do if c[2]==value then return i end end
     return 1
    end
    out[#out+1]={id=mod.id..':'..s.key,label=s.label or s.key,supportOnly=s.supportOnly,
     value=function()if s.readOnly then return s.unavailable or 'ADAPTER PENDING' end;return s.type=='number' and tostring(mod.options:get(s.key) or s.default or 0) or choices[index()][1]end,
     step=function(g,dir)
      if s.readOnly then return false end
      g=g or game
      local value
      if s.type=='number' then
       value=math.max(s.min or -math.huge,math.min(s.max or math.huge,(tonumber(mod.options:get(s.key)) or s.default or 0)+(dir or 1)*(s.step or 1)))
      else value=choices[(index()-1+(dir or 1))%#choices+1][2]end
      local opts=g and ((g.save and g.save.options) or g.options)
      if not (opts and g.mods)then return false end
      opts.modOptions=opts.modOptions or {};opts.modOptions[mod.id]=opts.modOptions[mod.id]or{}
      opts.modOptions[mod.id][s.key]=value
      g.mods.modOptions=g.mods.modOptions or {};g.mods.modOptions[mod.id]=g.mods.modOptions[mod.id]or{}
      g.mods.modOptions[mod.id][s.key]=value
      require('src.mods.Runtime').emit('mod.options_changed',{mod=mod.id,key=s.key,value=value})
      if g.writeOptions then g:writeOptions()elseif g.persistOptions then g:persistOptions()end
      return true
     end}
   end
  end
  return out
 end
 local gen3=require('src.core.GameVersion').generation()==3
 local screenId=mod.id..':options'
 if gen3 then
  local decorate
  if mod.read then decorate=assert((loadstring or load)(assert(mod:read('lib/Gen3OptionScreen.lua')),'@Gen3OptionScreen'))().decorate end
  -- API3's registered-screen bridge owns native stack/input and the GBA
  -- viewport. Settings and category pages use public widgets only.
  mod.content.screens:register(screenId,{new=function(game,pageTitle,pageRows)
   local function openPage(label,members)return mod.ui.push(game,screenId,label,members)end
   local source=pageRows
   if not source then
    local members,support={},{}
    for _,row in ipairs(rows(game))do
     local dest=row.supportOnly and support or members;dest[#dest+1]=row
    end
    source=categories and categories.native(members,openPage,mod.id)or members
    if #support>0 then source[#source+1]={label='OPTION SUPPORT',group=true,
     value=function()return #support..' OPTIONS'end,
     activate=function()return openPage('OPTION SUPPORT',support)end}end
   end
   local items={}
   local function refresh()
    for i,row in ipairs(source)do items[i].right=row.value and row.value(game)or'OPEN'end
   end
   for i,row in ipairs(source)do items[i]={label=row.label,row=row}end
   refresh();items[#items+1]={label='CANCEL'}
   local menu=mod.ui.ListMenu.new(game,pageTitle or title or mod.id,items,{onChoose=function(item,self)
    local row=item.row
    if not row then return self:close()end
    if row.activate then return row.activate(game)end
    if row.step then row.step(game,1);refresh()end
   end})
   local update=menu.update
   menu.update=function(self,dt)
    if not active then return self:close()end
    local input=game.input;local item=self.items[self.index];local row=item and item.row
    if row and row.step and(input:wasPressed('left')or input:wasPressed('right'))then
     row.step(game,input:wasPressed('left')and-1 or 1);refresh();return
    end
    return update(self,dt)
   end
   return decorate and decorate(menu)or menu
  end})
 end
 mod.hooks:wrap('ui.options.rows',function(nextFn,game,base)
   local out=nextFn(game,base);if not active or type(out)~='table'then return out end
   local seen={};for _,r in ipairs(out)do if r.id then seen[r.id]=true end end
   local at=#out+1
   for i,r in ipairs(out)do if r.id=='cancel' or r.label=='CANCEL' or r.label=='BACK'then at=i;break end end
   if gen3 then
    local id=mod.id..':settings'
    if not seen[id]then table.insert(out,at,{id=id,label=title or mod.id,group=true,
     value=function()return #rows(game)..' OPTIONS'end,
     activate=function(g)return mod.ui.push(g or game,screenId)end})end
   else
    for _,r in ipairs(rows(game))do if not seen[r.id]then table.insert(out,at,r);at=at+1 end end
   end
   return out
 end)
 mod.hooks:wrap('core.quit_to_launcher',function(nextFn,...)
  active=false;return nextFn(...)
 end)
end
return M
