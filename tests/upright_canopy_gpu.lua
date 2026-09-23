-- Production GLSL: varying the eye height/distance must never tilt a plant.
return function(V)
 local g=love.graphics
 local shader=g.newShader('#ifdef VERTEX\n'..V.require('CanopyBillboard').shader..[[
 uniform vec3 camera;
 varying float errorAmount;
 vec4 position(mat4 unused,vec4 vertex) {
  vec4 w=faceCanopy(mat4(1.0),vertex,camera);
  errorAmount=abs(w.y-vertex.y)+abs(w.z-30.0);
  return vec4((w.x-20.0)/16.0,(w.y-8.0)/16.0,0.0,1.0);
 }
 #endif
 #ifdef PIXEL
 varying float errorAmount;
 vec4 effect(vec4 c,Image t,vec2 uv,vec2 sc) {return errorAmount<0.0001?vec4(0,1,0,1):vec4(1,0,0,1);}
 #endif
 ]])
 local mesh=g.newMesh({{'VertexPosition','float',3},{'VertexTexCoord','float',2},{'VertexCanopy','float',3}},
 {{12,0,30,0,0,20,30,8},{28,0,30,0,0,20,30,8},{28,16,30,0,0,20,30,8},{12,16,30,0,0,20,30,8}},'fan')
 local canvas=g.newCanvas(64,64);local baseline
 for _,facing in ipairs({0,1})do for _,height in ipairs({-40,0,8,23,100,1000})do for _,distance in ipairs({.01,5,100})do
  g.push('all');g.setCanvas(canvas);g.clear(0,0,0,0);g.origin();g.setShader(shader);g.setBlendMode('replace');g.setMeshCullMode('none')
  shader:send('canopyFacing',facing);shader:send('camera',{20,height,30+distance});g.draw(mesh);g.pop()
  local data=canvas:newImageData();local red,green=data:getPixel(32,32)
  assert(red==0 and green>.9,'plant leaned or moved its foot plane')
  local bytes=data:getString();baseline=baseline or bytes;assert(bytes==baseline,'eye height/distance changed plant geometry');data:release()
 end end end
 mesh:release();canvas:release();shader:release()
 print('[upright canopy GPU] PASS 36 static/free eye heights and distances')
end
