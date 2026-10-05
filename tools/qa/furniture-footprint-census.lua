-- Engine driver: native Gen3 authored-furniture footprint census.
-- Set SHOT_DIR to an existing directory; writes footprints.csv.
-- Flags solids intersecting a walkable cell's central 8x8 pixels. These are
-- review candidates, not proven defects: seats and elevated ornaments need
-- visual review. Does not certify generic tile geometry or unmodeled objects.
-- Uses imported data read-only, never changes collision or saves progress.
return function(game)
 local U=dofile('tests/drivers/util.lua');local version=require('src.core.GameVersion').get()
 game:_handleBootAction({action='new_game',start={map=version=='emerald'and'EM_OLDALE_TOWN'or'FR_PALLET_TOWN',x=7,y=8,facing='down'}})
 local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib;local Map=require('src.core.game3.map')
 local P=V.require('Gen3Tilesets');local F=V.require('Gen3Furniture');local G=V.require('InteriorFurniture')
 local stats={};local maps,instances=0,0
 -- Resolve the complete atlas inventory before counting. Incremental alias
 -- binding during draw ticks made reports depend on Lua table traversal.
 local ids={};for id,d in pairs(game.data.maps)do Map.ensureMidLayout(game,id,d);ids[#ids+1]=id end
 table.sort(ids);P.bind(game.data.maps)
 for _,id in ipairs(ids)do local d=game.data.maps[id];if tonumber(d.mapType)==8 then
  Map.ensureMidLayout(game,id,d);local pair=P.canonical(d.midLayout.pair)
  local spec=P.resolve(d.midLayout.pair,require('src.import.gba.versions').TILESET_PAIRS);local cells={}
  for y=0,d.height-1 do for x=0,d.width-1 do cells[x..':'..y]={cx=x,cy=y,mid=d.midLayout:midAt(x,y),collision=d.midLayout:collAt(x,y),primary=spec.primary,secondary=spec.secondary,pair=pair,ts={}}end end
  for _,p in ipairs(F.extract(cells))do if p.recipe.design then
   instances=instances+1;local r=p.recipe;local hits={}
   G.draw(r.design,{width=p.w,height=p.d,recipe=r,sample=function()return{}end,source=function()end,face=function()end,
    box=function(l,y,n,rr,h,s)
     if h<=1.5 or y>=16 then return end
     for cy=math.floor(n/16),math.ceil(s/16)-1 do for cx=math.floor(l/16),math.ceil(rr/16)-1 do
      -- Test an actor's central footprint, excluding tiny decorative overhangs.
      if l<cx*16+12 and rr>cx*16+4 and n<cy*16+12 and s>cy*16+4 then
       local cell=cells[(p.cx+cx)..':'..(p.cy+cy)]
       if cell and cell.collision==0 then hits[cx..':'..cy]=true end
      end
     end end
    end})
   local st=stats[r.design]or{n=0,bad=0,maps={},recipes={},hits={}};stats[r.design]=st;st.n=st.n+1
   if next(hits)then st.bad=st.bad+1;st.maps[id]=true;st.recipes[r.name]=true;for k in pairs(hits)do st.hits[k]=true end end
  end end
  maps=maps+1;if maps%25==0 then U.wait(1)end
 end end
 local order={};for name,s in pairs(stats)do s.name=name;order[#order+1]=s end;table.sort(order,function(a,b)return a.bad==b.bad and a.name<b.name or a.bad>b.bad end)
 local f=assert(io.open(os.getenv('SHOT_DIR')..'/footprints.csv','w'));f:write('design,instances,flagged_instances,example_map,local_cells\n')
 for _,s in ipairs(order)do
  local examples={};for id in pairs(s.maps)do examples[#examples+1]=id end;table.sort(examples);local example=examples[1]or'';local hits={};for k in pairs(s.hits)do hits[#hits+1]=k end;table.sort(hits)
  f:write(string.format('%s,%d,%d,%s,%s\n',s.name,s.n,s.bad,example,table.concat(hits,' ')))
 end;f:close();print('[footprint census]',version,maps,instances)
 love.event.quit()
end
