-- Stable menu names/order across native engines. Keys, not module instances,
-- let each adapter retain its own live settings and persistence owner.
local M={legendaryRoot={id='legendary_visuals',label='LEGENDARY VISUALS'}}
local function row(id,label,keys)
 local r={id=id,label=label,keys={}};for k in keys:gmatch('%S+')do r.keys[#r.keys+1]=k end;return r
end
M.legendary={
 row('legendary_game_corner','GAME CORNER','communityCasino communityPrizeRoom'),
 row('legendary_lavender','LAVENDER & CITIES','communityCityGround'),
 row('legendary_interiors','INTERIORS','communityTunnels communityRocket communityElevator'),
 row('legendary_tower','POKEMON TOWER','communityTower communityTowerWall towerDetails towerFog towerFogThickness towerFogSpeed'),
 row('legendary_caves','CAVES','communityCaves communityCaveDetails communityCaveSound'),
 row('legendary_pillars','PILLARS & MASONRY','communityPillars communityMasonry'),
 row('legendary_signs','SIGNS & PROPS','communitySigns communityCutTrees'),
 row('legendary_nature','GRASS & TREES','communityGrass communityTrees communityTreeDetail communityForest communitySafari atmos communityKantoLife treeArtwork hdTreeTrunks sceneryProps surfaceArtwork'),
 row('legendary_structures','ROADS & STRUCTURES','vermilionBuildings communityRoads communityWalls communityCourtyards'),
 row('legendary_sky','SKY & BACKGROUND','communitySky'),
 row('legendary_battle','BATTLE PRESENTATION','standingTrainer'),
 row('ember_legacy','EMBER LEGACY','legendaryPokeballs emberLegacyAudio emberLegacyVolume pokeballSize pokeballSuction pokeballCapturePreset pokeballBeam pokeballStreamers pokeballPokemonGlow pokeballSuctionParticles pokeballCaptureSpeed pokeballOpenTime pokeballFxScale'),
}
M.ordinary={
 row('world','WORLD','fireredCamera grid curve worldFill water daytime invertY weather tiltshift'),
 row('performance','PERFORMANCE','renderDistance ramPrecacheMb shadowQuality aa spatialUpscale'),
 row('pokemon','POKEMON ART','interfaceSprites interfaceScaling battleArt trainerArtSet playerArtSet playerAnimatedSet frontAnimatedSet backAnimatedSet duplicateFix playerView frontFlip spritePack full_body_backs crystalFront crystalTrainers crystalPlayerSprite crystalBattlePic crystalAnimations'),
 row('battle','BATTLE SCENE','battles hudScale backPlacement spriteLight battleUi hudColor arenaFill stadiumCircle backdropOffset bossBg textboxFill modernBattleUI'),
}
M.all={};M.byKey={}
for _,list in ipairs({M.legendary,M.ordinary})do for _,r in ipairs(list)do
 M.all[#M.all+1]=r;for _,key in ipairs(r.keys)do assert(not M.byKey[key],key);M.byKey[key]=r end
end end
function M.native(rows,openPage,prefix)
 local buckets,other,master={},{},{}
 for _,r in ipairs(rows)do
  local key=r.id and r.id:sub(#prefix+2);local category=M.byKey[key]
  if key=='legendaryVisualsMode'then master[#master+1]=r
  elseif category then buckets[category]=buckets[category]or{};table.insert(buckets[category],r)
  else other[#other+1]=r end
 end
 local function opener(c,members)
  return {id=prefix..':group:'..c.id,label=c.label,group=true,members=members,
   value=function()return 'OPEN'end,activate=function()openPage(c.label,members)end}
 end
 for _,c in ipairs(M.legendary)do if buckets[c]then master[#master+1]=opener(c,buckets[c])end end
 local out={};if #master>0 then out[#out+1]=opener(M.legendaryRoot,master)end
 for _,c in ipairs(M.ordinary)do if buckets[c]then out[#out+1]=opener(c,buckets[c])end end
 for _,r in ipairs(other)do out[#out+1]=r end
 return out
end
return M
