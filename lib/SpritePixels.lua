-- One-time public readback for sprite providers exposing only a GPU Image.
-- Native CPU sheets and Canvas snapshots avoid the copy. Caller releases owned data.
local M={}
function M.snapshot(image)
 if not image then return end
 if type(image.newImageData)=='function' then
  local ok,data=pcall(image.newImageData,image);if ok and data then return data end
 end
 local gfx=love and love.graphics
 if not(gfx and gfx.newCanvas and image.getDimensions)then return end
 local canvas,pushed,data
 local ok=pcall(function()
  local w,h=image:getDimensions();canvas=gfx.newCanvas(w,h)
  gfx.push('all');pushed=true;gfx.setCanvas(canvas);gfx.origin();gfx.setShader();gfx.setScissor()
  gfx.setColor(1,1,1,1);gfx.setBlendMode('replace','premultiplied');gfx.clear(0,0,0,0)
  gfx.draw(image,0,0);gfx.pop();pushed=false
  data=canvas:newImageData()
 end)
 if pushed then gfx.pop()end
 if canvas and canvas.release then canvas:release()end
 if ok then return data end
end
return M
