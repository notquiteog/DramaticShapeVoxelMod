-- A render-only turf fringe inside authored dirt tiles. Never changes the
-- source map, collision, water edge, or the usable width of a path.
local M={}
function M.append(map,x,z,h,tile,emit,uvRect,shade)
  local id=map.tileset.id
  if h~=0 or tile~=6 or (id~="TILESET_JOHTO" and id~="TILESET_JOHTO_MODERN"
      and id~="TILESET_BATTLE_TOWER_OUTSIDE") then return end
  local tx,ty=x/8,z/8
  local u0,u1,v0,v1=uvRect(5,0,8)
  local function depth(a,b)
    local n=math.sin(a*12.9898+b*78.233)*43758.5453
    return .35+(n-math.floor(n))*1.15
  end
  for _,d in ipairs({{0,-1},{1,0},{0,1},{-1,0}}) do
    if map:tileAt(tx+d[1],ty+d[2])==5 then
      for i=0,7 do
        local a,b=i,i+1
        local c
        if d[2]==-1 then
          c={{a,0},{b,0},{b,depth(x+b,z)},{a,depth(x+a,z)}}
        elseif d[2]==1 then
          c={{a,8-depth(x+a,z+8)},{b,8-depth(x+b,z+8)},{b,8},{a,8}}
        elseif d[1]==-1 then
          c={{0,a},{depth(x,z+a),a},{depth(x,z+b),b},{0,b}}
        else
          c={{8-depth(x+8,z+a),a},{8,a},{8,b},{8-depth(x+8,z+b),b}}
        end
        local xyz,uv={},{}
        for j,p in ipairs(c) do
          xyz[j]={x+p[1],.035,z+p[2]}
          uv[j]={u0+(u1-u0)*p[1]/8,v0+(v1-v0)*p[2]/8}
        end
        emit(xyz,uv,shade)
      end
    end
  end
end
return M
