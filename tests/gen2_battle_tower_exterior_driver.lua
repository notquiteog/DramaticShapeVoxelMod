-- Isolated Crystal QA: actual scene cameras, complete claim ownership and native warps.
return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'))
 assert(require('src.core.GameVersion').get()==os.getenv('POKEPORT_VERSION'),'wrong imported game')
 local U=dofile('tests/drivers/util.lua');local dir=assert(os.getenv('SHOT_DIR'))
 local inspection
 local viewLock
 local update=game.update;game.update=function(self,dt)
  self.input:reset() -- Ignore physical pad activity during a stationary rendering fixture.
  local result=require('src.mods.Runtime').call('core.update',update,self,dt)
  if viewLock then viewLock()end
  return result
 end
 love.window.setMode(1280,720)
 local V=assert(game.mods.exports.BATTLE_ART_VOXEL_FORK).lib;local gen=V.require('Generation').number()
 local P=require('src.render.Pipelines');local F=V.require('FirstPerson')
 local frame=F.frame;F.frame=function(...)local rig,x,z=frame(...);if rig and inspection then rig.eye=inspection;rig.focus={144,64,72};rig.curve=0 end;return rig,x,z end
 if gen==3 then game:_handleBootAction({action='new_game',start={map=require('src.core.GameVersion').get()=='emerald' and 'EM_OLDALE_TOWN' or 'FR_PALLET_TOWN',x=10,y=9,facing='down'}})end
 V.require('TreePresentation').props:setIndex(1,game)
 local version=require('src.core.GameVersion').get()
 local targets=gen==3 and {{'FR_CELADON_CITY_DEPARTMENT_STORE_3F',6,12},{'FR_CELADON_CITY_DEPARTMENT_STORE_5F',6,12}} or {{'BATTLE_TOWER_OUTSIDE',9,12}}

 for _,p in ipairs(targets)do
  game.input:reset();if game.stack then game.stack:clear()end
  if gen==3 then
   assert(require('src.core.game3.map').load(nil,game,p[1],{x=p[2],y=p[3],facing='up'}));require('src.ui.game3.map_preview_screen').reset()
  elseif gen==2 then
   local w=game.world;w.noWildEncounters=true;w.trySceneScript=function()return false end;assert(w:setMap(p[1],p[2],p[3],'up'));w.vm=nil;w.textbox=nil
  else game.stack:push(require('src.world.OverworldController'),p[1],p[2],p[3],'up')end

  local function nativeGrid()
   local a={}
   if gen==3 then local d=require('src.core.game3.map').currentDef()
    for y=0,d.height-1 do for x=0,d.width-1 do a[#a+1]=d.midLayout:midAt(x,y)..':'..d.midLayout:collAt(x,y)end end
   elseif gen==2 then local m=game.world.map
    for y=0,m.heightCells*2-1 do for x=0,m.widthCells*2-1 do a[#a+1]=m:tileAt(x,y)end end
   end
   if gen==2 then local m=game.world.map;for y=0,m.heightCells-1 do for x=0,m.widthCells-1 do a[#a+1]=m:cellCollision(x,y)end end end;return table.concat(a,',')
  end
  assert(game.world.map:isWalkable(p[2],p[3]),'camera on blocked cell');local original=nativeGrid()
  viewLock=nil
  for _,view in ipairs({{6,0,'overview',{144,170,420}},{6,1.2,'side',{420,160,160}},{6,3.14,'rear',{144,160,-220}},{6,3.14159,'first'}})do
   inspection=view[4]
   if gen==3 then local C=V.require('Gen3Integration');C.setLevel(view[1],game);C.yaw=view[3]=='first' and (0) or view[2];C.pitch=.12
   else P.setLevel('voxel',view[1]);F.yaw=view[3]=='first' and math.pi or view[2];F.pitch=-.25 end
   if gen==3 then local C=V.require('Gen3Integration');local yaw,pitch=C.yaw,C.pitch
    viewLock=function()C.yaw=yaw;C.pitch=pitch end
   else local yaw,pitch=F.yaw,F.pitch;viewLock=function()F.yaw=yaw;F.pitch=pitch end end
   U.wait(view[3]=='overview' and 150 or 25);assert(U.shot(game,dir..'/'..p[1]..'-'..view[3]..'.png'))
  end
  if gen==3 then local C=V.require('Gen3Integration');assert(C.active and not C.lastError,tostring(C.lastError))end
  viewLock=nil
  if gen==3 and p[1]=='FR_ROCKET_HIDEOUT_B4F' then
   local d=require('src.core.game3.map').currentDef();local l=d.midLayout
   local pair=V.require('Gen3Tilesets').canonical(l.pair);local cells={}
   for y=0,d.height-1 do for x=0,d.width-1 do cells[x..':'..y]={cx=x,cy=y,mid=l:midAt(x,y),pair=pair,primary='building',ts={}}end end
   local n=0;for _,prop in ipairs(V.require('Gen3Furniture').extract(cells))do if prop.recipe.design=='fr_processing_machine'then n=n+1 end end
   assert(n==3,'Rocket machine count: '..n);print('[studio] 3 complete processing machines')
  end
  assert(nativeGrid()==original,'presentation changed native layout/collision')
  local built=V.require('Structures').forMap(game.world.map)
  assert(built.gen2BattleTower and built.gen2BattleTower.height==152)
  for y=0,19 do for x=8,27 do local k=(y+64)*4096+x+64
   assert(built.skip[k] and built.ground[k]==6,'claim changed '..x..','..y..' ground='..tostring(built.ground[k]))
  end end
  inspection=nil;viewLock=nil
  for _,cx in ipairs({8,9})do
   assert(game.world:setMap(p[1],cx,10,'up'));game.world.vm=nil;game.world.textbox=nil
   game.world:movePlayer('up');U.wait(120)
   assert(game.world.map.id=='BATTLE_TOWER_1F','native entrance warp failed')
  end
  print('[tower] complete source claims and both native entrance warps PASS')
  print('[specialty]',p[1],'PASS native draw; review images')
 end
 love.event.quit()
end
