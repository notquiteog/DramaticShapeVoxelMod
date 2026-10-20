local V,modules={},{}
function V.require(n)return assert(modules[n],n)end
local mode='modeled'
modules.TreePresentation={props={get=function()return mode end}}
local calls,failure=0,false
modules.GrassModels={buildBatches=function(list,upload,options)
 calls=calls+1;assert(type(upload)=='function'and type(options.parts)=='table')
 if failure then return nil,'missing texture'end
 return options.parts
end,hideRect=function(parts,x,z,x1,z1)
 assert(parts.token and x1-x==16 and z1-z==16);return 1
end}
local G=assert(loadfile('lib/Gen3GrassModels.lua'))(V)
local function cell(x,y,kind,extra)
 local c={cx=x,cy=y,shape={kind=kind},collision=0,mid=7,base=6}
 for k,v in pairs(extra or{})do c[k]=v end;return c
end
local cells={a=cell(3,2,'grass'),b=cell(1,2,'grass',{base=-4}),
 flower=cell(2,1,'flowers'),solid=cell(1,1,'grass',{collision=7}),
 edge=cell(0,1,'grass',{boundary='ground'}),stage=cell(4,1,'grass',{stageHidden=true})}
local list=G.placements(cells);assert(#list==2 and list[1].x==16 and list[2].x==48)
assert(list[1].y==-4 and list[2].y==6 and list[1].extent==16)
for _,p in ipairs(list)do assert(p.rotation>=0 and p.rotation<=3 and p.model=='oras_green')end
mode='cards';assert(G.build(cells,function()end,{})==nil and calls==0)
mode='modeled';failure=true
local parts,err=G.build(cells,function()end,{})
assert(not parts and err=='missing texture'and not cells.a.importedGrass)
failure=false;local destination={token=true};local out,_,count=G.build(cells,function()end,destination)
assert(out==destination and count==2 and cells.a.importedGrass and cells.b.importedGrass)
assert(not cells.flower.importedGrass and not cells.solid.importedGrass)
local regions={{x=1,y=1,w=4,h=3,def={midLayout={
 midAt=function(_,x,y)return x==2 and y==1 and 8 or 7 end,
 collAt=function()return 0 end}}}}
assert(G.prune(out,cells,regions)==1 and not cells.a.importedGrass and cells.b.importedGrass)
assert(G.prune(out,cells,regions)==0,'native Cut processed twice')
for _,c in pairs(cells)do assert(c.mid==7 and c.shape.kind~='model','native source changed')end
cells.b.shape.grassModel='third_party_tuft'
assert(G.placements(cells)[1].model=='third_party_tuft','extension recipe lost')
print('Gen3 imported grass: native predicates, local levels, opt-out/fallback and immediate Cut pass')
