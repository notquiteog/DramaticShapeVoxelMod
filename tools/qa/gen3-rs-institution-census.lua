-- Native-data census of only the new RS institutional components, including atlas reuse.
return function(game)
 local U=dofile('tests/drivers/util.lua');local ed=require('src.core.GameVersion').get()
 local prefix=ed=='emerald'and'EM_'or ed=='ruby'and'RU_'or ed=='sapphire'and'SA_'or'FR_'
 game:_handleBootAction({action='new_game',start={map=prefix=='FR_'and'FR_PALLET_TOWN'or prefix..'OLDALE_TOWN',x=10,y=9,facing='up'}})
 local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib;local P=V.require('Gen3Tilesets');local F=V.require('Gen3Furniture');local Map=require('src.core.game3.map')
 local ids={};for id,d in pairs(game.data.maps)do Map.ensureMidLayout(game,id,d);ids[#ids+1]=id end;table.sort(ids);P.bind(game.data.maps)
 local file=assert(io.open(os.getenv('SHOT_DIR')..'/models.tsv','w'));file:write('map\tmodel\tx\ty\n');local count,bad,seats=0,0,0
 for _,id in ipairs(ids)do local d=game.data.maps[id];if not P.outdoor(d)then
  local pair=P.canonical(d.midLayout.pair);local spec=P.resolve(d.midLayout.pair,require('src.import.gba.versions').TILESET_PAIRS);local cells={}
  for y=0,d.height-1 do for x=0,d.width-1 do cells[x..':'..y]={cx=x,cy=y,mid=d.midLayout:midAt(x,y),collision=d.midLayout:collAt(x,y),pair=pair,primary=spec.primary,secondary=spec.secondary,ts={}}end end
  local flights=F.extract(cells,'towerStairs');V.require('Gen3Stairs').prepare(cells)
  local props=F.extract(cells);for _,p in ipairs(flights)do props[#props+1]=p end
  for _,p in ipairs(props)do if p.recipe.kind=='rsInstitution'then
   count=count+1;if p.recipe.seat then seats=seats+1 end;file:write(table.concat({id,p.recipe.name,p.cx,p.cy},'\t')..'\n')
   F.append(p,function(v)
    local l,n,r,f,b,h=1e9,1e9,-1e9,-1e9,1e9,-1e9
    for _,q in ipairs(v)do l=math.min(l,q[1]);r=math.max(r,q[1]);n=math.min(n,q[3]);f=math.max(f,q[3]);b=math.min(b,q[2]);h=math.max(h,q[2])end
    for y=math.max(0,math.floor(n/16)),math.min(d.height-1,math.floor(f/16))do for x=math.max(0,math.floor(l/16)),math.min(d.width-1,math.floor(r/16))do
     if cells[x..':'..y].collision==0 and not p.recipe.seat and not(b==0 and h==0)and l<x*16+15.99 and r>x*16+.01 and n<y*16+15.99 and f>y*16+.01 then bad=bad+1 end
    end end
   end,function()return{{0,0},{1,0},{1,1},{0,1}}end)
  end end
 end end
 file:close();assert(bad==0,'new component overlaps native walking cell')
 print('[RS INSTITUTION CENSUS] PASS',ed,count,bad,'native seats',seats);love.event.quit()
end
