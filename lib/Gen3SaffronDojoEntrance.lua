-- Source Dojo has an open recessed entrance. Engine timing/warps stay native;
-- an unrelated closed native door card must not cover the source portal.
local M={}
function M.ownsDoor(g,x,y)return g and g.importedSaffronDojo~=nil and x==g.cx+3 and y==g.cy+4 or false end
function M.draw(g)return g and g.importedSaffronDojo~=nil or false end
function M.release()end
return M
