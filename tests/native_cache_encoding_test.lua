local C=assert(loadfile('lib/NativeGeometryCache.lua'))({require=function()return {}end}).canonical
local function reference(v,seen)
 local t=type(v)
 if t=='nil'then return'n'elseif t=='boolean'then return v and't'or'f'elseif t=='number'then return'd'..string.format('%.17g',v)..';'elseif t=='string'then return's'..#v..':'..v end
 seen=seen or{};assert(not seen[v]);seen[v]=true
 local keys={};for k in pairs(v)do keys[#keys+1]=k end
 table.sort(keys,function(a,b)return reference(a)<reference(b)end)
 local out={'{'};for _,k in ipairs(keys)do out[#out+1]=reference(k)..reference(v[k],seen)end
 seen[v]=nil;out[#out+1]='}';return table.concat(out)
end
local values={true,false,12,-3.5,'hello',{[1]='one',[10]='ten',[2]='two',foo=false,nested={a=3,b=4}}}
for _,v in ipairs(values)do assert(C(v)==reference(v))end
local settings={};for i=1,240 do settings['setting'..i]=i%3==0 and false or i end
assert(C(settings)==reference(settings))
local shared={x=1};assert(C({shared,shared})==reference({shared,shared}))
local cyclic={};cyclic.self=cyclic;assert(not pcall(C,cyclic))
assert(not pcall(C,{x=0/0}));assert(not pcall(C,{x=math.huge}))
print('PASS canonical ordering, nested settings, shared values and invalid-record rejection')
