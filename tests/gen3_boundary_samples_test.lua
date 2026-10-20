local calls=0
package.loaded['src.import.gba.versions']={TILESET_PAIRS={}}
package.loaded['src.core.game3.collision']={isSurfable=function(b)return b==1 end,behaviorOn=function()return 0 end}
local select=dofile('lib/BoundaryScenery.lua')
local shape={of=function(_,_,mid)calls=calls+1;return {kind=mid==1 and 'tree' or 'cliff',ground=3}end}
local B=assert(loadfile('lib/Gen3Boundary.lua'))({require=function(n)
 if n=='BoundaryScenery'then return select elseif n=='Gen3TileShape'then return shape end
 assert(n=='Gen3Tilesets');return {resolve=function()return {primary='general'}end}
end})
local r={x=0,y=0,w=16,h=16,def={midLayout={pair='p',midAt=function(_,x,y)return (x+y)%2+1 end}}}
local baseline={}
for y=-8,23 do for x=-8,23 do if x<0 or y<0 or x>15 or y>15 then
 local mid,p,s,kind=B.resolve({r},x,y);baseline[x..':'..y]={mid,p,s.kind,kind}
end end end
local uncached=calls;calls=0;r.boundaryCache=nil
local read=B.sampler()
for y=-8,23 do for x=-8,23 do if x<0 or y<0 or x>15 or y>15 then
 local mid,p,s,kind=B.resolve({r},x,y,read);local a=baseline[x..':'..y]
 assert(mid==a[1]and p==a[2]and s.kind==a[3]and kind==a[4],'cached donor changed native perimeter')
end end end
assert(calls<uncached/2,'overlapping edge strips were repeatedly classified')
local first=calls;local fresh=B.sampler();fresh(r,0,0)
assert(calls==first+1,'new build reused stale classification')
print('PASS identical native perimeter selection; classifications '..uncached..' -> '..first)

-- Connected providers may omit def.id; retain public world entry IDs so
-- optional forest/safari overrides resolve the actual owning map.
local primary={midLayout={width=10,height=8}}
local neighbor={midLayout={width=6,height=9}}
local world={{id='FR_VIRIDIAN_FOREST',def=neighbor,ox=10,oy=0}}
local regions=B.regions(primary,world,'FR_ROUTE_2')
assert(regions[1].mapId=='FR_ROUTE_2'and regions[2].mapId=='FR_VIRIDIAN_FOREST')
assert(B.regions(primary,world,'FR_ROUTE_2')==regions,'unchanged map identities discarded region cache')
local changed=B.regions(primary,world,'FR_ROUTE_2_ALIAS')
assert(changed~=regions and changed[1].mapId=='FR_ROUTE_2_ALIAS','map identity change reused stale owner metadata')
print('PASS connected owner map identities without native def.id and stable identity-aware region reuse')
