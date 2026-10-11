local drawn=0
love={graphics={setColor=function()end,setLineWidth=function()end,circle=function()drawn=drawn+1 end,line=function()drawn=drawn+1 end}}
for _,p in ipairs({'lib/BattleTheme.lua'})do
 local T=assert(loadfile(p))({});drawn=0
 for _,g in ipairs({'M','F','male','female','♂','♀'})do local before=drawn;T.gender(g,0,0);assert(drawn>before)end
 local before=drawn;T.gender('U',0,0);T.gender(nil,0,0);assert(drawn==before,'genderless gained a symbol')
 T.caught(0,0);assert(drawn>before,'caught marker missing')
end
print('PASS gender and caught icons in standalone and shared themes, genderless omission')
