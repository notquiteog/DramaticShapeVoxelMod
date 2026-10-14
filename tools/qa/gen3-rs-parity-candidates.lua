-- Ruby/Sapphire parity candidates: native cells RS renders flat while the
-- reviewed Emerald vocabulary would classify the same ID as an object.
--   POKEPORT_DRIVER=tools/qa/gen3-rs-parity-candidates.lua SHOT_DIR=<dir>
-- Candidates are NOT approvals: compare art (gen3-metatile-hashes.lua) and
-- inspect differing drawings before adding them to data/gen3_rs_parity.lua.
return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'),'refusing a non-QA profile')
 local U=dofile('tests/drivers/util.lua')
 local edition=require('src.core.GameVersion').get()
 assert(edition=='ruby' or edition=='sapphire','Ruby/Sapphire only')
 game:_handleBootAction({action='new_game',start={map=(edition=='ruby' and 'RU_' or 'SA_')..'OLDALE_TOWN',x=10,y=9,facing='down'}})
 U.wait(5)
 local V=assert(game.mods.exports.BATTLE_ART_VOXEL_FORK).lib
 local Pairs,Shapes,H=V.require('Gen3Tilesets'),V.require('Gen3TileShape'),V.require('Gen3Hoenn')
 local Map=require('src.core.game3.map');local Versions=require('src.import.gba.versions')
 local I=require('src.core.game3.scripting.interaction_scripts')
 local ids={};for id in pairs(game.data.maps)do ids[#ids+1]=id end;table.sort(ids)
 for i,id in ipairs(ids)do Map.ensureMidLayout(game,id,game.data.maps[id]);if i%30==0 then U.wait(1)end end
 Pairs.bind(game.data.maps)
 local rows={}
 -- Compare against RS's own vocabulary, not the already-approved table.
 V.require('Gen3RubySapphire').disableParity=true
 for _,id in ipairs(ids)do local def=game.data.maps[id]
  if def.midLayout then
   local pair=def.midLayout.pair;local spec=Pairs.resolve(pair,Versions.TILESET_PAIRS);local beh=I.behaviors[pair] or {}
   for y=0,def.height-1 do for x=0,def.width-1 do
    local mid,coll=def.midLayout:midAt(x,y),def.midLayout:collAt(x,y)
    local rs=Shapes.of(spec.primary,spec.secondary,mid,beh[mid],coll)
    local em=H.emeraldSurface(spec.primary,mid,coll) or H.emeraldShape(spec.primary,spec.secondary,mid,beh[mid],coll)
    if rs.kind~=em.kind or (em.reviewedSurface and not rs.reviewedSurface) then
     local key=table.concat({Pairs.canonical(pair),('%03X'):format(mid),em.kind,coll==0 and 'open' or 'blocked'},',')
     local r=rows[key] or {key=key,cells=0,maps={},example=id,x=x,y=y,rs=rs.kind};rows[key]=r
     r.cells=r.cells+1;r.maps[id]=true
    end
   end end
  end
 end
 local list={};for _,r in pairs(rows)do list[#list+1]=r end
 table.sort(list,function(a,b)return a.key<b.key end)
 local f=assert(io.open(assert(os.getenv('SHOT_DIR'))..'/'..edition..'-rs-parity-candidates.csv','w'))
 f:write('pair,mid,emerald_kind,collision,rs_kind,cells,maps,example_map,x,y\n')
 for _,r in ipairs(list)do local n=0;for _ in pairs(r.maps)do n=n+1 end
  f:write(('%s,%s,%d,%d,%s,%d,%d\n'):format(r.key,r.rs,r.cells,n,r.example,r.x,r.y))
 end
 V.require('Gen3RubySapphire').disableParity=nil
 f:close();print('[RS PARITY]',edition,#list);love.event.quit(0)
end
