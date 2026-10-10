local glow,particles,suction=1,.75,true
local V={};local loaded={};local calls,newMeshes=0,0
local states={}
local gpu={eye={20,10,20},seams=function(x)states.seams=x end,glass=function(x)states.glass=x end,
 blend=function(x)states.blend=x end,draw=function()calls=calls+1 end,
 newMesh=function(vertices,indices)newMeshes=newMeshes+1;return{setVertices=function(self,v)self.vertices=v end,release=function(self)self.released=true end,vertices=vertices}end}
gpu.pushQuad=function(map,n)local a=n*4+1;for _,i in ipairs({a,a+1,a+2,a,a+2,a+3})do map[#map+1]=i end end
gpu.withEffect=function(mode,draw)assert(mode=="add");draw();states.seams=true;states.glass=true end
function V.require(k)
 if k=='Voxel3D'then return gpu end
 if k=='PokeballSettings'then return{pokemonGlowMult=function()return glow end,suctionParticleMult=function()return particles end,suctionEnabled=function()return suction end,fxScaleMult=function()return 1 end}end
 loaded[k]=loaded[k]or assert(loadfile('lib/'..k..'.lua'))(V);return loaded[k]
end
love={image={newImageData=function()return{setPixel=function()end}end},graphics={newImage=function()return{setFilter=function()end}end}}
local Ball=V.require('Pokeball');local ball=setmetatable({visible=true,ball='MASTER_BALL',pos={0,2,0},scale=1,glossT=.3},Ball)
local function count()
 local n=0;ball:captureAura(0,8,24,.8,0,function(m)for _,x in ipairs(m)do assert(x==x and math.abs(x)<1e5)end;n=n+1 end);return n
end
local all=count();assert(all>50)
glow=0;assert(count()==all-6,'glow OFF must remove its six aura cards')
particles=0;assert(count()==4,'particles OFF keeps only the legacy ball core')
suction=false;assert(count()==0);glow=1;assert(count()==6,'glow remains independent of particle choreography')
suction=true;particles=.01;count() -- a single ring must remain finite
particles=.75;local cache={};assert(ball:drawCaptureAura(0,8,24,.8,0,cache));assert(calls<=7,'sparks must batch by depth')
local allocated=newMeshes;calls=0;assert(ball:drawCaptureAura(0,8,24,.8,0,cache));assert(newMeshes==allocated,'steady animation must reuse GPU meshes')
assert(states.seams and states.glass and states.blend==nil,'render state leaked')
print('PASS capture aura independent options, finite geometry, batched/reused GPU cards and render state')
