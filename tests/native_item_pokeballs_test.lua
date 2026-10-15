-- Production native adapter against each engine constant table, no guessed IDs.
local engine=assert(arg[1],'pass engine directory')
package.path=engine..'/?.lua;'..package.path
local modules={}
local V={require=function(n)return assert(modules[n],n)end}
modules.ModSetting={new=function()return{get=function()return'legendary'end}end}
modules.ItemPokeballs=assert(loadfile('lib/ItemPokeballs.lua'))(V)
modules.Mat4=assert(loadfile('lib/Mat4.lua'))()
modules.Water={CAST_RAISE=.25}
local drawn={}
modules.Voxel3D={newMesh=function()return{release=function()end}end,
 draw=function(_,_,m)drawn.world=m end}
modules.ShadowMap={draw=function(_,_,m)drawn.shadow=m end}
love={image={newImageData=function()return{setPixel=function()end,release=function()end}end},
 graphics={newImage=function()return{setFilter=function()end,release=function()end}end}}
local Adapter=assert(loadfile('lib/NativeItemPokeballs.lua'))(V)
for game,base in pairs({firered='firered',leafgreen='firered',emerald='emerald',ruby='ruby',sapphire='ruby'})do
 local data=assert(loadfile(engine..'/src/core/game3/constants/'..base..'/event_objects.lua'))()
 local ids=data.byName
 package.loaded['src.core.game3.constants']={active=function()return{id=function(_,kind,name)
  assert(kind=='event_objects');return ids[name]
 end}end}
 local gid=assert(ids.OBJ_EVENT_GFX_ITEM_BALL)
 assert(not Adapter.draw(gid+1,16,32,7,modules.Voxel3D.draw))
 assert(Adapter.draw(gid,16,32,7,modules.Voxel3D.draw))
 assert(drawn.world[4]==24 and drawn.world[8]==7 and drawn.world[12]==40,game..' support anchor')
 assert(Adapter.draw(gid,16,32,7,modules.ShadowMap.draw))
 assert(drawn.shadow[8]==7,game..' caster anchor')
 assert(Adapter.draw(gid,16,32,7,modules.Voxel3D.draw,2))
 assert(drawn.world[8]==-2.75,game..' reflection anchor')
end
modules.ItemPokeballs.setting.get=function()return'default'end
assert(not Adapter.draw(92,0,0,0,modules.Voxel3D.draw))
print('PASS native item model identity, fallback, support, shadows/reflections across five editions')
