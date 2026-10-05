-- Optional Gen1 forest geometry, fitted to each native tree drawing. The
-- default still uses native tree models/cards; no collision cells are edited.
local V=...
local M={}
local prototypes={}
local safari={FR_SAFARI_ZONE_CENTER=true,FR_SAFARI_ZONE_EAST=true,FR_SAFARI_ZONE_NORTH=true,FR_SAFARI_ZONE_WEST=true}
function M.card(card,c,mapId)
 local nativeForest=mapId=='FR_VIRIDIAN_FOREST'and c.shape and c.shape.spacing==3
  or mapId=='ILEX_FOREST'and card and card.w==32
 local Visuals=V.require('CommunityVisuals')
 local nativeSafari=safari[mapId]and c.shape
 local family=nativeForest and Visuals.customForest()and 'forest'
  or nativeSafari and Visuals.customSafari()and 'safari'
 if not(card and family and V.require('TreePresentation').voxel())then return card end
 local Trees=V.require('ForestTrees')
 local detail=V.require('CommunityVisuals').treeDetail:get()
 local variant=Trees.variant(c.cx,c.cy)
 local h=math.max(1,card.h-(card.bottom or 0))
 local key=table.concat({family,card.w,h,variant,detail},':')
 if prototypes[key]then return prototypes[key]end
 local source=family=='safari'and V.require('SafariLandscape').template('grove',variant)or Trees.template(variant,detail)
 local radius,top,foot=0,0,0
 for _,q in ipairs(source.quads)do for _,p in ipairs(q)do
  radius=math.max(radius,math.abs(p[1]),math.abs(p[3]));top=math.max(top,p[2]);foot=math.min(foot,p[2])
 end end
 local sx=(card.w/2)/math.max(1,radius)
 local sy=h/math.max(1,top-foot)
 local Materials=V.require('ReferenceMaterials')
 local proto={w=card.w,h=h,legendaryForest=family=='forest',legendarySafari=family=='safari'}
 function proto.appendModel(_,vertices,indices,count,x,y,z)
  for _,q in ipairs(source.quads)do
   V.require('BuildBudget').tick()
   local start=#vertices
   local shade=Materials.encode(q.referenceMaterial,q.shade or 1)
   for k,p in ipairs(q)do
    local uv=q.uv and q.uv[k]or {q.u or 0,q.v or 0}
    vertices[#vertices+1]={x+p[1]*sx,y+(p[2]-foot)*sy,z+p[3]*sx,
     uv[1],uv[2],type(shade)=='table'and shade[k]or shade}
   end
   for _,i in ipairs{1,2,3,1,3,4}do indices[#indices+1]=start+i end
   count=count+1
  end
  return count
 end
 prototypes[key]=proto;return proto
end
return M
