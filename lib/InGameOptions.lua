-- Native options adapters. Each mod ships its own copy and supplies only its
-- own public schema; no other mod or private manager implementation is needed.
local M={}
function M.install(mod,schema,title)
 local active=true
 local function rows(game)
  local out={}
  for _,s in ipairs(schema)do
   if s.type=='toggle' or s.type=='choice' or s.type=='number' then
    local choices=s.choices or {{'OFF',false},{'ON',true}}
    local function index()
     local value=mod.options:get(s.key)
     for i,c in ipairs(choices)do if c[2]==value then return i end end
     return 1
    end
    out[#out+1]={id=mod.id..':'..s.key,label=s.label or s.key,
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
 if require('src.core.GameVersion').generation()==3 then
  -- Game3 uses ctx-based native pages and does not dispatch ui.options.rows.
  local Rows=require('src.ui.game3.option_rows')
  -- Hot reload replaces this mod's owner without disturbing another mod's
  -- native page. Old composed wrappers become inert and simply delegate.
  Rows.modSettingsPages=Rows.modSettingsPages or {}
  local previous=Rows.modSettingsPages[mod.id]
  if previous then previous()end
  Rows.modSettingsPages[mod.id]=function()active=false end
  local build,group=Rows.build,Rows.group
  local function owned(id)return type(id)=='string' and id:sub(1,#mod.id+1)==mod.id..':'end
  Rows.build=function(ctx)
   local out=build(ctx)
   if active then for _,r in ipairs(rows(ctx.game))do
    local step=r.step;r.step=function(c,dir)return step(c.game,dir)end
    out[#out+1]=r
   end end
   return out
  end
  Rows.group=function(all,openPage)
   if not active then return group(all,openPage)end
   local kept,members={},{}
   for _,r in ipairs(all)do local dst=owned(r.id) and members or kept;dst[#dst+1]=r end
   local out=group(kept,openPage)
   if #members>0 then out[#out+1]={id=mod.id..':settings',label=title or mod.id,group=true,
    value=function()return #members..' OPTIONS'end,
    activate=function()openPage(title or mod.id,members)end}end
   return out
  end
 else
  mod.hooks:wrap('ui.options.rows',function(nextFn,game,base)
   local out=nextFn(game,base);if not active or type(out)~='table'then return out end
   local seen={};for _,r in ipairs(out)do if r.id then seen[r.id]=true end end
   local at=#out+1
   for i,r in ipairs(out)do if r.id=='cancel' or r.label=='CANCEL' or r.label=='BACK'then at=i;break end end
   for _,r in ipairs(rows(game))do if not seen[r.id]then table.insert(out,at,r);at=at+1 end end
   return out
  end)
 end
 mod.hooks:wrap('core.quit_to_launcher',function(nextFn,...)
  active=false;return nextFn(...)
 end)
end
return M
