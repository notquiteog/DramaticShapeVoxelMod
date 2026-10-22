local checks=0
local function check(q,msg)assert(q,msg);checks=checks+1 end
local modules={SceneryMask=dofile('lib/SceneryMask.lua'),BuildBudget={check=function()end},
 Gen3Civic={ground=function(c)return c.floorMid or 1 end},Gen3Furniture={groundAt=function(c)return c.prop.recipe.ground end}}
local C=assert(loadfile('lib/NativeSceneryCards.lua'))({require=function(n)return assert(modules[n],n)end})
local ground={.2,.6,.3,1};local ink={.8,.7,.5,1};local atlasIdentity={}
local ts={cols=8,rows=1,midToSlot={[1]=0,[2]=1,[3]=2,[4]=3,[5]=4},image=atlasIdentity,overImage={}}
ts.imageData={getPixel=function(_,x,y)
 local slot=math.floor(x/16);if slot==0 then return unpack(ground)end
 local xx=(slot-1)%2*16+x%16;local yy=math.floor((slot-1)/2)*16+y
 if xx>=4 and xx<28 and yy>=3 and yy<30 and not(xx==11 and yy==11)then return unpack(ink)end
 return unpack(ground)
end}
local g={cx=3,cy=4,rows={{2,3},{4,5}},width=2,depth=2,ts=ts,groundHeight=3};local cells={}
for y=0,1 do for x=0,1 do cells[(3+x)..':'..(4+y)]={cx=3+x,cy=4+y,mid=g.rows[y+1][x+1],ts=ts,civic=g,base=3,collision=x==1 and y==1 and 0x71 or 7}end end
local card=assert(C.prepareCivic(g,cells));check(card.pixels==24*27,'enclosed matching floor-color pixel lost');check(#card.segments==1 and card.segments[1].bottom==32)
check(card.base==3 and card.w==32 and card.h==32);check(not g.nativeSceneryCard,'preparation claimed source')
local function uvFor(t,mid)
 local s=t.midToSlot[mid];if not s then return end
 return{{s/8,0},{(s+1)/8,0},{(s+1)/8,1},{s/8,1}}
end
local n=0;check(C.append(card,function(p,uv,shade)
 n=n+1;check(shade==1,'native source shaded twice')
 for _,v in ipairs(p)do check(v[1]>=48 and v[1]<=80 and v[3]>=64 and v[3]<96,'card outside native owned footprint');check(v[2]>=0 and v[2]<=32)end
 for _,v in ipairs(uv)do check(v[1]>=0 and v[1]<=1 and v[2]>=0 and v[2]<=1)end
end,uvFor));check(n>0)
local parts={{existing=true}};local released=0
local part=assert(C.build(card,function(v,i)
 check(v[1][2]>=3 and #i>0);return{release=function()released=released+1 end}
end,parts,uvFor));check(#parts==2 and parts[1].existing and g.nativeSceneryCard==card)
local nextImage={};ts.image=nextImage;local images={};check(C.draw(part,function(_,image)images[#images+1]=image end));check(images[1]==nextImage and images[2]==ts.overImage,'live atlas replacement lost')
C.release(part);check(released==1 and ts.image==nextImage and ts.overImage,'borrowed atlas released')
g.nativeSceneryCard=nil;local failed,why=C.build(card,function()error('test upload failure')end,parts,uvFor)
check(not failed and why:find('test upload failure',1,true)and not g.nativeSceneryCard and #parts==2,'upload failure hid native fallback')
local emitted=0;check(not C.append(card,function()emitted=emitted+1 end,function()return nil end)and emitted==0,'partial UV failure emitted geometry')
local door=assert(C.doorSurface(card,4,5));check(door.w==16 and door.h==32 and door.sourceX==64 and door.sourceY==64 and door.base==3)
check(door.vertices[4][2]==0 and door.vertices[1][3]>80 and door.vertices[1][3]<96,'door left native warp cell')
check(not C.doorSurface(card,3,5),'non-warp source received door overlay')
local cell=cells['3:4'];cell.base=9;check(not C.prepareCivic(g,cells),'uneven ground flattened');cell.base=3
cell.stageHidden=true;check(not C.prepareCivic(g,cells),'hidden source emitted');cell.stageHidden=nil
local mid=cell.mid;cell.mid=999;check(not C.prepareCivic(g,cells),'changed native source drawing accepted');cell.mid=mid
-- Mixed source ownership makes separate native baselines, including two
-- original warp rows. No wing/arch pixels move onto the adjacent walking path.
local owner={};local mixed={};local rows={{2,3,2},{4,5,4},{2,3,2}}
for y=0,2 do for x=0,2 do mixed[x..':'..y]={cx=x,cy=y,mid=rows[y+1][x+1],ts=ts,base=0,collision=y==2-x and 0x71 or 7,prop=y<=2-x and owner or nil}end end
local m=assert(C.prepare({owner=owner,rows=rows,ts=ts,cx=0,cy=0,owns=function(c)return c.prop==owner end},mixed,{mask=function()return true end}))
check(#m.segments==3 and m.pixels==6*256)
check(C.append(m,function(p)
 for _,v in ipairs(p)do local x=math.min(2,math.floor((v[1]-.00001)/16));x=math.max(0,x);check(v[3]>=0 and v[3]<(3-x)*16)end
end,uvFor))
check(C.doorSurface(m,0,2).vertices[1][3]<48);check(C.doorSurface(m,1,1).vertices[1][3]<32)
check(C.doorSurface(m,2,0,{height=16}).vertices[1][3]<16)
local p={cx=3,cy=4,ts=ts,recipe={rows=g.rows,ground=1}};for _,c in pairs(cells)do c.civic=nil;c.prop=p end
check(C.prepareFurniture(p,cells)~=nil);p.recipe.noGround=true;check(not C.prepareFurniture(p,cells),'floor opening folded upright');p.recipe.noGround=nil
for _,c in pairs(cells)do c.prop=nil end
cell.shape={kind='sign',ground=1};check(C.prepareCell(cell,cells)~=nil)
cell.prop={};check(not C.prepareCell(cell,cells),'grouped drawing emitted twice');cell.prop=nil
cell.shape.ground=nil;check(not C.prepareCell(cell,cells),'unknown floor guessed')
local tiny=assert(C.prepareCell(cell,cells,{cellSize=8,mask=function()return true end}));check(tiny.w==8 and tiny.h==8,'generic native cell size lost')
check(not C.prepare({},cells),'malformed source did not retain fallback')
local image=ts.image;ts.image=nil;check(not C.build(tiny,function()error('GPU upload before image availability')end,{},uvFor),'missing GPU atlas hid native fallback');ts.image=image
print('PASS '..checks..' native source-card checks: exact pixels, local floor, enclosed colors, owner fronts/warps, live atlases, upload fallback and configurable cell size')
