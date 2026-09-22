-- Reproducible source-art coverage inventory, not an all-map visual approval.
-- CSV contains identifiers/counts only; never export imported art to the repo.
return function(game)
 assert(love.filesystem.getIdentity()=='firered-hd2d-qa','refusing a non-QA profile')
 local U=dofile('tests/drivers/util.lua')
 game:_handleBootAction({action='new_game',start={map='FR_PALLET_TOWN',x=10,y=9,facing='down'}})
 local V=assert(game.mods.exports.BATTLE_ART_VOXEL_FORK).lib
 local Pairs,Shapes,Furniture=V.require('Gen3Tilesets'),V.require('Gen3TileShape'),V.require('Gen3Furniture')
 local Map=require('src.core.game3.map');local Versions=require('src.import.gba.versions')
 local file=assert(io.open(assert(os.getenv('SHOT_DIR'))..'/firered-coverage.csv','w'))
 file:write('map,pair,primary,environment,hd_scene,cells,flat,trees,building_cells,room_walls,props\n')
 local ids={};for id in pairs(game.data.maps)do ids[#ids+1]=id end;table.sort(ids)
 local pairsSeen,enabled,propMaps,propsTotal,recipeCounts={},0,0,0,{}
 local tileRows={}
 for index,id in ipairs(ids)do
  local def=game.data.maps[id];Map.ensureMidLayout(game,id,def)
  local pair=def.midLayout.pair;local spec=Pairs.resolve(pair,Versions.TILESET_PAIRS)
  local supported=Pairs.supports(def,spec);if supported then enabled=enabled+1 end
  pairsSeen[pair]=true
  local cells={};local n,flat,trees,buildings,walls=0,0,0,0,0
  for y=0,def.height-1 do for x=0,def.width-1 do
   local mid=def.midLayout:midAt(x,y);local shape=Shapes.of(spec.primary,spec.secondary,mid)
   cells[x..':'..y]={cx=x,cy=y,mid=mid,pair=pair,primary=spec.primary,secondary=spec.secondary,shape=shape}
  end end
  local Buildings=V.require('Gen3Buildings')
  if supported then local gyms=Buildings.prepare(cells);V.require('Gen3Civic').prepare(cells,gyms,V.data("gen3_exteriors"))end
  local props=supported and Furniture.extract(cells) or {}
  if #props>0 then propMaps=propMaps+1 end;propsTotal=propsTotal+#props
  for _,p in ipairs(props)do recipeCounts[p.recipe.name]=(recipeCounts[p.recipe.name] or 0)+1 end
  if supported then
   Shapes.layout(cells)
   for _,c in pairs(cells)do if c.gym then c.column=Buildings.column(c.gym)end end
  end
  for _,c in pairs(cells)do
   local treatment=not supported and 'native_fallback' or c.prop and 'modeled_prop'
    or (c.column or c.civic) and 'modeled_building' or c.shape.kind=='flat' and (c.shape.reviewedSurface and 'reviewed_surface' or 'unreviewed')
    or (c.shape.kind=='roof' or c.shape.kind=='wall' or c.shape.kind=='roomWall') and 'unmatched_building'
    or 'modeled_'..c.shape.kind
   local key=pair..':'..c.mid..':'..treatment
   local row=tileRows[key] or {pair=pair,mid=c.mid,kind=c.shape.kind,treatment=treatment,cells=0,maps={},example=id,x=c.cx,y=c.cy}
   tileRows[key]=row;row.cells=row.cells+1;row.maps[id]=true
   n=n+1
   if c.prop then
   elseif c.civic then buildings=buildings+1
   elseif c.column then if c.column.indoor then walls=walls+1 else buildings=buildings+1 end
   elseif c.shape.kind=='tree' and supported then trees=trees+1
   elseif not supported or c.shape.kind=='flat' or c.shape.kind=='roof' or c.shape.kind=='wall' or c.shape.kind=='roomWall' then flat=flat+1 end
  end
  file:write(('%s,%s,%s,%s,%s,%d,%d,%d,%d,%d,%d\n'):format(id,pair,spec.primary or '',def.environment or '',tostring(supported),n,flat,trees,buildings,walls,#props))
  if index%20==0 then U.wait(1)end
 end
 file:close()
 local tiles=assert(io.open(assert(os.getenv('SHOT_DIR'))..'/firered-tiles.csv','w'))
 tiles:write('pair,metatile,kind,treatment,cells,maps,example_map,x,y\n')
 local keys={};for key in pairs(tileRows)do keys[#keys+1]=key end;table.sort(keys)
 for _,key in ipairs(keys)do local r=tileRows[key];local maps=0;for _ in pairs(r.maps)do maps=maps+1 end
  tiles:write(('%s,%03X,%s,%s,%d,%d,%s,%d,%d\n'):format(r.pair,r.mid,r.kind,r.treatment,r.cells,maps,r.example,r.x,r.y))
 end
 tiles:close()
 print('[FR tile ledger]',#keys,'distinct tile/treatment rows')
 local np=0;for _ in pairs(pairsSeen)do np=np+1 end
 for name,count in pairs(recipeCounts)do print('[FR recipe]',name,count)end
 print('[FR coverage] PASS',#ids,'maps',np,'pairs',enabled,'HD scenes',propMaps,'furnished maps',propsTotal,'objects')
 love.event.quit()
end
