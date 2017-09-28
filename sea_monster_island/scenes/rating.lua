local pathOfThisFile = ...
local folderOfThisFile = (...):match("(.-)[^%.]+$")

require (folderOfThisFile .. 'ui_controls')

local composer = require( "composer" )  
-- -----------------------------------------------------------------------------------
-- Code below will only be executed ONCE unless "composer.removeScene()" for scene
-- -----------------------------------------------------------------------------------
local scene = composer.newScene()
local widgets = {}
local scene_fade = {effect = "fade", time = 200 }
 
-- -----------------------------------------------------------------------------------
-- Ui callbacks
-- -----------------------------------------------------------------------------------
local function menu( )
    composer.gotoScene( global.scene_menu, scene_fade)
end
-- -----------------------------------------------------------------------------------
-- Scene event functions
-- ----------------------------------------------------------------------------------- 
-- Code here runs when the scene is first created but has not yet appeared on screen
function scene:create( event ) 
    widgets.view = self.view
    widgets.bg = menu_background(widgets.view)
    widgets.button = ratings_button(menu, widgets.view)
end 
 
-- show()
function scene:show( event ) 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)
        widgets.text_group = display.newGroup()
        widgets.view:insert(widgets.text_group)
        local scores = global.preference.getValue(global.preference.highscores)
        for i=1,5 do
            if #scores >= i and scores[i] ~= nil then
                --local text = ratings_text(i, string.format("%s (%.0f)", unpack(scores[i])), widgets.text_group)
                local text = ratings_text(i, string.format("%.0f", scores[i][2]), widgets.text_group) -- temp without name
                text.appear(i*50)
            else
                local text = ratings_text(i, "-", widgets.text_group)
                text.appear(i*50)
            end
        end
        widgets.button.appear(5*50)
    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen
 
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
        widgets.text_group:removeSelf()
        widgets.text_group = nil
    end
end
 
 
-- Code here runs prior to the removal of scene's view
function scene:destroy( event ) 
    local sceneGroup = self.view
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