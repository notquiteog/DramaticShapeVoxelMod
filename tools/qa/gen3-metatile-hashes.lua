-- Gen3 native metatile fingerprints for cross-edition source comparison.
--
--   POKEPORT_DRIVER=tools/qa/gen3-metatile-hashes.lua SHOT_DIR=<existing dir>
--   optional QA_HASH_SHEETS=1 also writes per-pair atlas PNGs to SHOT_DIR
--
-- Writes <edition>-metatile-hashes.tsv: canonical pair, native pair, mid,
-- FNV-1a hash of the composited 16x16 under+over RGBA pixels. Comparing two
-- editions' hashes shows which identically numbered drawings are actually the
-- same art; a matching ID with a different hash is a different object. Hashes
-- and optional QA sheets stay in scratch; never commit imported art.
return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'),'refusing a non-QA profile')
 local U=dofile('tests/drivers/util.lua')
 local edition=require('src.core.GameVersion').get()
 local start=edition=='emerald' and 'EM_OLDALE_TOWN' or edition=='ruby' and 'RU_OLDALE_TOWN'
  or edition=='sapphire' and 'SA_OLDALE_TOWN' or 'FR_PALLET_TOWN'
 game:_handleBootAction({action='new_game',start={map=start,x=10,y=9,facing='down'}})
 U.wait(5)
 local V=assert(game.mods.exports.BATTLE_ART_VOXEL_FORK).lib
 local Pairs=V.require('Gen3Tilesets');local Map=require('src.core.game3.map')
 local Tiles=require('src.core.game3.tileset_native')
 local ids={};for id in pairs(game.data.maps)do ids[#ids+1]=id end;table.sort(ids)
 local pairsUsed={}
 for i,id in ipairs(ids)do local def=game.data.maps[id];Map.ensureMidLayout(game,id,def)
  if def.midLayout and def.midLayout.pair then pairsUsed[def.midLayout.pair]=pairsUsed[def.midLayout.pair] or id end
  if i%30==0 then U.wait(1)end
 end
 Pairs.bind(game.data.maps)
 local list={};for p in pairs(pairsUsed)do list[#list+1]=p end;table.sort(list)
 local dir=assert(os.getenv('SHOT_DIR'))
 local out=assert(io.open(dir..'/'..edition..'-metatile-hashes.tsv','w'))
 out:write('canonical\tnative\tmid\thash\texample_map\tslot\tcols\n')
 local bit=require('bit');local sheets=os.getenv('QA_HASH_SHEETS')=='1'
 for _,pair in ipairs(list)do
  local ts
  for _=1,600 do ts=Tiles.get(pair);if ts and ts.imageData then break end;U.wait(1)end
  if ts and ts.imageData then
   local under,over=ts.imageData,ts.overImageData
   local mids={};for mid in pairs(ts.midToSlot)do mids[#mids+1]=mid end;table.sort(mids)
   for _,mid in ipairs(mids)do
    local slot=ts.midToSlot[mid];local sx,sy=(slot%ts.cols)*16,math.floor(slot/ts.cols)*16
    local h=2166136261
    for _,img in ipairs({under,over})do if img then
     for y=0,15 do for x=0,15 do
      local r,g,b,a=img:getPixel(sx+x,sy+y)
      for _,v in ipairs({r,g,b,a})do h=bit.bxor(h,math.floor(v*255+.5));h=bit.tobit(h+bit.lshift(h,1)+bit.lshift(h,4)+bit.lshift(h,7)+bit.lshift(h,8)+bit.lshift(h,24))end
     end end
    end end
    out:write(('%s\t%s\t%03X\t%s\t%s\t%d\t%d\n'):format(Pairs.canonical(pair),pair,mid,bit.tohex(h),pairsUsed[pair],slot,ts.cols))
   end
   if sheets then
    local f=io.open(dir..'/atlas-'..Pairs.canonical(pair)..'.png','wb')
    if f then f:write(under:encode('png'):getString());f:close()end
    if over then local g=io.open(dir..'/atlas-over-'..Pairs.canonical(pair)..'.png','wb');if g then g:write(over:encode('png'):getString());g:close()end end
   end
  else print('[HASH MISSING]',pair)end
  U.wait(1)
 end
 out:close()
 -- Native layouts (ids/collision only) let QA composite source views offline.
 local lay=assert(io.open(dir..'/'..edition..'-layouts.tsv','w'))
 lay:write('map\tcanonical\tnative\toutdoor\tw\th\tmids\tcollision\n')
 for _,id in ipairs(ids)do local def=game.data.maps[id]
  if def.midLayout and def.midLayout.pair then
   local m,c={},{}
   for y=0,def.height-1 do for x=0,def.width-1 do m[#m+1]=('%03X'):format(def.midLayout:midAt(x,y));c[#c+1]=tostring(def.midLayout:collAt(x,y))end end
   lay:write(('%s\t%s\t%s\t%s\t%d\t%d\t%s\t%s\n'):format(id,Pairs.canonical(def.midLayout.pair),def.midLayout.pair,tostring(Pairs.outdoor(def)),def.width,def.height,table.concat(m,' '),table.concat(c,' ')))
  end
 end
 lay:close();print('[HASHES]',edition,#list,'pairs');love.event.quit(0)
end
