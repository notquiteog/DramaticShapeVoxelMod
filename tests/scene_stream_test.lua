local now=0
love={timer={getTime=function()return now end}}
local B=dofile('lib/BuildBudget.lua')
local S=assert(loadfile('lib/SceneStream.lua'))({require=function(n)assert(n=='BuildBudget');return B end})
local releases={}
local s=S.new(function(value)assert(not releases[value],'double release');releases[value]=true end)
local function build(name,fail)
 return function(v)
  v.name=name
  for i=1,12 do now=now+.001;B.check();v.progress=i end
  if fail then error('upload failed')end
  v.ready=true;return v
 end
end
local a=s:update('a','map',build('a'),.002)
assert(a.ready and not s.pending,'cold scene must be complete')
assert(s:update('b','map',build('b'),.002)==a and s.pending,'retain previous window')
local abandoned=s.pending.value
assert(not abandoned.ready and not releases[a],'partial geometry escaped')
assert(s:update('a','map',build('unused'),.002)==a and releases[abandoned],'reversal did not cancel')
assert(s:update('b','map',build('b'),.002)==a)
local b
for i=1,20 do b=s:update('b','map',build('b'),.002);if not s.pending then break end end
assert(b~=a and b.ready and releases[a],'complete candidate not atomically swapped')
assert(s.stats.maxStreamSlice<=.0031,'cooperative slice overran its checkpoint')
-- A running player can change requested windows every slice. Finish useful
-- work instead of continually restarting it, and publish its OWN key.
local running=s:update('run1','map',build('run1'),.002)
for i=2,20 do
 running=s:update('run'..i,'map',build('run'..i),.002)
 if running~=b then break end
end
assert(running~=b and running.name=='run1' and s.key=='run1','moving window starved or was mislabeled')
local completed=s.stats.completed
assert(s:update('run1','map',build('unused'),.002)==running and s.stats.completed==completed)
b=running
local c=s:update('c','other map',build('c'),.002)
assert(c.ready and releases[b] and not s.pending,'warp used old map geometry')
s:update('d','other map',build('bad',true),.002)
local bad=s.pending.value
local ok,err=true
for i=1,20 do ok,err=pcall(s.update,s,'d','other map',build('bad',true),.002);if not ok then break end end
assert(not ok and tostring(err):find('upload failed') and releases[bad] and s.active==c and not releases[c],'failure leaked/replaced scene')
-- In-place edits / replay views cannot use the immutable-layout shortcut.
local replay=s:update(nil,nil,build('replay'),.002)
assert(replay.ready and releases[c] and not s.pending)
s:update('e',nil,build('immediate'),.002)
s:clear();s:clear();assert(not s.active and not s.pending)
print('PASS retained window, atomic publish, reversal, warp, failure cleanup, synchronous replay and budget')
local warm=S.new(function(value)assert(not releases[value],'double release');releases[value]=true end)
local home=warm:update('home','home',build('home'),.002)
warm:prefetch('next','next',build('next'),.002)
assert(warm.active==home and warm.warm and not warm.warm.ready,'prefetch changed active scene')
for i=1,20 do warm:prefetch('next','next',build('next'),.002)end
assert(warm.warm.ready and warm.stats.prefetched==1)
local start=now;local promoted=warm:update('next','next',function()error('warm scene rebuilt')end,.002)
assert(promoted.name=='next'and now==start and not releases[home]and warm.warm.value==home and warm.stats.promoted==1)
warm:prefetch('third','third',build('third'),.002)
assert(releases[home],'displaced retained scene leaked')
local partial=warm.warm.value
local third=warm:update('third','third',function()error('partial warm scene restarted')end,.002)
assert(third==partial and third.ready and not releases[promoted] and warm.warm.value==promoted)
assert(warm.stats.forcedCompletions==1 and warm.stats.maxPromotionSlice>.002,'late completion cost missing from metrics')
warm:prefetch('bad','bad',build('bad',true),.002)
for i=1,20 do warm:prefetch('bad','bad',build('bad',true),.002)end
assert(warm.warm.failed and warm.stats.prefetchFailed==1 and warm.active==third)
warm:prefetch('old','old',build('old'),.002);local obsolete=warm.warm.value
warm:prefetch('changed','changed',build('changed'),.002);assert(releases[obsolete])
local abandonedWarm=warm.warm.value;warm:clear();assert(releases[abandonedWarm]and releases[third])
print('PASS bounded prefetch, atomic ready promotion, partial completion, failure isolation and cancellation')
local near=S.new(function(value)assert(not releases[value]);releases[value]=true end)
near:update('a','a',build('a'),.002)
for i=1,20 do near:prefetch('b0','b',build('b0'),.002)end
local n=near:update('b1','b',build('b1'),.002,function()return true end)
assert(n.name=='b0'and near.key=='b0'and near.pending and near.stats.promoted==1,'nearby window promotion relabeled or rebuilt synchronously')
near:clear()
print('PASS adjacent-window promotion retains original key while correct window streams')
local partialNear=S.new(function()end)
partialNear:update('home','home',build('home'),.002)
partialNear:prefetch('edge0','edge',build('edge0'),.002)
assert(not partialNear.warm.ready)
local partialValue=partialNear.warm.value
local entered=partialNear:update('edge1','edge',build('edge1'),.002,function()return true end)
assert(entered==partialValue and entered.name=='edge0' and partialNear.stats.promoted==1,'partial adjacent entry discarded work')
partialNear:clear()
print('PASS partial adjacent-window entry finishes existing work before streaming corrected window')

local swap=S.new(function(value)assert(not releases[value]);releases[value]=true end)
local left=swap:update('left','l',build('left'),.002)
for i=1,20 do swap:prefetch('right','r',build('right'),.002)end
local right=swap:update('right','r',function()error('ready rebuilt')end,.002)
swap:discardPrefetch(true);assert(swap.warm.value==left,'outside-cell interpolation dropped retained scene')
local stamp=now
for i=1,4 do
 swap:prefetch('left','l',function()error('retained rebuilt')end,.002)
 assert(swap:update('left','l',function()error('return rebuilt')end,.002)==left)
 swap:prefetch('right','r',function()error('retained rebuilt')end,.002)
 assert(swap:update('right','r',function()error('return rebuilt')end,.002)==right)
end
assert(now==stamp and swap.stats.retainedHits==8 and not releases[left]and not releases[right])
swap:prefetch('left-new-atlas','l',build('fresh'),.002)
assert(releases[left]and not releases[right],'provider key change reused retained scene')
local stale=swap.warm.value
swap:prefetch('left-new-atlas','edited-layout',build('edit'),.002)
assert(releases[stale],'gameplay context change retained old scene')
swap:clear();swap:clear();assert(releases[right])
print('PASS repeated return crossings reuse bounded scenes; provider/edit invalidation and cleanup')

local advancing=S.new(function(v)assert(not releases[v]);releases[v]=true end)
advancing:update('home','home',build('home'),.002)
advancing:prefetch('ahead1','ahead',build('ahead1'),.002)
local original=advancing.warm.value
for i=2,20 do
 advancing:prefetch('ahead'..i,'ahead',build('ahead'..i),.002,function()return true end)
 if advancing.warm.ready then break end
end
assert(advancing.warm.ready and advancing.warm.value==original and original.name=='ahead1',
 'moving destination restarted unfinished work')
local stamp=now
advancing:prefetch('adjacent','ahead',function()error('ready nearby candidate rebuilt')end,.002,function()return true end)
assert(advancing.warm.value==original and now==stamp,'ready destination coverage was discarded')
advancing:prefetch('new-provider','ahead',build('provider'),.002,function()return false end)
assert(releases[original] and advancing.warm.value~=original,'unacceptable provider remained cached')
local stale=advancing.warm.value
advancing:prefetch('edited','changed-context',build('edited'),.002,function()return true end)
assert(releases[stale],'changed native layout retained stale prefetch')
advancing:clear()
print('PASS destination window progress, ready adjacent reuse and provider/context invalidation')

local provider=S.new(function(v)assert(not releases[v]);releases[v]=true end)
provider:prefetch('unloaded','world',build('old-atlas'),.002)
local missing=provider.warm.value
provider:prefetch('loaded','world',build('new-atlas'),.002,function()return false end)
assert(releases[missing] and provider.warm.value~=missing,'partial provider change reused stale atlas')
provider:clear()
print('PASS partial provider readiness changes cancel safely before crossing')
