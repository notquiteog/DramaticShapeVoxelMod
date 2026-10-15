local checks=0
local function check(v,why)checks=checks+1;assert(v,why)end
local oldImage,newImage,selected={},{},{}
local first={species=25,personality=1,isShiny=false,image=oldImage}
local second={species=155,personality=2,isShiny=true,image=newImage}
local P={SPECIES_SPINDA=308,SPECIES_DEOXYS=410,speciesOf=function(m)return m.species end,
 national=function(s)return s end,isEgg=function(m)return m.isEgg end,
 monPicSpecies=function(m)return m.form or m.species end,isShiny=function(m)return m.isShiny end,
 monFrontPic=function(m)return{image=m.image},nil,'native'end}
local reader=P.monFrontPic
local seen,source,enabled,fail=nil,nil,true,false
local Use={_st={}}
Use.show=function(mon)Use._st.sel=mon;Use._st.monPic=P.monFrontPic(mon).image;return nil,'show',false end
Use.update=function(load)
 if load=='error'then error('native update failure')end
 if load then Use._st.monPic=P.monFrontPic(Use._st.sel).image end
 return nil,'update',false
end
Use.draw=function()seen=Use._st.monPic;if fail then error('native draw failure')end;return nil,'draw',false end
Use.reset=function()Use._st.monPic=nil end
local Feed={_st={}}
Feed.show=function(mon)Feed._st.mon={image=P.monFrontPic(mon).image,affine={rotation=.5}}end
Feed.update=function()end
Feed.draw=function()seen=Feed._st.mon.image end
Feed.reset=function()Feed._st.mon=nil end
package.loaded['src.ui.game3.rse.use_pokeblock']=Use
package.loaded['src.ui.game3.rse.pokeblock_feed']=Feed
local original={Use.show,Use.update,Use.draw,Use.reset,Feed.show,Feed.update,Feed.draw,Feed.reset}
local Art={picture=function(m)source=m;return enabled and selected or nil end}
local M=assert(loadfile('lib/NativePokeblockArt.lua'))();local undo=M.install(Art,P)
local a,b,c=Use.show(first);check(a==nil and b=='show'and c==false and P.monFrontPic==reader,'native show returns and reader ownership')
a,b,c=Use.draw();check(a==nil and b=='draw'and c==false and seen==selected and Use._st.monPic==oldImage,'scoped cached substitution')
Use._st.sel=second;Use.update(false);Use.draw();check(source.personality==1 and not source.isShiny,'outgoing picture retains old identity after cursor changes')
a,b,c=Use.update(true);Use.draw();check(source.personality==2 and source.isShiny and Use._st.monPic==newImage,'new loaded picture changes identity at native boundary')
check(a==nil and b=='update'and c==false,'native update exact returns')
enabled=false;Use.draw();check(seen==newImage,'OFF or unavailable art keeps original cache');enabled=true
fail=true;check(not pcall(Use.draw)and Use._st.monPic==newImage,'draw error restores native cache');fail=false
check(not pcall(Use.update,'error')and P.monFrontPic==reader,'update error restores native reader')
local broken=function()error('native reader failure')end;P.monFrontPic=broken
check(not pcall(Use.update,true)and P.monFrontPic==broken and Use._st.monPic==newImage,'reader errors unwind without changing cached picture');P.monFrontPic=reader
for _,mon in ipairs({{species=308},{species=410},{species=25,isEgg=true},{species=201,form=413}})do
 mon.image=oldImage;Use.show(mon);Use.draw();check(seen==oldImage,'special native identity retained')
end
Feed.show(second);local affine=Feed._st.mon.affine;Feed.draw()
check(seen==selected and source.personality==2 and Feed._st.mon.image==newImage and Feed._st.mon.affine==affine,'feeding original affine/cache ownership')
Use.show(first);Use.reset();Use._st.monPic=oldImage;Use.draw();check(seen==oldImage,'reset clears stale image identity')
undo();check(Use.show==original[1]and Use.update==original[2]and Use.draw==original[3]and Use.reset==original[4]and Feed.show==original[5]and Feed.update==original[6]and Feed.draw==original[7]and Feed.reset==original[8],'unload restores all native owners')
print('PASS '..checks..' native Pokeblock cached-picture checks')
