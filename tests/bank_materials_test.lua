local V={mod={read=function()return'original PNG'end}}
local B=assert(loadfile('lib/BankMaterials.lua'))(V)
local S=assert(loadfile('lib/ShoreBanks.lua'))()
package.loaded['src.core.game3.mb']={nameOf=function(b)return({[16]='POND_WATER',[21]='OCEAN_WATER'})[b]end}
local pond={water={behavior=16,base=0,waterSurface=-20/9,shape={kind='water'}}}
local sea={water={behavior=21,base=0,waterSurface=-4,shape={kind='water'}}}
assert(B.key('hoenn',pond)=='hoennRiver'and B.key('hoenn',sea)=='hoennSea')
pond.water.waterSurface=-4;assert(B.key('hoenn',pond)=='hoennSea','connected coastal sheet lost its material')
pond.water.waterSurface=-20/9
assert(B.key('kanto',pond)=='kanto'and B.key('unknown',pond)==nil)
local stone={land={shape={kind='cliff'}},water=sea.water}
local stoneUV=B.uv('hoenn',stone);local grassyUV=B.uv('hoenn',sea)
assert(stoneUV[4][2]==36.5/128 and stoneUV[1][2]==grassyUV[1][2],'bare cliff invented a lower grass rim')
for _,key in ipairs{'kanto','hoennRiver','hoennSea'}do
 local uv=assert(B.uv(key));assert(#uv==4)
 assert(uv[1][2]>uv[4][2]and uv[2][1]>uv[1][1],'bank dirt/rim orientation reversed')
 for _,p in ipairs(uv)do assert(p[1]>0 and p[1]<1 and p[2]>0 and p[2]<1)end
end
assert(S.material({mid=2,shape={kind='flat'}})==2)
assert(S.material({mid=3,shape={kind='interiorFloor'}})==3)
assert(S.material({mid=4,shape={kind='flowers'}})==nil,'flower art became a solid wall')
assert(S.material({mid=5,shape={kind='furniture'}})==nil,'furniture facade became a solid wall')
local files,loads,releases=0,0,0
love={filesystem={newFileData=function()return{release=function()files=files+1 end}end},graphics={newImage=function()
 loads=loads+1;return{setFilter=function()end,setWrap=function()end,release=function()releases=releases+1 end}
end}}
local image=assert(B.image('kanto'));assert(B.image('kanto')==image and loads==1 and files==1)
assert(B.image('hoenn',pond)and B.image('hoenn',sea)and loads==3)
B.release();assert(releases==3)
V.mod.read=function()return nil end;assert(not B.image('kanto'))
V.mod.read=function()return'original PNG'end;assert(B.image('kanto')and loads==4,'late texture did not retry')
assert(not B.register('bad',{path='x',width=16,height=16,rect={0,0,17,8}}))
assert(B.register('custom',{path='own-bank.png',width=16,height=16,rect={.5,.5,15.5,15.5}}))
local authored={land={shape={bankMaterial='custom'}}}
assert(B.key('kanto',authored)=='custom'and B.image('kanto',authored))
assert(B.register('custom',{path='own-bank2.png',width=16,height=16,rect={.5,.5,15.5,15.5}}))
assert(releases==3,'live scene bank texture released during registration')
assert(B.image('kanto',authored))
B.release();assert(releases==6)
print('PASS source dirt/rim UV orientation, connected coastal material, safe native flat-floor fallback, shared images/late retry/release and third-party overrides')
