-- One complete illustrated foliage card per tree. The physical trunk and
-- ground shadow are separate; there are no caps, cheeks or stacked crowns.
local M={}
function M.append(v,indices,q,x,y,z,lift,seed,family)
  local shrub=lift==3
  local sapling=lift<=4 and not shrub
  local phase=(math.sin(seed*12.9898)*43758.5453)%1
  local height=(lift==20 and 42 or 34)*(.92+phase*.14)
  local spread=lift==20 and 1.18 or 1
  local base,wide,tall=height*.24,12*spread,height*.78
  if family=='conifer' then wide=11*spread end
  if sapling then family='broadleaf';base,wide,tall=2.5,5.5,13*(.92+phase*.14) end
  if shrub then family='shrub';base,wide,tall=.2,7.3,7.6*(.94+phase*.12) end
  local col=(family=='conifer' or family=='shrub') and 1 or 0
  local row=(family=='spreading' or family=='shrub') and 1 or 0
  local bottom,top=(row+.99)*.5,(row+.01)*.5
  if shrub then bottom,top=.946,.686 end
  local k=#v
  for _,p in ipairs({{-1,0},{1,0},{1,1},{-1,1}}) do
    local dx,t=p[1],p[2]
    -- The last three fields are the card's bottom anchor X/Z/Y. A positive
    -- anchor height enables billboarding; ordinary solid meshes use zero.
    v[#v+1]={x+dx*wide,y+base+t*tall,z,
      (col+.01+(dx+1)*.49)*.5,bottom+(top-bottom)*t,.96,x,z,y+base}
  end
  for _,i in ipairs({1,2,3,1,3,4}) do indices[#indices+1]=k+i end
  return q+1
end
return M
