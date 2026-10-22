-- Real ModSetting persistence/rows; no graphics, model catalogs or engine mocks.
local function eq(a,b,message) assert(a==b,(message or 'mismatch')..': '..tostring(a)..' ~= '..tostring(b)) end
local id='BATTLE_ART_VOXEL_FORK'
local legacy={communityTrees='n64memory',communityBuildings='n64memory',legendaryVisualsMode='full',
 treeArt='voxel',treeProps='voxel',flowerStyle='modern',pokemonStyle='modern',characterStyle='voxel',xdModels=true}
local function policy(stored)
 local reads={};local V={mod={id=id,options={get=function(_,key)reads[#reads+1]=key;return stored[key]end}}}
 local Setting=assert(loadfile('lib/ModSetting.lua'))(V)
 V.require=function(name)eq(name,'ModSetting','unexpected dependency');return Setting end
 return assert(loadfile('lib/VisualStyles.lua'))(V),reads
end
local M,reads=policy(legacy)
local order={'buildings','trees','flowers','props','interiors','terrain','pokemon','characters'}
local protected={flowers=true,pokemon=true,characters=true}
eq(#M.settings,8);eq(#M.order,8);eq(#M.registrations,8)
for i,category in ipairs(order)do
 eq(M.order[i],category,'stable menu order')
 local entry=M.byCategory[category];local setting=M.setting(category)
 eq(setting,M.settings[i]);eq(entry,M.registrations[i]);eq(M.byKey[setting.key],entry);eq(entry.order,i)
 local wanted=protected[category]and'hd2d'or'modern'
 eq(M.get(category),wanted,'safe initial category default');eq(entry.default,wanted)
 eq(M.modern(category),wanted=='modern');eq(M.voxel(category),false);eq(M.hd2d(category),wanted=='hd2d')
 local schema=setting:schema(entry.help)
 eq(schema.default,wanted);eq(schema.type,'choice');eq(#schema.choices,3)
 for index,value in ipairs{'modern','voxel','hd2d'}do eq(schema.choices[index][2],value)end
 assert(entry.help:find('where supported',1,true),'modern preference claims universal availability')
 assert(entry.help:find('100% original game sprite art',1,true),'native voxel art contract missing')
end
for _,key in ipairs(reads)do assert(key:match('^visualStyle'),'legacy key influenced new styles')end
eq(M.get('unregistered'),nil);eq(M.modern('unregistered'),false);eq(M.voxel('unregistered'),false);eq(M.hd2d('unregistered'),false)

-- Explicit preferences from the new schema survive a new module/session.
local saved={visualStyleFlowers='modern',visualStylePokemon='voxel',visualStyleCharacters='modern',
 visualStyleBuildings='hd2d',visualStyleTrees='n64memory',visualStyleTerrain=false}
local restored=policy(saved)
eq(restored.get('flowers'),'modern');eq(restored.get('pokemon'),'voxel');eq(restored.get('characters'),'modern')
eq(restored.get('buildings'),'hd2d');eq(restored.get('trees'),'modern','invalid persisted value fallback')
eq(restored.get('terrain'),'modern','invalid persisted type fallback')
restored.setting('flowers'):sync('voxel');eq(restored.get('flowers'),'voxel')
restored.setting('flowers'):sync('legacy');eq(restored.get('flowers'),'hd2d','invalid actor/flower sync must use safe default')

-- Native OPTIONS rows and manager schema share the ordinary ModSetting value.
local writes=0
local game={save={options={}},mods={},writeOptions=function()writes=writes+1 end}
local flowers=M.setting('flowers');local row=flowers:row()
eq(row.id,id..':visualStyleFlowers');eq(row.value(),'HD2D')
assert(row.step(game,1));eq(M.get('flowers'),'modern');eq(row.value(),'MODERN 3D')
eq(game.save.options.modOptions[id][flowers.key],'modern');eq(game.mods.modOptions[id][flowers.key],'modern');eq(writes,1)
assert(row.step(game,1));eq(M.get('flowers'),'voxel');eq(row.value(),'NATIVE VOXEL')
local gen3={options={},mods={},persistOptions=function()writes=writes+1 end}
M.setting('pokemon'):setIndex(2,gen3);eq(M.get('pokemon'),'voxel')
eq(gen3.options.modOptions[id].visualStylePokemon,'voxel');eq(gen3.mods.modOptions[id].visualStylePokemon,'voxel');eq(writes,3)
eq(M.get('characters'),'hd2d','editing one category changed another')

-- Provider metadata is appended in registration order and cannot replace core
-- actor defaults, reuse an owned key, or smuggle a fourth choice into the policy.
local custom,entry=M.register('example_rocks',{label='ROCK STYLE',default='hd2d',help='Provider rocks.'})
eq(M.order[9],'example_rocks');eq(M.settings[9],custom);eq(M.registrations[9],entry)
eq(custom.key,'visualStyle_example_rocks');eq(M.get('example_rocks'),'hd2d');eq(entry.help,'Provider rocks.')
local ok=pcall(M.register,'flowers',{default='modern'});eq(ok,false)
ok=pcall(M.register,'example_other',{key='visualStyleFlowers'});eq(ok,false)
ok=pcall(M.register,'bad id',{});eq(ok,false)
ok=pcall(M.register,'example_other',{default='auto'});eq(ok,false)
eq(#M.order,9,'failed registration changed menu metadata')
local other=M.register('example_other',{})
eq(M.get('example_other'),'modern');eq(other.label,'EXAMPLE OTHER STYLE')
custom.values[1]='test-only';eq(other.values[1],'modern','categories share mutable choice arrays')
print('PASS category styles: safe defaults, explicit persistence, native rows, manager sync and provider registration')
