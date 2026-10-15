local checks=0
local function check(v,why)checks=checks+1;assert(v,why)end
local first={getDimensions=function()return 64,64 end}
local full={getDimensions=function()return 100,80 end}
local chosen=first;local seen={};local fail
local Art={picture=function(mon)seen[#seen+1]=mon;return chosen end}
local P={national=function(n)return n-1000 end,isEgg=function(m)return m.species==1412 end,
 monPicSpecies=function(m)return m.species==1201 and 1202 or m.species end,SPECIES_SPINDA=1327,SPECIES_DEOXYS=1386}
local cache={[0]={key='native0'},[1]={key='native1'},[4]={key='other'}}
local sim={_pics=cache,game={gfx={numPlayers=2},monInfo={[0]={species=1025,personality=100,shiny=false},[1]={species=1025,personality=200,shiny=true}}}}
local during
local Render={draw=function(s,marker)during=s._pics;if fail then error('native draw failed')end;return nil,marker,false end}
package.loaded['src.ui.game3.minigames.pokemon_jump.render']=Render
local original=Render.draw;local undo=dofile('lib/NativeJumpArt.lua').install(Art,P)
local a,b,c=Render.draw(sim,'draw')
check(a==nil and b=='draw'and c==false,'exact native returns')
check(sim._pics==cache and cache[0].key=='native0','original picture cache restored')
check(during~=cache and during[4]==cache[4],'temporary view preserves other native cached entries')
check(during[0].entry.image==first and during[0].key=='1025:100:false','native cache key contract')
check(seen[1].species==25 and seen[1].personality==100 and seen[1].isShiny==false and seen[2].isShiny==true,'same-species player identities stay independent')
chosen=full;Render.draw(sim);check(during[0].entry.w==100 and during[0].entry.h==80,'FULL dimensions remain unclamped')
sim.game.monInfo[1].personality=300;Render.draw(sim);check(during[1].key=='1025:300:true','changed player identity is not stale')
chosen=nil;Render.draw(sim);check(during==cache,'OFF/missing art uses native cache directly')
chosen=first
for _,species in ipairs({1412,1201,1327,1386})do
 sim.game.monInfo[0].species=species;Render.draw(sim);check(during[0]==cache[0],'egg/forms retain native entry')
end
sim.game.monInfo[0].species=1025
fail=true;local ok=pcall(Render.draw,sim);check(not ok and sim._pics==cache,'draw errors restore cache owner')
fail=false;sim._pics=nil;Render.draw(sim);check(sim._pics==nil,'absent native cache remains absent')
undo();check(Render.draw==original,'unload restores native renderer')
print('PASS '..checks..' native Pokemon Jump picture checks')
