-- Closed, thin roof projections. The edge's pitch is retained; underside,
-- fascia and end grain stay visible from first person and rear viewpoints.
local M={}
function M.edge(a,b,dx,dz,uv,emit,thickness)
 local t=thickness or .65
 local A={a[1],a[2]+.04,a[3]};local B={b[1],b[2]+.04,b[3]}
 local C={b[1]+dx,b[2]+.04,b[3]+dz};local D={a[1]+dx,a[2]+.04,a[3]+dz}
 local E={A[1],A[2]-t,A[3]};local F={B[1],B[2]-t,B[3]}
 local G={C[1],C[2]-t,C[3]};local H={D[1],D[2]-t,D[3]}
 local center={(A[1]+B[1]+C[1]+D[1])/4,(A[2]+B[2]+C[2]+D[2])/4-t/2,(A[3]+B[3]+C[3]+D[3])/4}
 local raw=emit
 emit=function(p,tex,shade)
  local u,v={p[2][1]-p[1][1],p[2][2]-p[1][2],p[2][3]-p[1][3]},
   {p[3][1]-p[1][1],p[3][2]-p[1][2],p[3][3]-p[1][3]}
  local nx,ny,nz=u[2]*v[3]-u[3]*v[2],u[3]*v[1]-u[1]*v[3],u[1]*v[2]-u[2]*v[1]
  if nx*(p[1][1]-center[1])+ny*(p[1][2]-center[2])+nz*(p[1][3]-center[3])<0 then
   p={p[4],p[3],p[2],p[1]};tex={tex[4],tex[3],tex[2],tex[1]}
  end
  raw(p,tex,shade)
 end
 emit({A,B,C,D},uv,1);emit({H,G,F,E},uv,.52)
 emit({D,C,G,H},uv,.78)
 emit({A,D,H,E},uv,.7);emit({C,B,F,G},uv,.7)
end
return M
