-- Verify actual integrated Scene ownership; source upload fixtures alone miss legacy claims.
return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'),'QA profile required')
 local U=dofile(assert(os.getenv('QA_UTIL'),'QA_UTIL must name frame-driver helper'))
 local ed=require('src.core.GameVersion').get();local pre=({ruby='RU_',sapphire='SA_',emerald='EM_'})[ed]or'FR_'
 local V=assert(game.mods.exports.BATTLE_ART_VOXEL_FORK).lib;local C,S=V.require('Gen3Integration'),V.require('Gen3Scene')
 local Map,P=require('src.core.game3.map'),require('src.core.game3.player');local dir=os.getenv('SHOT_DIR');local json=require('src.link.Json');local results={}
 local missing=os.getenv('QA_MISSING_ASSETS')=='1'
 if missing then local read=V.mod.read;V.mod.read=function(self,path)
  if path:match('^assets/scenery/viridian%-house/')or path:match('^assets/scenery/oras%-dewford%-house/')or path:match('^assets/scenery/pallet%-buildings/')or path:match('^assets/scenery/oras%-route104%-')or path:match('^assets/scenery/interiors/')or path:match('^assets/scenery/hgss%-')then return nil end
  return read(self,path)
 end end
 game:_handleBootAction({action='new_game',start={map=pre=='FR_'and'FR_PALLET_TOWN'or pre..'ROUTE104',x=pre=='FR_'and 6 or 17,y=pre=='FR_'and 12 or 53,facing='up'}})
 U.wait(5);V.require('RenderDistance').setting:sync(16);V.require('DayNight').setting:sync('day');V.require('RenderDistance').haze=function()return nil end
 local function settle()
  local stable,last=0
  for _=1,2000 do U.wait(1);local a=S.streaming
   if S.sceneDef==Map.currentDef() and a.started+a.promoted==a.completed+a.cancelled and last==a.started then stable=stable+1 else stable=0 end
   last=a.started;if stable>=6 then break end
  end;assert(stable>=6 and C.active and C.recovery.failures==0,'renderer/stream failure')
 end
 local function dismiss()require('src.ui.game3.map_preview_screen').dismiss();require('src.ui.game3.map_name_popup').dismiss()end
 local function shot(n)assert(U.shot(game,dir..'/'..n..'.png'))end
 local function load(id,x,y)
  C.setLevel(0,game);assert(Map.load(nil,game,id,{x=x,y=y,facing='up'}));game.input:reset();C.yaw=0;C.pitch=math.rad(8);C.setLevel(3,game);settle();dismiss();U.wait(3)
 end
 local function hash(d)
  local a={};for y=0,d.height-1 do for x=0,d.width-1 do local c=d.midLayout:cellAt(x,y);a[#a+1]=table.concat({c.mid,c.coll,c.elev},':')end end
  return love.data.encode('string','hex',love.data.hash('sha256',table.concat(a,';')))
 end
 local function flush()local f=assert(io.open(dir..'/results.json','w'));f:write(json.encode(results));f:close()end

 local facade=V.require('Gen3ModernHoennBuildings');local original=facade.prepare
 facade.prepare=function(cells,newMesh,parts)
  for _,c in pairs(cells)do local r=c.region;local id=r and r.def and r.def.id
   if id==pre..'PETALBURG_CITY'and c.cx-(r.x or 0)==17 and(c.cy-(r.y or 0)==9 or c.cy-(r.y or 0)==10)then
    local row={x=c.cx,y=c.cy,mid=c.mid,collision=c.collision,base=c.base,primary=c.primary,pair=c.pair,boundary=not not c.boundary,stageHidden=not not c.stageHidden,prop=c.prop and c.prop.recipe and c.prop.recipe.name or not not c.prop,civic=c.civic and c.civic.custom and c.civic.custom.name or not not c.civic,gym=not not c.gym,stairs=not not c.stairs,column=not not c.column,layered=c.ts and c.ts.layered,idxBytes=c.ts and c.ts.idxBlob and #c.ts.idxBlob,overBytes=c.ts and c.ts.overBlob and #c.ts.overBlob,shape=c.shape and c.shape.kind}
    print('[ACTUAL NOTICE CELL]',json.encode(row))
    if c.mid==0x131 then
     local N=V.require('Gen3ImportedGymNotices');local top=cells[c.cx..':'..(c.cy-1)];local p=c.prop
     assert(N.eligible(c,cells),'reviewed native notice must qualify')
     local old=p.recipe.name;p.recipe.name='unreviewed_fixture';assert(not N.eligible(c,cells));p.recipe.name=old
     old=p.w;p.w=32;assert(not N.eligible(c,cells));p.w=old
     old=top.prop;top.prop={};assert(not N.eligible(c,cells));top.prop=old
     old=p.stageHidden;p.stageHidden=true;assert(not N.eligible(c,cells));p.stageHidden=old
     assert(not N.build(cells,function()return nil end,{}));assert(not p.importedGymNotice and not c.importedGymNotice and not top.importedGymNotice,'failed source claimed native notice')
     print('[ACTUAL NOTICE OWNER GUARDS+ROLLBACK] PASS',ed)
    end

   end
  end
  local result,err,n=original(cells,newMesh,parts);assert(n==1 and not err,'Petalburg notice missing');print('[ACTUAL NOTICE RESULT]',n,err);return result,err,n
 end
 local fixtures={{'petalburg','PETALBURG_CITY',8,15,'hoennGyms',1,'hoennMarts',1}}
 V.require('RenderDistance').setting:sync(64)
 for _,f in ipairs(fixtures)do
  load(pre..f[2],f[3],f[4]);local before=hash(Map.currentDef());local snap=S.performanceSnapshot()
  print('[MODERN BUILDING]',ed,f[1],json.encode(snap.scenery),json.encode(V.require('SceneryModels').stats()))
  for i=5,#f,2 do assert(snap.scenery[f[i]]>=f[i+1],f[1]..' source missing '..f[i]..' '..tostring(snap.scenery[f[i]]))end
  shot(f[1]..'-front');C.setLevel(6,game);settle();shot(f[1]..'-first')
  C.yaw=math.rad(25);settle();shot(f[1]..'-rotate')
  assert(hash(Map.currentDef())==before,'native collision/warps changed')
 end
 print('[MODERN BUILDINGS] PASS',ed,'native hash unchanged, streaming recovery zero')
end
