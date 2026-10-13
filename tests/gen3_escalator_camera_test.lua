-- The native escalator toggles its tile movement between phases while the
-- warp remains active. Rendering must retain ownership across those gaps.
local function module(n,v)package.loaded['src.core.game3.'..n]=v or{}end
local active,moving,warp,battle=false,false,false,false
module('map',{currentDef=function()return{midLayout={pair='network'}}end})
for _,n in ipairs({'tileset_native','ow_sprites','player','objects','pokecenter_heal','doors'})do module(n)end
package.loaded['src.import.gba.versions']={TILESET_PAIRS={}}
package.loaded['src.ui.game3.shop_menu']={isShopCamera=function()return false end}
local fx={_anims={}};module('field_effects',fx)
module('special_field_anim',{isActive=function()return active end,isEscalatorMoving=function()return moving end})
module('warp',{isEscalatorActive=function()return warp end})
module('battle_transition',{isActive=function()return battle end})
local P={bind=function()end,resolve=function()return{}end,supports=function()return true end}
-- Only nativeRequired is exercised: GPU/model dependencies are not invoked.
-- Keep the effect classifiers real so newly supported effects are checked.
local deps={Gen3ScreenEffects=dofile('lib/Gen3ScreenEffects.lua'),Gen3Tilesets=P,Gen3GroundEffects=dofile('lib/Gen3GroundEffects.lua'),Gen3EmoteCards=dofile('lib/Gen3EmoteCards.lua'),SceneStream={new=function()return{}end}}
local Scene=assert(loadfile('lib/Gen3Scene.lua'))({require=function(n)return deps[n]or{}end})
local g={session={},data={maps={}}}
assert(not Scene.nativeRequired(g))
active,warp=true,true;assert(not Scene.nativeRequired(g),'escalator inter-phase flicker')
moving=true;assert(not Scene.nativeRequired(g))
warp,moving=false,false;assert(Scene.nativeRequired(g),'unrelated special animation changed')
active=false;fx._anims={1};assert(Scene.nativeRequired(g),'unmodeled effect lost native renderer')
fx._anims={{kind='dust'}};assert(not Scene.nativeRequired(g),'ledge landing dust stole camera')
fx._anims={{kind='dust'},{kind='flash_level'}};assert(Scene.nativeRequired(g),'unsupported overlapping effect bypassed')
fx._anims={{kind='emote'}};assert(not Scene.nativeRequired(g),'exclamation stole voxel camera')
fx._anims={{kind='exclamation'},{kind='dust'}};assert(not Scene.nativeRequired(g),'legacy emote plus dust stole camera')
fx._anims={{kind='emote'},{kind='flash_level'}};assert(Scene.nativeRequired(g),'unsupported effect no longer falls back')
for _,kind in ipairs({'splash','feet_water','hot_springs','camera_shake','cut_grass_scatter','deoxys_rock_move','deoxys_rock_destroy','bg_flash'})do fx._anims={{kind=kind}};assert(not Scene.nativeRequired(g),kind..' stole camera')end
fx._anims={{kind='flash'}};assert(not Scene.nativeRequired(g),'full-world flash stole camera')
fx._anims={{kind='sweet_scent'}};assert(not Scene.nativeRequired(g),'Sweet Scent stole camera')
fx._anims={};battle=true;assert(Scene.nativeRequired(g),'battle transition lost native renderer')
print('PASS escalator phase gaps preserve camera; unrelated native effects unchanged')
