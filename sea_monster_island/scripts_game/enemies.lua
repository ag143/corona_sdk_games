local pathOfThisFile = ...
local folderOfThisFile = (...):match("(.-)[^%.]+$")

EnemyControll = class("EnemyControll")

function EnemyControll:initialize(spritesheet, map, group)
    self.enemies = {}
    self.spritesheet = spritesheet
    self.map = map
    self.spawn_points = self:get_spawn_points()
    self.group = display.newGroup()   
    self.targets = {}
    
    local function on_tap( event )  
        if (event.phase == "began") then  
            self:take_damage(event)
        end
    end

    group:insert(self.group)
    group:addEventListener( "touch", on_tap)
end

function EnemyControll:get_spawn_points()
    local cells = {}
    for h=1, self.map.height do for w=1, self.map.width do
        if not self.map:get(w, h).is_valid then
          table.insert(cells, position(w, h))
        end
    end end
    return cells
end

function EnemyControll:find_next( pos_start, pos_final )
    local adj = self.map:get_adjacent(pos_start.x, pos_start.y)
    local best = nil
    for i=1, #adj do
      if best == nil or distance(best, pos_final) > distance(adj[i], pos_final) then
         best = adj[i]
      end
    end    
    return best
end

function EnemyControll:gen_enemy(enemy_type, speed, dps)
    local enemy = { type=enemy_type, tile=nil, speed=speed, pos_next=nil, health=1, dps = dps }    
    local spawn = random_value(self.spawn_points)
    enemy.pos_prev = position(spawn.x, spawn.y)
    enemy.pos = position(spawn.x, spawn.y)
    enemy.target = self.map.center
    enemy.animations = {
        {
            name = "appear",
            start = enemy_type+12, count = 4, time = 300, loopCount = 1
        },
        {
            name = "walk",
            start = enemy_type, count = 4, time = 500, loopCount = 0, loopDirection = "bounce"
        },
        {
            name = "attack",
            start = enemy_type+4, count = 4, time = 500, loopCount = 0, loopDirection = "bounce"
        },
        {
            name = "die",
            start = enemy_type+8, count = 4, time = 300, loopCount = 1
        },
        {
            name = "hide",
            frames = {enemy_type+12+3, enemy_type+12+2, enemy_type+12+1, enemy_type+12}, time = 300, loopCount = 1
        },
    }

    local function enemy_update (  )
        if enemy.target ~= nil and self.map:is_empty(enemy.target.x, enemy.target.y) then
          enemy.target = nil
          enemy.pos_next = nil
        end
        if enemy.target == nil then  
            for h=1, self.map.height do for w=1, self.map.width do
                if not self.map:is_empty(w, h) then
                    enemy.target = position(w, h)
                    break
                end
            end end 
        end 
        if enemy.target == nil then
            enemy.tile:setSequence(enemy.animations[5].name)
            enemy.tile:play()
            enemy.type = nil
            enemy.update = nil
        elseif enemy.pos_next == nil then 
            enemy.pos_next = self:find_next(enemy.pos_prev, enemy.target)
        end
    end

    enemy.on_complete_die_transition = function ( ) 
        if enemy.tile ~= nil then enemy.tile.isVisible = false end
    end 
    
    enemy.sprite_anim_handler = function ( event ) 
        if event.phase == "ended" and enemy.tile ~= nil and enemy.tile.sequence == enemy.animations[1].name then
            enemy.tile:setSequence(enemy.animations[2].name)
            enemy.tile:play()
            enemy.update = enemy_update
        end 
        if event.phase == "bounce" and enemy.tile ~= nil and enemy.tile.sequence == enemy.animations[2].name then  
            if enemy.pos_next ~= nil and not self.map:is_empty(enemy.pos_next.x, enemy.pos_next.y) then
                -- attack what blocking the way
                enemy.tile:setSequence(enemy.animations[3].name)
                enemy.tile:play()
            end
        end
        if event.phase == "bounce" and enemy.tile ~= nil and enemy.tile.sequence == enemy.animations[3].name then
            if enemy.pos_next ~= nil and not self.map:is_empty(enemy.pos_next.x, enemy.pos_next.y) then
                if not self.is_paused then
                  self.map:take_damage(enemy.pos_next.x, enemy.pos_next.y, enemy.animations[1].time/1000 * enemy.dps)
                end
            else
                enemy.tile:setSequence(enemy.animations[2].name)
                enemy.tile:play()
                enemy.target = nil
            end
        end
        if event.phase == "ended" and enemy.tile ~= nil and enemy.tile.sequence == enemy.animations[4].name  then 
            transition.to( enemy.tile, {  alpha=0.1, xScale=0.5, yScale=0.5, time=90, transition=easing.inOutSine, onComplete=enemy.on_complete_die_transition })
        end
        if event.phase == "ended" and enemy.tile ~= nil and enemy.tile.sequence == enemy.animations[5].name  then 
            enemy.tile:removeSelf() 
            enemy.tile = nil
        end
    end
    table.insert(self.enemies, enemy)
end

function EnemyControll:pause(state)
  self.is_paused = state
end

function EnemyControll:take_damage(pos)
    local count = table.getn(self.enemies)
    for i=1, count do
        local obj = self.enemies[i]
        if obj.tile ~= nil and obj.health > 0 and distance(pos, obj.tile) <= self.map.tilew * 1.1 then
            obj.health = obj.health - 1
            if obj.health == 0 then
                obj.tile:setSequence(obj.animations[4].name)
                obj.tile:play()
                obj.type = nil
                obj.update = nil
            end
            break
        end
    end
end

function EnemyControll:clear()
    self.targets = {}
    
    for i=1,#self.enemies do
        local child = self.enemies[i]
        if child.tile ~= nil then 
          transition.cancel(child.tile)
          child.tile:setSequence(child.animations[5].name)
          child.tile:play()
          child.type = nil
        end
    end
    self.enemies = {}
end

function EnemyControll:update(dt)  
    local count = table.getn(self.enemies)
    for i=1, count do
        local enemy = self.enemies[i]
        if enemy.update ~= nil then
           enemy.update()
        end
    end 
end

function EnemyControll:draw(dt)
    local count = table.getn(self.enemies)
    for i=1, count do        
        local obj = self.enemies[i]
        -- draw missing enemy tile
        if obj.tile == nil and obj.type ~= nil then
            obj.tile = display.newSprite(self.group, self.spritesheet, obj.animations )           
            obj.tile:scale(self.map.scale, self.map.scale)
            obj.tile:addEventListener( "sprite", obj.sprite_anim_handler )
            obj.tile:play()
        end
        if obj.tile ~= nil and obj.pos_next ~= nil and self.map:is_empty(obj.pos_next.x, obj.pos_next.y) then 
            -- move enemy to dest
            obj.pos.x = lerp_current(obj.pos_prev.x, obj.pos_next.x, obj.pos.x, dt * obj.speed)
            obj.pos.y = lerp_current(obj.pos_prev.y, obj.pos_next.y, obj.pos.y, dt * obj.speed)
            if position_cmp(obj.pos, obj.pos_next) then
                obj.pos_prev = obj.pos_next
                obj.pos_next = nil
            end
        end
        if obj.tile ~= nil and obj.target ~= nil then
            obj.tile.rotation = direction_to_angle(obj.pos, obj.target)
        end
        if obj.tile ~= nil then
            -- update enemy position on screen
            local coordinates = self.map:translate(obj.pos.x, obj.pos.y)
            obj.tile.x = coordinates.x
            obj.tile.y = coordinates.y
        end
    end
end