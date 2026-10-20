local Mat=dofile('lib/Mat4.lua')
local enabled=true
local made,released,drawn=0,0,0
local contexts={}
local modules={Mat4=Mat,Voxel3D={draw=function()drawn=drawn+1 end},
 XDModels={active=function()return enabled end,newInstance=function(dex)
  made=made+1
  if dex==386 then return end
  return {metrics=function()return {height=1,floor=-.2}end,
   playContext=function(_,name)contexts[#contexts+1]=name;return true end,
   isFinished=function()return false end,
   update=function()end,release=function()released=released+1 end,
   drawWith=function(_,draw,m)assert(m[8]>=3);draw();return true end}
 end}}
package.loaded['src.core.game3.pokemon']={national=function(s)return s end,
 isShiny=function(m)return m.shiny end}
package.loaded['src.core.game3.battle.anim_coords']={battler=function(st,id)return st.battlers[id]end}
local visible=true
local nativeMoves=0
local anim={present=function()return{visible=visible,scale=1}end,
 launchMove=function()nativeMoves=nativeMoves+1;return true end,
 faintMon=function()return 'native-faint'end,idOf=function(id)return id end}
package.loaded['src.core.game3.battle.anim']=anim
package.loaded['src.core.game3.battle.moves']={get=function()return{category='special'}end}
love={timer={getDelta=function()return 1/60 end}}
local M=assert(loadfile('lib/Gen3XDActors.lua'))({require=function(k)return assert(modules[k],k)end})
local st={battlers={}}
local frame={st=st,byId={},points={},camera={yaw=0},PIXEL=.25}
for id=0,3 do st.battlers[id]={species=id==3 and 386 or 25,mon={}};frame.byId[id]={id=id};frame.points[id]={id,3,0}end
M.prepare(frame);assert(made==4)
local native=anim.launchMove
local uninstall=M.install()
assert(anim.launchMove(1,{attackerId=2})and nativeMoves==1 and contexts[1]=='special')
assert(anim.faintMon(1)=='native-faint'and contexts[2]=='faint')
M.prepare(frame);assert(made==4,'instances survive frame recreation, including failed species')
for id=0,2 do assert(M.draw(frame,frame.byId[id]));assert(M.draw(frame,frame.byId[id],function()end))end
assert(not M.draw(frame,frame.byId[3])and drawn==3,'missing model retains native art')
visible=false;M.prepare(frame);assert(not M.draw(frame,frame.byId[0]),'native visibility wins')
enabled=false;M.prepare(frame);assert(released==3)
M.clear();assert(released==3,'cleanup is idempotent')
uninstall();assert(anim.launchMove==native)
print('XD GBA actor lifecycle passed')
