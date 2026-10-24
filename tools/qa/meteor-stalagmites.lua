-- Exact native Meteor two-cell spikes; disposable profiles only.
-- QA_BEFORE=1 retains the pre-batch native flat drawing.
-- QA_MISSING_METEOR=1 omits original PNG bytes to exercise closed native art.
return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'),'disposable QA identity required')
 local U=dofile(assert(os.getenv('QA_UTIL')));local V=assert(game.mods.exports.BATTLE_ART_VOXEL_FORK).lib
 local ed=require('src.core.GameVersion').get();local pre=assert(({emerald='EM_',ruby='RU_',sapphire='SA_',firered='FR_',leafgreen='FR_'})[ed]);local Map=require('src.core.game3.map');local C=V.require('Gen3Integration');local S=V.require('Gen3Scene');local P=require('src.core.game3.player')
 local dir=assert(os.getenv('SHOT_DIR'));local missing=os.getenv('QA_MISSING_METEOR')=='1';local before=os.getenv('QA_BEFORE')=='1'
 if before then for _,r in ipairs(V.require('Gen3Furniture').recipes)do if r.name=='hoenn_meteor_stalagmite'then r.pair='__disabled_before' end end end
 if missing then local read=V.mod.read;V.mod.read=function(self,path)if path:match('^assets/scenery/oras%-meteor%-stalagmite/')then return nil end;return read(self,path)end end
 V.require('VisualStyles').setting('interiors'):sync('modern');V.require('RenderDistance').setting:sync(64);V.require('DayNight').setting:sync('day');V.require('RenderDistance').haze=function()return nil end
 game:_handleBootAction({action='new_game',start={map=pre..((ed=='firered'or ed=='leafgreen')and'PALLET_TOWN'or'LITTLEROOT_TOWN'),x=7,y=9,facing='down'}})
 local json=require('src.link.Json');local list={};local id=pre..'METEOR_FALLS_1F_1R'
 local sourceBytes=assert(V.mod:read('lib/ImportedMeteorStalagmiteData.lua'));local sourceHash=love.data.encode('string','hex',love.data.hash('sha256',sourceBytes))
 if ed=='emerald'or ed=='ruby'or ed=='sapphire'then
  local targets={};for _,q in ipairs{{6,1},{17,13},{3,24},{16,25},{28,27}}do targets[#targets+1]={x=q[1],y=q[2],family='hoenn_meteor_stalagmite',model='oras_meteor_stalagmite'}end
  list[1]={map=id,targets=targets,serverCount=5,sourceCandidates={},nativeHash=({emerald='961614392805352a2a230a8c7bfbd62c7f875c7018b3da5028c147bbf263e588',ruby='82dc4a9a5ef0d8537eba2b8f2566a677552c07938ceb1ad117c32ccc30261009',sapphire='82dc4a9a5ef0d8537eba2b8f2566a677552c07938ceb1ad117c32ccc30261009'})[ed]}
 end
 local out=assert(io.open(dir..'/contacts.jsonl','w'))
 local function shot(n)assert(U.shot(game,dir..'/'..n..'.png'))end
 local function settle()
  local stable,last=0
  for _=1,1600 do U.wait(1);local a=S.streaming;if S.sceneDef==Map.currentDef()and a.started+a.promoted==a.completed+a.cancelled and last==a.started then stable=stable+1 else stable=0 end;last=a.started;if stable>=5 then break end end
  assert(stable>=5 and C.active and C.recovery.failures==0,'renderer failed')
 end
 local function hash(d)local a={};for y=0,d.height-1 do for x=0,d.width-1 do local c=d.midLayout:cellAt(x,y);a[#a+1]=table.concat({c.mid,c.coll,c.elev},':')end end;return love.data.encode('string','hex',love.data.hash('sha256',table.concat(a,';')))end
 for _,r in ipairs(list)do
  C.setLevel(0,game);local pristine=game.data.maps[r.map];Map.ensureMidLayout(game,r.map,pristine);local cellsBefore={}
  for y=0,pristine.height-1 do for x=0,pristine.width-1 do local c=pristine.midLayout:cellAt(x,y);cellsBefore[x..':'..y]={c.mid,c.coll,c.elev}end end
  assert(Map.load(nil,game,r.map,{x=5,y=5,facing='up'}));U.wait(10)
  require('src.ui.game3.start_menu').close();local d=Map.currentDef();for _,f in ipairs(r.targets)do local q={};for y=0,1 do for x=0,0 do local c=d.midLayout:cellAt(f.x+x,f.y+y);q[#q+1]={mid=c.mid,collision=c.coll,elevation=c.elev}end end;print('[SPIKE EXACT ROWS]',r.map,f.x,f.y,json.encode(q))end;local best,bx,by=math.huge
  for y=2,d.height-1 do for x=0,d.width-1 do local c=d.midLayout:cellAt(x,y);local dist=(x-d.width/2)^2+(y-d.height/2)^2;if(c.coll==0 or c.coll==43)and dist<best then best,bx,by=dist,x,y end end end
  assert(bx,'missing native floor');P.reset(bx,by,'up');require('src.ui.game3.map_preview_screen').dismiss();require('src.ui.game3.map_name_popup').dismiss();U.wait(2);shot(r.map..'-native');local original=hash(d);local originalWarps=json.encode(d.warps);local nativeDelta={}
  for y=0,d.height-1 do for x=0,d.width-1 do local c=d.midLayout:cellAt(x,y);local a=cellsBefore[x..':'..y];if a[1]~=c.mid or a[2]~=c.coll or a[3]~=c.elev then nativeDelta[#nativeDelta+1]={x=x,y=y,before=a,after={c.mid,c.coll,c.elev}}end end end
  C.yaw=0;C.pitch=math.rad(12);C.setLevel(3,game);settle();U.wait(5);shot(r.map..'-modern')
  local snapshot=S.performanceSnapshot();local count=snapshot.scenery.interiors;local base=0;for _,n in pairs(r.sourceCandidates)do base=base+n end
  local expected=missing and 0 or base+(before and 0 or #r.targets)-(r.sourceCandidates.oras_meteor_stalagmite or 0)
  assert(count==expected and(missing or not snapshot.scenery.interiorError),'source count '..r.map..' '..count..'/'..expected..' '..tostring(snapshot.scenery.interiorError))
  local renderedFixtures={}
  if os.getenv('QA_VIEWS')=='1'then
   local Fixtures=V.require('Gen3Furniture');local ts=require('src.core.game3.tileset_native').get(d.midLayout.pair);local cells={};local canonical=V.require('Gen3Tilesets').canonical(d.midLayout.pair);local spec=V.require('Gen3Tilesets').resolve(d.midLayout.pair,require('src.import.gba.versions').TILESET_PAIRS)
   for y=0,d.height-1 do for x=0,d.width-1 do local c=d.midLayout:cellAt(x,y);cells[x..':'..y]={cx=x,cy=y,mid=c.mid,collision=c.coll,pair=canonical,ts=ts,primary=spec.primary,secondary=spec.secondary}end end
   local targetKeys={};for _,f in ipairs(r.targets)do targetKeys[f.family..':'..f.x..':'..f.y]=f.model end
   local viewTargets=Fixtures.extract(cells);if before then viewTargets={};for _,f in ipairs(r.targets)do viewTargets[#viewTargets+1]={cx=f.x,cy=f.y,recipe={name=f.family,rows={{0x254},{0x25C}}}}end end
   for _,p in ipairs(viewTargets)do if targetKeys[p.recipe.name..':'..p.cx..':'..p.cy]then
    local behaviors=require('src.core.game3.scripting.interaction_scripts').behaviors[d.midLayout.pair]or{};for _,row in ipairs(p.recipe.rows)do for _,mid in ipairs(row)do assert(behaviors[mid]~=0x86,'cupboard is actually a TV')end end
    local tx,tz=p.cx+.5,p.cy+1.5
    local views={}
    for n,angle in ipairs{0,math.pi/2,math.pi,-math.pi/2}do
     local camera,score
     for y=math.max(0,p.cy-7),math.min(d.height-1,p.cy+8)do for x=math.max(0,p.cx-7),math.min(d.width-1,p.cx+7)do
      local cell=cells[x..':'..y];local dx,dz=x+.5-tx,y+.5-tz;local distance=math.sqrt(dx*dx+dz*dz)*16
      if cell and not cell.prop and(cell.collision==0 or cell.collision==43)and distance>=24 then
       local viewAngle=math.atan2(-dx,dz);local delta=math.abs((viewAngle-angle+math.pi)%(2*math.pi)-math.pi)
       local cost=delta*100+math.abs(distance-48)
       if not score or cost<score then camera={x,y,viewAngle};score=cost end
      end
     end end
     assert(camera,'no native walkable fixture view')
     P.reset(camera[1],camera[2],'up');C.yaw=camera[3];C.pitch=math.rad(8);C.setLevel(6,game);settle();U.wait(5)
     local name=r.map..'-'..p.cx..'-'..p.cy..'-first-'..n;shot(name)
     C.setLevel(7,game);C.pitch=math.rad(35);settle();U.wait(5);shot(r.map..'-'..p.cx..'-'..p.cy..'-orbit-'..n)
     views[#views+1]={capture=name,x=camera[1],y=camera[2],yaw=camera[3]}
    end
    renderedFixtures[#renderedFixtures+1]={family=p.recipe.name,x=p.cx,y=p.cy,model=targetKeys[p.recipe.name..':'..p.cx..':'..p.cy],views=views}
   end end
   assert(#renderedFixtures==r.serverCount,'not every server fixture was viewed')
  end
  assert(hash(d)==original and json.encode(d.warps)==originalWarps,'native cells/warps mutated')
  assert(original==r.nativeHash,'unexpected Meteor native map fixture')
  out:write(json.encode({edition=ed,map=r.map,sourceDataHash=sourceHash,count=count,nativeHash=original,missing=missing,before=before,censusHash=r.nativeHash,nativeMapScriptDelta=nativeDelta,renderedFixtures=renderedFixtures}),'\n');out:flush()
 end
 out:close();print('[ORAS METEOR SPIKES] PASS',ed,#list)
end
