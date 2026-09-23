-- Run inside a native LOVE driver. Exercise the production vertex transform
-- on the GPU at four headings, with an off-origin layer pivot.
return function(V)
  local G=love.graphics
  local shader=G.newShader([[
    #ifdef VERTEX
  ]]..V.require('CanopyBillboard').shader..[[
    uniform vec3 camera;
    uniform vec2 viewRight;
    uniform vec3 viewUp;
    vec4 position(mat4 ignored, vec4 vertex) {
      vec4 w=faceCanopy(mat4(1.0),vertex,camera);
      return vec4(dot(w.xz-vec2(20.0,30.0),viewRight)/24.0,
                  dot(w.xyz-vec3(20.0,8.0,30.0),viewUp)/24.0,0.0,1.0);
    }
    #endif
    #ifdef PIXEL
    vec4 effect(vec4 colour,Image tex,vec2 uv,vec2 screen) {
      return vec4(1.0,1.0,1.0,1.0);
    }
    #endif
  ]])
  local canvas=G.newCanvas(128,128)
  local function render(angle,moving,viewAngle,pitch,static)
    local verts={}
    for _,p in ipairs({{-8,0},{8,0},{8,16},{-8,16}}) do
      verts[#verts+1]={20+p[1],p[2],30,0,0,20,30,moving and 8 or 0}
    end
    local mesh=G.newMesh({{'VertexPosition','float',3},
      {'VertexTexCoord','float',2},{'VertexCanopy','float',3}},verts,'fan')
    shader:send("canopyFacing",static and 0 or 1)
    pitch=pitch or 0
    shader:send('camera',{20+100*math.sin(angle)*math.cos(pitch),
      8+100*math.sin(pitch),30+100*math.cos(angle)*math.cos(pitch)})
    viewAngle=viewAngle or angle
    shader:send('viewRight',{math.cos(viewAngle),-math.sin(viewAngle)})
    shader:send('viewUp',{-math.sin(viewAngle)*math.sin(pitch),
      math.cos(pitch),-math.cos(viewAngle)*math.sin(pitch)})
    G.push('all');G.setCanvas(canvas);G.clear(0,0,0,0);G.origin()
    G.setShader(shader);G.setMeshCullMode('none');G.setBlendMode('replace')
    G.draw(mesh);G.pop();mesh:release()
    local data=canvas:newImageData();local count=0
    for y=0,127 do for x=0,127 do
      local _,_,_,a=data:getPixel(x,y);if a>.5 then count=count+1 end
    end end
    local bytes=data:getString();data:release()
    return count,bytes
  end
  for _,angle in ipairs({0,math.pi/2,math.pi,-math.pi/2}) do
    assert(render(angle,true)>1500,'leaf layer turned edge-on')
  end
  assert(render(0,true,nil,math.rad(75))>400,'upright tree disappears at highest exposed angle')
  assert(render(0,true,nil,math.pi/2)<10,'tree tilted into the overhead camera')
  assert(render(math.pi/2,false)<10,'fixed geometry unexpectedly billboarded')
  local _,front=render(0,false,0)
  local _,side=render(math.pi/2,false,0)
  assert(front==side,'solid geometry changed when camera position changed')
  local _,staticA=render(0,true,0,0,true)
  local _,staticB=render(math.pi/2,true,0,0,true)
  assert(staticA==staticB,'static-view tree turns as the eye moves')
  assert(render(0,true,nil,math.rad(75),true)>400,'fixed tree disappears at highest exposed angle')
  shader:release()
  -- Report which side of the foliage plane the production transform puts
  -- each trunk fragment on. Upper wood must be behind; roots remain physical.
  shader=G.newShader([[
    varying float inFront;
    #ifdef VERTEX
  ]]..V.require('CanopyBillboard').shader..[[
    uniform float rootOffset;
    vec4 position(mat4 ignored,vec4 vertex) {
      vec4 wood=vertex;wood.y-=rootOffset;
      vec4 w=faceCanopy(mat4(1.0),wood,vec3(20.0,20.0,130.0));
      inFront=dot(w.xyz-vec3(20.0,8.0,30.0),vec3(0.0,0.0,1.0));
      return vec4((vertex.x-20.0)/24.0,(vertex.y-18.0)/24.0,0.0,1.0);
    }
    #endif
    #ifdef PIXEL
    vec4 effect(vec4 c,Image tex,vec2 uv,vec2 screen) {
      return inFront>0.0?vec4(1.0,0.0,0.0,1.0):vec4(0.0,1.0,0.0,1.0);
    }
    #endif
  ]])
  local wood=G.newMesh({{'VertexPosition','float',3},
    {'VertexTexCoord','float',2},{'VertexCanopy','float',3}},
    {{12,10,38,0,0,20,30,-8},{28,10,38,0,0,20,30,-8},
     {28,26,38,0,0,20,30,-8},{12,26,38,0,0,20,30,-8}},'fan')
  for _,offset in ipairs({0,20}) do
    G.push('all');G.setCanvas(canvas);G.clear(0,0,0,0);G.origin()
    G.setShader(shader);G.setMeshCullMode('none');G.setBlendMode('replace')
    shader:send('rootOffset',offset);shader:send('canopyFacing',1);G.draw(wood);G.pop()
    local data=canvas:newImageData();local red,green=data:getPixel(64,64)
    assert(offset==0 and green>.9 or offset==20 and red>.9,
      'upper wood must sit behind foliage without displacing the root')
    data:release()
  end
  wood:release();canvas:release();shader:release()
  print('[canopy GPU] PASS static orientation, free-camera headings, upright high-angle foliage, upper-wood occlusion')
end
