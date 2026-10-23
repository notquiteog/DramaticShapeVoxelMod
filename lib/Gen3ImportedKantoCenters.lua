-- Standard HGSS Center for the complete native FR/LG five-column family.
-- The caller owns native civic discovery and scene resource/fallback lifecycle.
local V=...
local Models=V.require('SceneryModels')
local M={id='hgss_kanto_center'}
local registered=false
local body={{0x48,0x49,0x4a,0x4b,0x187},{0x50,0x51,0x52,0x53,0x18f},{0x58,0x59,0x5a,0x5b,0x197}}
local headers={{0x17b,0x17c,0x17d,0x17e,0x17f},{0x2b0,0x2b1,0x2b2,0x2b3,0x2b4},
 {0x282,0x283,0x284,0x285,0x286},{0x280,0x281,0x282,0x283,0x284},{0x2fc,0x2fd,0x2fe,0x306,0x2ff},
 {768,769,770,771,772},{669,670,671,680,383},{862,380,381,382,383},{771,772,773,774,775}}
function M.eligible(g,cells)
 if g.kind~='center' or type(g.rows)~='table' or not g.rows[1] or g.custom or g.width~=5 or(g.depth~=4 and g.depth~=5)or g.stageHidden then return false end
 local offset=g.depth-4;local base;local roofPermission;local lavenderHeader=false
 local c=cells[g.cx..':'..g.cy];local r=c and c.region;local id=r and r.def and r.def.id
 local waterRoof=id=='FR_VERMILION_CITY'and g.cx-(r.x or 0)==13 and g.cy-(r.y or 0)==2 and g.depth==5
 local projection=id=='FR_SAFFRON_CITY_CONNECTION'and g.cx-(r.x or 0)==12 and g.cy-(r.y or 0)==27 and g.depth==5
 if offset==1 then
  local valid=false
  for index,row in ipairs(headers)do
   local match=true;for x,mid in ipairs(row)do local c=cells[(g.cx+x-1)..':'..g.cy];if not c or c.mid~=mid then match=false end end
   valid=valid or match;if match and index==7 then lavenderHeader=true end
  end
  if not valid then return false end
 end
 for y=0,g.depth-1 do for x=0,4 do
  local c=cells[(g.cx+x)..':'..(g.cy+y)]
  if not c or c.civic~=g or c.pair~=g.pair or c.primary~='general' or c.boundary or c.stageHidden then return false end
  if y<offset then
   if waterRoof then if c.collision~=0x29 or c.mid~=0x282+x then return false end
   elseif c.collision~=0 and c.collision~=7 then return false end
   if lavenderHeader then
    if c.collision~=(x==4 and 0 or 7)then return false end
   elseif roofPermission==nil then roofPermission=c.collision elseif c.collision~=roofPermission then return false end
  else
   local by=y-offset;local mid=by<3 and body[by+1][x+1]or(x==0 and 0x60 or x==1 and 0x61 or x==2 and 0x62 or x==3 and 0x186 or 0x19f)
   if by==3 and g.rows[1][1]==0x2fc then if x==0 then mid=0x2df elseif x==4 then mid=0x307 end end
   local permission=by==3 and(x<2 and 0x82 or x==2 and(projection and 7 or 0x71)or 7)or 7
   if c.mid~=mid or c.collision~=permission then return false end
  end
  if base==nil then base=c.base or 0 elseif math.abs((c.base or 0)-base)>.001 then return false end
 end end
 return true
end
function M.register()
 if registered then return true end
 local data=V.require('HGSSCenterData')[M.id];local parts={}
 for _,p in ipairs(data.parts)do if p.role~='source_door'then parts[#parts+1]=p end end
 local ok,err=Models.register(M.id,{parts=parts,anchors=data.anchors},{read=function(path)return V.mod:read(path)end})
 if ok then registered=true end;return ok,err
end
function M.build(g,cells,newMesh,parts)
 if not M.eligible(g,cells)then return false end
 local ok,err=M.register();if not ok then return false,err end
 local fit={groundInset=.05,width=80,depth=64,padding=.25,anchor='door',targetX=40,targetZ=51}
 local placement={model=M.id,x=g.cx*16,y=g.groundHeight or 0,z=(g.cy+g.depth-4)*16,fit=fit}
 local fitted=assert(Models.fit(M.id,fit));fitted.model=M.id
 local doors=V.require('Gen3KantoCenterDoors');local geometry,why=Models.vertices(M.id,fit);if not geometry then return false,why end
 local safe,why=doors.clearance(g,cells,geometry);if not safe then return false,why end
 local ready,reason=doors.build(g,fitted,newMesh,cells);if not ready then return false,reason end
 local result,why=Models.buildBatches({placement},newMesh,{parts=parts})
 if not result then doors.release(g);return false,why end
 g.importedKantoCenter=fitted;doors.commit(g);return true
end
function M.doorSurface(g,tx,ty)
 local f=g.importedKantoCenter
 if not f or tx~=g.cx+2 or ty~=g.cy+g.depth-1 then return end
 local a=f.anchors.door;local x,z=g.cx*16+a[1],(g.cy+g.depth-4)*16+a[3]+.025
 local half=10.00879*f.scale/90;local height=30*f.scale/90
 return {w=14,h=16,sourceX=g.cx*16+33,sourceY=(g.cy+g.depth-1)*16,base=g.groundHeight or 0,
  vertices={{x-half,a[2]+height,z},{x+half,a[2]+height,z},{x+half,a[2],z},{x-half,a[2],z}}}
end
return M
