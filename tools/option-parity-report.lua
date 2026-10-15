-- Run from the mod root. A source inventory, not a claim of runtime QA.
local cache={}
local V={}
function V.require(name)
 if not cache[name]then cache[name]=assert(loadfile('lib/'..name..'.lua'))(V)end
 return cache[name]
end
local support=V.require('OptionSupport')
if arg and arg[1]=='--json' then
 local function quote(value)
  if value==false then return 'false' end
  return '"'..tostring(value):gsub('[%z\1-\31\\"]',function(c)
   return string.format('\\u%04x',c:byte())
  end)..'"'
 end
 print('{"generations":{')
 for gen=1,3 do
  print(quote(gen)..':[')
  local rows=support.inventory(gen)
  for i,row in ipairs(rows)do
   local fields={}
   for _,key in ipairs({'generation','key','label','module','status','consumer','detail','verification'})do
    fields[#fields+1]=quote(key)..':'..(key=='generation'and tostring(row[key])or quote(row[key]))
   end
   print('{'..table.concat(fields,',')..'}'..(i<#rows and ','or''))
  end
  print(']'..(gen<3 and ','or''))
 end
 print('},"verification":"Source-consumer inventory generated from lib/OptionSupport.lua. Individual runtime checks are documented separately; this inventory is not full gameplay verification."}')
 return
end
print('generation\tkey\tlabel\tstatus\tconsumer\tlimitation')
for gen=1,3 do for _,row in ipairs(support.inventory(gen))do
 print(table.concat({gen,row.key,row.label,row.status,tostring(row.consumer),row.detail},'\t'))
end end
