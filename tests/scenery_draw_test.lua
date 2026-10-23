local calls,opacity={},nil
local R={withSceneryMaterial=function(a,fn)local before=opacity;opacity=a;local ok,err=pcall(fn);opacity=before;if not ok then error(err)end end}
local D=assert(loadfile('lib/SceneryDraw.lua'))({require=function(n)return n=='FrustumCull'and dofile('lib/FrustumCull.lua')or R end})
local parts={{mesh='solid',image='s',count=1,opacity=1},{mesh='cutout',count=1,alphaMode='cutout'},
 {mesh='near',count=1,opacity=.29,center={2,0,0}},{mesh='far',count=1,alphaMode='blend',center={10,0,0}},
 {mesh='hidden',count=1,opacity=0},{mesh='empty',count=0},{mesh='ground',count=1,role='ground_shadow'}}
local function draw(mesh)calls[#calls+1]={mesh,opacity}end
D.opaque(parts,draw,true);assert(#calls==2 and calls[1][1]=='solid'and calls[2][1]=='cutout')
calls={};D.opaque(parts,draw,false);assert(#calls==3 and calls[3][1]=='ground')
calls={};assert(D.blended(parts,draw,{0,0,0})==2)
assert(calls[1][1]=='far'and calls[1][2]==1 and calls[2][1]=='near'and calls[2][2]==.29)
assert(opacity==nil)
assert(not pcall(D.blended,parts,function()error('provider failure')end,{0,0,0}));assert(opacity==nil)
local cards={{mesh='flowers',count=19,role='hd2d_flower_cards'}}
R.canopyFacing=false
D.opaque(cards,function()assert(R.canopyFacing)end,false);assert(R.canopyFacing==false)
assert(not pcall(D.opaque,cards,function()assert(R.canopyFacing);error('flower draw failure')end,true));assert(R.canopyFacing==false)
print('PASS opaque/cutout ownership, blended depth order, source opacity, zero-alpha omission and failed-provider scope cleanup')

local F=dofile('lib/FrustumCull.lua')
local planes=F.prepare(dofile('lib/Mat4.lua').identity())
local clipped={{mesh='outside',count=1,bounds={5,5,5,6,6,6}},
 {mesh='edge',count=1,bounds={1,0,0,2,1,1}},
 {mesh='unknown',count=1},
 {mesh='billboard',count=1,role='hd2d_flower_cards',bounds={5,5,5,6,6,6}}}
calls={};D.opaque(clipped,draw,false,planes)
assert(#calls==3 and calls[1][1]=='edge'and calls[2][1]=='unknown'and calls[3][1]=='billboard')
calls={};D.opaque(clipped,draw,true,planes);assert(#calls==4,'offscreen shadow caster culled')
calls={};D.opaque(clipped,draw,false,nil);assert(#calls==4,'absent/curved camera failed open')
print('PASS physical main-pass culling preserves edge, unknown bounds, billboards and all shadow casters')
