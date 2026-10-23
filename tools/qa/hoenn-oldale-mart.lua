-- Adapter upload/state/rollback QA; final native Scene drawing is separate.
return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'),'QA identity required')
 local U=dofile(assert(os.getenv('QA_UTIL'),'QA_UTIL must name external helper'))
 local V=assert(game.mods.exports.BATTLE_ART_VOXEL_FORK).lib
 local edition=require('src.core.GameVersion').get();local prefix=({emerald='EM_',ruby='RU_',sapphire='SA_'})[edition]
 game:_handleBootAction({action='new_game',start={map=prefix..'PETALBURG_CITY',x=15,y=11,facing='up'}})
 local Map=require('src.core.game3.map');local Pairs=V.require('Gen3Tilesets');local Versions=require('src.import.gba.versions');local Tiles=require('src.core.game3.tileset_native');local Shape=V.require('Gen3TileShape');local Inter=require('src.core.game3.scripting.interaction_scripts')
 V.require('Gen3Integration').setLevel(0,game)
 for _,f in ipairs{{'OLDALE_TOWN',13,3,'oldale_mart'},{'PETALBURG_CITY',24,9,'petalburg_city_mart'},{'RUSTBORO_CITY',15,42,'rustboro_city_mart'}}do
  assert(Map.load(nil,game,prefix..f[1],{x=f[2],y=f[3]+2,facing='up'}));U.wait(2)
  local def=Map.currentDef();local lay=def.midLayout;local spec=Pairs.resolve(lay.pair,Versions.TILESET_PAIRS);local ts=assert(Tiles.get(lay.pair));local region={x=0,y=0,w=def.width,h=def.height,def=def};local cells={}
  for y=0,def.height-1 do for x=0,def.width-1 do local raw=lay:cellAt(x,y);local behavior=(Inter.behaviors[lay.pair]or{})[raw.mid]
   cells[x..':'..y]={cx=x,cy=y,mid=raw.mid,collision=raw.coll,elevation=raw.elev,region=region,ts=ts,pair=Pairs.canonical(lay.pair),primary=spec.primary,secondary=spec.secondary,behavior=behavior,shape=Shape.of(spec.primary,spec.secondary,raw.mid,behavior,raw.coll)}
  end end
  local civics=V.require('Gen3Civic').prepare(cells,V.require('Gen3Buildings').prepare(cells),V.data('gen3_exteriors'))
  Shape.layout(cells);V.require('Gen3Elevation').bind(cells,{region})
  local g;for _,q in ipairs(civics)do if q.custom and q.custom.name==f[4]then g=q end end;assert(g,'missing original Mart')
  local M=V.require('Gen3ImportedMarts');assert(M.eligible(g,cells),'native Mart guard rejected')
  local parts={};local result,err=M.build(g,cells,V.require('Voxel3D').newMesh,parts);assert(result,err);assert(#parts==2 and g.importedMartDoors and #g.importedMartDoors.parts==6)
  local D=V.require('Gen3MartDoors');for state=0,2 do local draws=0;D.draw(g,{x=g.cx+1,y=g.cy+3,frame=state},function()draws=draws+1 end);assert(draws==2)end
  D.release(g);V.require('SceneryModels').releaseBatches(parts);g.importedHoenn=nil
  result=M.build(g,cells,function()return nil end,{});assert(not result and not g.importedHoenn and not g.importedMartDoors)
  local P=require('src.core.game3.player');P.reset(f[2]+1,f[3]+6,'up');U.wait(5);require('src.ui.game3.map_preview_screen').dismiss();require('src.ui.game3.map_name_popup').dismiss();assert(U.shot(game,os.getenv('SHOT_DIR')..'/'..f[1]..'-native.png'))
  print('[OLDALE MART NATIVE BUILD+ALL DOOR STATES+ROLLBACK] PASS',edition,f[1])
 end
end
