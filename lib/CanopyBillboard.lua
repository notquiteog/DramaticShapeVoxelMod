-- Face individual leaf layers toward the view without rotating the fixed
-- crown shell, its cap, or the trunk. Colour and shadow passes share pivots.
local M={}
M.shader=[[
  attribute vec3 VertexCanopy; // local pivot X/Z, enabled
  vec4 faceCanopy(mat4 transform, vec4 vertex, vec3 camera) {
    vec4 w=transform*vertex;
    if (VertexCanopy.z < 0.5) return w;
    vec3 pivot=(transform*vec4(VertexCanopy.x,0.0,VertexCanopy.y,1.0)).xyz;
    vec2 toward=(camera-pivot).xz;
    if (dot(toward,toward)<0.0001) return w;
    vec3 original=(transform*vec4(0.0,0.0,1.0,0.0)).xyz;
    float a=atan(toward.x,toward.y)-atan(original.x,original.z);
    float c=cos(a),s=sin(a);
    vec2 d=w.xz-pivot.xz;
    w.xz=pivot.xz+vec2(c*d.x+s*d.y,-s*d.x+c*d.y);
    return w;
  }
]]
return M
