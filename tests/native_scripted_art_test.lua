local checks=0
local function check(v,why)checks=checks+1;assert(v,why)end
local native={};local selected={getDimensions=function()return 64,72 end}
local seen,mon,enabled,fail=nil,nil,true,false
local Pic={active=false,_img=native,_w=64,_h=64}
Pic.show=function(species)Pic.active=true;Pic.species=species;Pic._img=native;return nil,'shown',false end
Pic.hide=function()Pic.active=false end
Pic.draw=function()
 seen={Pic._img,Pic._w,Pic._h,Pic._animTransform}
 if fail then error('native draw failure')end
 return nil,'drawn',false
end
local Entry={active=false}
Entry.show=function(m)if Entry.active then return end;Pic.show(m.species);Entry.active=true;return nil,'entry',false end
Entry.hide=function()Entry.active=false;Pic.hide()end
Entry.reset=function()Entry.active=false end
package.loaded['src.ui.game3.mon_pic']=Pic
package.loaded['src.ui.game3.rse.contest_entry_pic']=Entry
local Pokemon={SPECIES_EGG=412,SPECIES_SPINDA=308,SPECIES_DEOXYS=410,
 national=function(s)return s==277 and 252 or s end,
 picSpecies=function(s,p)return s==201 and p==0x8000 and 417 or s end,
 isShiny=function(m)return m.otId==7 and m.otSecretId==9 and m.personality==14 end}
local mode='fit'
local Art={settings={false,{get=function()return mode end}},picture=function(m)mon=m;return enabled and selected or nil end}
local originals={Pic.draw,Pic.show,Pic.hide,Entry.show,Entry.hide,Entry.reset}
local M=assert(loadfile('lib/NativeScriptedArt.lua'))()
local undo=M.install(Art,Pokemon)
local a,b,c=Pic.show(277);check(a==nil and b=='shown'and c==false,'show exact returns')
local transform={x2=3,rotation=.25};Pic._animTransform=transform
 a,b,c=Pic.draw();check(a==nil and b=='drawn'and c==false,'draw exact returns')
check(mon.species==252 and not mon.isShiny and mon.personality==0x8000,'script national/default identity')
check(seen[1]==selected and seen[2]==64 and seen[3]==72 and seen[4]==transform,'native cached draw substitution and transform')
check(Pic._img==native and Pic._w==64 and Pic._h==64,'original cache restored')
mode='full';Pic.draw();check(seen[4]~=transform and seen[4].rotation==transform.rotation and seen[4].x2==3 and seen[4].sx==72/64 and seen[4].sy==72/64,'FULL compensates only native viewport scaling')
check(Pic._animTransform==transform,'FULL original animation state restored');mode='fit'
enabled=false;Pic.draw();check(seen[1]==native,'OFF/missing picture native');enabled=true
for _,species in ipairs({412,308,410,201})do Pic.show(species);Pic.draw();check(seen[1]==native,'special native picture rules')end
local entry={species=155,personality=14,otId=9*65536+7}
a,b,c=Entry.show(entry);check(a==nil and b=='entry'and c==false,'contest exact returns');Pic.draw()
check(mon.species==155 and mon.personality==14 and mon.otId==7 and mon.otSecretId==9 and mon.isShiny,'contest packed OT/shiny identity')
Entry.show({species=25,personality=30,otId=0});Pic.draw();check(mon.species==155 and mon.isShiny,'active contest show retains first identity')
fail=true;local ok=pcall(Pic.draw);check(not ok and Pic._img==native and Pic._w==64 and Pic._h==64,'native errors restore cache');fail=false
Entry.hide();Pic.show(155);Pic.draw();check(not mon.isShiny and mon.personality==0x8000,'hide clears contest context')
Entry.show(entry);Entry.reset();Pic.draw();check(not mon.isShiny,'reset clears context')
undo();check(Pic.draw==originals[1]and Pic.show==originals[2]and Pic.hide==originals[3]and Entry.show==originals[4]and Entry.hide==originals[5]and Entry.reset==originals[6],'unload restores every owner')
package.loaded['src.ui.game3.mon_pic']={}
local noop=M.install(Art,Pokemon);check(type(noop)=='function','missing native capability safely declines');noop()
print('PASS '..checks..' scripted picture lifecycle checks')
