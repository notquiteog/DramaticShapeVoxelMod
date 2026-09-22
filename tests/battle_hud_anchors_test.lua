local A=dofile('lib/BattleHudAnchors.lua')
local I={1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1}
local function card(m)
 return {tex={getWidth=function()return 100 end,getHeight=function()return 100 end},model=m,
  hudAnchors={player={25,25},player2={75,50}}}
end
local h=A.project({card(I)},I)
assert(h.player[1]==.375 and h.player[2]==.875)
assert(h.player2[1]==.625 and h.player2[2]==.75,'paired heads collapsed')
local mirrored={-1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1}
h=A.project({card(mirrored)},I)
assert(h.player[1]==.625 and h.player2[1]==.375,'heads did not follow mirrored art')
local behind={1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,-1}
assert(next(A.project({card(I)},behind))==nil,'behind-camera card projected')
local Clear=dofile('lib/Gen3BattleClear.lua')
assert(not Clear.hits(nil,-5,-5,5,5))
local c={battle=true,center={0,0},yaw=0}
assert(Clear.hits(c,-5,-5,5,5),'stage occupied')
assert(Clear.hits(c,-4,70,4,90),'camera corridor occupied')
assert(not Clear.hits(c,60,60,70,70),'distant scenery removed')
assert(Clear.hits(c,40,0,160,100),'building intersecting clearing must hide whole')
assert(not Clear.hits(c,-5,-100,5,-80),'distant backdrop removed')
c.yaw=math.pi/2
assert(Clear.hits(c,-90,-4,-70,4),'rotated camera corridor occupied')
c.battle=false
assert(not Clear.hits(c,-5,-5,5,5),'battle culling leaked into overworld')
print('PASS paired/mirrored head projection, behind-camera guard, whole-object battle clearing and field restoration')
