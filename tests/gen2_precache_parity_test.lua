-- Predictive warm-up uses each engine's real warp and map graph APIs.
local requested,loaded,masks,cancelled
local mesher={cancelSpeculative=function(id)cancelled=id end,pending=function()return 0 end,peek=function()return true end,
 slotKnown=function()return true end,request=function(map,_,m)requested=map;masks=m end}
local V={require=function(n)
 if n=='ChunkMesher'then return mesher elseif n=='VoxelMeshDisk'then return{staticEligible=function()return true end}
 elseif n=='RamPrecache'then return{off=function()return false end}
 elseif n=='VoxelScene'then return{}end;error(n)
end}
local from={id='TOWN',def={width=5,height=4,warps={{x=2,y=2,destMap='WRONG',destWarp=255}},connections={west={map=3,mapId='ROUTE'}}}}
local maps={TOWN=from.def,ROUTE={width=8,height=4},UPSTAIRS={width=3,height=3}}
local world={map=from,maps=maps,player={cellX=0,cellY=2},resolveWarp=function()return 'UPSTAIRS',1 end,
 connectionMap=function(_,id)loaded=id;return{id=id,def=maps[id]}end}
package.loaded['src.world.gen2.World']={computeNeighbors=function(m,id,hops)
 assert(m==maps and hops==2);return{{id='TOWN',ox=256,oy=0}}
end}
package.loaded['src.world.Warp']={destination=function()error('Gen1 warp resolver used for Gen2')end}
package.loaded['src.world.MapLoader']={load=function()error('Gen1 map loader used for Gen2')end}
local P=assert(loadfile('lib/VoxelPrecache.lua'))(V)
local data={maps=maps};local c=P.candidates(data,world)
assert(#c==2 and c[1].id=='ROUTE' and c[2].id=='UPSTAIRS','missing native mapId connection or dynamic warp')
P.update({world=world,data=data})
assert(loaded=='ROUTE' and requested.id=='ROUTE','Gen2 collision map not used for warmup')
assert(masks[1][1]==256 and masks[1][3]==416,'native connection mask lost')
local all=P.allJobs(data);local body={};for _,job in ipairs(all)do if job.bodyOnly then body[job.id]=true end end
assert(body.TOWN and body.ROUTE and not body.UPSTAIRS,'Gen2 body job discovery wrong')
world.map={id='UPSTAIRS',def=maps.UPSTAIRS};P.update({world=world,data=data})
assert(cancelled=='ROUTE','leaving area retained unrelated speculative work')
print('PASS Gen2 native warp, connection graph, map loader, border masks and precache discovery')
