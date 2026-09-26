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
