-- Share unchanged facade/glow textures between the bounded active, pending
-- and destination scenes. No idle GPU cache: the last scene releases them.
local V=...
local Civic=V.require('Gen3Civic')
local canonical=V.require('NativeGeometryCache').canonical
local M={}
local entries={}
local function key(g)
 local ts=g.ts
 return canonical({g.kind,g.width,g.depth,g.rows,g.custom,g.northRows,g.launchDisplay,
  Civic.profile(g),ts.cols,ts.rows,ts.midToSlot})
end
function M.acquire(g)
 local ok,id=pcall(key,g)
 local ts=g.ts
 if ok then
  for _,r in ipairs(entries)do
   if r.key==id and r.imageSource==ts.imageData and r.overSource==ts.overImageData then
    r.refs=r.refs+1;return r
   end
  end
 end
 local image,glow,read=Civic.material(g)
 local r={image=image,glow=glow,read=read,refs=1}
 if ok then
  r.key=id;r.imageSource=ts.imageData;r.overSource=ts.overImageData
  entries[#entries+1]=r
 end
 return r
end
function M.release(r)
 if not r or r.refs<=0 then return end
 r.refs=r.refs-1
 if r.refs>0 then return end
 for i,v in ipairs(entries)do if v==r then table.remove(entries,i);break end end
 if r.image then r.image:release()end
 if r.glow then r.glow:release()end
 r.image,r.glow,r.read,r.imageSource,r.overSource=nil,nil,nil,nil,nil
end
-- Existing leases remain valid until their scene is retired. New scenes
-- must rebuild after explicit in-place source/extension edits.
function M.invalidate()entries={}end
return M
