local C=assert(loadfile('lib/Gen3Civic.lua'))()
local recipe;for _,r in ipairs(dofile('data/gen3_exteriors.lua'))do if r.name=='one_island_center'then recipe=r end end
assert(recipe and #recipe.claimOutside==1)
local function fixture()
 local cells={}
 for y,row in ipairs(recipe.rows)do for x,mid in ipairs(row)do cells[(x-1)..':'..(y-1)]={cx=x-1,cy=y-1,primary='general',pair=recipe.pair,mid=mid,collision=y==6 and x==4 and 113 or 7,base=16,ts={}}end end
 cells['2:6']={cx=2,cy=6,primary='general',pair=recipe.pair,mid=721,collision=0,base=16}
 -- A native sign/grass/cliff strip shares that same row; none can be claimed.
 for _,x in ipairs{0,1,3,4,5,6}do cells[x..':6']={cx=x,cy=6,primary='general',pair=recipe.pair,mid=x==4 and 2 or 16,collision=0,base=16,prop=x==4 and{}or nil,shape={kind='flat'}}end
 return cells
end
local cells=fixture();local groups=C.prepare(cells,{}, {recipe});assert(#groups==1)
local g=groups[1];assert(g.depth==6 and g.width==7 and #g.rows==6,'claim expanded authoritative foundation/body rectangle')
assert(cells['2:6'].civic==g and C.ground(cells['2:6'])==16 and #g.claimedOutside==1)
for _,x in ipairs{0,1,3,4,5,6}do assert(not cells[x..':6'].civic,'adjacent native ground/sign was stolen')end
for k,v in pairs{mid=720,collision=7,pair='other',prop={},civic={},stageHidden=true,boundary=true}do
 cells=fixture();cells['2:6'][k]=v;assert(#C.prepare(cells,{}, {recipe})==0,'unknown outside art/permission must stand down')
 assert(not cells['0:0'].civic,'refused outside claim left partial body ownership')
end
cells=fixture();cells['2:6']=nil;assert(#C.prepare(cells,{}, {recipe})==0)
print('PASS atomic exact outside-pillar ownership, unchanged body/foundation rectangle and adjacent native sign/grass/permission isolation')
