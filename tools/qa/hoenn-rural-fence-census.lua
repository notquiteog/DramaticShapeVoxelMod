-- Read actual edition-native outdoor layouts without mutating map data.
return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'))
 local U=dofile(assert(os.getenv('QA_UTIL')))
 local edition=require('src.core.GameVersion').get()
 local pre=assert(({emerald='EM_',ruby='RU_',sapphire='SA_'})[edition])
 game:_handleBootAction({action='new_game',start={map=pre..'RUSTBORO_CITY',x=8,y=15,facing='up'}})
 U.wait(4)
 local Dataset,Map=require('src.core.game3.dataset'),require('src.core.game3.map')
 local wanted={[0x138]=true,[0x139]=true,[0x13a]=true,[0x140]=true,[0x141]=true,[0x142]=true,[0x148]=true,[0x149]=true,[0x14a]=true}
 local out={edition=edition,maps={},cells=0,byMid={}}
 for id,def in pairs(game.data.maps)do if Dataset.isOutdoorMapType(def.mapType)then
  local layout=Map.ensureMidLayout(game,id,def)
  if layout and layout.pair and layout.pair:match('^general__')then
   local row={map=id,width=def.width,height=def.height,pair=layout.pair,cells={}}
   for y=0,def.height-1 do for x=0,def.width-1 do local c=layout:cellAt(x,y)
    if wanted[c.mid]then
     row.cells[#row.cells+1]={x=x,y=y,mid=c.mid,collision=c.coll,elevation=c.elev,behavior=c.behavior}
     local k=('%03x:%s'):format(c.mid,tostring(c.coll));out.byMid[k]=(out.byMid[k]or 0)+1;out.cells=out.cells+1
    end
   end end
   out.maps[#out.maps+1]=row
  end
 end end
 table.sort(out.maps,function(a,b)return a.map<b.map end)
 local f=assert(io.open(assert(os.getenv('SHOT_DIR'))..'/rural-native-census.json','wb'))
 f:write(require('src.link.Json').encode(out));f:close()
 print('[HOENN RURAL NATIVE CENSUS]',edition,#out.maps,out.cells)
end
