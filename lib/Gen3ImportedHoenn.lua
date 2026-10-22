-- Original ORAS Route104 Briney exterior. Eligibility never changes native
-- collision, map art or warps; missing public resources retain Civic fallback.
local V=...
local Models=V.require('SceneryModels')
local M={id='oras_route104_briney_house'}
local registered={}
M.shopId='oras_route104_pretty_petal_shop_native'
local rows={{0x268,0x269,0x26a,0x26b,0x26c},{0x270,0x271,0x272,0x273,0x274},
 {0x278,0x279,0x27a,0x27b,0x27c},{0x280,0x281,0x282,0x283,0x284}}
local permissions={{0,0,0,0,0},{7,7,7,7,7},{7,7,7,7,7},{7,7,0x71,7,7}}
-- Append this family to the ordinary Hoenn exterior recipes before Civic.prepare.
-- Its ordinary native-art Civic shell is also the missing-resource fallback.
M.recipes={{family='rse',name='route104_briney_house',pair='general__rustboro',header=4,
 rows=rows,permissions=permissions,back=2,bodyBack=16,roofEnd=36,wallBottom=63,
 bevel=0,roofShape='gable',roofRise=13,openings={{33,45,47,63,door=true}},
 groundCandidates={[1]=true},wallSample={5,57},trimSample={5,40}},
 {family='rse',name='route104_pretty_petal_shop',pair='general__rustboro',header=4,
 rows={{0x248,0x249,0x24a,0x24b,0x24c,0x24d},{0x250,0x251,0x252,0x253,0x254,0x255},
  {0x258,0x259,0x25a,0x25b,0x25c,0x25d},{0x260,0x261,0x262,0x263,0x264,0x265}},
 permissions={{0,7,7,7,7,7},{7,7,7,7,7,7},{7,7,7,7,7,7},{7,7,0x71,7,7,7}},
 back=2,bodyBack=16,roofEnd=36,wallBottom=63,bevel=0,roofShape='barrel',roofRise=13,
 openings={{33,45,47,63,door=true}},groundCandidates={[1]=true},wallSample={5,57},trimSample={5,40}}}
local recipes={};for _,r in ipairs(M.recipes)do recipes[r.name]=r end
local function dewford(g)
 local n=g.custom and g.custom.name
 return n=='dewford_town_home' or n=='dewford_town_south_home'
end
-- Regional adaptation shortens only the plain central wall/roof bay between
-- the two side-window assemblies. Front fixtures and rear facade are rigid;
-- all source UVs/colors remain unchanged. This is applied to a private copy.
function M.shopDepth(z,bay)
 if z<=bay.start then return z+bay.shorten end
 if z>=bay.finish then return z end
 return z+bay.shorten*(bay.finish-z)/(bay.finish-bay.start)
end
function M.register(id)
 id=id or M.id;if registered[id]then return true end
 local source,data
 if id==M.id then data=V.require('ImportedHoennData');source=data[M.id]
 elseif id==M.shopId then
  data=V.require('ImportedHoennShopData');source=data.oras_route104_pretty_petal_shop
  local d={parts={},anchors={}};local bay=source.nativeDepthBay
  for name,a in pairs(source.anchors)do d.anchors[name]={a[1],a[2],M.shopDepth(a[3],bay)}end
  for i,p in ipairs(source.parts)do
   local q={};for k,value in pairs(p)do q[k]=value end;q.vertices={}
   for j,v in ipairs(p.vertices)do local row={unpack(v)};row[3]=M.shopDepth(row[3],bay);q.vertices[j]=row end
   d.parts[i]=q
  end
  source=d
 else return nil,'unknown Hoenn import'end
 local ok,err=Models.register(id,source,{read=function(path)return V.mod:read(path)end})
 if not ok then return nil,err end
 registered[id]=true;return true
end
function M.eligible(g,cells)
 if dewford(g)then return V.require('Gen3ImportedDewford').eligible(g,cells)end
 local r=g.custom and recipes[g.custom.name]
 if not(r and g.custom.family=='rse')or g.pair~=r.pair or g.kind~='house'
  or g.width~=#r.rows[1] or g.depth~=#r.rows or g.stageHidden then return false end
 local base
 for y=0,g.depth-1 do for x=0,g.width-1 do
  local c=cells[(g.cx+x)..':'..(g.cy+y)]
  if not c or c.civic~=g or c.pair~=g.pair or c.mid~=r.rows[y+1][x+1]
   or c.collision~=r.permissions[y+1][x+1] or c.boundary or c.stageHidden then return false end
  if base==nil then base=c.base or 0 elseif math.abs((c.base or 0)-base)>.001 then return false end
 end end
 return true
end
function M.build(g,cells,newMesh,parts)
 if dewford(g)then return V.require('Gen3ImportedDewford').build(g,cells,newMesh,parts)end
 if not M.eligible(g,cells)then return false end
 local shop=g.custom.name=='route104_pretty_petal_shop';local id=shop and M.shopId or M.id
 local ok,err=M.register(id);if not ok then return false,err end
 -- The rear drawing row contains walkable cells. Every mesh remains in
 -- the three solid body rows (80x48 house or96x48 shop). Uniform scaling
 -- follows the documented shop bay adaptation; entrance X stays native.
 local fit={width=g.width*16,depth=48,padding=.25,anchor='door',targetX=40,targetZ=shop and 39.8 or 38}
 local placement={model=id,x=g.cx*16,y=g.groundHeight or 0,z=(g.cy+1)*16,fit=fit}
 local result,why=Models.buildBatches({placement},newMesh,{parts=parts})
 if not result then return false,why end
 g.importedHoenn=assert(Models.fit(id,fit));g.importedHoenn.model=id
 return true
end
function M.doorSurface(g,tx,ty)
 if g.importedHoenn and g.importedHoenn.model=='oras_dewford_narrow_house'then return V.require('Gen3ImportedDewford').doorSurface(g,tx,ty)end
 if not g.importedHoenn or tx~=g.cx+2 or ty~=g.cy+3 then return end
 local fit=g.importedHoenn;local a=fit.anchors.door;local top=fit.anchors.doorTop
 local x,z=g.cx*16+a[1],(g.cy+1)*16+a[3]+.025
 local shop=fit.model==M.shopId
 local half=shop and 16.92/121.4654*fit.scale or 12/132.5*fit.scale
 return {w=14,h=18,sourceX=g.cx*16+33,sourceY=g.cy*16+45,base=g.groundHeight or 0,
  vertices={{x-half,top[2],z},{x+half,top[2],z},{x+half,a[2],z},{x-half,a[2],z}}}
end
return M
