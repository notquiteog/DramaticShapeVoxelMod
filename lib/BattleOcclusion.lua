-- A camera-relative opening to each complete battler group. Scenery behind
-- the subjects and the battle's supporting floor remain intact.
local M={}
function M.build(eye,arena,ground,textures)
 if not (eye and arena and arena.player and arena.enemy) then return nil end
 local out={floor=(ground or 0)+.25-eye[2]}
 for i,side in ipairs({'player','enemy'}) do
  local tex=textures and textures[side] or {}
  local k=16/56
  local width=(tex.contentWidth or 56)*k
  local height=(tex.contentHeight or 56)*k
  local p=arena[side]
  out[i]={p[1]-eye[1],(ground or 0)+height*.5-eye[2],p[2]-eye[3],
   math.max(10,width*.5,height*.5)+5}
 end
 return out
end
function M.blocks(ray,target)
 local len=target[1]^2+target[2]^2+target[3]^2
 if len<1 then return false end
 local t=(ray[1]*target[1]+ray[2]*target[2]+ray[3]*target[3])/len
 if t<=0 or t>=1 then return false end
 local d=0;for i=1,3 do d=d+(ray[i]-target[i]*t)^2 end
 return d<(3+target[4]*t)^2
end
M.shader=[[
  uniform float battleCutOn;
  uniform float battleCutFloor;
  uniform vec4 battleCutA;
  uniform vec4 battleCutB;
  bool battleBlocked(vec3 ray, vec4 target) {
    float len = dot(target.xyz,target.xyz);
    if (len < 1.0) return false;
    float t = dot(ray,target.xyz)/len;
    if (t <= 0.0 || t >= 1.0) return false;
    float width = 3.0 + target.w*t;
    vec3 delta = ray-target.xyz*t;
    return dot(delta,delta) < width*width;
  }
]]
return M
