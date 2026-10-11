-- Opt-in shared city turf, clipped to native turf pixels. No terrain/collision edits.
local V=...
local M={}
local cities={FR_LAVENDER_TOWN='LAVENDER_TOWN',FR_FUCHSIA_CITY='FUCHSIA_CITY'}
function M.geometry(cells,id)
 if not cities[id]or not V.require('CommunityVisuals').customCityGround()then return end
 local vs,ix={},{};local masks={};local count=0
 for _,c in pairs(cells)do
  if c.collision==0 and c.shape.kind=='flat'and not c.stairs and not c.prop and not c.civic and not c.boundary then
   local key=tostring(c.ts)..':'..c.mid;local mask=masks[key]
   if not mask then mask=V.require('NativeLegendaryRoads').mask(c.ts,c.mid,1)or{};masks[key]=mask end
   if #mask>0 then
    count=count+1
    for _,r in ipairs(mask)do
     local x,z=c.cx*16,c.cy*16;local n=#vs;local y=(c.base or 0)+.018
     for _,p in ipairs{{r[1],r[4]},{r[3],r[4]},{r[3],r[2]},{r[1],r[2]}}do
      vs[#vs+1]={x+p[1],y,z+p[2],((x%128)+p[1])/128,((z%128)+p[2])/128,1}
     end
     for _,i in ipairs{1,2,3,1,3,4}do ix[#ix+1]=n+i end
    end
   end
  end
 end
 if count==0 then return end
 return vs,ix,count
end
function M.build(cells,id)
 local vs,ix,count=M.geometry(cells,id);if not vs then return end
 local g=love.graphics;local previous=g.getCanvas();local canvas=g.newCanvas(128,128,{dpiscale=1});g.push('all')
 local ok,err=pcall(function()
  g.setCanvas(canvas);g.origin();g.setShader();g.setScissor();g.setDepthMode();g.setStencilTest()
  g.setBlendMode('replace','premultiplied');g.clear(0,0,0,0)
  V.require('LawnMaterial').draw(g,0,0,128,cities[id])
 end)
 g.setCanvas(previous);g.pop();if not ok then canvas:release();error(err,0)end
 canvas:setFilter('nearest','nearest')
 return{mesh=V.require('Voxel3D').newMesh(vs,ix),image=canvas,count=count}
end
return M
