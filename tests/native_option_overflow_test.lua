package.loaded['src.core.GameVersion']={get=function()return 'ruby'end}
local calls,clips={},0
local Font={measure=function(s)return #s*8 end}
function Font.draw(text,x,y,opts)calls[#calls+1]={text=text,x=x,opts=opts}end
package.loaded['src.ui.game3.frlg_font']=Font
local row={id='TEST:long',label='LONG NATIVE OPTION NAME',value=function()return'ON'end}
local page={rows={row,{id='textSpeed',label='NATIVE BASE ROW'}},index=1,scroll=0}
local Menu={VISIBLE=7,_k=0,_pages={page},_data={rows={{x=8,y=40,choices={{x=80}}}}}}
function Menu.draw()Font.draw(row.label,8,40,{});Font.draw('ON',80,40,{});Font.draw('NATIVE BASE ROW',8,56,{})end
package.loaded['src.ui.game3.rs.option_menu']=Menu
love={graphics={push=function()end,pop=function()end,transformPoint=function(x,y)return x,y end,intersectScissor=function()clips=clips+1 end}}
local active=true;local original=Font.draw
dofile('lib/NativeOptionsOverflow.lua')({id='TEST'},function()return active end)
Menu.draw();assert(calls[1].text==row.label and calls[1].opts.maxWidth==68 and calls[1].x==8)
assert(not calls[2].opts.maxWidth and not calls[3].opts.maxWidth and clips==1,'native/value rows were changed')
assert(Font.draw==original,'native font leaked')
Menu._k=100;calls={};Menu.draw();assert(calls[1].x<8 and calls[1].x%1==0,'selected label did not scroll in integer pixels')
page.index=2;calls={};Menu.draw();assert(calls[1].x==8,'unselected overflow scrolled')
active=false;calls={};Menu.draw();assert(not calls[1].opts.maxWidth,'unloaded owner still changed labels')
print('PASS full native label retained, bounded selected scroll, base/value rows and unloaded owner unchanged')
