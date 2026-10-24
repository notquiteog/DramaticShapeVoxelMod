-- Native Emerald Navel Rock wall/portal fixtures; raw captures stay local.
return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'),'disposable QA identity required')
 local U=dofile(assert(os.getenv('QA_UTIL')));local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib
 local ed=require('src.core.GameVersion').get();local pre=({emerald='EM_',ruby='RU_',sapphire='SA_',firered='FR_',leafgreen='FR_'})[ed];local hoenn=pre~='FR_';assert(ed=='emerald','Emerald Navel vocabulary fixture')
 local Map=require('src.core.game3.map');local C=V.require('Gen3Integration');local S=V.require('Gen3Scene');local P=require('src.core.game3.player');local dir=assert(os.getenv('SHOT_DIR'));local J=require('src.link.Json')
 game:_handleBootAction({action='new_game',start={map=pre..(hoenn and'LITTLEROOT_TOWN'or'PALLET_TOWN'),x=7,y=9,facing='down'}})
 V.require('VisualStyles').setting('interiors'):sync('modern');V.require('RenderDistance').setting:sync(64);V.require('DayNight').setting:sync('day');V.require('RenderDistance').haze=function()return nil end
 local targets={'NAVEL_ROCK_ENTRANCE','NAVEL_ROCK_B1F','NAVEL_ROCK_FORK'};for i=1,11 do targets[#targets+1]=string.format('NAVEL_ROCK_DOWN%02d',i)end;for i=1,4 do targets[#targets+1]='NAVEL_ROCK_UP'..i end;targets[#targets+1]='NAVEL_ROCK_BOTTOM';targets[#targets+1]='NAVEL_ROCK_TOP'
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
 out:close()
 -- Verify the real exit through the native warp-trigger tile. The arch is
 -- behind that trigger and must leave the actual approach visible/open.
 C.setLevel(0,game);assert(Map.load(nil,game,'EM_NAVEL_ROCK_ENTRANCE',{x=10,y=25,facing='down'}));U.wait(12)
 require('src.ui.game3.map_preview_screen').dismiss();require('src.ui.game3.map_name_popup').dismiss();require('src.ui.game3.start_menu').close();P.reset(10,25,'down')
 C.setLevel(6,game);C.yaw=math.pi;C.pitch=.12;U.wait(45);assert(U.shot(game,dir..'/native-exit-approach.png'))
 C.setLevel(3,game);U.wait(8);U.tap(game,'down');U.wait(35)
 assert(P.cellX==10 and P.cellY==26,'native approach step changed')
 -- Arrow warps activate on the next native directional intent from the
 -- trigger tile, rather than automatically when stepping onto it.
 U.tap(game,'down');U.wait(150)
 assert(Map.currentDef().id=='EM_NAVEL_ROCK_EXTERIOR','native exit warp blocked or changed')
 assert(C.recovery.failures==0,'exit transition renderer recovery');assert(U.shot(game,dir..'/native-exit-complete.png'))
 print('[NAVEL NATIVE EXIT] PASS',Map.currentDef().id)
 print('[CAVE COMPLETE]',ed);love.event.quit()
end
