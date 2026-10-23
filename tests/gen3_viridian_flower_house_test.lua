local modules={SceneryModelData={},ViridianHouseData=dofile('lib/ViridianHouseData.lua'),ModelInstances={},BuildBudget={check=function()end}}
local V={mod={read=function()return nil end}};V.require=function(n)return assert(modules[n],n)end
local S=assert(loadfile('lib/SceneryModels.lua'))(V);modules.SceneryModels=S
local H=assert(loadfile('lib/Gen3ImportedViridianFlowerHouses.lua'))(V)
local D=assert(loadfile('lib/Gen3ViridianFlowerHouseDoors.lua'))(V);modules.Gen3ViridianFlowerHouseDoors=D
local Cards=assert(loadfile('lib/Gen3ViridianFlowerCards.lua'))(V);modules.Gen3ViridianFlowerCards=Cards
local rows={{640,641,642,643,644},{648,649,650,651,652},{656,657,658,659,660},{664,665,666,667,668},{672,206,674,675,676}}
local g={family='viridian_flower_house',pair='viridian_outdoor',width=5,depth=5,cx=24,cy=15,groundHeight=0}
local cells={};for y,row in ipairs(rows)do for x,mid in ipairs(row)do cells[(g.cx+x-1)..':'..(g.cy+y-1)]={civic=g,pair=g.pair,mid=mid,collision=(y==1 or y==5)and 0 or(y==4 and x==2 and 113 or 7),base=0}end end
assert(H.eligible(g,cells));local c=cells['24:15'];c.base=1;assert(not H.eligible(g,cells));c.base=0
c.boundary=true;assert(not H.eligible(g,cells));c.boundary=nil
local door=cells['25:18'];door.collision=7;assert(not H.eligible(g,cells));door.collision=113
assert(H.register());local parts,fit=assert(S.vertices(H.id,{width=80,depth=48,padding=.25,groundInset=.05,anchor='door',targetX=24,targetZ=35.4}))
for _,p in ipairs(parts)do assert(p.role~='source_door'and p.role~='source_shading'and p.role~='ground_shadow');for _,v in ipairs(p.vertices)do assert(v[1]>=.25-1e-6 and v[1]<=79.75+1e-6 and v[3]>=.25-1e-6 and v[3]<=47.75+1e-6)end end
local v,i=Cards.geometry(g,fit);assert(#v==8 and #i==12)
for _,q in ipairs(v)do assert(#q==13 and q[1]>=384.25 and q[1]<=463.75 and q[3]>240 and q[3]<320)end
for state=0,2 do local p=assert(D.geometry(g,fit,state));local count=0;for _,q in ipairs(p)do count=count+#q.indices/3 end;assert(count==8)end
assert(not H.build(g,cells,function()error('missing source door image must retain native model')end,{}));assert(not g.importedViridianFlowerHouse)
-- A flower image/mesh is owned independently from immutable source PNGs.
local released=0;g.importedViridianFlowerImage={release=function()released=released+1 end};Cards.release(g);Cards.release(g);assert(released==1)
local oldLove=love;local disposed=0
love={image={newImageData=function()return{setPixel=function()end,release=function()disposed=disposed+1 end}end}}
local ts={cols=5,midToSlot={},imageData={getPixel=function()return 1,1,1,1 end}};for y,row in ipairs{rows[4],rows[5]}do for x,mid in ipairs(row)do ts.midToSlot[mid]=(y-1)*5+x-1 end end
local rejected,why=Cards.imageData(ts);assert(not rejected and why:find('unreviewed native planter pixels')and disposed==1,'unknown native artwork must keep complete fallback without leaking its temporary atlas');love=oldLove
-- A late native-planter failure unwinds newly uploaded body and source doors,
-- preserving every pre-existing scene part and native fallback ownership.
local bodyReleased,doorsReleased=0,0
D.build=function()return true end;D.release=function()doorsReleased=doorsReleased+1 end
S.buildBatches=function(_,_,opts)opts.parts[#opts.parts+1]={mesh={release=function()bodyReleased=bodyReleased+1 end}};return opts.parts end
Cards.build=function()return false,'unreviewed planter pixels'end
local existing={};local out={existing};local ok,err=H.build(g,cells,function()end,out)
assert(not ok and err=='unreviewed planter pixels'and #out==1 and out[1]==existing and bodyReleased==1 and doorsReleased==1 and not g.importedViridianFlowerHouse)
print('PASS exact Viridian flower-house drawing/permissions, source body/door split, native HD2D card placement, source failure and idempotent owned-texture release')
