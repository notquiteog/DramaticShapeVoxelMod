-- Multi-owner replacement stays native until the complete GPU batch exists.
local ready=false
local Models={retryImages=function()end}
function Models.buildBatches(list,upload,opts)
 assert(#list==2 and type(upload)=='function')
 if not ready then return nil,'deliberate missing source texture'end
 return opts.parts
end
local modules={SceneryModels=Models,TreePresentation={voxel=function()return true end},CommunityVisuals={customTrees=function()return false end}}
local T=assert(loadfile('lib/ImportedTrees.lua'))({require=function(n)return assert(modules[n],n)end})
local bounds={0,0,16,32}
local canopy={collision=7,shape={treeBounds=bounds}}
local trunk={collision=7,shape={treeBounds={0,32,16,48}}}
local union={bounds={.25,.25,15.75,47.75},height=20}
local back={bounds={.25,.25,15.75,15.75},height=20}
local front={bounds={.25,16.25,15.75,47.75},height=20}
T.gen3Placements=function()return{
 {model='source-pine',source=canopy,treeInfo=union},
 {model='source-pine',source=canopy,sources={canopy,trunk},treeInfo=union,sourceTreeInfos={[canopy]=union,[trunk]=front}},
}end
local prior={};local out,err=T.buildGen3({},function()end,prior)
assert(not out and err and not canopy.importedTree and not trunk.importedTree,'partial batch hid native owners')
ready=true;assert(T.buildGen3({},function()end,prior)==prior)
assert(canopy.importedTree==union and trunk.importedTree==front,'merged tree lost per-owner bounds')
assert(canopy.shape.treeBounds==bounds and canopy.collision==7 and trunk.collision==7,'native bounds or collision mutated')
print('PASS atomic multi-owner source tree fallback and per-owner replacement bounds')
