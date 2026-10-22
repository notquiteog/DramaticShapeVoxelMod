local W=dofile('lib/Gen3Water.lua')
local function key(x,y)return x..':'..y end
local function near(a,b)assert(math.abs(a-b)<1e-8,tostring(a)..' != '..tostring(b))end
local function names(b)return({[21]='OCEAN_WATER',[19]='WATERFALL'})[b]end
local function options(regions)return{region='hoenn',outdoor=true,behaviorName=names,regions=regions}end
local function water(x,y,base,floor,layer,mid)
 return{cx=x,cy=y,base=base,mid=mid or 0x170,collision=floor and 41 or 7,elevation=layer,
  pair='general__rustboro',behavior=21,shape={kind='water'},
  floor={x=x,y=y,height=base,floor=floor,kind='water',layer=layer,mid=mid or 0x170,behavior=21}}
end
-- Actual thirteen Route104 blocked-ocean cells assigned terrace support6 in
-- all three imported R/S/E floor fields. The native dock fringe links them to
-- real surf-floor335/276 south of the jetty, whose authoritative datum is0.
local source={{9,47,0x145},{9,48,0x12b},{10,48,0x12c},{11,48,0x12c},
 {12,48,0x12c},{13,48,0x145},{11,49,0x170},{12,49,0x170},{13,49,0x123},
 {11,50,0x170},{12,50,0x170},{13,50,0x12b},{11,51,0x33d,0}}
local cells={};for _,v in ipairs(source)do cells[key(v[1],v[2])]=water(v[1],v[2],6,false,v[4]or 1,v[3])end
cells['11:52']=water(11,52,0,false,0,0x345)
cells['11:53']=water(11,53,0,true,1,0x335)
cells['12:53']=water(12,53,0,true,1,0x276)
local raw={};for k,c in pairs(cells)do raw[k]={c.mid,c.base,c.collision,c.elevation,c.floor,c.floor.height,c.floor.layer}end
local _,plan=W.bind(cells,options());assert(#plan.components==1)
for k,c in pairs(cells)do
 near(W.surface(c),-4);near(plan.cells[k].base,0)
 local b=raw[k];assert(c.mid==b[1]and c.base==b[2]and c.collision==b[3]and c.elevation==b[4]
  and c.floor==b[5]and c.floor.height==b[6]and c.floor.layer==b[7],'native field or permission mutated')
end
-- Full-field planning gives the same result when every real datum anchor is
-- outside the moving scene window. It does not depend on loaded neighbors.
local r={x=0,y=0,w=40,h=80,floorOffset=0,def={midLayout={pair='general__rustboro'}},floorField={cells={}}}
for k,c in pairs(cells)do r.floorField.cells[k]=c.floor end
local crop={['11:49']=cells['11:49']};W.bind(crop,options({r}));near(W.surface(crop['11:49']),-4)
-- Independent real floor heights remain independent, even with a blocked
-- coastal strip between them. Equal-distance ownership follows native order.
local a,b=water(0,0,0,true,1),water(4,0,12,true,1)
local strip={['0:0']=a,['4:0']=b};for x=1,3 do strip[key(x,0)]=water(x,0,6,false,1)end
local f=W.plan(strip,options());near(f.cells['1:0'].surface,-4);near(f.cells['2:0'].surface,-4);near(f.cells['3:0'].surface,8)
assert(#f.components==2 and a.base==0 and b.base==12)
-- A different collision layer, disconnected body, waterfall, explicit level,
-- preserved surface, boundary fill or native underpass cannot borrow a datum.
for _,mode in ipairs{'layer','disconnected','waterfall','level','preserve','boundary','underpass'}do
 local seed=water(0,0,0,true,1);local c=water(1,0,6,false,1)
 if mode=='layer'then c.floor.layer=2
 elseif mode=='disconnected'then c.cx=3;c.floor.x=3
 elseif mode=='waterfall'then c.behavior=19
 elseif mode=='level'then c.shape.waterLevel=9
 elseif mode=='preserve'then c.shape.preserveWaterLevel=true
 elseif mode=='boundary'then c.boundary='water'
 elseif mode=='underpass'then c.underpass=true end
 local p=W.plan({['0:0']=seed,[key(c.cx,0)]=c},options());local n=p.cells[key(c.cx,0)]
 near(n.base,6);near(n.surface,mode=='level'and 9 or(mode=='waterfall'or mode=='preserve')and 6.05 or 2)
end
-- Old/extension fields lacking explicit native floor flags retain their own
-- datum. A known blocked ocean with no reachable surf-floor anchor also does.
local unknown=water(1,0,6,false,1);unknown.floor.floor=nil
local unanchored=water(8,0,6,false,1)
local p=W.plan({['0:0']=water(0,0,0,true,1),['1:0']=unknown,['8:0']=unanchored},options())
near(p.cells['1:0'].surface,2);near(p.cells['8:0'].surface,2)
print('PASS native Route10413-cell ocean datum, full-field streaming, distinct real heights/layers, authored/waterfall/underpass/boundary standdown and immutable native fields')
