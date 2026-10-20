-- Changing defaults must not rewrite the player's explicitly saved options.
local function fixture(saved)
 local V={mod={options={get=function(_,key)return saved[key]end}}};local modules={}
 function V.require(name)
  if not modules[name]then modules[name]=assert(loadfile('lib/'..name..'.lua'))(V)end
  return modules[name]
 end
 return V.require('TreePresentation')
end
local T=fixture({})
assert(T.voxel()and T.original()and not T.flat(),'new installs lost solid 3D trees/trunks')
assert(T.art:schema('').default=='modeled'and T.setting:schema('').default=='solid')
for _,art in ipairs{'original','illustrated','modeled'}do for _,trunk in ipairs{'flat','solid'}do
 local saved={treeArtwork=art,hdTreeTrunks=trunk,sceneryProps='cards'}
 local t=fixture(saved)
 assert(t.art:get()==art and t.setting:get()==trunk and t.props:get()=='cards','explicit option replaced')
 assert(saved.treeArtwork==art and saved.hdTreeTrunks==trunk,'reading defaults persisted a replacement')
 assert(t.flat()==(trunk=='flat')and t.voxel()==(art=='modeled'))
end end
print('PASS new-install solid trees/trunks, saved card/flat optouts and schema/runtime agreement')
