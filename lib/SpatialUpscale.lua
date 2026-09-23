-- AMD FSR 1 EASU + RCAS on the 3D scene only. HUD/text stay native resolution.
-- These are the unmodified MIT reference kernels; only the texture callbacks
-- and LÖVE postprocess plumbing live here. No temporal/DLSS claim is implied.
local V=...
local M={}
M.setting=V.require('ModSetting').new('spatialUpscale','FSR 1',
 {1,1.3,1.5,1.7,2},{'OFF','ULTRA QUALITY','QUALITY','BALANCED','PERFORMANCE'})
M.description='AMD FSR 1 spatial upscaling for the 3D scene. HUD/text stay at full resolution. Takes priority over supersampling AA; OFF preserves native pixels. No frame generation.'
local shaders,targets
local pre=[[
#pragma language glsl3
#define A_GPU 1
#define A_GLSL 1
#ifdef PIXEL
uniform Image source;
uniform vec2 inputSize;
uniform vec2 outputSize;
// GLSL 330 lacks half packing. Only the reference setup's unused FP16
// constant needs it here; retain correct packing without requiring GL 4.2.
uint fsrHalf(float value){
 uint u=floatBitsToUint(value),s=(u>>16u)&0x8000u,m=u&0x7fffffu,ex=(u>>23u)&255u;
 if(ex==255u)return s|0x7c00u|(m==0u?0u:0x200u);
 int e=int(ex)-112;
 if(e>=31)return s|0x7c00u;
 if(e<=0){
  if(e< -10)return s;
  m|=0x800000u;uint shift=uint(14-e),h=m>>shift;
  uint tail=m&((1u<<shift)-1u),halfway=1u<<(shift-1u);
  return s|(h+uint(tail>halfway||(tail==halfway&&(h&1u)!=0u)));
 }
 return s|((uint(e)<<10u)+((m+0xfffu+((m>>13u)&1u))>>13u));
}
uint fsrPackHalf(vec2 v){return fsrHalf(v.x)|(fsrHalf(v.y)<<16u);}
#define packHalf2x16 fsrPackHalf
uint fsrExtract(uint value,int offset,int count){
 return count==0?0u:count>=32?value:(value>>uint(offset))&((1u<<uint(count))-1u);
}
uint fsrInsert(uint base,uint insert,int offset,int count){
 if(count>=32)return insert;
 uint mask=((1u<<uint(count))-1u)<<uint(offset);
 return (base&~mask)|((insert<<uint(offset))&mask);
}
#define bitfieldExtract fsrExtract
#define bitfieldInsert fsrInsert
]]
local easu=[[
// A gather is ordered lower-left, lower-right, upper-right, upper-left.
// Explicit taps also work without GL_ARB_texture_gather / GLES extensions.
vec4 gatherChannel(vec2 p,int c){
 vec2 b=floor(p*inputSize-0.5)+0.5;
 return vec4(Texel(source,(b+vec2(0,1))/inputSize)[c],
 Texel(source,(b+vec2(1,1))/inputSize)[c],
 Texel(source,(b+vec2(1,0))/inputSize)[c],Texel(source,b/inputSize)[c]);
}
vec4 FsrEasuRF(vec2 p){return gatherChannel(p,0);}
vec4 FsrEasuGF(vec2 p){return gatherChannel(p,1);}
vec4 FsrEasuBF(vec2 p){return gatherChannel(p,2);}
vec4 effect(vec4 color,Image tex,vec2 uv,vec2 screen){
 uvec4 a,b,c,d;FsrEasuCon(a,b,c,d,inputSize.x,inputSize.y,inputSize.x,inputSize.y,outputSize.x,outputSize.y);
 vec3 rgb;FsrEasuF(rgb,uvec2(uv*outputSize),a,b,c,d);
 return vec4(rgb,Texel(source,uv).a)*color;
}
#endif
]]
local rcas=[[
vec4 FsrRcasLoadF(ivec2 p){return Texel(source,(vec2(p)+0.5)/inputSize);}
void FsrRcasInputF(inout float r,inout float g,inout float b){}
vec4 effect(vec4 color,Image tex,vec2 uv,vec2 screen){
 uvec4 c;FsrRcasCon(c,0.7);vec3 rgb;FsrRcasF(rgb.r,rgb.g,rgb.b,uvec2(uv*inputSize),c);
 return vec4(rgb,Texel(source,uv).a)*color;
}
#endif
]]
local function ready()
 if shaders~=nil then return shaders~=false end
 local ok,a,b=pcall(function()
  local common=assert(V.mod:read('assets/shaders/fsr1/ffx_a.h'))
  local kernel=assert(V.mod:read('assets/shaders/fsr1/ffx_fsr1.h'))
  -- GLSL 330 requires unsigned literals in the reference setup constants.
  kernel=kernel:gsub('(con%d?%[%d%])=0;', '%1=0u;')
  local e=love.graphics.newShader(pre..'\n#define FSR_EASU_F 1\n'..common..kernel..easu)
  local r=love.graphics.newShader(pre..'\n#define FSR_RCAS_F 1\n'..common..kernel..rcas)
  return e,r
 end)
 if ok then shaders={a,b};return true end
 shaders=false;M.error=tostring(a);print('[Battle Art FSR1] unavailable: '..M.error);return false
end
function M.factor()
 local value=tonumber(M.setting:get())or 1
 return value>1 and ready()and value or 1
end
function M.resolve(canvas,w,h,slot)
 if not ready()then return canvas end
 local g=love.graphics;targets=targets or {};slot=slot or 'world'
 local t=targets[slot]
 if not t or t.w~=w or t.h~=h then
  if t then for _,c in ipairs(t)do c:release()end end
  t={w=w,h=h};for i=1,2 do t[i]=g.newCanvas(w,h);t[i]:setFilter('nearest','nearest')end;targets[slot]=t
 end
 local originalMin,originalMag,anisotropy=canvas:getFilter()
 g.push('all');g.origin();g.setScissor();g.setDepthMode();g.setBlendMode('replace','premultiplied');g.setColor(1,1,1,1)
 local ok,err=pcall(function()
  local src=canvas
  for i=1,2 do
   src:setFilter('nearest','nearest');local sw,sh=src:getDimensions();local shader=shaders[i]
   g.setCanvas(t[i]);g.setShader(shader);shader:send('source',src);shader:send('inputSize',{sw,sh})
   if shader:hasUniform('outputSize')then shader:send('outputSize',{w,h})end
   g.draw(src,0,0,0,w/sw,h/sh);src=t[i]
  end
 end)
 g.pop();canvas:setFilter(originalMin,originalMag,anisotropy)
 if not ok then M.error=tostring(err);return canvas end
 M.last={sourceWidth=canvas:getWidth(),sourceHeight=canvas:getHeight(),width=w,height=h}
 return t[2]
end
function M.invalidate()
 for _,t in pairs(targets or {})do for _,c in ipairs(t)do c:release()end end;targets=nil
end
return M
