-- Genuine shared ORAS corridor Gym. Native drawings, floors, collision and warps
-- remain authoritative; every physical triangle must stay on blocked body cells.
local V=...
local Models=V.require('SceneryModels')
local M={id='oras_hoenn_gym',noticeId='oras_hoenn_gym_notice'}
local families={petalburg_city_gym={map='PETALBURG_CITY',pair='general__petalburg',x=12,y=4,rear={7,7,7,7,7,7}},
 dewford_town_gym={map='DEWFORD_TOWN',pair='general__dewford',x=5,y=13,rear={0,0,0,0,0,0}},
 rustboro_city_gym={map='RUSTBORO_CITY',pair='general__rustboro',x=24,y=15,rear={7,0,0,0,0,0}}}
local sourceRows={
 petalburg_city_gym={{0x1aa,0x1ab,0x1ab,0x1ab,0x1ab,0x1ac},{0x1b2,0x1b3,0x1b3,0x1b3,0x1b3,0x1b4},{0x1b8,0x1b9,0x1ba,0x1b3,0x1bb,0x1bc},{0x1c0,0x1c1,0x1c2,0x1c5,0x1c3,0x1c4},{0x1c8,0x1c9,0x1ca,0x1cd,0x1cb,0x1cc}},
 dewford_town_gym={{0x21a,0x21b,0x21b,0x21b,0x21b,0x21c},{0x222,0x223,0x223,0x223,0x223,0x224},{0x22b,0x22c,0x22d,0x1b3,0x22e,0x22f},{0x233,0x234,0x235,0x1c5,0x236,0x237},{0x23b,0x23c,0x23d,0x1cd,0x23e,0x23f}},
 rustboro_city_gym={{0x2ca,0x2cb,0x2cb,0x2cb,0x2cb,0x2db},{0x1b2,0x1b3,0x1b3,0x1b3,0x1b3,0x1b4},{0x2c8,0x1b9,0x1ba,0x1b3,0x1bb,0x2c9},{0x2d0,0x1c1,0x1c2,0x1c5,0x1c3,0x2d1},{0x2d8,0x2d9,0x2d2,0x1cd,0x2d3,0x2da}}}
local front={0,0,7,0x71,7,0}
function M.register(id)
 id=id or M.id;if Models.info(id)then return true end
 local data=V.require('ImportedHoennGymData')[id];if not data then return nil,'original ORAS Gym source unavailable'end
 return Models.register(id,data,{read=function(path)return V.mod:read(path)end})
end
function M.eligible(g,cells)
 local name=g and g.custom and g.custom.name;local family=families[name]
 if not(family and g.custom.family=='rse'and g.kind=='gym'and g.width==6 and g.depth==5 and g.pair==family.pair and not g.stageHidden)then return false end
 local c=cells[g.cx..':'..g.cy];local region=c and c.region;local id=region and region.def and region.def.id
 if not(id and(id=='EM_'..family.map or id=='RU_'..family.map or id=='SA_'..family.map)
  and g.cx-(region.x or 0)==family.x and g.cy-(region.y or 0)==family.y)then return false end
 local level
 for y=0,4 do for x=0,5 do
  local a=cells[(g.cx+x)..':'..(g.cy+y)];local permission=y==0 and family.rear[x+1]or(y==4 and front[x+1]or 7)
  if not(a and a.civic==g and a.pair==g.pair and a.mid==sourceRows[name][y+1][x+1]and a.collision==permission and not(a.boundary or a.stageHidden))then return false end
  if y>=1 and permission~=0 then if level==nil then level=a.base or 0 elseif math.abs((a.base or 0)-level)>.001 then return false end end
 end end
 return true
end
-- Clip a projected source triangle to each native tile. Testing only vertices
-- would miss an angled face spanning a walkable corner between blocked cells.
local function area(poly)
 local a=0;for i,p in ipairs(poly)do local q=poly[i%#poly+1];a=a+p[1]*q[2]-q[1]*p[2]end;return math.abs(a)/2
end
local function clip(poly,axis,bound,sign)
 local out={};if #poly==0 then return out end
 local a=poly[#poly];local da=(a[axis]-bound)*sign
 for _,b in ipairs(poly)do local db=(b[axis]-bound)*sign
  if(da>=0)~=(db>=0)then local t=da/(da-db);out[#out+1]={a[1]+(b[1]-a[1])*t,a[2]+(b[2]-a[2])*t}end
  if db>=0 then out[#out+1]=b end;a,da=b,db
 end;return out
end
function M.clearance(g,cells,parts)
 for _,part in ipairs(parts)do
  for _,v in ipairs(part.vertices)do
   local x,z=math.floor(v[1]/16),math.floor(v[3]/16)+1;local c=cells[(g.cx+x)..':'..(g.cy+z)]
   if not(c and c.civic==g and(c.collision==7 or c.collision==0x71))then return false,'source Gym vertex enters native walking ground'end
  end
  for i=1,#part.indices,3 do
   local tri={};local lo,hi,back,fore=math.huge,-math.huge,math.huge,-math.huge
   for j=0,2 do local v=part.vertices[part.indices[i+j]];tri[#tri+1]={v[1],v[3]};lo,hi,back,fore=math.min(lo,v[1]),math.max(hi,v[1]),math.min(back,v[3]),math.max(fore,v[3])end
   for y=math.floor(back/16),math.floor(fore/16)do for x=math.floor(lo/16),math.floor(hi/16)do
    local c=cells[(g.cx+x)..':'..(g.cy+y+1)]
    if not(c and c.civic==g and(c.collision==7 or c.collision==0x71))then
     local q=clip(clip(clip(clip(tri,1,x*16,1),1,(x+1)*16,-1),2,y*16,1),2,(y+1)*16,-1)
     if #q>2 and area(q)>1e-7 then return false,'source Gym face spans native walking ground'end
    end
   end end
  end
 end;return true
end
function M.build(g,cells,newMesh,parts)
 if not M.eligible(g,cells)then return false end
 local ok,err=M.register();if not ok then return false,err end
 local fit={width=96,depth=64,padding=.25,anchor='door',targetX=56,targetZ=54}
 local source,placed=Models.vertices(M.id,fit);if not source then return false,placed end
 local safe,why=M.clearance(g,cells,source);if not safe then return false,why end;placed.model=M.id
 local doors=V.require('Gen3GymDoors');local cache,reason=doors.build(g,placed,newMesh,cells)
 if not cache then return false,reason end
 local result,message=Models.buildBatches({{model=M.id,x=g.cx*16,y=(g.groundHeight or 0)-.05,z=(g.cy+1)*16,fit=fit}},newMesh,{parts=parts})
 if not result then doors.release(g);return false,message end
 g.importedHoenn=placed;g.importedGymY=(g.groundHeight or 0)-.05;doors.commit(g);return true
end
return M
