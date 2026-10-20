local Cam=assert(loadfile('lib/BattleCam.lua'))({})
local Mat=assert(loadfile('lib/Mat4.lua'))()
local arena={mid={0,0},cameraSafe=true}
for _,layout in ipairs({'modern','gen3-native-pair'})do
 local rig=Cam.rig(Cam.forLayout(arena,layout),0,true)
 local lens=layout=='modern'and 2*math.atan(math.tan(rig.fov/2)*2.3)or rig.fov
 local base=math.tan(lens/2)*1.5
 for _,aspect in ipairs({360/640,540/960,1,1.5,16/9})do
  local fitted=Cam.fitAspect(lens,aspect)
  assert(math.abs(math.tan(fitted/2)*aspect-math.max(base,math.tan(lens/2)*aspect))<1e-8,
   'narrow view cropped native battlefield horizontal span')
  if aspect>=1.5 then assert(math.abs(fitted-lens)<1e-8,'landscape lens changed')end
 end
 local function projected(aspect,x,y,z)
  local vp=Mat.mul(Mat.perspective(Cam.fitAspect(lens,aspect),aspect,1,4096),
   Mat.lookAt(rig.eye,rig.focus,{0,1,0}))
  local w=vp[13]*x+vp[14]*y+vp[15]*z+vp[16]
  return .5+.5*(vp[1]*x+vp[2]*y+vp[3]*z+vp[4])/w
 end
 local span,row=layout=='modern'and 32 or 12,layout=='modern'and 24 or 40
 for _,x in ipairs({-span,span})do for _,z in ipairs({-row,row})do
  local p=projected(360/640,x,0,z)
  assert(math.abs(p-projected(1.5,x,0,z))<1e-8,'portrait displaced a paired actor')
  assert(p>0 and p<1,'paired actor anchor outside native composition')
 end end
end
print('PASS portrait GBA paired actor anchors preserve native horizontal framing; landscape unchanged')
