-- Complete native two-cell Meteor rock spikes remain independent fixtures.
local V=...
local M={id='oras_meteor_stalagmite'}
M.recipes={{name='hoenn_meteor_stalagmite',pair='general__meteor_falls',primary='general',family='rse',
 caveInterior=true,rows={{0x254},{0x25C}},blockedRows={[1]=true,[2]=true},collisionRows={{7},{7}},kind='caveSpike',ground=0x201}}
function M.append(p,emit,sample)
 -- Missing source paint retains a closed native-painted spike, never a
 -- flat card. Registration/CPU geometry do not require texture upload.
 local I=V.require('Gen3ImportedInteriors');assert(I.register(M.id))
 local parts,fit=V.require('SceneryModels').vertices(M.id,{width=16,depth=16,height=32,padding=.25,groundInset=.025})
 assert(parts,fit)
 local x,z=p.cx*16,(p.cy+1)*16
 for _,part in ipairs(parts)do for i=1,#part.indices,3 do
  local q={};local y=0
  for j=0,2 do local v=part.vertices[part.indices[i+j]];q[#q+1]={x+v[1],v[2],z+v[3]};y=y+v[2]end
  q[4]=q[3]
  local sourceY=math.max(0,math.min(31,31-y/3/32*31))
  emit(q,sample(7,sourceY),1)
 end end
end
return M
