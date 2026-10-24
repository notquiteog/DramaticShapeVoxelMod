-- Actual regional HGSS two/three-storey nonenterable Saffron blocks.
local V=...
local Models=V.require('SceneryModels')
local M={}
local specs={
 saffron_house={id='hgss_saffron_ordinary_block',width=4,depth=5,rows={{661,662,662,663},{669,670,670,671},{677,678,655,679},{664,665,667,668},{672,673,675,676}}},
 saffron_tall_house={id='hgss_saffron_tall_block',width=5,depth=6,headerEdgeMayBlock=true,rows={{641,642,642,645,646},{648,649,649,653,654},{656,657,658,659,660},{664,665,666,667,668},{664,665,666,667,668},{672,673,674,675,676}}},
}
function M.selection(g)return g and specs[g.family]end
function M.eligible(g,cells)
 local s=M.selection(g)
 if not(s and g.pair=='general__rom_082d4b9c'and g.width==s.width and g.depth==s.depth and not g.stageHidden)then return false end
 local first,last=cells[g.cx..':'..g.cy],cells[(g.cx+g.width-1)..':'..g.cy]
 local west=s.headerEdgeMayBlock and first and last and first.collision==7 and last.collision==0
 local east=s.headerEdgeMayBlock and first and last and last.collision==7 and first.collision==0
 local base
 for y,row in ipairs(s.rows)do for x,mid in ipairs(row)do
  local c=cells[(g.cx+x-1)..':'..(g.cy+y-1)];local permission=y==1 and((west and x==1 or east and x==g.width)and 7 or 0)or 7
  if not(c and c.civic==g and c.pair==g.pair and c.mid==mid and c.collision==permission and not(c.boundary or c.stageHidden or c.prop))then return false end
  if y>1 then if base==nil then base=c.base or 0 elseif math.abs((c.base or 0)-base)>.001 then return false end end
 end end
 return true
end
function M.register(id)
 if Models.info(id)then return true end
 local source=V.require('SaffronBlockData')[id];if not source then return nil,'unknown regional Saffron block'end
 return Models.register(id,source,{read=function(path)return V.mod:read(path)end})
end
function M.build(g,cells,newMesh,parts)
 if not M.eligible(g,cells)then return false end
 local id=M.selection(g).id;local ok,err=M.register(id);if not ok then return false,err end
 local fit={width=g.width*16,depth=(g.depth-1)*16,padding=.25,groundInset=.05}
 local fitted,why=Models.fit(id,fit);if not fitted then return false,why end
 local result,message=Models.buildBatches({{model=id,x=g.cx*16,y=g.groundHeight or 0,z=(g.cy+1)*16,fit=fit}},newMesh,{parts=parts})
 if not result then return false,message end
 fitted.model=id;g.importedSaffronBlock=fitted;return true
end
return M
