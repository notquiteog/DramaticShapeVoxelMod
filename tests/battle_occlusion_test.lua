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
-- The corridor: the whole frame is clear of scenery between the camera and
-- the fight, not just the sightline thread. A trunk beside the sightline,
-- a quarter of the way out, is inside the cut -- under the old capsule it
-- rendered and the fight read through the hole it left (the binocular shot).
for _,target in ipairs(cut) do
  local w=target[4]
  local ray={target[1]*.25,target[2]*.25,target[3]*.25}
  ray[1]=ray[1]+(3+w*.25)          -- just past the old capsule's radius there
  assert(B.blocks(ray,target),
    'scenery beside the sightline, near the camera, must clear')
  -- and the stage keeps its surroundings: at the subjects' own depth the
  -- corridor is eased away and only the subject's opening remains.
  local far={target[1]*.95,target[2]*.95,target[3]*.95}
  far[1]=far[1]+(3+w*.95)
  assert(not B.blocks(far,target),
    'scenery beside the subjects stays in the shot')
end
-- the radius itself: mon opening at the subject, full frame mid-line
assert(B.radius(1,15)==3+15,'the subject end keeps its own opening')
assert(B.radius(.5,15)>=(15+20)*.5,'the mid-line corridor clears the frame')
assert(B.radius(0,15)==3,'at the lens only the thread was ever needed')
print('Battle occlusion: both groups, depth limits, floor and corridor PASS')
-- Foreground clearing spans the viewport, including the bridge between two
-- targets and arbitrarily wide aspect ratios. Ground/background remain intact.
for _,x in ipairs({-150,-25,0,15,60,150})do
 local z=(cut.view[4]*.4-x*cut.view[1])/cut.view[3]
 assert(B.foreground({x,0,z},cut),'foreground rim survives across the frame')
 assert(not B.foreground({x,cut.floor,z},cut),'battle floor erased')
end
assert(not B.foreground({cut.view[1]*(cut.view[4]+10),0,cut.view[3]*(cut.view[4]+10)},cut))
assert(not B.foreground({-cut.view[1],0,-cut.view[3]},cut))
print('Battle continuous foreground slab PASS')

local overhead=B.build({16,80,64},arena,0)
assert(B.foreground({0,-30,0},overhead),'overhead camera leaves foreground canopy opaque')
assert(not B.foreground({0,-80,0},overhead),'overhead floor clipped')
print('Battle overhead cutaway PASS')

-- GLSL ES does not implicitly promote an injected Lua integer to float.
assert(B.shader:find('w + float(20)',1,true),'battle margin became an integer shader operand')
