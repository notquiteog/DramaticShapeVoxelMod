-- Shared presentation consumers for Game3. No GB world/state facade patches.
local V=...
local M={}
local Day=V.require('DayNight')
local Sky=V.require('Sky')
local AA=V.require('AntiAlias')
local R=V.require('Voxel3D')
local Underlay=V.require('WorldUnderlay')
local TiltShift=V.require('TiltShift')
local Community=V.require('CommunityVisuals')
M.tilt=V.require('ModSetting').new('tiltshift','T-SHIFT',{0,1,2,3},{'OFF','1','2','3'})
M.invert=V.require('CameraSettings').invertY
M.settings={AA.setting,Day.setting,Underlay.setting,Community.sky,M.invert,M.tilt,
 V.require('Water').setting}

function M.update(dt)
 Day.update(dt)
 TiltShift.setLevel(M.tilt:get())
end

function M.environment(indoor,background)
 Day.applyRig(not indoor)
 R.tint=Day.tint(not indoor)
 if indoor then return background end
 return Sky.dress({background[1],background[2],background[3],background[4] or 1})
end

function M.underlay(indoor,cx,cz,background)
 if indoor then return false end
 local mode=Underlay.selected()
 local color=mode=='black' and Underlay.COLORS.black or background
 -- NATURE follows the native outdoor horizon. Native interior boundaries
 -- are authored by InteriorDiorama, so the underlay never fills a room.
 return Underlay.draw(true,cx,cz,color)
end

function M.expand(w,h)return AA.expand(w,h)end
function M.finish(canvas,w,h)
 canvas=AA.resolve(canvas,w,h,'firered')
 return TiltShift.apply(canvas)
end
function M.release()
 AA.invalidate();TiltShift.invalidate()
 R.tint={1,1,1};R.fog=nil
end
return M
