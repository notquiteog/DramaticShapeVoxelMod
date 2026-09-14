local A=assert(loadfile('lib/Mat4.lua'))()
local Ball=assert(loadfile('lib/ItemPokeballs.lua'))({require=function(id) assert(id=='Mat4');return A end})
local v,ix=Ball.geometry()
local lo,hi={math.huge,math.huge,math.huge},{-math.huge,-math.huge,-math.huge}
for _,p in ipairs(v) do for i=1,3 do lo[i]=math.min(lo[i],p[i]);hi[i]=math.max(hi[i],p[i]) end end
assert(math.abs(hi[2]-4)<1e-8 and math.abs(lo[2])<1e-8,'handheld ball must be four pixels high and planted')
assert(hi[1]-lo[1]<=4 and hi[3]-lo[3]<4.2,'button must shrink with shell')
for _,i in ipairs(ix) do assert(v[i]) end
for _,ground in ipairs({0,6,14}) do
 local m=Ball.transform({px=16,py=32,groundHeight=ground,lift=2})
 assert(m[1]==1 and m[6]==1 and m[11]==1,'shared rock transform must not scale')
 assert(m[4]==24 and m[8]==ground+2 and m[12]==40,'ground/table/lift anchor shifted')
end
assert(Ball.accepts({spriteId='SPRITE_POKE_BALL'}))
assert(not Ball.accepts({isPlayer=true,spriteId='SPRITE_POKE_BALL'}))
print('item ball dimensions, indices, live ownership and shared rock transform passed')
