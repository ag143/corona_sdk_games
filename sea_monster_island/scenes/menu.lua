local pathOfThisFile = ...
local folderOfThisFile = (...):match("(.-)[^%.]+$")

require (folderOfThisFile .. 'ui_controls')

local composer = require( "composer" ) 
local scene = composer.newScene()
 
-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local widgets = {}
local scene_fade = {effect = "fade", time = 200 }
local sound_bg = audio.loadStream( sound_menu )
local sound_bg_chanel = 1

-- -----------------------------------------------------------------------------------
-- Callbacks
-- -----------------------------------------------------------------------------------
local function start_game( ... )
    composer.gotoScene( global.scene_game, scene_fade)
    audio.fadeOut({ channel=sound_bg_chanel, time=100 } )
    audio.stopWithDelay( 100, { channel=sound_bg_chanel } )
end

local function unlock_animation( ... )
    global.preference.save{is_menu_unlocked=true}
    widgets.normal.unlock(50)
    widgets.hard.unlock(50*2)
end

local function appear_animation( all )
    widgets.casual.appear(0)
    if all then
        widgets.normal.appear(50)
        widgets.hard.appear(50*2)
    end
    widgets.sound.appear(50)
    widgets.scores.appear(50*2)
end

local function start_casual( event ) 
    global.game_mode = global.game_mode_casual
    start_game()
end 

local function start_normal( event ) 
    global.game_mode = global.game_mode_normal
    start_game()
end 

local function start_hard( event ) 
    global.game_mode = global.game_mode_hard
    start_game()
end 

local function show_scores ( ... )
    composer.gotoScene( global.scene_rating, scene_fade)
end

local function sound_setting( event )
    local switch = event.target
    if switch.isOn then
        global.preference.save{volume=0.5}
    else
        global.preference.save{volume=0}
    end
    audio.setVolume( global.preference.getValue(global.preference.volume), { channel=sound_bg_chanel} )
end 
-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
-- Code here runs when the scene is first created but has not yet appeared on screen
function scene:create( event )    
    widgets.view = self.view
    widgets.bg = menu_background(widgets.view)
    widgets.casual = menu_button_1(start_casual, widgets.view)
    widgets.sound = sound_button(sound_setting, widgets.view)
    widgets.sound:setState({ isOn=global.preference.getValue(global.preference.volume)>0 })
    widgets.scores = scores_button(show_scores, widgets.view)
end
 
 
-- show()
function scene:show( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)
        local active = false
        if global.preference.getValue(global.preference.is_menu_unlocked) or global.preference.getValue(global.preference.menu_unlock_anim) then
            active = true
        end  
        widgets.temp_group = display:newGroup()
        widgets.view:insert(widgets.temp_group)
        widgets.normal = menu_button_2(start_normal,widgets.temp_group, active)
        widgets.hard = menu_button_3(start_hard, widgets.temp_group, active)
 
    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen
        audio.setVolume( global.preference.getValue(global.preference.volume), { channel=sound_bg_chanel} )
        audio.play( sound_bg, { channel=sound_bg_chanel, loops=-1, fadein=100 } )
        -- unlock buttons animation
        if not global.preference.getValue(global.preference.is_menu_unlocked) and global.preference.getValue(global.preference.menu_unlock_anim) then
            unlock_animation()
            appear_animation(false)
        else
            appear_animation(true)
        end
    end
end
 
 
-- hide()
function scene:hide( event ) 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is on screen (but is about to go off screen) 
    elseif ( phase == "did" ) then
        -- Code here runs immediately after the scene goes entirely off screen 
        widgets.temp_group:removeSelf()
        widgets.temp_group = nil
    end
end
 
 
-- Code here runs prior to the removal of scene's view
function scene:destroy( event )
    widgets = nil
    audio.dispose( sound_bg )
    sound_bg = nil
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