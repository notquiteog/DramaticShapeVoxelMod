-- Native tree footprint census; identifiers/geometry only, no imported pixels.
-- Isolated QA profiles only. Default: first three settlements and routes in the
-- selected edition. QA_MAP_LIST may name a newline-separated explicit map list.
-- QA_TREE_FIT=1 invokes the reviewed footprint adapter after normal preparation.
-- QA_TREE_MODE=native|replacement selects native or optional Gen1 solid models.
-- The illustrated option is a GPU billboard, so its static CPU projection is
-- deliberately outside this solid-model census.
-- QA_STRICT=1 rejects any positive-area emitted crown face over walkable land
-- or a blocked native tree cell with less than 25% projected crown coverage.
-- Coverage samples the union of projected crown faces at each native pixel
-- centre. Rounded corners are expected: report zero and <25% coverage separately.
return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'),'QA profile required')
 local U=dofile('tests/drivers/util.lua');local ed=require('src.core.GameVersion').get()
 local pre=({ruby='RU_',sapphire='SA_',emerald='EM_'})[ed]or'FR_'
 game:_handleBootAction({action='new_game',start={map=pre=='FR_'and'FR_PALLET_TOWN'or pre..'OLDALE_TOWN',x=10,y=9,facing='down'}});U.wait(5)
 local V=assert(game.mods.exports.BATTLE_ART_VOXEL_FORK).lib
 local P,S,N=V.require('Gen3Tilesets'),V.require('Gen3TileShape'),V.require('NativeTreeArt')
 local mode=os.getenv('QA_TREE_MODE')or'native';assert(mode=='native'or mode=='replacement','unknown tree geometry mode')
 if mode=='replacement'then V.require('TreePresentation').art:sync('modeled');V.require('CommunityVisuals').trees:sync('n64memory');V.require('CommunityVisuals').forest:sync('n64memory')end
 local function geometry(c,cells,id,tx,tz)
  local v,ix={},{}
  local card=N.gen3(c)
  if mode=='replacement'then
    card=V.require('NativeLegendaryForest').card(card,c,id);local groups={}
    if V.require('NativeLegendaryTrees').add(card,c,cells,groups,tx,0,tz)then
     for _,group in pairs(groups)do for _,part in ipairs(group.template.groups)do for _,pos in ipairs(group.positions)do
      for _,p in ipairs(part.vertices)do v[#v+1]={p[1]+pos[1],p[2]+pos[2],p[3]+pos[3]}end
     end end end
    else N.appendModel(card,v,ix,0,tx,0,tz)end
  else N.appendModel(card,v,ix,0,tx,0,tz)end
  return v,ix
 end
 local Map=require('src.core.game3.map');local Tiles=require('src.core.game3.tileset_native')
 local Perm=require('src.core.CollPermissions');local Versions=require('src.import.gba.versions')
 local I=require('src.core.game3.scripting.interaction_scripts');local ids={}
 if os.getenv('QA_MAP_LIST')then for id in io.lines(os.getenv('QA_MAP_LIST'))do ids[#ids+1]=id end
 else for _,n in ipairs(pre=='FR_'and{'PALLET_TOWN','VIRIDIAN_CITY','PEWTER_CITY','ROUTE_1','ROUTE_2','VIRIDIAN_FOREST'}or{'LITTLEROOT_TOWN','OLDALE_TOWN','PETALBURG_CITY','ROUTE101','ROUTE102','ROUTE103'})do ids[#ids+1]=pre..n end end
 for _,id in ipairs(ids)do Map.ensureMidLayout(game,id,assert(game.data.maps[id]))end;P.bind(game.data.maps)
 local dir=assert(os.getenv('SHOT_DIR'));local overlap=assert(io.open(dir..'/tree-overlaps.tsv','w'));local coverage=assert(io.open(dir..'/tree-coverage.tsv','w'));local roots=assert(io.open(dir..'/tree-roots.tsv','w'));local summary=assert(io.open(dir..'/tree-summary.tsv','w'))
 overlap:write('map\troot_x\troot_y\troot_mid\tland_x\tland_y\tland_mid\tpermission\tface_count\tmax_face_area\n')
 coverage:write('map\tx\ty\tmid\tpermission\tcovered_pixels\ttotal_pixels\n')
 roots:write('map\tx\ty\tmid\tpermission\tanchor_x\tanchor_z\twidth\tdepth\tfaces\tmin_x\tmax_x\tmin_z\tmax_z\n')
 summary:write('map\troots\tblocked_tree_cells\twalking_root_cell_pairs\twalking_cells\tuncovered_tree_cells\tunder25pct_tree_cells\tsource_digest\n')
 local totals={roots=0,blocked=0,pairs=0,land=0,empty=0,low=0}
 for _,id in ipairs(ids)do
  local d=game.data.maps[id];local l=d.midLayout;local sp=P.resolve(l.pair,Versions.TILESET_PAIRS);local beh=I.behaviors[l.pair]or{};local ts=assert(Tiles.get(l.pair));local cells,source={},{}
  for y=0,d.height-1 do for x=0,d.width-1 do local mid,coll=l:midAt(x,y),l:collAt(x,y);local k=x..':'..y
   cells[k]={cx=x,cy=y,mid=mid,collision=coll,pair=P.canonical(l.pair),nativePair=l.pair,primary=sp.primary,secondary=sp.secondary,behavior=beh[mid],ts=ts,shape=S.of(sp.primary,sp.secondary,mid,beh[mid],coll)}
   source[#source+1]=table.concat({x,y,mid,coll,tostring(l.elevAt and l:elevAt(x,y)or'-')},':')
  end end
  local digest=love.data.encode('string','hex',love.data.hash('sha256',table.concat(source,';')))
  if V.require('Gen3Hoenn').active()then V.require('Gen3Hoenn').prepareTrees(cells)end;V.require('Gen3Forest').prepare(cells)
  V.require('Gen3Civic').prepare(cells,V.require('Gen3Buildings').prepare(cells),V.data('gen3_exteriors'))
  V.require('Gen3NativeLamps').prepare(cells);V.require('Gen3Stairs').prepare(cells);V.require('Gen3Furniture').extract(cells)
  local candidates={};for k,c in pairs(cells)do if c.shape.kind=='tree'and not c.civic and not c.prop and not Perm.isWalkable(c.collision)then candidates[k]=c end end
  if os.getenv('QA_TREE_FIT')=='1'then V.require('Gen3TreeFootprints').prepare(cells,ed)end
  local blocked,covered,walking={}, {}, {};local nr,np,nb,ne,nlow=0,0,0,0,0
  for k,c in pairs(candidates)do blocked[k]=c;covered[k]={};nb=nb+1 end
  for _,c in pairs(cells)do if c.shape.kind=='tree'and c.shape.root and not c.civic and not c.prop then
   nr=nr+1;local v,ix={},{};local tx,tz=c.cx*16+(c.shape.anchorX or 16),c.cy*16+(c.shape.anchorZ or 12)
   v,ix=geometry(c,cells,id,tx,tz);local touched={};local minx,maxx,minz,maxz=1e9,-1e9,1e9,-1e9
   for start=1,#v,4 do
    local x0,x1,z0,z1=1e9,-1e9,1e9,-1e9
    for j=start,math.min(start+3,#v)do local p=v[j];x0=math.min(x0,p[1]);x1=math.max(x1,p[1]);z0=math.min(z0,p[3]);z1=math.max(z1,p[3])end
    minx,maxx,minz,maxz=math.min(minx,x0),math.max(maxx,x1),math.min(minz,z0),math.max(maxz,z1)
    if x1-x0>.001 and z1-z0>.001 then
     for yy=math.max(0,math.floor(z0/16)),math.min(d.height-1,math.floor(z1/16))do for xx=math.max(0,math.floor(x0/16)),math.min(d.width-1,math.floor(x1/16))do
      local k=xx..':'..yy;local target=cells[k];local a,b=math.max(x0,xx*16),math.min(x1,(xx+1)*16);local n,f=math.max(z0,yy*16),math.min(z1,(yy+1)*16);local area=(b-a)*(f-n)
      if b-a>.001 and f-n>.001 then
       if Perm.isWalkable(target.collision)then local t=touched[k]or{count=0,area=0};t.count=t.count+1;t.area=math.max(t.area,area);touched[k]=t;walking[k]=true end
       if covered[k]then for pz=math.max(0,math.ceil(n-yy*16-.5)),math.min(15,math.floor(f-yy*16-.5))do for px=math.max(0,math.ceil(a-xx*16-.5)),math.min(15,math.floor(b-xx*16-.5))do covered[k][pz*16+px]=true end end end
      end
     end end
    end
   end
   for k,t in pairs(touched)do local target=cells[k];np=np+1;overlap:write(table.concat({id,c.cx,c.cy,string.format('%03X',c.mid),target.cx,target.cy,string.format('%03X',target.mid),target.collision,t.count,t.area},'\t')..'\n')end
   roots:write(table.concat({id,c.cx,c.cy,string.format('%03X',c.mid),c.collision,tx,tz,c.shape.modelWidth or'-',c.shape.modelDepth or'-',#v/4,minx,maxx,minz,maxz},'\t')..'\n')
  end end
  local nl=0;for _ in pairs(walking)do nl=nl+1 end
  for k,c in pairs(blocked)do local pixels=0;for _ in pairs(covered[k])do pixels=pixels+1 end;if pixels==0 then ne=ne+1 end;if pixels<64 then nlow=nlow+1 end;coverage:write(table.concat({id,c.cx,c.cy,string.format('%03X',c.mid),c.collision,pixels,256},'\t')..'\n')end
  -- Read-only preparation must retain the authoritative source drawing,
  -- permission and elevation at every cell. Never repair gameplay to fit art.
  local again={};for y=0,d.height-1 do for x=0,d.width-1 do again[#again+1]=table.concat({x,y,l:midAt(x,y),l:collAt(x,y),tostring(l.elevAt and l:elevAt(x,y)or'-')},':')end end
  assert(table.concat(source,';')==table.concat(again,';'),'native layout changed')
  summary:write(table.concat({id,nr,nb,np,nl,ne,nlow,digest},'\t')..'\n');summary:flush()
  totals.roots=totals.roots+nr;totals.blocked=totals.blocked+nb;totals.pairs=totals.pairs+np;totals.land=totals.land+nl;totals.empty=totals.empty+ne;totals.low=totals.low+nlow
  print('[TREE MAP]',id,nr,nb,np,nl,ne,nlow);U.wait(1)
 end
 overlap:close();coverage:close();roots:close();summary:close()
 print('[TREE CENSUS]',ed,mode,#ids,'maps',totals.roots,'roots',totals.blocked,'blocked tree cells',totals.pairs,'walking root/cell pairs',totals.land,'walking cells',totals.empty,'uncovered',totals.low,'under25pct')
 if os.getenv('QA_STRICT')=='1'then
  assert(totals.pairs==0,'tree crown face extends into native walkable land')
  assert(totals.empty==0 and totals.low==0,'blocked native tree cell lacks projected crown coverage')
 end
 love.event.quit()
end
