-- Real LÖVE compression/float codec; fake in-memory mod storage only.
return function(game)
 local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib
 local source=assert(V.mod:read('lib/NativeGeometryCache.lua'))
 local disk={};local value=256;local style='default';local calls,reads,writes=0,0,0
 local failWrite=false;local failIndex=false;local reverse=false;local revision='one'
 local RAM={setting={get=function()return value end},bytes=function()if value==false then return nil end;return value=='session'and 0 or value*1024*1024 end,
  off=function()return value==0 or value=='session'end,retainGenerated=function()return value=='session'end}
 local function fresh()
  local v={mod={list=function(_,dir)return dir=='lib'and(reverse and{'z.lua','a.lua'}or{'a.lua','z.lua'})or{}end,
   info=function()return{type='file'}end,read=function(_,path)return path..revision end,
   storage={readBytes=function(_,_,key)reads=reads+1;return disk[key]end,
    writeBytes=function(_,_,key,b)writes=writes+1;if failWrite or failIndex and key:sub(-5)=='index' then return false end;disk[key]=b;return true end}}}
  v.require=function(name)if name=='RamPrecache'then return RAM elseif name=='BuildBudget'then return{check=function()end}
   elseif name=='ModSetting'then return{snapshot=function()return{style=style,ramPrecacheMb=value}end}end;error(name)end
  return assert(loadstring(source))(v)
 end
 local image=love.image.newImageData(32,16);image:setPixel(0,0,.2,.3,.4,1)
 local g={cx=2,cy=3,kind='test',rows={{0}},ts={imageData=image,cols=2,rows=1,midToSlot={[0]=0}}}
 local function build(g,emit)calls=calls+1;g.chimneyOutlet={x=2,y=3,z=4};emit({{0,0,0},{1,0,0},{1,1,0},{0,1,0}},{{0,0},{1,0},{1,1},{0,1}},.5,{2,3,4})end
 local emitted=0;local function emit(p,t,s,a)assert(a and a[1]==2 and a[2]==3 and a[3]==4);emitted=emitted+1;assert(#p==4 and #t==4 and s==.5)end
 local function draw(c)c.prepare(game,{{def={id='CACHE_QA'}}});c.append('CACHE_QA',g,build,emit)end
 local c=fresh();draw(c);draw(c);assert(calls==1 and emitted==2 and c.stats.hits==1 and writes==0 and c.ramStats().dirty==1,'render must never write storage')
 assert(c.saveRamToDisk() and writes==2 and c.ramStats().dirty==0)
 reverse=true;c=fresh();draw(c);assert(calls==1 and c.stats.hits==1 and c.stats.loaded==1,'source listing order or persistent preload')
 style='other';draw(c);assert(calls==2,'settings did not invalidate')
 image:setPixel(0,0,.8,.3,.4,1);draw(c);assert(calls==3,'native pixels did not invalidate')
 g.ts.midToSlot[0]=1;draw(c);assert(calls==4,'atlas slot mapping did not invalidate')
 revision='two';c=fresh();draw(c);assert(calls==5,'model source did not invalidate');assert(c.saveRamToDisk())
 local dataKey;for k in pairs(disk)do if k:sub(-5)~='index'and k:find('/')then dataKey=k end end
 -- Corrupt every cached payload while retaining the indexes; rebuild once,
 -- and never append an incomplete replay before rebuilding.
 for k in pairs(disk)do if k:sub(-5)~='index'then disk[k]='BAG2'..love.data.pack('string','<I4',1)..'bad zlib'end end
 c=fresh();local before=emitted;draw(c);assert(calls==6 and emitted==before+1,'corrupt replay duplicated geometry');assert(c.saveRamToDisk())
 -- Valid compression with non-finite coordinates is still corrupt geometry.
 local corruptCalls=calls
 for k,bytes in pairs(disk)do if k:sub(-5)~='index' and bytes:sub(1,4)=='BAG2'then
  local valid,raw=pcall(love.data.decompress,'string','zlib',bytes:sub(9))
  if valid then raw=raw:sub(1,16)..love.data.pack('string','<f',0/0)..raw:sub(21)
  disk[k]=bytes:sub(1,8)..love.data.compress('string','zlib',raw,1)end
 end end
 c=fresh();before=emitted;draw(c);assert(calls==corruptCalls+1 and emitted==before+1,'non-finite geometry replayed')
 value='session';local r,w=reads,writes;c=fresh();draw(c);draw(c);assert(calls==8 and reads==r and writes==w and c.stats.hits==1,'LIVE read persistent data');assert(c.saveRamToDisk(),'explicit LIVE save failed')
 value=0;r,w=reads,writes;draw(c);draw(c);assert(calls==10 and reads==r and writes==w and c.stats.bytes==0,'OFF retained/read data')
 value=false;c=fresh();draw(c);assert(c.stats.bytes>0,'FULL failed')
 value=.000001;draw(c);assert(c.stats.bytes<=value*1024*1024,'budget exceeded')
 value=256;style='failed-write';failWrite=true;c=fresh();draw(c);assert(c.stats.misses==1,'failed writes should retain live native result')
 local ok,saved,failed=c.saveRamToDisk();assert(not ok and saved==0 and failed==1 and c.ramStats().dirty==1)
 failWrite=false;assert(c.saveRamToDisk() and c.ramStats().dirty==0,'retry failed')
 style='index-failure';draw(c)
 failIndex=true;ok,saved,failed=c.saveRamToDisk();assert(not ok and c.ramStats().dirty==1)
 draw(c);assert(c.ramStats().dirty==1,'cache hit lost pending save')
 failIndex=false;assert(c.saveRamToDisk());c.drop();assert(c.ramStats().files==0 and c.stats.bytes==0)
 image:release();print('[PASS native compressed geometry cache] disk/replay/source/art/options/OFF/LIVE/FULL/budget/corruption/write failure')
 love.event.quit()
end
