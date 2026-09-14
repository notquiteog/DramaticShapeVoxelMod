local Trees=assert(loadfile('lib/Gen2Trees.lua'))()
local Materials=assert(loadfile('lib/Gen2Materials.lua'))({})
local DOF=assert(loadfile('lib/DepthOfField.lua'))({})
local Mat4=assert(loadfile('lib/Mat4.lua'))()
local checks=0
local function check(ok,msg) checks=checks+1;assert(ok,msg) end
local families={}
for seed=0,2 do
  families[Trees.family(seed,10)]=true
  local tv,ti,cv,ci,dv,di={},{},{},{},{},{}
  Trees.append(tv,ti,0,cv,ci,0,0,0,0,10,seed,dv,di,0)
  check(#ti+#ci+#di<2200,'tree exceeds the dense-border geometry budget')
  check(#di>0,'tree must have fine leaf silhouettes, not just a solid hull')
  for _,pair in ipairs({{tv,ti},{cv,ci},{dv,di}}) do
    for _,i in ipairs(pair[2]) do assert(pair[1][i],'invalid triangle index') end
    for _,v in ipairs(pair[1]) do for _,n in ipairs(v) do assert(n==n and math.abs(n)<100) end end
  end
end
check(families.broadleaf and families.conifer and families.spreading,'three distinct tree families')
check(Trees.family(0,4)=='shrub','interactive bushes keep a distinct short model')
for _,kind in ipairs({'grass','path','wood','stone','water','floor'}) do
  for y=0,31 do for x=0,31 do
    local r,g,b=Materials.color(kind,x,y,.5,.5,.5,1)
    assert(r>=0 and r<=1 and g>=0 and g<=1 and b>=0 and b<=1)
  end end
  check(true,'material channels stay in range')
end
local ts={blocks={{96,97,98,100},{99,101,102}}}
check(Materials.woodTile({tileset=ts})==103,'timber never overwrites an authored tile')
local matrix=Mat4.mul(Mat4.perspective(.7,1.5,1,1000),Mat4.translate(2,-5,15))
local inverse=assert(DOF.inverse(matrix))
local product=Mat4.mul(matrix,inverse)
for y=1,4 do for x=1,4 do
  assert(math.abs(product[(y-1)*4+x]-(x==y and 1 or 0))<1e-7,'depth unprojection differs from camera')
end end
check(true,'depth unprojection reverses the actual camera matrix')
check(DOF.inverse({0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0})==nil,'degenerate depth camera fails open')
local canvas={}
check(DOF.apply(canvas)==canvas,'optional depth blur defaults off')
print(checks..' HD scenery/material/focus checks passed')
