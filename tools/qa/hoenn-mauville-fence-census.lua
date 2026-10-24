-- Read actual edition-native outdoor layouts without mutating map data.
return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'))
 local U=dofile(assert(os.getenv('QA_UTIL')))
 local edition=require('src.core.GameVersion').get()
 local pre=assert(({emerald='EM_',ruby='RU_',sapphire='SA_'})[edition])
 game:_handleBootAction({action='new_game',start={map=pre..'RUSTBORO_CITY',x=8,y=15,facing='up'}})
 U.wait(4)
 local Dataset,Map=require('src.core.game3.dataset'),require('src.core.game3.map')
 local wanted=assert(game.mods.exports.BATTLE_ART_VOXEL_FORK).lib.require('Gen3FenceFamilies').mauville
 local out={edition=edition,maps={},cells=0,byMid={}}
 local function write(name,bytes)local f=assert(io.open(assert(os.getenv('SHOT_DIR'))..'/'..name,'wb'));f:write(bytes);f:close()end
 local ts=assert(require('src.core.game3.tileset_native').get('general__mauville'))
 for _,pair in ipairs{{ts.imageData,'base'},{ts.overImageData,'over'}}do
  local bytes=pair[1]:encode('png');write('mauville-native-'..pair[2]..'-atlas.png',bytes:getString());bytes:release()
 end
 out.atlasCols=ts.cols;out.slots={}
 for mid,slot in pairs(ts.midToSlot)do out.slots[#out.slots+1]={mid=mid,slot=slot}end
 for id,def in pairs(game.data.maps)do if Dataset.isOutdoorMapType(def.mapType)then
  local layout=Map.ensureMidLayout(game,id,def)
  if layout and layout.pair and layout.pair=='general__mauville'then
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
 local f=assert(io.open(assert(os.getenv('SHOT_DIR'))..'/mauville-native-census.json','wb'))
 f:write(require('src.link.Json').encode(out));f:close()
 print('[HOENN MAUVILLE NATIVE CENSUS]',edition,#out.maps,out.cells)
end
