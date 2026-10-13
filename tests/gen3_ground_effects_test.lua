local M=dofile('lib/Gen3GroundEffects.lua')
local paints,emits=0,0
love={graphics={setColor=function()end,draw=function(image,q,x,y,r,sx,sy)
 assert(image=='native' and q=='frame2' and x==16 and y==0 and sx==-1 and sy==1)
 paints=paints+1
end}}
local fx={_anims={{kind='tracks',visible=true,cx=3,cy=4,frame=2,hflip=true,sheet='sand_footprints'},
 {kind='tracks',visible=false,cx=3,cy=4},{kind='flash'}},loadSheet=function(name)
 assert(name=='sand_footprints');return {image='native',quads={[2]='frame2'}}
end}
M.draw(fx,function(x,z)assert(x==56 and z==72);return 9 end,function(id,w,h,paint,v,base)
 emits=emits+1;assert(w==16 and h==16 and base==9)
 assert(v[1][1]==48 and v[1][3]==64 and v[3][1]==64 and v[3][3]==80)
 for _,p in ipairs(v)do assert(p[2]==.09,'footprint stands upright')end
 paint()
end)
assert(emits==1 and paints==1)
assert(M.supports('tracks') and M.supports('ripple') and not M.supports('flash'))
print('PASS native sand frames/flips, terrain placement, fade and fallback eligibility')
local attached=0
local wet={_anims={{kind='splash',cx=2,cy=4},{kind='feet_water',cx=2,cy=4},{kind='hot_springs',cx=2,cy=4},{kind='camera_shake',cx=2,cy=4}},collectActors=function(out)
 out[1]={kind='field_effect_splash',i=1,x=32,y=68,sortY=64.5,draw=function(_,x,y)assert(x==32 and y==68);attached=attached+1 end}
end}
M.draw(wet,function(x,z)assert(x==40 and z==72);return 3 end,function(id,w,h,paint,v,base)
 assert(w==16 and h==8 and base==3);assert(v[1][2]==8 and v[3][2]==0);paint()
end,{level=6,yaw=math.pi/2})
assert(attached==1 and M.supports('camera_shake'),'attached water effects or shake lose camera')
print('PASS player-attached native splash art, rotated upright card and terrain support')

local burst={cx=2,cy=3,timer=4,kind='cut_grass_scatter',particles={{x=44,y=45,vx=2,vy=-1}}}
local count=0
love.graphics.draw=function(img,frame,x,y)assert(img=='native-leaf'and frame=='original'and x==0 and y==0)end
M.draw({_anims={burst},loadSheet=function(n,w,h,total)assert(n=='cut_grass'and w==8 and h==8 and total==1);return {image='native-leaf',quads={[0]='original'}}end},
 function(x,z)assert(x==40 and z==56);return 12 end,
 function(id,w,h,paint,v,base)
  count=count+1;assert(w==8 and h==8 and base==12)
  assert(math.abs(v[1][1]-40)<.001 and math.abs(v[1][3]-60)<.001 and v[1][2]==15)
  assert(v[3][2]==7,'native leaf motion changed');paint()
 end,{level=6,yaw=math.pi/2})
assert(count==1 and burst.timer==4 and burst.particles[1].y==45 and M.supports('cut_grass_scatter'))
print('PASS native Cut leaf frame, camera-facing plane, terrain support and unchanged particle lifecycle')

local rock={kind='deoxys_rock_destroy',state='shatter',x=32,y=48,frags={{x=24,y=28,frame=2},{x=48,y=60,frame=1,off=true}}}
local pieces=0
love.graphics.draw=function(img,q)assert(img=='native-rock'and q=='piece2')end
M.draw({_anims={rock},loadSheet=function(n,w,h,total)assert(n=='deoxys_rock_fragments'and total==4);return{image='native-rock',quads={[2]='piece2'}}end},
 function(x,z)assert(x==40 and z==56);return 9 end,
 function(id,w,h,paint,v,base)pieces=pieces+1;assert(base==9 and v[1][1]==24 and v[1][2]==36 and v[3][2]==28);paint()end,{level=3})
assert(pieces==1 and not rock.frags[1].off,'native fragment state changed')
print('PASS native Deoxys frames, off-fragment filtering and unchanged original positions')
