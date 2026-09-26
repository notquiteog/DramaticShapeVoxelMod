-- Closed native-art rock volumes shared by Crystal cave and ice families.
local V=...
local M={}
function M.build(t,data,pr,aw,ah)
 local w,h=#t.tiles[1]*8,#t.tiles*8
 local function key(r,g,b)return math.floor(r*255+.5)*65536+math.floor(g*255+.5)*256+math.floor(b*255+.5)end
 local function pixel(tile,x,y)
  local sx,sy=tile%pr*8+x,math.floor(tile/pr)*8+y
  return sx,sy,data:getPixel(sx,sy)
 end
 local votes,bg,best={},nil,0
 for _,row in ipairs(t.groundTiles)do for _,tile in ipairs(row)do for y=0,7 do for x=0,7 do
  local _,_,r,g,b=pixel(tile,x,y);local k=key(r,g,b);votes[k]=(votes[k]or 0)+1
  if votes[k]>best then bg,best=k,votes[k]end
 end end end end
 local function at(x,y)
  return pixel(t.tiles[math.floor(y/8)+1][math.floor(x/8)+1],x%8,y%8)
 end
 local mask=V.require('SceneryMask').mask(w,function(x,y)
  local _,_,r,g,b,a=at(x,y);return a==0 or key(r,g,b)==bg
 end,h)
 local bottom=h
 for y=0,h-1 do for x=0,w-1 do if mask[y*w+x] then bottom=math.min(bottom,h-y-1)end end end
 local faces=V.require('VoxelHull').build(w,h,function(x,y)
  local sx,sy,r,g,b,a=at(x,y)
  return r,g,b,mask[y*w+x]and a or 0,(sx+.5)/aw,(sy+.5)/ah
 end,1,bottom)
 for _,q in ipairs(faces)do
  local uv={q.u,q.v};q.uv={uv,uv,uv,uv}
  for i=1,4 do q[i][1]=q[i][1]+w/2;q[i][3]=q[i][3]+h/2 end
 end
 return faces
end
return M
