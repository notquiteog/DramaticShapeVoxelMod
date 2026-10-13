-- Fingerprint immutable native layouts plus sparse gameplay edits. Keep the
-- world context separate from provider readiness: loading a neighbor atlas
-- must not discard an in-flight scene or force another synchronous cold build.
local M={}
function M.keys(regions,x0,z0,x1,z1,tiles,cam)
 if cam and cam.replay then return nil end
 local parts,providers={},{}
 for _,r in ipairs(regions)do
  local l=r.def.midLayout
  if not(l and type(l.cells)=='table' and type(l.overrides)=='table')then return nil end
  local ts=tiles[l.pair]
  parts[#parts+1]=table.concat({tostring(l),tostring(l.cells),l.pair,r.x,r.y,r.w,r.h},':')
  providers[#providers+1]=table.concat({l.pair,tostring(ts),tostring(ts and ts.imageData),tostring(ts and ts.overImageData)},':')
  parts[#parts+1]=table.concat(l.borderMids or {},',')
  local keys={};for k in pairs(l.overrides)do keys[#keys+1]=k end;table.sort(keys)
  for _,k in ipairs(keys)do local c=l.overrides[k];parts[#parts+1]=table.concat({k,c.mid or 0,c.coll or 255,c.elev or 0},',')end
 end
 if cam and cam.battle then parts[#parts+1]=table.concat({'battle',cam.center[1],cam.center[2],cam.yaw},':')end
 local context=table.concat(parts,';')
 return table.concat({x0,z0,x1,z1,context,table.concat(providers,';')},';'),context
end
function M.key(...)return (M.keys(...))end
return M
