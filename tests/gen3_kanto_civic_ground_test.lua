local C=assert(loadfile('lib/Gen3Civic.lua'))()
local specs={
 {'FR_CERULEAN_CITY',28,17,'general__rom_082d4af4','gym',1,{{313,314,314,314,314,314,315},{321,322,322,322,322,322,323},{329,330,330,330,330,330,331},{336,337,338,339,340,341,342},{344,345,346,347,348,349,350}}},
 {'FR_SAFFRON_CITY',37,8,'general__rom_082d4b9c','gym',741,{{816,817,799,817,799,818},{824,825,825,825,825,826},{832,833,833,833,833,834},{821,822,823,811,812,827},{829,830,831,819,820,835}}},
 {'FR_SAFFRON_CITY',22,34,'general__rom_082d4b9c','center',741,{{764,765,766,774,767},{72,73,74,75,391},{80,81,82,83,399},{88,89,90,91,407},{735,97,98,390,775}}},
 {'FR_SAFFRON_CITY',38,18,'general__rom_082d4b9c','mart',741,{{760,761,762,763},{48,49,50,51},{56,57,58,59},{758,65,98,759}}},
}
local count=0
local function fixture(s,projection)
 local rows=s[7];local region={x=10,y=20,def={id=projection and'FR_SAFFRON_CITY_CONNECTION'or s[1]}};local cx=s[2]+10-(projection and 10 or 0);local cy=s[3]+20-(projection and 7 or 0);local cells={}
 for y,row in ipairs(rows)do for x,mid in ipairs(row)do cells[(cx+x-1)..':'..(cy+y-1)]={cx=cx+x-1,cy=cy+y-1,primary='general',pair=s[4],mid=mid,collision=y==1 and 0 or 7,base=16,shape={kind='flat'},region=region,ts={layered=true}}end end
 -- Nearby genuine but unrelated road/grass must not determine this floor.
 for y=cy-2,cy+#rows+1 do for x=cx-2,cx+#rows[1]+1 do local k=x..':'..y
  if not cells[k]then cells[k]={cx=x,cy=y,primary='general',pair=s[4],mid=s[6]==1 and 212 or 1,collision=0,base=16,shape={kind='flat',reviewedSurface=true}}end
 end end
 return cells,cx,cy,region
end
local function prepare(s,cells,cx,cy)
 return C.prepare(cells,s[5]=='gym'and{{cx=cx,cy=cy+1,width=#s[7][1],pair=s[4]}}or{}, {})
end
for _,s in ipairs(specs)do for _,projection in ipairs(s[1]=='FR_SAFFRON_CITY'and{false,true}or{false})do
 local cells,cx,cy,region=fixture(s,projection);local before={};for k,c in pairs(cells)do before[k]={c.mid,c.collision,c.base,c.shape}end
 local out=prepare(s,cells,cx,cy);assert(#out==1,'exact native service drawing not claimed');local g=out[1];assert(g.sourceGround==s[6])
 for k,c in pairs(cells)do
  if c.civic then assert(C.ground(c)==s[6],'native art-ground proof lost to proximity');assert(not C.underOnly(c),'whole source roof accidentally reused')end
  assert(c.mid==before[k][1]and c.collision==before[k][2]and c.base==before[k][3]and c.shape==before[k][4],'native data changed')
 end
 count=count+1
 for _,mutation in ipairs{'pair','art','boundary','stageHidden'}do
  cells,cx,cy,region=fixture(s,projection);local checkSpec=s
  if mutation=='pair'then for _,c in pairs(cells)do c.pair='THIRD_PARTY_PAIR'end;local copy={unpack(s)};copy[4]='THIRD_PARTY_PAIR';checkSpec=copy elseif mutation=='art'then cells[(cx+1)..':'..(cy+2)].mid=999 else cells[(cx+1)..':'..(cy+2)][mutation]=true end
  out=prepare(checkSpec,cells,cx,cy);for _,v in ipairs(out)do assert(not v.sourceGround,'unknown source evidence was accepted '..mutation)end
 end
end end
assert(count==7)
print('PASS7 exact Kanto civic native floors, stitched-region offsets, neighbor-donor refusal, unchanged native cells and unknown-art/pair/owner fallback')
