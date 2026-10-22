-- Conservative native ground continuity below reviewed outdoor props.
-- No nearest-tile vote: opposite strips must agree, including the phase of
-- alternating native metatiles. Never changes source cells, collision or edges.
local M={}
local function region(c)
 local r=c.region
 return r and(r.mapId or r.def and r.def.id)
end
local function floor(c,n)
 if not(n and n.pair==c.pair and n.collision==0 and n.shape and n.shape.kind=='flat'
  and not(n.boundary or n.stageHidden or n.prop or n.civic or n.stairs or n.gym or n.column)
  and (n.behavior==nil or n.behavior==0))then return end
 if math.abs((n.base or 0)-(c.base or 0))>.01 then return end
 local a,b=region(c),region(n)
 if a and b and a~=b then return end
 return n.mid
end
local function axis(cells,c,dx,dy)
 local function at(step)return floor(c,cells[(c.cx+dx*step)..':'..(c.cy+dy*step)])end
 local a,b=at(-1),at(1)
 if not(a and a==b)then return end
 local aa,bb=at(-2),at(2)
 -- One additional identical native cell proves period-one continuation.
 -- Merely seeing equal opposite cells is insufficient: in a checkerboard
 -- those two cells are the OTHER phase, not the hidden target metatile.
 if aa==a or bb==a then return a,'uniform'end
 -- A-B-A on both sides proves a period-two phase without stretching one
 -- swatch over an authored 32px/2x2 pattern or copying a mismatched edge.
 if aa and aa==bb and at(-3)==a and at(3)==a then return aa,'alternating'end
end
function M.infer(cells,c)
 if type(cells)~='table'or not(c and c.shape and c.pair)then return end
 local horizontal,hkind=axis(cells,c,1,0)
 local vertical,vkind=axis(cells,c,0,1)
 if horizontal and vertical and horizontal~=vertical then return nil,'conflicting native strips'end
 local mid=horizontal or vertical
 if not mid then return nil,'no proven native continuation'end
 if c.ts and c.ts.midToSlot and c.ts.midToSlot[mid]==nil then return nil,'native donor absent'end
 return mid,horizontal and('horizontal '..hkind)or('vertical '..vkind)
end
function M.resolve(cells,c)
 -- R/S/E General MID3 is the complete board drawing, with no recoverable
 -- clean BG ground layer. Its former unconditional grass donor is wrong on
 -- Rustboro paving. Other art families retain their own reviewed recipes.
 if not(c and c.primary=='general'and c.mid==3 and c.collision==7 and c.shape
  and c.shape.kind=='sign'and c.shape.hoenn and not(c.boundary or c.stageHidden or c.prop or c.civic))then
  return nil,'unreviewed prop family'
 end
 return M.infer(cells,c)
end
function M.ground(cells,c)
 local mid,reason=M.resolve(cells,c)
 return mid or c and c.shape and c.shape.ground,reason
end
return M
