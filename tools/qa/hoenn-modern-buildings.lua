-- Read-only atomic building/door upload QA; whole Scene rendering is separate.
return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'),'QA identity required')
 local U=dofile(assert(os.getenv('QA_UTIL'),'QA_UTIL must name external helper'))
 local V=assert(game.mods.exports.BATTLE_ART_VOXEL_FORK).lib
 local edition=require('src.core.GameVersion').get();local prefix=({emerald='EM_',ruby='RU_',sapphire='SA_'})[edition]
 game:_handleBootAction({action='new_game',start={map=prefix..'PETALBURG_CITY',x=15,y=11,facing='up'}})
 local Map=require('src.core.game3.map');local Pairs=V.require('Gen3Tilesets');local Versions=require('src.import.gba.versions');local Tiles=require('src.core.game3.tileset_native');local Shape=V.require('Gen3TileShape');local Inter=require('src.core.game3.scripting.interaction_scripts')
 V.require('Gen3Integration').setLevel(0,game)
 for _,f in ipairs{{'OLDALE_TOWN',13,3,'oldale_mart','importedMartDoors',2,6,1,3,2},{'PETALBURG_CITY',24,9,'petalburg_city_mart','importedMartDoors',2,6,1,3,2},{'RUSTBORO_CITY',15,42,'rustboro_city_mart','importedMartDoors',2,6,1,3,2},{'PETALBURG_CITY',12,4,'petalburg_city_gym','importedGymDoors',6,9,3,4,3},{'DEWFORD_TOWN',5,13,'dewford_town_gym','importedGymDoors',6,9,3,4,3},{'RUSTBORO_CITY',24,15,'rustboro_city_gym','importedGymDoors',6,9,3,4,3},{'OLDALE_TOWN',4,4,'oldale_house','importedOldaleDoors',3,6,1,3,2},{'OLDALE_TOWN',14,13,'oldale_house','importedOldaleDoors',3,6,1,3,2}}do
  assert(Map.load(nil,game,prefix..f[1],{x=f[2],y=f[3]+2,facing='up'}));U.wait(2)
  local def=Map.currentDef();local lay=def.midLayout;local spec=Pairs.resolve(lay.pair,Versions.TILESET_PAIRS);local ts=assert(Tiles.get(lay.pair));local region={x=0,y=0,w=def.width,h=def.height,def=def};local cells={}
  for y=0,def.height-1 do for x=0,def.width-1 do local raw=lay:cellAt(x,y);local behavior=(Inter.behaviors[lay.pair]or{})[raw.mid]
   cells[x..':'..y]={cx=x,cy=y,mid=raw.mid,collision=raw.coll,elevation=raw.elev,region=region,ts=ts,pair=Pairs.canonical(lay.pair),primary=spec.primary,secondary=spec.secondary,behavior=behavior,shape=Shape.of(spec.primary,spec.secondary,raw.mid,behavior,raw.coll)}
  end end
  local civics=V.require('Gen3Civic').prepare(cells,V.require('Gen3Buildings').prepare(cells),V.data('gen3_exteriors'))
  Shape.layout(cells);V.require('Gen3Elevation').bind(cells,{region})
  local g;for _,q in ipairs(civics)do if q.custom and q.custom.name==f[4]and q.cx==f[2]and q.cy==f[3]then g=q end end;assert(g,'missing original Mart')
  local M=V.require('Gen3ModernHoennBuildings')
  local parts={};local result,err=M.build(g,cells,V.require('Voxel3D').newMesh,parts);assert(result,err);assert(#parts==f[6]+1 and g[f[5]] and #g[f[5]].parts==f[7])
  local D=M;for state=0,2 do local draws=0;D.draw(g,{x=g.cx+f[8],y=g.cy+f[9],frame=state},function()draws=draws+1 end);assert(draws==f[10])end
  D.release(g);V.require('SceneryModels').releaseBatches(parts);g.importedHoenn=nil
  assert(not M.ownsDoor(g,g.cx+f[8],g.cy+f[9]));result=M.build(g,cells,function()return nil end,{});assert(not result and not g.importedHoenn and not g[f[5]])
  local P=require('src.core.game3.player');P.reset(f[2]+1,f[3]+6,'up');U.wait(5);require('src.ui.game3.map_preview_screen').dismiss();require('src.ui.game3.map_name_popup').dismiss();assert(U.shot(game,os.getenv('SHOT_DIR')..'/'..f[1]..'-native.png'))
  print('[REVIEWED HOENN DISPATCH+DOORS+ROLLBACK] PASS',edition,f[1])
 end
end
