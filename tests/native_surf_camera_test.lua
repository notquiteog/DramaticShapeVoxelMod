local S=dofile('lib/SurfCamera.lua')
local me={px=0,py=0,gh=-8};local state={player={surfing=true}}
assert(S.measure(me,{},state)==nil,'native HD2D surfer invented an oversized model')
me.surfRide={seatY=24}
local fallback=S.measure(me,{},state)
assert(fallback.distance==180 and fallback.radius==66 and fallback.seat==24,'unavailable Stadium2 metadata lost safe clearance')
me.surfRide=nil
local p={surfMount={playerPose=me},stadiumMon={}}
assert(S.measure(me,{p},state).distance==180,'posed provider mount lost unavailable-buffer fallback')
me.surfRide={seatY=5}
p.stadiumMatrix={1,0,0,0,0,1,0,0,0,0,1,0};p.stadiumMon.rig={parts={{rows={{0,4,0},{20,16,0}}}}}
local measured=S.measure(me,{p},state)
assert(measured.top==16 and measured.radius==math.sqrt(12^2+8^2) and measured.seat==5,'real model bounds replaced by invented native camera')
state.flyAnim={};assert(S.measure(me,{p},state)==nil,'Fly retained Surf camera')
state.flyAnim=nil;state.player._pokepcAsPokemon=true;assert(S.measure(me,{p},state)==nil)
state.player._pokepcAsPokemon=nil;state.player.surfing=false;assert(S.measure(me,{p},state)==nil)
print('PASS native HD2D Surf stays at the head; measured Stadium and missing-buffer provider clearance/lifecycle preserved')
