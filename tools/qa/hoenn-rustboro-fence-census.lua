-- Exact native source pixels and actual post-classification Scene fence owners.
return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'))
 local U=dofile(assert(os.getenv('QA_UTIL')))
 local edition=require('src.core.GameVersion').get();local pre=assert(({emerald='EM_',ruby='RU_',sapphire='SA_'})[edition]);local id=pre..'RUSTBORO_CITY'
 local V=assert(game.mods.exports.BATTLE_ART_VOXEL_FORK).lib
 local F=V.require('Gen3ImportedFences');local families=V.require('Gen3FenceFamilies');local place=F.placements;local seen,refs={},{}
 F.placements=function(cells)
  local rows=place(cells);local counts={};for _,p in ipairs(rows)do counts[p.source]=(counts[p.source]or 0)+1 end
  for _,c in pairs(cells)do local r=c.region;local def=r and r.def
   if def and def.id==id then
    local x,y=c.cx-(r.x or 0),c.cy-(r.y or 0)
    refs[x..':'..y]=c
    seen[x..':'..y]={x=x,y=y,mid=c.mid,collision=c.collision,behavior=c.behavior,base=c.base,
     kind=c.shape and c.shape.kind,nativeFence=c.shape and c.shape.nativeFence,
     eligible=F.eligible(c)or false,segments=counts[c]or 0,boundary=c.boundary~=nil and c.boundary~=false,
     civic=c.civic and(c.civic.custom and c.civic.custom.name or c.civic.kind)or false,
     prop=c.prop and(c.prop.recipe and c.prop.recipe.name or c.prop.kind or true)or false,
     stairs=c.stairs~=nil and c.stairs~=false,stageHidden=c.stageHidden~=nil and c.stageHidden~=false}
   end
  end
  return rows
 end
 game:_handleBootAction({action='new_game',start={map=id,x=8,y=15,facing='up'}})
 local C,S=V.require('Gen3Integration'),V.require('Gen3Scene');local Map,P=require('src.core.game3.map'),require('src.core.game3.player')
 local dir=assert(os.getenv('SHOT_DIR'));local def=Map.currentDef();local grid={};local bymid={}
 for y=0,def.height-1 do for x=0,def.width-1 do local c=def.midLayout:cellAt(x,y);grid[#grid+1]={x=x,y=y,mid=c.mid,collision=c.coll,elevation=c.elev};bymid[c.mid]=(bymid[c.mid]or 0)+1 end end
 local ts=assert(require('src.core.game3.tileset_native').get(def.midLayout.pair))
 local function write(path,bytes)local f=assert(io.open(dir..'/'..path,'wb'));f:write(bytes);f:close()end
 local function png(data,name)if data then local bytes=data:encode('png');write(name,bytes:getString());bytes:release()end end
 png(ts.imageData,'rustboro-native-base-atlas.png');png(ts.overImageData,'rustboro-native-over-atlas.png')
 C.setLevel(0,game);U.wait(5);assert(U.shot(game,dir..'/rustboro-native.png'))
 V.require('RenderDistance').setting:sync(64);V.require('DayNight').setting:sync('day');V.require('RenderDistance').haze=function()return nil end
 C.setLevel(3,game);C.yaw=0;C.pitch=.24
 local stable,last=0
 for _=1,3000 do U.wait(1);local a=S.streaming
  if S.sceneDef==Map.currentDef()and a.started+a.promoted==a.completed+a.cancelled and last==a.started then stable=stable+1 else stable=0 end
  last=a.started;if stable>=6 then break end
 end
 assert(stable>=6 and C.active and C.recovery.failures==0)
 require('src.ui.game3.map_preview_screen').dismiss();require('src.ui.game3.map_name_popup').dismiss();U.wait(3)
 for _,q in ipairs{{8,15,'north'},{8,53,'south'},{20,40,'center'},{18,20,'gym'},{34,29,'east'},{18,56,'gate'}}do
  assert(def.midLayout:cellAt(q[1],q[2]).coll==0,'QA viewpoint must be native walkable')
  P.reset(q[1],q[2],'up');C.yaw=0;C.pitch=.24;U.wait(12);assert(U.shot(game,dir..'/rustboro-modern-'..q[3]..'.png'))
  C.yaw=math.pi/2;U.wait(4);assert(U.shot(game,dir..'/rustboro-modern-'..q[3]..'-side.png'))
 end
 for _,row in ipairs(grid)do local c=def.midLayout:cellAt(row.x,row.y)
  assert(c.mid==row.mid and c.coll==row.collision and c.elev==row.elevation,'Native map changed')
 end
 local slots={};for mid,slot in pairs(ts.midToSlot)do slots[#slots+1]={mid=mid,slot=slot}end
 for k,c in pairs(refs)do seen[k].importedFence=c.importedFence or false end
 local metadata={edition=edition,map=id,width=def.width,height=def.height,pair=def.midLayout.pair,grid=grid,scene=seen,slots=slots,atlasCols=ts.cols}
 local json=require('src.link.Json');write('rustboro-fences.json',json.encode(metadata))
 local count,eligible,built=0,0,0;for _,c in pairs(seen)do count=count+1;if c.eligible then eligible=eligible+1 end;if c.importedFence then built=built+1 end end
 assert(count==#grid,'Scene census did not reach every native city cell')
 print('[RUSTBORO FENCE EXACT CENSUS]',edition,count,eligible,built,'unchanged-native-grid',C.recovery.failures)
 if os.getenv('EXPECTED_FENCES')then assert(eligible==tonumber(os.getenv('EXPECTED_FENCES')) and built==eligible,'missing live fence owners')end
end
