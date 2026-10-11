-- Optional shared Prize Room paneling, bounded by native solid wall columns.
local V=...
local M={}
function M.geometry(cells,id)
 if id~='FR_CELADON_CITY_GAME_CORNER_PRIZE_ROOM' or V.require('CommunityVisuals').prizeRoom:get()~='n64memory'then return end
 local out,indices,claims={}, {}, {};local count=0
 local nativeTop={0x285,0x286,0x282,0x283,0x284,0x285,0x286}
 local nativeBottom={0x28d,0x28e,0x28a,0x28b,0x28c,0x28d,0x28e}
 local source,sourceIndices=V.require('PrizeRoom').geometry({},'north')
 for key,c in pairs(cells)do
  local col=c.column
  if not col and c.cy==1 and nativeBottom[c.cx]==c.mid then
   local top=cells[c.cx..':0'];local floor=cells[c.cx..':2']
   if top and top.mid==nativeTop[c.cx] and floor and floor.collision==0 then
    col={indoor=true,first=0,last=1,back=28,front=32,height=32}
   end
  end
  local solid=col and col.indoor and not col.stageHidden and c.cy==col.last
  if solid then for y=col.first,col.last do local n=cells[c.cx..':'..y];if not n or n.collision~=7 or n.prop then solid=false;break end end end
  if solid then
   -- Each column gets one 32px authored fabric/brass panel. The original kit's
   -- depth lies entirely within its blocked source column, never the aisle.
   local left=(c.cx%5)*32;local first=#out
   local remap={}
   for k=1,#sourceIndices,3 do
    local a,b,d=source[sourceIndices[k]],source[sourceIndices[k+1]],source[sourceIndices[k+2]]
    local lo,hi=math.min(a[1],b[1],d[1]),math.max(a[1],b[1],d[1])
    if hi>=left and lo<=left+32 then
     for j=k,k+2 do local old=sourceIndices[j];local index=remap[old]
      if not index then local p=source[old];index=#out+1;remap[old]=index
       out[index]={c.cx*16+math.max(0,math.min(32,p[1]-left))*.5,(c.base or 0)+p[2]*col.height/64,
        col.back+math.max(0,math.min(1,(p[3]+2)/6))*(col.front-col.back),p[4],p[5],p[6]}
      end;indices[#indices+1]=index
     end
    end
   end
   if #out>first then count=count+1;for y=col.first,col.last do claims[c.cx..':'..y]=true end end
  end
 end
 if #out>0 then return out,indices,claims,count end
end
function M.build(cells,id)
 local vs,ix,claims,count=M.geometry(cells,id);if not vs then return end
 local d=love.image.newImageData(16,1)
 for i,c in ipairs(V.require('PrizeRoom').palette())do d:setPixel(i-1,0,c[1],c[2],c[3],1)end
 local image=love.graphics.newImage(d);image:setFilter('nearest','nearest');d:release()
 return{mesh=V.require('Voxel3D').newMesh(vs,ix),image=image,claims=claims,count=count}
end
return M
