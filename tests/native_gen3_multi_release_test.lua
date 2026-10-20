local st={double=true};local balls={};local present={};local points,native,byId={},{},{}
local cards={};local freed,painted={},{}
for id=0,3 do
 balls[id]={battler=id,frame=1};present[id]={visible=true,scale=.58}
 points[id]={id*10,3,20};native[id]={foot=112,y=80};byId[id]={id=id,tex=id,model={}}
 cards[#cards+1]={ball=true,event=balls[id]}
end
local stage={balls=balls}
package.loaded['src.core.game3.battle.anim']={stage=function()return stage end,present=function(id)return present[id]end}
package.loaded['src.core.game3.battle.catch_seq']={busy=function()return false end}
local serial=0;local current,failId
local R={newMesh=function()if current==failId and failId~=nil then error('GPU limit')end;serial=serial+1;local n=serial;return{release=function()freed[n]=true end,setVertices=function()end}end}
local modules={Voxel3D=R,Gen3Battle={enabled=function()return true end},PokeballSettings={active=function()return true end},
 NativeGen3SendoutShell={shell=function(_,card)return{yaw=0,mouth=function()return card.event.battler*10,4,20 end},card.event end},
 ['q57/Release']={DURATION=1.35,pose=function(t,source,mouth)return{source=source,mouth=mouth,fade=1,pull=.5}end},
 ['q57/Plasma']={newGeometry=function()return{},{}end,update=function(_,pose)current=pose.source[1]/10 end},
 ['q57/Material']={draw=function(_,_,tex,model,_,pose,subject)
  assert(pose.source[1]==pose.mouth[1],'release crossed to another actor')
  if subject then assert(tex==pose.source[1]/10);painted[tex]=true end
  return true
 end}}
local M=assert(loadfile('lib/NativeGen3Release.lua'))({require=function(k)return assert(modules[k],k)end})
local frame={st=st,cards=cards,points=points,native=native,byId=byId,PIXEL=.25}
M.prepare(frame);assert(#frame.releasePoses==4 and frame.releasePose==nil);assert(M.draw(frame))
for id=0,3 do assert(M.subject(frame,byId[id],{})and painted[id])end
assert(serial==4);M.prepare(frame);M.draw(frame);assert(serial==4,'event meshes not reused')
present[2].scale=1;M.prepare(frame);assert(#frame.releasePoses==3 and freed[3]and not freed[1]and not M.subject(frame,byId[2],{}))
cards[#cards+1]=cards[1];M.prepare(frame);assert(#frame.releasePoses==2 and not frame.releaseById[0]and frame.releaseById[1])
table.remove(cards);M.prepare(frame);assert(#frame.releasePoses==3)
local event=balls[0];balls[0]={battler=0,frame=1};cards[1].event=balls[0]
M.prepare(frame);assert(frame.releaseById[0].native~=event)
M.clear();for n=1,4 do assert(freed[n],'native event mesh leaked')end
assert(present[0].scale==.58 and balls[0].frame==1,'cleanup changed native state')
failId=1;M.prepare(frame);assert(M.draw(frame),'one failed volume disabled the others')
assert(not M.subject(frame,byId[1],{})and M.subject(frame,byId[0],{}),'failed volume tinted the wrong actor')
M.clear();for n=1,serial do assert(freed[n],'partial failure leaked a surviving event mesh')end
print('PASS four native release owners, distinct subject material, independent completion/ambiguity/replacement and bounded mesh reuse')
