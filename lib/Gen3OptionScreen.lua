-- API3 owns registration, stack, input and lifecycle. Its stock ListMenu
-- draws GB glyphs, which are not installed in native GBA profiles. Only the
-- artwork below uses edition-native internals until mod.ui exposes a GBA font.
local M={}
function M.decorate(menu)
 menu.gbaCanvas=true -- this renderer uses the full native 240x160 canvas
 menu.rows=7
 menu.draw=function(self)
  local Font=require('src.ui.game3.frlg_font')
  local Window=require('src.ui.game3.window')
  local function fit(text,width)
   text=tostring(text or '')
   if Font.measure(text)<=width then return text end
   local n=Font.countChars(text)
   repeat n=n-1;text=Font.truncate(text,n) until n<=0 or Font.measure(text..'...')<=width
   return text..'...'
  end
  love.graphics.setColor(1,1,1,1)
  love.graphics.rectangle('fill',0,0,240,160)
  Window.stdFrame(Window.template(1,1,28,2))
  Window.stdFrame(Window.template(1,5,28,14))
  Font.draw(fit(self.title,208),16,8)
  for row=1,self.rows do
   local i=(self.scroll or 0)+row;local item=self.items[i]
   if not item then break end
   local y=40+(row-1)*15
   local right=item.right and tostring(item.right)or''
   local width=math.min(100,Font.measure(right))
   Font.draw(fit(item.label,192-width-(right~=''and 8 or 0)),24,y)
   if right~=''then Font.draw(fit(right,100),224-width,y)end
   if i==self.index then Font.drawGlyph(Font.CHAR_SELECTOR_ARROW,12,y)end
  end
  love.graphics.setColor(1,1,1,1)
 end
 return menu
end
return M
