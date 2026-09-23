-- Native map identity -> existing optional Battle Art plates. No Gen1 map
-- facade, trainer state or imported assets are copied into the native engine.
local V=...
local UI=V.require('UiBackplates')
local Day=V.require('DayNight')
local Images=V.require('BackdropImage')
local Trainers=V.require('Gen3TrainerArt')
local config=V.data('gen6_battle_backgrounds')
local bosses=V.data('boss_battle_backgrounds')
local M={settings={UI.arenaFill,UI.backdropOffset,UI.bossBg,UI.spriteLight}}
local periods=setmetatable({},{__mode='k'})
function M.mapKey(id)
 if type(id)~='string'then return nil end
 id=id:gsub('^FR_',''):gsub('_CITY_GYM$','_GYM'):gsub('^POKEMON_LEAGUE_','')
 local special={CINNABAR_ISLAND_GYM='CINNABAR_GYM',SAFFRON_CITY_DOJO='FIGHTING_DOJO',INDIGO_PLATEAU_EXTERIOR='INDIGO_PLATEAU',ROUTE_21_NORTH='ROUTE_21',ROUTE_21_SOUTH='ROUTE_21'}
 return special[id] or id
end
local function period(st)
 if st and periods[st]then return periods[st]end
 local name,weight='day',-1
 for key,value in pairs(Day.mix(Day.time()))do if value>weight then name,weight=key,value end end
 name=({golden='dusk',violet='night'})[name] or name
 if st then periods[st]=name end
 return name
end
function M.files(mapId,def,st)
 local id=M.mapKey(mapId);local boss=bosses.rooms[id]
 local trainer=Trainers.key(st)
 local key=trainer and ('OPP_'..trainer:upper():gsub('-','_'))
 local tr=key and bosses.trainers[key]
 if not boss and tr then boss=tr.map==id and tr.file or tr[id]end
 if not boss and st and st.wild and st.enemy then
  local P=require('src.core.game3.pokemon')
  local enemy=st.enemy.mon or st.enemy
  local species=P.national(st.enemy.species or P.speciesOf(enemy))
  local name=V.data('battle_species_dex_386')[species]
  local encounter=name and bosses.species[tostring(name):upper()]
  if encounter and encounter.map==id then boss=encounter.file end
  -- FireRed's Moltres encounter moved from Victory Road to Mt. Ember.
  if tostring(name):upper()=='MOLTRES' and id=='MT_EMBER_SUMMIT'then boss='moltres.jpg'end
 end
 local set=config.maps[id]
 if not set and V.require('Gen3Tilesets').outdoor(def)then set='grassy'end
 local files=set and config.sets[set]
 local ordinary=type(files)=='string' and files or type(files)=='table' and (files[period(st)]or files.day)
 return ordinary,boss
end
function M.frame(mapId,def,st)
 local mode=UI.arenaFill:get()
 if mode=='OFF' or mode=='BLUE'then return nil end -- BLUE requires the Stadium provider.
 if mode=='WHITE'then return {color={1,1,1,1}}end
 local ordinary,boss=M.files(mapId,def,st)
 local image=UI.bossEnabled() and Images.load('bosses',boss)
 if not image then
  if mode=='PNG'then image=Images.load('bosses','arena.png')
  elseif mode=='GEN6'then image=Images.load('gen6',ordinary)end
 end
 return image and {image=image,offset=UI.backdropOffsetPixels(),color={0,0,0,1}}or nil
end
return M
