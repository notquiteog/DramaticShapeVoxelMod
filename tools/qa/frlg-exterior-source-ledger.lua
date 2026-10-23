-- Read-only native FR/LG exterior-source ledger, including every map identifier.
-- Eligibility is not rendered acceptance. Rows contain identifiers/hashes only.
-- Use a disposable *-qa identity and an explicitly supplied QA_UTIL helper.
-- Writes identifiers/counts only; imported pixels never enter the report.
return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'),'disposable QA identity required')
 local U=dofile(assert(os.getenv('QA_UTIL'),'QA_UTIL must name the external frame-driver helper'))
 local edition=require('src.core.GameVersion').get()
 assert(edition=='firered'or edition=='leafgreen','FRLG only')
 game:_handleBootAction({action='new_game',start={map='FR_PALLET_TOWN',x=8,y=8,facing='down'}})
 local V=assert(game.mods.exports.BATTLE_ART_VOXEL_FORK).lib
 V.require('Gen3Integration').setLevel(0,game)
 local Map=require('src.core.game3.map');local Tiles=require('src.core.game3.tileset_native')
 local Versions=require('src.import.gba.versions');local I=require('src.core.game3.scripting.interaction_scripts')
 local Pairs,Shapes,Civic,Furniture=V.require('Gen3Tilesets'),V.require('Gen3TileShape'),V.require('Gen3Civic'),V.require('Gen3Furniture')
 local ids={};for id in pairs(game.data.maps)do ids[#ids+1]=id end
 table.sort(ids)
 for _,id in ipairs(ids)do Map.ensureMidLayout(game,id,game.data.maps[id])end
 Pairs.bind(game.data.maps)
 local out=assert(io.open(assert(os.getenv('SHOT_DIR'))..'/exteriors-'..edition..'.jsonl','w'))
 local Json=require('src.link.Json');local total={maps=0,civics=0,importableCivics=0,furniture=0,importableFurniture=0,trees=0,importableTreeOwners=0}
 for _,id in ipairs(ids)do
  local def=game.data.maps[id];local layout=def.midLayout
  if layout then
  local spec=Pairs.resolve(layout.pair,Versions.TILESET_PAIRS);local behaviors=I.behaviors[layout.pair]or{}
  local ts=assert(Tiles.get(layout.pair),'native tileset absent '..id)
  local cells,source={},{}
  local region={x=0,y=0,w=def.width,h=def.height,def=def,mapId=id}
  for y=0,def.height-1 do for x=0,def.width-1 do
   local raw=layout:cellAt(x,y);local mid,collision=raw.mid,raw.coll
   cells[x..':'..y]={cx=x,cy=y,mid=mid,collision=collision,elevation=raw.elev,region=region,ts=ts,
    nativePair=layout.pair,pair=Pairs.canonical(layout.pair),primary=spec.primary,secondary=spec.secondary,
    behavior=behaviors[mid],shape=Shapes.of(spec.primary,spec.secondary,mid,behaviors[mid],collision)}
   source[#source+1]=table.concat({mid,collision,raw.elev},':')
  end end
  V.require('Gen3SeaRocks').prepare(cells);V.require('Gen3Forest').prepare(cells)
  local civics=Civic.prepare(cells,V.require('Gen3Buildings').prepare(cells),V.data('gen3_exteriors'))
  for _,g in ipairs(V.require('Gen3ImportedKanto').prepare(cells,{region}))do civics[#civics+1]=g end
  V.require('Gen3NativeLamps').prepare(cells);V.require('Gen3Stairs').prepare(cells)
  local furniture=Furniture.extract(cells)
  V.require('Gen3Bridges').prepare(cells);V.require('Gen3TreeFootprints').prepare(cells,edition)
  Shapes.layout(cells);V.require('Gen3Elevation').bind(cells,{region})
  local trees={}
  local treeSources={};for _,p in ipairs(trees)do for _,c in ipairs(p.sources or{p.source})do treeSources[c]=true end end
  local interior=V.require('Gen3ImportedInteriors').placements(cells)
  local row={edition=edition,map=id,mapType=def.mapType,pair=layout.pair,width=def.width,height=def.height,
   outdoor=Pairs.outdoor(def),supported=Pairs.supports(def,spec),civics={},furniture={},kinds={},unimportedTreeOwners={},signGrounds={},
   adapterOnly=true,renderedAcceptance=false,unclassifiedBlockedCells=0,importableTreePlacements=#trees,importableFurniture=#interior}
  local seenTrees={}
  for _,g in ipairs(civics)do
   local imported=g.kantoRecipe and V.require('Gen3ImportedKanto').eligible(g,cells)and g.family or V.require('Gen3ImportedKantoCenters').eligible(g,cells)and'hgss_kanto_center'or V.require('Gen3ImportedPewterMuseum').eligible(g,cells)and'hgss_pewter_museum'or V.require('Gen3ImportedViridianHouses').eligible(g,cells)and'hgss_viridian_house'or V.require('Gen3ImportedPewterHouses').eligible(g,cells)and'hgss_pewter_house'or V.require('Gen3ImportedViridianFlowerHouses').eligible(g,cells)and'hgss_viridian_flower_house'or V.require('Gen3ImportedHGSSMarts').eligible(g,cells)and'hgss_kanto_mart'or V.require('Gen3ImportedCeladonBlocks').eligible(g,cells)and'hgss_celadon_balcony_block'or V.require('Gen3ImportedSaffronBlocks').eligible(g,cells)and V.require('Gen3ImportedSaffronBlocks').selection(g).id or V.require('Gen3ImportedLavenderNameRater').eligible(g,cells)and'hgss_lavender_name_rater'or V.require('Gen3ImportedLavenderHouses').eligible(g,cells)and'hgss_lavender_house'or V.require('Gen3ImportedSaffronDojo').eligible(g,cells)and'hgss_saffron_dojo'or V.require('Gen3ImportedHGSSGyms').eligible(g,cells)and V.require('Gen3ImportedHGSSGyms').selection(g).id
   local ground={};for y=g.cy,g.cy+g.depth-1 do for x=g.cx,g.cx+g.width-1 do local c=cells[x..':'..y];if c and c.civic==g then ground[Civic.ground(c)]=true end end end
   local floors={};for mid in pairs(ground)do floors[#floors+1]=mid end;table.sort(floors)
   local drawing={};for y=0,g.depth-1 do for x=0,g.width-1 do local c=cells[(g.cx+x)..':'..(g.cy+y)];drawing[#drawing+1]=table.concat({c.mid,c.collision,c.elevation or 0},':')end end
   local nativeDecorationsHash
   if imported=='hgss_viridian_flower_house'then local data,why=V.require('Gen3ViridianFlowerCards').imageData(g.ts);assert(data,why);nativeDecorationsHash=love.data.encode('string','hex',love.data.hash('sha256',data:getString()));data:release()end
   row.civics[#row.civics+1]={nativeDecorationsHash=nativeDecorationsHash,family=g.custom and g.custom.name or g.family or g.kind,x=g.cx,y=g.cy,width=g.width,depth=g.depth,ground=floors,
    modernEligible=imported or false,renderedAccepted=false,nativeDrawingHash=love.data.encode('string','hex',love.data.hash('sha256',table.concat(drawing,';')))}
   if imported then total.importableCivics=total.importableCivics+1 end
  end
  local interiorSources={};for _,p in ipairs(interior)do interiorSources[p.source]=p.model end
  for _,p in ipairs(furniture)do row.furniture[#row.furniture+1]={family=p.recipe.name,x=p.cx,y=p.cy,model=interiorSources[p]or false}end
  for _,c in pairs(cells)do
   local kind=c.shape.kind
   if row.outdoor and c.collision==7 and not(c.civic or c.column or c.gym or c.prop or c.stairs or c.nativeLamp or c.forestTree or c.tree)and(kind=='flat'or kind=='wall'or kind=='roof'or kind=='roomWall')then row.unclassifiedBlockedCells=row.unclassifiedBlockedCells+1 end
   row.kinds[c.shape.kind]=(row.kinds[c.shape.kind]or 0)+1
   if c.shape.kind=='tree'and c.shape.root and not(c.civic or c.prop)then
    local owner=c.shape.treeBounds or c.shape; if not seenTrees[owner]then
     seenTrees[owner]=true;total.trees=total.trees+1
     if treeSources[c]then total.importableTreeOwners=total.importableTreeOwners+1
     else row.unimportedTreeOwners[#row.unimportedTreeOwners+1]={x=c.cx,y=c.cy,mid=c.mid}end
    end
   end
   if c.shape.kind=='sign'then local ground,reason=V.require('Gen3PropGround').ground(cells,c)
    row.signGrounds[#row.signGrounds+1]={x=c.cx,y=c.cy,mid=c.mid,ground=ground,proof=reason or'native recipe'}
   end
  end
  local after={};for y=0,def.height-1 do for x=0,def.width-1 do local c=layout:cellAt(x,y);after[#after+1]=table.concat({c.mid,c.coll,c.elev},':')end end
  assert(table.concat(source,';')==table.concat(after,';'),'native source mutated '..id)
  row.nativeHash=love.data.encode('string','hex',love.data.hash('sha256',table.concat(source,';')))
  out:write(Json.encode(row),'\n');out:flush()
  total.maps=total.maps+1;total.civics=total.civics+#civics;total.furniture=total.furniture+#furniture;total.importableFurniture=total.importableFurniture+#interior
  U.wait(1)
  end
 end
 out:close();print('[FRLG EXTERIOR SOURCE LEDGER]',Json.encode(total))
end
