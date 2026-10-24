-- Source adapter upload/state/cap/rollback QA; final native Scene drawing is separate.
return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'),'QA identity required')
 local U=dofile(assert(os.getenv('QA_UTIL'),'QA_UTIL must name external driver helper'))
 local V=assert(game.mods.exports.BATTLE_ART_VOXEL_FORK).lib
 local edition=require('src.core.GameVersion').get();local prefix=({emerald='EM_',ruby='RU_',sapphire='SA_'})[edition]
 game:_handleBootAction({action='new_game',start={map=prefix..'PETALBURG_CITY',x=15,y=11,facing='up'}})
 local Map=require('src.core.game3.map');local Pairs=V.require('Gen3Tilesets');local Versions=require('src.import.gba.versions');local Tiles=require('src.core.game3.tileset_native');local Shape=V.require('Gen3TileShape');local Inter=require('src.core.game3.scripting.interaction_scripts')
 V.require('Gen3Integration').setLevel(0,game)
 for _,f in ipairs{{'OLDALE_TOWN',4,4,'oldale_house'},{'OLDALE_TOWN',14,13,'oldale_house'}}do
  assert(Map.load(nil,game,prefix..f[1],{x=f[2],y=f[3]+2,facing='up'}));U.wait(2)
  local def=Map.currentDef();local lay=def.midLayout;local spec=Pairs.resolve(lay.pair,Versions.TILESET_PAIRS);local ts=assert(Tiles.get(lay.pair));local region={x=0,y=0,w=def.width,h=def.height,def=def};local cells={}
  for y=0,def.height-1 do for x=0,def.width-1 do local raw=lay:cellAt(x,y);local behavior=(Inter.behaviors[lay.pair]or{})[raw.mid]
   cells[x..':'..y]={cx=x,cy=y,mid=raw.mid,collision=raw.coll,elevation=raw.elev,region=region,ts=ts,pair=Pairs.canonical(lay.pair),primary=spec.primary,secondary=spec.secondary,behavior=behavior,shape=Shape.of(spec.primary,spec.secondary,raw.mid,behavior,raw.coll)}
  end end
  local civics=V.require('Gen3Civic').prepare(cells,V.require('Gen3Buildings').prepare(cells),V.data('gen3_exteriors'))
  Shape.layout(cells);V.require('Gen3Elevation').bind(cells,{region})
  local g;for _,q in ipairs(civics)do if q.custom and q.custom.name==f[4]and q.cx==f[2]and q.cy==f[3]then g=q end end;assert(g,'missing original Mart')
  local M=V.require('Gen3ImportedOldaleHomes');assert(M.eligible(g,cells),'native Mart guard rejected')
  local parts={};local capCount=0
  local function upload(v,i,format)
   if #v==28 and #i==78 then for _,p in ipairs(v)do assert(math.abs(p[2]+.05)<1e-8);capCount=capCount+1 end end
   return V.require('Voxel3D').newMesh(v,i,format)
  end
  local result,err=M.build(g,cells,upload,parts);assert(result,err);assert(capCount==28 and #parts==3 and g.importedOldaleDoors and #g.importedOldaleDoors.parts==6)
  local D=V.require('Gen3OldaleDoors');for state=0,2 do local draws=0;D.draw(g,{x=g.cx+1,y=g.cy+3,frame=state},function()draws=draws+1 end);assert(draws==2)end
  D.release(g);V.require('SceneryModels').releaseBatches(parts);g.importedHoenn=nil
  result=M.build(g,cells,function()return nil end,{});assert(not result and not g.importedHoenn and not g.importedOldaleDoors)
  local P=require('src.core.game3.player');P.reset(f[2]+1,f[3]+6,'up');U.wait(5);require('src.ui.game3.map_preview_screen').dismiss();require('src.ui.game3.map_name_popup').dismiss();assert(U.shot(game,os.getenv('SHOT_DIR')..'/'..f[1]..'-'..f[2]..'-'..f[3]..'-native.png'))
  print('[OLDALE HOME NATIVE BUILD+HINGES+FLOOR SEPARATION+ROLLBACK] PASS',edition,f[1])
 end
end
