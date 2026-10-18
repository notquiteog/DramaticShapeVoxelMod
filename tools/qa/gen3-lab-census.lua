-- Lab source/permission ownership and emitted-solid clearance; QA data only.
return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'),'QA profile required')
 local ed=require('src.core.GameVersion').get();local pre=({ruby='RU_',sapphire='SA_',emerald='EM_'})[ed]or'FR_'
 game:_handleBootAction({action='new_game',start={map=pre=='FR_'and'FR_PALLET_TOWN'or pre..'OLDALE_TOWN',x=10,y=9,facing='up'}})
 local V=assert(game.mods.exports.BATTLE_ART_VOXEL_FORK).lib;local Map=require('src.core.game3.map')
 local P,F=V.require('Gen3Tilesets'),V.require('Gen3Furniture')
 local ids={};for id in io.lines(assert(os.getenv('QA_MAP_LIST')))do ids[#ids+1]=id;Map.ensureMidLayout(game,id,game.data.maps[id])end;P.bind(game.data.maps)
 local Research=os.getenv('QA_RESEARCH')=='1'and V.require('Gen3ResearchRooms')
 local count,bad,pads=0,0,0;local report=assert(io.open(os.getenv('SHOT_DIR')..'/clearance.tsv','w'));report:write('map\tobject\tx\ty\tpermission\theight\n')
 local inventory=assert(io.open(os.getenv('SHOT_DIR')..'/fixtures.tsv','w'));inventory:write('map\tname\tx\ty\tdesign\trows\tpermissions\n')
 for _,id in ipairs(ids)do
  local d=game.data.maps[id];local pair=P.canonical(d.midLayout.pair);local spec=P.resolve(d.midLayout.pair,require('src.import.gba.versions').TILESET_PAIRS);local cells={}
  local plan=Research and assert(Research.profile(d,pair),'unrecognized native lab '..id)
  for y=0,d.height-1 do for x=0,d.width-1 do cells[x..':'..y]={cx=x,cy=y,mid=d.midLayout:midAt(x,y),collision=d.midLayout:collAt(x,y),pair=pair,primary=spec.primary,secondary=spec.secondary,ts={}}end end
  local props=F.extract(cells)
  for _,p in ipairs(props)do
   count=count+1;if plan then p.researchWall=plan.north+.04 end
   local rows,permissions={},{}
   for yy,row in ipairs(p.recipe.rows)do local m,c={},{};for xx,mid in ipairs(row)do m[#m+1]=string.format('%x',mid);c[#c+1]=tostring(d.midLayout:collAt(p.cx+xx-1,p.cy+yy-1))end;rows[#rows+1]=table.concat(m,',');permissions[#permissions+1]=table.concat(c,',')end
   inventory:write(table.concat({id,p.recipe.name,p.cx,p.cy,p.recipe.design or p.recipe.kind,table.concat(rows,';'),table.concat(permissions,';')},'\t')..'\n')
   if p.recipe.kind=='plant'then
   elseif p.recipe.walkablePad then pads=pads+1
   else F.append(p,function(v)
    if Research then Research.attach(p,v)end
    local l,r,n,f,h=1e9,-1e9,1e9,-1e9,-1e9
    for _,q in ipairs(v)do l=math.min(l,q[1]);r=math.max(r,q[1]);n=math.min(n,q[3]);f=math.max(f,q[3]);h=math.max(h,q[2])end
    if h>1.3 then for y=math.max(0,math.floor(n/16)),math.min(d.height-1,math.floor(f/16))do for x=math.max(0,math.floor(l/16)),math.min(d.width-1,math.floor(r/16))do
     local c=d.midLayout:collAt(x,y)
     if c==0 and l<x*16+15.99 and r>x*16+.01 and n<y*16+15.99 and f>y*16+.01 then bad=bad+1;report:write(table.concat({id,p.recipe.name,x,y,c,h},'\t')..'\n')end
    end end end
   end,function()return{{0,0},{1,0},{1,1},{0,1}}end)end
  end
 end
 report:close();inventory:close();print('[LAB CENSUS]',ed,#ids,'rooms',count,'fixtures',bad,'walking face overlaps',pads,'native pads')
 if os.getenv('QA_STRICT')=='1'then assert(bad==0,'lab solid overlaps native walking cell')end
 love.event.quit()
end
