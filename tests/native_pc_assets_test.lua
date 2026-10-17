local checks=0;local function check(v,why)checks=checks+1;assert(v,why)end
local native='data/generated/gba/pokemon/storage/pc_screen_bar.png'
local path='pokemon/storage/'..native;local fallbackCalls=0
local supplied,missing,errorDraw=false,false,false
local Assets={image=function(p,marker)
 if p=='pokemon/storage/'..native or p=='data/generated/gba/pokemon/storage/'..native then if supplied then return 'provided',marker end;error('missing prefixed file')end
 if p==native then fallbackCalls=fallbackCalls+1;if missing then error('native file absent')end;return 'native-bar',marker end
 return 'other',marker
end}
package.loaded['src.render.Assets']=Assets
local seen
local Pc={ensure=function(marker)
 seen={Assets.image(path,marker)}
 if errorDraw then error('native ensure failure')end
 return nil,marker,false
end}
local ensure,image=Pc.ensure,Assets.image
local undo=dofile('lib/NativePcAssets.lua').install(Pc)
local a,b,c=Pc.ensure('rs')
check(a==nil and b=='rs'and c==false,'exact native ensure tuple')
check(seen[1]=='native-bar'and seen[2]=='rs'and fallbackCalls==1,'only missing duplicate path resolves original native image')
check(Assets.image==image,'public image reader restored')
supplied=true;Pc.ensure();check(seen[1]=='provided'and fallbackCalls==1,'supplied native/provider image wins');supplied=false
missing=true;local ok=pcall(Pc.ensure);check(not ok and Assets.image==image,'absent original artwork retains failure and restores reader');missing=false
errorDraw=true;ok=pcall(Pc.ensure);check(not ok and Assets.image==image,'native ensure error restores reader');errorDraw=false
path='unrelated.png';Pc.ensure();check(seen[1]=='other','unrelated image paths untouched')
path='data/generated/gba/pokemon/storage/'..native;Pc.ensure();check(seen[1]=='native-bar','second native duplicated prefix handled')
undo();check(Pc.ensure==ensure and Assets.image==image,'unload restores original public owners')
print('PASS '..checks..' native PC asset checks')
