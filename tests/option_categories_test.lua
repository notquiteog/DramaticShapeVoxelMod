local C=dofile('lib/OptionCategories.lua')
local catalog=dofile('lib/SettingsCatalog.lua')
local rows,expected={},{}
for _,r in ipairs(catalog)do
 if r.key~='fireredBattleStage'then
  assert(C.byKey[r.key] or r.key=='legendaryVisualsMode','uncategorized '..r.key)
  local row={id='MOD:'..r.key,label=r.label,value=function()return 'saved'end,step=function()return true end}
  rows[#rows+1]=row;expected[row.id]=row
 end
end
local title,page
local tree=C.native(rows,function(t,p)title,page=t,p end,'MOD')
assert(tree[1].label=='LEGENDARY VISUALS' and tree[2].label=='WORLD' and tree[3].label=='PERFORMANCE' and tree[4].label=='POKEMON ART' and tree[5].label=='BATTLE SCENE')
local count=0
local function visit(list)
 for _,r in ipairs(list)do
  if r.group then r.activate();assert(title==r.label and page==r.members);visit(r.members)
  else assert(expected[r.id]==r,'lost/replaced/duplicated live row');expected[r.id]=nil;count=count+1 end
 end
end
visit(tree);assert(next(expected)==nil and count==#rows)
assert(#C.native({},function()end,'MOD')==0,'empty categories shown')
print('PASS every catalog option categorized once; Gen1 labels/order and live row owners preserved')
