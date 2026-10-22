-- Shared tree presentation choices. Defaults only apply to absent/invalid
-- preferences; explicitly saved card artwork and flat trunks remain intact.
local V=...
local M={}
M.setting=V.require('ModSetting').new('hdTreeTrunks','TREE TRUNKS',
 {'flat','solid'},{'FLAT 2.5D','MODELED'},2)
M.art=V.require('ModSetting').new('treeArtwork','TREE ART',
 {'original','illustrated','modeled'},{'ORIGINAL CARD','ILLUSTRATED CARD','3D MODELS'},3)
M.props=V.require('ModSetting').new('sceneryProps','ROCKS & PLANTS',
 {'modeled','cards'},{'3D MODELS','2.5D SPRITES'},1)
M.surfaces=V.require('ModSetting').new('surfaceArtwork','SCENERY TEXTURES',
 {'original','detailed'},{'ORIGINAL GAME','DETAILED'},1)
local okStyles,Styles=pcall(V.require,'VisualStyles')
local originalPropsGet=M.props.get
function M.props:get()
 if okStyles then return Styles.hd2d('props')and'cards'or'modeled'end
 return originalPropsGet(self)
end
function M.original()return okStyles or M.art:get()~='illustrated'end
function M.voxel()return okStyles and not Styles.hd2d('trees')or not okStyles and M.art:get()=='modeled'end
function M.flat()return okStyles and Styles.hd2d('trees')or not okStyles and M.setting:get()=='flat'end
function M.changed(key)
 if key~=M.setting.key and key~=M.art.key and key~=M.surfaces.key and key~=M.props.key and key~="communityTreeDetail" and key~="communityGrass" and key~="communityForest" and key~="communitySafari" and key~="communityRoads" and key~="communityWalls" and key~="communityMasonry" and key~="communityPillars" and key~="communityRocket" and key~="communityElevator" and key~="communityCutTrees" and key~="communitySigns" and key~="communityTowerWall" and key~="communityTower" and key~="communityTunnels" and key~="communityCityGround" and key~="communityTrees" and key~="communityCasino" and key~="communityCourtyards" and key~="communityPrizeRoom" and key~="vermilionBuildings" then return end
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
wrapSetting(M.setting);wrapSetting(M.art);wrapSetting(M.surfaces);wrapSetting(M.props)
return M
