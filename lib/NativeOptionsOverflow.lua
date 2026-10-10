-- RS native options have a narrow fixed label column. Keep our full names
-- and native pixel font; selected overflow scrolls instead of covering values.
return function(mod,active)
 local GV=require('src.core.GameVersion');local version=GV.get and GV.get()
 if version~='ruby'and version~='sapphire'then return end
 local Menu=require('src.ui.game3.rs.option_menu')
 local Font=require('src.ui.game3.frlg_font')
 local original=Menu.draw;local selection,started
 Menu.draw=function(...)
  if not active()then return original(...)end
  local pages=Menu._pages;local page=pages and pages[#pages]
  local key=tostring(page)..':'..tostring(page and page.index)
  if key~=selection then selection=key;started=tonumber(Menu._k)or 0 end
  local draw=Font.draw
  Font.draw=function(text,x,y,opts)
   local d=Menu._data;local pages=Menu._pages;local p=pages and pages[#pages]
   local base=d and d.rows and d.rows[1]
   local n=base and p and (y-base.y)/16+1
   local row=n and n%1==0 and n>=1 and n<=(Menu.VISIBLE or 7)and p.rows[(p.scroll or 0)+n]
   local own=row and type(row.id)=='string'and row.id:sub(1,#mod.id+1)==mod.id..':'
   local width=base and base.choices and base.choices[1]and base.choices[1].x-x-4
   if not(own and row.value and text==row.label and x==base.x and width and width>0)then return draw(text,x,y,opts)end
   local overflow=Font.measure(text)-width
   if overflow<=0 then return draw(text,x,y,opts)end
   local offset=0
   if p.index==(p.scroll or 0)+n then
    local frame=math.max(0,(tonumber(Menu._k)or 0)-(started or 0))
    local travel=math.ceil(overflow*4);local phase=frame%(travel+120)
    offset=math.min(overflow,math.max(0,math.floor((phase-60)/4)))
   end
   local style={};for k,v in pairs(opts or{})do style[k]=v end
   style.maxWidth=width+offset
   local g=love.graphics;g.push('all')
   local sx,sy=g.transformPoint(x,y);local ex,ey=g.transformPoint(x+width,y+16)
   g.intersectScissor(sx,sy,ex-sx,ey-sy)
   local ok,err=pcall(draw,text,x-offset,y,style);g.pop()
   if not ok then error(err,0)end
  end
  local result={pcall(original,...)};Font.draw=draw
  if not result[1]then error(result[2],0)end
  return unpack(result,2)
 end
end
