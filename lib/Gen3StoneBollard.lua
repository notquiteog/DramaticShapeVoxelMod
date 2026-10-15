-- Route 23's pale stone traffic posts: a wide plinth, bevelled shoulder and
-- pale inset crown. One continuous closed octagonal shell per solid cell.
local M={}
function M.append(p,emit,sample)
 local x,z=p.cx*16+8,p.cy*16+8
 local dark,stone,rim,cap=sample(2,12),sample(5,11),sample(3,8),sample(7,3)
 local oct={{-1,-.55},{-.55,-1},{.55,-1},{1,-.55},{1,.55},{.55,1},{-.55,1},{-1,.55}}
 local profile={{0,6.2,dark},{1.3,6.2,dark},{2,5.8,stone},{5.8,5.8,stone},
  {6.6,7,rim},{7.5,7,rim},{9.2,5.3,stone},{9.2,4.5,cap}}
 for j=2,#profile do local a,b=profile[j-1],profile[j]
  for i,u in ipairs(oct)do local v=oct[i%8+1]
   emit({{x+u[1]*b[2],b[1],z+u[2]*b[2]},{x+v[1]*b[2],b[1],z+v[2]*b[2]},
    {x+v[1]*a[2],a[1],z+v[2]*a[2]},{x+u[1]*a[2],a[1],z+u[2]*a[2]}},b[3],.82+i*.02)
  end
 end
 for i,u in ipairs(oct)do local v=oct[i%8+1]
  emit({{x,9.2,z},{x+u[1]*4.5,9.2,z+u[2]*4.5},{x+v[1]*4.5,9.2,z+v[2]*4.5},{x,9.2,z}},cap,1)
  emit({{x,0,z},{x+v[1]*6.2,0,z+v[2]*6.2},{x+u[1]*6.2,0,z+u[2]*6.2},{x,0,z}},dark,.65)
 end
end
return M
