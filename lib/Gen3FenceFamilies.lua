-- Explicit R/S/E source-art matches. A failed model upload leaves complete
-- native art; only a successful adapter owns the clean original lower layer.
local M={}
-- Length, centerX, centerZ, quarter-turn. All bases remain inside the original
-- blocked tile. Thin native edge drawings describe actual railing in depth.
M.ornate={
 [0x2be]={{16,8,14,0}},[0x2bf]={{16,8,14,0}},
 [0x2cd]={{16,8,14,0}},[0x2d5]={{16,8,14,0}},
 [0x2fc]={{16,8,14,0}},[0x2e9]={{12,6,14,0},{14,2,7,1}},
 [0x2ec]={{16,2,8,1}},[0x315]={{16,14,8,1}},
 [0x318]={{16,2,8,1}},[0x319]={{16,14,8,1}},
 [0x31a]={{16,14,8,1},{6,11,14,0}},
 [0x31b]={{8,2,12,1}},[0x31d]={{16,2,8,1}},
 [0x320]={{14,2,7,1},{14,9,14,0}},
 [0x321]={{14,14,7,1},{14,7,14,0}},
 [0x32c]={{14,14,7,1},{14,7,14,0}},
 [0x32d]={{16,2,8,1},{14,9,14,0}},
}
-- Original lower 8px quadrants, proven pixel-identical to these clean native
-- terrain quadrants in each R/S/E cache. Preserve exact mixed paving/grass.
M.ground={
 [0x2be]={{0x2bb,0},{0x2bb,1},{0x2bb,2},{0x2bb,3}},
 [0x2bf]={{0x2bb,0},{0x2bb,1},{0x2bb,2},{0x2bb,3}},
 [0x2cd]={{0x2bb,0},{0x2bb,1},{0x2bb,2},{0x2bb,3}},
 [0x2d5]={{0x2bb,0},{0x2bb,1},{0x2bb,2},{0x2bb,3}},
 [0x2e9]={{0x2bb,0},{0x2bb,1},{0x2bb,2},{0x2bb,1}},
 [0x2ec]={{0x2c3,0},{0x2bc,3},{0x2bd,2},{0x2bc,3}},
 [0x2fc]={{0x2bb,1},{0x2bb,2},{0x2f1,2},{0x2f0,3}},
 [0x315]={{0x2bb,1},{0x2e2,1},{0x2bb,1},{0x2e2,3}},
 [0x318]={{0x2e0,0},{0x2bb,2},{0x2e0,2},{0x2bb,0}},
 [0x319]={{0x2bb,1},{0x2e2,1},{0x2bb,1},{0x2e2,3}},
 [0x31a]={{0x2bb,1},{0x2e2,1},{0x2bb,1},{0x2e2,3}},
 [0x31b]={{1,0},{1,1},{1,1},{1,0}},
 [0x31d]={{0x2e0,0},{0x2bb,2},{0x2e0,2},{0x2bb,0}},
 [0x320]={{0x2e0,0},{0x2bb,2},{0x2e0,2},{0x2f0,3}},
 [0x321]={{0x2bb,1},{0x2e2,1},{0x2f1,2},{0x2e2,3}},
 [0x32c]={{0x2bb,1},{0x2e2,1},{0x2f1,2},{0x2e2,3}},
 [0x32d]={{0x2e0,0},{0x2bb,2},{0x2e0,2},{0x2bb,0}},
}
function M.shape(primary,secondary,mid,behavior,collision)
 if primary~='general'or collision~=7 then return end
 if mid==0x149 then return{kind='flat',reviewedSurface=true,nativeFence='rural149',ground=1}end
 if secondary=='rustboro'and M.ornate[mid]then
  return{kind='flat',reviewedSurface=true,nativeFence='rustboro',ground=mid}
 end
end
return M
