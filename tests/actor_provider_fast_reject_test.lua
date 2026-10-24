-- Full-distance scenes visit connected-map actors in several render passes.
-- Unrelated actors must not touch engine/provider state in vehicle adapters.
for name,id in pairs({Gen3Boats=88,Gen3TruckExterior=94,Gen3TruckCargo=113})do
 local adapter=assert(loadfile('lib/'..name..'.lua'))({require=function()error('unrelated actor loaded provider state')end})
 for _,gid in ipairs({0,1,13,87,89,93,95,112,114,255,'invalid'})do
  if gid~=id then assert(adapter.draw(gid)==false,name..' accepted unrelated actor')end
 end
 assert(adapter.draw(nil)==false)
end
print('PASS unrelated actors reject before engine/provider access')
