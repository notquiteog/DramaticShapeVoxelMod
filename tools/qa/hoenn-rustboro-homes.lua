-- Own-source Rustboro adapter/dispatcher upload QA; final combined Scene acceptance is separate.
return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'),'QA identity required')
 local U=dofile(assert(os.getenv('QA_UTIL'),'QA_UTIL must name external frame helper'))
 local V=assert(game.mods.exports.BATTLE_ART_VOXEL_FORK).lib
 local edition=require('src.core.GameVersion').get();local prefix=({emerald='EM_',ruby='RU_',sapphire='SA_'})[edition]
 game:_handleBootAction({action='new_game',start={map=prefix..'RUSTBORO_CITY',x=15,y=11,facing='up'}})
 local Map=require('src.core.game3.map');local Pairs=V.require('Gen3Tilesets');local Versions=require('src.import.gba.versions');local Tiles=require('src.core.game3.tileset_native');local Shape=V.require('Gen3TileShape');local Inter=require('src.core.game3.scripting.interaction_scripts')
 V.require('Gen3Integration').setLevel(0,game)
 for _,f in ipairs{{'RUSTBORO_CITY',7,34,'rustboro_small_tan',16,2,4},{'RUSTBORO_CITY',31,15,'rustboro_white_small',16,2,4},{'RUSTBORO_CITY',28,24,'rustboro_white_small',16,2,4},{'RUSTBORO_CITY',24,30,'rustboro_east_tan',20,3,5}}do
  assert(Map.load(nil,game,prefix..f[1],{x=f[2]+f[6],y=f[3]+6,facing='up'}));U.wait(2)
  local def=Map.currentDef();local lay=def.midLayout;local spec=Pairs.resolve(lay.pair,Versions.TILESET_PAIRS);local ts=assert(Tiles.get(lay.pair));local region={x=0,y=0,w=def.width,h=def.height,def=def};local cells={}
  for y=0,def.height-1 do for x=0,def.width-1 do local raw=lay:cellAt(x,y);local behavior=(Inter.behaviors[lay.pair]or{})[raw.mid]
   cells[x..':'..y]={cx=x,cy=y,mid=raw.mid,collision=raw.coll,elevation=raw.elev,region=region,ts=ts,pair=Pairs.canonical(lay.pair),primary=spec.primary,secondary=spec.secondary,behavior=behavior,shape=Shape.of(spec.primary,spec.secondary,raw.mid,behavior,raw.coll)}
  end end
  local civics=V.require('Gen3Civic').prepare(cells,V.require('Gen3Buildings').prepare(cells),V.data('gen3_exteriors'))
  Shape.layout(cells);V.require('Gen3Elevation').bind(cells,{region})
  local g;for _,q in ipairs(civics)do if q.custom and q.custom.name==f[4]and q.cx==f[2]and q.cy==f[3]then g=q end end;assert(g,'missing exact native Rustboro building')
  local M=V.require('Gen3ModernHoennBuildings')
  local parts={};local capCount=0
  local function upload(v,i,format)
   if #v==f[5]and #i==(f[5]-2)*3 then for _,p in ipairs(v)do assert(math.abs(p[2]+.05)<1e-8);capCount=capCount+1 end end
   return V.require('Voxel3D').newMesh(v,i,format)
  end
  local result,err=M.build(g,cells,upload,parts);assert(result,err);assert(capCount==f[5] and #parts==f[7] and g.importedRustboroDoors and #g.importedRustboroDoors.parts==6)
  local blend=0;for _,part in ipairs(parts)do if part.opacity<1 then assert(part.opacity==.6 and part.alphaMode=='blend');blend=blend+1 end end;assert(blend==(f[7]==5 and 1 or 0))
  assert(M.kind(g)=='rustboroHomes'and M.ownsDoor(g,g.cx+f[6],g.cy+4));local D=M;for state=0,2 do local draws=0;D.draw(g,{x=g.cx+f[6],y=g.cy+4,frame=state},function()draws=draws+1 end);assert(draws==2)end
  D.release(g);V.require('SceneryModels').releaseBatches(parts);g.importedHoenn=nil
  result=M.build(g,cells,function()return nil end,{});assert(not result and not g.importedHoenn and not g.importedRustboroDoors)
  local P=require('src.core.game3.player');P.reset(f[2]+f[6],f[3]+6,'up');game.input:reset();U.wait(45);assert(Map.currentDef().id==prefix..f[1],'native map changed');require('src.ui.game3.map_preview_screen').dismiss();require('src.ui.game3.map_name_popup').dismiss();assert(U.shot(game,os.getenv('SHOT_DIR')..'/'..f[1]..'-'..f[2]..'-'..f[3]..'-native.png'))
  print('[RUSTBORO HOME NATIVE BUILD+HINGES+FLOOR SEPARATION+ROLLBACK] PASS',edition,f[1])
 end
end
