-- Exact complete native Mt. Pyre grave drawings; wall-shadow variants remain
-- separate. The original neighboring 0x2e6 floor is the native underlay.
local recipes={}
for _,edition in ipairs{'emerald','rs'}do
 local prefix=edition=='emerald'and'hoenn_pyre_memorial'or'rs_pyre_memorial'
 recipes[#recipes+1]={name=prefix,
  edition=edition=='rs'and'rs'or nil,family='rse',primary='general',pair='general__facility',
  rows={{0x2ee}},blockedRows={[1]=true},
  kind='designed',design='fr_tower_grave',ground=0x2e6,groundInset=.025}
 recipes[#recipes+1]={name=prefix..'_wall_shadow',
  edition=edition=='rs'and'rs'or nil,family='rse',primary='general',pair='general__facility',
  rows={{0x326}},blockedRows={[1]=true},kind='designed',design='fr_tower_grave',ground=0x2e7,groundInset=.025}
end
return recipes
