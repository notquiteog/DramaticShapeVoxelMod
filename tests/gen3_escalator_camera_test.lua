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
local Scene=assert(loadfile('lib/Gen3Scene.lua'))({require=function(n)return n=='Gen3Tilesets'and P or{}end})
local g={session={},data={maps={}}}
assert(not Scene.nativeRequired(g))
active,warp=true,true;assert(not Scene.nativeRequired(g),'escalator inter-phase flicker')
moving=true;assert(not Scene.nativeRequired(g))
warp,moving=false,false;assert(Scene.nativeRequired(g),'unrelated special animation changed')
active=false;fx._anims={1};assert(Scene.nativeRequired(g),'unmodeled effect lost native renderer')
fx._anims={{kind='dust'}};assert(not Scene.nativeRequired(g),'ledge landing dust stole camera')
fx._anims={{kind='dust'},{kind='flash'}};assert(Scene.nativeRequired(g),'unsupported overlapping effect bypassed')
fx._anims={};battle=true;assert(Scene.nativeRequired(g),'battle transition lost native renderer')
print('PASS escalator phase gaps preserve camera; unrelated native effects unchanged')
