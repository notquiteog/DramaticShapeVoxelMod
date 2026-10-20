-- Native Gen1/Gen2 source-mask and imported ORAS grass review.
-- Runs in an isolated *-qa profile; all fixture edits are presentation only.
return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'))
 local U=dofile('tests/drivers/util.lua');local ed=require('src.core.GameVersion').get()
 assert(require('src.core.Version').engine=='0.3.91')
 local V=assert(game.mods.exports.BATTLE_ART_VOXEL_FORK).lib
 local gen=V.require('Generation').number();assert(gen==1 or gen==2)
 local P=require('src.render.Pipelines');local F=V.require('FirstPerson')
 local R,M,G=V.require('Voxel3D'),V.require('ChunkMesher'),V.require('GrassModels')
 local S=V.require('Structures');local Json=require('src.link.Json');local dir=assert(os.getenv('SHOT_DIR'))
 local update=game.update;game.update=function(self,dt)return require('src.mods.Runtime').call('core.update',update,self,dt)end
 assert(love.window.setMode(1280,720,{vsync=0,resizable=false}))
 V.require('AntiAlias').setting:sync(0);V.require('SpatialUpscale').setting:sync(1);V.require('WorldCurve').setting:sync(0)
 V.require('RenderDistance').setting:sync(16);V.require('DayNight').setting:sync('day');V.require('Weather').setting:sync('clear')
 V.require('KantoFirstPerson').sky:sync(false)
 local report={engine='0.3.91',edition=ed,generation=gen,renderer={love.graphics.getRendererInfo()},hashes={},cases={}}
 assert(table.concat(report.renderer,' '):lower():find('nvidia',1,true))
 for _,name in ipairs{'lib/Structures.lua','lib/ChunkMesher.lua','lib/VoxelScene.lua','lib/BattleScene.lua','lib/GrassModels.lua','lib/GrassModelData.lua'}do
  local b=assert(V.mod:read(name));report.hashes[name]=love.data.encode('string','hex',love.data.hash('sha256',b))
 end
 for _,m in ipairs(game.mods:status().loaded)do assert(m.id=='BATTLE_ART_VOXEL_FORK','unexpected companion')end
 local function enter(id,x,y,facing)
  P.setLevel('voxel',0);game.input:reset()
  if gen==1 then U.teleport(game,id,x,y,facing)
  else game.stack:clear();assert(game:startWorld());assert(game.world:warpToMapId(id,x,y,facing))end
  U.wait(25);local world=gen==1 and game.overworld or game.world;assert(world and world.map.id==id)
  if game.options then game.options.zoom=0 end;require('src.render.Zoom').reset()
  if gen==2 then world:zoomStep(0)end;U.wait(3);return world
 end
 local id=gen==1 and'ROUTE_1'or'ROUTE_29';local world=enter(id,8,8,'down');local map=world.map
 local best,spot
 for y=2,map.heightCells-3 do for x=2,map.widthCells-3 do
  if map:isGrassCell(x,y)and map:isWalkableCell(x,y)and not(world.npcAtCell and world:npcAtCell(x,y))then
   local n=0;for yy=y-2,y+2 do for xx=x-2,x+2 do if map:isGrassCell(xx,yy)then n=n+1 end end end
   local score=n-((x-map.widthCells/2)^2+(y-map.heightCells/2)^2)*.001
   if not best or score>best then best=score;spot={x,y}end
  end
 end end
 assert(spot,'no native encounter grass fixture');world=enter(id,spot[1],spot[2],'down');map=world.map
 local function nativeHash()
  local t={};for y=0,map.heightCells*2-1 do for x=0,map.widthCells*2-1 do t[#t+1]=tostring(map:tileAt(x,y))end end
  for y=0,map.heightCells-1 do for x=0,map.widthCells-1 do t[#t+1]=tostring(map:isGrassCell(x,y))..':'..tostring(map:isWalkableCell(x,y))end end
  return love.data.encode('string','hex',love.data.hash('sha256',table.concat(t,';')))
 end
 local nativeBefore=nativeHash();report.map=id;report.start={spot[1],spot[2]};report.nativeBefore=nativeBefore
 local function settle()
  local stable=0;for _=1,2400 do U.wait(1);if M.pending()==0 then stable=stable+1 else stable=0 end;if stable>=8 then break end end
  assert(stable>=8,'grass/terrain did not settle');U.wait(25)
 end
 local active,drawCount={},0;local draw=R.draw
 R.draw=function(mesh,...)
  if active[mesh]then drawCount=drawCount+1 end
  return draw(mesh,...)
 end
 local function verify(label,instanced)
  local expected=S.grassPlacements(map);assert(#expected>0)
  local wanted={};local function key(x,y,z)return string.format('%.6f:%.6f:%.6f',x,y,z)end
  for _,p in ipairs(expected)do local k=key(p.x,p.y,p.z);assert(not wanted[k],'duplicate native mask placement');wanted[k]=true end
  local parts=assert(M.grassModels(map),'imported grass unavailable');local count=0;active={}
  for _,part in ipairs(parts)do
   assert(part.mesh and part.image and part.extent==8)
   if instanced~=nil then assert(part.instanced==instanced,'wrong upload backend')end
   for _,p in ipairs(part.positions)do
    local k=key(p[1],p[2],p[3]);assert(wanted[k],'model escaped or duplicated native grass mask');wanted[k]=nil;count=count+1
   end
   assert(#part.positions==part.count);active[part.mesh]=true
  end
  assert(not next(wanted)and count==#expected,'native grass subtile missing')
  assert(not M.grass(map),'old grass cards duplicated imported models')
  drawCount=0;U.wait(8);assert(drawCount>0,'imported model mesh never reached native draw')
  report.cases[#report.cases+1]={label=label,placements=count,parts=#parts,draws=drawCount,instanced=instanced}
  print('[GB GRASS CASE]',ed,label,count,#parts,drawCount)
  return parts,count
 end
 local function shot(name)assert(U.shot(game,dir..'/'..name..'.png'))end
 shot('source-flat')
 P.setLevel('voxel',3);settle();local parts,original=verify('native source mask')
 shot('grass-35')
 P.setLevel('voxel',6);settle();assert(F.engaged()and F.cardBlend()>.99)
 F.pitch=.22
 for j=0,3 do F.yaw=j*math.pi/2;U.wait(8);shot('grass-first-person-'..j)end
 -- Actual native movement while the orbit camera owns no first-person input.
 P.setLevel('voxel',3);settle();local x0,y0=world.player.cellX,world.player.cellY
 local direction
 for _,d in ipairs{{0,1,'down'},{1,0,'right'},{0,-1,'up'},{-1,0,'left'}}do
  local x,y=x0+d[1],y0+d[2]
  if map:isGrassCell(x,y)and map:isWalkableCell(x,y)and not(world.npcAtCell and world:npcAtCell(x,y))then direction=d;break end
 end
 assert(direction,'no native grass walk');U.hold(game,direction[3],12);U.wait(20);game.input:reset()
 assert(world.player.cellX~=x0 or world.player.cellY~=y0,'native movement did not advance')
 report.walk={x0,y0,world.player.cellX,world.player.cellY,direction[3]};shot('native-walk')
 -- Exercise the same immediate presentation edit native Cut dispatches. The
 -- source map/collision itself is untouched; rebuild restores the exact mask.
 local bx,by=math.floor(world.player.cellX/2),math.floor(world.player.cellY/2)
 local beforeCount=0;for _,p in ipairs(parts)do beforeCount=beforeCount+p.count end
 M.dropBlock(map.id,bx,by);local afterCount=0;for _,p in ipairs(parts)do afterCount=afterCount+p.count end
 assert(afterCount<beforeCount,'Cut presentation failed to remove grass');report.cutHidden=beforeCount-afterCount
 U.wait(8);shot('cut-presentation-rectangle')
 M.invalidate(map.id);settle();verify('source mask restored after Cut presentation');shot('cut-restored')
 if os.getenv('QA_GRASS_FALLBACK')~='0'then
  local image=G.image;G.image=function()return nil,'QA missing asset fixture'end
  M.invalidate(map.id);settle();assert(not M.grassModels(map)and M.grass(map),'missing texture did not restore original grass')
  shot('missing-asset-original-35');P.setLevel('voxel',6);settle();F.yaw=math.pi;F.pitch=.22;shot('missing-asset-original-first-person')
  G.image=image;M.invalidate(map.id);settle();verify('late asset available');shot('asset-restored-first-person')
  local I=V.require('ModelInstances');local available=I.available;I.available=function()return false end
  M.invalidate(map.id);settle();verify('ordinary mesh backend',false);shot('ordinary-mesh-first-person')
  P.setLevel('voxel',3);settle();shot('ordinary-mesh-35');I.available=available
 end
 assert(nativeHash()==nativeBefore,'grass presentation changed native source/gameplay permissions')
 report.nativeAfter=nativeHash();assert(R.available()and not R.lastShaderError,R.lastShaderError)
 assert(#game.mods:status().errors==0,table.concat(game.mods:status().errors,';'))
 local f=assert(io.open(dir..'/grass-review.json','w'));f:write(Json.encode(report));f:close()
 print('[GB IMPORTED GRASS] PASS',ed,original,'native source subtiles','Cut-hidden',report.cutHidden,'walk',unpack(report.walk));love.event.quit()
end
