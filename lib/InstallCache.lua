-- Indexed installation cache. Public mod.cache has scoped byte I/O but no
-- directory enumeration; this bounded index supplies only this owner's keys.
local M={}
local MAX_KEYS,MAX_INDEX=32768,4*1024*1024
local function valid(key)
 return type(key)=='string'and #key>0 and #key<=512 and key:match('^[%w_./%-]+$')
  and key:sub(1,1)~='/'and not key:find('..',1,true)
end
function M.new(api,version)
 if not(api and api.read and api.write and api.delete)then return nil end
 assert(type(version)=='string'and version:match('^[%w_-]+$'),'cache version required')
 local root='voxel/'..version..'/'
 local indexKey=root..'index.txt';local keys,count={},0
 local ok,text=pcall(api.read,api,indexKey)
 if ok and type(text)=='string'and #text<=MAX_INDEX then
  for key in text:gmatch('[^\r\n]+')do
   if valid(key)and not keys[key]and count<MAX_KEYS then keys[key]=true;count=count+1 end
  end
 end
 local function save()
  local lines={};for key in pairs(keys)do lines[#lines+1]=key end;table.sort(lines)
  local body=table.concat(lines,'\n')
  if #body>MAX_INDEX then return nil,'cache index limit exceeded'end
  return api:write(indexKey,body)
 end
 local out={}
 function out:list(prefix)
  local names={}
  for key in pairs(keys)do if not prefix or key:sub(1,#prefix)==prefix then names[#names+1]=key end end
  table.sort(names);return names
 end
 function out:readBytes(key)
  if not valid(key)then return nil,'invalid cache key'end
  return api:read(root..key)
 end
 function out:writeBytes(key,bytes)
  if not valid(key)then return nil,'invalid cache key'end
  if not keys[key]and count>=MAX_KEYS then return nil,'cache index limit exceeded'end
  local wrote,why=api:write(root..key,bytes);if not wrote then return wrote,why end
  if not keys[key]then
   keys[key]=true;count=count+1
   local indexed,err=save()
   if not indexed then keys[key]=nil;count=count-1;api:delete(root..key);return nil,err end
  end
  return true
 end
 function out:delete(key)
  if not valid(key)then return nil,'invalid cache key'end
  local removed,why=api:delete(root..key)
  if not removed then return removed,why end
  if keys[key]then keys[key]=nil;count=count-1;return save()end
  return true
 end
 return out
end
return M
