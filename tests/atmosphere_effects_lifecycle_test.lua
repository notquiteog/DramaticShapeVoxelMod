-- Cached submission order must survive revocation, failure and new owners.
local drawn,depth,shader={},0,nil
local noop=function()end
love={graphics={newShader=function(source)return {name=source,hasUniform=function()return true end,send=noop,release=noop}end,
 newMesh=function()return {setTexture=noop,release=noop}end,
 push=function()depth=depth+1 end,pop=function()depth=depth-1 end,
 setShader=function(s)shader=s end,setDepthMode=noop,setMeshCullMode=noop,setBlendMode=noop,setColor=noop,
 draw=function()if shader.name=='fail'then error('fixture failure')end;drawn[#drawn+1]=shader.name end}}
local V={require=function(n)return assert(loadfile('lib/'..n..'.lua'))()end}
local S=assert(loadfile('lib/AtmosphereEffects.lua'))(V).new()
local function owner(name,source)
 local api=S.owner(name)
 local mat=assert(api:material{source=source or name})
 local mesh=assert(api:mesh{format={{'VertexPosition','float',3}},vertices={{0,0,0},{1,0,0},{0,1,0}}})
 return api,function()assert(api:enqueue{phase='sky_deck',material=mat,mesh=mesh})end
end
local b,qb=owner('b');local a,qa=owner('a')
S.beginFrame(1,true);qb();qa();assert(S.draw('sky_deck',{}, {},true))
assert(table.concat(drawn)== 'ab'and depth==0)
S.beginFrame(2,true);drawn={};assert(S.draw('sky_deck',{}, {},true));assert(#drawn==0,'stale queued draws')
qa();qb();assert(a:clear());assert(S.draw('sky_deck',{}, {},true));assert(table.concat(drawn)=='b')
S.revoke('a');local c,qc=owner('c');S.beginFrame(3,true);qc();qb();drawn={}
assert(S.draw('sky_deck',{}, {},true));assert(table.concat(drawn)=='bc')
local bad,qbad=owner('aa','fail');S.beginFrame(4,true);qbad();qb();qc();drawn={}
assert(not S.draw('sky_deck',{}, {},true));assert(table.concat(drawn)=='bc'and depth==0,'failure skipped another owner or leaked state')
assert(not bad:camera(),'failed owner remains live')
S.beginFrame(5,true);qb();qc();drawn={};assert(S.draw('sky_deck',{}, {},true));assert(table.concat(drawn)=='bc')
S.reset();drawn={};assert(S.draw('sky_deck',{}, {},true));assert(#drawn==0)
print('PASS atmosphere sorted owner lifecycle, frame/explicit clearing, failure isolation and reset')
