-- Viridian/Pattern Bush's overlapping crowns each denote a complete tree.
-- Only looking for exposed trunk 676 drops nearly every tree inside a grove.
local M={}
function M.prepare(cells)
 local count=0
 for _,c in pairs(cells)do
  if c.shape.kind=='tree' and c.shape.spacing==3 and not c.boundary then
   local root=c.mid==649 or c.mid==665
   if c.mid==676 then
    local crown=cells[c.cx..':'..(c.cy-3)]
    root=not(crown and crown.pair==c.pair and (crown.mid==649 or crown.mid==665))
   end
   local s={};for k,v in pairs(c.shape)do s[k]=v end
   s.root=root;s.anchorZ=(c.mid==649 or c.mid==665)and 56 or 8;c.shape=s
   if root then count=count+1 end
  end
 end
 return count
end
return M
