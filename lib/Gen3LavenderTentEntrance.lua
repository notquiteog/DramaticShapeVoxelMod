-- The genuine HGSS Name Rater curtains are already open in the source model.
-- Native FR/LG warp and animation timing continue; no wooden panel is invented.
local M={}
function M.ownsDoor(g,x,y)
 return g and g.importedLavenderNameRater~=nil and x==g.cx+2 and y==g.cy+3 or false
end
function M.draw(g)return g and g.importedLavenderNameRater~=nil or false end
function M.release()end -- Static source geometry follows normal Scene ownership.
return M
