-- Gen3 gap census: blocked native drawings that production still renders flat.
--
--   POKEPORT_DRIVER=tools/qa/gen3-gap-census.lua SHOT_DIR=<existing dir>
--   optional QA_GAP_SCOPE=outdoor|indoor|all (default outdoor)
--
-- Mirrors Gen3Scene's preparation order (Hoenn trees, forest, gyms, civic
-- recipes incl. optional native buildings, native lamps, stairs, furniture,
-- column layout). A cell is a GAP when native collision blocks it and nothing
-- authored claims it: shape kind flat/roof/wall/roomWall without a civic,
-- column, gym, prop, stair, lamp or tree owner. Connected gap cells form a
-- component; identical (pair, mid grid) components group into one FAMILY so the
-- authoring queue counts distinct drawings, not instances. Identifiers only;
-- never writes imported pixels. Refuses non-QA identities.
return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'),'refusing a non-QA profile')
 local U=dofile('tests/drivers/util.lua')
 local edition=require('src.core.GameVersion').get()
 local start=edition=='emerald' and 'EM_OLDALE_TOWN' or edition=='ruby' and 'RU_OLDALE_TOWN'
  or edition=='sapphire' and 'SA_OLDALE_TOWN' or 'FR_PALLET_TOWN'
 game:_handleBootAction({action='new_game',start={map=start,x=10,y=9,facing='down'}})
 U.wait(5)
 local V=assert(game.mods.exports.BATTLE_ART_VOXEL_FORK).lib
 local Pairs,Shapes,Furniture=V.require('Gen3Tilesets'),V.require('Gen3TileShape'),V.require('Gen3Furniture')
 local Map=require('src.core.game3.map');local Versions=require('src.import.gba.versions')
 local I=require('src.core.game3.scripting.interaction_scripts')
 local Perm=require('src.world.gen2.Permissions')
 local scope=os.getenv('QA_GAP_SCOPE') or 'outdoor'
 local ids={};for id,def in pairs(game.data.maps)do ids[#ids+1]=id end;table.sort(ids)
 for i,id in ipairs(ids)do Map.ensureMidLayout(game,id,game.data.maps[id]);if i%30==0 then U.wait(1)end end
 Pairs.bind(game.data.maps)
 local dir=assert(os.getenv('SHOT_DIR'))
 local comp=assert(io.open(dir..'/'..edition..'-gap-components.csv','w'))
 comp:write('map,outdoor,pair,x,y,w,h,cells,family\n')
 local families,mapsDone,gapCells,claimedCells,mids={},0,0,0,{}
 for index,id in ipairs(ids)do
  local def=game.data.maps[id]
  local outdoor=Pairs.outdoor(def)
  if def.midLayout and (scope=='all' or (scope=='outdoor')==outdoor) then
   local pair=def.midLayout.pair;local spec=Pairs.resolve(pair,Versions.TILESET_PAIRS)
   if Pairs.supports(def,spec) then
    mapsDone=mapsDone+1
    local cells={}
    local beh=I.behaviors[pair] or {}
    for y=0,def.height-1 do for x=0,def.width-1 do
     local mid,coll=def.midLayout:midAt(x,y),def.midLayout:collAt(x,y)
     cells[x..':'..y]={cx=x,cy=y,mid=mid,pair=Pairs.canonical(pair),nativePair=pair,primary=spec.primary,secondary=spec.secondary,
      behavior=beh[mid],collision=coll,shape=Shapes.of(spec.primary,spec.secondary,mid,beh[mid],coll)}
    end end
    local ok,err=pcall(function()
     if V.require('Gen3Hoenn').active() then V.require('Gen3Hoenn').prepareTrees(cells)end
     V.require('Gen3SeaRocks').prepare(cells)
     V.require('Gen3Forest').prepare(cells)
     local gyms=V.require('Gen3Buildings').prepare(cells)
     local recipes=V.data('gen3_exteriors')
     local optional=V.require('NativeLegendaryBuildings').recipes(def)
     if #optional>0 then local combined={};for _,r in ipairs(optional)do combined[#combined+1]=r end;for _,r in ipairs(recipes)do combined[#combined+1]=r end;recipes=combined end
     V.require('Gen3Civic').prepare(cells,gyms,recipes)
     V.require('Gen3NativeLamps').prepare(cells)
     V.require('Gen3Stairs').prepare(cells)
     Furniture.extract(cells)
     Shapes.layout(cells)
     for _,c in pairs(cells)do if c.gym then c.column=V.require('Gen3Buildings').column(c.gym)end end
    end)
    if not ok then print('[GAP ERROR]',id,err)end
    local function gap(c)
     -- Native Gen3 collision arrives as Gen2 permission codes: 0x18 tall
     -- grass and similar walkable codes are not obstacles.
     if not c or c.collision==nil or Perm.isWalkable(c.collision) and not Perm.isLedge(c.collision) then return false end
     if c.civic or c.column or c.gym or c.prop or c.stairs or c.nativeLamp or c.forestTree or c.tree then return false end
     local k=c.shape and c.shape.kind or 'flat'
     return k=='flat' or k=='roof' or k=='wall' or (k=='roomWall' and not c.column) or k=='interiorFloor'
    end
    for _,c in pairs(cells)do if c.collision and not Perm.isWalkable(c.collision) then
     if gap(c)then gapCells=gapCells+1
      local k=c.pair..':'..c.mid;local m=mids[k] or {pair=c.pair,mid=c.mid,kind=c.shape and c.shape.kind or 'flat',cells=0,maps={},example=id,x=c.cx,y=c.cy}
      mids[k]=m;m.cells=m.cells+1;m.maps[id]=true
     else claimedCells=claimedCells+1 end
    end end
    local seen={}
    for y=0,def.height-1 do for x=0,def.width-1 do
     local c=cells[x..':'..y]
     if gap(c) and not seen[c] then
      local stack,list={c},{};seen[c]=true
      local x0,y0,x1,y1=x,y,x,y
      while #stack>0 do
       local n=table.remove(stack);list[#list+1]=n
       x0,y0,x1,y1=math.min(x0,n.cx),math.min(y0,n.cy),math.max(x1,n.cx),math.max(y1,n.cy)
       for _,d in ipairs({{1,0},{-1,0},{0,1},{0,-1}})do
        local m=cells[(n.cx+d[1])..':'..(n.cy+d[2])]
        if gap(m) and not seen[m] then seen[m]=true;stack[#stack+1]=m end
       end
      end
      local inside={};for _,n in ipairs(list)do inside[n]=true end
      local rows={}
      for yy=y0,y1 do local r={};for xx=x0,x1 do local m=cells[xx..':'..yy];r[#r+1]=inside[m] and ('%03X'):format(m.mid) or '...' end;rows[#rows+1]=table.concat(r,' ')end
      local key=c.pair..'|'..table.concat(rows,'/')
      local f=families[key] or {pair=c.pair,w=x1-x0+1,h=y1-y0+1,cells=#list,count=0,maps={},example=id,x=x0,y=y0,outdoor=outdoor,grid=table.concat(rows,'/')}
      families[key]=f;f.count=f.count+1;f.maps[id]=true
      comp:write(('%s,%s,%s,%d,%d,%d,%d,%d,%s\n'):format(id,tostring(outdoor),c.pair,x0,y0,x1-x0+1,y1-y0+1,#list,key:gsub(',',';')))
     end
    end end
   end
  end
  if index%15==0 then U.wait(1)end
 end
 comp:close()
 local list={};for _,f in pairs(families)do list[#list+1]=f end
 table.sort(list,function(a,b)local wa,wb=a.cells*a.count,b.cells*b.count;if wa~=wb then return wa>wb end;return a.example<b.example end)
 local fam=assert(io.open(dir..'/'..edition..'-gap-families.csv','w'))
 fam:write('rank,weight,cells,count,maps,w,h,outdoor,pair,example_map,x,y,grid\n')
 for i,f in ipairs(list)do local n=0;for _ in pairs(f.maps)do n=n+1 end
  fam:write(('%d,%d,%d,%d,%d,%d,%d,%s,%s,%s,%d,%d,%s\n'):format(i,f.cells*f.count,f.cells,f.count,n,f.w,f.h,tostring(f.outdoor),f.pair,f.example,f.x,f.y,f.grid))
 end
 fam:close()
 local ml={};for _,m in pairs(mids)do ml[#ml+1]=m end
 table.sort(ml,function(a,b)if a.cells~=b.cells then return a.cells>b.cells end;return a.pair..a.mid<b.pair..b.mid end)
 local mf=assert(io.open(dir..'/'..edition..'-gap-mids.csv','w'))
 mf:write('pair,mid,kind,gap_cells,maps,example_map,x,y\n')
 for _,m in ipairs(ml)do local n=0;for _ in pairs(m.maps)do n=n+1 end
  mf:write(('%s,%03X,%s,%d,%d,%s,%d,%d\n'):format(m.pair,m.mid,m.kind,m.cells,n,m.example,m.x,m.y))
 end
 mf:close()
 print('[GAP CENSUS]',edition,scope,'maps',mapsDone,'families',#list,'gap_cells',gapCells,'claimed_blocked',claimedCells)
 love.event.quit(0)
end
