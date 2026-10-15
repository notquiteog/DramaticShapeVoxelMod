-- Public native field choice/message UI keeps edition styling and controller input.
local V=...
local M={}
function M.install()
 V.mod.hooks:wrap('ui.start_menu.items',function(next,game,items)
  local out=next(game,items)
  if type(out)~='table'then return out end
  for _,entry in ipairs(out)do if entry.label=='CACHE'then return out end end
  local entry={id='battle_art_cache',label='CACHE',onSelect=function(g,session)
   local Start=require('src.ui.game3.start_menu')
   local Choice=require('src.ui.game3.choice')
   local Message=require('src.ui.game3.message')
   local cache=V.require('NativeGeometryCache')
   local cursor=Start.cursor
   Start.close(true)
   local function reopen()Start.show({game=g or game,session=session,cursor=cursor})end
   local choose
   choose=function()
    Choice.multi({'SAVE','DROP','CANCEL'},0,function(index)
     if index==0 then
      local ok,saved,failed=cache.saveRamToDisk()
      local text=not ok and ('CACHE SAVE FAILED\n'..failed..' FILES NOT WRITTEN')
       or saved==0 and 'CACHE ALREADY SAVED' or ('CACHE SAVED\n'..saved..' FILES')
      Message.show(text,{done=choose})
     elseif index==1 then
      cache.drop()
      Message.show('MODEL RAM CACHE DROPPED',{done=choose})
     else reopen()end
    end,{left=20,top=3})
   end
   choose()
  end}
  local at=#out+1
  for i,item in ipairs(out)do if item.id=='save'or item.label=='SAVE'then at=i;break end end
  table.insert(out,at,entry)
  return out
 end)
end
return M
