local S=dofile('lib/Gen3ServiceRooms.lua')
local kinds={
 {'network',{0x2a0,0x2a6,0x2a1,0x2a2},15,10,9},
 {'building__rom_082d4bcc',{0x290,0x291,0x2bd,0x2be},11,9,8},
 {'building__pokemon_center',{0x208,0x20f,0x228,0x237},14,9,9},
 {'building__pokemon_center',{0x208,0x20f,0x228,0x237},14,10,10},
 {'building__shop',{0x210,0x215,0x214,0x21c},11,8,8},
}
for _,k in ipairs(kinds)do
 local pair,c,w,h,rows=unpack(k)
 local def={width=w,height=h,midLayout={}}
 local changed=false
 function def.midLayout:midAt(x,y)
  if y>=rows then return 8 end
  if x==0 and y==0 then return changed and 999 or c[1]end
  if x==w-1 and y==0 then return c[2]end
  if x==0 and y==rows-1 then return c[3]end
  if x==w-1 and y==rows-1 then return c[4]end
  return 1
 end
 function def.midLayout:collAt()return 0 end
 local plan=assert(S.profile(def,pair));assert(#plan.outline==8 and #plan.outer==8)
 assert(plan.bounds[2]==3.8 and plan.bounds[4]==rows*16,'wall through healing bay or padded room')
 -- Every lower native cell center remains inside the chamfered perimeter.
 for x=0,w-1 do local poly=S.clip({{x*16+8,rows*16-8}},plan.outline);assert(#poly==1,'native corner walking center cut off')end
 assert(not S.replacesFloor({cx=math.floor(w/2),cy=rows-1},plan),'native exit mat replaced by blank floor')
 assert(not S.replacesFloor({cx=0,cy=rows-3,prop={recipe={noGround=true}}},plan),'room border sealed descending escalator well')
 assert(S.replacesFloor({cx=0,cy=rows-1},plan),'corner art was not clipped to the wall envelope')
 local p={serviceRoom=plan,bounds=plan.bounds,height=32,wallpaper=true,doorways={{},{},{{48,64}},{}},openings={{0,80,32,112}}}
 for side=1,6 do
  for _,opened in ipairs{false,true}do
   local v,i=S.geometry(p,side,opened);assert(#v>0 and #i>0)
   for _,q in ipairs(v)do
    assert(q[1]>=-3.01 and q[1]<=w*16+3.01 and q[3]>=.79 and q[3]<=rows*16+3.01,'unbounded corner miter')
    assert(q[2]>=-4 and q[2]<=32.06,'synthetic trim or roof protrudes')
    if opened and side<=4 then assert(q[2]<=0,'cutaway covers room')end
   end
   if side==1 then
    -- All north vertices are at/beyond the rear plane, leaving the original
    -- z25 healing machine and z29 storage depth fully in front of the wall.
    for _,q in ipairs(v)do assert(q[3]<=20,'north finish folds around furniture')end
   end
   if side==5 then
    for n=1,#i,3 do
     local x,z=0,0;for j=0,2 do x=x+v[i[n+j]][1]/3;z=z+v[i[n+j]][3]/3 end
     assert(not(x>0 and x<32 and z>80 and z<112),'foundation sealed escalator well')
    end
   end
  end
 end
 local count=0
 S.floor({cx=0,cy=0},plan,function(v,uv)
  count=count+1;for j,q in ipairs(v)do assert(#S.clip({{q[1],q[3]}},plan.outline)==1,'floor bleeds outside chamfer');assert(uv[j][1]>=0 and uv[j][1]<=1 and uv[j][2]>=0 and uv[j][2]<=1)end
 end,{{0,0},{1,0},{1,1},{0,1}})
 assert(count>0)
 changed=true;assert(not S.profile(def,pair),'changed third-party corner was claimed')
end
assert(not S.profile({width=4,height=4,midLayout={midAt=function()return 1 end}},'building__other'),'unrelated room acquired service geometry')
-- The polygon faces share exact inner/outer corner vertices; no daylight
-- wedge remains between adjacent diagonal and straight wall prisms.
print('PASS native service-room chamfers, closed miters, padding, walking centers, fixture clearance, clipped floors and open escalator wells')
