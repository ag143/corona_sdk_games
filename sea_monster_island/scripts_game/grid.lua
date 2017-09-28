-- simple rectangular tiled grid

local cell_neighbours =  {{-1, 0}, {0, 1}, {1,0}, {0,-1}, {-1,-1}, {1,1}, {-1, 1}, {1, -1}}
local wall_animation = { alpha = 1 }

RectGrid = class("RectGrid")

function RectGrid:initialize(spritesheet, options, group)
  self.height = global.height
  self.width = global.width
  self.tilew = math.round(options.width * options.scale)
  self.tileh = math.round( options.height * options.scale)
  self.scale = options.scale
  self.spritesheet = spritesheet
  self.center = position(math.ceil(self.width/2), math.ceil(self.height/2))
  self.cells = {}
  self.layers = {}
  self.energy = 1
  self.energy_max = 10

  for i=1, 2 do 
     self.layers[#self.layers+1] = display.newGroup()
     group:insert(self.layers[i]) 
  end
  
  for h=0, self.height+1 do for w=0, self.width+1 do
      self:set(w, h, nil)
  end end   

  function blink_in(e)
    transition.to(wall_animation,{time=700,alpha=1, onComplete=blink_out, transition=easing.inSine  })
  end

  function blink_out(e)
    transition.to(wall_animation,{time=700,alpha=0.4, onComplete=blink_in, transition=easing.outSine })
  end

  blink_out()
end

function RectGrid:set(w, h, type)
    local index = (self.width+2)*h+w
    if self.cells[index] ~= nil and self.cells[index].tile ~= nil then 
        self.cells[index].tile:removeSelf()
    end
    if w == 0 or h == 0 or w == self.width+1 or h == self.height+1 then type=1 end
    self.cells[index] = { x=w, y=h, tile_type=type, tile=nil, 
      health = 0, health_max =0, walls = nil, 
      is_valid= w > 1 and w < self.width and h > 1 and h < self.height}
end

function RectGrid:count( type )
    local count = 0
    for h=1, self.height do for w=1, self.width do
      local cell = self:get(w, h)
      if cell.tile_type == type and cell.health > 0 then
        count = count + 1
      end
    end end  
    return count
end
  
function RectGrid:get(w, h)
    local index = (self.width+2)*h+w
    return self.cells[index] ~= nil and self.cells[index] or {}
end

function RectGrid:get_free_cells()
    local cells = {}
    for h=1, self.height do for w=1, self.width do
        if self:is_empty(w, h) and self:get(w, h).is_valid then
            table.insert(cells, self:get(w, h))
        end
    end end 
    return cells
end

function RectGrid:is_empty(w, h)
    local index = (self.width+2)*h+w
    return self.cells[index] ~= nil and self.cells[index].tile_type == nil
end

function RectGrid:get_adjacent(w, h, max)
    local neighbours = cell_neighbours
    max = max ~= nil and max or #cell_neighbours
    local cells = {}
    for i=1, max do
        local x, y = w+neighbours[i][1], h+neighbours [i][2]
        if 0 < x and x <= self.width and 0 < y and y <= self.height then
            table.insert(cells, self:get(x, y))
        end
    end
    return cells
end

function RectGrid:add_object(w, h, object)
    local cell = self:get(w, h)
    cell.tile_type = object.tile_type
    cell.health = object.health
    cell.health_max = object.health_max
end

function RectGrid:translate(w, h)
    return { x=display.contentCenterX - self.width/2*self.tileh - self.tileh/2 + w*self.tileh, 
             y=display.contentCenterY - self.height/2*self.tilew - self.tilew/2 + h*self.tilew }
end

function RectGrid:new_tile(layer, pos, tile_type, scale)
    local tile = display.newSprite(layer, self.spritesheet, { start = tile_type, count=1 })
    local coordinates = self:translate(pos.x, pos.y)
    tile:scale(scale, scale)
    tile.x = coordinates.x
    tile.y = coordinates.y
    transition.from( tile, { xScale=0.1, yScale=0.1, time=100, transition=easing.inOutSine } )
    return tile
end

function RectGrid:take_damage(w, h, amount)
    if self.energy > 0 then
      self.energy = math.max(0, self.energy - amount)
    else
      local cell = self:get(w, h)
      if cell.health > 0 then
        cell.health = math.max(0, cell.health - amount)
      end
    end
end

function RectGrid:update_day(dt)
    for h=1, self.height do for w=1, self.width do
        local cell = self:get(w, h)
        if cell.walls ~= nil then
            cell.walls.alpha =  0
        end
  end end
end

function RectGrid:update_night(dt)  
    for h=1, self.height do for w=1, self.width do
        local cell = self:get(w, h)
        if cell.tile ~= nil and cell.health == 0 then
            cell.health = -1
            cell.tile_type = nil
            cell.tile:removeSelf()
            cell.tile = nil
            local function on_complete()
              cell.walls:removeSelf()
              cell.walls = nil
              cell.basement:removeSelf()
              cell.basement = nil
            end
            transition.to( cell.basement, { alpha=0, time=100, transition=easing.inOutSine, onComplete = on_complete, is_valid = true } )
        elseif cell.walls ~= nil and self.energy > 0 then
            cell.walls.alpha = wall_animation.alpha
        elseif cell.walls ~= nil and self.energy <= 0 then
            cell.walls.alpha =  0
        end
  end end
end

function RectGrid:clear()    
    for i=1, #self.layers do 
        while self.layers[i].numChildren > 0 do
            local child = self.layers[i][1]
            if child then child:removeSelf() end
        end
    end
    for h=0, self.height+1 do for w=0, self.width+1 do
        local cell = self:get(w, h)
        self:set(w, h, nil)
    end end 
end

function RectGrid:draw() 
    for h=1, self.height do for w=1, self.width do
        local cell = self:get(w, h)
        if cell.tile_type ~= nil and cell.basement == nil then
          cell.basement = self:new_tile(self.layers[1], cell, global.basement, self.scale)
        end
        if cell.tile == nil and cell.tile_type ~= nil then
            cell.tile = self:new_tile(self.layers[2], cell, cell.tile_type, self.scale)
        end
        if cell.tile_type ~= nil and cell.walls == nil then
            cell.walls = self:new_tile(self.layers[2], cell, global.wall, self.scale)
        end
        if cell.tile ~= nil then
            cell.tile.alpha = math.max(0, cell.health/cell.health_max)
        end
    end end
end