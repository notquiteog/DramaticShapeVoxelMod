-- Compressed CPU model records; no GPU objects or gameplay state persist.
-- Same OFF/LIVE CACHE/FULL/MB contract as RamPrecache. Unsupported descriptors,
-- stale/corrupt records and unavailable storage always rebuild native geometry.
local V=...
local M={stats={hits=0,misses=0,bytes=0,evicted=0,loaded=0}}
local RAM=V.require('RamPrecache');local Budget=V.require('BuildBudget')
local records,index={},{};local clock=0;local policy;local scope,prefix,sourceHash
local preloaded={}
local atlasKeys=setmetatable({},{__mode="k"})
local function canonical(value,seen)
 local t=type(value)
 if t=='nil'then return 'n'elseif t=='boolean'then return value and 't'or'f'
 elseif t=='number'then assert(value==value and math.abs(value)<math.huge);return 'd'..string.format('%.17g',value)..';'
 elseif t=='string'then return 's'..#value..':'..value end
 assert(t=='table','unsupported geometry dependency');seen=seen or{};assert(not seen[value],'cyclic geometry dependency');seen[value]=true
 local keys={};for k in pairs(value)do assert(type(k)=='string'or type(k)=='number');keys[#keys+1]=k end
 table.sort(keys,function(a,b)return canonical(a)<canonical(b)end)
 local out={'{'};for _,k in ipairs(keys)do out[#out+1]=canonical(k)..canonical(value[k],seen)end
 seen[value]=nil;out[#out+1]='}';return table.concat(out)
end
M.canonical=canonical
local function hash(bytes)return love.data.encode('string','hex',love.data.hash('sha256',bytes))end
local function codeHash()
 if sourceHash then return sourceHash end
 assert(V.mod.list and V.mod.info and V.mod.read,'source inventory unavailable')
 local parts={'native-model-cache-v2'}
 local function walk(dir)
  local names=V.mod:list(dir);table.sort(names)
  for _,name in ipairs(names)do
   local path=dir..'/'..name;local info=V.mod:info(path)
   if info and info.type=='directory'then walk(path)
   elseif name:match('%.lua$')then parts[#parts+1]=path;parts[#parts+1]=assert(V.mod:read(path));Budget.check()end
  end
 end
 walk('lib');walk('data');sourceHash=hash(table.concat(parts,'\0'));return sourceHash
end
local function read(key)
 local ok,value=pcall(V.mod.storage.readBytes,V.mod.storage,scope,key)
 return ok and value or nil
end
local function write(key,bytes)
 local ok,result=pcall(V.mod.storage.writeBytes,V.mod.storage,scope,key,bytes)
 return ok and result~=false and result~=nil
end
local function trim()
 local limit=RAM.bytes();if RAM.retainGenerated()then limit=nil end
 while limit and M.stats.bytes>limit do
  local oldest,key
  for k,r in pairs(records)do if not oldest or r.used<oldest then oldest,key=r.used,k end end
  if not key then break end
  M.stats.bytes=M.stats.bytes-#records[key].bytes;records[key]=nil;M.stats.evicted=M.stats.evicted+1
 end
end
local function retain(key,bytes)
 clock=clock+1
 if records[key]then M.stats.bytes=M.stats.bytes-#records[key].bytes end
 records[key]={bytes=bytes,used=clock};M.stats.bytes=M.stats.bytes+#bytes;trim()
end
function M.prepare(game,regions)
 if not(love and love.data and V.mod.storage and V.mod.storage.readBytes and V.mod.storage.writeBytes)then return false end
 atlasKeys=setmetatable({},{__mode="k"})
 local value=RAM.setting:get()
 local changed=value~=policy
 if value~=policy then
  policy=value;preloaded={}
  if RAM.retainGenerated()then records={};M.stats.bytes=0 end
  if RAM.off()and not RAM.retainGenerated()then records={};M.stats.bytes=0 else trim()end
 end
 if RAM.off()and not RAM.retainGenerated()then return false end
 local version=require('src.core.GameVersion').get()
 local ok,code=pcall(codeHash);if not ok then return false end
 local nextPrefix='native-geometry/'..version..'/'..code..'/'
 if nextPrefix~=prefix or changed and not RAM.retainGenerated()then
  prefix=nextPrefix;scope={save={version=version,meta={playthroughId='battle-art-native-geometry'}}}
  records={};M.stats.bytes=0;index={};preloaded={}
  if not RAM.retainGenerated()then
   local text=read(prefix..'index')or''
   for map,key in text:gmatch('([a-f0-9]+) ([a-f0-9]+)\n')do
    if #map==64 and #key==64 then index[key]=map end
   end
  end
 end
 -- CONTINUE loads compressed records of the real current/connected maps.
 -- OFF reads nothing; LIVE keeps only geometry produced this session.
 if not RAM.retainGenerated()then
  for _,region in ipairs(regions or{})do
   local map=region.def and region.def.id
   if map then local id=hash(map)
    if not preloaded[id]then
     preloaded[id]=true
     local keys={};for key,owner in pairs(index)do if owner==id then keys[#keys+1]=key end end;table.sort(keys)
     for _,key in ipairs(keys)do
      local bytes=read(prefix..key)
      if type(bytes)=='string'and #bytes<=16*1024*1024 then retain(key,bytes);M.stats.loaded=M.stats.loaded+1 end
      Budget.check()
     end
    end
   end
  end
 end
 return true
end
local function unpackRecord(bytes,emit,g)
 if bytes:sub(1,4)~='BAG2'then return false end
 local count=love.data.unpack('<I4',bytes,5)
 if count>524288 then return false end
 local raw=love.data.decompress('string','zlib',bytes:sub(9))
 if #raw~=16+count*100 then return false end
 local function finite(n)return n==n and math.abs(n)<math.huge end
 local flag,x,y,z=love.data.unpack('<ffff',raw)
 if (flag~=0 and flag~=1)or not finite(x)or not finite(y)or not finite(z)then return false end
 g.chimneyOutlet=flag==1 and{x=x,y=y,z=z}or nil
 local pos=17
 for _=1,count do
  local row={love.data.unpack('<'..string.rep('f',25),raw,pos)};pos=row[26]
  for i=1,25 do if not finite(row[i])then return false end end
  if row[22]~=0 and row[22]~=1 then return false end
  local p,t={},{}
  for i=1,4 do local k=(i-1)*5;p[i]={row[k+1],row[k+2],row[k+3]};t[i]={row[k+4],row[k+5]}end
  emit(p,t,row[21],row[22]==1 and {row[23],row[24],row[25]}or nil);Budget.check()
 end
 return true
end
function M.append(map,g,build,emit)
 if not prefix or RAM.off()and not RAM.retainGenerated()then return build(g,emit)end
 local ok,key=pcall(function()
  local input={};for k,v in pairs(g)do if k~='ts'and k~='chimneyOutlet'then input[k]=v end end
  local ts=assert(g.ts)
  local pixels=assert(ts.imageData)
  local atlas=atlasKeys[ts];if not atlas then atlas={};atlasKeys[ts]=atlas end
  local used={};local rows=g.rows or g.recipe and g.recipe.rows
  assert(rows,'native model source rows unavailable')
  for _,row in ipairs(rows)do for _,mid in ipairs(row)do
   local slot=assert(ts.midToSlot[mid])
   if not atlas[mid]then
    local part=love.image.newImageData(16,16,pixels:getFormat())
    part:paste(pixels,0,0,slot%ts.cols*16,math.floor(slot/ts.cols)*16,16,16)
    atlas[mid]=hash(part:getString());part:release()
   end
   used[mid]={slot,atlas[mid]}
  end end
  input.atlas={ts.cols,ts.rows,used}
  local settings=V.require('ModSetting').snapshot();settings.ramPrecacheMb=nil
  local key=hash(canonical({map,input,settings}))
  if M.onKey then M.onKey(map,g,input,settings,key)end
  return key
 end)
 if not ok then return build(g,emit)end
 local record=records[key];local bytes=record and record.bytes
 if not bytes and not RAM.retainGenerated()and index[key]then bytes=read(prefix..key)end
 if bytes then
  -- Validate/decode fully before emitting: a corrupt record must not leave
  -- half a model followed by a full rebuilt model in the same vertex buffer.
  local decoded={};local meta={}
  local valid,done=pcall(unpackRecord,bytes,function(p,t,s,a)decoded[#decoded+1]={p,t,s,a}end,meta)
  if valid and done then
   retain(key,bytes);g.chimneyOutlet=meta.chimneyOutlet
   for _,q in ipairs(decoded)do emit(q[1],q[2],q[3],q[4])end
   M.stats.hits=M.stats.hits+1;return
  end
 end
 M.stats.misses=M.stats.misses+1
 local chunks={};local count=0;local supported=true
 local result=build(g,function(p,t,shade,anchor)
  if #p~=4 or #t~=4 or type(shade or 1)~='number'then supported=false;emit(p,t,shade,anchor);return end
  local row={};for i=1,4 do for j=1,3 do row[#row+1]=p[i][j]end;for j=1,2 do row[#row+1]=t[i][j]end end
  row[#row+1]=shade or 1;row[#row+1]=anchor and 1 or 0
  for i=1,3 do row[#row+1]=anchor and anchor[i]or 0 end
  chunks[#chunks+1]=love.data.pack('string','<'..string.rep('f',25),unpack(row));count=count+1
  emit(p,t,shade,anchor)
 end)
 if supported and count>0 and count<=524288 then
  local c=g.chimneyOutlet;local raw=love.data.pack('string','<ffff',c and 1 or 0,c and c.x or 0,c and c.y or 0,c and c.z or 0)..table.concat(chunks)
  local encoded='BAG2'..love.data.pack('string','<I4',count)..love.data.compress('string','zlib',raw,1)
  retain(key,encoded)
  if not RAM.retainGenerated()then
   if write(prefix..key,encoded)then
    index[key]=hash(map)
    local rows={};for k,v in pairs(index)do rows[#rows+1]=v..' '..k..'\n'end;table.sort(rows);write(prefix..'index',table.concat(rows))
   end
  end
 end
 return result
end
return M
