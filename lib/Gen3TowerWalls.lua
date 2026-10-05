-- Native purple paneling with a white cornice. Outline tiles are cap/return
-- geometry, never white upright pillars. Gameplay collision remains untouched.
local M={}
function M.append(cells,c,emit,uvFor)
 local col=c.column
 local x,front=c.cx*16,col.front
 local back=front-4
 -- A stepped outline needs returns connecting the adjacent wall planes.
 -- Bound the search to its two-row native perimeter, never bridge a room.
 for _,dx in ipairs{-1,1}do
  for y=col.last-2,col.last+2 do
   local n=cells[(c.cx+dx)..':'..y]
   local q=n and n.column
   if q and n.pair==c.pair and n.shape.wallStyle=='tower' and q.front<=front and front-q.front<=32 then
    back=math.min(back,q.front-4)
   end
  end
 end
 local panel=assert(uvFor(c.ts,0x2a0))
 local cap=assert(uvFor(c.ts,0x298))
 local u=(cap[1][1]+cap[2][1])*.5
 local v=cap[1][2]+(cap[3][2]-cap[1][2])*.04
 local white={{u,v},{u,v},{u,v},{u,v}}
 local function face(q,t,shade)emit(q,t,shade or 1)end
 -- Full panel faces on both sides and returns, capped without open corners.
 face({{x,24,front},{x+16,24,front},{x+16,0,front},{x,0,front}},panel)
 face({{x+16,24,back},{x,24,back},{x,0,back},{x+16,0,back}},panel,.75)
 face({{x,24,back},{x,24,front},{x,0,front},{x,0,back}},panel,.8)
 face({{x+16,24,front},{x+16,24,back},{x+16,0,back},{x+16,0,front}},panel,.8)
 face({{x,26,back},{x+16,26,back},{x+16,26,front},{x,26,front}},white)
 face({{x,26,front},{x+16,26,front},{x+16,24,front},{x,24,front}},white)
 face({{x+16,26,back},{x,26,back},{x,24,back},{x+16,24,back}},white,.75)
 face({{x,26,back},{x,26,front},{x,24,front},{x,24,back}},white,.8)
 face({{x+16,26,front},{x+16,26,back},{x+16,24,back},{x+16,24,front}},white,.8)
end
return M
