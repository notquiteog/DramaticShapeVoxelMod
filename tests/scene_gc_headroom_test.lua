local M=dofile('lib/SceneGcHeadroom.lua')
local engine={GC_CEILING_KB=256*1024,GC_BUDGET_SEC=.0003,GC_MAX_STEPS=64}
local gc=M.new(engine)
gc:update(true);assert(engine.GC_CEILING_KB==512*1024)
assert(engine.GC_BUDGET_SEC==.0003 and engine.GC_MAX_STEPS==64)
gc:update(true);gc:dispose();assert(engine.GC_CEILING_KB==256*1024)
gc:update(false);gc:update(true);engine.GC_CEILING_KB=768*1024
gc:update(true);gc:dispose();assert(engine.GC_CEILING_KB==768*1024)
gc:update(true);gc:dispose();assert(engine.GC_CEILING_KB==768*1024)
engine.GC_CEILING_KB=256*1024;gc:update(true);engine.GC_CEILING_KB=128*1024
gc:update(true);gc:update(true);assert(engine.GC_CEILING_KB==128*1024)
gc:dispose();assert(engine.GC_CEILING_KB==128*1024)
for _,e in ipairs({{}, {GC_CEILING_KB='other'}, {GC_CEILING_KB=0}, {GC_CEILING_KB=-1}})do
 local old=e.GC_CEILING_KB;local g=M.new(e);g:update(true);g:dispose();assert(e.GC_CEILING_KB==old)
end
-- An already established engine dynamic threshold is engine-owned.
engine._gcNextKB=900*1024;gc:update(true);gc:dispose();assert(engine._gcNextKB==900*1024)
local mobile={GC_CEILING_KB=256*1024};M.new(mobile,{mobile=true}):update(true);assert(mobile.GC_CEILING_KB==256*1024)
print('PASS bounded construction headroom, original incremental policy, restore, absent API and other-mod ownership')
