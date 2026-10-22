-- Gen 2 blits a pipeline result at unit scale; Gen 1 applies inverse DPI.
-- Keep rendering in physical pixels, then return a logical-size high-DPI
-- canvas for Gen 2. No copy is needed on density-1 displays.
local M={}
function M.install(World)
  local inner=World.drawPipeline
  local target,tw,th,td
  local function release()
    if target then target:release();target=nil end
  end
  function World:drawPipeline(id,w,h,...)
    local canvas=inner(self,id,w,h,...)
    if id~='voxel'or not canvas then return canvas end
    local cw,ch=canvas:getDimensions()
    if cw==w and ch==h then return canvas end
    local d=math.max(cw/w,ch/h)
    if not target or tw~=w or th~=h or td~=d then
      local ok,made=pcall(love.graphics.newCanvas,w,h,{dpiscale=d})
      if not ok or not made then return nil end -- native scene on allocation failure
      release();target=made;tw,th,td=w,h,d
      target:setFilter('nearest','nearest')
    end
    local g=love.graphics;local previous=g.getCanvas()
    g.push('all')
    local ok=pcall(function()
      g.origin();g.setScissor();g.setShader();g.setCanvas(target)
      g.setDepthMode('always',false);g.setStencilTest();g.setColorMask(true,true,true,true)
      g.clear(0,0,0,0);g.setColor(1,1,1,1);g.setBlendMode('replace','premultiplied')
      g.draw(canvas,0,0,0,w/cw,h/ch)
    end)
    g.setCanvas(previous);g.pop()
    return ok and target or nil
  end
  return function()World.drawPipeline=inner;release()end
end
return M
