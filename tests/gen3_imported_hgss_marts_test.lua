local mods={SceneryModelData={},HGSSMartData=dofile('lib/HGSSMartData.lua'),ModelInstances={},BuildBudget={check=function()end}}
local V={mod={read=function()return nil end}};V.require=function(n)return assert(mods[n],n)end
local S=assert(loadfile('lib/SceneryModels.lua'))(V);mods.SceneryModels=S;mods.Gen3ImportedGyms=assert(loadfile('lib/Gen3ImportedGyms.lua'))(V)
local H=assert(loadfile('lib/Gen3ImportedHGSSMarts.lua'))(V);mods.Gen3ImportedHGSSMarts=H;local D=assert(loadfile('lib/Gen3HGSSMartDoors.lua'))(V);mods.Gen3HGSSMartDoors=D
for _,q in ipairs{{'FR_PEWTER_CITY',26,15,'pewter_outdoor'},{'FR_SAFFRON_CITY',38,18,'general__rom_082d4b9c'},{'FR_SAFFRON_CITY_CONNECTION',28,11,'general__rom_082d4b9c'}}do
 local name,cx,cy,pair=unpack(q);local saffron=name~='FR_PEWTER_CITY';local closed=name=='FR_SAFFRON_CITY_CONNECTION';local g={kind='mart',cx=cx+10,cy=cy+7,width=4,depth=4,pair=pair,groundHeight=0};local region={def={id=name},x=10,y=7};local rows=saffron and{{760,761,762,763},{48,49,50,51},{56,57,58,59},{758,65,98,759}}or{{40,41,42,43},{48,49,50,51},{56,57,58,59},{64,65,98,99}};local cells={}
 for y,row in ipairs(rows)do for x,mid in ipairs(row)do cells[(g.cx+x-1)..':'..(g.cy+y-1)]={civic=g,pair=pair,mid=mid,region=region,base=y==1 and 16 or 0,collision=y==1 and 0 or y==4 and(x<=2 and 130 or x==3 and(not closed and 113 or 7)or 7)or 7}end end
 assert(H.eligible(g,cells));local c=cells[g.cx..':'..(g.cy+3)];c.collision=0;assert(not H.eligible(g,cells));c.collision=130;c.mid=0;assert(not H.eligible(g,cells));c.mid=rows[4][1];c.boundary=true;assert(not H.eligible(g,cells));c.boundary=nil
 assert(H.register());local opts={width=64,depth=48,padding=.25,groundInset=.05,anchor='door',targetX=40,targetZ=40};local parts,fit=assert(S.vertices(H.id,opts));fit.model=H.id;assert(H.clearance(g,cells,parts));assert(c.collision==130,'clearance must never rewrite native WALL130 cells');assert(fit.bounds[4]-fit.bounds[1]>59 and fit.bounds[6]-fit.bounds[3]>45 and fit.anchors.door[1]==40 and fit.anchors.door[3]==40)
 local left=cells[(g.cx+1)..':'..(g.cy+3)];left.collision=0;assert(not H.clearance(g,cells,parts),'source sign/facade must not enter actual walking ground');left.collision=130
 for state=0,2 do local ps=assert(D.geometry(g,fit,state));local n=0
  for _,p in ipairs(ps)do n=n+#p.indices/3;local a={vertices={},indices=p.indices};for _,v in ipairs(p.vertices)do a.vertices[#a.vertices+1]={v[1]-g.cx*16,v[2],v[3]-(g.cy+1)*16}end;assert(H.clearance(g,cells,{a}),'hinged source panel must stay inside native blocked mask')end;assert(n==2)
 end
 assert(not H.build(g,cells,function()error('PNG failure must precede mesh upload')end,{}));assert(not g.importedHGSSMart and not D.ownsDoor(g,g.cx+2,g.cy+3))
 local image=S.image;S.image=function()return{}end;local live,calls=0,0;local function mesh()live=live+1;return{setTexture=function()end,release=function()live=live-1 end}end
 assert(not D.build(g,fit,function()calls=calls+1;if calls==2 then return nil end;return mesh()end,cells));assert(live==0 and not g.importedHGSSMartDoors)
 assert(D.build(g,fit,mesh,cells));assert(live==3 and D.ownsDoor(g,g.cx+2,g.cy+3));D.release(g);assert(live==0);S.image=image
end
print('PASS exact regional native Mart guards/WALL130, source-filled footprint/portal, bounded original2-triangle door poses and atomic PNG/upload fallback')
