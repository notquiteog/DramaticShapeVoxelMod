-- Native Center/Mart ownership and walking clearance; no pixels are exported.
return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'),'QA profile required')
 local ed=require('src.core.GameVersion').get();local pre=({ruby='RU_',sapphire='SA_',emerald='EM_'})[ed]or'FR_'
 local U=dofile('tests/drivers/util.lua')
 game:_handleBootAction({action='new_game',start={map=pre=='FR_'and'FR_PALLET_TOWN'or pre..'OLDALE_TOWN',x=10,y=9,facing='up'}})
 local V=assert(game.mods.exports.BATTLE_ART_VOXEL_FORK).lib;local Map=require('src.core.game3.map')
 local P,F,S=V.require('Gen3Tilesets'),V.require('Gen3Furniture'),V.require('Gen3ServiceRooms')
 local ids={};for _,city in ipairs(pre=='FR_'and{'VIRIDIAN_CITY','PEWTER_CITY'}or{'OLDALE_TOWN','PETALBURG_CITY'})do
  for _,room in ipairs{'POKEMON_CENTER_1F','POKEMON_CENTER_2F','MART'}do ids[#ids+1]=pre..city..'_'..room end
 end
 for _,id in ipairs(ids)do Map.ensureMidLayout(game,id,game.data.maps[id])end;P.bind(game.data.maps)
 local count,bad,seats=0,0,0;local report=assert(io.open(os.getenv('SHOT_DIR')..'/clearance.tsv','w'));report:write('map\tobject\tcell_x\tcell_y\theight_low\theight_high\n')
 for _,id in ipairs(ids)do
  local d=game.data.maps[id];local pair=P.canonical(d.midLayout.pair);local plan=assert(S.profile(d,pair),'source envelope not recognized '..id)
  local spec=P.resolve(d.midLayout.pair,require('src.import.gba.versions').TILESET_PAIRS);local cells={}
  for y=0,d.height-1 do for x=0,d.width-1 do cells[x..':'..y]={cx=x,cy=y,mid=d.midLayout:midAt(x,y),collision=d.midLayout:collAt(x,y),pair=pair,primary=spec.primary,secondary=spec.secondary,ts={}}end end
  local props=F.extract(cells)
  for _,p in ipairs(props)do
   p.serviceRoom=true;count=count+1
   if p.recipe.kind=='plant'then -- Decorative foliage/card is not a furniture solid.
   elseif p.recipe.walkablePad then seats=seats+1
   else F.append(p,function(v)
    local l,r,n,f,b,h=1e9,-1e9,1e9,-1e9,1e9,-1e9
    for _,q in ipairs(v)do l=math.min(l,q[1]);r=math.max(r,q[1]);n=math.min(n,q[3]);f=math.max(f,q[3]);b=math.min(b,q[2]);h=math.max(h,q[2])end
    if h>1.3 then
     for y=math.max(0,math.floor(n/16)),math.min(d.height-1,math.floor(f/16))do for x=math.max(0,math.floor(l/16)),math.min(d.width-1,math.floor(r/16))do
      local pad=false
      for _,q in ipairs(p.recipe.walkablePads or{})do if l>=p.cx*16+q[1]and r<=p.cx*16+q[3]and n>=p.cy*16+q[2]and f<=p.cy*16+q[4]and h<=q[5]then pad=true end end
      if not pad and d.midLayout:collAt(x,y)==0 and l<x*16+15.99 and r>x*16+.01 and n<y*16+15.99 and f>y*16+.01 then
       bad=bad+1;report:write(table.concat({id,p.recipe.name,x,y,b,h},'\t')..'\n')
      end
     end end
    end
   end,function()return{{0,0},{1,0},{1,1},{0,1}}end)end
  end
 end
 report:close();print('[SERVICE CENSUS]',ed,#ids,'rooms',count,'fixtures',bad,'walking face overlaps',seats,'native pads')
 if os.getenv('QA_STRICT')=='1'then assert(bad==0,'service solid overlaps native walking cell')end
 love.event.quit()
end
