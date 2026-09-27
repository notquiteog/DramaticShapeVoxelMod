local field={cells={['1:0']={height=60},['2:2']={height=72,high=78}}}
local modules={Gen3Tilesets={resolve=function()return{primary='general',secondary='cave'}end},
 Gen3Elevation={field=function()return field end},Gen2Elevation={field=function()return field end}}
package.loaded['src.import.gba.versions']={TILESET_PAIRS={}}
local M=assert(loadfile('lib/InteriorDiorama.lua'))({require=function(n)return assert(modules[n],n)end})
for gen=1,3 do
 local def={tileset='CAVERN',environment='CAVE',mapType=4,width=4,height=4,warps={{x=1,y=0}},
  midLayout={pair='cave',cellAt=function(_,x,y)return{coll=y==0 and 0 or 7}end}}
 local map={def=def,isWalkableCell=function(_,x,y)return y==0 end}
 local p=assert(M.forMap(map,gen));assert(p.cave and p.theme=='cave')
 assert(not M.camera(p,.6,16/9),'cave stole the scrolling camera')
 assert(p.bounds[1]==0 and p.bounds[2]==0,'cave padding incorrectly trimmed')
 if gen~=1 then assert(p.height==142,'ceiling intersected a raised platform')end
 assert(#p.passages[1]==1 and #p.passages[2]==0,'boundary exit sealed or invented')
 local floor=gen==1 and 0 or 60
 local wall,indices=M.geometry(p,1,false);assert(#indices>0)
 for i=1,#wall,4 do local q=wall[i];local cx=(q[1]+wall[i+2][1])/2;local y=(q[2]+wall[i+2][2])/2
  assert(not(cx>16 and cx<32 and y>floor and y<floor+32),'stone face fills exit opening')
 end
 for side=1,6 do local v=assert(M.geometry(p,side,false));assert(#v>0)
  for _,q in ipairs(v)do assert(q[2]>=-4 and q[2]<=p.height)end
 end
 for side=1,4 do for _,q in ipairs(M.geometry(p,side,true))do assert(q[2]<=0,'cutaway hides the map')end end
end
assert(not M.profile({tileset='OVERWORLD',width=8,height=8},1))
assert(not M.profile({environment='ROUTE',width=8,height=8},2))
assert(not M.profile({mapType=1,width=8,height=8},3))
assert(M.profile({environment='CAVE',tileset='TILESET_ICE_PATH',width=8,height=8},2).theme=='ice')
print('PASS all-generation cave walls, terrace clearance, boundary passages, cutaway and outdoor exclusion')
