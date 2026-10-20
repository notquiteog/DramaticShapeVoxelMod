-- Coherent low waves for the native GBA scenery adapter. The shader computes
-- height and its analytic gradient together; no relief traversal or repeated
-- noise/finite-difference samples are needed. Legacy GB water is separate.
local M={HEIGHT=.30,SLOPE=1.9}
M.glsl=[[
vec3 nativeSurface(vec2 q,float t,vec2 footprint) {
 vec2 k0=vec2(.105,.033),k1=vec2(-.049,.119),k2=vec2(.174,.153);
 vec2 bendK=vec2(.017,-.013);
 float bendPhase=dot(q,bendK)-t*.10;
 vec2 gradient0=k0+bendK*(.72*cos(bendPhase));
 vec3 phase=vec3(dot(q,k0)+t*.75+.72*sin(bendPhase),
                 dot(q,k1)-t*1.05,dot(q,k2)+t*1.40);
 vec3 bandWeight=1.0-smoothstep(vec3(.5),vec3(2.0),vec3(
  dot(footprint,abs(k0)),dot(footprint,abs(k1)),dot(footprint,abs(k2))));
 vec3 amplitude=vec3(.52,.31,.17)*bandWeight;
 vec3 slope=.5*amplitude*cos(phase);
 vec2 gradient=gradient0*slope.x+k1*slope.y+k2*slope.z;
 return vec3(.5+.5*dot(amplitude,sin(phase)),gradient);
}
]]
-- CPU reference for gradient, wrapping, amplitude and distance-filter tests.
function M.sample(x,z,t,sx,sz)
 local k={{.105,.033},{-.049,.119},{.174,.153}}
 local bp=x*.017-z*.013-t*.10
 local phase={x*k[1][1]+z*k[1][2]+t*.75+.72*math.sin(bp),
  x*k[2][1]+z*k[2][2]-t*1.05,x*k[3][1]+z*k[3][2]+t*1.40}
 local gradient={{k[1][1]+.017*.72*math.cos(bp),k[1][2]-.013*.72*math.cos(bp)},k[2],k[3]}
 local weights={.52,.31,.17};local height,dx,dz=.5,0,0
 for i=1,3 do
  local span=math.abs(sx or 0)*math.abs(k[i][1])+math.abs(sz or 0)*math.abs(k[i][2])
  local f=math.max(0,math.min(1,(span-.5)/1.5));f=1-f*f*(3-2*f)
  local a=.5*weights[i]*f
  height=height+a*math.sin(phase[i]);local slope=a*math.cos(phase[i])
  dx=dx+slope*gradient[i][1];dz=dz+slope*gradient[i][2]
 end
 return height,dx,dz
end
return M
