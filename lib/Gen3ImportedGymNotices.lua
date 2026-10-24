-- Actual ORAS standing Gym notice. The two native drawing cells retain their
-- exact underlying grass/sand/paving; only the reviewed overlaid art is replaced.
local V=...
local Models=V.require('SceneryModels')
local M={id='oras_hoenn_gym_notice'}
local families={
 PETALBURG_CITY={pair='general__petalburg',x=17,y=10,top=0x130,bottom=0x131,ground=1,under={2493525241,2585406725},body={57153983,54925760}},
 DEWFORD_TOWN={pair='general__dewford',x=11,y=16,top=0x208,bottom=0x210,ground=0x121,under={877157383,912022539},body={1926570453,1923162580}},
 RUSTBORO_CITY={pair='general__rustboro',x=23,y=19,top=0x2cc,bottom=0x2d4,ground=0x2bb,under={2465497755,2961867482},body={1862019192,1963665545}}}
local function pixels(blob,mid)
 if type(blob)~='string'or blob:sub(1,4)~='SVMI'or #blob<12 then return end
 local count=blob:byte(7)+blob:byte(8)*256
 if count<1 or count>4096 or #blob<12+count*258 then return end
 for i=0,count-1 do local at=13+i*2
  if blob:byte(at)+blob:byte(at+1)*256==mid then local start=13+count*2+i*256;return blob:sub(start,start+255)end
 end
end
local function checksum(s)
 if not s then return end
 local a,b=1,0;for i=1,#s do a=(a+s:byte(i))%65521;b=(b+a)%65521 end;return b*65536+a
end
local function available(c)
 return c and c.primary=='general'and c.ts and c.ts.layered and not(c.boundary or c.stageHidden or c.civic or c.gym or c.stairs or c.column)
end
local function legacyNotice(p,c,top)
 local r=type(p)=='table'and p.recipe
 return type(r)=='table'and r.name=='hoenn_field_gym_notice'and r.family=='rse'and r.primary=='general'
  and r.pair=='general__petalburg'and r.kind=='earlyHoennProp'and r.variant=='gymNotice'
  and type(r.rows)=='table'and #r.rows==2 and type(r.rows[1])=='table'and type(r.rows[2])=='table'and #r.rows[1]==1 and #r.rows[2]==1 and r.rows[1][1]==0x130 and r.rows[2][1]==0x131
  and p.cx==top.cx and p.cy==top.cy and p.w==16 and p.d==32 and p.pair==c.pair and p.ts==c.ts
  and not p.stageHidden
end
function M.eligible(c,cells)
 if not available(c)or c.collision~=7 then return end
 local r=c.region;local id=r and(r.mapId or r.def and r.def.id)
 local edition,name;if id then edition,name=id:match('^(%u%u)_(.+)$')end
 local f=name and families[name]
 if not(f and(edition=='EM'or edition=='RU'or edition=='SA')and c.pair==f.pair and c.mid==f.bottom
  and c.cx-(r.x or 0)==f.x and c.cy-(r.y or 0)==f.y)then return end
 local top=cells[c.cx..':'..(c.cy-1)]
 if not(available(top)and top.region==r and top.ts==c.ts and top.pair==c.pair and top.mid==f.top and top.collision==0
  and math.abs((c.base or 0)-(top.base or 0))<.01)then return end
 local owner=c.prop
 if owner or top.prop then
  if name~='PETALBURG_CITY'or not(owner and top.prop==owner and legacyNotice(owner,c,top))then return end
 end
 local version=edition=='EM'and 1 or 2;local ts=c.ts
 if checksum(pixels(ts.idxBlob,f.top))~=f.under[version]or checksum(pixels(ts.idxBlob,f.bottom))~=f.body[version]
  or checksum(pixels(ts.idxBlob,f.ground))~=f.under[version]or checksum(pixels(ts.overBlob,f.top))~=2628716491
  or checksum(pixels(ts.overBlob,f.bottom))~=16777217 or checksum(pixels(ts.overBlob,f.ground))~=16777217 then return end
 return f,top,owner
end
function M.placements(cells)
 local list={}
 for _,c in pairs(cells)do local f,top,owner=M.eligible(c,cells)
  if f then list[#list+1]={model=M.id,x=c.cx*16,y=c.base or 0,z=c.cy*16,
   fit={width=16,depth=16,padding=.25},source=c,top=top,ground=f.ground,legacyProp=owner}end
 end
 table.sort(list,function(a,b)return a.z==b.z and a.x<b.x or a.z<b.z end);return list
end
function M.build(cells,newMesh,parts)
 local list=M.placements(cells);if #list==0 then return parts,nil,0 end
 local ok,err=V.require('Gen3ImportedGyms').register(M.id);if not ok then return nil,err,0 end
 -- Only the authored horizontal leg-bottom caps overlap native floor. Move
 -- those uploaded closure faces below ground; original legs, source body,
 -- fit bounds and ground anchors remain exact. Nothing else is translated.
 local function upload(vertices,indices,format)
  local caps=#vertices==8 and #indices==12
  if caps then for _,v in ipairs(vertices)do if math.abs(v[2])>1e-8 then caps=false;break end end end
  if caps then local copy={};for i,v in ipairs(vertices)do copy[i]={unpack(v)};copy[i][2]=v[2]-.05 end;vertices=copy end
  return newMesh(vertices,indices,format)
 end
 local result,why=Models.buildBatches(list,upload,{parts=parts})
 if result then for _,p in ipairs(list)do p.source.importedGymNotice=p.ground;p.top.importedGymNotice=p.ground;if p.legacyProp then p.legacyProp.importedGymNotice=M.id end end end
 return result,why,result and #list or 0
end
function M.ownsProp(p)return p and p.importedGymNotice==M.id or false end
function M.floor(c)return c and c.importedGymNotice end
return M
