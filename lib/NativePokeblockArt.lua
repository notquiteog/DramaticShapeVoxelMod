-- Pokeblock screens cache native pictures between their update and draw.
-- Observe the public mon reader during native loading, then replace only the
-- cached picture for a draw. Cursor changes must not relabel an outgoing image.
local M={}
local function pack(...)return {n=select('#',...),...}end
function M.install(Art,Pokemon)
 if type(Pokemon.monFrontPic)~='function'then return function()end end
 local undo={}
 for _,entry in ipairs({{'use_pokeblock','monPic'},{'pokeblock_feed','image'}})do
  local ok,screen=pcall(require,'src.ui.game3.rse.'..entry[1])
  if ok and type(screen)=='table'and type(screen._st)=='table'and type(screen.show)=='function'
   and type(screen.update)=='function'and type(screen.draw)=='function'and type(screen.reset)=='function'then
   local state=screen._st
   local originals={show=screen.show,update=screen.update,draw=screen.draw,reset=screen.reset}
   local sources=setmetatable({},{__mode='k'})
   local function observe(original,...)
    local reader=Pokemon.monFrontPic
    Pokemon.monFrontPic=function(mon,...)
     local result=pack(reader(mon,...))
     local pic=result[1]
     if pic and pic.image and type(mon)=='table'then
      local species=Pokemon.speciesOf(mon)
      local special=Pokemon.isEgg(mon)or species==Pokemon.SPECIES_SPINDA or species==Pokemon.SPECIES_DEOXYS
       or Pokemon.monPicSpecies(mon)~=species
      sources[pic.image]=not special and{species=Pokemon.national(species),personality=mon.personality,
       otId=mon.otId,otSecretId=mon.otSecretId,isShiny=Pokemon.isShiny(mon)}or false
     end
     return unpack(result,1,result.n)
    end
    local result=pack(pcall(original,...))
    Pokemon.monFrontPic=reader
    if not result[1]then error(result[2],0)end
    return unpack(result,2,result.n)
   end
   screen.show=function(...)
    sources=setmetatable({},{__mode='k'});return observe(originals.show,...)
   end
   screen.update=function(...)return observe(originals.update,...)end
   screen.reset=function(...)
    sources=setmetatable({},{__mode='k'});return originals.reset(...)
   end
   screen.draw=function(...)
    local owner=entry[2]=='monPic'and state or state.mon
    local image=owner and owner[entry[2]]
    local source=image and sources[image]
    local selected=source and Art.picture(source)
    if not selected then return originals.draw(...)end
    owner[entry[2]]=selected
    local result=pack(pcall(originals.draw,...))
    owner[entry[2]]=image
    if not result[1]then error(result[2],0)end
    return unpack(result,2,result.n)
   end
   undo[#undo+1]=function()
    screen.show,screen.update,screen.draw,screen.reset=originals.show,originals.update,originals.draw,originals.reset
    sources=setmetatable({},{__mode='k'})
   end
  end
 end
 return function()for i=#undo,1,-1 do undo[i]()end end
end
return M
