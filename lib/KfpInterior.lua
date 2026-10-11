-- Kanto First Person's ceiling/headroom/cutaway concepts, adapted to the
-- existing shared shell rather than drawing a second room over native models.
-- Source: vendor/kanto-first-person/payload_ceiling.lua (permitted import).
local V=...
local M={}
local Setting=V.require('ModSetting')
M.ceiling=Setting.new('fpceiling','FP CEILING',{true,false},{'ON','OFF'})
M.headroom=Setting.new('fpheadroom','HEADROOM',{0,48,64},{'NATIVE','AIRY','TALL'})
M.cutaway=Setting.new('fpcutaway','CUTAWAY',{true,false},{'ON','OFF'})
M.settings={M.ceiling,M.headroom,M.cutaway}
function M.height(native)
 -- KFP's 16/24px low ceilings would intersect our native furniture and cave
 -- elevation. Never shrink a reviewed room below its existing headroom.
 return math.max(native,tonumber(M.headroom:get())or 0)
end
function M.prepare(p)
 p.nativeHeight=p.nativeHeight or p.height
 local h=M.height(p.nativeHeight)
 if h==p.height then return end
 for _,mesh in pairs(p.meshes or {})do mesh:release()end
 p.meshes={};p.height=h
end
return M
