-- Camera-facing foliage, anchored where it meets the independent trunk.
-- Share the exact upright transform with the shadow pass. Camera altitude
-- and distance must never tip a plant away from its physical ground anchor.
local M={}
M.shader=[[
  uniform float canopyFacing;
  attribute vec3 VertexCanopy; // local anchor X/Z/Y; negative Y marks trunk, zero is ordinary geometry
  vec4 faceCanopy(mat4 transform, vec4 vertex, vec3 camera) {
    vec4 w=transform*vertex;
    if (abs(VertexCanopy.z) < 0.0001) return w;
    vec3 localAnchor=vec3(VertexCanopy.x,abs(VertexCanopy.z),VertexCanopy.y);
    vec3 anchor=(transform*vec4(localAnchor,1.0)).xyz;
    // Cylindrical billboarding: yaw only. A close eye below the canopy must
    // not rotate its top backwards or lift its roots out of the ground.
    vec3 toward=canopyFacing>0.5?vec3(camera.x-anchor.x,0.0,camera.z-anchor.z):vec3(0.0,0.0,1.0);
    if (dot(toward,toward)<0.0001) toward=vec3(0.0,0.0,1.0);
    vec3 forward=normalize(toward);
    if (VertexCanopy.z < 0.0) {
      // Root stays physical. Only wood above the foliage anchor is put
      // behind its own leaf plane; normal scene depth testing stays enabled.
      if (vertex.y > localAnchor.y) {
        float front=max(0.0,dot(w.xyz-anchor,forward)+0.35);
        w.xyz-=forward*front;
      }
      return w;
    }
    vec3 right=vec3(toward.z,0.0,-toward.x);
    if (dot(right,right)<0.0001) right=vec3(1.0,0.0,0.0);
    right=normalize(right);
    vec3 up=vec3(0.0,1.0,0.0);
    float sx=length((transform*vec4(1.0,0.0,0.0,0.0)).xyz);
    float sy=length((transform*vec4(0.0,1.0,0.0,0.0)).xyz);
    vec3 d=vertex.xyz-localAnchor;
    // A small local depth offset keeps the flat trunk behind its leaf art.
    float sz=length((transform*vec4(0.0,0.0,1.0,0.0)).xyz);
    w.xyz=anchor+right*d.x*sx+up*d.y*sy+forward*d.z*sz;
    return w;
  }
]]
return M
