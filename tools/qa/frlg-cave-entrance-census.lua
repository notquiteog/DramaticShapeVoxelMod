-- Identifier-only census of every outdoor warp to a native underground map.
return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'))
 game:_handleBootAction({action='new_game',start={map='FR_PALLET_TOWN',x=8,y=8,facing='down'}})
 local V=assert(game.mods.exports.BATTLE_ART_VOXEL_FORK).lib;V.require('Gen3Integration').setLevel(0,game)
 local Map=require('src.core.game3.map');local Pairs=V.require('Gen3Tilesets');local E=V.require('Gen3CaveEntrances');local json=require('src.link.Json');local out={}
 for id,d in pairs(game.data.maps)do if Pairs.outdoor(d)then
  Map.ensureMidLayout(game,id,d)
  for _,w in ipairs(d.warps or{})do local dest=game.data.maps[w.destMap]
   if dest and dest.mapType==4 then
    local c=d.midLayout:cellAt(w.x,w.y);local scope=false
    for _,p in ipairs(E.locations[id]or{})do if p[1]==w.x and p[2]==w.y then scope=true end end
    out[#out+1]={edition=require('src.core.GameVersion').get(),map=id,x=w.x,y=w.y,destination=w.destMap,pair=d.midLayout.pair,nativeDrawing=c.mid,nativeCollision=c.coll,nativeElevation=c.elev,openMouthCandidate=scope,sourceModelEligible=false,renderedAccepted=false,runtime='v'..require('src.core.Version').engine}
   end
  end
 end end
 table.sort(out,function(a,b)return a.map<b.map or a.map==b.map and(a.x<b.x or a.x==b.x and a.y<b.y)end)
 local f=assert(io.open(os.getenv('SHOT_DIR')..'/cave-inventory.json','w'));f:write(json.encode(out));f:close();print('[FRLG CAVE INVENTORY] PASS',#out)
end
