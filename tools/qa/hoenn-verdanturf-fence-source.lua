-- Actual Scene owners across every edition-native General outdoor Verdanturf pickets.
return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'))
 local U=dofile(assert(os.getenv('QA_UTIL')))
 local edition=require('src.core.GameVersion').get();local pre=assert(({emerald='EM_',ruby='RU_',sapphire='SA_'})[edition])
 local V=assert(game.mods.exports.BATTLE_ART_VOXEL_FORK).lib
 local F,Families=V.require('Gen3ImportedFences'),V.require('Gen3FenceFamilies')
 local C,S=V.require('Gen3Integration'),V.require('Gen3Scene')
 local Map,P,Dataset=require('src.core.game3.map'),require('src.core.game3.player'),require('src.core.game3.dataset')
 local place,refs=F.placements,{}
 local Models=V.require('SceneryModels');local image=Models.image;local imageErrors={}
 Models.image=function(...)
  local img,err=image(...)
  if not img then local id,texture=...;local row={id=id,texture=texture,error=err,stats=Models.stats()}
   imageErrors[#imageErrors+1]=row;print('[VERDANTURF SOURCE IMAGE ERROR]',require('src.link.Json').encode(row))
  end
  return img,err
 end
 F.placements=function(cells)
  for _,c in pairs(cells)do local r=c.region;local def=r and r.def
   if def and (c.secondary=='mauville'and Families.verdanturf[c.mid])then
    refs[def.id..':'..(c.cx-(r.x or 0))..':'..(c.cy-(r.y or 0))]=c
   end
  end
  return place(cells)
 end
 game:_handleBootAction({action='new_game',start={map=pre..'RUSTBORO_CITY',x=8,y=15,facing='up'}})
 local out={edition=edition,maps={},expected=0,imageErrors=imageErrors};local targets={}
 for id,def in pairs(game.data.maps)do if Dataset.isOutdoorMapType(def.mapType)then
  local layout=Map.ensureMidLayout(game,id,def)
  if layout and layout.pair and layout.pair=='general__mauville'then
   local row={id=id,width=def.width,height=def.height,grid={},cells={},views={}}
   for y=0,def.height-1 do for x=0,def.width-1 do local c=layout:cellAt(x,y)
    row.grid[#row.grid+1]={x=x,y=y,mid=c.mid,collision=c.coll,elevation=c.elev}
    if Families.verdanturf[c.mid]then assert(c.coll==7);row.cells[#row.cells+1]={x=x,y=y,mid=c.mid}end
   end end
   if #row.cells>0 and(not os.getenv('QA_MAP')or id:match(os.getenv('QA_MAP')))then
    local covered,reviewed={},{}
    for i,f in ipairs(row.cells)do if not covered[i]or(os.getenv('QA_REVIEW_ALL')and not reviewed[f.mid])then
     reviewed[f.mid]=true
     local best,score
     for dy=-8,8 do for dx=-8,8 do local x,y=f.x+dx,f.y+dy
      if x>=0 and y>=0 and x<def.width and y<def.height and layout:cellAt(x,y).coll==0 then
       local d=dx*dx+(dy-3)*(dy-3);if not score or d<score then score=d;best={x=x,y=y}end
      end
     end end
     assert(best,'no native walkable fence viewing cell '..id)
     row.views[#row.views+1]=best
     for j,g in ipairs(row.cells)do if math.abs(g.x-best.x)<=40 and math.abs(g.y-best.y)<=40 then covered[j]=true end end
    end end
    for _,v in ipairs{{x=5,y=9,yaw=math.pi,facing='down'},{x=6,y=14,yaw=0}}do
     assert(layout:cellAt(v.x,v.y).coll==0,'native rear/close viewpoint blocked');row.views[#row.views+1]=v
    end
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
 local function shot(name)assert(U.shot(game,assert(os.getenv('SHOT_DIR'))..'/'..name..'.png'))end
 for _,row in ipairs(targets)do
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
   P.reset(v.x,v.y,v.facing or'up');game.input:reset();C.setLevel(3,game);C.yaw=v.yaw or 0;C.pitch=.24;settle();dismiss();U.wait(3);shot(row.id..'-'..i..'-front')
   C.setLevel(6,game);U.wait(3);shot(row.id..'-'..i..'-first')
   C.setLevel(7,game);C.yaw=(v.yaw or 0)+math.pi/2;C.pitch=.5;U.wait(3);shot(row.id..'-'..i..'-side')
   C.yaw=(v.yaw or 0)+math.pi;U.wait(3);shot(row.id..'-'..i..'-rear')
  end
  local layout=Map.currentDef().midLayout;assert(Map.currentDef().id==row.id)
  for _,g in ipairs(row.grid)do local c=layout:cellAt(g.x,g.y);assert(c.mid==g.mid and c.coll==g.collision and c.elev==g.elevation,('native map changed %s %d,%d mid%d/%d coll%d/%d elev%d/%d'):format(row.id,g.x,g.y,g.mid,c.mid,g.collision,c.coll,g.elevation,c.elev))end
  local missing={};local owned=0
  for _,f in ipairs(row.cells)do local c=refs[row.id..':'..f.x..':'..f.y]
   if c and c.importedFence=='oras_verdanturf_fence'then owned=owned+1 else
    missing[#missing+1]={x=f.x,y=f.y,mid=f.mid,seen=c~=nil,eligible=c and F.eligible(c)or false,
     boundary=c and c.boundary or false,prop=c and c.prop~=nil or false,civic=c and c.civic~=nil or false}
   end
  end
  row.grid=nil;row.owned=owned;row.missing=missing;row.fences=S.performanceSnapshot().fences;out.maps[#out.maps+1]=row
  print('[VERDANTURF SCENE MAP]',edition,row.id,#row.cells,owned,#missing,row.fences and row.fences.error)
 end
 local owned=0;for _,row in ipairs(out.maps)do owned=owned+row.owned end;out.owned=owned
 local f=assert(io.open(assert(os.getenv('SHOT_DIR'))..'/verdanturf-scene-owners.json','wb'));f:write(require('src.link.Json').encode(out));f:close()
 if os.getenv('QA_EXPECT_NATIVE_FALLBACK')then
  assert(owned==0 and out.expected>0,'missing source must retain all native fence art')
  print('[HOENN VERDANTURF SOURCE FALLBACK]',edition,#targets,out.expected,owned,'unchanged-grid',C.recovery.failures);return
 end
 assert(owned==out.expected,'unbuilt native Verdanturf pickets cells: '..(out.expected-owned))
 print('[HOENN VERDANTURF SOURCE ACCEPTANCE]',edition,#targets,out.expected,owned,'unchanged-grid',C.recovery.failures)
end
