-- Original UI geometry following the user's lbDmiO.png reference: restrained
-- silver status cards with pointers and four coloured corner commands.
local M={apiVersion=1,paper={.77,.78,.76,1},ink={.19,.21,.20,1},
 edge={.27,.28,.26,1},selected={.88,.90,.84,1}}
M.commands={fight={.83,.05,.09,1},pokemon={.10,.37,.04,1},bag={.76,.40,.08,1},run={.13,.27,.62,1}}
function M.panel(x,y,w,h,selected)
 local G=love.graphics
 G.setColor(.06,.07,.06,.4);G.rectangle('fill',x+.5,y+1,w,h,1,1)
 G.setColor(unpack(M.edge));G.rectangle('fill',x,y,w,h,1,1)
 G.setColor(unpack(selected and M.selected or M.paper));G.rectangle('fill',x+1,y+1,w-2,h-2)
 G.setColor(.94,.94,.90,1);G.line(x+1,y+1,x+w-1,y+1)
end
function M.statusCard(x,y,w,h,tip,selected)
 local G=love.graphics
 tip=math.max(x+6,math.min(x+w-6,tip or x+w/2))
 G.setColor(unpack(M.edge));G.polygon('fill',{tip-6,y+h-1,tip+6,y+h-1,tip,y+h+6})
 G.setColor(unpack(M.paper));G.polygon('fill',{tip-4.5,y+h-1,tip+4.5,y+h-1,tip,y+h+4.5})
 M.panel(x,y,w,h,selected)
end
function M.button(x,y,w,h,kind,selected,flip)
 local G=love.graphics;local c=M.commands[kind]or {.22,.34,.52,1}
 local cut=4
 local p=flip and {x,y,x+w-cut,y,x+w,y+cut,x+w,y+h,x+cut,y+h,x,y+h-cut}
  or {x+cut,y,x+w,y,x+w,y+h-cut,x+w-cut,y+h,x,y+h,x,y+cut}
 G.setColor(.16,.17,.15,1);G.polygon('fill',p)
 G.setLineWidth(selected and 1.2 or .65)
 G.setColor(c[1],c[2],c[3],1);G.polygon('fill',p)
 G.setColor(selected and 1 or .32,selected and .94 or .35,selected and .78 or .29,1);G.polygon('line',p)
 G.setColor(1,1,1,.18);G.line(x+cut,y+2,x+w-3,y+2)
end
function M.hpColor(fraction)
 if fraction>.5 then return .09,.73,.21,1 end
 if fraction>.2 then return .93,.65,.23,1 end
 return .87,.29,.28,1
end
function M.scale(w,h)return math.max(1,math.min(4,w/320,h/240))end
function M.aboveHead(x,y,w,h,viewW,viewH)
 return math.max(3,math.min(viewW-w-3,x-w/2)),math.max(3,math.min(viewH-h-9,y-h-10))
end
-- Keep paired status cards apart while retaining each sprite's own pointer.
-- Layout uses the projected heads, so it also follows native battle motion.
function M.layoutStatusCards(items,viewW,viewH)
 local placed={}
 for _,item in ipairs(items)do
  local x,y=M.aboveHead(item.x,item.y,item.w,item.h,viewW,viewH)
  placed[item.id]={x=x,y=y,w=item.w,h=item.h,tip=item.x}
 end
 for side=0,1 do
  local group={}
  for _,item in ipairs(items)do if item.id%2==side then group[#group+1]=item end end
  table.sort(group,function(a,b)return a.x==b.x and a.id<b.id or a.x<b.x end)
  for i=2,#group do
   local a,b=placed[group[i-1].id],placed[group[i].id]
   if a.y<b.y+b.h+6 and b.y<a.y+a.h+6 and a.x+a.w+5>b.x then
    if a.w+b.w+11<=viewW then
     local middle=(a.x+a.w+b.x)/2
     local left=math.max(3,math.min(viewW-a.w-b.w-8,middle-a.w-2.5))
     a.x=left;b.x=left+a.w+5
    else
     -- Very narrow screens: keep both cards above their sprites.
     b.y=math.max(3,a.y-b.h-9)
     if b.y+b.h+6>a.y then a.y=b.y+b.h+9 end
    end
   end
  end
 end
 return placed
end
-- Use the engine's bundled pixel face directly at its design grid. Text is
-- composited at window resolution, outside the world/attack effect canvases.
local face,faceScale
function M.text(value,x,y,width,color,command)
 local G=love.graphics
 if not face then
  local ok,f=pcall(G.newFont,'assets/fonts/plainpixel/PlainPixel-Regular.ttf',15,'mono',1)
  face=ok and f or G.newFont(7);faceScale=ok and .5 or 1
  if face.setFilter then face:setFilter('nearest','nearest')end
 end
 local size=faceScale*(command and 1.5 or 1)
 local str=tostring(value or ''):gsub('<PK><MN>','PKMN'):gsub('<LV>','Lv.'):gsub('<[^>]+>','')
 -- Remove complete UTF-8 codepoints, never leave a broken trailing byte.
 while #str>0 and width and face:getWidth(str)*size>width do
  str=str:gsub('[%z\1-\127\194-\244][\128-\191]*$','')
 end
 G.setFont(face);G.setColor(unpack(color or M.ink))
 G.print(str,math.floor(x+.5),math.floor(y+.5),0,size,size)
 return face:getWidth(str)*size
end
function M.commandHub(x,y)
 local G=love.graphics
 G.setColor(.16,.17,.16,1)
 G.polygon('fill',{x,y-8,x+8,y,x,y+8,x-8,y})
 G.setColor(.07,.08,.07,1);G.setLineWidth(.6)
 G.polygon('line',{x,y-8,x+8,y,x,y+8,x-8,y})
end
return M
