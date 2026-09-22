-- Complete FireRed gym exteriors. Secondary trim is recognized only as part
-- of the shared roof/facade drawing, never by an ambiguous secondary ID alone.
local M={}
local function eq(a,b)
 if #a~=#b then return false end
 for i,v in ipairs(a)do if v~=b[i]then return false end end
 return true
end
function M.prepare(cells)
 local out={}
 for _,c in pairs(cells)do if c.primary=='general' and c.mid==0x141 then
  local w=1
  while w<10 do local n=cells[(c.cx+w)..':'..c.cy]
   if not n or n.pair~=c.pair or n.mid~=0x142 then break end;w=w+1
  end
  w=w+1
  if w>=6 and w<=8 then
   local rows,parts={},{};local match=true
   for dy=-1,3 do local row={};rows[dy]=row
    for dx=0,w-1 do local n=cells[(c.cx+dx)..':'..(c.cy+dy)]
     if not n or n.pair~=c.pair or n.prop then match=false else row[#row+1]=n.mid;parts[#parts+1]=n end
    end
   end
   local roof,edge={0x141},{0x149}
   for _=2,w-1 do roof[#roof+1]=0x142;edge[#edge+1]=0x14A end
   roof[w]=0x143;edge[w]=0x14B
   match=match and eq(rows[0],roof) and eq(rows[1],edge)
   local upper={0x150,0x151,0x152,0x153,0x154}
   local lower={0x158,0x159,0x15A,0x15B,0x15C}
   for _=6,w-1 do upper[#upper+1]=0x155;lower[#lower+1]=0x15D end
   upper[w]=0x156;lower[w]=0x15E
   local trim=rows[-1];local variant
   if trim[1]==0x139 and trim[w]==0x13B then
    variant='standard';for i=2,w-1 do if trim[i]~=0x13A then variant=nil end end
   elseif w==6 and eq(trim,{0x2AD,0x2AE,0x2AE,0x2AE,0x2AE,0x2AF})then variant='viridian'
   elseif w==6 and eq(trim,{0x281,0x282,0x283,0x283,0x283,0x284})then variant='cinnabar';lower[w]=0x2BF
   elseif w==7 and eq(trim,{0x285,0x286,0x286,0x286,0x286,0x286,0x287})then variant='fuchsia'
   elseif w==7 and eq(trim,{0x300,0x301,0x302,0x301,0x302,0x301,0x303})then
    variant='saffron';upper[1]=0x305;lower={0x310,0x311,0x312,0x15B,0x313,0x314,0x315}
   end
   if match and variant and eq(rows[2],upper) and eq(rows[3],lower) then
    local g={cx=c.cx,cy=c.cy,width=w,pair=c.pair,variant=variant,ts=c.ts}
    out[#out+1]=g
    if variant=='saffron' then
     for dx=-2,w+2 do
      local n=cells[(c.cx+dx)..':'..(c.cy+4)]
      local below=cells[(c.cx+dx)..':'..(c.cy+5)]
      if n and below and n.pair==c.pair and below.pair==c.pair and n.mid==0x304 and below.mid==0x30C then n.gymNotice=true end
     end
    end
    for _,n in ipairs(parts)do
     n.gym=g
     n.shape={kind=n.cy<=c.cy+1 and 'roof' or 'wall',ground=1,roofType='gable'}
    end
   end
  end
 end end
 -- Saffron's neighboring Fighting Dojo has its own complete secondary
 -- drawing. Its IDs are otherwise ambiguous, so require every cell.
 local dojo={{0x330,0x331,0x31F,0x331,0x31F,0x332},
  {0x338,0x339,0x339,0x339,0x339,0x33A},
  {0x340,0x341,0x341,0x341,0x341,0x342},
  {0x335,0x336,0x337,0x32B,0x32C,0x33B},
  {0x33D,0x33E,0x33F,0x333,0x334,0x343}}
 for _,c in pairs(cells)do if c.primary=='general' and c.mid==0x330 then
  local match,parts=true,{}
  for y,row in ipairs(dojo)do for x,mid in ipairs(row)do
   local n=cells[(c.cx+x-1)..':'..(c.cy+y-1)]
   if not n or n.prop or n.gym or n.pair~=c.pair or n.mid~=mid then match=false else parts[#parts+1]=n end
  end end
  if match then
   local g={cx=c.cx,cy=c.cy+1,width=6,pair=c.pair,variant='dojo',ts=c.ts};out[#out+1]=g
   for _,n in ipairs(parts)do n.gym=g;n.shape={kind=n.cy<=g.cy+1 and 'roof' or 'wall',ground=1,roofType='gable'}end
  end
 end end
 return out
end
function M.column(g)
 return {first=g.cy-1,last=g.cy+3,roofs=3,walls=2,front=(g.cy+4)*16,
  back=(g.cy-1)*16,height=32,roofType='gable',roofInset=12,style='gym'}
end
-- Give the unseen sides a plausible continuation of the gym's concrete
-- facade: a plinth, eave trim, masonry courses and high-set windows. This is
-- visual siding on the existing closed shell, not extra collision volume.
function M.appendSiding(g,emit,uvFor)
 if g.variant=='dojo' then return end
 local col=M.column(g)
 local x0,x1=g.cx*16,(g.cx+g.width)*16
 local z0=col.back+(col.front-col.back)*col.roofInset/(col.roofs*16)
 local z1=col.front
 local wall=assert(uvFor(g.ts,0x150) or uvFor(g.ts,0x151))
 local u,v=wall[1][1]+(wall[2][1]-wall[1][1])*.5,wall[1][2]+(wall[3][2]-wall[1][2])*.75
 local solid={{u,v},{u,v},{u,v},{u,v}}
 local source=assert(uvFor(g.ts,0x151))
 local l,r=source[1][1]+(source[2][1]-source[1][1])/16,source[2][1]-(source[2][1]-source[1][1])/16
 local top,bottom=source[1][2],source[1][2]+(source[3][2]-source[1][2])*.48
 local glass={{l,top},{r,top},{r,bottom},{l,bottom}}
 for _,side in ipairs({-1,1})do
  local x=side<0 and x0 or x1
  for _,band in ipairs({{0,2,.6,.66},{8,8.18,.12,.74},{16,16.18,.12,.74},{24,24.18,.12,.74},{30,32,.6,.91}})do
   local low,high,offset,shade=unpack(band);local outer=x+side*offset
   emit({{outer,high,z0},{outer,high,z1},{outer,low,z1},{outer,low,z0}},solid,shade)
   emit({{x,high,z0},{outer,high,z0},{outer,high,z1},{x,high,z1}},solid,.94)
  end
  for z=z0+10,z1-20,24 do
   emit({{x+side*.2,27,z},{x+side*.2,27,z+16},{x+side*.2,17,z+16},{x+side*.2,17,z}},glass,.93)
  end
 end
 for _,band in ipairs({{0,2,.6,.66},{8,8.18,.12,.74},{16,16.18,.12,.74},{24,24.18,.12,.74},{30,32,.6,.91}})do
  local low,high,offset,shade=unpack(band);local outer=z0-offset
  emit({{x1,high,outer},{x0,high,outer},{x0,low,outer},{x1,low,outer}},solid,shade)
  emit({{x0,high,z0},{x0,high,outer},{x1,high,outer},{x1,high,z0}},solid,.94)
 end
 for x=x0+16,x1-30,32 do
  emit({{x+16,27,z0-.2},{x,27,z0-.2},{x,17,z0-.2},{x+16,17,z0-.2}},glass,.9)
 end
end
return M
