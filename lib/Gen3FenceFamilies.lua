-- Explicit R/S/E source-art matches. A failed model upload leaves complete
-- native art; only a successful adapter owns the clean original lower layer.
local M={}
-- Length, centerX, centerZ, quarter-turn. All bases remain inside the original
-- blocked tile. Thin native edge drawings describe actual railing in depth.
M.ornate={
 [0x2b7]={{16,14,8,1},{14,7,14,0}},
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
 [0x2b7]={{1,0},{1,1},{1,2},{1,3}},
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
-- Southern border variants add a tiny native leaf overlay to the same rail.
-- These runs are exactly the nontransparent pixels of original tiles CC/CD;
-- retain their source UVs separately from the painted flat fence/shadow.
M.plants={
 [0x337]={{12,12,3},{11,13,5},{9,14,7},{8,15,8}},
 [0x33e]={{12,12,3},{11,13,5},{9,14,7},{8,15,8}},
 [0x33f]={{1,12,3},{0,13,5},{0,14,7},{0,15,8}},
}
M.plantsRS={
 [0x337]={{15,11,1},{14,12,2},{13,13,3},{11,14,5},{10,15,6}},
 [0x33e]={{15,11,1},{14,12,2},{13,13,3},{11,14,5},{10,15,6}},
 [0x33f]={{0,11,1},{0,12,2},{0,13,3},{0,14,5},{0,15,6}},
}
function M.plantRows(c)
 local id=c.region and c.region.def and c.region.def.id or ''
 return (id:match('^RU_')or id:match('^SA_'))and M.plantsRS[c.mid]or M.plants[c.mid]
end
for mid in pairs(M.plants)do
 M.ornate[mid]=mid==0x337 and{{14,2,7,1},{14,9,14,0}}or{{16,8,14,0}}
 M.ground[mid]={{1,0},{1,1},{1,2},{1,3}}
end
function M.shape(primary,secondary,mid,behavior,collision)
 if primary~='general'or collision~=7 then return end
 if mid==0x149 then return{kind='flat',reviewedSurface=true,nativeFence='rural149',ground=1}end
 if secondary=='rustboro'and M.ornate[mid]then
  return{kind='flat',reviewedSurface=true,nativeFence='rustboro',ground=mid}
 end
end
return M
