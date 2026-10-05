local M=dofile('lib/Gen3EmoteCards.lua')
local age,frame,completed=12,2,0
local bubble={kind='field_effect_emote',x=32,y=43,sortY=64.5,i=91001,elevation=4,
 draw=function(self,cx,cy)assert(cx==32 and cy==43);assert(age==12 and frame==2);completed=completed+1 end}
local fx={_anims={{kind='emote'}},collectActors=function(out)
 out[1]={kind='field_effect_cut_tree'};out[2]=bubble
end}
local captures=0
for _,cam in ipairs({{level=3,yaw=1},{level=6,yaw=math.pi/2},{level=7,yaw=math.pi/4}})do
 M.draw(fx,cam,function(x,z,layer)
  assert(x==40 and math.abs(z-79.999)<.001 and layer==4);return 6
 end,function(id,w,h,paint,v,base)
  captures=captures+1;assert(id=='emote-91001' and w==16 and h==16 and base==6)
  paint();assert(v[1][2]==37 and v[3][2]==21,'native bounce/height changed')
  local dx,dz=v[2][1]-v[1][1],v[2][3]-v[1][3]
  assert(math.abs(dx*dx+dz*dz-256)<1e-8,'billboard scaled with orbit')
  assert(v[1][1]==v[4][1] and v[1][3]==v[4][3],'emote leans with camera')
  if cam.level==3 then assert(dz==0,'static view rotated emote')end
 end)
end
assert(captures==3 and completed==3 and age==12 and frame==2)
fx._anims={};fx.collectActors=function()error('idle field enumerated effects')end
M.draw(fx,{},nil,nil)
assert(M.supports('emote') and M.supports('exclamation') and not M.supports('flash'))
print('PASS native emote art, upright camera-facing cards, support layer, bounce and no animation ticks')
