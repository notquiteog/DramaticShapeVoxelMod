-- Native engine driver. Read-only diagnostics/optional integration contract;
-- run on disposable imported profiles for each supported game.
return function(game)
 local exports=assert(game.mods.exports.BATTLE_ART_VOXEL_FORK)
 local api=assert(exports.performance,'performance provider missing')
 local gv=require('src.core.GameVersion')
 local s=api.snapshot()
 assert(s.generation==gv.generation() and s.game==gv.get())
 if s.generation==3 then
  assert(exports[gv.get()]==exports.gen3,'cart alias differs from shared native provider')
  assert(s.nativeScene and s.nativeScene.stream and s.nativeScene.geometryCache)
  assert(next(s.mesher)==nil and next(api.storageSnapshot())==nil)
  s.nativeScene.stream.hits=-1
  assert(api.snapshot().nativeScene.stream.hits>=0,'snapshot mutated live counters')
 else
  assert(s.nativeScene==nil and s.cache and s.mesher and s.shadow)
 end
 print('[performance API] PASS',s.game)
 love.event.quit()
end
