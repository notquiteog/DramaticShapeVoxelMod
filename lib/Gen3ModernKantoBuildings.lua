-- Shared entry point for the verified regional FR/LG source families. Scene
-- ownership, style choice and native fallback remain with the caller.
local V=...
local M={}
local specs={
 {kind='saffronBlocks',building='Gen3ImportedSaffronBlocks',marker='importedSaffronBlock'},
 {kind='lavenderNameRater',building='Gen3ImportedLavenderNameRater',doors='Gen3LavenderTentEntrance',marker='importedLavenderNameRater'},
 {kind='lavenderHouses',building='Gen3ImportedLavenderHouses',doors='Gen3LavenderHouseDoors',marker='importedLavenderHouse'},
 {kind='viridianFlowerHouses',building='Gen3ImportedViridianFlowerHouses',doors='Gen3ViridianFlowerHouseDoors',marker='importedViridianFlowerHouse'},
 {kind='pewterHouses',building='Gen3ImportedPewterHouses',doors='Gen3PewterHouseDoors',marker='importedPewterHouse'},
 {kind='hgssGyms',building='Gen3ImportedHGSSGyms',doors='Gen3HGSSGymDoors',marker='importedHGSSGym'},
}
local function owner(g)
 if type(g)~='table'then return end
 for _,s in ipairs(specs)do if g[s.marker]then return s end end
end
function M.kind(g)local s=owner(g);return s and s.kind end
function M.build(g,cells,newMesh,parts)
 if type(g)~='table'or type(cells)~='table'then return false end
 for _,s in ipairs(specs)do
  local a=V.require(s.building)
  if a.eligible(g,cells)then
   local ok,err=a.build(g,cells,newMesh,parts)
   if not ok then return false,err end
   return true,s.kind
  end
 end
 return false
end
function M.draw(g,anim,draw)
 local s=owner(g);if not s then return false end
 if not s.doors then return true end
 return V.require(s.doors).draw(g,anim,draw)
end
function M.release(g)
 local s=owner(g);if not s then return false end
 if s.doors then V.require(s.doors).release(g)end;local a=V.require(s.building);if a.release then a.release(g)end;g[s.marker]=nil;return true
end
function M.ownsDoor(g,x,y)
 local s=owner(g);return s and s.doors and V.require(s.doors).ownsDoor(g,x,y)or false
end
function M.doorSurface(g,x,y)
 local s=owner(g);if not s then return end
 local a=V.require(s.building);if a.doorSurface then return a.doorSurface(g,x,y)end
end
function M.chimney(g)
 local s=owner(g);if not s then return end
 local a=V.require(s.building);if a.chimney then return a.chimney(g)end
end
return M
