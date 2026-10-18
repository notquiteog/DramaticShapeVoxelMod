-- Native transforms/masks are already baked into the card. Share the GB
-- intake color/full-bright pass without scaling that native animation twice.
local V=...
local R=V.require('Voxel3D')
local M={}
local WHITE={1,1,1}
local function pack(...)return {n=select('#',...),...}end
function M.intake(st,id)
 local Capture=V.require('Gen3Capture')
 if id~=Capture.target(st)then return end
 local intake=Capture.intake(st)
 if type(intake)=='table'and intake.active and type(intake.color)=='table'then return intake end
end
function M.draw(st,card,mesh,sun)
 local intake=M.intake(st,card.id)
 if not intake then return R.draw(mesh,card.tex,card.model,0,sun)end
 local tint=R.tint
 R.flatten(intake.color,intake.colorAmount)
 R.tint=WHITE;R.dayTint(WHITE);R.lighting(false)
 local result=pack(pcall(R.draw,mesh,card.tex,card.model,0,nil))
 R.tint=tint;R.lighting(not V.require('UiBackplates').spritesUnlit());R.dayTint();R.flatten(nil)
 if not result[1]then error(result[2],0)end
 return unpack(result,2,result.n)
end
return M
