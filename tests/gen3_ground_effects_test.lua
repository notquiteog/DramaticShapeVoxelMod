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
