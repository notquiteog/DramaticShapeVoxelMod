-- Pokemon Jump caches pictures by player. Give only its original draw a
-- selected-image view of that cache; never persist art into simulation state.
local M={}
local function pack(...)return {n=select('#',...),...}end
function M.install(Art,Pokemon)
 local ok,Render=pcall(require,'src.ui.game3.minigames.pokemon_jump.render')
 if not ok or type(Render)~='table'or type(Render.draw)~='function'then return function()end end
 local draw=Render.draw
 Render.draw=function(sim,...)
  local game=sim and sim.game
  if not(game and game.gfx and type(game.monInfo)=='table')then return draw(sim,...)end
  local native=sim._pics;local selected
  for i=0,(game.gfx.numPlayers or 0)-1 do
   local info=game.monInfo[i]
   if info and info.species and info.species~=0 then
    local mon={species=info.species,personality=info.personality,isShiny=info.shiny}
    local special=Pokemon.isEgg(mon)or info.species==Pokemon.SPECIES_SPINDA or info.species==Pokemon.SPECIES_DEOXYS
     or Pokemon.monPicSpecies(mon)~=info.species
    local image=not special and Art.picture({species=Pokemon.national(info.species),personality=info.personality,isShiny=info.shiny})
    if image then
     if not selected then selected={};for k,v in pairs(native or{})do selected[k]=v end end
     local w,h=image:getDimensions()
     selected[i]={key=tostring(info.species)..':'..tostring(info.personality)..':'..tostring(info.shiny),entry={image=image,w=w,h=h}}
    end
   end
  end
  if not selected then return draw(sim,...)end
  sim._pics=selected
  local result=pack(pcall(draw,sim,...))
  sim._pics=native
  if not result[1]then error(result[2],0)end
  return unpack(result,2,result.n)
 end
 return function()Render.draw=draw end
end
return M
