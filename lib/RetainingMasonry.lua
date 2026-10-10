-- Shared Legendary retaining courses. Source tile callers supply their own
-- clipped face emitter, material swatches and orientation; geometry is identical.
local M={}
function M.build(d,x0,z0,y0,y1,shade,options)
 local tileOverride,custom=options.cave,options.custom
 local rockNoise,faceAxisPoint,sideSolid=options.noise,options.point,options.emit
 local uvDark,uvShadow,uvBody,uvLight=options.dark,options.shadow,options.body,options.light
    local axis0 = (d == 5 or d == 6) and x0 or z0
    local axis1 = axis0 + 8

    sideSolid({ faceAxisPoint(d, x0, z0, axis0, y0, 0),
                faceAxisPoint(d, x0, z0, axis1, y0, 0),
                faceAxisPoint(d, x0, z0, axis1, y1, 0),
                faceAxisPoint(d, x0, z0, axis0, y1, 0) },
              uvDark, shade, 0.74, d, x0, z0, y0, y1)

    local courseH = 4
    local gap = 0.16
    local depth = 0.28
    local firstRow = math.floor(y0 / courseH)
    local lastRow = math.ceil(y1 / courseH) - 1
    for row = firstRow, lastRow do
      local ys = math.max(y0, row * courseH)
      local ye = math.min(y1, (row + 1) * courseH)
      local offset = (row % 2 ~= 0) and 3 or 0
      local firstCol = math.floor((axis0 - offset - 8) / 6) - 1
      local lastCol = math.ceil((axis1 - offset + 8) / 6) + 1
      for col = firstCol, lastCol do
        -- TEST38 lets only the cave masonry wander farther from the ruler.
        -- The same world-space boundary sample is shared by both neighbours,
        -- so irregular widths never open a crack at a hidden source-tile cut.
        local boundaryJitter = tileOverride and 1.85 or 1.05
        local xs = col * 6 + offset
                   + (rockNoise(col, row, 41) - 0.5) * boundaryJitter
        local xe = (col + 1) * 6 + offset
                   + (rockNoise(col + 1, row, 41) - 0.5) * boundaryJitter
        if xe > axis0 and xs < axis1 then
          local sx = math.max(axis0, xs + gap)
          local ex = math.min(axis1, xe - gap)
          local sy = ys + gap
          local ey = ye - gap
          if ex > sx and ey > sy then
            -- Each cave brick has four independently weathered corners.
            -- The insets stay inside the original cell, leaving chipped,
            -- crooked silhouettes against the single dark backing face. At
            -- artificial 8px clips the inset is zero, allowing a stone to
            -- continue seamlessly into the neighbouring cached tile.
            local sxBottom, sxTop, exBottom, exTop = sx, sx, ex, ex
            local syLeft, syRight, eyLeft, eyRight = sy, sy, ey, ey
            local leftEdge, rightEdge = true, true
            if tileOverride or custom then
              local spanX = ex - sx
              local spanY = ey - sy
              local xInset = math.min(0.30, spanX * 0.30)
              local yInset = math.min(0.27, spanY * 0.30)
              leftEdge = xs + gap >= axis0 - 0.001
              rightEdge = xe - gap <= axis1 + 0.001
              if leftEdge then
                sxBottom = sx + rockNoise(col, row, 70 + d) * xInset
                sxTop = sx + rockNoise(col, row, 71 + d) * xInset
              end
              if rightEdge then
                exBottom = ex - rockNoise(col, row, 72 + d) * xInset
                exTop = ex - rockNoise(col, row, 73 + d) * xInset
              end
              -- A brick split only for caching must meet itself exactly at
              -- that invisible cut. Fully contained bricks receive the full
              -- crooked upper/lower silhouette; clipped bricks keep their
              -- irregular natural end but share straight cut coordinates.
              if leftEdge and rightEdge then
                syLeft = sy + rockNoise(col, row, 74 + d) * yInset
                syRight = sy + rockNoise(col, row, 75 + d) * yInset
                eyLeft = ey - rockNoise(col, row, 76 + d) * yInset
                eyRight = ey - rockNoise(col, row, 77 + d) * yInset
              end
            end

            local bbl = faceAxisPoint(d, x0, z0, sxBottom, syLeft, 0)
            local bbr = faceAxisPoint(d, x0, z0, exBottom, syRight, 0)
            local btr = faceAxisPoint(d, x0, z0, exTop, eyRight, 0)
            local btl = faceAxisPoint(d, x0, z0, sxTop, eyLeft, 0)
            -- TEST38 keeps TEST37's recessed-to-proud relief, then adds stable
            -- corner wear. A minority of stones are deeply eroded or pushed
            -- forward, breaking the new tall walls into an ancient cave ruin
            -- without decals, extra overlays or live-light-dependent detail.
            -- Outdoor retaining masonry keeps its exact TEST36 geometry.
            local brickDepth = depth
            local brickTilt = 0
            local wear = 0.5
            if tileOverride then
              wear = rockNoise(col, row, 68 + d)
              brickDepth = 0.15 + rockNoise(col, row, 66 + d) * 0.46
              if wear > 0.84 then
                brickDepth = 0.09 + rockNoise(col, row, 69 + d) * 0.15
              elseif wear < 0.10 then
                brickDepth = 0.52 + rockNoise(col, row, 69 + d) * 0.12
              end
              if leftEdge and rightEdge then
                brickTilt = (rockNoise(col, row, 67 + d) - 0.5) * 0.10
              end
            end
            if not tileOverride and custom then
              brickDepth=.18+rockNoise(col,row,606+d)*.20
              if leftEdge and rightEdge then brickTilt=(rockNoise(col,row,607+d)-.5)*.06 end
            end
            local function batteredDepth(salt, sideTilt)
              local cornerWear = tileOverride and leftEdge and rightEdge
                and (rockNoise(col, row, salt + d) - 0.5) * 0.14 or 0
              return math.max(0.08, math.min(0.68,
                                            brickDepth + sideTilt + cornerWear))
            end
            local depthBL = batteredDepth(78, -brickTilt)
            local depthBR = batteredDepth(79, brickTilt)
            local depthTR = batteredDepth(80, brickTilt)
            local depthTL = batteredDepth(81, -brickTilt)
            local fbl = faceAxisPoint(d, x0, z0, sxBottom, syLeft, depthBL)
            local fbr = faceAxisPoint(d, x0, z0, exBottom, syRight, depthBR)
            local ftr = faceAxisPoint(d, x0, z0, exTop, eyRight, depthTR)
            local ftl = faceAxisPoint(d, x0, z0, sxTop, eyLeft, depthTL)
            local variation = rockNoise(col, row, 50 + d)
            local uv = wear > 0.84 and uvShadow
                       or variation > 0.86 and uvLight
                       or variation < 0.13 and uvShadow or uvBody
            local tone = 0.87 + rockNoise(col, row, 60 + d) * 0.15

            sideSolid({ fbl, fbr, ftr, ftl }, uv,
                      shade, tone, d, x0, z0, y0, y1)
            sideSolid({ btl, btr, ftr, ftl }, uvLight,
                      shade, 0.94, d, x0, z0, y0, y1)
            sideSolid({ bbr, bbl, fbl, fbr }, uvShadow,
                      shade, 0.80, d, x0, z0, y0, y1)

            -- A stone clipped only by the hidden 8px source-tile boundary
            -- resumes in the neighbour without receiving a fake end bevel.
            if xs + gap >= axis0 - 0.001 then
              sideSolid({ bbl, btl, ftl, fbl }, uvShadow,
                        shade, 0.84, d, x0, z0, y0, y1)
            end
            if xe - gap <= axis1 + 0.001 then
              sideSolid({ btr, bbr, fbr, ftr }, uvBody,
                        shade, 0.87, d, x0, z0, y0, y1)
            end
          end
        end
      end
    end
end
return M
