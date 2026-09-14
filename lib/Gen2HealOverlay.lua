-- Crystal owns the party count, timing and palette rotation. Project each
-- native OAM piece onto the horizontal machine, independently of the camera.
local V=...
local M={}
function M.points(state,ha)
 local out={}
 if not (ha and ha.layout) then return out end
 local ox,oz=ha.px-64,ha.py-64
 local anchor=(ha.layout.machine or ha.layout.balls)[1]
 if not anchor then return out end
 local ax,az=ox+anchor[1]+4,oz+anchor[2]+4
 local height=0
 local bed
 if not ha.hof and state and state.map then
  local structures=V.require('Structures').forMap(state.map)
  local best=math.huge
  for _,f in ipairs(structures and structures.furniture or {}) do
   if f.id=='crystal_center_healer' or f.id=='crystal_healing_machine' then
    local dx=math.max(f.x0-ax,0,ax-f.x1)
    local dz=math.max(f.z0-az,0,az-f.z1)
    local dist=dx*dx+dz*dz
    if dist<best then best=dist;height=f.height or 6;bed=f end
   end
  end
 end
 -- Furniture recipes relocate the imported two-cell machine horizontally.
 -- Seat the native two-column/three-row layout within its actual footprint.
 if bed then
  ox=ox+(bed.x0+bed.x1)/2-(ox+ha.layout.balls[1][1]+8)
  oz=oz+(bed.z0+bed.z1)/2-(oz+ha.layout.balls[3][2]+4)
 end
 local function add(kind,b)
  out[#out+1]={kind=kind,x=ox+b[1]+4,z=oz+b[2]+4,
   h=height+(kind=='ball' and 2.5 or .8),flip=b[3]==true,ink={x=4,y=4}}
 end
 for _,b in ipairs(ha.layout.machine or {}) do add('monitor',b) end
 for i=1,math.min(ha.lit or 0,#ha.layout.balls) do add('ball',ha.layout.balls[i]) end
 return out
end
function M.sheet(state)
 local img=state and state.healMachineImage
 if not img then return nil end
 if not state.healMachineQuads then
  local w,h=img:getDimensions()
  state.healMachineQuads={machine=love.graphics.newQuad(0,0,8,8,w,h),
   ball=love.graphics.newQuad(8,0,8,8,w,h)}
 end
 return img,{state.healMachineQuads.machine,state.healMachineQuads.ball}
end
function M.colors(state,ha)
 local P=require('src.render.GbcPalette')
 local pal=state.healMachinePalette
 if not pal then return nil end
 local byte=0
 for i=0,3 do byte=byte+((i+(ha.rotation or 0))%4)*4^i end
 return P.remap(P.resolve(pal),byte)
end
return M
