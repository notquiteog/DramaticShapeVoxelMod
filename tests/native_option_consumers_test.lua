-- Focused native-option contracts; no GPU or gameplay coverage is implied.
local checks=0
local function check(ok,why)checks=checks+1;assert(ok,why)end
local function load(name,V)return assert(loadfile('lib/'..name..'.lua'))(V)end
local cache,stored={},{}
local V={mod={id='BATTLE_ART_VOXEL_FORK',options={get=function(_,key)return stored[key]end}}}
function V.require(name)if not cache[name]then cache[name]=load(name,V)end;return cache[name]end
local Setting=V.require('ModSetting')
local s=Setting.new('example','EXAMPLE',{false,true},{'OFF','ON'})
local persisted=0
local native={options={},mods={modOptions={}},persistOptions=function()persisted=persisted+1 end}
s:setIndex(2,native)
check(native.options.modOptions[V.mod.id].example==true,'native options bucket')
check(native.mods.modOptions[V.mod.id].example==true and persisted==1,'native persistence')
local gb={save={options={}},mods={modOptions={}},writeOptions=function()persisted=persisted+1 end}
s:setIndex(1,gb)
check(gb.save.options.modOptions[V.mod.id].example==false and persisted==2,'GB false value and persistence')
local Camera=V.require('Gen3Integration')
Camera.pitch=0;Camera.look(.1,.2);check(Camera.pitch==.2,'normal native look')
V.require('CameraSettings').invertY:setIndex(2)
Camera.pitch=0;Camera.look(.1,.2);check(Camera.pitch==-.2,'inverted native look')
Camera.yaw=math.pi/2
local x,z=Camera.moveVector(1,0)
check(math.abs(x-1)<1e-8 and math.abs(z)<1e-8,'east-facing movement intent')
Camera.yaw=0;x,z=Camera.moveVector(0,1)
check(x==1 and z==0,'north-facing strafe intent')

local calls={}
local function hit(name,value)calls[#calls+1]={name,value};return value end
local fakeSetting=function()return {get=function()return 2 end}end
local modules={SpatialUpscale={setting=s},ModSetting=Setting,CameraSettings={invertY=s},
 DayNight={setting=s,update=function(dt)hit('clock',dt)end,
 applyRig=function(out)hit('rig',out)end,tint=function(out)return out and {1,.4,.2}or{1,1,1}end},
 Sky={dress=function(bg)bg.bands={{1,2,3}};return bg end},
 AntiAlias={setting=s,expand=function(w,h)return w*2,h*2 end,
 resolve=function(c,w,h,slot)hit('resolve',slot);return 'resolved' end,invalidate=function()end},
 Voxel3D={},WorldUnderlay={setting=s,COLORS={black={0,0,0}},selected=function()return 'black'end,
 draw=function(_,x,z,color)hit('underlay',color);return true end},
 TiltShift={setLevel=function(n)hit('tilt',n)end,apply=function(c)hit('blur',c);return 'blurred'end,invalidate=function()end},
 CommunityVisuals={sky=s},Water={setting=s}}
local Options=load('Gen3SceneOptions',{require=function(name)return assert(modules[name],name)end})
Options.tilt:setIndex(3);Options.update(.25)
check(calls[1][1]=='clock' and calls[1][2]==.25,'clock advances on native update')
check(calls[2][1]=='tilt' and calls[2][2]==2,'tilt option reaches postprocess')
local bg=Options.environment(false,{.1,.2,.3,1})
check(bg.bands and modules.Voxel3D.tint[2]==.4,'outdoor sky/tint')
Options.environment(true,{0,0,0,1})
check(modules.Voxel3D.tint[2]==1 and calls[#calls][2]==false,'indoor noon rig/tint reset')
check(not Options.underlay(true,0,0,bg),'interiors retain native room underlay')
check(Options.underlay(false,0,0,bg) and calls[#calls][2][1]==0,'BLACK material reaches floor')
x,z=Options.expand(320,180);check(x==640 and z==360,'AA changes render dimensions')
check(Options.finish('source',320,180)=='blurred' and calls[#calls][2]=='resolved','AA resolves before tilt')

local mode,depth,beginOK='off',true,true
local drawn,mirrors,restored,plain,casts=0,0,0,0,0
local R={curveK=0,eye={},vp={},cell=1,size=function()return 320,180 end,
 draw=function()plain=plain+1 end,depthReadable=function()return depth end,
 beginCast=function()return 'cast'end,endCast=function()casts=casts+1 end,
 beginWater=function(fn)mirrors=mirrors+1;if fn then fn()end;return 'mirror','depth'end,
 endWater=function()restored=restored+1 end}
local Water={CAST_ALPHA=.5,enabled=function()return mode~='off'end,
 begin=function(ctx,skyOnly)check(ctx.screen[1]==320,'water screen binding');return beginOK or skyOnly end,
 draw=function()drawn=drawn+1 end,finish=function()end}
local Pass=load('WaterSurfacePass',{require=function(name)return ({Voxel3D=R,Water=Water,VoxelGrid={enabled=function()return false end}})[name]end})
check(not Pass.draw({{'mesh','atlas'}}) and plain==1 and mirrors==0,'OFF draws native flat water')
mode='full';local actor=0
check(Pass.draw({{'mesh','atlas'}},function()actor=actor+1 end,function()actor=actor+1 end),'FULL renders reflection')
check(drawn==1 and mirrors==1 and restored==1 and casts==1 and actor==2,'reflection actor and state lifecycle')
beginOK=false
check(Pass.draw({{'mesh','atlas'}}) and restored==3,'failed full pass falls back to sky and restores state')
depth=false;mode='off';R.curveK=.1
check(not Pass.draw({{'mesh','atlas'}}) and plain==2,'curve depth prepass draws flat once')

local catalog=V.require('SettingsCatalog')
local Support=V.require('OptionSupport')
local seen={};for _,row in ipairs(catalog)do check(not seen[row.key],'duplicate catalog key');seen[row.key]=true end
for gen=1,3 do
 local inventory=Support.inventory(gen)
 check(#inventory==#catalog,'complete support inventory')
 for _,row in ipairs(inventory)do
  check(row.status~='implemented' or type(row.consumer)=='string','implemented options have a consumer')
 end
end
local rows=Support.rows({{key='aa',type='choice'}},3)
check(#rows==#catalog-1,'support rows omit the migrated duplicate 3D-BTL alias')
check(rows[1].readOnly~=true,'actual control remains editable')
local unsupported;for _,row in ipairs(rows)do if row.key=='pokeballSuction'then unsupported=row end end
check(unsupported and unsupported.readOnly and unsupported.supportOnly,'missing adapter is diagnostic, never fake writable control')
print('PASS '..checks..' native option consumer checks')
