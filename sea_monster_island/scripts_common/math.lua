function size(width, height)
    return {width=width, height=height}
end

function rect(x, y, width, height)
    return {x=x, y=y, width=width, height=height}
end

function is_in_rect(rect, position)
    return (rect.x-rect.width*0.5) < position.x and (rect.x+rect.width*0.5) > position.x 
        and (rect.y-rect.height*0.5) < position.y and (rect.y+rect.height*0.5) > position.y
end

function position(x, y)
    return {x=x, y=y}
end

function position_cmp(a, b)
    if a ~= nil and b ~= nil then
        return a.x == b.x and a.y == b.y
    else
        return false
    end
end

function distance(a, b)
    return math.sqrt(math.abs(a.x-b.x)^2 + math.abs(a.y-b.y)^2)
end

function distance_compare(a1, a2, b)
    return distance(a1, b) < distance(a2, b)
end

function clamp(x, min, max)
    return x < min and min or x > max and max or x
end

function lerp_current(v0, v1, cur, amount)
    local sign = v1 > v0 and 1 or -1
    local result = cur + sign * amount
    return clamp(result, math.min(v0, v1), math.max(v0, v1))
end

function lerp(v0, v1, t)
    local t1 = clamp(t, 0, 1)
    if v1 < v0 then t1 = 1 - t1 end
    local result = math.min(v0, v1) + t1 * math.abs(v0 - v1)
    return clamp(result, math.min(v0, v1), math.max(v0, v1))
end

function random_value(array)
    return array[math.random(#array)]
end

function table.shallow_copy(t)
    local t2 = {}
    for k,v in pairs(t) do
        t2[k] = v
    end
    return t2
end

function table.print(t)    
    for i, node in ipairs (t ) do
        print ( "Index " .. i .. ": " .. node.x .. ":".. node.y)
    end
end

function direction_to_angle(from, to)  
  local deltaX = to.x - from.x;
  local deltaY = to.y - from.y;
  local rad = math.atan2(deltaY, deltaX); -- In radians
  return rad * (180 / math.pi) + 90 -- in degrees,  todo: unusual +90???
end