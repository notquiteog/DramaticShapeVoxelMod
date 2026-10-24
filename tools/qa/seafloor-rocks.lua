-- Native Seafloor current-room rock volumes; disposable isolated profiles.
return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'),'disposable QA identity required')
 local U=dofile(assert(os.getenv('QA_UTIL')));local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib
 local ed=require('src.core.GameVersion').get();local pre=({emerald='EM_',ruby='RU_',sapphire='SA_',firered='FR_',leafgreen='FR_'})[ed];local hoenn=pre~='FR_';assert(ed=='emerald'or ed=='ruby'or ed=='sapphire','RSE current-room fixtures')
 local Map=require('src.core.game3.map');local C=V.require('Gen3Integration');local S=V.require('Gen3Scene');local P=require('src.core.game3.player');local dir=assert(os.getenv('SHOT_DIR'));local J=require('src.link.Json')
 game:_handleBootAction({action='new_game',start={map=pre..(hoenn and'LITTLEROOT_TOWN'or'PALLET_TOWN'),x=7,y=9,facing='down'}})
 V.require('VisualStyles').setting('interiors'):sync('modern');V.require('RenderDistance').setting:sync(64);V.require('DayNight').setting:sync('day');V.require('RenderDistance').haze=function()return nil end
 local targets={'SEAFLOOR_CAVERN_ROOM6','SEAFLOOR_CAVERN_ROOM7'}
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
 -- Match complete native north/south frames and exercise their real
 -- native warp input. Geometry never changes the underlying trigger cells.
 local arches={}
 for y=0,d.height-1 do for x=0,d.width-3 do local a=d.midLayout:cellAt(x,y);local b=d.midLayout:cellAt(x+1,y);local c=d.midLayout:cellAt(x+2,y)
  if(a.mid==0x290 and b.mid==0x291 and c.mid==0x292)or(a.mid==0x298 and b.mid==0x299 and(c.mid==0x29A or c.mid==0x271))then
   local north=a.mid==0x290;local wy=north and y or y-1;local warp
   for _,w in ipairs(d.warps)do if w.x==x+1 and w.y==wy then warp=w;break end end
   assert(warp,'native arch lacks expected warp')
   arches[#arches+1]={x=x+1,y=north and y+2 or y-2,dir=north and'up'or'down',yaw=north and 0 or math.pi,warp=warp}
  end
 end end
 assert(#arches==2,'expected two complete native arch owners')
 for n,a in ipairs(arches)do
  C.setLevel(0,game);assert(Map.load(nil,game,id,{x=a.x,y=a.y,facing=a.dir}));U.wait(12)
  require('src.ui.game3.map_preview_screen').dismiss();require('src.ui.game3.map_name_popup').dismiss();require('src.ui.game3.start_menu').close();P.reset(a.x,a.y,a.dir)
  local cell=Map.currentDef().midLayout:cellAt(a.x,a.y);assert(cell.coll==0 or cell.coll==43,'arch camera is not native walking floor')
  C.setLevel(6,game);C.yaw=a.yaw;C.pitch=.12;U.wait(40);assert(U.shot(game,dir..'/'..id..'-arch-'..n..'-approach.png'))
  C.setLevel(3,game);U.wait(8)
  for step=1,5 do if Map.currentDef().id~=id then break end;U.tap(game,a.dir);U.wait(35)end
  U.wait(120);assert(Map.currentDef().id==a.warp.destMap,'actual native arch warp changed')
  assert(C.recovery.failures==0,'native warp renderer recovery');assert(U.shot(game,dir..'/'..id..'-arch-'..n..'-complete.png'))
  print('[SEAFLOOR NATIVE ARCH WARP] PASS',id,n,Map.currentDef().id)
 end
 else print('[CAVE MISSING]',id)end end
 out:close();print('[CAVE COMPLETE]',ed);love.event.quit()
end
