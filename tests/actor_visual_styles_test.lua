local modules={};local reads,errors,items,shadows=0,0,0,0
local V={mod={id='BATTLE_ART_VOXEL_FORK',options={get=function(_,key)
 -- Every legacy switch may be on without admitting modern actors by default.
 if key=='xdModels'then return true end
 if key=='legendaryVisualsMode'then return 'full'end
end},log={error=function()errors=errors+1 end},read=function(_,path)reads=reads+1;return 'manifest'end}}
V.require=function(name)return assert(modules[name],name)end
local function load(name)modules[name]=assert(loadfile('lib/'..name..'.lua'))(V);return modules[name]end
load('ModSetting');local S=load('VisualStyles')
modules.ItemPokeballs={accepts=function(c)return c and c.spriteId=='SPRITE_POKE_BALL'end,
 draw=function(_,shadow)if shadow then shadows=shadows+1 else items=items+1 end;return true end}
modules.ShadowMap={}
local C=load('CharacterRenderers')
local calls=0
local legacy=assert(C.register({id='legacy',drawEntity=function()calls=calls+1;return true end,
 drawReflection=function()calls=calls+1;return true end,drawShadow=function()calls=calls+1;return true end,
 suppressGhost=function()calls=calls+1;return true end,afterActors=function()calls=calls+1 end,
 drawBattleTrainer=function()calls=calls+1;return true end}))
local human={isPlayer=true,spriteId='SPRITE_RED'}
for _,method in ipairs{'drawEntity','drawReflection','drawShadow','suppressGhost','drawBattleTrainer'}do
 assert(not C.has(method)and not C.first(method,human),'HD2D default invoked a legacy model renderer')
end
C.all('afterActors',{});assert(calls==0)
C.setBattle(true,{},1);C.setBattleHand({1,2,3});assert(not C.battleActive()and not C.battleHandWorld())
for _,method in ipairs{'drawEntity','drawReflection','drawShadow'}do assert(C.first(method,{spriteId='SPRITE_POKE_BALL'}))end
assert(items==2 and shadows==1,'actor styles changed ItemPokeballs prop ownership')

S.setting('characters'):sync('modern');assert(C.first('drawEntity',human)and calls==1)
local follower={entity={pikachuFollower=true},spriteId='SPRITE_PIKACHU'}
local generic={spriteId='SPRITE_MONSTER'}
local registered={spriteId='SPRITE_PICHU',state={game={data={pokemon={PICHU={}}}}}}
for _,ctx in ipairs{follower,generic,registered,{isPokemon=true},{visualCategory='pokemon'},{entity={def={species=25}}}}do
 assert(C.category(ctx)=='pokemon'and not C.first('drawEntity',ctx),'character choice overrode Pokemon HD2D')
end
S.setting('characters'):sync('hd2d');S.setting('pokemon'):sync('modern')
assert(C.first('drawEntity',follower)and not C.first('drawEntity',human))
S.setting('pokemon'):sync('voxel');assert(not C.first('drawEntity',follower),'voxel reused modern callback')
local voxelCalls=0
local voxel=assert(C.register({id='voxel',supportedStyles={pokemon={'voxel'}},
 drawEntity=function()voxelCalls=voxelCalls+1;return true end}))
assert(C.first('drawEntity',follower)and voxelCalls==1)
assert(not C.first('drawEntity',human),'category-specific provider claimed characters')
local hdCalls=0
local hd=assert(C.register({id='hd2d',supportedStyles={hd2d=true},
 drawEntity=function()hdCalls=hdCalls+1;return true end}))
assert(C.first('drawEntity',human)and hdCalls==1)
assert(not C.register({id='invalid',supportedStyles={'auto'},drawEntity=function()end}))
assert(not C.register({id='invalid2',supportedStyles='modern',drawEntity=function()end}))

hd:release();voxel:release();legacy:release()
local broken=assert(C.register({id='broken',supportedStyles={'hd2d'},
 drawEntity=function()error('provider construction/draw failure')end}))
assert(not C.first('drawEntity',human)and errors==1,'provider error claimed native art')
assert(not C.first('drawEntity',human)and errors==1,'provider failure logging repeated')
broken:release()
local rev=C.revision();S.setting('characters'):sync('voxel');assert(C.revision()>rev)
rev=C.revision();assert(C.revision()==rev,'unchanged style invalidated each frame')

-- A real local XD consumer stays dormant under HD2D even with its legacy ON
-- option. It probes/validates the optional pack only after explicit modern.
local manifestValid=false
package.loaded['src.link.Json']={decode=function()return{format='xd-converted-pack',version=1,
 renderReady=manifestValid,models={}}end}
local XD=load('XDModels')
assert(S.get('pokemon')=='voxel'and not XD.active()and reads==0)
S.setting('pokemon'):sync('hd2d');assert(not XD.active()and reads==0)
S.setting('pokemon'):sync('modern');assert(not XD.active()and reads==1,'invalid optional pack did not fail open')
manifestValid=true;XD.reset();assert(XD.active()and reads==2)
assert(not XD.newInstance(25,'shiny'),'missing shiny variant borrowed unrelated model')
XD.setting:sync(false);assert(not XD.active(),'provider OFF ignored under modern')
XD.setting:sync(true);S.setting('pokemon'):sync('hd2d');assert(not XD.active()and not XD.newInstance(25))
assert(reads==2,'HD2D touched optional model assets')
print('PASS actor styles: HD2D defaults, category/provider declarations, stale hand/shadow ownership, item props and optional XD failure/off fallback')
