local active,unlit=true,false
local target,view=1,{}
local light=true;local flat,amount,day;local tint={.5,.6,.7};local seen={};local throws=false
local R={tint=tint,flatten=function(c,a)flat,amount=c,a end,dayTint=function(c)day=c end,lighting=function(on)light=on end}
R.draw=function(...)
 seen[#seen+1]={args={...},n=select('#',...),light=light,flat=flat,amount=amount,day=day,tint=R.tint}
 if throws then error('native draw failed')end
 return nil,'native',false
end
local V={require=function(n)return({Voxel3D=R,Gen3Capture={target=function()return active and target or nil end,intake=function()return view.dramaticShape3DBallIntake end},UiBackplates={spritesUnlit=function()return unlit end}})[n]end}
local M=assert(loadfile('lib/NativeGen3CaptureTint.lua'))(V)
local intake={active=true,color={1,.12,.19},colorAmount=.75};local st={};view.dramaticShape3DBallIntake=intake
local model,tex,mesh,sun={},{},{},{};local c={id=1,model=model,tex=tex}
local a,b,d=M.draw(st,c,mesh,sun);assert(a==nil and b=='native'and d==false)
local s=seen[#seen];assert(s.args[1]==mesh and s.args[2]==tex and s.args[3]==model and s.args[4]==0 and s.n==5 and s.args[5]==nil)
assert(s.flat==intake.color and s.amount==.75 and not s.light and s.tint[1]==1 and s.day==s.tint)
assert(R.tint==tint and light and flat==nil and day==nil,'capture leaked render state')
for _,id in ipairs({0,2,3,4,5})do c.id=id;M.draw(st,c,mesh,sun);s=seen[#seen];assert(s.args[5]==sun and s.flat==nil and s.tint==tint)end
target=3;c.id=3;M.draw(st,c,mesh,sun);assert(seen[#seen].flat==intake.color,'detached partner intake missing')
c.id=1;M.draw(st,c,mesh,sun);assert(seen[#seen].args[5]==sun,'primary opponent tinted for partner capture')
target=1;c.id=1;active=false;M.draw(st,c,mesh,sun);assert(seen[#seen].args[5]==sun);active=true
intake.active=false;M.draw(st,c,mesh,sun);assert(seen[#seen].args[5]==sun);intake.active=true
unlit=true;light=false;M.draw(st,c,mesh,sun);assert(not light and R.tint==tint)
throws=true;local ok,err=pcall(M.draw,st,c,mesh,sun)
assert(not ok and tostring(err):find('native draw failed')and R.tint==tint and not light and flat==nil and day==nil)
assert(c.model==model and c.tex==tex and view.dramaticShape3DBallIntake==intake and st.dramaticShape3DBallIntake==nil,'native actor/capture state changed')
print('PASS native capture intake tint, actual target, unchanged matrix/texture, fallback, native returns and error-state restoration')
