local pathOfThisFile = ...
local folderOfThisFile = (...):match("(.-)[^%.]+$")

require (folderOfThisFile .. 'ui_controls')

local composer = require( "composer" )  
-- -----------------------------------------------------------------------------------
-- Code below will only be executed ONCE unless "composer.removeScene()" for scene
-- -----------------------------------------------------------------------------------
local scene = composer.newScene()
local widgets = {}
 
-- -----------------------------------------------------------------------------------
-- Ui callbacks
-- -----------------------------------------------------------------------------------
function dialog_close( ... )
    local scene_fade = {effect = "fade", time = 200 }
    composer.gotoScene( global.scene_menu, scene_fade)
end

function save_score( ... ) 
    if global.last_score > 0 then
        global.preference.save_score("", global.last_score+global.win_bonus)
    end
    dialog_close()
end

function dialog_animation( ... )
    -- animate
    widgets.dialog.text.appear(0) 
    widgets.button.appear(50)   
end
-- -----------------------------------------------------------------------------------
-- Scene event functions
-- ----------------------------------------------------------------------------------- 
-- Code here runs when the scene is first created but has not yet appeared on screen
function scene:create( event ) 
    local sceneGroup = self.view

    widgets.view = sceneGroup
    widgets.dialog = results_dialog_text(widgets.view)
    widgets.button = results_dialog_button(save_score, widgets.view)
end
 
 
-- show()
function scene:show( event ) 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        widgets.dialog.text.text = string.format("Your max score was %s\nWin bonus %s", global.last_score, 
       global.win_bonus)
    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen
        dialog_animation()    
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
 
    end
end
 
 
-- Code here runs prior to the removal of scene's view
function scene:destroy( event ) 
    local sceneGroup = self.view
    widgets.global_group:removeSelf()
    widgets = nil
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