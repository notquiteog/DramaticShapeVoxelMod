package.loaded['src.core.game3.collision']={isSurfable=function()return false end}
local Shape=assert(loadfile('lib/Gen3TileShape.lua'))()
local Wall=dofile('lib/Gen3TowerWalls.lua')
for _,mid in ipairs{0x284,0x285,0x287,0x28e,0x292,0x294}do
 assert(Shape.of('building','rom_082d4efc',mid,0,7).kind=='flat','native green floor became a wall')
end
local cells={}
for x=0,2 do
 local y=x==1 and 2 or 1
 cells[x..':'..y]={cx=x,cy=y,pair='tower',mid=0x2a0,ts={},
  shape=Shape.of('building','rom_082d4efc',0x2a0,0,7),
  column={front=(y+1)*16,last=y}}
end
local function uv(_,mid)
 if mid==0x2a0 then return{{0,0},{.5,0},{.5,1},{0,1}}end
 assert(mid==0x298);return{{.5,0},{1,0},{1,1},{.5,1}}
end
local faces={}
Wall.append(cells,cells['1:2'],function(q,t)faces[#faces+1]=q
 for i,p in ipairs(q)do assert(p[1]>=16 and p[1]<=32 and p[2]>=0 and p[2]<=26)
  assert(p[3]>=28 and p[3]<=48);assert(t[i][1]>=0 and t[i][1]<=1)
 end
end,uv)
assert(#faces==9)
assert(faces[3][1][3]==28,'step return does not reach the adjacent wall')
assert(faces[5][1][2]==26 and faces[5][1][3]==28,'cornice left a gap over return')
-- An unrelated room or a distant segment must not stretch the return.
cells['0:1'].pair='other';cells['2:1']=nil;faces={}
Wall.append(cells,cells['1:2'],function(q)faces[#faces+1]=q end,uv)
assert(faces[3][1][3]==44)
print('PASS Tower native floor exclusions, closed cornices and bounded stepped returns')

local A=dofile('lib/ArchitecturalDetails.lua')
for _,door in ipairs{true,false}do
 local native,standard=0,0
 A.opening(function()native=native+1 end,0,0,12,18,0,{}, {},door,'native')
 A.opening(function()standard=standard+1 end,0,0,12,18,0,{}, {},door)
 assert(native==25 and standard==31,'native glass acquired invented hardware')
end
print('PASS native openings retain their original sash and handle artwork')
