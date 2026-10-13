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
local wet={_anims={{kind='splash'},{kind='feet_water'},{kind='hot_springs'}},collectActors=function(out)
 out[1]={kind='field_effect_splash',i=1,x=32,y=68,sortY=64.5,draw=function(_,x,y)assert(x==32 and y==68);attached=attached+1 end}
end}
M.draw(wet,function(x,z)assert(x==40 and z==72);return 3 end,function(id,w,h,paint,v,base)
 assert(w==16 and h==8 and base==3);assert(v[1][2]==8 and v[3][2]==0);paint()
end,{level=6,yaw=math.pi/2})
assert(attached==1 and M.supports('camera_shake'),'attached water effects or shake lose camera')
print('PASS player-attached native splash art, rotated upright card and terrain support')
