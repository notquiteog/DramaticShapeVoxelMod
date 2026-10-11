-- Shared battle-scene cutaway. A continuous camera-relative depth slab
-- clears foreground scenery across the viewport, preserving the supporting
-- floor and background. Target capsules additionally protect raised silhouettes.
local M={}
-- How much wider than the subject the frame is, in world pixels at the
-- subjects' depth: the GB frame holds about 34 world px vertically at the
-- aim distance and the subjects sit off its centre line, so a corridor that
-- clears the frame needs roughly the subject's own width plus this.
M.FRAME_MARGIN=20
-- The corridor holds the full frame out to this fraction of each sightline,
-- then eases back to the subject's own opening by the subject itself.
M.CORRIDOR_END=0.85
local function smooth(a,b,x)
  x=math.max(a,math.min(b,x));x=(x-a)/(b-a);return x*x*(3-2*x)
end
-- The corridor's radius at fraction t along one sightline, for a subject
-- whose own opening is w at t=1.
function M.radius(t,w)
  -- the subject's own opening at the far end: the historic capsule
  local mine=3+w*t
  -- the near/mid corridor: the whole frame, eased off before the stage
  local near=(w+M.FRAME_MARGIN)*t
    *(1-smooth(M.CORRIDOR_END,1,t))
  return math.max(mine,near)
end
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
 -- One depth slab spans the visible frame. Separate target capsules leave
 -- opaque bridges and circular rims around the combatants.
 local x,y,z=(out[1][1]+out[2][1])*.5,(out[1][2]+out[2][2])*.5,(out[1][3]+out[2][3])*.5
 local length=math.sqrt(x*x+y*y+z*z)
 if length>0 then
  x,y,z=x/length,y/length,z/length
  out.view={x,y,z,math.max(out[1][1]*x+out[1][2]*y+out[1][3]*z,out[2][1]*x+out[2][2]*y+out[2][3]*z)}
 else out.view={0,0,0,0} end
 return out
end
function M.foreground(ray,cut)
 if not cut or ray[2]<=cut.floor then return false end
 local v=cut.view
 local depth=ray[1]*v[1]+ray[2]*v[2]+ray[3]*v[3]
 return depth>0 and depth<v[4]
end
function M.blocks(ray,target)
 local len=target[1]^2+target[2]^2+target[3]^2
 if len<1 then return false end
 local t=(ray[1]*target[1]+ray[2]*target[2]+ray[3]*target[3])/len
 if t<=0 or t>=1 then return false end
 local d=0;for i=1,3 do d=d+(ray[i]-target[i]*t)^2 end
 return d<M.radius(t,target[4])^2
end
M.shader=[[
  uniform float battleCutOn;
  uniform float battleCutFloor;
  uniform vec4 battleCutView;
  uniform vec4 battleCutA;
  uniform vec4 battleCutB;
  float battleWidth(float t, float w) {
    float mine = 3.0 + w*t;
    float x = clamp((t - ]]..M.CORRIDOR_END..[[)/]]..(1-M.CORRIDOR_END)..[[, 0.0, 1.0);
    float ease = x*x*(3.0 - 2.0*x);
    float near = (w + ]]..M.FRAME_MARGIN..[[)*t*(1.0 - ease);
    return max(mine, near);
  }
  bool battleBlocked(vec3 ray, vec4 target) {
    float len = dot(target.xyz,target.xyz);
    if (len < 1.0) return false;
    float t = dot(ray,target.xyz)/len;
    if (t <= 0.0 || t >= 1.0) return false;
    float width = battleWidth(t, target.w);
    vec3 delta = ray-target.xyz*t;
    return dot(delta,delta) < width*width;
  }
]]
return M