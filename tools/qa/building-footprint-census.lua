-- Runtime QA: recognized Civic assemblies only. Flags low face bounding boxes
-- overlapping the central 8x8 of native walkable cells; not a full collision proof.
-- Run as POKEPORT_DRIVER with SHOT_DIR set to an existing output directory.
return function(game)
 local U=dofile('tests/drivers/util.lua');local ver=require('src.core.GameVersion').get()
 game:_handleBootAction({action='new_game',start={map=ver=='emerald'and'EM_OLDALE_TOWN'or'FR_PALLET_TOWN',x=10,y=9,facing='down'}})
 local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib;local Map=require('src.core.game3.map');local P=V.require('Gen3Tilesets');local C=V.require('Gen3Civic')
 local ids={};for id,d in pairs(game.data.maps)do Map.ensureMidLayout(game,id,d);ids[#ids+1]=id end;table.sort(ids);P.bind(game.data.maps)
 local f=assert(io.open(os.getenv('SHOT_DIR')..'/footprints.csv','w'));f:write('map,family,x,y,walkable_cells\n');local count,bad=0,0
 for _,id in ipairs(ids)do local d=game.data.maps[id]
  if P.outdoor(d)then
   local spec=P.resolve(d.midLayout.pair,require('src.import.gba.versions').TILESET_PAIRS);local cells={}
   for y=0,d.height-1 do for x=0,d.width-1 do cells[x..':'..y]={cx=x,cy=y,mid=d.midLayout:midAt(x,y),collision=d.midLayout:collAt(x,y),primary=spec.primary,secondary=spec.secondary,pair=P.canonical(d.midLayout.pair)}end end
   local list=C.prepare(cells,V.require('Gen3Buildings').prepare(cells),V.data('gen3_exteriors'))
   for _,g in ipairs(list)do local hits={};count=count+1
    C.append(g,function(v)
     local l,n,h,r,s,b=math.huge,math.huge,math.huge,-math.huge,-math.huge,-math.huge
     for _,q in ipairs(v)do l=math.min(l,q[1]);r=math.max(r,q[1]);n=math.min(n,q[3]);s=math.max(s,q[3]);h=math.min(h,q[2]);b=math.max(b,q[2])end
     if b>1.5 and h<16 then
      for y=math.floor(n/16),math.floor(s/16)do for x=math.floor(l/16),math.floor(r/16)do
       if l<x*16+12 and r>x*16+4 and n<y*16+12 and s>y*16+4 then local c=cells[x..':'..y];if c and c.collision==0 then hits[x..':'..y]=true end end
      end end
     end
    end)
    local rows={};for k in pairs(hits)do rows[#rows+1]=k end;table.sort(rows)
    if #rows>0 then bad=bad+1;f:write(table.concat({id,g.family or g.kind,g.cx,g.cy,table.concat(rows,' ')},',')..'\n')end
   end
  end
 end
 f:close();print('BUILDING FOOTPRINTS',ver,count,bad);love.event.quit(0)
end
