local Mat=dofile('lib/Mat4.lua')
local enabled=true
local style='hd2d'
local form='default';local substitute,pending,ghost=false,false,false
local matrices={}
local made,released,drawn=0,0,0
local contexts={}
local modules={VisualStyles={modern=function(category)assert(category=='pokemon');return style=='modern'end},Mat4=Mat,Voxel3D={draw=function()drawn=drawn+1 end},
 XDModels={active=function()return enabled end,formFor=function()return form end,newInstance=function(dex,variant,opts)
  assert(opts.form==form)
  made=made+1
  if dex==386 then error('deliberate optional provider construction failure')end
  return {metrics=function()return {height=1,floor=-.2}end,
   playContext=function(_,name)contexts[#contexts+1]=name;return true end,
   isFinished=function()return false end,
   update=function()end,release=function()released=released+1 end,
   drawWith=function(_,draw,m)assert(m[8]>=3);matrices[#matrices+1]=m;draw();return true end}
 end}}
package.loaded['src.core.game3.pokemon']={national=function(s)return s end,
 isShiny=function(m)return m.shiny end}
package.loaded['src.core.game3.battle.anim_coords']={battler=function(st,id)return st.battlers[id]end}
local visible=true
local nativeMoves=0
package.loaded['src.core.game3.battle.ui']={showsGhost=function()return ghost end}
local anim={present=function()return{visible=visible,scale=1,substitute=substitute,pendingTransform=pending}end,
 launchMove=function()nativeMoves=nativeMoves+1;return true end,
 faintMon=function()return 'native-faint'end,idOf=function(id)return id end}
package.loaded['src.core.game3.battle.anim']=anim
package.loaded['src.core.game3.battle.moves']={get=function()return{category='special'}end}
love={timer={getDelta=function()return 1/60 end}}
local M=assert(loadfile('lib/Gen3XDActors.lua'))({require=function(k)return assert(modules[k],k)end})
local st={battlers={}}
local frame={st=st,byId={},points={},camera={yaw=0},PIXEL=.25}
for id=0,3 do st.battlers[id]={species=id==3 and 386 or 25,mon={}};frame.byId[id]={id=id};frame.points[id]={id,3,0}end
M.prepare(frame);assert(made==0,'HD2D default must not allocate enabled model providers')
style='modern';M.prepare(frame);assert(made==4)
local native=anim.launchMove
local uninstall=M.install()
assert(anim.launchMove(1,{attackerId=2})and nativeMoves==1 and contexts[1]=='special')
assert(anim.faintMon(1)=='native-faint'and contexts[2]=='faint')
M.prepare(frame);assert(made==4,'instances survive frame recreation, including failed species')
for id=0,2 do assert(M.draw(frame,frame.byId[id]));assert(M.draw(frame,frame.byId[id],function()end))end
assert(not M.draw(frame,frame.byId[3])and drawn==3,'failed optional model retains native art')
local first=matrices[1]
frame.camera.yaw=1.9;M.prepare(frame);assert(M.draw(frame,frame.byId[0]))
for i=1,16 do assert(math.abs(first[i]-matrices[#matrices][i])<1e-8,'model turns with orbit camera')end
for _,which in ipairs({'substitute','pending','ghost'})do
 substitute=which=='substitute';pending=which=='pending';ghost=which=='ghost'
 M.prepare(frame);assert(not M.draw(frame,frame.byId[0]),'native '..which..' art hidden')
end
substitute,pending,ghost=false,false,false
form='1';M.prepare(frame);assert(made==8 and released==3,'form change did not replace instances')
visible=false;M.prepare(frame);assert(not M.draw(frame,frame.byId[0]),'native visibility wins')
style='hd2d';assert(not M.draw(frame,frame.byId[0]),'stale XD placement survived HD2D switch')
assert(released==6 and frame.xdActors==nil)
style='voxel';M.prepare(frame);assert(made==8,'native voxel borrowed modern models')
style='modern';enabled=false;M.prepare(frame);assert(released==6)
M.clear();assert(released==6,'cleanup is idempotent')
uninstall();assert(anim.launchMove==native)
print('XD GBA actor lifecycle passed')
