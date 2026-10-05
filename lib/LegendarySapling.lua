-- Shared authored Gen1 cut-sapling geometry. The caller owns materials and
-- native Cut visibility/collision; this generator changes neither.
local V=...
local Voxel3D=V.require('Voxel3D')
local M={}
function M.gen2(map,cx,cy)
 if not(map and type(map.cellCollision)=='function')then return false end
 if not V.require('CommunityVisuals').customCutTrees()or not V.require('TreePresentation').voxel()then return false end
 local ok,P=pcall(require,'src.world.gen2.Permissions')
 return ok and P.isCutTree(map:cellCollision(cx,cy))or false
end
function M.append(tV,tI,tQ,cV,cI,cQ,mx,mz,base,cx,cy,hash01)
        -- TEST47 CITY-SUPPORTED SAPLING:
        -- The cuttable prop is deliberately NOT the smallest mature tree any
        -- more. It is a newly planted municipal sapling: pencil-thin leader,
        -- sparse young crown, two timber stakes and dark flexible support ties.
        -- All geometry stays inside the original 16x16 cell and is visual-only;
        -- the map's original block continues to own Cut, collision, replacement
        -- grass and regrowth.
        local function tube(x0,y0,z0,r0,x1,y1,z1,r1,sides,shade,uScale)
          sides = sides or 6
          shade = shade or 1
          local vx,vy,vz=x1-x0,y1-y0,z1-z0
          local vl=math.sqrt(vx*vx+vy*vy+vz*vz)
          if vl < 0.001 then return end
          vx,vy,vz=vx/vl,vy/vl,vz/vl
          local ux,uy,uz=-vz,0,vx
          local ul=math.sqrt(ux*ux+uz*uz)
          if ul < 0.001 then ux,uy,uz=1,0,0 else ux,uz=ux/ul,uz/ul end
          local wx=vy*uz-vz*uy
          local wy=vz*ux-vx*uz
          local wz=vx*uy-vy*ux
          local a,b={},{}
          for i=0,sides-1 do
            local q=i*2*math.pi/sides
            local cq,sq=math.cos(q),math.sin(q)
            local rx,ry,rz=ux*cq+wx*sq,uy*cq+wy*sq,uz*cq+wz*sq
            a[i+1]={x0+rx*r0,y0+ry*r0,z0+rz*r0}
            b[i+1]={x1+rx*r1,y1+ry*r1,z1+rz*r1}
          end
          local v1=math.max(0.16,vl*(uScale or 0.18))
          for i=0,sides-1 do
            local ni=(i+1)%sides
            local a0,a1=a[i+1],a[ni+1]
            local b0,b1=b[i+1],b[ni+1]
            local sideLight=shade*(0.82+0.18*math.max(
              0,math.cos(i*2*math.pi/sides-0.65)))
            tV[#tV+1]={b1[1],b1[2],b1[3],1,v1,sideLight}
            tV[#tV+1]={b0[1],b0[2],b0[3],0,v1,sideLight}
            tV[#tV+1]={a0[1],a0[2],a0[3],0,0,sideLight*0.96}
            tV[#tV+1]={a1[1],a1[2],a1[3],1,0,sideLight*0.96}
            Voxel3D.pushQuad(tI,tQ); tQ=tQ+1
          end
        end

        local function leafBox(x,y,z,hx,hy,hz,tone)
          local p={
            {x-hx,y-hy,z-hz},{x+hx,y-hy,z-hz},
            {x+hx,y-hy,z+hz},{x-hx,y-hy,z+hz},
            {x-hx,y+hy,z-hz},{x+hx,y+hy,z-hz},
            {x+hx,y+hy,z+hz},{x-hx,y+hy,z+hz},
          }
          local faces={{1,2,6,5},{2,3,7,6},{3,4,8,7},{4,1,5,8},{5,6,7,8}}
          for fi,f in ipairs(faces) do
            local sh=tone*((fi==5) and 1.08 or ((fi==1 or fi==4) and 0.98 or 0.84))
            for vi=1,4 do
              local v=p[f[vi]]
              local u=((vi==2 or vi==3) and 1 or 0)
              local vv=((vi>=3) and 1 or 0)
              cV[#cV+1]={v[1],v[2],v[3],u,vv,sh}
            end
            Voxel3D.pushQuad(cI,cQ); cQ=cQ+1
          end
        end

        local turn=hash01(cx,cy,47001)*math.pi
        local dx,dz=math.cos(turn),math.sin(turn)
        local px,pz=-dz,dx
        local lean=(hash01(cx,cy,47002)-0.5)*0.42
        local topx,topz=mx+px*lean,mz+pz*lean

        -- Slender live trunk and four light young branches.
        tube(mx,base+0.10,mz,0.72,
             mx+px*lean*0.42,base+12.8,mz+pz*lean*0.42,0.50,7,1.00)
        tube(mx+px*lean*0.42,base+12.6,mz+pz*lean*0.42,0.50,
             topx,base+20.5,topz,0.31,7,0.98)
        tube(mx+px*lean*0.34,base+13.7,mz+pz*lean*0.34,0.35,
             topx-dx*2.35,base+17.7,topz-dz*2.35,0.16,6,0.92)
        tube(mx+px*lean*0.43,base+15.0,mz+pz*lean*0.43,0.32,
             topx+dx*2.55,base+18.9,topz+dz*2.55,0.14,6,0.94)
        tube(mx+px*lean*0.48,base+16.1,mz+pz*lean*0.48,0.27,
             topx+px*2.10,base+19.2,topz+pz*2.10,0.12,6,0.88)
        tube(mx+px*lean*0.40,base+14.5,mz+pz*lean*0.40,0.28,
             topx-px*1.85,base+17.8,topz-pz*1.85,0.12,6,0.90)

        -- Two plain city planting stakes, kept lower than the live crown.
        local stakeR=4.15
        local lx,lz=mx-dx*stakeR,mz-dz*stakeR
        local rx,rz=mx+dx*stakeR,mz+dz*stakeR
        tube(lx,base+0.08,lz,0.48,lx,base+9.8,lz,0.42,4,0.78,0.12)
        tube(rx,base+0.08,rz,0.48,rx,base+9.8,rz,0.42,4,0.78,0.12)

        -- Dark support ties: opposing flexible lines plus a short central
        -- binding band. The reduced shade makes the bark material read as
        -- black-brown garden wire without adding another texture or draw pass.
        tube(lx,base+9.05,lz,0.15,
             mx-dx*0.50,base+8.55,mz-dz*0.50,0.13,4,0.30,0.08)
        tube(rx,base+9.05,rz,0.15,
             mx+dx*0.50,base+8.55,mz+dz*0.50,0.13,4,0.30,0.08)
        tube(mx-dx*0.68,base+8.55,mz-dz*0.68,0.17,
             mx+dx*0.68,base+8.55,mz+dz*0.68,0.17,4,0.26,0.08)

        -- A compact, deliberately open crown. Five separated bunches leave
        -- daylight between leaves, clearly distinguishing a new sapling from
        -- the dense umbrellas on the locked mature family.
        local green=0.91+hash01(cx,cy,47003)*0.10
        leafBox(topx,base+20.3,topz,1.35,1.45,1.20,green)
        leafBox(topx-dx*2.20,base+17.9,topz-dz*2.20,1.35,1.15,1.10,green*0.88)
        leafBox(topx+dx*2.35,base+19.0,topz+dz*2.35,1.45,1.25,1.12,green*1.02)
        leafBox(topx+px*1.95,base+19.3,topz+pz*1.95,1.18,1.05,1.30,green*0.94)
        leafBox(topx-px*1.72,base+18.0,topz-pz*1.72,1.10,1.00,1.22,green*0.84)
 return tQ,cQ
end
return M
