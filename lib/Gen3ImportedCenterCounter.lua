-- One original U-counter replaces one complete native three-owner drawing.
-- Separate wings are never fitted independently or hidden by partial matches.
local M={id='oras_center_reception_counter'}
local specs={
 hoenn_center_front_desk={pair='building__pokemon_center',family='rse',
  rows={{0x258,0x221,0x221,0x205,0x221,0x259}},collision={{7,7,7,144,7,7}},
  left={name='hoenn_center_left',rows={{0x248},{0x250}},collision={{7},{7}}},
  right={name='hoenn_center_right',rows={{0x249},{0x251}},collision={{7},{7}}}},
 center_front_desk={pair='network',
  rows={{0x2b9,0x2bc,0x2bc,0x298,0x2bc,0x2bc,0x2bd}},collision={{7,144,144,144,144,144,7}},
  left={name='center_counter_left',rows={{0x2a9},{0x2b1}},collision={{7},{144}}},
  right={name='center_counter_right',rows={{0x2ad},{0x2b5}},collision={{7},{144}}}},
}
function M.isFront(p)return not not(type(p)=='table'and type(p.recipe)=='table'and specs[p.recipe.name])end
local function matches(p,cells,spec,name,rows,collisions,kind,x,y,base)
 local r=type(p)=='table'and p.recipe
 if type(r)~='table'or r.name~=name or r.kind~=kind or r.family~=spec.family or r.design~=nil
  or type(r.rows)~='table'or #r.rows~=#rows
  or p.cx~=x or p.cy~=y or p.w~=#rows[1]*16 or p.d~=#rows*16
  or p.pair~=spec.pair or p.stageHidden or math.abs((p.groundHeight or 0)-base)>.001 then return false end
 for row,expected in ipairs(rows)do
  if not r.rows[row]or #r.rows[row]~=#expected then return false end
  for col,mid in ipairs(expected)do
   local c=cells[(x+col-1)..':'..(y+row-1)]
   if r.rows[row][col]~=mid or not c or c.prop~=p or c.mid~=mid or c.collision~=collisions[row][col]
    or c.primary~='building' or c.pair~=spec.pair or c.boundary or c.stageHidden or c.stairs or c.civic
    or math.abs((c.base or 0)-base)>.001 then return false end
  end
 end
 return true
end
function M.placement(p,cells)
 local spec=M.isFront(p)and specs[p.recipe.name];if not spec then return end
 local base=p.groundHeight or 0;local width=#spec.rows[1];local left,right
 local a,b=cells[p.cx..':'..(p.cy-2)],cells[(p.cx+width-1)..':'..(p.cy-2)]
 if a then left=a.prop end;if b then right=b.prop end
 if not matches(p,cells,spec,p.recipe.name,spec.rows,spec.collision,'centerCounter',p.cx,p.cy,base)
  or not matches(left,cells,spec,spec.left.name,spec.left.rows,spec.left.collision,'centerWing',p.cx,p.cy-2,base)
  or not matches(right,cells,spec,spec.right.name,spec.right.rows,spec.right.collision,'centerWing',p.cx+width-1,p.cy-2,base)
  or left==right or left==p or right==p then return end
 return{model=M.id,source=p,sources={p,left,right},x=p.cx*16,y=base,z=(p.cy-2)*16,
  fit={width=width*16,depth=48,height=32,padding=.25,groundInset=.025}}
end
function M.eligible(p,cells)return M.placement(p,cells)~=nil end
return M
