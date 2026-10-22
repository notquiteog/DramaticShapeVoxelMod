-- LÖVE driver: actual zlib/packing/hash and ImageData, isolated cache provider.
return function(game)
 local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib
 local settings={detail='normal',ramPrecacheMb=64};local builds,emitted=0,0
 local B=V.require('BuildBudget')
 local fake={mod={list=function()return{}end,info=function()end,read=function()end,
  storage={readBytes=function()end,writeBytes=function()return true end}}}
 function fake.require(n)
  if n=='RamPrecache'then return {bytes=function()return nil end,setting={get=function()return'live'end},off=function()return false end,retainGenerated=function()return true end}end
  if n=='BuildBudget'then return B end
  if n=='ModSetting'then return {snapshot=function()local t={};for k,v in pairs(settings)do t[k]=v end;return t end}end
  error(n)
 end
 local C=assert(loadfile(os.getenv('MOD_ROOT')..'/lib/NativeGeometryCache.lua'))(fake)
 assert(C.prepare(game,{}))
 local pixels=love.image.newImageData(16,16)
 local g={ts={imageData=pixels,midToSlot={[1]=0},cols=1,rows=1},rows={{1}}}
 local p={{0,0,0},{1,0,0},{1,0,1},{0,0,1}};local uv={{0,0},{1,0},{1,1},{0,1}}
 local function build(_,emit)builds=builds+1;for i=1,500 do emit(p,uv,.75,{1,2,3})end end
 local function emit(q,t,s,a)assert(q[2][1]==1 and t[3][2]==1 and s==.75 and a[3]==3);emitted=emitted+1 end
 local function append()C.append('fixture',g,build,emit)end
 append();append();assert(builds==1 and C.stats.hits==1)
 settings.detail='full';append();assert(builds==2)
 settings.detail='normal';append();assert(builds==2 and C.stats.hits==2)
 settings.extra=false;append();assert(builds==3)
 settings.extra=nil;append();assert(builds==3)
 settings.ramPrecacheMb=128;append();assert(builds==3,'RAM policy changed geometry identity')
 assert(emitted==3500);pixels:release()
 print('PASS native geometry zlib roundtrip, changed/added/removed settings, cache reuse and quad integrity')
 love.event.quit()
end
