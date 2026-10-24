return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'))
 local U=dofile(assert(os.getenv('QA_UTIL')))
 local edition=require('src.core.GameVersion').get();local pre=assert(({emerald='EM_',ruby='RU_',sapphire='SA_'})[edition])
 game:_handleBootAction({action='new_game',start={map=pre..'RUSTBORO_CITY',x=8,y=15,facing='up'}});U.wait(4)
 local Dataset,Map,Tiles=require('src.core.game3.dataset'),require('src.core.game3.map'),require('src.core.game3.tileset_native')
 local out={edition=edition,maps={},entrances={},atlases={}}
 local function write(name,bytes)local f=assert(io.open(assert(os.getenv('SHOT_DIR'))..'/'..name,'wb'));f:write(bytes);f:close()end
 for id,def in pairs(game.data.maps)do if Dataset.isOutdoorMapType(def.mapType)then
  local warps={}
  for i,w in ipairs(def.warps or{})do local d=game.data.maps[w.destMap]
   if d and(d.mapType==4 or w.destMap:match('CAVE')or w.destMap:match('TUNNEL')or w.destMap:match('FALLS')or w.destMap:match('CHAMBER'))then
    warps[#warps+1]={x=w.x,y=w.y,dest=w.destMap,destWarp=w.destWarp,destType=d.mapType,destCave=d.cave}
   end
  end
  if #warps>0 then
   local layout=assert(Map.ensureMidLayout(game,id,def));local ts=assert(Tiles.get(layout.pair));local row={id=id,pair=layout.pair,width=def.width,height=def.height,warps=warps,grid={}}
   for y=0,def.height-1 do for x=0,def.width-1 do local c=layout:cellAt(x,y)
    row.grid[#row.grid+1]={x=x,y=y,mid=c.mid,collision=c.coll,elevation=c.elev,behavior=c.behavior}
   end end
   if not out.atlases[layout.pair]then local atlas={cols=ts.cols,slots={}};out.atlases[layout.pair]=atlas
    for mid,slot in pairs(ts.midToSlot)do atlas.slots[#atlas.slots+1]={mid=mid,slot=slot}end
    for _,pair in ipairs{{ts.imageData,'base'},{ts.overImageData,'over'}}do if pair[1]then local bytes=pair[1]:encode('png');write(layout.pair..'-'..pair[2]..'.png',bytes:getString());bytes:release()end end
   end
   out.maps[#out.maps+1]=row
  end
 end end
 table.sort(out.maps,function(a,b)return a.id<b.id end)
 write('cave-native-census.json',require('src.link.Json').encode(out));print('[HOENN CAVE NATIVE CENSUS]',edition,#out.maps)
end
