local pathOfThisFile = ...
local folderOfThisFile = (...):match("(.-)[^%.]+$")

require (folderOfThisFile .. 'ui_controls')
require (folderOfThisFile .. 'cutscenes')

require 'scripts_game.controller'

local composer = require( "composer" ) 
local scene = composer.newScene()
 
-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local controller
local widgets = {}
local is_paused = false
local sound_day_bg = audio.loadStream( sound_day )
local sound_night_bg = audio.loadStream( sound_night )
local sound_channel_current = 1
local scene_fade = {effect = "fade", time = 200 }
local jobs_count = 0

-- -----------------------------------------------------------------------------------
-- controls callbacks
-- -----------------------------------------------------------------------------------
local function check_can_build()
    local free = #controller.map:get_free_cells()
    jobs_count = 0
    for i=1, #widgets.buildings_all do 
        free = free - widgets.buildings_all[i].count
        jobs_count = jobs_count + widgets.buildings_all[i].count
    end
    for i=1, #widgets.buildings_all do 
        if widgets.buildings_all[i].isOn or free > 0 and jobs_count < controller.buildings_max then 
          widgets.buildings_all[i].alpha = 1
          widgets.buildings_all[i].isEnabled = true
        else
          widgets.buildings_all[i].alpha = 0.5
          widgets.buildings_all[i].isEnabled = false
        end
    end
end

local function on_ability_button(event)
    if event.target.isEnabled then
      controller:use_ability(event.target.ability)
    end
end

local function on_build_button(event)
    if event.target.isEnabled then
      local max = controller.buildings_max - jobs_count + event.target.count
      event.target.count = (event.target.count + 1) % (max + 1)
    end
    event.target:setState({ isOn=event.target.count > 0 })
    if event.target.count > 0 then
      event.target.text.text = event.target.count
    else
      event.target.text.text = ""
    end
    if event.target.isEnabled then
      check_can_build()
    end
end

local function end_day_night( ... )
    controller:switch_mode()
    jobs_count = 0

    for i=1, #widgets.buildings_all do 
      for j=1, widgets.buildings_all[i].count do 
        controller:build(widgets.buildings_all[i].building)
      end
    end
    controller:update_score()

    audio.fadeOut({ channel=sound_channel_current, time=100 } )
    audio.stopWithDelay( 100, { channel=sound_channel_current } )
    sound_channel_current = sound_channel_current%2 + 1
    audio.setVolume( global.preference.getValue(global.preference.volume), { channel=sound_channel_current} )
    if controller.is_night then
        for i=1, #widgets.buildings_all do 
          widgets.buildings_all[i]:setState({ isOn=false }) 
          widgets.buildings_all[i].count = 0
          widgets.buildings_all[i].text.text = ""
        end
        audio.play( sound_night_bg, { channel=sound_channel_current, loops=-1, fadein=100 } )
    else
        check_can_build()
        audio.play( sound_day_bg, { channel=sound_channel_current, loops=-1, fadein=100 } )
    end
    widgets.days_counter.appear()
end

local function unpause_game(...)
    local function on_complete()
      is_paused = false
      widgets.pause_group.isVisible = false
    end
    widgets.pause_dialog.animation_hide(widgets.pause_dialog, on_complete)
    return true
end

local function pause_game( ... )
    is_paused = true
    widgets.pause_group.isVisible = true
    widgets.pause_dialog.animation_appear(widgets.pause_dialog)
    return true
end

local function cancel_game( ... )
    controller.is_finished = true
    controller.day_night_timer = 0
    is_paused = false
    return true
end

local function finish_game( ... )     
    for i=1, #widgets.buildings_all do 
      widgets.buildings_all[i]:setState({ isOn=false }) 
      widgets.buildings_all[i].alpha = 1
      widgets.buildings_all[i].isEnabled = true
    end
        
    -- remember score
    global.last_score = controller.score_max
    global.preference.save{is_menu_unlocked=true}
    
    -- additional score for finishing game well
    if controller.days_passed >= controller.days_in_game then
       global.win_bonus = 20
    else
       global.win_bonus = 0
    end
    
    audio.fadeOut({ channel=sound_channel_current, time=100 } )
    audio.stopWithDelay( 100, { channel=sound_channel_current } )
    composer.gotoScene( global.scene_finish, scene_fade)
end
-- -----------------------------------------------------------------------------------
-- ui animations
-- -----------------------------------------------------------------------------------
function score_anim_out( ... )
    widgets.score_counter.text = string.format( "SCORE: %02d", widgets.score_counter.current )
    transition.scaleTo( widgets.score_counter, { xScale=1.0, yScale=1.0, time=100, transition=easing.outSine } )
end
function score_anim( ... )
    widgets.score_counter:setFillColor(unpack(widgets.score_counter.normal_color)) 
    widgets.score_counter.current = controller.score
    transition.scaleTo( widgets.score_counter, { xScale=1.2, yScale=1.2, time=100, onComplete=score_anim_out, transition=easing.inSine } )
end
-- -----------------------------------------------------------------------------------
-- ui structure (create)
-- -----------------------------------------------------------------------------------
function day_ui( ... )
    widgets.day_group = display.newGroup()
    widgets.view:insert(widgets.day_group)

    -- new buildings
    widgets.power_station = build_button_1(on_build_button, widgets.day_group)
    widgets.power_station.building = global.build_type_energy
    
    widgets.living_block = build_button_2(on_build_button, widgets.day_group)
    widgets.living_block.building = global.build_type_civil
    
    widgets.farm = build_button_3(on_build_button, widgets.day_group)
    widgets.farm.building = global.build_type_food

    widgets.buildings_all = { widgets.power_station, widgets.living_block, widgets.farm }
    --widgets.buildings_counter = buildings_counter(widgets.day_group)

    -- system controls
    widgets.end_day = end_day_button(end_day_night, widgets.day_group)

    widgets.day_group.isVisible = not controller.is_night
end

function night_ui( ... )
    widgets.night_group = display.newGroup()
    widgets.view:insert(widgets.night_group)    
    widgets.night_group.isVisible = controller.is_night
    widgets.energy_counter = energy_bar(widgets.night_group)
    
    widgets.ability_fire = ability_button_1(on_ability_button, widgets.night_group)
    widgets.ability_fire.ability = global.ability_fire
    
    widgets.ability_shield = ability_button_3(on_ability_button, widgets.night_group)
    widgets.ability_shield.ability = global.ability_shield
    
    widgets.ability_all = { widgets.ability_fire, widgets.ability_shield }
end

function pause_ui( ... )
    widgets.pause_group = display.newGroup()
    widgets.view:insert(widgets.pause_group)

    widgets.pause_dialog = pause_dialog(unpause_game, widgets.pause_group, cancel_game)

    widgets.pause_group.isVisible = false
end
-- -----------------------------------------------------------------------------------
-- main cycle
-- -----------------------------------------------------------------------------------
local function on_enter_frame(event)
    controller:pause(is_paused)
    
    if is_paused then return end
    if controller.is_finished then 
      finish_game()
    else
      
      controller:update()
      controller:update_score()
      -- auto switch day\night for some modes
      if controller.day_night_timer == 0 and (controller.is_night or global.game_mode ~= global.game_mode_casual) then
          end_day_night()
      end
      
      -- update ui visibility
      widgets.day_group.isVisible = not controller.is_night
      widgets.night_group.isVisible = controller.is_night    
      widgets.timer.isVisible = controller.is_night or global.game_mode ~= global.game_mode_casual

      -- update counters\stats ui
      widgets.timer:setProgress(controller.day_night_timer)  
      widgets.energy_counter:setProgress(controller:get_energy())
      if controller.is_night then      
          if widgets.score_counter.current ~= controller.score then score_anim() end
          widgets.days_counter.text = string.format("NIGHT: %02d", controller.days_in_game - controller.days_passed)
          
          -- update ability buttons
          for i=1, #widgets.ability_all  do 
            if controller.ability_cooldown[widgets.ability_all[i].ability] == nil or controller.ability_cooldown[widgets.ability_all[i].ability].current == 0 then
                widgets.ability_all[i].alpha = 1
                widgets.ability_all[i].isEnabled = true
                widgets.ability_all[i].text.text = ''
            else
                widgets.ability_all[i].alpha = 0.5
                widgets.ability_all[i].isEnabled = false
                widgets.ability_all[i].text.text = string.format("%02d%%", (1 - controller.ability_cooldown[widgets.ability_all[i].ability].current)*100)
            end
          end
    
      else
          widgets.score_counter.current = controller.score
          -- show potential future score
          local add_score = 0
          local max_jobs = controller.buildings_max
          for i=1, #widgets.buildings_all do 
            if widgets.buildings_all[i].isOn then 
              add_score = add_score+controller:build_rate(widgets.buildings_all[i].building)*widgets.buildings_all[i].count 
            end 
          end
          if add_score > 0 then 
              widgets.score_counter:setFillColor(unpack(widgets.score_counter.increase_color)) 
          else 
              widgets.score_counter:setFillColor(unpack(widgets.score_counter.normal_color)) 
          end
          widgets.score_counter.text = string.format( "SCORE: %02d", widgets.score_counter.current + add_score )
          --widgets.buildings_counter.text = string.format("%1d/%1d", jobs_count, max_jobs)
          widgets.days_counter.text = string.format("DAY: %02d", controller.days_in_game - controller.days_passed)
      end
    end
end
-- -----------------------------------------------------------------------------------
-- Scene event functions
-- ----------------------------------------------------------------------------------- 
-- create()
-- Code here runs when the scene is first created but has not yet appeared on screen 
function scene:create( event )
    widgets.view = display.newGroup()
    self.view:insert(widgets.view)
    
    game_background(widgets.view)
    controller = GameController(widgets.view)

    widgets.general = display.newGroup()
    widgets.view:insert(widgets.general)
    widgets.score_counter = score_counter(widgets.general)
    widgets.score_counter.current = 0
    widgets.pause_button = pause_button(pause_game, widgets.general) 
    widgets.timer = timer_bar(widgets.general)
    widgets.days_counter = days_counter(widgets.general)
    
    day_ui()
    night_ui()
    pause_ui()
end 
 
-- show()
function scene:show( event ) 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        controller:reset()
        widgets.end_day.isVisible = global.game_mode == global.game_mode_casual
        widgets.timer.isVisible = controller.is_night or global.game_mode ~= global.game_mode_casual        
        widgets.pause_group.isVisible = false
    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen
        Runtime:addEventListener( "enterFrame", on_enter_frame )  
        if global.preference.getValue(global.preference.is_tutorial) then
            tutorial_1(widgets) 
        end
        audio.setVolume( global.preference.getValue(global.preference.volume), { channel=sound_channel_current} )
        audio.play( sound_day_bg, { channel=sound_channel_current, loops=-1, fadein=100 } )
        -- controls appear animations
        widgets.score_counter.appear()
        widgets.days_counter.appear(50)
        widgets.pause_button.appear()
        --widgets.buildings_counter.appear(50)
        for i=1, #widgets.buildings_all do widgets.buildings_all[i].appear(50*i) end
        if widgets.end_day.isVisible then
          widgets.end_day.appear((1+#widgets.buildings_all)*50)
        end
    end
end
 
function scene:hide( event ) 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        Runtime:removeEventListener( "enterFrame", on_enter_frame )
        -- Code here runs when the scene is on screen (but is about to go off screen) 
    elseif ( phase == "did" ) then
        controller:reset()
        -- Code here runs immediately after the scene goes entirely off screen
    end
end 
 
function scene:destroy( event ) 
    local sceneGroup = self.view
    
    -- clear ui
    widgets = nil

    -- clear game controller
    controller:destroy() 
    controller = nil

    audio.dispose( sound_day_bg )
    audio.dispose( sound_night_bg )
    sound_day_bg = nil
    sound_night_bg = nil
end 
-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------
 
return scene