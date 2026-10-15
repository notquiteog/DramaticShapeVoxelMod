-- Fingerprint immutable native layouts plus sparse gameplay edits. Keep the
-- world context separate from provider readiness: loading a neighbor atlas
-- must not discard an in-flight scene or force another synchronous cold build.
local function fingerprint(regions,x0,z0,x1,z1,tiles,cam)
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
-- One bounded snapshot per consumer, shared by request and completed build. Check sparse
-- gameplay edits by value on every call: table identity alone misses Cut and
-- script edits. Unchanged frames allocate no fingerprint strings/tables.
local function new()
local M={}
local snapshot,oldKey,oldContext,lastX0,lastZ0,lastX1,lastZ1,battleX,battleZ,battleYaw
local function matches(regions,tiles,cam)
 if not snapshot or #snapshot~=#regions then return false end
 local battle=cam and cam.battle
 if battleX~=(battle and cam.center[1] or nil) or battleZ~=(battle and cam.center[2] or nil)
  or battleYaw~=(battle and cam.yaw or nil) then return false end
 for i,r in ipairs(regions)do
  local a,l=snapshot[i],r.def.midLayout
  if not l or a.layout~=l or a.cells~=l.cells or a.pair~=l.pair
   or a.x~=r.x or a.y~=r.y or a.w~=r.w or a.h~=r.h then return false end
  local ts=tiles[l.pair]
  if a.provider~=ts or a.image~=(ts and ts.imageData) or a.over~=(ts and ts.overImageData)then return false end
  local border=l.borderMids or a.empty
  if #a.border~=#border then return false end
  for k,v in ipairs(border)do if a.border[k]~=v then return false end end
  if type(l.overrides)~='table' then return false end
  local count=0
  for k,v in pairs(l.overrides)do
   local old=a.edits[k];count=count+1
   if not old or old[1]~=(v.mid or 0) or old[2]~=(v.coll or 255) or old[3]~=(v.elev or 0)then return false end
  end
  if count~=a.count then return false end
 end
 return true
end
function M.keys(regions,x0,z0,x1,z1,tiles,cam)
 if cam and cam.replay then return nil end
 if x0==lastX0 and z0==lastZ0 and x1==lastX1 and z1==lastZ1 and matches(regions,tiles,cam)then
  return oldKey,oldContext
 end
 local key,context=fingerprint(regions,x0,z0,x1,z1,tiles,cam)
 if not key then snapshot=nil;return key,context end
 snapshot={}
 for i,r in ipairs(regions)do
  local l=r.def.midLayout;local ts=tiles[l.pair]
  local a={layout=l,cells=l.cells,pair=l.pair,x=r.x,y=r.y,w=r.w,h=r.h,
   provider=ts,image=ts and ts.imageData,over=ts and ts.overImageData,border={},empty={},edits={},count=0}
  for k,v in ipairs(l.borderMids or a.empty)do a.border[k]=v end
  for k,v in pairs(l.overrides)do a.edits[k]={v.mid or 0,v.coll or 255,v.elev or 0};a.count=a.count+1 end
  snapshot[i]=a
 end
 local battle=cam and cam.battle
 battleX,battleZ,battleYaw=battle and cam.center[1] or nil,battle and cam.center[2] or nil,battle and cam.yaw or nil
 oldKey,oldContext,lastX0,lastZ0,lastX1,lastZ1=key,context,x0,z0,x1,z1
 return key,context
end
function M.key(...)return (M.keys(...))end
return M
end
local M=new();M.new=new
return M
