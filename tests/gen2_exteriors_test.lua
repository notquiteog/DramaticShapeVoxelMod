local M=dofile('lib/Gen2Exteriors.lua')
local drawing={
 {16,17,17,17,17,17,17,18},{13,14,14,14,14,14,14,15},
 {13,14,14,14,14,14,14,15},{10,11,11,11,11,11,11,12},
 {26,7,7,7,7,7,7,28},{26,7,7,7,7,7,7,28},
 {26,7,55,56,8,9,7,28},{1,2,57,58,23,23,2,22}}
local map={def={width=2,height=2},tileset={id='TILESET_JOHTO',imageWidth=128,imageHeight=128}}
function map:tileAt(x,y)return drawing[y+1] and drawing[y+1][x+1] end
local list=M.placements(map)
assert(#list==1 and list[1].style=='flat_brick' and list[1].roofRows==4)
local S={gen2=true,outdoor=true,skip={},ground={},objectQuads={}}
M.build(S,map);assert(#S.exteriors==1 and #S.objectQuads>0)
local back,front,roof=0,0,0
for _,q in ipairs(S.objectQuads)do
 for _,v in ipairs(q)do assert(v[1]>=-2 and v[1]<=66 and v[2]>=0 and v[2]<=33.25 and v[3]>=-2 and v[3]<=66)end
 if q[1][3]==0 and q[2][3]==0 and q[1][2]<=32 then back=back+1 end
 if q[1][3]>=64 and q[2][3]>=64 and q[1][2]<=32 then front=front+1 end
 if q[1][2]==33.2 and q[2][2]==33.2 and q[3][2]==33.2 then roof=roof+1 end
end
assert(back>=32 and front>=32 and roof==64,'incomplete square brick shell')
assert(drawing[7][5]==8 and drawing[8][3]==57,'native sign/door mutated')
drawing[8][8]=5;assert(#M.placements(map)==0,'incomplete facade swallowed grass')
drawing[8][8]=22;map.tileset.id='TILESET_LAB';assert(#M.placements(map)==0,'interior tile IDs became an exterior')
drawing={{5,6,7,7,7,7,8,9},{21,22,23,23,23,23,24,25},
 {37,38,10,10,10,10,40,41},{92,95,95,95,95,95,95,93},
 {15,34,34,34,34,34,34,31},{29,26,26,26,26,26,26,60}}
map.tileset.id='TILESET_KANTO'
local houses=M.placements(map)
assert(#houses==1 and houses[1].roofRows==4,'dormer counted as another storey')
S={gen2=true,outdoor=true,skip={},ground={},objectQuads={}}
M.build(S,map)
local lowWall,dormer=false,false
for _,q in ipairs(S.objectQuads)do
 for _,v in ipairs(q)do assert(v[2]<=32.05,'Kanto house has an extra floor')end
 if q[1][3]==48 and q[1][2]==16 then lowWall=true end
 if q[1][3]==48 and q[1][2]==32 and q[1][1]==16 then dormer=true end
end
assert(lowWall and dormer,'roof window band was erased or raised as a wall')
print('PASS complete Crystal brick facade, flat roof, all four closed walls, preserved sign/door and incomplete/interior rejection')
