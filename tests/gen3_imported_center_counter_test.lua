local C=dofile('lib/Gen3ImportedCenterCounter.lua')
for _,rse in ipairs{true,false}do
 local cells={};local pair=rse and'building__pokemon_center'or'network';local width=rse and 6 or 7
 local function owner(name,kind,rows,collision,x,y)
  local p={cx=x,cy=y,w=#rows[1]*16,d=#rows*16,pair=pair,groundHeight=8,
   recipe={name=name,kind=kind,family=rse and'rse'or nil,rows=rows}}
  for row,q in ipairs(rows)do for col,mid in ipairs(q)do cells[(x+col-1)..':'..(y+row-1)]={
   mid=mid,collision=collision[row][col],pair=pair,primary='building',base=8,prop=p}end end
  return p
 end
 local front=owner(rse and'hoenn_center_front_desk'or'center_front_desk','centerCounter',
  rse and{{0x258,0x221,0x221,0x205,0x221,0x259}}or{{0x2b9,0x2bc,0x2bc,0x298,0x2bc,0x2bc,0x2bd}},
  rse and{{7,7,7,144,7,7}}or{{7,144,144,144,144,144,7}},4,3)
 local left=owner(rse and'hoenn_center_left'or'center_counter_left','centerWing',
  rse and{{0x248},{0x250}}or{{0x2a9},{0x2b1}},rse and{{7},{7}}or{{7},{144}},4,1)
 local right=owner(rse and'hoenn_center_right'or'center_counter_right','centerWing',
  rse and{{0x249},{0x251}}or{{0x2ad},{0x2b5}},rse and{{7},{7}}or{{7},{144}},4+width-1,1)
 assert(C.isFront(front)and not C.isFront(left)and C.eligible(front,cells))
 local p=C.placement(front,cells);assert(p.source==front and p.sources[2]==left and p.sources[3]==right)
 assert(p.x==64 and p.y==8 and p.z==16 and p.fit.width==width*16 and p.fit.depth==48 and p.fit.groundInset==.025)
 for _,prop in ipairs{front,left,right}do
  for _,k in ipairs{'cx','cy','w','d','pair','groundHeight','stageHidden'}do
   local old=prop[k];prop[k]=k=='stageHidden'and true or k=='pair'and'foreign'or -5
   assert(not C.eligible(front,cells),'partial counter accepted changed '..k);prop[k]=old
  end
  for _,k in ipairs{'name','kind','family','design'}do local old=prop.recipe[k];prop.recipe[k]='foreign'
   assert(not C.eligible(front,cells),'foreign recipe accepted '..k);prop.recipe[k]=old end
 end
 for key,cell in pairs(cells)do
  for _,k in ipairs{'mid','collision','pair','primary','base','prop','boundary','stageHidden','stairs','civic'}do
   local old=cell[k];cell[k]=k=='base'and 10 or k=='mid'and 0 or true
   assert(not C.eligible(front,cells),'partial cell accepted '..k);cell[k]=old
  end
  cells[key]=nil;assert(not C.eligible(front,cells),'missing native owner cell accepted');cells[key]=cell
 end
 -- Counter upload/marking is atomic across its three owners, with no Scene
 -- dependency or gameplay mutation. Incomplete source leaves every native part.
 local loaded,available={},false
 local models={info=function(id)return loaded[id]end,register=function(id)loaded[id]=true;return true end,
  buildBatches=function(items,mesh,opt)assert(#items==1 and #items[1].sources==3);if not available then return nil,'missing texture'end;return opt.parts end}
 local V={mod={read=function()end}}
 V.require=function(name)
  if name=='SceneryModels'then return models elseif name=='Gen3ImportedCenterCounter'then return C
  elseif name=='Gen3PublicPCFrames'then return dofile('lib/Gen3PublicPCFrames.lua')
  elseif name=='ImportedCenterCounterData'then return dofile('lib/ImportedCenterCounterData.lua')end
  error(name)
 end
 local I=assert(loadfile('lib/Gen3ImportedInteriors.lua'))(V)
 assert(#I.placements(cells)==1)
 local original={};local parts,err,n=I.build(cells,function()error('unaccepted counter uploaded')end,original)
 assert(parts==original and not err and n==0,'unaware renderer hides native counter')
 parts,err,n=I.build(cells,function()end,{},{receptionCounter=true});assert(not parts and err and n==0)
 for _,q in ipairs{front,left,right}do assert(not q.importedInterior)end
 available=true;parts,err,n=I.build(cells,function()end,{},{receptionCounter=true});assert(parts and not err and n==1)
 for _,q in ipairs{front,left,right}do assert(q.importedInterior==C.id)end
 -- Independent League wing arrangements do not match a complete front owner.
 local old=left.cy;left.cy=0;assert(#I.placements(cells)==0);left.cy=old
end
print('PASS both native three-owner counter identities, all geometry/collision guards, shared fit and atomic source fallback')
