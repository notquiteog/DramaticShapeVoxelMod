-- Disposable native runtime cave geometry and gameplay-invariance checks.
-- QA_EXPORT_ATLAS=1 optionally writes native review pixels only to SHOT_DIR.
return function(game)
 local U=dofile(assert(os.getenv('QA_UTIL')));local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib
 local ed=require('src.core.GameVersion').get();local pre=({emerald='EM_',ruby='RU_',sapphire='SA_',firered='FR_',leafgreen='FR_'})[ed];local hoenn=pre~='FR_'
 local Map=require('src.core.game3.map');local C=V.require('Gen3Integration');local S=V.require('Gen3Scene');local P=require('src.core.game3.player');local dir=assert(os.getenv('SHOT_DIR'));local J=require('src.link.Json')
 game:_handleBootAction({action='new_game',start={map=pre..(hoenn and'LITTLEROOT_TOWN'or'PALLET_TOWN'),x=7,y=9,facing='down'}})
 V.require('VisualStyles').setting('interiors'):sync('modern');V.require('RenderDistance').setting:sync(64);V.require('DayNight').setting:sync('day');V.require('RenderDistance').haze=function()return nil end
 local targets=hoenn and{'GRANITE_CAVE_1F','RUSTURF_TUNNEL','METEOR_FALLS_1F_1R','SHOAL_CAVE_LOW_TIDE_ICE_ROOM'}or{'MT_MOON_1F','SEAFOAM_ISLANDS_1F','FOUR_ISLAND_ICEFALL_CAVE_ENTRANCE'}
 local out=assert(io.open(dir..'/audit.jsonl','w'))
 local function hash(d)local a={};for y=0,d.height-1 do for x=0,d.width-1 do local c=d.midLayout:cellAt(x,y);a[#a+1]=table.concat({c.mid,c.coll,c.elev},':')end end;return love.data.encode('string','hex',love.data.hash('sha256',table.concat(a,';')))end
 for _,suffix in ipairs(targets)do local id=pre..suffix;local d=game.data.maps[id]
 if d then
 C.setLevel(0,game);Map.ensureMidLayout(game,id,d);local bx,by,score;local counts={};local grid={}
 local behaviors=require('src.core.game3.scripting.interaction_scripts').behaviors[d.midLayout.pair]or{};local ts=assert(require('src.core.game3.tileset_native').get(d.midLayout.pair));local mids={}
 for y=0,d.height-1 do local row={};for x=0,d.width-1 do local a=d.midLayout:cellAt(x,y);local key=string.format('%03X/%d/%d',a.mid,a.coll,behaviors[a.mid]or-1);counts[key]=(counts[key]or 0)+1;row[#row+1]=key;mids[a.mid]=true;local r=(x-d.width/2)^2+(y-d.height/2)^2;if (a.coll==0 or a.coll==43) and(not score or r<score)then bx,by,score=x,y,r end end;grid[#grid+1]=row end
 assert(Map.load(nil,game,id,{x=bx,y=by,facing='up'}));U.wait(12);require('src.ui.game3.map_preview_screen').dismiss();require('src.ui.game3.map_name_popup').dismiss();require('src.ui.game3.start_menu').close();assert(bx,'walkable target');P.reset(bx,by,'up');game.session.flashLevel=0;U.wait(3);assert(U.shot(game,dir..'/'..id..'-native.png'))
 if os.getenv('QA_EXPORT_ATLAS')=='1'then local sorted={};for mid in pairs(ts.midToSlot)do sorted[#sorted+1]=mid end;table.sort(sorted)
 local sheet=love.image.newImageData(16*16,math.ceil(#sorted/16)*24)
 local f=assert(io.open(dir..'/'..id..'-atlas.txt','w'));for i,mid in ipairs(sorted)do local slot=assert(ts.midToSlot[mid]);sheet:paste(ts.imageData,(i-1)%16*16,math.floor((i-1)/16)*24,slot%ts.cols*16,math.floor(slot/ts.cols)*16,16,16);f:write(string.format('%d %03X\n',i,mid))end;f:close();local png=sheet:encode('png');local pf=assert(io.open(dir..'/'..id..'-atlas.png','wb'));pf:write(png:getString());pf:close() end
 local nativeHash,warpsBefore=hash(d),J.encode(d.warps);C.setLevel(3,game);local stable,last=0
 for _=1,1600 do U.wait(1);local a=S.streaming;if S.sceneDef==Map.currentDef()and a.started+a.promoted==a.completed+a.cancelled and last==a.started then stable=stable+1 else stable=0 end;last=a.started;if stable>=5 then break end end
 assert(stable>=5 and C.active and C.recovery.failures==0,'renderer');assert(U.shot(game,dir..'/'..id..'-modern.png'))
 for i,v in ipairs({{0,.15},{math.pi/2,.15},{math.pi,.15},{-math.pi/2,.15}})do C.setLevel(6,game);C.yaw=v[1];C.pitch=v[2];U.wait(8);assert(U.shot(game,dir..'/'..id..'-first-'..i..'.png'))end
 assert(hash(d)==nativeHash and J.encode(d.warps)==warpsBefore,'renderer changed native cells/warps');local kinds={};local spec=V.require('Gen3Tilesets').resolve(d.midLayout.pair,require('src.import.gba.versions').TILESET_PAIRS);for y=0,d.height-1 do for x=0,d.width-1 do local a=d.midLayout:cellAt(x,y);local k=V.require('Gen3TileShape').of(spec.primary,spec.secondary,a.mid,behaviors[a.mid],a.coll).kind;kinds[k]=(kinds[k]or 0)+1 end end
 out:write(J.encode({nativeHash=nativeHash,geometryKinds=kinds,edition=ed,map=id,pair=d.midLayout.pair,x=bx,y=by,counts=counts,grid=grid,width=d.width,height=d.height,warps=d.warps})..'\n');out:flush();print('[CAVE PASS]',id)
 else print('[CAVE MISSING]',id)end end
 out:close();print('[CAVE COMPLETE]',ed);love.event.quit()
end
