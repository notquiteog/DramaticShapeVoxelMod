local G=dofile('lib/Gen3PropGround.lua')
local function cell(x,y,mid,collision)
 return {cx=x,cy=y,mid=mid,collision=collision or 0,pair='general__rustboro',primary='general',base=0,
  shape={kind=mid==3 and'sign'or'flat',hoenn=mid==3,ground=mid==3 and 1 or nil}}
end
local function fixture(x,y,h,v)
 local c=cell(x,y,3,7);local cells={[x..':'..y]=c};local offsets={-3,-2,-1,1,2,3}
 for i,d in ipairs(offsets)do
  local a=h[i];if a then cells[(x+d)..':'..y]=cell(x+d,y,a[1],a[2])end
  local b=v[i];if b then cells[x..':'..(y+d)]=cell(x,y+d,b[1],b[2])end
 end
 return cells,c
end
-- Metadata from official .95 imported R/S/E maps, identical across editions.
-- Each sign is MID3/collision7. The full six-cell strips retain source IDs;
-- facades and two-row pavement borders must not be flattened into the donor.
local cases={
 {30,8,{{699,0},{699,0},{699,0},{699,0},{699,0},{699,0}},{{468,7},{484,7},{679,7},{761,0},{777,0},{699,0}}},
 {17,20,{{538,7},{699,0},{699,0},{699,0},{699,0},{768,0}},{{711,7},{711,7},{725,7},{699,0},{699,0},{703,7}}},
 {25,35,{{699,0},{699,0},{699,0},{699,0},{699,0},{699,0}},{{561,7},{570,7},{577,7},{699,0},{699,0},{699,0}}},
 {12,38,{{559,113},{577,7},{579,7},{699,0},{699,0},{614,7}},{{699,0},{699,0},{699,0},{699,0},{761,0},{777,0}}},
 {19,49,{{770,0},{699,0},{699,0},{699,0},{699,0},{699,0}},{{699,0},{761,0},{777,0},{699,0},{699,0},{699,0}}},
}
for _,spec in ipairs(cases)do
 local cells,c=fixture(unpack(spec));local before={}
 for key,n in pairs(cells)do before[key]={n.mid,n.collision,n.shape.ground}end
 assert(G.infer(cells,c)==0x2bb,'Rustboro sign still received grass: '..spec[1]..','..spec[2])
 for key,n in pairs(cells)do local b=before[key];assert(n.mid==b[1]and n.collision==b[2]and n.shape.ground==b[3],'native source was mutated')end
end
assert(not G.boardOnly(nil),'missing source should not admit inference')
local function indexed(value)
 return 'SVMI'..string.char(1,2,1,0,1,0,1,0,3,0)..string.rep(string.char(value),256)
end
assert(not G.boardOnly({idxBlob=indexed(45),overBlob=indexed(0)}),'genuine grass in source sign was discarded')
assert(not G.boardOnly({idxBlob=indexed(19),overBlob=indexed(0)}),'changed source board pattern was inferred')
assert(not G.boardOnly({idxBlob=indexed(19),overBlob=indexed(45)}),'new source over-layer was discarded')

local missingCells,missing=fixture(unpack(cases[1]))
assert(G.resolve(missingCells,missing)==nil and G.ground(missingCells,missing)==1,'unverified source art was replaced')
local same={{1,0},{1,0},{1,0},{1,0},{1,0},{1,0}}
local empty={}
local cells,c=fixture(7,8,same,empty)
assert(G.ground(cells,c)==1,'grass sign was repaved')
local alternating={{20,0},{21,0},{20,0},{20,0},{21,0},{20,0}}
cells,c=fixture(7,8,alternating,empty)
assert(G.infer(cells,c)==21,'alternating native floor phase was lost')
-- Equal immediate donors alone cannot establish the phase under a prop.
cells,c=fixture(7,8,{false,false,{20,0},{20,0}},empty)
assert(G.resolve(cells,c)==nil and G.ground(cells,c)==1)
-- Two proven but contradictory axes mark a material junction; do not guess.
local paving={{699,0},{699,0},{699,0},{699,0},{699,0},{699,0}}
cells,c=fixture(7,8,same,paving)
assert(G.resolve(cells,c)==nil and G.ground(cells,c)==1)
-- Missing/streamed, altered, raised, cross-pair and provider-owned neighbors
-- are not witnesses for native ground continuity.
for _,mutate in ipairs{
 function(n)n.pair='general__petalburg'end,
 function(n)n.base=6 end,
 function(n)n.boundary='ground'end,
 function(n)n.prop={}end,
 function(n)n.civic={}end,
 function(n)n.behavior=0x60 end,
 function(n)n.region={mapId='other'}end,
}do
 cells,c=fixture(7,8,paving,empty);c.region={mapId='current'}
 for _,n in pairs(cells)do if n~=c then mutate(n)end end
 assert(G.infer(cells,c)==nil,'unsafe ground witness was used')
end
cells,c=fixture(7,8,paving,empty);c.ts={midToSlot={[1]=1}}
assert(G.infer(cells,c)==nil,'missing native material was invented')
cells,c=fixture(7,8,paving,empty);c.shape.hoenn=false
assert(G.resolve(cells,c)==nil and G.ground(cells,c)==1,'FRLG sign behavior changed')
c.shape.hoenn=true;c.mid=0x34d;c.shape.kind='fence'
assert(G.resolve(cells,c)==nil,'unreviewed fence family was inferred')
print('PASS source prop ground: five native RSE Rustboro signs, grass, alternating phase, material junctions, edge/source ownership and no mutation')

local sand={{0x124,0},{0x124,0},{0x124,0},{0x124,0},{0x124,0},{0x124,0}}
for _,edition in ipairs{'emerald','ruby','sapphire'}do
 local field,c=fixture(10,10,sand,{})
 c.pair='general__dewford'
 for _,n in pairs(field)do n.pair=c.pair;if n~=c then n.behavior=33 end end
 assert(G.infer(field,c)==0x124,'Dewford sand rejected for '..edition)
 for _,n in pairs(field)do if n~=c then n.mid=0x125 end end
 assert(not G.infer(field,c),'unreviewed special sand drawing borrowed')
end
print('PASS reviewed RSE plain-sand sign strips without unsafe behavior broadening')
