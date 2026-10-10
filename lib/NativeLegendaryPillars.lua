-- Native solid stone-fence cells may opt into the shared Legendary pillar kit.
-- Wood/composite foliage, walkable art and battle-cleared scenery stay native.
local V=...
local M={}
function M.owners(cells,id)
 if not tostring(id):match('^FR_') or not V.require('CommunityVisuals').customPillars()then return end
 local owners,claims={},{}
 for key,c in pairs(cells)do
  local s=c.shape
  if s and s.kind=='fence'and s.wood==false and not s.material
    and c.collision and c.collision~=0 and not c.prop and not c.stageHidden then
   owners[c.cx..'|'..c.cy]=c.base or 0;claims[key]=true
  end
 end
 if not next(owners)then return end
 return owners,claims
end
function M.build(cells,id)
 local owners,claims=M.owners(cells,id);if not owners then return end
 local record=V.require('GranitePillars').native(owners,id)
 if record then record.claims=claims end
 return record
end
function M.draw(record,draw)return V.require('GranitePillars').drawNative(record,draw)end
return M
