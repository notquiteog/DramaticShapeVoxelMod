-- Repeated uninterrupted native source tour with unchanged resource ceilings.
return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'))
 local U=dofile(assert(os.getenv('QA_UTIL')))
 local edition=require('src.core.GameVersion').get();local pre=assert(({emerald='EM_',ruby='RU_',sapphire='SA_'})[edition])
 local V=assert(game.mods.exports.BATTLE_ART_VOXEL_FORK).lib
 local F,Families=V.require('Gen3ImportedFences'),V.require('Gen3FenceFamilies')
 local markers={rural149='oras_rural_fence',rustboro='oras_rustboro_fence',mauville='oras_mauville_fence',verdanturf='oras_verdanturf_fence'}
 local function fence(secondary,mid,behavior,collision)return Families.shape('general',secondary,mid,behavior,collision)end
 local C,S=V.require('Gen3Integration'),V.require('Gen3Scene')
 local Map,P,Dataset=require('src.core.game3.map'),require('src.core.game3.player'),require('src.core.game3.dataset')
 local place,refs=F.placements,{}
 local Models=V.require('SceneryModels');local image=Models.image;local imageErrors,registerErrors={},{}
 local register=Models.register
 Models.register=function(...)local ok,why=register(...);if not ok then registerErrors[#registerErrors+1]={id=(...),error=why}end;return ok,why end
 local function checkedStats()
  local a,l=Models.stats(),Models.limits
  assert(l.models==256 and l.textures==256 and l.textureBytes==8388608 and l.catalogVertices==262144 and l.catalogBytes==10485760 and l.cachedVertices==262144 and l.cachedBytes==10485760,'resource ceilings changed')
  assert(a.textureBytes<=l.textureBytes and a.catalogVertices<=l.catalogVertices and a.catalogBytes<=l.catalogBytes and a.cachedVertices<=l.cachedVertices and a.cachedBytes<=l.cachedBytes,'resource accounting exceeded its ceiling')
  return a
 end
 Models.image=function(...)
  local img,err=image(...)
  if not img then local id,texture=...;local row={id=id,texture=texture,error=err,stats=Models.stats()}
   imageErrors[#imageErrors+1]=row;print('[RURAL SOURCE IMAGE ERROR]',require('src.link.Json').encode(row))
  end
  return img,err
 end
 F.placements=function(cells)
  for _,c in pairs(cells)do local r=c.region;local def=r and r.def
   if def and fence(c.secondary,c.mid,c.behavior,c.collision)then
    refs[def.id..':'..(c.cx-(r.x or 0))..':'..(c.cy-(r.y or 0))]=c
   end
  end
  return place(cells)
 end
 game:_handleBootAction({action='new_game',start={map=pre..'RUSTBORO_CITY',x=8,y=15,facing='up'}})
 local tours=tonumber(os.getenv('QA_TOURS'))or 2;assert(tours>=2 and tours<=4)
 local out={edition=edition,maps={},expected=0,imageErrors=imageErrors,registerErrors=registerErrors,tours=tours,sourceSha256=love.data.encode('string','hex',love.data.hash('sha256',assert(V.mod:read('lib/SceneryModels.lua'))))};local targets={}
 for id,def in pairs(game.data.maps)do if Dataset.isOutdoorMapType(def.mapType)then
  local layout=Map.ensureMidLayout(game,id,def)
  if layout and layout.pair and layout.pair:match('^general__')then
   local row={id=id,width=def.width,height=def.height,grid={},cells={},views={}}
   for y=0,def.height-1 do for x=0,def.width-1 do local c=layout:cellAt(x,y)
    row.grid[#row.grid+1]={x=x,y=y,mid=c.mid,collision=c.coll,elevation=c.elev}
    local shape=fence(layout.pair:match('^general__(.+)$'),c.mid,c.behavior,c.coll)
    if shape then assert(c.coll==7);row.cells[#row.cells+1]={x=x,y=y,mid=c.mid,marker=assert(markers[shape.nativeFence])}end
   end end
   if #row.cells>0 and(not os.getenv('QA_MAP')or id:match(os.getenv('QA_MAP')))then
    local covered={}
    for i,f in ipairs(row.cells)do if not covered[i]then
     local best,score
     for dy=-8,8 do for dx=-8,8 do local x,y=f.x+dx,f.y+dy
      if x>=0 and y>=0 and x<def.width and y<def.height and layout:cellAt(x,y).coll==0 then
       local d=dx*dx+dy*dy;if not score or d<score then score=d;best={x=x,y=y}end
      end
     end end
     assert(best,'no native walkable fence viewing cell '..id)
     row.views[#row.views+1]=best
     for j,g in ipairs(row.cells)do if math.abs(g.x-best.x)<=40 and math.abs(g.y-best.y)<=40 then covered[j]=true end end
    end end
    targets[#targets+1]=row;out.expected=out.expected+#row.cells
   end
  end
 end end
 table.sort(targets,function(a,b)return a.id<b.id end)
 V.require('RenderDistance').setting:sync(64);V.require('DayNight').setting:sync('day');V.require('RenderDistance').haze=function()return nil end
 local function settle()
  local stable,last=0
  for _=1,3600 do U.wait(1);local a=S.streaming
   if S.sceneDef==Map.currentDef()and a.started+a.promoted==a.completed+a.cancelled and a.started==last then stable=stable+1 else stable=0 end
   last=a.started;if stable>=6 then break end
  end
  assert(stable>=6 and C.active and C.recovery.failures==0,'native Scene did not settle')
 end
 local function dismiss()require('src.ui.game3.map_preview_screen').dismiss();require('src.ui.game3.map_name_popup').dismiss()end
 local currentTour=0
 local function shot(name)if currentTour==1 and not os.getenv('QA_NO_SHOTS')then assert(U.shot(game,assert(os.getenv('SHOT_DIR'))..'/'..name..'.png'))end end
 local function copy(value)if type(value)~='table'then return value end;local out={};for k,v in pairs(value)do out[k]=copy(v)end;return out end
 local finalStats
 for tour=1,tours do currentTour=tour
 for _,template in ipairs(targets)do local row=copy(template);row.tour=tour
  local first=row.views[1];C.setLevel(0,game);assert(Map.load(nil,game,row.id,{x=first.x,y=first.y,facing='up'}));game.input:reset();U.wait(30);dismiss()
  -- Native on-load scripts may initialize ordinary map tiles (Route111).
  -- Compare presentation against the settled native state, never a pre-load cache.
  local initial=Map.currentDef().midLayout;row.nativeOnLoadChanges={}
  for _,g in ipairs(row.grid)do local c=initial:cellAt(g.x,g.y)
   if c.mid~=g.mid or c.coll~=g.collision or c.elev~=g.elevation then
    row.nativeOnLoadChanges[#row.nativeOnLoadChanges+1]={x=g.x,y=g.y,before=g.mid,after=c.mid}
    g.mid,g.collision,g.elevation=c.mid,c.coll,c.elev
   end
  end
  shot(row.id..'-native');C.setLevel(3,game);C.yaw=0;C.pitch=.24;settle()
  for i,v in ipairs(row.views)do
   P.reset(v.x,v.y,'up');game.input:reset();C.setLevel(3,game);C.yaw=0;C.pitch=.24;settle();dismiss();U.wait(3);shot(row.id..'-'..i..'-front')
   C.setLevel(6,game);U.wait(3);shot(row.id..'-'..i..'-first')
   C.setLevel(7,game);C.yaw=math.pi/2;C.pitch=.5;U.wait(3);shot(row.id..'-'..i..'-side')
   C.yaw=math.pi;U.wait(3);shot(row.id..'-'..i..'-rear')
  end
  local layout=Map.currentDef().midLayout;assert(Map.currentDef().id==row.id)
  for _,g in ipairs(row.grid)do local c=layout:cellAt(g.x,g.y);assert(c.mid==g.mid and c.coll==g.collision and c.elev==g.elevation,('native map changed %s %d,%d mid%d/%d coll%d/%d elev%d/%d'):format(row.id,g.x,g.y,g.mid,c.mid,g.collision,c.coll,g.elevation,c.elev))end
  local missing={};local owned=0
  for _,f in ipairs(row.cells)do local c=refs[row.id..':'..f.x..':'..f.y]
   if c and c.importedFence==f.marker then owned=owned+1 else
    missing[#missing+1]={x=f.x,y=f.y,mid=f.mid,seen=c~=nil,eligible=c and F.eligible(c)or false,
     boundary=c and c.boundary or false,prop=c and c.prop~=nil or false,civic=c and c.civic~=nil or false}
   end
  end
  row.grid=nil;row.owned=owned;row.missing=missing;row.fences=S.performanceSnapshot().fences;row.resources=checkedStats();out.maps[#out.maps+1]=row
  print('[RESOURCE TOUR MAP]',edition,tour,row.id,#row.cells,owned,#missing,require('src.link.Json').encode(row.resources))
 end
 local stats=checkedStats()
 if finalStats then assert(stats.textureBytes==finalStats.textureBytes and stats.catalogBytes==finalStats.catalogBytes and stats.catalogVertices==finalStats.catalogVertices,'repeated tour grew unique source resources')end
 finalStats=stats
 end
 out.resources=finalStats
 -- Exercise actual Scene teardown ordering, which releases its manual door
 -- meshes and owned source batches before clearing the shared asset cache.
 C.setLevel(0,game);S.release();out.afterSceneRelease=checkedStats()
 print('[RESOURCE TOUR RELEASE]',edition,require('src.link.Json').encode(out.afterSceneRelease))
 assert(out.afterSceneRelease.imageLeases==0 and out.afterSceneRelease.textures==0 and out.afterSceneRelease.textureBytes==0,'source images survived complete Scene release')
 C.setLevel(3,game);C.yaw=0;C.pitch=.24;settle();dismiss();U.wait(3)
 local last=targets[#targets];local restored=0
 for _,f in ipairs(last.cells)do local c=refs[last.id..':'..f.x..':'..f.y];if c and c.importedFence==f.marker then restored=restored+1 end end
 assert(restored==#last.cells,'source did not rebuild after resource reset')
 out.afterReload=checkedStats();out.reloadedOwners=restored
 assert(U.shot(game,assert(os.getenv('SHOT_DIR'))..'/source-after-resource-reset-front.png'))
 C.setLevel(7,game);C.yaw=math.pi/2;C.pitch=.5;U.wait(3)
 assert(U.shot(game,assert(os.getenv('SHOT_DIR'))..'/source-after-resource-reset-side.png'))
 local owned=0;for _,row in ipairs(out.maps)do owned=owned+row.owned end;out.owned=owned
 local f=assert(io.open(assert(os.getenv('SHOT_DIR'))..'/scenery-resource-tour.json','wb'));f:write(require('src.link.Json').encode(out));f:close()
 assert(#imageErrors==0 and #registerErrors==0,'source resource failures during uninterrupted tour')
 assert(owned==out.expected*tours,'unbuilt native source fence cells: '..(out.expected*tours-owned))
 print('[HOENN RESOURCE TOUR ACCEPTANCE]',edition,#targets,tours,out.expected,owned,'unchanged-grid',C.recovery.failures)
end
