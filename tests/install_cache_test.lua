local Cache=dofile('lib/InstallCache.lua')
local files={};local failIndex=false
local api={read=function(_,k)return files[k]end,
 write=function(_,k,v)if failIndex and k:match('index.txt$')then return nil,'full'end;files[k]=v;return true end,
 delete=function(_,k)files[k]=nil;return true end}
local red=assert(Cache.new(api,'red'));local blue=assert(Cache.new(api,'blue'))
assert(red:writeBytes('cache/one','red data'));assert(blue:writeBytes('cache/one','blue data'))
assert(red:readBytes('cache/one')=='red data'and blue:readBytes('cache/one')=='blue data','versions share cache')
assert(red:writeBytes('other/two','second'));local restarted=assert(Cache.new(api,'red'))
assert(#restarted:list('cache/')==1 and #restarted:list()==2,'restart/index enumeration')
assert(restarted:delete('cache/one'));assert(not Cache.new(api,'red'):readBytes('cache/one'))
assert(#Cache.new(api,'red'):list()==1 and blue:readBytes('cache/one')=='blue data','owner-scoped deletion')
for _,k in ipairs({'../other','/absolute','a/../../b','a\nb',''})do assert(not red:writeBytes(k,'bad'))end
failIndex=true;local ok=red:writeBytes('cache/rollback','orphan');assert(not ok)
assert(not files['voxel/red/cache/rollback'],'unindexed write survives failed index')
failIndex=false
files['voxel/gold/index.txt']='../escape\n/absolute\ncache/good\ncache/good'
local gold=assert(Cache.new(api,'gold'));assert(#gold:list()==1 and gold:list()[1]=='cache/good')
print('PASS installation cache version isolation, restart, scoped deletion, bounded keys and write rollback')
