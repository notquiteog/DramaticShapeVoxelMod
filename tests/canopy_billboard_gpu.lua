-- Run inside a native LOVE driver. Exercise the production vertex transform
-- on the GPU at four headings, with an off-origin layer pivot.
return function(V)
  local G=love.graphics
  local shader=G.newShader([[
    #ifdef VERTEX
  ]]..V.require('CanopyBillboard').shader..[[
    uniform vec3 camera;
    uniform vec2 viewRight;
    vec4 position(mat4 ignored, vec4 vertex) {
      vec4 w=faceCanopy(mat4(1.0),vertex,camera);
      return vec4(dot(w.xz-vec2(20.0,30.0),viewRight)/24.0,
                  (w.y-8.0)/24.0,0.0,1.0);
    }
    #endif
    #ifdef PIXEL
    vec4 effect(vec4 colour,Image tex,vec2 uv,vec2 screen) {
      return vec4(1.0,1.0,1.0,1.0);
    }
    #endif
  ]])
  local canvas=G.newCanvas(128,128)
  local function render(angle,moving,viewAngle)
    local verts={}
    for _,p in ipairs({{-8,0},{8,0},{8,16},{-8,16}}) do
      verts[#verts+1]={20+p[1],p[2],30,0,0,20,30,moving and 1 or 0}
    end
    local mesh=G.newMesh({{'VertexPosition','float',3},
      {'VertexTexCoord','float',2},{'VertexCanopy','float',3}},verts,'fan')
    shader:send('camera',{20+100*math.sin(angle),24,30+100*math.cos(angle)})
    viewAngle=viewAngle or angle
    shader:send('viewRight',{math.cos(viewAngle),-math.sin(viewAngle)})
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
  assert(render(math.pi/2,false)<10,'fixed geometry unexpectedly billboarded')
  local _,front=render(0,false,0)
  local _,side=render(math.pi/2,false,0)
  assert(front==side,'fixed crown changed when camera position changed')
  canvas:release();shader:release()
  print('[canopy GPU] PASS four headings, local pivot, fixed shell')
end
