local list=assert(loadfile('data/gen2_furniture.lua'))().TILESET_UNDERGROUND
local recipe=list[2]
assert(recipe.model=='planter' and #recipe.tiles==4 and recipe.drawingRows==3)
assert(recipe.tiles[4][1]==16 and recipe.tiles[4][2]==16,'unclaimed floor row becomes a partial-cell wall')
assert(recipe.maps.OLIVINE_PORT_PASSAGE and recipe.maps.VERMILION_PORT_PASSAGE and recipe.maps.TEAM_ROCKET_BASE_B1F and not recipe.maps.SAFFRON_GYM)
local V={require=function(n)
 if n=='SceneryMask' then return dofile('lib/SceneryMask.lua')end
 if n=='TreePresentation' then return {props={get=function()return 'solid'end}}end
 error(n)
end}
local P=assert(loadfile('lib/Gen2Planter.lua'))(V)
P.fromDrawing=function(w,h,pixel)
 assert(w==16 and h==24,'floor padding changes the native plant proportions')
 return {w,h}
end
local q=P.build(recipe,{getPixel=function()return .3,.7,.2,1 end},16,128,128)
assert(q[1]==16 and q[2]==24)
print('PASS storage plants: complete blocked-cell claim, native drawing crop and reviewed map scope')
