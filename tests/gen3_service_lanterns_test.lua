local L=dofile('lib/Gen3ServiceLanterns.lua');local B=dofile('lib/BuildingLights.lua')
for _,kind in ipairs{'center','mart'}do
 local g={cx=10,cy=20,depth=4,kind=kind,custom={[kind=='center' and 'centerRoof' or 'martRoof']=true}}
 local p={w=64,h=64,wall=23};local vertices={};local glass,solid=0,0
 assert(L.append(g,p,function(v,uv,shade)
  for i,q in ipairs(v)do
   local xx,yy,zz=q[1]-160,q[2],q[3]-320
   assert(xx>=9.799 and xx<=38.201 and yy>=8.599 and yy<=16.701 and zz>=59.8 and zz<=62.111,'blocked facade fixture bounds '..xx..','..yy..','..zz)
   assert(xx<16 or xx>32,'doorframe overwritten');assert(xx<40,'service sign overwritten')
   vertices[#vertices+1]={q[1],q[2],q[3],uv[i][1],uv[i][2],shade}
  end
  if shade>=64 then glass=glass+1;assert(uv[1][1]==131.5/132,'glass must use pale palette swatch')else solid=solid+1;assert(uv[1][1]==130.5/132,'frame must use dark palette swatch')end
 end)==2)
 assert(glass==12 and solid>60)
 local lights=B.collect(vertices,nil,132,64);assert(#lights==2,'a lamp must have one emitter, not one per pane')
 local forward=0;for _,light in ipairs(lights)do if light[6]>.9 then forward=forward+1 end end
 assert(forward==2,'both lanterns need outward warm-light emitters')
end
assert(L.append({cx=0,cy=0,depth=4,kind='house',custom={centerRoof=true}},{w=64,h=64,wall=23},function()error('unreviewed house lamp')end)==0)
assert(L.append({cx=0,cy=0,depth=4,kind='center'},{w=64,h=64,wall=23},function()error('unreviewed Kanto lamp')end)==0)
print('PASS closed service lanterns, explicit pane emission, collected emitters and clear native door/sign/footprint')
