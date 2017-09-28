local pathOfThisFile = ...
local folderOfThisFile = (...):match("(.-)[^%.]+$")

require (folderOfThisFile .. 'grid')
require (folderOfThisFile .. 'enemies')

-- constants
local buildings_scores = { 
    [global.build_type_energy] = 0,
    [global.build_type_civil] = 1,
    [global.build_type_food] = 2,
}
local buildings_energy = { 
    [global.build_type_energy] = 1.45,
    [global.build_type_civil] = 1.2,
    [global.build_type_food] = 1,
}

local function new_building(building_type)
    if building_type == global.build_type_energy then
        return { tile_type=building_type, health=10, health_max = 10 }
    elseif building_type == global.build_type_civil then
        return { tile_type=building_type, health=6, health_max = 6 }
    elseif building_type == global.build_type_food then
        return { tile_type=building_type, health=3, health_max = 3 }
    end
    return { tile_type=building_type, health=1, health_max = 1 }
end

GameController = class("GameController")

function GameController:initialize(group)
    -- local objects
    self.map = RectGrid(spritesheet_game, spritesheet_game_options, group)      
    
    -- some adjustment of buildable tiles to our shore (todo: make other way)
    self.map:get(1, 1).is_valid = false
    self.map:get(1, 2).is_valid = false
    self.map:get(1, 3).is_valid = false
    self.map:get(1, 4).is_valid = false
    self.map:get(1, 5).is_valid = false
    self.map:get(1, 9).is_valid = false
    self.map:get(2, 1).is_valid = false
    self.map:get(2, 9).is_valid = false
    self.map:get(3, 1).is_valid = false
    self.map:get(15, 1).is_valid = false
    self.map:get(15, 9).is_valid = false 
    
    self.enemies = EnemyControll(spritesheet_game, self.map, group)
    self:reset()
end

function GameController:reset()    
    local platform_coeff = 1
    if system.platform == 'android' then
      platform_coeff = 1.3
    end  

    self.ability_cooldown = {}
    
    if global.game_mode == global.game_mode_casual then
      self.night_total_time = 600
      self.day_total_time = 1
      self.days_in_game = 8
      self.enemy_speed = self.map.tilew / 550
      self.enemy_start_dps = 1 * platform_coeff
      self.enemy_add_dps = 1
      self.night_speed = 1
      self.day_speed = 1
      self.spawn_cooldown_max = 10 / platform_coeff
      self.ability_cooldown[global.ability_fire] = { current = 0, max = 1, speed =  self.night_speed * 5 /self.night_total_time }
      self.ability_cooldown[global.ability_shield] = { current = 0, max = 1, speed =  self.night_speed * 3 /self.night_total_time }
    end
    if global.game_mode == global.game_mode_normal then
      self.night_total_time = 700
      self.day_total_time = 100
      self.days_in_game = 10
      self.enemy_speed = self.map.tilew / 500
      self.enemy_start_dps = 1.1 * platform_coeff
      self.enemy_add_dps = 1.3
      self.night_speed = 1
      self.day_speed = 1
      self.spawn_cooldown_max = 10 / platform_coeff
      self.ability_cooldown[global.ability_fire] = { current = 0, max = 1, speed =  self.night_speed * 3 / self.night_total_time}
      self.ability_cooldown[global.ability_shield] = { current = 0, max = 1, speed =  self.night_speed * 1.5 /self.night_total_time }
    end
    if global.game_mode == global.game_mode_hard then
      self.night_total_time = 800
      self.day_total_time = 80
      self.days_in_game = 10
      self.enemy_speed = self.map.tilew / 450
      self.enemy_start_dps = 1.3 * platform_coeff
      self.enemy_add_dps = 1.5
      self.night_speed = 1
      self.day_speed = 1
      self.spawn_cooldown_max = 9 / platform_coeff
      self.ability_cooldown[global.ability_fire] = { current = 0, max = 1, speed =  self.night_speed * 2 / self.night_total_time}
      self.ability_cooldown[global.ability_shield] = { current = 0, max = 1, speed = self.night_speed * 1.1 / self.night_total_time}
    end
    
    -- state info & timers
    self.is_night = false
    self.is_finished = false
    self.day_night_timer = 1
    self.days_passed = 0
    self.score = 0
    self.score_max = 0
    self.build_cells = {}
    self.buildings_max = 3
    self.spawn_cooldown = 0
    self.restore_energy_timer = 0

    self.map:clear()
    self.enemies:clear()
    
    self.map.energy = self.map.energy_max
    self.map:add_object(self.map.center.x, self.map.center.y, new_building(global.build_type_civil))
    
    self:update_score()    
    self:update_energy( )
end

function GameController:use_ability(ability)
    if ability == global.ability_fire then 
      self.spawn_cooldown = 300
      for h=1, self.map.height do for w=1, self.map.width do
          local coordinates = self.map:translate(w, h)
          local generate = math.random(100)
          if generate > 65 then
            local rocket_animation = {
                  name = "appear",
                  start = global.enemy_1+16, count = 4, time = 300, loopCount = 1
              }
            local function animation_handler ( event ) 
              if event.phase == "ended" then
                  event.target:removeSelf() 
              end
            end 
            local rocket = display.newSprite(self.enemies.group, spritesheet_game, rocket_animation )           
            rocket:scale(self.map.scale, self.map.scale)
            rocket:addEventListener( "sprite", animation_handler)
            rocket:play()

            rocket.x = coordinates.x
            rocket.y = coordinates.y
          end

          local myClosure  =  function() return self.enemies:take_damage(coordinates) end
          timer.performWithDelay( 300, myClosure  )
      end end
    end
    if ability == global.ability_shield then
      self.restore_energy_timer = 1
      self.restore_energy_start = self.map.energy
    end
    self.ability_cooldown[ability].current = self.ability_cooldown[ability].max
end

function GameController:get_energy( ... )
    return self.map.energy / self.map.energy_max
end

function GameController:destroy( ... )
    self.enemies:clear()
    self.enemies = nil
    self.map:clear()
    self.map = nil
end

function GameController:day()
    local dt = global.delta_time

    self.day_night_timer = math.max(0, self.day_night_timer - dt * self.day_speed / self.day_total_time)
    self.map.energy = math.min(self.map.energy_max, self.map.energy + dt * 0.6)
end

function GameController:night()
    local dt = global.delta_time
    
    self.day_night_timer = math.max(0, self.day_night_timer - dt * self.night_speed / self.night_total_time)
    
    -- restore shield ability is active
    if self.restore_energy_timer > 0 then
      self.restore_energy_timer = math.max(0, self.restore_energy_timer - dt * 0.1)
      self.map.energy = self.restore_energy_start + ( 1 - self.restore_energy_timer) *  self.map.energy_max
    end
    
    -- abilities cooldown
    for i=1, #global.ability_all do
      self.ability_cooldown[global.ability_all[i]].current = math.max(0, self.ability_cooldown[global.ability_all[i]].current-dt*self.ability_cooldown [global.ability_all[i]].speed)
    end

    -- was the last living building destroyed and we failed the game
    if self.map:count(global.build_type_civil) == 0 then
      self.is_finished = true
      self.day_night_timer = 0
    end
    
    -- spawn new enemies    
    if self.spawn_cooldown == 0 then 
      self.spawn_cooldown = self.spawn_cooldown_max
      self.enemies:gen_enemy(global.enemy_1, self.enemy_speed, self.enemy_start_dps + self.enemy_add_dps * self.days_passed/self.days_in_game)
    else
      self.spawn_cooldown = clamp(self.spawn_cooldown - dt, 0, self.spawn_cooldown_max)
    end

    self.enemies:update(dt)
    self.enemies:draw(dt)
end

function GameController:update_energy( ) 
    self.map.energy_max = 10
    for h=1, self.map.height do for w=1, self.map.width do
        if not self.map:is_empty(w, h) then
          self.map.energy_max = self.map.energy_max * buildings_energy[self.map:get(w, h).tile_type]
        end 
    end end
end

function GameController:pause( state )  
    self.enemies:pause(state)
end

function GameController:switch_mode( )    
    self.is_night = not self.is_night
    self.day_night_timer = 1
    if  self.is_night then
        for i=1, #global.ability_all do
          self.ability_cooldown[global.ability_all[i]].current = 0
        end
    else    
        self.days_passed = clamp(self.days_passed + 1, 0, self.days_in_game)
        self.spawn_timer = 0
        self.enemies:clear()
        self.is_finished = self.days_passed == self.days_in_game or self.map:count(global.build_type_civil) == 0
    end
    
    self:update_energy()
end

function GameController:build_rate( building_type )
    return buildings_scores[building_type]
end

-- get cell we can build on
function GameController:get_build_cell()
    local function distance(a, b)
        if a.x == b.x or a.y == b.y then
            return math.abs(a.x-b.x) + math.abs(a.y-b.y)
        end
        return math.abs(a.x-b.x)*0.8 + math.abs(a.y-b.y)*0.8
    end
    local cell = nil
    for h=1, self.map.height do for w=1, self.map.width do
        if self.map:is_empty(w, h) and self.map:get(w, h).is_valid then
            local neighbours = self.map:get_adjacent(w, h)
            for i=1, #neighbours do
              if neighbours[i].tile_type ~= nil and (cell == nil or distance(cell, self.map.center) > distance(position(w, h), self.map.center)) then
                cell = position(w, h)
                break
              end
            end
        end
    end end 
    return cell
end

function GameController:update_score()
    self.score =  0
    for h=1, self.map.height do for w=1, self.map.width do
        if not self.map:is_empty(w, h) then
          self.score = self.score + buildings_scores[self.map:get(w, h).tile_type]
        end
    end end
    self.score_max = math.max(self.score_max, self.score)
end

function GameController:build(building_type)
    local cell = self:get_build_cell()
    self.map:add_object(cell.x, cell.y, new_building(building_type))
end

function GameController:update(...)
    if self.is_night then
        self:night()
        self.map:update_night(global.delta_time)
    else
        self:day()
        self.map:update_day(global.delta_time)
    end

    self.map:draw()
end