-- Native GB/GBC shoreline depth, camera/actor support, fallback and Surf review.
-- Disposable isolated profiles. Surf flags are a documented fixture setup;
-- the subsequent water movement uses the native engine input/controller.
return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'))
 local U=dofile('tests/drivers/util.lua');local ed=require('src.core.GameVersion').get()
 assert(require('src.core.Version').engine=='0.3.91')
 local V=assert(game.mods.exports.BATTLE_ART_VOXEL_FORK).lib;local gen=V.require('Generation').number()
 local P=require('src.render.Pipelines');local F=V.require('FirstPerson')
 local R,M,W,S=V.require('Voxel3D'),V.require('ChunkMesher'),V.require('GBWater'),V.require('VoxelScene')
 local dir=assert(os.getenv('SHOT_DIR'));local Json=require('src.link.Json')
 local update=game.update;game.update=function(self,dt)return require('src.mods.Runtime').call('core.update',update,self,dt)end
 assert(love.window.setMode(1280,720,{vsync=0,resizable=false}))
 V.require('AntiAlias').setting:sync(0);V.require('SpatialUpscale').setting:sync(1);V.require('WorldCurve').setting:sync(0)
 V.require('RenderDistance').setting:sync(16);V.require('DayNight').setting:sync(os.getenv('QA_DAYTIME')or'day');V.require('Weather').setting:sync('clear');V.require('KantoFirstPerson').sky:sync(false)
 local report={engine='0.3.91',edition=ed,renderer={love.graphics.getRendererInfo()},cases={},hashes={}}
 assert(table.concat(report.renderer,' '):lower():find('nvidia',1,true))
 for _,n in ipairs{'GBWater','TileShape','ChunkMesher','VoxelScene','BattleScene','BattleRaft','WaterFooting','BankMaterials','SurfCamera'}do
  local b=assert(V.mod:read('lib/'..n..'.lua'));report.hashes[n]=love.data.encode('string','hex',love.data.hash('sha256',b))
 end
 for _,m in ipairs(game.mods:status().loaded)do assert(m.id=='BATTLE_ART_VOXEL_FORK','unexpected companion')end
 local function enter(id,x,y,facing)
  P.setLevel('voxel',0);game.input:reset()
  if gen==1 then U.teleport(game,id,x,y,facing)
  else game.stack:clear();assert(game:startWorld());assert(game.world:warpToMapId(id,x,y,facing))end
  U.wait(25);local world=gen==1 and game.overworld or game.world;assert(world.map.id==id)
  if game.options then game.options.zoom=0 end;require('src.render.Zoom').reset();if gen==2 then world:zoomStep(0)end;U.wait(3)
  return world
 end
 local id=gen==1 and'PALLET_TOWN'or'CHERRYGROVE_CITY';local world=enter(id,8,8,'down');local map=world.map
 local best,spot;local dirs={{0,-1,'up',math.pi},{1,0,'right',math.pi/2},{0,1,'down',0},{-1,0,'left',math.pi*1.5}}
 for y=2,map.heightCells-3 do for x=2,map.widthCells-3 do
  if map:isWalkableCell(x,y)and not map:isWaterCell(x,y)and not(world.npcAtCell and world:npcAtCell(x,y))then
   for _,d in ipairs(dirs)do if map:isWaterCell(x+d[1],y+d[2])then
    local n=0;for yy=y-4,y+4 do for xx=x-4,x+4 do if map:isWaterCell(xx,yy)then n=n+1 end end end
    local score=n-((x-map.widthCells/2)^2+(y-map.heightCells/2)^2)*.001
    if not best or score>best then best,spot=score,{x,y,d}end
   end end
  end
 end end
 assert(spot,'no native shoreline');world=enter(id,spot[1],spot[2],spot[3][3]);map=world.map
 report.map=id;report.land={spot[1],spot[2]};local wx,wy=spot[1]+spot[3][1],spot[2]+spot[3][2];report.water={wx,wy}
 local function digest()
  local a={};for y=0,map.heightCells*2-1 do for x=0,map.widthCells*2-1 do a[#a+1]=map:tileAt(x,y)end end
  for y=0,map.heightCells-1 do for x=0,map.widthCells-1 do a[#a+1]=tostring(map:isWaterCell(x,y))..':'..tostring(map:isWalkableCell(x,y));if map.cellCollision then a[#a+1]=map:cellCollision(x,y)end end end
  return love.data.encode('string','hex',love.data.hash('sha256',table.concat(a,';')))
 end
 report.nativeBefore=digest()
 local function settle()
  local stable=0;for _=1,2400 do U.wait(1);if M.pending()==0 then stable=stable+1 else stable=0 end;if stable>=8 then break end end
  assert(stable>=8,'terrain did not settle');U.wait(20)
 end
 local casts={};local begin=R.beginCast;R.beginCast=function(plane)casts[#casts+1]=plane;return begin(plane)end
 local bankDraws=0;local bankImage=V.require('BankMaterials').image('kanto');assert(bankImage)
 local draw=R.draw;R.draw=function(mesh,image,...)if mesh and image==bankImage then bankDraws=bankDraws+1 end;return draw(mesh,image,...)end
 local function sheetHeight(expected)
  local _,mesh=M.pair(map,false);assert(mesh,'native uploaded water mesh missing')
  local count=mesh:getVertexCount();assert(count>0)
  local min,max=math.huge,-math.huge
  for i=1,count do local _,y=mesh:getVertex(i);min=math.min(min,y);max=math.max(max,y)end
  assert(math.abs(min-expected)<.001 and math.abs(max-expected)<.001,'actual uploaded native water Y '..min..'..'..max..' expected '..expected)
  report.cases[#report.cases+1]={gpuVertices=count,minY=min,maxY=max,expected=expected}
 end
 local function shot(name)assert(U.shot(game,dir..'/'..name..'.png'))end
 P.setLevel('voxel',3);V.require('Water').setting:sync('full');settle();sheetHeight(-8);shot('source-profile-before')
 assert(W.surfaceAt(map,wx*16+8,wy*16+8)==-8,'natural sheet is not HGSS -8')
 assert(S.groundAt(map,wx,wy)==-8,'actor/camera support differs from water')
 local config=map.def.voxelWater;map.def.voxelWater=false;M.invalidate(map.id);settle();sheetHeight(-2);shot('legacy-depth-control-35')
 assert(W.surfaceAt(map,wx*16+8,wy*16+8)==-2,'opt-out did not retain legacy sheet')
 map.def.voxelWater=config;M.invalidate(map.id);settle();sheetHeight(-8)
 for _,cam in ipairs{3,6}do
  P.setLevel('voxel',cam);settle();if cam==6 then F.yaw=spot[3][4];F.pitch=.22 end
  for _,mode in ipairs{'full','sky','off'}do
   V.require('Water').setting:sync(mode);casts={};bankDraws=0;U.wait(15)
   assert(bankDraws>0,'source HGSS bank mesh never reached native draw')
   if mode~='off'then for _,plane in ipairs(casts)do assert(plane==-8,'planar cast remained at legacy water height')end end
   report.cases[#report.cases+1]={camera=cam,mode=mode,bankDraws=bankDraws,castCount=#casts,surface=W.surfaceAt(map,wx*16+8,wy*16+8),support=S.groundAt(map,wx,wy)}
   shot('shore-'..cam..'-'..mode)
   if os.getenv('QA_RIPPLE_PAIRS')=='1'and mode=='full'then
    local t=W and V.require('Water')._rippleTime();U.wait(45)
    assert(V.require('Water')._rippleTime()>t+.2,'continuous water phase did not advance')
    shot('shore-'..cam..'-full-phase2')
   end
  end
 end
 -- Native renderer fallback retains closed native bank faces.
 local materials=V.require('BankMaterials');local image=materials.image;materials.image=function()return nil end
 M.invalidate(map.id);settle();shot('missing-soil-texture-fallback-first-person');materials.image=image;M.invalidate(map.id);settle()
 -- Enter Surf through the native Gen2 script special or an explicitly scoped
 -- Gen1 state fixture, then exercise real directional input over native water.
 P.setLevel('voxel',3);settle()
 if gen==2 then assert(world:surfStartStep());U.wait(40)
 else world.player.surfing=true;U.hold(game,spot[3][3],12);U.wait(20)end
 game.input:reset();assert(map:isWaterCell(world.player.cellX,world.player.cellY),'native Surf did not enter water')
 report.surf={world.player.cellX,world.player.cellY};assert(S.groundAt(map,unpack(report.surf))==-8)
 V.require('Water').setting:sync('full');settle();shot('surf-35')
 P.setLevel('voxel',6);settle();F.yaw=spot[3][4];F.pitch=.15;U.wait(8)
 local eye=assert(R.camera and R.camera.eye,'actual first-person rig unavailable')
 assert(eye[2]>-10 and eye[2]<12,'native HD2D Surf selected oversized provider camera '..eye[2])
 assert(math.abs(eye[1]-(world.player.px+8))<5 and math.abs(eye[3]-(world.player.py+8))<5,'first-person Surf eye left native head')
 report.surfEye={eye[1],eye[2],eye[3]};shot('surf-first-person')
 if os.getenv('QA_RIPPLE_PAIRS')=='1'then
  local body=V.require('DayNight').body();if body then
   F.yaw=math.atan2(body.dx,body.dz);F.pitch=.15;U.wait(8);shot('surf-sunward-first-person')
   U.wait(45);shot('surf-sunward-first-person-phase2')
  end
 end
 assert(digest()==report.nativeBefore,'presentation mutated native tiles/collision');report.nativeAfter=digest()
 assert(R.available()and not R.lastShaderError,R.lastShaderError);assert(#game.mods:status().errors==0)
 local f=assert(io.open(dir..'/water-banks-review.json','w'));f:write(Json.encode(report));f:close()
 print('[GB WATER BANKS] PASS',ed,id,'HGSS gap8, soil, full/sky/off, camera, Surf, unchanged native digest');love.event.quit()
end
