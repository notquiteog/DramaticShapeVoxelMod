-- Reviewed original ORAS building/door transaction. The Scene owns body batches;
-- this facade owns cached door states and exposes one atomic native-fallback API.
local V=...
local M={}
local gyms={kind='hoennGyms',adapter='Gen3ImportedGyms',doors='Gen3GymDoors',marker='importedGymDoors',models={oras_hoenn_gym=true}}
local marts={kind='hoennMarts',adapter='Gen3ImportedMarts',doors='Gen3MartDoors',marker='importedMartDoors',models={oras_oldale_mart=true,oras_petalburg_mart=true,oras_rustboro_mart=true}}
local homes={kind='oldaleHomes',adapter='Gen3ImportedOldaleHomes',doors='Gen3OldaleDoors',marker='importedOldaleDoors',models={oras_oldale_home_northwest=true,oras_oldale_home_southeast=true}}
local petalburg={kind='petalburgHomes',adapter='Gen3ImportedPetalburgHomes',doors='Gen3PetalburgDoors',marker='importedPetalburgDoors',models={oras_petalburg_home_wide=true,oras_petalburg_home_west=true,oras_petalburg_home_east=true}}
local rustboro={kind='rustboroHomes',adapter='Gen3ImportedRustboroHomes',doors='Gen3RustboroDoors',marker='importedRustboroDoors',models={oras_rustboro_cutters=true,oras_rustboro_house1=true,oras_rustboro_house2=true,oras_rustboro_school=true,oras_rustboro_flat1=true,oras_rustboro_house3=true}}
local routes={petalburg_city_gym=gyms,dewford_town_gym=gyms,rustboro_city_gym=gyms,
 oldale_mart=marts,petalburg_city_mart=marts,rustboro_city_mart=marts,oldale_house=homes,petalburg_city_home=petalburg,petalburg_city_wide_home=petalburg,rustboro_small_tan=rustboro,rustboro_white_small=rustboro,rustboro_east_tan=rustboro,rustboro_wide_tan=rustboro,rustboro_south_tan=rustboro}
local function route(g)
 return g and g.custom and g.custom.family=='rse'and routes[g.custom.name]
end
function M.release(g)
 local r=route(g);if not r then return end
 V.require(r.doors).release(g)
 if g.importedHoenn and r.models[g.importedHoenn.model]then g.importedHoenn=nil end
 g.modernHoennBuilding=nil
 if r==gyms then g.importedGymY=nil end
end
function M.build(g,cells,newMesh,parts)
 local r=route(g);if not r then return false end
 if type(newMesh)~='function'or type(parts)~='table'then return false,'invalid reviewed Hoenn upload request'end
 M.release(g)
 local first=#parts+1
 local ok,built,reason=pcall(function()return V.require(r.adapter).build(g,cells,newMesh,parts)end)
 if not(ok and built and g.importedHoenn and r.models[g.importedHoenn.model]and g[r.marker])then
  M.release(g)
  -- An unexpected provider exception after partial body upload must preserve
  -- preceding scene resources and unwind only this building's new resources.
  for i=#parts,first,-1 do V.require('SceneryModels').releaseBatches({parts[i]});parts[i]=nil end
  return false,ok and(reason or'builder did not prepare complete source building and doors')or tostring(built)
 end
 g.modernHoennBuilding=g.custom.name
 return true
end
function M.kind(g)
 local r=route(g);return r and g.modernHoennBuilding==g.custom.name and r.kind or nil
end
function M.draw(g,anim,draw)
 local r=route(g);if not(r and g.modernHoennBuilding==g.custom.name and g[r.marker])then return false end
 return V.require(r.doors).draw(g,anim,draw)
end
function M.ownsDoor(g,x,y)
 local r=route(g)
 return r and g.modernHoennBuilding==g.custom.name and g[r.marker]~=nil and V.require(r.doors).ownsDoor(g,x,y)or false
end
function M.prepare(cells,newMesh,parts)
 return V.require('Gen3ImportedGymNotices').build(cells,newMesh,parts)
end
function M.ownsProp(p)return V.require('Gen3ImportedGymNotices').ownsProp(p)end
function M.ground(c)return V.require('Gen3ImportedGymNotices').floor(c)end
return M
