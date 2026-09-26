-- One complete illustrated foliage card per tree. The physical trunk and
-- ground shadow are separate; there are no caps, cheeks or stacked crowns.
local V=...
local M={}
local bushModel
function M.appendBush(v,indices,q,x,y,z)
  local Hull=V.require('VoxelHull')
  if not bushModel then
    local file=love.filesystem.newFileData(assert(V.mod:read('assets/crystal/depth-crowns-v2.png')),'depth-crowns-v2.png')
    local data=love.image.newImageData(file);file:release()
    V.require('TreeIllustrations').isolate(data)
    local w,h=data:getDimensions()
    bushModel=Hull.build(16,16,function(px,py)
      local u,v=.51+(px+.5)/16*.48,.686+(py+.5)/16*.26
      local r,g,b,a=data:getPixel(math.floor(u*w),math.floor(v*h))
      return r,g,b,a,u,v
    end,1,0,nil,'bush')
    data:release()
  end
  return Hull.append(bushModel,v,indices,q,x,y,z)
end
function M.append(v,indices,q,x,y,z,lift,seed,family,flatTrunk)
  local shrub=lift==3
  local sapling=lift==4
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
      (col+.01+(dx+1)*.49)*.5,bottom+(top-bottom)*t,.96,x,z,flatTrunk and y+.001 or y+base}
  end
  for _,i in ipairs({1,2,3,1,3,4}) do indices[#indices+1]=k+i end
  return q+1
end
return M
