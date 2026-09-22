local T=dofile('lib/BattleTheme.lua')
local function overlaps(a,b)
 return a.x<b.x+b.w and b.x<a.x+a.w and a.y<b.y+b.h+6 and b.y<a.y+a.h+6
end
for _,width in ipairs({160,240,320,640})do
 for _,center in ipairs({0,30,width/2,width-10,width+20})do
  local cards={{id=1,x=center,y=60,w=76,h=22},{id=3,x=center+20,y=65,w=76,h=22},
   {id=0,x=center,y=160,w=76,h=27},{id=2,x=center+10,y=170,w=76,h=27}}
  local out=T.layoutStatusCards(cards,width,240)
  assert(not overlaps(out[1],out[3]),'enemy cards overlap')
  assert(not overlaps(out[0],out[2]),'ally cards overlap')
  for _,r in pairs(out)do assert(r.x>=3 and r.x+r.w<=width-3,'off-screen card')end
  assert(out[1].tip==center and out[3].tip==center+20,'sprite anchors changed')
 end
end
print('PASS paired card spacing, screen edges, four battlers and sprite anchors')
