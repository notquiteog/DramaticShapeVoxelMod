-- Exact full-cell footprint audit of the new regional families, five editions.
-- POKEPORT_DRIVER=<this file>, SHOT_DIR=<scratch>; requires a private *-qa identity.
-- Does not edit saves, maps, permissions, or imported art.
return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'),'refusing a non-QA profile')
 local U=dofile('tests/drivers/util.lua');local edition=require('src.core.GameVersion').get()
 local prefix=({emerald='EM_',ruby='RU_',sapphire='SA_'})[edition]
 game:_handleBootAction({action='new_game',start={map=prefix and prefix..'OLDALE_TOWN' or 'FR_PALLET_TOWN',x=10,y=9,facing='down'}})
 U.wait(5)
 local V=assert(game.mods.exports.BATTLE_ART_VOXEL_FORK).lib
 local P=V.require('Gen3Tilesets');local Trees=V.require('Gen3RegionalTrees')
 local Map=require('src.core.game3.map');local Versions=require('src.import.gba.versions')
 local ids={};for id in pairs(game.data.maps)do ids[#ids+1]=id end;table.sort(ids)
 local f=assert(io.open(assert(os.getenv('SHOT_DIR'))..'/regional-trees.csv','w'))
 f:write('map,pair,mid,x,y,width,depth,family,claimed_cells\n')
 local total,claimed=0,0
 for index,id in ipairs(ids)do
  local def=game.data.maps[id];Map.ensureMidLayout(game,id,def)
  if def.midLayout and P.outdoor(def)then
   local spec=P.resolve(def.midLayout.pair,Versions.TILESET_PAIRS);local cells={}
   for y=0,def.height-1 do for x=0,def.width-1 do
    cells[x..':'..y]={cx=x,cy=y,pair=P.canonical(def.midLayout.pair),primary=spec.primary,secondary=spec.secondary,
     mid=def.midLayout:midAt(x,y),collision=def.midLayout:collAt(x,y),shape={kind='flat'}}
   end end
   local count=Trees.prepare(cells,edition);total=total+count
   for _,c in pairs(cells)do
    assert(c.collision==def.midLayout:collAt(c.cx,c.cy),'native permissions changed')
    if c.regionalTree then claimed=claimed+1;assert(c.collision==7)end
    if c.regionalTree and c.shape.root then
     local s=c.shape;local b=s.treeBounds;local cx,cz=c.cx*16+s.anchorX,c.cy*16+s.anchorZ
     assert(cx-s.modelWidth/2>b[1] and cx+s.modelWidth/2<b[3],'x footprint spill')
     assert(cz-s.modelDepth/2>b[2] and cz+s.modelDepth/2<b[4],'z footprint spill')
     local n=0
     for y=b[2]/16,b[4]/16-1 do for x=b[1]/16,b[3]/16-1 do
      local member=assert(cells[x..':'..y]);assert(member.collision==7 and member.regionalTree==c,'walking or foreign cell in model footprint');n=n+1
     end end
     f:write(('%s,%s,%03X,%d,%d,%.2f,%.2f,%s,%d\n'):format(id,c.pair,c.mid,c.cx,c.cy,s.modelWidth,s.modelDepth,s.treeFamily,n))
    end
   end
  end
  if index%15==0 then U.wait(1)end
 end
 f:close();print('[REGIONAL TREES] PASS',edition,total,'models',claimed,'blocked cells','0 walking intersections')
 assert(total>0,'regional recipes matched no native source');love.event.quit(0)
end
