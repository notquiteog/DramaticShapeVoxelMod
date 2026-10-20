-- QA-only instrumentation of public mod producers, never engine callbacks.
-- Checks actual uploaded water quads beneath every wet-rock source cell and
-- emitted closed hull midpoint against the same world water plane.
return function(V)
 local W,R,S,C=V.require('Gen3Water'),V.require('Voxel3D'),V.require('Gen3SeaRocks'),V.require('Gen3Cave')
 local bind,draws,newMesh=W.bind,W.draws,R.newMesh
 local cells;local vertices=setmetatable({},{__mode='k'})
 local stats={builds=0,cells=0,large=0,small=0}
 W.bind=function(c,options)local n,field=bind(c,options);cells=c;return n,field end
 R.newMesh=function(v,...)
  local m,e=newMesh(v,...);if m then vertices[m]=v end;return m,e
 end
 local uv=function()return{{0,0},{1,0},{1,1},{0,1}}end
 local function heightKey(y)return string.format('%.5f',y)end
 W.draws=function(parts)
  local out,levels=draws(parts);local sheets={};local templates={}
  for _,p in ipairs(parts)do for _,w in ipairs(p.waters or{})do
   local vs=vertices[w.mesh]
   if not vs then
    -- A persisted native mesh can bypass the newMesh producer. Read its
    -- public Mesh vertices instead of rejecting an otherwise valid cache hit.
    vs={};for i=1,w.mesh:getVertexCount()do vs[i]={w.mesh:getVertex(i)}end
    vertices[w.mesh]=vs
   end
   for i=1,#vs,4 do
    local l,n,rr,f=math.huge,math.huge,-math.huge,-math.huge
    for j=i,i+3 do local q=vs[j];l=math.min(l,q[1]);rr=math.max(rr,q[1]);n=math.min(n,q[3]);f=math.max(f,q[3]);assert(math.abs(q[2]-w.height)<1e-6,'water height group contains a tilted quad')end
    if rr-l>=15.99 and f-n>=15.99 then
     local k=math.floor((l+rr)/32)..':'..math.floor((n+f)/32)
     sheets[k]=sheets[k]or{};sheets[k][heightKey(w.height)]=true
    end
   end
  end end
  local wet,large,small=0,0,0
  for k,c in pairs(cells or{})do local s=c.shape
   if s.kind=='rock'and(s.seaRock or s.wetRock)then
    wet=wet+1;local world=(c.base or 0)+S.waterline(c)
    assert(sheets[k]and sheets[k][heightKey(world)],'wet rock lacks matching uploaded water sheet '..k)
    if s.wetRock or s.root then
     local lo,hi=math.huge,-math.huge
     local function emitted(v)
      for _,q in ipairs(v)do
       lo=math.min(lo,q[2]+(c.base or 0));hi=math.max(hi,q[2]+(c.base or 0))
       local w=s.seaRock and 32 or 16
       assert(q[1]>=c.cx*16-.001 and q[1]<=(c.cx*16+w)+.001 and q[3]>=c.cy*16-.001 and q[3]<=(c.cy*16+w)+.001,'wet hull escaped blocked source footprint')
      end
     end
     if s.seaRock then
      large=large+1
      local g={};for a,b in pairs(s.seaRock)do g[a]=b end
      local original=s.seaRock.template;templates[original]=templates[original]or{};g.template=templates[original]
      local cc={cx=c.cx,cy=c.cy,ts=c.ts,shape={root=true,seaRock=g,waterline=s.waterline}}
      S.append(cc,emitted,uv)
     else small=small+1;C.rock(c,emitted,uv)end
     assert(lo<world and hi>world and math.abs((lo+hi)/2-world)<1e-5,'actual wet hull does not straddle world waterline')
    end
   end
  end
  if wet>0 then stats.builds=stats.builds+1;stats.cells=stats.cells+wet;stats.large=stats.large+large;stats.small=stats.small+small
   print('[SEA WATER COVERAGE] PASS',require('src.core.game3.map').current,wet,'wet cells',large,'complete hulls',small,'small hulls')
  end
  return out,levels
 end
 return function()
  W.bind,W.draws,R.newMesh=bind,draws,newMesh
  assert(stats.builds>0 and stats.large>0,'no wet geometry audited')
  if os.getenv('QA_SMALL_ROCKS')=='1'then assert(stats.small>0,'no small wet-rock geometry audited')end
  print('[SEA WATER AUDIT] PASS',stats.builds,stats.cells,stats.large,stats.small)
  return stats
 end
end
