local Cover=assert(loadfile('lib/Gen2GroundCover.lua'))()
local function uv()return 0,1,0,1 end
local function run(id,tile,h)
  local count=0
  for z=0,120,8 do for x=0,120,8 do
    local before=count
    Cover.append({tileset={id=id}},x,z,h,tile,function(c,t)
      count=count+1
      for i,p in ipairs(c) do
        assert(p[1]>=x and p[1]<=x+8 and p[3]>=z and p[3]<=z+8,'cover crosses tile bounds')
        assert(p[2]>0 and p[2]<=1.95,'cover obscures actors')
        assert(t[i][1]>=0 and t[i][1]<=1 and t[i][2]>=0 and t[i][2]<=1)
      end
    end,uv,1)
    assert(count-before<=5,'excessive clump geometry')
  end end
  return count
end
local n=run('TILESET_JOHTO',5,0)
assert(n>0 and n<256*5*.4,'meadow must remain sparse')
assert(run('TILESET_JOHTO',5,0)==n,'cover changes between rebuilds')
assert(run('TILESET_JOHTO',6,0)==0,'path receives cover')
assert(run('TILESET_JOHTO',5,6)==0,'raised prop receives cover')
assert(run('TILESET_LAB',5,0)==0,'interior receives cover')
assert(run('OVERWORLD',5,0)==0,'Gen 1 receives Crystal cover')
print('meadow bounds, density, deterministic rebuild and exclusions passed')
