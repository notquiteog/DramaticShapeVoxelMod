-- Explicit R/S/E source-art matches. A failed model upload leaves complete
-- native art; only a successful adapter owns the clean original lower layer.
local M={}
-- Native white field-fence vocabulary, independently inspected in all R/S/E
-- outdoor layouts. The joined adapter consumes the reviewed corral graphs
-- below; metadata records original layer placement and post centers.
-- Post centers use pixel edges. Clean base art for138..142 is exactly MID1;
-- their complete fence drawing lives in the native over layer.
M.ruralArt={
 [0x138]={side='left',corner='top',postX=4,over=true},
 [0x139]={side='left',cap='top',postX=4,over=true},
 [0x13a]={side='right',corner='top',postX=12,over=true},
 [0x140]={side='left',postX=4,over=true},
 [0x141]={side='right',cap='top',postX=12,over=true},
 [0x142]={side='right',postX=12,over=true},
 [0x148]={side='left',corner='bottom',postX=4},
 [0x149]={horizontal=true},
 [0x14a]={side='right',corner='bottom',postX=12},
}
-- Reviewed native corral graph: posts retain the exact source cross-section;
-- only straight rails span the original blocked cell between those posts.
M.rural={
 [0x138]={runs={{4,14,16,14},{4,14,4,16}},posts={{4,14,0},{12,14,0}}},
 [0x139]={runs={{4,4,4,16}},posts={{4,4,1},{4,12,1}}},
 [0x13a]={runs={{0,14,12,14},{12,14,12,16}},posts={{4,14,0},{12,14,0}}},
 [0x140]={runs={{4,0,4,16}},posts={{4,4,1},{4,12,1}}},
 [0x141]={runs={{12,4,12,16}},posts={{12,4,1},{12,12,1}}},
 [0x142]={runs={{12,0,12,16}},posts={{12,4,1},{12,12,1}}},
 [0x148]={runs={{4,0,4,14},{4,14,16,14}},posts={{4,4,1},{4,14,0},{12,14,0}}},
 [0x149]={runs={{0,14,16,14}},posts={{4,14,0},{12,14,0}}},
 [0x14a]={runs={{12,0,12,14},{0,14,12,14}},posts={{12,4,1},{4,14,0},{12,14,0}}},
}
-- One reviewed secondary duplicate: exact complete native RGBA match to142,
-- including its clean grass. Region guard prevents same-MID unrelated art.
M.ruralAliases={battle_frontier_outside_east={[0x3d7]=0x142}}
function M.ruralMid(secondary,mid)
 if M.rural[mid]then return mid end
 local aliases=M.ruralAliases[secondary];return aliases and aliases[mid]
end
-- Length, centerX, centerZ, quarter-turn. All bases remain inside the original
-- blocked tile. Thin native edge drawings describe actual railing in depth.
M.ornate={
 [0x2a7]={{16,8,14,0}},[0x352]={{14,7,14,0}},
 -- Full horizontal rails, including the grass variant formerly mistaken for
 -- an L. End posts and actual depth runs are distinct native drawings.
 [0x2b7]={{16,8,14,0}},
 [0x2be]={{14,9,14,0}},[0x2bf]={{14,7,14,0}},
 [0x2cd]={{14,9,14,0}},[0x2d5]={{14,7,14,0}},
 [0x2d7]={{14,7,14,0}},[0x2e6]={{14,9,14,0}},[0x2e7]={{14,7,14,0}},
 [0x2fc]={{16,8,14,0}},[0x2e9]={{12,6,14,0},{14,11.5,7,1}},
 -- Three-pixel native depth stripes: dark/light/dark. Targets are their
 -- pixel-edge centers, not the opposite edge of the paving/grass tile.
 [0x2c6]={{16,3.5,8,1}},[0x2c7]={{16,12.5,8,1}},
 [0x2dc]={{16,12.5,8,1}},[0x2de]={{16,3.5,8,1}},[0x2df]={{16,12.5,8,1}},
 [0x2ec]={{16,12.5,8,1}},[0x315]={{16,3.5,8,1}},
 [0x318]={{16,11.5,8,1}},[0x319]={{16,4.5,8,1}},
 [0x31a]={{16,4.5,8,1},{6,3,14,0}},
 [0x31b]={{16,11.5,8,1},{6,13,14,0}},[0x31d]={{16,12.5,8,1}},
 [0x320]={{14,11.5,7,1},{6,13,14,0}},
 [0x321]={{14,4.5,7,1},{6,3,14,0}},
 [0x32c]={{14,3.5,7,1},{6,3,14,0}},
 [0x32d]={{16,11.5,8,1},{6,13,14,0}},
}
-- Clean original terrain quadrant donors preserve mixed paving/grass.
-- The current pixel audit proves all visible non-rail terrain; it does not
-- infer hidden pixels from a baked fence. Older split-layer proof is historical.
M.ground={
 [0x2a7]={{0x2bb,0},{0x2bb,1},{0x2bb,2},{0x2bb,3}},
 [0x352]={{0x2e0,0},{0x2e0,1},{0x2e0,2},{0x2bb,0}},
 [0x2c6]={{0x2bb,0},{0x2bb,1},{0x2bb,2},{0x2bb,3}},
 [0x2c7]={{0x2bb,0},{0x2bb,1},{0x2bb,2},{0x2bb,3}},
 [0x2dc]={{0x2bd,0},{0x2bb,1},{0x2bd,2},{0x2bd,3}},
 [0x2d7]={{1,0},{1,1},{1,2},{1,3}},
 [0x2de]={{1,0},{1,1},{1,2},{1,3}},[0x2df]={{1,0},{1,1},{1,2},{1,3}},
 [0x2e6]={{1,0},{1,1},{1,2},{1,3}},[0x2e7]={{1,0},{1,1},{1,2},{1,3}},
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
 M.ornate[mid]=mid==0x337 and{{14,11.5,7,1},{14,9,14,0}}or{{16,8,14,0}}
 M.ground[mid]={{1,0},{1,1},{1,2},{1,3}}
end
function M.shape(primary,secondary,mid,behavior,collision)
 if primary~='general'or collision~=7 then return end
 if M.ruralMid(secondary,mid)then return{kind='flat',reviewedSurface=true,nativeFence='rural149',ground=1}end
 if secondary=='rustboro'and M.ornate[mid]then
  return{kind='flat',reviewedSurface=true,nativeFence='rustboro',ground=mid}
 end
end
return M
