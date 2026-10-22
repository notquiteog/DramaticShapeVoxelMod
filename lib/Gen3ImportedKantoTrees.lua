-- Regional source selection only. ImportedTrees retains native ownership,
-- full blocked/level bounds, settings and successful-upload suppression.
local M={model='oras_evergreen_tree'}
local pairs={pallet_outdoor=true,pewter_outdoor=true,viridian_outdoor=true,sevii_outdoor=true}
for _,suffix in ipairs{'082d4af4','082d4b0c','082d4b24','082d4b3c','082d4b54','082d4b84','082d4b9c','082d5004','082d5064','082d507c'}do
 pairs['general__rom_'..suffix]=true
end
local mids={[0x0a]=true,[0x0b]=true,[0x0c]=true,[0x0e]=true,[0x0f]=true,[0x13]=true}
for _,start in ipairs{0x14,0x1c,0x24}do for i=0,3 do mids[start+i]=true end end
function M.select(c,options)
 local s=c and c.shape;local def=c and(c.def or c.region and c.region.def)
 local id=def and def.id or c and c.region and c.region.mapId or options and options.mapId or ''
 if not(id:match('^FR_')or id:match('^SEVII_')or options and options.region=='kanto')then return end
 if not(s and s.kind=='tree'and s.root and c.primary=='general'and pairs[c.pair]and mids[c.mid])then return end
 -- Source art is the common pointed three-tier General drawing, not a
 -- botanical inference from TreeFootprints' default "conifer" label.
 if s.importedTreeModel or s.treeRows or s.spacing or s.treePalette or s.treeFamily and s.treeFamily~='conifer'then return end
 local b=s.treeBounds
 if not(b and #b==4 and math.abs(b[3]-b[1]-32)<.001 and math.abs(b[4]-b[2]-32)<.001)then return end
 -- Cropped one-cell, narrow and shallow owners retain native solid models;
 -- a uniform mature source fit would leave much of their body empty.
 return M.model
end
return M
