local W=dofile('lib/Gen3Water.lua')
local halo={['0:0']={cx=0,cy=0,mid=11,primary='general'},['9:9']={cx=9,cy=9,mid=99,primary='general'}}
local fetched={}
W.complete(halo,{[11]={{},1,1}},function(x,y)fetched[x..':'..y]=true end)
assert(fetched['-1:-1']and fetched['0:-1']and fetched['-1:0']and not fetched['0:0']and not fetched['9:9'])
local cells={}
local function add(x,y,kind,base,mid,shape)
 local c={cx=x,cy=y,pair='native',mid=mid,collision=kind=='water'and 41 or 7,elevation=kind=='water'and 1 or 4,base=base,shape=shape or{kind=kind}}
 cells[x..':'..y]=c;return c
end
for y=0,3 do for x=0,3 do add(x,y,'water',6,0x170)end end
local root=cells['1:1'];local group={root=root,family={rows={{1,2},{3,4}}}}
for y=1,2 do for x=1,2 do local c=cells[x..':'..y];c.shape={kind='rock',seaRock=group,ground=0x2d};c.base=x==1 and 12 or 0 end end
local raw={};for k,c in pairs(cells)do raw[k]={c.mid,c.collision,c.elevation,c.base}end
assert(W.bind(cells)==4)
for y=1,2 do for x=1,2 do local c=cells[x..':'..y];local ground,line=W.underlay(c);assert(ground==0x170 and math.abs(line+c.base-6.05)<1e-9)end end
for k,c in pairs(cells)do local a=raw[k];assert(c.mid==a[1]and c.collision==a[2]and c.elevation==a[3]and c.base==a[4],'native source or physical floor mutated')end
local land=add(7,7,'rock',0,0xe0,{kind='rock',height=14,ground=1});assert(not W.underlay(land))
local wet=add(8,8,'rock',0,0xc5,{kind='rock',wetRock=true,height=6,ground=0x2d});add(8,9,'water',-3,0x170)
W.bind(cells);local ground,line=W.underlay(wet);assert(ground==0x170 and math.abs(line+2.95)<1e-9)
local mesh1,mesh2={},{};local parts={{pair='a',waters={{mesh=mesh1,height=6.05}}},{pair='b',waters={{mesh=mesh2,height=.05}}}}
local draws,levels=W.draws(parts);assert(#draws==2 and #levels==2 and levels[1].height==.05)
local image1,image2={},{};local providers={a={image=image1},b={image=image2}}
assert(W.sync(draws,providers)==draws and draws[1][2]==image1)
providers.a.image={};W.sync(draws,providers);assert(draws[1][2]==providers.a.image and levels[2][1]==draws[1],'live atlas replaced cached provider image or draw lists')
providers.b=nil;W.sync(draws,providers);assert(draws[2][1]==nil,'missing provider kept a stale mesh texture')
providers.b={image=image2};W.sync(draws,providers);assert(draws[2][1]==mesh2)
local samples=0
local ts={cols=1,midToSlot={[4]=0},imageData={getPixel=function(_,x,y)
 samples=samples+1
 if y==0 then return .9,.95,1,1 end -- white native foam is not body color
 if x==0 then return .1,.5,.1,1 end -- native bank remains its own material
 return .3,.5,.8,1
end}}
local tint=assert(W.tint(ts,4));assert(math.abs(tint[1]-.3)<1e-8 and math.abs(tint[3]-.8)<1e-8 and tint[4]<1)
assert(W.tint(ts,4)==tint and samples<272,'native palette scanned every frame')
local absent={cols=1,midToSlot={[4]=0}};assert(not W.tint(absent,4));absent.imageData=ts.imageData;assert(W.tint(absent,4),'late native provider did not recover')
ts.imageData={getPixel=function()return .2,.4,.7,1 end};assert(W.tint(ts,4)~=tint,'replaced native palette retained old color')
local liveR=.2;ts.imageData={getPixel=function()return liveR,.4,.7,1 end}
local beforePatch=W.tint(ts,4);liveR=.3;local afterPatch=W.tint(ts,4)
assert(beforePatch~=afterPatch and math.abs(afterPatch[1]-.3)<1e-8,'in-place native palette edit retained old color')
local batch={};W.note(batch,4);W.note(batch,5);W.note(batch,5);assert(W.dominant(batch.waterMids)==5)
assert(W.dominant({[5]=1,[4]=1})==4,'palette choice depends on table iteration')
local materialParts={{pair='a',waterMid=4,waters={{mesh=mesh1,height=.05}}}}
local materialDraws=W.draws(materialParts);W.sync(materialDraws,{a=ts});assert(materialDraws[1][5]==W.tint(ts,4),'water draw lost native palette')
print('PASS water/rock sheet continuity across native elevations, source immutability, land standdown and stable live-atlas draw grouping')

local _,levels=W.draws({{waters={{mesh='a',height=0,bounds={0,0,0,16,0,16}}}},
 {waters={{mesh='b',height=0,bounds={-16,0,16,0,0,32}},{mesh='c',height=2}}}})
assert(levels[1].bounds[1]==-16 and levels[1].bounds[4]==16 and levels[1].bounds[6]==32)
assert(not levels[2].bounds,'unknown provider water bounds must fail open')
local _,unknown=W.draws({{waters={{mesh='a',height=0},{mesh='b',height=0,bounds={0,0,0,16,0,16}}}}})
assert(not unknown[1].bounds,'partial bounded tileset hid unbounded sheet')
print('PASS full water-plane bounds union and unknown-provider visibility fallback')
