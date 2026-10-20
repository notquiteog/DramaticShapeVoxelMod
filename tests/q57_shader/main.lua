-- Real-driver probe: DS_MOD_PATH=/absolute/mod LOVE_GRAPHICS_USE_OPENGLES=1
-- love tests/q57_shader. Desktop GLES is not physical Android/iOS verification.
function love.errorhandler(err)
 print('[q57 shader] FAIL '..tostring(err))
 return function()love.event.quit(1)end
end
function love.load()
 local root=assert(os.getenv('DS_MOD_PATH'))
 local Material=assert(loadfile(root..'/lib/q57/Material.lua'))()
 local identity={1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1}
 local format={{'VertexPosition','float',3},{'VertexTexCoord','float',2}}
 local mesh=love.graphics.newMesh(format,{{-.8,-.8,0,0,1},{.8,-.8,0,1,1},{.8,.8,0,1,0},{-.8,.8,0,0,0}},'fan','static')
 local pixels=love.image.newImageData(8,8)
 for y=0,7 do for x=0,7 do pixels:setPixel(x,y,1,.25,.1,(x>0 and x<7)and 1 or 0)end end
 local image=love.graphics.newImage(pixels);image:setFilter('nearest','nearest')
 local canvas=love.graphics.newCanvas(96,96,{dpiscale=1})
 local voxel={vp=identity,eye={0,0,4}}
 local pose={source={0,0,0},mouth={0,-1,0},width=2,height=2,timer=.6,convert=.5,release=true}
 love.graphics.setCanvas(canvas);love.graphics.clear(0,0,0,0);love.graphics.setColor(.3,.4,.5,.6)
 for _,subject in ipairs({false,true})do
  assert(Material.draw(voxel,mesh,image,identity,0,pose,subject),Material.status().error)
  assert(love.graphics.getShader()==nil,'material leaked shader')
  local r,g,b,a=love.graphics.getColor();assert(math.abs(r-.3)<.001 and math.abs(a-.6)<.001,'material leaked color')
 end
 love.graphics.setCanvas();local output=canvas:newImageData();local opaque=0
 for y=0,95 do for x=0,95 do local _,_,_,a=output:getPixel(x,y);if a>0 then opaque=opaque+1 end end end
 assert(opaque>100,'material produced no visible pixels')
 print('[renderer]',love.graphics.getRendererInfo())
 print('[q57 shader] PASS volume/subject draw, visible pixels, state restore',opaque)
 Material.release();mesh:release();image:release();pixels:release();canvas:release();output:release()
 love.event.quit()
end
