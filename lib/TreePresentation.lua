-- Shared Crystal/FireRed presentation choice. Never changes tree collision.
local V=...
local M={}
M.setting=V.require('ModSetting').new('hdTreeTrunks','TREE TRUNKS',
 {'flat','solid'},{'FLAT 2.5D','MODELED'},1)
M.art=V.require('ModSetting').new('treeArtwork','TREE ART',
 {'original','illustrated','modeled'},{'ORIGINAL CARD','ILLUSTRATED CARD','ORIGINAL MODEL'},3)
M.surfaces=V.require('ModSetting').new('surfaceArtwork','SCENERY TEXTURES',
 {'original','detailed'},{'ORIGINAL GAME','DETAILED'},1)
function M.original()return M.art:get()~='illustrated' end
function M.voxel()return M.art:get()=='modeled' end
function M.flat()return M.setting:get()=='flat' end
function M.changed(key)
 if key~=M.setting.key and key~=M.art.key and key~=M.surfaces.key and key~="communityTreeDetail" then return end
 if V.require('Generation').isGen3() then V.require('Gen3Scene').invalidate()
 else V.require('CommunityVisuals').invalidate() end
end
local function wrapSetting(setting)
local row=setting.row
function setting:row()
 local r=row(self);local step=r.step
 r.step=function(game,dir)local result=step(game,dir);M.changed(self.key);return result end
 return r
end
end
wrapSetting(M.setting);wrapSetting(M.art);wrapSetting(M.surfaces)
return M
