-- Source lighting removal must not lose painted textures, alpha, closure,
-- authored anchors, provider vertex paint, or atomic native fallback.
local png='\137PNG\13\10\26\10'..string.char(0,0,0,13)..'IHDR'..string.char(0,0,0,8,0,0,0,8)
local reads,uploaded,released={},{},0
local function mesh()return{setTexture=function()end,release=function()released=released+1 end}end
local V={require=function(n)
 if n=='SharedModelMesh'then return dofile('lib/SharedModelMesh.lua')elseif n=='SceneryModelData'then return{}elseif n=='BuildBudget'then return{check=function()end}
 elseif n=='ModelInstances'then return{new=function()return mesh()end}end;error(n)
end}
love={filesystem={newFileData=function()return{release=function()end}end},graphics={newImage=function()local m=mesh();m.getDimensions=function()return 8,8 end;m.setFilter=function()end;m.setWrap=function()end;return m end}}
local S=assert(loadfile('lib/SceneryModels.lua'))(V)
local function part(texture,role,color)
 return{texture=texture,role=role,vertices={{-.5,0,-.5,0,.2,.25},{.5,0,-.5,1,.2,.5},{0,1,.5,.5,1,.75}},indices={1,2,3},colors={color,color,color}}
end
local def={vertexColorRole='lighting',parts={part('paint.png','structure',{.3,.5,.8,.6}),part('missing.png','source_shading',{0,0,0,.7}),part('missing2.png','ground_shadow',{.2,.2,.2,.4}),part('h_kage.png','structure',{1,1,1,1}),part('painted-glass.png','structure',{.15,.85,.2,.3})},anchors={door={0,0,.5}},surfaces={message={part=5,triangles={1},uvBounds={0,.2,1,1},normal={0,0,1}}}}
def.parts[5].vertexColorRole='paint';def.parts[5].alphaMode='blend';def.parts[5].opacity=.7
assert(S.register('lighting_fixture',def,{read=function(path)reads[#reads+1]=path;if not path:find('missing',1,true)and path~='h_kage.png'then return png end end}))
local parts,fit=S.vertices('lighting_fixture',{width=32,depth=32});assert(#parts==5 and fit.bounds[5]==31.5 and fit.anchors.door[3]==31.75)
for i,p in ipairs(parts)do for j,v in ipairs(p.vertices)do
 local src=def.parts[i].vertices[j];assert(v[4]==src[4]and v[5]==src[5]and v[6]==1 and src[6]~=1)
 assert(v[10]==def.parts[i].colors[j][4],'source alpha lost')
 if i==5 then assert(v[7]==.15 and v[8]==.85 and v[9]==.2,'explicit painted tint lost')else assert(v[7]==1 and v[8]==1 and v[9]==1,'source illumination retained')end
end end
assert(def.parts[1].colors[1][1]==.3,'source arrays mutated')
local face=S.surface('lighting_fixture','message',{width=32,depth=32});assert(#face==3 and face[1][6]==1,'source part indices changed')
local placements={{model='lighting_fixture',x=0,y=0,z=0,fit={width=32,depth=32}}}
local function upload(v)local m=mesh();uploaded[#uploaded+1]=v;return m end
local out=assert(S.buildBatches(placements,upload));assert(#out==2 and out[1].part==1 and out[2].part==5 and #reads==2,'baked overlay loaded/uploaded or physical part lost')
assert(out[2].alphaMode=='blend'and out[2].opacity==.7,'physical translucent material changed');S.releaseBatches(out)
local paint={parts={part('third-party.png','structure',{.2,.7,.4,.5})}}
assert(S.register('paint_provider',paint,{read=function()return png end}));assert(S.vertices('paint_provider',{width=16,depth=16})[1].vertices[1][8]==.7,'third-party paint changed without explicit opt in')
local failed={parts={part('good.png','structure',{1,1,1,1}),part('unavailable.png','structure',{1,1,1,1})}}
assert(S.register('missing_structure',failed,{read=function(path)if path=='good.png'then return png end end}))
local older=mesh();local owned={{mesh=older}};local n=released
local result=S.buildBatches({{model='missing_structure',x=0,y=0,z=0,fit={width=16,depth=16}}},upload,{parts=owned})
assert(not result and #owned==1 and owned[1].mesh==older and released>=n+2,'missing structural texture lost atomic fallback')
print('PASS explicit source lighting only: UV/alpha/paint/closure/anchors preserved, shadow assets skipped, provider paint retained, failed physical material rolls back')
