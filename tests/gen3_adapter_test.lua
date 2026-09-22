-- Headless contract tests. Native rendering is covered by gen3_views_driver.
local root=os.getenv('DS_MOD_PATH') or '.'
local G=assert(loadfile(root..'/lib/Generation.lua'))()
local ver={generation=function()return 3 end,engine=function()return 'game3' end,get=function()return 'firered' end}
package.loaded['src.core.GameVersion']=ver;G.reset()
assert(G.isGen3() and not G.isGen2() and G.lineage()=='game3')
assert(G.screenId('BoxMenu')=='BoxMenu')
ver.engine=nil;G.reset();assert(G.lineage()=='game3')
ver.generation=function()return 2 end;G.reset();assert(G.lineage()=='gs' and G.screenId('BoxMenu')=='Gen2PcMenu')
local Shape=assert(loadfile(root..'/lib/Gen3TileShape.lua'))()
assert(Shape.of('building','pallet_town',0x14).kind=='flat')
assert(Shape.of('general','pallet_town',0x14).root)
assert(Shape.of('general','viridian_city',0x281).kind=='roof')
assert(Shape.of('general','other_city',0x281).kind=='flat')
local cells={}
for i,mid in ipairs({0x281,0x289,0x291,0x298,0x2a0}) do
 local cy=i+2;cells['5:'..cy]={cx=5,cy=cy,pair='pallet_outdoor',shape=Shape.of('general','pallet_town',mid)}
end
for key in pairs(cells) do local c=assert(Shape.column(cells,key));assert(c.first==3 and c.last==7 and c.roofs==3 and c.walls==2 and c.height==32) end
-- Generated cache pair names survive without import-time Versions entries.
local Pairs=assert(loadfile(root..'/lib/Gen3Tilesets.lua'))()
local generated=Pairs.resolve('general__rom_opaque',{})
assert(generated.primary=='general' and generated.secondary=='rom_opaque')
assert(not Pairs.supports({midLayout={pair='general__rom_opaque'},environment='INDOOR'},generated))
assert(Pairs.supports({midLayout={pair='general__rom_opaque'},environment='TOWN'},generated))
assert(not Pairs.supports({midLayout={},environment='TOWN',mapType=4},generated),'cave header lost to cached environment default')
assert(not Pairs.supports({midLayout={},environment='TOWN',mapType=8},generated),'indoor header lost to cached environment default')
assert(not Pairs.supports({midLayout={pair='unreviewed'}},{primary='building'}))
local Furniture=assert(loadfile(root..'/lib/Gen3Furniture.lua'))()
local fc={}
for y,row in ipairs({{0x4C,0x4D},{0x54,0x55}})do for x,mid in ipairs(row)do
 fc[x..':'..y]={cx=x,cy=y,mid=mid,primary='building',pair='house',ts={}}
end end
local props=Furniture.extract(fc);assert(#props==1 and props[1].recipe.name=='checked_table')
assert(#Furniture.extract(fc)==0,'a drawing was modelled twice')
local count,maxY=0,0
Furniture.append(props[1],function(vertices,uv)
 count=count+1
 for i,v in ipairs(vertices)do
  assert(v[1]>=16 and v[1]<=48 and v[3]>=16 and v[3]<=48,'table changed footprint')
  assert(v[2]>=0 and v[2]<10,'table is taller than the player')
  assert(uv[i][1]>=0 and uv[i][1]<=1 and uv[i][2]>=0 and uv[i][2]<=1)
  maxY=math.max(maxY,v[2])
 end
end,function()return {{0,0},{1,0},{1,1},{0,1}}end)
assert(count>20 and maxY>9,'table has no surface/legs')
-- A partial match or another primary must never consume a floor tile.
fc['2:2'].mid=1;for _,c in pairs(fc)do c.prop=nil end
assert(#Furniture.extract(fc)==0)
for _,c in pairs(fc)do c.primary='general' end;fc['2:2'].mid=0x55
assert(#Furniture.extract(fc)==0)
-- A shorter trim column must share the adjacent roof's height and ridge.
local joined={}
for x=1,3 do for y=1,(x==1 and 3 or 4)do
 joined[x..':'..y]={cx=x,cy=y,pair='pallet',shape={kind=y<=2 and 'roof' or 'wall'}}
end end
Shape.layout(joined)
for _,c in pairs(joined)do assert(c.column.height==32 and c.column.front==80)end
local native,draws,presents,moves=0,0,0,{}
local Field={draw=function()native=native+1 end}
local Tilt={level=4,angle=1}
local Display={present=function(game)assert(Tilt.level==0 and Tilt.angle==0);Field.draw(game,320,180) end}
local Player={update=function(_,input)moves[#moves+1]={up=input:isDown('up'),right=input:isDown('right'),b=input:isDown('b'),pressed=input.wasPressed and input:wasPressed('right')} end}
package.loaded['src.core.game3.field_view']=Field
package.loaded['src.core.game3.display']=Display
package.loaded['src.core.game3.player']=Player
package.loaded['src.core.game3.battle']={isActive=function()return false end}
package.loaded['src.render.Tilt']=Tilt
local fail,needsNative,canDraw=false,false,true
local Scene={nativeRequired=function()return needsNative end,
 draw=function()draws=draws+1;if fail then error('test GPU error')end;return canDraw end,
 restore=function()end,release=function()end}
local hooks,events={},{}
local mod={id='BATTLE_ART_VOXEL_FORK',version='test',exports={},
 options={get=function()end,define=function()end},
 hooks={wrap=function(_,key,fn)hooks[key]=fn end},events={on=function(_,key,fn)events[key]=fn end}}
local V={mod=mod};function V.require(name)
 if name=='Gen3Scene' then return Scene end
 if name=='ModSetting' then return assert(loadfile(root..'/lib/ModSetting.lua'))(V) end
 error(name)
end
local A=assert(loadfile(root..'/lib/Gen3Integration.lua'))(V);A.install()
local game={phase='field',session={},options={}}
Display.present(game);assert(A.active and draws==1 and native==0 and Tilt.angle==1 and Tilt.level==4)
A.setLevel(7);A.yaw=math.pi/2
Player.update(game,{isDown=function(_,key)return key=='up' or key=='b' end,wasPressed=function(_,key)return key=='up' end})
assert(moves[1].right and not moves[1].up and moves[1].b and moves[1].pressed)
needsNative=true;Field.draw(game);assert(not A.active and native==1)
Player.update(game,{isDown=function(_,key)return key=='up' end});assert(moves[2].up and not moves[2].right)
needsNative=false;canDraw=false;Field.draw(game);assert(not A.active and native==2)
canDraw=true;hooks['input.key'](function()error('3 forwarded')end,game,{key='3',phase='pressed'});assert(A.level==0)
events['mod.options_changed']({mod=mod.id,key='fireredCamera',value=7});assert(A.level==7)
fail=true;Field.draw(game);assert(native==3 and not A.active)
Field.draw(game);assert(native==4 and draws==3,'failed GPU must stop retrying each frame')
local restored=false;hooks['core.quit_to_launcher'](function()restored=true end);assert(restored)
assert(Field.draw~=nil);Field.draw(game);assert(native==5)
print('PASS FireRed generation isolation, tileset scope, folded columns, native fallback, camera intent, options and unload')
