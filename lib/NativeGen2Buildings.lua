-- Native Gen2 counterpart of the optional shared Vermilion building kit.
local V=...
local M={}
function M.spec(map,g)
 if map.id~='VERMILION_CITY'or not V.require('CommunityVisuals').referenceBuildings()then return end
 local x0,z0,W,D=g.x*8,g.y*8,g.width*8,g.depth*8
 if x0%16~=0 or z0%16~=0 or W%16~=0 or D%16~=0 then return end
 local doors,warps={},{};local destination
 for _,w in ipairs(map.def.warps or{})do
  local x,z=w.x*16+8,w.y*16+8
  if x>x0 and x<x0+W and z>=z0 and z<z0+D then
   doors[#doors+1]={x=x,w=14};warps[w.x..':'..w.y]=true;destination=w.destMap or w.map
  end
 end
 if #doors==0 or #doors>2 or type(map.isWalkableCell)~='function'then return end
 local back=z0
 -- Entirely walkable roof-art rows are overhead projections, not a solid body.
 while back<z0+D-16 do
  local all=true
  for x=x0,x0+W-16,16 do if not map:isWalkableCell(x/16,back/16)then all=false;break end end
  if not all then break end;back=back+16
 end
 for z=back,z0+D-16,16 do for x=x0,x0+W-16,16 do
  if map:isWalkableCell(x/16,z/16)and not warps[x/16 ..':'.. z/16]then return end
 end end
 table.sort(doors,function(a,b)return a.x<b.x end)
 local style=tostring(destination):find('FAN_CLUB')and'club'or g.style=='kanto_flat_brick'and'townhouse'or'bluehouse'
 return{x0=x0+3,x1=x0+W-3,z0=back+3,z1=z0+D-4,style=style,doors=doors}, {x0,back,x0+W,z0+D}
end
function M.build(S,map)
 if not S.gen2 or not S.outdoor then return end
 local replacements={};local count=0
 for _,g in ipairs(S.exteriors or{})do
  local spec,bounds=M.spec(map,g)
  if spec and g.quadFirst and g.quadLast then
   local quads=V.require('ReferenceBuildings').model(spec)
   -- Shared material tags supply the palette; use an opaque native wall donor
   -- for alpha instead of indexing Gen1's atlas in a different generation.
   local ts=map.tileset;local per=ts.tilesPerRow or 16;local tile=g.wallTile
   local uv={(tile%per*8+3.5)/(ts.imageWidth or 128),(math.floor(tile/per)*8+3.5)/(ts.imageHeight or 128)}
   for _,q in ipairs(quads)do
    q.uv={uv,uv,uv,uv}
    for _,p in ipairs(q)do if p[2]<24 then
     p[1]=math.max(bounds[1],math.min(bounds[3],p[1]));p[3]=math.max(bounds[2],math.min(bounds[4],p[3]))
    end end
   end
   replacements[g.quadFirst]=quads;for i=g.quadFirst+1,g.quadLast do replacements[i]=false end;count=count+1
  end
 end
 if count>0 then
  local out={};for i,q in ipairs(S.objectQuads)do local replacement=replacements[i]
   if replacement==nil then out[#out+1]=q elseif replacement then for _,p in ipairs(replacement)do out[#out+1]=p end end
  end;S.objectQuads=out
 end
 M.lastCount=count;S.nativeReferenceBuildingCount=count
end
return M
