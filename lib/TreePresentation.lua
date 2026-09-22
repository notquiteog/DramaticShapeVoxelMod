-- Shared Crystal/FireRed presentation choice. Never changes tree collision.
local V=...
local M={}
M.setting=V.require('ModSetting').new('hdTreeTrunks','TREE TRUNKS',
 {'flat','solid'},{'FLAT HD-2D','SOLID'},1)
function M.flat()return M.setting:get()=='flat' end
function M.changed(key)
 if key~=M.setting.key then return end
 if V.require('Generation').isGen3() then V.require('Gen3Scene').invalidate()
 else V.require('CommunityVisuals').invalidate() end
end
local row=M.setting.row
function M.setting:row()
 local r=row(self);local step=r.step
 r.step=function(game,dir)local result=step(game,dir);M.changed(self.key);return result end
 return r
end
return M
