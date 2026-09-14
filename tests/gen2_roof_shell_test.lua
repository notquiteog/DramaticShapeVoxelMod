local R=assert(loadfile('lib/Gen2RoofShell.lua'))()
local runs={}
local function key(x,z)return x..','..z end
local function at(x,z)return runs[key(x,z)] end
local function h(x,z)return at(x,z) and at(x,z).h or 0 end
local run={h=24,rise=24,extent=8,front=7}
for x=0,5 do for z=0,7 do runs[key(x,z)]=run end end
local count=0
for x=0,5 do for z=0,7 do
  local c=R.corners(run,x,z,h)
  R.append(run,x,z,c,at,h,function(p,uv)
    count=count+1
    assert(x==0 or x==5,'shared roof interior should not emit walls')
    for _,v in ipairs(p) do assert(v[2]>=24 and v[2]<=48) end
    assert(p[1][2]==24 and p[2][2]==24,'gable must meet the facade')
    -- Every emitted top endpoint coincides with the roof at that position.
    local heights={[key(x*8,(z+1)*8)]=c[1],[key((x+1)*8,(z+1)*8)]=c[2],
      [key((x+1)*8,z*8)]=c[3],[key(x*8,z*8)]=c[4]}
    for i=3,4 do assert(p[i][2]==heights[key(p[i][1],p[i][3])]) end
  end,function()return 0,1,0,1 end,27)
end end
assert(count>0,'roof flanks remain open')
-- A lower adjoining building hides only the portion it actually covers.
runs[key(1,3)]={h=24,rise=8,extent=8,front=7}
local seam=0
R.append(run,0,3,R.corners(run,0,3,h),at,h,function(p)
  if p[1][1]==8 and p[2][1]==8 then
    seam=seam+1
    assert(p[1][2]==32 and p[2][2]==30,'adjoining roof edge mismatch')
  end
end,function()return 0,1,0,1 end,27)
assert(seam==1,'different roof heights leave an open step')
print('roof shell meets facade and slope; shared faces culled; stepped roof sealed')
