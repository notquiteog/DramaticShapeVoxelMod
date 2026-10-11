-- Kanto First Person's pixel umbrella, permitted by its author. Rain stays
-- owned by Weather; this bounded prop pass never spawns rain or changes actors.
local V=...
local M={}
M.setting=V.require('ModSetting').new('kfpUmbrellas','RAIN UMBRELLAS',{false,true},{'OFF','ON'})
M.settings={M.setting}
local image,mesh
local function makeUmbrella()
  local ok, img = pcall(function()
    local S = 16
    local data = love.image.newImageData(S, S)
    local DARK = { 0.13, 0.13, 0.18 }
    local BODY = { 0.83, 0.24, 0.28 }
    local LITE = { 0.96, 0.52, 0.50 }
    local SHAF = { 0.55, 0.44, 0.30 }
    local function put(x, y, c, a)
      if x >= 0 and y >= 0 and x < S and y < S then
        data:setPixel(x, y, c[1], c[2], c[3], a or 1)
      end
    end
    -- The pole sits a pixel right of centre, and the whole thing is
    -- drawn around it: carried off to one side, the way a person holds
    -- an umbrella, rather than balanced on their head.  Baking the
    -- offset into the ART keeps it true from every angle, which a world
    -- offset would not -- a billboard turns to face you.
    local POLE = 9

    -- the canopy, higher in the frame now to leave room for the pole
    for x = 0, 15 do
      local dx = (x - POLE + 0.5) / 8.5
      local top = math.floor(1 + dx * dx * 3.5)
      for y = top, 5 do
        local c = (y == top) and DARK or ((x < POLE) and LITE or BODY)
        put(x, y, c)
      end
    end
    -- the scalloped hem
    for x = 0, 15 do
      put(x, 5, DARK)
      if (x % 4) == 1 or (x % 4) == 2 then put(x, 6, BODY); put(x, 7, DARK) end
    end
    -- the pole: all the way down the frame, so the grip lands at the
    -- height this is drawn at rather than somewhere above the sprite
    for y = 5, 15 do
      put(POLE, y, SHAF)
      put(POLE + 1, y, DARK)
    end
    -- a hand-sized grip, and the crook turning off to the left
    put(POLE, 11, DARK); put(POLE + 1, 11, DARK)
    put(POLE - 1, 14, SHAF); put(POLE - 2, 15, SHAF)
    put(POLE - 1, 15, DARK)
    local i = love.graphics.newImage(data)
    i:setFilter("nearest", "nearest")
    data:release()
    return i
  end)
  return ok and img or nil
end


function M.draw(actors,map,time,yaw)
 if not M.setting:get()then return 0 end
 local mode=V.require('Weather').mode(map)
 if mode~='rain'and mode~='storm'then return 0 end
 local R=V.require('Voxel3D');local T=V.require('Mat4')
 if not image then image=makeUmbrella()end
 if not image then return 0 end
 if not mesh then
  local indices={};R.pushQuad(indices,0)
  mesh=R.newMesh({{-.5,.5,0,0,0,1},{.5,.5,0,1,0,1},{.5,-.5,0,1,1,1},{-.5,-.5,0,0,1,1}},indices)
 end
 local count=0
 love.graphics.push('all')
 local ok,err=pcall(function()
  love.graphics.setDepthMode('lequal',false)
  for _,actor in ipairs(actors or {})do
   -- Require the owning scene to positively identify a human. Never give
   -- unknown objects, Pokémon, followers or the first-person player a prop.
   if actor.human==true and not actor.player and actor.x and actor.z then
    local height=actor.height or 24
    local model=T.mul(T.mul(T.translate(actor.x,(actor.ground or 0)+height-1,actor.z),T.rotateY(-(yaw or 0))),T.scale(15,15,1))
    R.draw(mesh,image,model);count=count+1
    if count==32 then break end
   end
  end
 end)
 love.graphics.pop()
 M.error=not ok and tostring(err)or nil
 return count
end
function M.invalidate()
 if image then image:release()end;if mesh then mesh:release()end
 image,mesh=nil,nil
end
return M
