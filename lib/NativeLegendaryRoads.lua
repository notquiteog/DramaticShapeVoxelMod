-- Optional shared Lavender stonework clipped to the native path's actual pixels.
local V=...
local M={}
local mids={[0x162]=true,[0x163]=true,[0x164]=true,[0x172]=true,[0x173]=true,[0x174]=true,[0x281]=true,[0x282]=true,[0x283]=true}
local function color(r,g,b)return math.floor(r*255+.5)*65536+math.floor(g*255+.5)*256+math.floor(b*255+.5)end
local function pixel(ts,mid,x,y)
 local slot=ts.midToSlot[mid];if not slot or not ts.imageData then return end
 return ts.imageData:getPixel(slot%ts.cols*16+x,math.floor(slot/ts.cols)*16+y)
end
function M.mask(ts,mid)
 local palette={};if not ts.midToSlot[0x163]or not ts.imageData then return end
 for y=0,15 do for x=0,15 do palette[color(pixel(ts,0x163,x,y))]=true end end
 local rows,previous={},{}
 for y=0,15 do
  local runs={};local start
  for x=0,16 do
   local hit=x<16 and palette[color(pixel(ts,mid,x,y))]
   if hit and not start then start=x elseif not hit and start then runs[#runs+1]={start,y,x,y+1};start=nil end
  end
  local current={}
  for _,r in ipairs(runs)do
   local key=r[1]..':'..r[3];local prior=previous[key]
   if prior and prior[4]==y then prior[4]=y+1;current[key]=prior
   else rows[#rows+1]=r;current[key]=r end
  end
  previous=current
 end
 return rows
end
local function clip(poly,axis,edge,sign)
 local out={};local a=poly[#poly];if not a then return out end
 local da=(a[axis]-edge)*sign
 for _,b in ipairs(poly)do
  local db=(b[axis]-edge)*sign
  if (da<=0)~=(db<=0)then local t=da/(da-db);out[#out+1]={a[1]+(b[1]-a[1])*t,a[2]+(b[2]-a[2])*t,a[3]+(b[3]-a[3])*t}end
  if db<=0 then out[#out+1]=b end;a,da=b,db
 end
 return out
end
function M.geometry(cells,id)
 if id~='FR_LAVENDER_TOWN' or not V.require('CommunityVisuals').customRoads()then return end
 local G=V.require('RoadStoneGeometry');local vertices,indices={},{};local count=0
 local names={'moss','dark','shadow','body','light'};local slots={};for i,k in ipairs(names)do slots[k]=(i-.5)/#names end
 local masks={}
 for _,c in pairs(cells)do
  V.require('BuildBudget').tick()
  if mids[c.mid]and c.collision==0 and c.shape.kind=='flat'and not c.prop and not c.civic and not c.stairs then
   local key=tostring(c.ts)..':'..c.mid;local mask=masks[key]
   if not mask then mask=M.mask(c.ts,c.mid);masks[key]=mask end
   if mask and #mask>0 then
    count=count+1;local x,z=c.cx*16,c.cy*16
    local function emit(poly,swatch,tone)
     for _,r in ipairs(mask)do
      local p=clip(clip(clip(clip(poly,1,x+r[1],-1),1,x+r[3],1),3,z+r[2],-1),3,z+r[4],1)
      for j=2,#p-1 do
       local a,b,d=p[1],p[j],p[j+1]
       local ux,uy,uz=b[1]-a[1],b[2]-a[2],b[3]-a[3];local vx,vy,vz=d[1]-a[1],d[2]-a[2],d[3]-a[3]
       if (uy*vz-uz*vy)^2+(uz*vx-ux*vz)^2+(ux*vy-uy*vx)^2>1e-12 then
        for _,v in ipairs{a,b,d}do vertices[#vertices+1]={v[1],v[2],v[3],slots[swatch],.5,tone or 1};indices[#indices+1]=#vertices end
       end
      end
     end
    end
    for dz=0,8,8 do for dx=0,8,8 do G.build('LAVENDER_TOWN',x+dx,z+dz,(c.base or 0)+.025,emit,{})end end
   end
  end
 end
 if count==0 then return end
 return vertices,indices,count
end
function M.build(cells,id)
 local vertices,indices,count=M.geometry(cells,id);if not vertices then return end
 local palette=V.require('RoadStoneGeometry').palette('LAVENDER_TOWN');local d=love.image.newImageData(5,1)
 for i,k in ipairs{'moss','dark','shadow','body','light'}do d:setPixel(i-1,0,unpack(palette[k]))end
 local image=love.graphics.newImage(d);image:setFilter('nearest','nearest');d:release()
 return {mesh=V.require('Voxel3D').newMesh(vertices,indices),image=image,count=count}
end
return M
