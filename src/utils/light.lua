local PATH = (...):gsub('%.[^%.]+$', '')

local vector = require(PATH..".libs.vector-light")

-- Each light source will have a visibility polygon
-- That polygon will be used as a stencil for the light sprite
-- This visibility polygon only needs to be re-calculated if either:
--  a) The light moves
--  b) The map changes
-- Otherwise we can store the stencil as a cached canvas. Nice.

local function visiblityPolygonSortFunc(a, b)
  return a.angle < b.angle
end

-- occluderCoordinates in format: { x1, y1, x2, y2, ... }
local function calculateVisibilityPolygon(originX, originY, radius, occluderCoordinates)
  local visibilityPolygon = {}

  print("calculate")
  -- For each edge (point to point)
  for p=1,#occluderCoordinates-2,2 do
    local rdx = occluderCoordinates[p] - originX
    local rdy = occluderCoordinates[p+1] - originY

    local baseAngle = math.atan2(rdx, rdy)
    print("baseAngle", baseAngle)
    local angle = 0

    -- For each point, cast 3 rays. 1 ray directly at point, then one slightly to either side
    for rayIndex=1,3 do
      if rayIndex == 1 then angle = baseAngle - 0.0001 end
      if rayIndex == 2 then angle = baseAngle end
      if rayIndex == 3 then angle = baseAngle + 0.0001 end

      -- Create ray along angle for required distance
      local rayX = radius * math.cos(angle)
      local rayY = radius * math.sin(angle)

      local min_t1 = math.huge
      local min_px = 0
      local min_py = 0
      local minAngle = 0
      local valid = false

      for p2=1,#occluderCoordinates-2,2 do
        local p2sx = occluderCoordinates[p2]
        local p2sy = occluderCoordinates[p2+1]
        local p2ex = occluderCoordinates[p2+2]
        local p2ey = occluderCoordinates[p2+3]

        -- Line segment
        local sdx = p2ex - p2sx
        local sdy = p2ey - p2sy

        if math.abs(sdx-rayX) > 0 and math.abs(sdy-rayY) > 0 then
          -- t2 is the normalised distance from line segment start to line segment end of intersect point
          local t2 = (rayX * (p2sy - originY) + (rayY * (originX - p2sx))) / (sdx * rayY - sdy * rayX)
          -- t1 is the normalised distance from source along ray to ray length of intersect point
          local t1 = (p2sx + sdx * t2 - originX) / rayX

          -- If intersect point exists along ray, and along line segment, then
          -- intersect point is valid

          if t1 > 0 and t2 >= 0 and t2 <= 1 then
            -- Check if this intersect point is closest to source. If it is,
            -- then store this point and reject others
            if t1 < min_t1 then
              min_t1 = t1
              min_px = originX + rayX * t1
              min_py = originY + rayY * t1
              minAngle = math.atan2(min_px - originX, min_py - originY)
              valid = true
            end
          end
        end
      end

      if valid then
        -- Add intersection point to visibility polygon perimeter
        table.insert(visibilityPolygon, { angle = minAngle, x = min_px, y = min_py })
      end
    end
  end

  -- Sort points by angle from source. This will allow us to draw a triangle fan
  table.sort(visibilityPolygon, visiblityPolygonSortFunc)
  return visibilityPolygon
end

local function calcPolygon(ox, oy, radius, occluderEdges)
  local polygon = {}

  for _, e1 in ipairs(occluderEdges) do
    for i=0,1 do
      local rdx = (i == 0 and e1.sx or e1.ex) - ox
      local rdy = (i == 0 and e1.sy or e1.ey) - oy

      local base_ang = math.atan2(rdx, rdy)
      local ang = 0

      for j=0,2 do
        if j == 0 then ang = base_ang - 0.0001 end
        if j == 1 then ang = base_ang end
        if j == 2 then ang = base_ang + 0.0001 end

        rdx = radius * math.cos(ang)
        rdy = radius * math.sin(ang)

        local min_t1 = math.huge
        local min_px, min_py, min_ang = 0
        local valid = false

        for _, e2 in ipairs(occluderEdges) do
          local sdx = e2.ex - e2.sx
          local sdy = e2.ey - e2.sy

          if math.abs(sdx - rdx) > 0 and math.abs(sdy - rdy) > 0 then
            local t2 = (rdx * (e2.sy - oy) + (rdy * (ox - e2.sx))) / (sdx * rdy - sdy * rdx)
            local t1 = (e2.sx + sdx * t2 - ox) / rdx

            if t1 > 0 and t2 >= 0 and t2 <= 1 then
              if t1 < min_t1 then
                min_t1 = t1
                min_px = ox + rdx * t1
                min_py = oy * rdy * t1
                min_ang = math.atan2(min_px - ox, min_py - oy)
                valid = true
              end
            end
          end
        end

        if valid then
          table.insert(polygon, { angle = min_ang, x = min_px, y = min_py })
        end
      end
    end
  end

  local function sortFunc(a, b)
    return a.angle < b.angle
  end

  table.sort(polygon, sortFunc)
  return polygon
end

return {
  calculateVisibilityPolygon = calculateVisibilityPolygon,
  calcPolygon = calcPolygon
}
