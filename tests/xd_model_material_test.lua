-- CPU graphics double: source channels, animation selection, texture ownership.
local wrapS,wrapT,filterMin,filterMag,aniso='repeat','clamp','nearest','linear',2
local texture={getWrap=function()return wrapS,wrapT end,setWrap=function(_,s,t)wrapS,wrapT=s,t end,
 getFilter=function()return filterMin,filterMag,aniso end,setFilter=function(_,a,b,c)filterMin,filterMag,aniso=a,b,c end}
love={graphics={newMesh=function(_,vertices)return {setVertices=function()end,release=function()end}end},
 data={decompress=function(_,_,bytes)return bytes end,unpack=function()return 1,0,0,0,0,1,0,0,0,0,1,0 end}}
local M=assert(loadfile('lib/XDModelInstance.lua'))({})
local function make(source,alpha,light)
 local material={diffuse_color={.2,.3,.4},alpha=.6,color_source=source,alpha_source=alpha,lighting=light,
 texture_layers={{image={path='skin.png'},interpolation='Linear',wrap_s='CLAMP',wrap_t='MIRROR'}}}
 local bone={name='root',world_matrix={{1,0,0,0},{0,1,0,0},{0,0,1,0}}}
 local data={version=1,model={bones={bone},meshes={{vertices={{0,0,0},{1,0,0},{0,1,0}},
 faces={{0,1,2}},material=material,color_layers={{colors={{.5,.5,.5,.5},{.5,.5,.5,.5},{.5,.5,.5,.5}}}}}}},
 clips={}}
 for i,name in ipairs({'Idle','Physical_B','Physical','Damage'})do
 data.clips[i]={name='hash_0'..i..'_'..name,frames=2,bones=1,fps=30,path=name}
 end
 local inst=assert(M.new(data,{image=function()return texture end,white=function()return texture end,
 read=function()return string.rep('\0',96)end}))
 return inst,data
end
local a,data=make('MATERIAL','MATERIAL','UNLIT')
local v=a.meshes[1].vertices[1]
assert(v[7]==.2 and v[8]==.3 and v[10]==.6 and v[6]==1,'material-only/unlit was darkened')
assert(a:playContext('attack',false)and a.clip==3,'alternate clip chosen before primary')
a:update(1/30);assert(a:isFinished())
data.clips[4].bones=2
assert(not a:playContext('damage',false)and a.clip==3,'corrupt pose changed valid animation')
local ok=pcall(a.drawWith,a,function()
 assert(wrapS=='clamp'and wrapT=='mirroredrepeat'and filterMin=='linear'and filterMag=='linear')
 error('draw failure')
end,{})
assert(not ok and wrapS=='repeat'and wrapT=='clamp'and filterMin=='nearest'and filterMag=='linear'and aniso==2,'shared texture sampler leaked')
local b=make('VERTEX','VERTEX','UNLIT');v=b.meshes[1].vertices[1]
assert(v[7]==.5 and v[10]==.5,'vertex source multiplied by material')
local c=make('BOTH','BOTH','UNLIT');v=c.meshes[1].vertices[1]
assert(v[7]==.1 and v[10]==.3,'combined source lost multiplication')
a:release();b:release();c:release()
print('PASS XD source color/alpha, unlit, primary animation, pose validation and shared sampler restoration')
