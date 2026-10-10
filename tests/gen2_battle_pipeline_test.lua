local M=dofile('lib/Gen2BattlePipeline.lua')
local stage=false
local selected=nil
local P={worldPipeline=function()return selected end}
local W={draw=function()return P.worldPipeline()end}
assert(M.install(W,P,function()return stage end))
assert(W:draw()==nil and P.worldPipeline()==nil)
stage=true
assert(W:draw()=='voxel' and P.worldPipeline()==nil)
selected='other'
assert(W:draw()=='voxel' and P.worldPipeline()=='other')
stage=false
assert(W:draw()=='other')
assert(M.install(W,P,function()error('double installed')end))
stage=true
assert(W:draw()=='voxel')
-- A failed render must never force voxel on Options or the next world frame.
local Q={worldPipeline=function()return nil end}
local E={draw=function()assert(Q.worldPipeline()=='voxel');error('render failed')end}
assert(M.install(E,Q,function()return true end))
assert(not pcall(E.draw,E));assert(Q.worldPipeline()==nil)
print('Gen2 battle pipeline scope PASS')
