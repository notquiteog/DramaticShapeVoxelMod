local B=assert(loadfile('lib/BattleOcclusion.lua'))()
local eye={0,24,0}
local arena={player={0,48},enemy={32,80}}
local cut=B.build(eye,arena,0,{player={contentWidth=56,contentHeight=56},
  enemy={contentWidth=112,contentHeight=56}})
assert(cut and cut.floor==-23.75)
for _,target in ipairs(cut) do
  local front,behind={},{ }
  for i=1,3 do front[i]=target[i]*.5;behind[i]=target[i]*1.2 end
  assert(B.blocks(front,target),'scenery in front of battler stays opaque')
  assert(not B.blocks(behind,target),'scenery behind battler disappears')
  assert(not B.blocks(target,target),'battler plane is clipped')
  front[1]=front[1]+100
  assert(not B.blocks(front,target),'unrelated scenery is clipped')
end
assert(not B.blocks({0,0,0},cut[1]))
assert(not B.blocks({0,0,0},{0,0,0,20}))
-- The draw shader's height gate preserves the supporting terrain plane.
assert(0-eye[2]<=cut.floor)
assert(B.build(eye,nil,0)==nil,'leaving battle retains a cut volume')
print('Battle occlusion: both groups, depth limits, floor and unrelated scenery PASS')
