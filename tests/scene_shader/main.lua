-- Real-driver regression probe (no ROM or engine required).
-- DS_MOD_PATH=/absolute/mod LOVE_GRAPHICS_USE_OPENGLES=1 love tests/scene_shader
function love.errorhandler(err)
 print('[scene shader] FAIL '..tostring(err))
 return function()love.event.quit(1)end
end
function love.load()
 local root=assert(os.getenv('DS_MOD_PATH'),'Set DS_MOD_PATH to the mod checkout')..'/lib/'
 local real={Mat4=true,CanopyBillboard=true,BattleOcclusion=true,DrawUniforms=true}
 local V={require=function(name)
  if real[name]then return assert(loadfile(root..name..'.lua'))()end
  return {} -- Non-shader scene services are not exercised by this probe.
 end}
 print('[renderer]',love.graphics.getRendererInfo())
 local R=assert(loadfile(root..'Voxel3D.lua'))(V)
 assert(R.available(),R.lastShaderError or '3D unavailable')
 assert(R.shader(),R.lastShaderError)
 if love.graphics.getSupported().shaderderivatives then
  assert(R.shader(true),R.lastShaderError)
 end
 assert(R.unlitShader(),R.lastShaderError)
 print('[scene shader] PASS plain/grid-supported/unlit')
 love.event.quit()
end
