local U=dofile('lib/WaterDrawUniforms.lua').new()
local sends,fail=0,false
local shader={send=function()sends=sends+1;if fail then error('GPU failure')end end}
U:begin(shader)
local palette={.2,.4,.8,.88}
local matrix={1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1}
for i=1,100 do
 assert(U:send('nativePalette',palette))
 assert(U:send('reserveWater',0));assert(U:send('waveHeight',.3))
 assert(U:send('waveSlope',.3));assert(U:send('gardenWater',0))
 assert(U:send('model',matrix,true))
end
assert(sends==6,'identical water materials/models resent uniforms')
palette[1]=.5;assert(U:send('nativePalette',palette));matrix[4]=16;assert(U:send('model',matrix,true))
assert(sends==8,'in-place mutations were missed')
assert(U:send('reserveWater',1));assert(U:send('reserveWater',0));assert(sends==10,'returning material value was suppressed')
U:begin(shader);assert(U:send('nativePalette',palette));assert(sends==11,'begin must invalidate shader state from preceding pass')
fail=true;assert(not U:send('waveHeight',.5));assert(not U:send('waveHeight',.5));assert(sends==13,'failed sends must retry')
fail=false;assert(U:send('waveHeight',.5));assert(sends==14)
print('PASS 100 identical water meshes: 600 sends -> 6; mutable palette/model, material return, pass reset and failed-send retry')
