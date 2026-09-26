-- Native LÖVE driver test: identical model placements and sun shadows.
return function(V)
 local G=love.graphics;local R=V.require('Voxel3D');local Shadow=V.require('ShadowMap')
 local Hull=V.require('VoxelHull');local Instances=V.require('ModelInstances')
 local q=Hull.build(16,24,function()return .2,.65,.1,1,.5,.5 end,2,0,nil,'tree','conifer')
 local v,i={},{};Hull.append(q,v,i,0,0,0,0);local prototype=assert(R.newMesh(v,i))
 local positions={{-20,0,-12},{15,0,14},{5,7,-20}}
 v,i={},{};for _,p in ipairs(positions)do Hull.append(q,v,i,0,unpack(p))end
 local merged=assert(R.newMesh(v,i));local batch=assert(Instances.new(prototype,positions))
 local pixels=love.image.newImageData(1,1);pixels:setPixel(0,0,.2,.65,.1,1)
 local texture=G.newImage(pixels);pixels:release()
 local floor=R.newMesh({{-70,0,-70,.5,.5,1},{70,0,-70,.5,.5,1},{70,0,70,.5,.5,1},{-70,0,70,.5,.5,1}},{1,2,3,1,3,4})
 local saved=G.getCanvas();G.push('all')
 V.require('Shadows').setting:sync('high')
 R.canopyFacing=false;R.fog=nil;R.interior=nil;R.tint={1,1,1}
 local function render(mesh,angle)
  R.camera={eye={90*math.sin(angle),48,90*math.cos(angle)},focus={0,10,0},fov=math.rad(55)}
  R.viewProjection(0,0,160,120)
  assert(Shadow.begin(0,0,160,120));Shadow.draw(floor,texture);Shadow.draw(mesh,texture);Shadow.finish('instance-test')
  assert(R.beginScene(320,240,0,0,160,120,{.3,.5,.8,1},'instance-test'))
  R.draw(floor,texture);R.draw(mesh,texture)
  -- Draw an ordinary model after the batch: an instancing uniform leak
  -- would move it, or make a missing vertex attribute affect its placement.
  R.draw(prototype,texture,V.require('Mat4').translate(-28,0,24))
  local data=R.endScene():newImageData();local bytes=data:getString();data:release();return bytes
 end
 for _,angle in ipairs({0,math.pi*.5,math.pi,math.pi*1.5})do
  assert(render(merged,angle)==render(batch,angle),'GPU instances changed geometry/shadows at '..angle)
 end
 batch:release();prototype:release();merged:release();floor:release();texture:release()
 Shadow.discard();R.camera=nil;G.pop();G.setCanvas(saved)
 print('PASS GPU instanced/merged pixels and shadows identical at four headings; ordinary draw restored')
end
