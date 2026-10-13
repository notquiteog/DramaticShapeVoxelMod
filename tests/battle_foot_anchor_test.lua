local Mat=dofile('lib/Mat4.lua')
package.loaded['src.render.PaletteFX']={}
local modules={Mat4=Mat,Voxel3D={eye={0,20,50}},BattleBillboard={FULL_W=16,FULL_PIC=56,yawToward=function()return 0 end},SafariFooting={ground=function(_,_,_,h)return h end}}
local V={require=function(name)return modules[name]or{}end}
local M=assert(loadfile('lib/BattleScene.lua'))(V)
for _,h in ipairs({144,145,151})do for _,ay in ipairs({96,143,144})do
 local tex={canvas={getWidth=function()return 160 end,getHeight=function()return h end},ax=80,ay=ay}
 local cards=M.monCards({player={0,0},enemy={16,0}},7,{enemy=tex},{})
 local m=cards[1].model
 local visibleY=1-ay/h
 assert(math.abs(m[6]*visibleY+m[8]-7)<1e-8,'fractional foot correction leaves visible sprite floating')
 -- A deliberate four-source-pixel hop still rises by four pixel pitches.
 assert(math.abs(m[6]*(visibleY+4/h)+m[8]-(7+4*16/56))<1e-8)
end end
print('PASS exact battle foot anchors across padded canvas sizes; explicit hops retained')
