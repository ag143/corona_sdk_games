-- initialize common resources
require 'resources'
require 'scripts_common.class'
require 'scripts_common.middleclass'
require 'scripts_common.math'

-- define globals
global = {}
global.height = 9
global.width = 15
global.delta_time = 0

global.scene_menu = "scenes.menu"
global.scene_game = "scenes.game"
global.scene_finish = "scenes.finish"
global.scene_rating = 'scenes.rating'

global.game_mode_casual = 'casual'
global.game_mode_normal = 'normal'
global.game_mode_hard = 'hard'

global.build_type_civil = 2
global.build_type_energy = 3
global.build_type_food = 4
global.basement = 5
global.wall = 6
global.ground = 6
global.ground_fake = 8
global.enemy_1 = 9
global.ability_fire = 0
global.ability_repair = 1
global.ability_shield = 2
global.ability_all = {global.ability_fire, global.ability_shield}

global.win_bonus = 0
global.last_score = 0

global.preference = require "scripts_common.preference"
global.preference.volume = "volume"
global.preference.is_tutorial = "tutorial"
global.preference.menu_unlock_anim = "menu_unlock_anim"
global.preference.is_menu_unlocked = "is_menu_unlocked"
global.preference.highscores = "highscores"
if global.preference.getValue(global.preference.is_tutorial) == nil then
	global.preference.save{tutorial=true}
end
if global.preference.getValue(global.preference.menu_unlock_anim) == nil then
	global.preference.save{menu_unlock_anim=false}
end
if global.preference.getValue(global.preference.is_menu_unlocked) == nil then
	global.preference.save{is_menu_unlocked=false}
end
if global.preference.getValue(global.preference.highscores) == nil then
	global.preference.save{highscores={}}
end
if global.preference.getValue(global.preference.volume) == nil then
	global.preference.save{volume=0.5}
end
local function save_score(name, score)
  local all = global.preference.getValue(global.preference.highscores)
  local inserted = false
  for i=1, #all do
    local n, s = unpack(all[i])
    if score > s then
      table.insert(all, i,{name, score})
      inserted = true
      break
    end
  end
  if not inserted then
    table.insert(all,{name, score})
  end
  if #all > 10 then
    table.remove(all)
  end
  global.preference.save{highscores=all}
end
global.preference.save_score = save_score

-- frame delta time count
local runtime = 0
local function on_enter_frame(event)
	-- store delta time
	local temp = system.getTimer()  -- Get current game time in ms
	global.delta_time = (temp-runtime)*1.0/ (1000/display.fps)  -- 60 fps or 30 fps as base
	runtime = temp  -- Store game time
end

Runtime:addEventListener( "enterFrame", on_enter_frame )

local composer = require( "composer" )
composer.gotoScene( global.scene_menu )