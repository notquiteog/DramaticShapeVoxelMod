-- Isolated QA: walkable station seats retain their native north-edge rule.
return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'))
 assert(require('src.core.GameVersion').get()==os.getenv('POKEPORT_VERSION'))
 local U=dofile('tests/drivers/util.lua');local dir=assert(os.getenv('SHOT_DIR'))
 local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib;local F=V.require('FirstPerson');local P=require('src.render.Pipelines')
 local lock,eye,focus;local frame=F.frame
 F.frame=function(...)local r,x,z=frame(...);if r and eye then r.eye=eye;r.focus=focus;r.curve=0 end;return r,x,z end
 local update=game.update;game.update=function(self,dt)self.input:reset();local r=require('src.mods.Runtime').call('core.update',update,self,dt);if lock then lock()end;return r end
 love.window.setMode(1280,720);V.require('TreePresentation').props:setIndex(1,game)
 local w=game.world;w.noWildEncounters=true;w.trySceneScript=function()return false end
 for _,p in ipairs({{'GOLDENROD_MAGNET_TRAIN_STATION',4,13,64,192,8},{'SAFFRON_MAGNET_TRAIN_STATION',12,13,192,192,10}})do
  game.input:reset();if game.stack then game.stack:clear()end
  assert(w:setMap(p[1],p[2],p[3],'up'));w.vm=nil;w.textbox=nil;local m=w.map;assert(m:isWalkable(p[2],p[3]),'camera blocked '..p[1])
  local function grid()local a={};for y=0,m.heightCells*2-1 do for x=0,m.widthCells*2-1 do a[#a+1]=m:tileAt(x,y)end end;for y=0,m.heightCells-1 do for x=0,m.widthCells-1 do a[#a+1]=m:cellCollision(x,y)end end;return table.concat(a,',')end
  local before=grid();local native=0
  local pattern={{64,65},{66,67}}
  for y=0,m.heightCells*2-2 do for x=0,m.widthCells*2-2 do
   local hit=true;for dy=0,1 do for dx=0,1 do if m:tileAt(x+dx,y+dy)~=pattern[dy+1][dx+1]then hit=false end end end
   if hit then assert(x%2==0 and y%2==0 and m:isWalkable(x/2,y/2),'chair walking intrusion');native=native+1 end
  end end
  assert(native==p[6],'native chair count')
  local cx,cz=p[4]+8,p[5];focus={cx,6,cz+8}
  for _,v in ipairs({{'overview',{cx+22,32,cz+40}},{'side',{cx+35,26,cz+25}},{'rear',{cx,28,cz-20}},{'first'}})do
   eye=v[2];P.setLevel('voxel',6);lock=function()F.yaw=math.pi;F.pitch=.4 end;lock()
   U.wait(v[1]=='overview' and 150 or 25);assert(U.shot(game,dir..'/'..p[1]..'-'..v[1]..'.png'))
  end
  local n=0;for _,f in ipairs(V.require('Structures').forMap(m).furniture or {})do if (f.id=='crystal_depth_station_seat' or f.id=='crystal_station_seat')then n=n+1 end end
  local x=p[2]
  w:movePlayer('up');U.wait(120);assert(w.player.cellX==x and w.player.cellY==12,'native seat entry failed')
  assert(m:cellCollision(x,12)==178,'native north-edge collision changed')
  w:movePlayer('up');U.wait(30);assert(w.player.cellY==12,'native seat north boundary changed')
  w:movePlayer('down');U.wait(15);w:movePlayer('down');U.wait(120);assert(w.player.cellY==13,'native seat return failed')
  assert(n==0 and before==grid());print('[chair]',p[1],n,'native/grid/walkable drawing PASS')
 end
 love.event.quit()
end
