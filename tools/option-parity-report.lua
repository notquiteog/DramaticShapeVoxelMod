-- Run from the mod root. A source inventory, not a claim of runtime QA.
local cache={}
local V={}
function V.require(name)
 if not cache[name]then cache[name]=assert(loadfile('lib/'..name..'.lua'))(V)end
 return cache[name]
end
local support=V.require('OptionSupport')
print('generation\tkey\tlabel\tstatus\tconsumer\tlimitation')
for gen=1,3 do for _,row in ipairs(support.inventory(gen))do
 print(table.concat({gen,row.key,row.label,row.status,tostring(row.consumer),row.detail},'\t'))
end end
