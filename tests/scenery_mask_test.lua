local M=dofile('lib/SceneryMask.lua')
local function check(rows)
 local w,h=#rows[1],#rows;local reads={}
 local mask=M.mask(w,function(x,y)
  local k=y*w+x;reads[k]=(reads[k]or 0)+1
  assert(reads[k]==1,'foreground edge sampled repeatedly')
  return rows[y+1]:sub(x+1,x+1)=='.'
 end,h)
 -- Independent reachability: expand all reachable background cells until
 -- stable, rather than relying on the implementation's queue order.
 local reachable={};local changed=true
 while changed do
  changed=false
  for y=0,h-1 do for x=0,w-1 do
   local k=y*w+x
   if rows[y+1]:sub(x+1,x+1)=='.' and not reachable[k] and
    (x==0 or y==0 or x==w-1 or y==h-1 or reachable[k-1] or reachable[k+1] or reachable[k-w] or reachable[k+w])then
    reachable[k]=true;changed=true
   end
  end end
 end
 for y=0,h-1 do for x=0,w-1 do local k=y*w+x;assert(mask[k]==not not (not reachable[k]),'mask changed silhouette')end end
end
check({'.'});check({'#'});check({'.....','.....'})
check({'.....','.###.','.#.#.','.###.','.....'}) -- enclosed pale highlight survives
check({'.#..','.#.#','...#'}) -- rectangular, connected and diagonal cavities
math.randomseed(174)
for i=1,100 do
 local rows={};local w,h=math.random(2,19),math.random(2,19)
 for y=1,h do local row={};for x=1,w do row[x]=math.random(1,3)==1 and '#' or '.' end;rows[y]=table.concat(row)end
 check(rows)
end
print('PASS rectangular source masks, enclosed highlights, edges and 100 reachability comparisons')
