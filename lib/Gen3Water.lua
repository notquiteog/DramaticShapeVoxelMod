-- One physical sheet for native water and reviewed wet-rock underlays.
-- Native permissions/elevations and source drawings remain authoritative.
local M={LEVEL=.05}
local palettes=setmetatable({},{__mode='k'})
-- Derive body color from a real native water drawing once per live atlas.
-- Only blue water pixels contribute; banks, white foam and transparent art
-- keep their original material. Failed/late providers are retried.
function M.tint(ts,mid)
 local source=ts and ts.imageData
 local slot=ts and ts.midToSlot and ts.midToSlot[mid]
 if not(source and slot and ts.cols)then return end
 local old=palettes[ts]
 if not old or old.source~=source then old={source=source};palettes[ts]=old end
 local entry=old[mid]
 if entry then
  local same=true
  -- Native palette edits may repaint ImageData in place. Recheck one source
  -- pixel per native color, rather than rescanning the whole tile on
  -- every frame or retaining a stale palette until the provider is replaced.
  for _,p in ipairs(entry.probes)do
   local rr,gg,bb,aa=source:getPixel(p[1],p[2])
   if rr~=p[3]or gg~=p[4]or bb~=p[5]or aa~=p[6]then same=false;break end
  end
  if same then return entry.tint or nil end
 end
 local r,g,b,n=0,0,0,0
 local probes,colors={},{}
 local sx,sy=slot%ts.cols*16,math.floor(slot/ts.cols)*16
 for y=0,15 do for x=0,15 do
  local rr,gg,bb,aa=source:getPixel(sx+x,sy+y)
  local key=rr..':'..gg..':'..bb..':'..aa
  if not colors[key]then colors[key]=true;probes[#probes+1]={sx+x,sy+y,rr,gg,bb,aa}end
  if aa>=.5 and bb>gg+.065 and bb>rr+.12 then
   r,g,b,n=r+rr,g+gg,b+bb,n+1
  end
 end end
 if n<16 then old[mid]={tint=false,probes=probes};return end
 local tint={r/n,g/n,b/n,.88};old[mid]={tint=tint,probes=probes};return tint
end
function M.note(batch,mid)
 batch.waterMids=batch.waterMids or{}
 batch.waterMids[mid]=(batch.waterMids[mid]or 0)+1
end
function M.dominant(mids)
 local chosen,count
 for mid,n in pairs(mids or{})do
  if not count or n>count or n==count and mid<chosen then chosen,count=mid,n end
 end
 return chosen
end
function M.complete(cells,members,fetch)
 local roots,seen={},{}
 for _,c in pairs(cells)do
  local m=c.primary=='general'and not c.boundary and members[c.mid]
  if m then
   local x,y=c.cx-m[2],c.cy-m[3];local k=x..':'..y
   if not seen[k]then seen[k]=true;roots[#roots+1]={x,y}end
  end
 end
 -- Load only the missing cells of a recognized 2x2 source drawing. The
 -- normal recipe still validates every metatile and native permission;
 -- a window edge cannot turn a known rock back into a painted water patch.
 for _,r in ipairs(roots)do for y=r[2],r[2]+1 do for x=r[1],r[1]+1 do
  if not cells[x..':'..y]then fetch(x,y)end
 end end end
end
local function wet(c)
 local s=c and c.shape
 return s and s.kind=='rock'and(s.seaRock or s.wetRock)
end
function M.underlay(c)
 if wet(c)then return c.shape.waterGround or c.shape.ground,c.shape.waterline or M.LEVEL end
end
function M.bind(cells)
 local count,seen=0,{}
 for _,c in pairs(cells)do if wet(c)then
  count=count+1
  local g=c.shape.seaRock or c
  if not seen[g]then
   seen[g]=true
   local root=g.root or c;local w=g.family and #g.family.rows[1]or 1;local h=g.family and #g.family.rows or 1
   local votes,best,chosen={},0,nil
   -- Use the immediate body's actual drawn level and source water, rather
   -- than a blocked cell's unrelated collision-layer number or land height.
   for y=root.cy-1,root.cy+h do for x=root.cx-1,root.cx+w do
    local n=cells[x..':'..y]
    if n and n.pair==c.pair and n.shape.kind=='water'then
     local level=(n.base or 0)+M.LEVEL
     local k=string.format('%.6f:%s',level,n.shape.ground or n.mid)
     votes[k]=(votes[k]or 0)+1
     if votes[k]>best then best=votes[k];chosen={level,n.shape.ground or n.mid}end
    end
   end end
   local level=chosen and chosen[1]or(root.base or 0)+M.LEVEL
   local ground=chosen and chosen[2]or root.shape.ground
   for y=root.cy,root.cy+h-1 do for x=root.cx,root.cx+w-1 do
    local n=cells[x..':'..y]
    if n and wet(n)and(n.shape.seaRock or n)==g then
     n.shape.waterline=level-(n.base or 0);n.shape.waterGround=ground
    end
   end end
  end
 end end
 return count
end
-- Water geometry and height groups do not change between scene rebuilds.
-- Keep these lists stable, but refresh the provider image after palette reloads.
function M.draws(parts)
 local out,byHeight,levels={},{},{}
 for _,p in ipairs(parts)do for _,water in ipairs(p.waters or{})do
  local d={water.mesh,nil,nil,water.height,mesh=water.mesh,pair=p.pair,waterMid=p.waterMid}
  out[#out+1]=d
  local group=byHeight[water.height]
  if not group then group={height=water.height};byHeight[water.height]=group;levels[#levels+1]=group end
  group[#group+1]=d
 end end
 table.sort(levels,function(a,b)return a.height<b.height end)
 return out,levels
end
function M.sync(draws,providers)
 for _,d in ipairs(draws)do
  local ts=providers[d.pair];d[1],d[2]=ts and d.mesh or nil,ts and ts.image or nil
  d[5]=d.waterMid and M.tint(ts,d.waterMid)or nil
 end
 return draws
end
return M
