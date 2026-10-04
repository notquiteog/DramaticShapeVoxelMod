-- Legendary Pokemon Tower exterior detector + Gothic geometry.
local checks=0
local function check(v,msg) checks=checks+1; assert(v,msg) end
local custom=true
local CV={referenceBuildings=function()return false end,customTower=function() return custom end,towerWallStyle=function() return 'smoke_black' end}
local Voxel3D={newMesh=function(v,i) return {v=v,i=i} end,draw=function() end}
local Mat4={translate=function(x,y,z)return{x=x,y=y,z=z}end,mul=function(a,b)return{a=a,b=b}end}
local modules={Voxel3D=Voxel3D,Mat4=Mat4,CommunityVisuals=CV}
local V={require=function(name)return assert(modules[name],name)end}
local M=assert(loadfile('lib/LegendaryTowerExterior.lua'))(V)
local vertices,indices=M.geometry()
check(#vertices>150 and #indices>200,'Gothic exterior has substantial authored geometry')
local maxY,minX,maxX=0,1e9,-1e9
for _,v in ipairs(vertices)do maxY=math.max(maxY,v[2]);minX=math.min(minX,v[1]);maxX=math.max(maxX,v[1])end
check(maxY>=170,'centre Gothic spire reaches intended tower height')
check(minX<0 and maxX>96,'roof eaves project beyond the exact source footprint')

local BODY={
 {15,10,10,10,10,10,10,10,10,10,10,31},{15,75,75,75,75,75,75,75,75,75,75,31},
 {15,10,10,10,10,10,10,10,10,10,10,31},{15,75,75,75,75,75,75,75,75,75,75,31},
 {15,10,10,10,10,10,10,10,10,10,10,31},{15,75,75,75,75,75,75,75,75,75,75,31},
 {15,75,75,75,75,75,75,75,75,75,75,31},{78,26,26,26,26,26,26,26,26,26,26,79,17},
}
local tx,ty=5,3
local grid={}
for r,row in ipairs(BODY)do for c,id in ipairs(row)do grid[(ty+r-1)..':'..(tx+c-1)]=id end end
local map={id='LAVENDER_TOWN',tileset={id='OVERWORLD'},def={width=8,height=5}}
function map:tileAt(x,y)return grid[y..':'..x] or 0 end
local at=M.detect(map)
check(at and at.tx==tx and at.ty==ty and at.width==12 and at.height==8,'detector follows exact Lavender source drawing')
check(M.activeFor(map,{id='pokemon_tower'}),'Legendary Tower option owns exterior template')
check(not M.activeFor({id='LAVENDER_TOWN',tileset={id='OVERWORLD'},def={width=8,height=5}},
  {id='pokemon_tower'}),'stock exterior survives when Legendary footprint detection is unavailable')
custom=false
check(not M.activeFor(map,{id='pokemon_tower'}),'Battle Art keeps stock exterior template')
print(checks..' checks passed (Legendary Tower exterior)')
