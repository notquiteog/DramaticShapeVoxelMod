-- Shared authored timber posts, metal collars, double rails and uprights.
local M={}
function M.node(box,cap,x,z,east,south)
    -- Slim timber posts with dark feet and beveled caps. Original nodes/openings remain.
    box(x-1.1,0,z-1.1,x+1.1,10.0,z+1.1)
    box(x-1.3,0,z-1.3,x+1.3,1.0,z+1.3,true)
    cap(x,z)
    -- Each east/south link is emitted once; three metal uprights per connected bay.
    if east then
      box(x+1.1,2.8,z-.45,x+14.9,3.6,z+.45)
      box(x+1.1,8.2,z-.55,x+14.9,9.05,z+.55)
      for _,u in ipairs({4.5,8,11.5})do box(x+u-.17,3.6,z-.17,x+u+.17,8.2,z+.17,true)end
      for _,u in ipairs({1.15,14.4})do
        box(x+u,7.95,z-.65,x+u+.45,9.2,z+.65,true)
      end
    end
    if south then
      box(x-.45,2.8,z+1.1,x+.45,3.6,z+14.9)
      box(x-.55,8.2,z+1.1,x+.55,9.05,z+14.9)
      for _,u in ipairs({4.5,8,11.5})do box(x-.17,3.6,z+u-.17,x+.17,8.2,z+u+.17,true)end
      for _,u in ipairs({1.15,14.4})do
        box(x-.65,7.95,z+u,x+.65,9.2,z+u+.45,true)
      end
    end
end
return M
