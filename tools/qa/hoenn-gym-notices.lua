-- Read-only native notice adapter/upload/rollback QA; rendered acceptance is separate.
return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'),'disposable profile required')
 local U=dofile(assert(os.getenv('QA_UTIL'),'QA_UTIL must name frame-driver helper'))
 local V=assert(game.mods.exports.BATTLE_ART_VOXEL_FORK).lib
 local edition=require('src.core.GameVersion').get();local prefix=({emerald='EM_',ruby='RU_',sapphire='SA_'})[edition]
 game:_handleBootAction({action='new_game',start={map=prefix..'PETALBURG_CITY',x=15,y=11,facing='up'}})
 local Map=require('src.core.game3.map');local Pairs=V.require('Gen3Tilesets');local Versions=require('src.import.gba.versions');local Tiles=require('src.core.game3.tileset_native');local Shape=V.require('Gen3TileShape');local Inter=require('src.core.game3.scripting.interaction_scripts')
 V.require('Gen3Integration').setLevel(0,game)
 for _,f in ipairs{{'PETALBURG_CITY',17,10},{'DEWFORD_TOWN',11,16},{'RUSTBORO_CITY',23,19}}do
  assert(Map.load(nil,game,prefix..f[1],{x=f[2],y=f[3]+2,facing='up'}));U.wait(2)
  local def=Map.currentDef();local lay=def.midLayout;local spec=Pairs.resolve(lay.pair,Versions.TILESET_PAIRS);local ts=assert(Tiles.get(lay.pair));local region={x=0,y=0,w=def.width,h=def.height,def=def};local cells={}
  for y=0,def.height-1 do for x=0,def.width-1 do local raw=lay:cellAt(x,y);local behavior=(Inter.behaviors[lay.pair]or{})[raw.mid]
   cells[x..':'..y]={cx=x,cy=y,mid=raw.mid,collision=raw.coll,elevation=raw.elev,region=region,ts=ts,pair=Pairs.canonical(lay.pair),primary=spec.primary,secondary=spec.secondary,behavior=behavior,shape=Shape.of(spec.primary,spec.secondary,raw.mid,behavior,raw.coll)}
  end end
  Shape.layout(cells);V.require('Gen3Elevation').bind(cells,{region})
  local c=cells[f[2]..':'..f[3]];local top=cells[f[2]..':'..(f[3]-1)];print('[GYM NOTICE]',edition,f[1],c.base,top.base,ts.idxBlob and #ts.idxBlob,ts.overBlob and #ts.overBlob)
  local notices=V.require('Gen3ImportedGymNotices');assert(#notices.placements(cells)==1,'notice eligibility '..f[1]);local old=top.collision;top.collision=7;assert(#notices.placements(cells)==0);top.collision=old
  old=top.base;top.base=old+1;assert(#notices.placements(cells)==0);top.base=old
  old=c.mid;c.mid=0;assert(#notices.placements(cells)==0);c.mid=old
  old=ts.idxBlob;ts.idxBlob=nil;assert(#notices.placements(cells)==0);ts.idxBlob=old
  local parts={};local capCount=0
  local function upload(vertices,indices,format)
   if #vertices==8 and #indices==12 then for _,v in ipairs(vertices)do assert(math.abs(v[2]+.05)<1e-8,'notice cap overlaps floor');capCount=capCount+1 end
   else local minY=math.huge;for _,v in ipairs(vertices)do minY=math.min(minY,v[2])end;assert(math.abs(minY)<1e-8,'original notice moved')end
   return V.require('Voxel3D').newMesh(vertices,indices,format)
  end
  local result,err,n=notices.build(cells,upload,parts);assert(result,err);assert(capCount==8 and n==1 and #parts==2 and c.importedGymNotice and top.importedGymNotice)
  V.require('SceneryModels').releaseBatches(parts)
  c.importedGymNotice=nil;top.importedGymNotice=nil
  result=notices.build(cells,function()return nil end,{});assert(not result and not c.importedGymNotice and not top.importedGymNotice)
  print('[NOTICE ELIGIBLE+BUILD+GUARDS] PASS',edition,f[1])
 end
end
