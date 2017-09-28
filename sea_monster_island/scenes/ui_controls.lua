local atlas = spritesheet_ui
local frames = spritesheet_ui_options.frames
local widget = require( "widget" )
local border_padding = 10
local scale = 1.2
local bg_color = {0, 176/255, 226/255}
local active_color = { 149/255, 21/255, 0 } 
local unactive_color = { 244/255, 227/255, 147/255 }
local active_color_light = { 220/255, 30/255, 0 }

function image_button_scaled(default_frame, over_frame, callback, group, scale)
    local frame = frames[default_frame]
    local button
    button = widget.newButton(
    {
        sheet = atlas,
        defaultFrame = default_frame,
        overFrame = over_frame,
        onPress = callback,
        width = frame.width,
        height = frame.height,
        fontSize = 25,
        font = font,
        labelColor = { default=active_color, over=active_color }
    })
    local function appear_anim( delay )
        if delay == nil then delay = 0 end 
        transition.to( button, { xScale = scale * 1.1, yScale=scale * 1.1, time=80, delay = delay, transition=easing.inSine} ) 
        transition.to( button, { xScale = scale, yScale=scale, time=80, delay=delay + 80, transition=easing.outSine } ) 
    end
    button.appear = appear_anim
    button.xScale = scale
    button.yScale = scale
    if group ~= nil then group:insert(button) end
    return button
end

function image_button(default_frame, over_frame, callback, group, active)
    local frame = frames[default_frame]
    local button
    if active or active == nil then
        button = widget.newButton(
        {
            sheet = atlas,
            defaultFrame = default_frame,
            overFrame = over_frame,
            onPress = callback,
            width = frame.width,
            height = frame.height,
            fontSize = 25,
            font = font,
            labelColor = { default=active_color, over=active_color }
        })
        local function unlock_anim( delay )
            button.alpha = 0.8
            if delay == nil then delay = 0 end 
            transition.to( button, { xScale = scale * 1.1, yScale=scale * 1.1, time=80, delay = delay, transition=easing.inSine} ) 
            transition.to( button, { alpha = 1, xScale = scale, yScale=scale, time=80, delay= delay + 80, transition=easing.outSine } ) 
        end
        button.unlock = unlock_anim
        local function appear_anim( delay )
            if delay == nil then delay = 0 end 
            transition.to( button, { xScale = scale * 1.1, yScale=scale * 1.1, time=80, delay = delay, transition=easing.inSine} ) 
            transition.to( button, { xScale = scale, yScale=scale, time=80, delay=delay + 80, transition=easing.outSine } ) 
        end
        button.appear = appear_anim
    else
        button = widget.newButton(
        {
            sheet = atlas,
            defaultFrame = default_frame,
            overFrame = over_frame,
            width = frame.width,
            height = frame.height,
            fontSize = 25,
            font = font,
            labelColor = { default=unactive_color, over=unactive_color }
        })
        button.alpha = 0.8
        local function appear_anim( delay )
            if delay == nil then delay = 0 end 
            transition.to( button, { xScale = scale * 1.1, yScale=scale * 1.1, time=80,delay = delay,  transition=easing.inSine} ) 
            transition.to( button, { xScale = scale, yScale=scale, time=80, delay=delay + 80, transition=easing.outSine } ) 
        end
        button.appear = appear_anim
    end
    button.xScale = scale
    button.yScale = scale
    if group ~= nil then group:insert(button) end
    return button
end

function toggle_button(frame_on, frame_off, callback, group)
    local frame = frames[frame_on]
    local button = widget.newSwitch(
    {
        sheet = atlas,
        frameOn = frame_on,
        frameOff = frame_off,
        style = "checkbox",
        onPress = callback,
        width = frame.width,
        height = frame.height,
    })
    button.xScale = scale
    button.yScale = scale
    local function appear_anim( delay )
        if delay == nil then delay = 0 end 
        transition.to( button, { xScale = scale * 1.1, yScale=scale * 1.1, time=80,delay = delay, transition=easing.inSine} ) 
        transition.to( button, { xScale = scale, yScale=scale, time=80, delay=delay +80, transition=easing.outSine } ) 
    end
    button.appear = appear_anim
    if group ~= nil then group:insert(button) end
    return button
end
-----------------------------------------------------------------------------------
function menu_button_1(callback, group)
    local button = image_button(1, 2, callback, group)
    button.x, button.y = display.contentCenterX, display.contentCenterY - button.height*button.xScale - border_padding   
    button:setLabel('CASUAL')
    return button
end
function menu_button_2(callback, group, active)
    local button = image_button(1, 2, callback, group, active)
    button.x, button.y = display.contentCenterX, display.contentCenterY
    button:setLabel('NORMAL')
    return button
end
function menu_button_3(callback, group, active)
    local button = image_button(1, 2, callback, group, active)
    button.x, button.y = display.contentCenterX, display.contentCenterY + button.height*button.xScale + border_padding
    button:setLabel('HARD')
    return button
end

function sound_button(callback, group)
    local button = toggle_button(12, 11, callback, group)
    button.x, button.y = display.contentWidth - border_padding - button.width * button.xScale* 0.5, button.height * button.yScale* 0.5 + border_padding
    return button
end

function scores_button(callback, group)
    local button = image_button(19, 20, callback, group)
    button.x, button.y = display.contentWidth - border_padding - button.width * button.xScale* 0.5, button.height * button.yScale* 0.5 + button.height + border_padding * 3
    return button
end
-----------------------------------------------------------------------------------
function pause_button(callback, group)
    local button = image_button(3,3, callback, group)    
    button.anchorX, button.anchorY = 1, 0
    button.x, button.y = display.contentWidth - border_padding, border_padding
    return button
end

function pause_dialog(callback, group, exit_callback)  
    local function appear(target, complete_callback)
      local delay = 0
      target.alpha = 0
      transition.to( target, { alpha = 1, time=50, delay=delay, transition=easing.inSine} ) 
      target.button2.appear(50)
    end
    
    local function hide(target, complete_callback)
      local delay = 0
      transition.to( target, { alpha = 0, time=80, delay=delay, transition=easing.outSine, onComplete = complete_callback} ) 
    end
    
    local fontSize = 50
    local obj = display.newRect(display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight)
    obj:setFillColor(unpack(bg_color))
    obj.animation_appear = appear
    obj.animation_hide = hide   
    if group ~= nil then group:insert(obj) end
    
    local button1 = image_button(4,4, callback, group)    
    button1.anchorX, button1.anchorY = 1, 0
    button1.x, button1.y = display.contentWidth - border_padding, border_padding
    
    obj.button2 = image_button(1,2, exit_callback, group)
    obj.button2.x, obj.button2.y = display.contentCenterX, display.contentHeight - border_padding - obj.button2.height * obj.button2.yScale
    obj.button2:setLabel('MENU')
    return obj
end

function build_button_label( button, group )
    local fontSize = 40
    local obj = display.newText(
    {
        text = "",
        align = "center",
        x = button.x - button.width, 
        y = button.y,
        font = font,
        fontSize = fontSize,
    })
    obj:setFillColor(unpack(active_color))
    if group ~= nil then group:insert(obj) end
    return obj
end

function build_button_1(callback, group)
    local button = toggle_button(6, 5, callback, group)
    button.x = display.contentWidth-border_padding-button.width*button.xScale*0.5
    button.y = display.contentHeight * 0.5 - button.height * button.yScale*1 - border_padding
    button.count = 0
    button.isEnabled = true
    button.text = build_button_label(button, group)
    return button
end

function build_button_2(callback, group)
    local button = toggle_button(8, 7, callback, group)
    button.x = display.contentWidth-border_padding-button.width*button.xScale*0.5 
    button.y = display.contentHeight * 0.5
    button.count = 0
    button.isEnabled = true
    button.text = build_button_label(button, group)
    return button
end

function build_button_3(callback, group)
    local button = toggle_button(26, 25, callback, group)
    button.x = display.contentWidth-border_padding-button.width*button.xScale*0.5 
    button.y = display.contentHeight * 0.5 + button.height * button.yScale + border_padding
    button.count = 0
    button.isEnabled = true
    button.text = build_button_label(button, group)
    return button
end

function ability_button_label( button, group )
    local fontSize = 25
    local obj = display.newText(
    {
        text = "",
        align = "center",
        x = button.x - button.width, 
        y = button.y,
        font = font,
        fontSize = fontSize,
    })
    obj:setFillColor(unpack(active_color))
    if group ~= nil then group:insert(obj) end
    return obj
end

function ability_button_1(callback, group)
    local button = image_button(30, 31, callback, group)
    button.x = display.contentWidth-border_padding-button.width*button.xScale*0.5
    button.y = display.contentHeight * 0.5 - button.height * button.yScale*1 - border_padding
    button.count = 0
    button.isEnabled = true
    button.text = ability_button_label(button, group)
    return button
end

function ability_button_3(callback, group)
    local button = image_button(34, 35, callback, group)
    button.x = display.contentWidth-border_padding-button.width*button.xScale*0.5 
    button.y = display.contentHeight * 0.5
    button.count = 0
    button.isEnabled = true
    button.text = ability_button_label(button, group)
    return button
end

function ability_button_2(callback, group)
    local button = image_button(32, 33, callback, group)
    button.x = display.contentWidth-border_padding-button.width*button.xScale*0.5 
    button.y = display.contentHeight * 0.5 + button.height * button.yScale + border_padding
    button.count = 0
    button.isEnabled = true
    button.text = ability_button_label(button, group)
    return button
end

function energy_bar(group)
    local height = 20
    local obj = widget.newProgressView(
    { 
        sheet = atlas,  
        fillOuterLeftFrame = 13,
        fillOuterMiddleFrame = 14,
        fillOuterRightFrame = 15,
        fillInnerLeftFrame = 27,
        fillInnerMiddleFrame = 28,
        fillInnerRightFrame = 29,
        fillOuterWidth = height,
        fillOuterHeight = height,
        fillWidth = height,
        fillHeight = height,
        width = 500, 
    })    
    obj.x, obj.y =  display.contentCenterX , display.contentHeight - height*2 - border_padding * 2
    obj:setProgress(1)
    if group ~= nil then group:insert(obj) end
    return obj
end

function timer_bar(group)
    local height = 20
    local obj = widget.newProgressView(
    { 
        sheet = atlas,  
        fillOuterLeftFrame = 13,
        fillOuterMiddleFrame = 14,
        fillOuterRightFrame = 15,
        fillInnerLeftFrame = 16,
        fillInnerMiddleFrame = 17,
        fillInnerRightFrame = 18,
        fillOuterWidth = height,
        fillOuterHeight = height,
        fillWidth = height,
        fillHeight = height,
        width = 500, 
    })    
    obj:setProgress(1)
    obj.x, obj.y =  display.contentCenterX , display.contentHeight - height - border_padding
    if group ~= nil then group:insert(obj) end
    return obj
end

function end_day_button(callback, group)
    local button = image_button_scaled(23,24, callback, group, scale * 1.4)
    button.x, button.y = border_padding, display.contentHeight - border_padding
    button.anchorX, button.anchorY = 0, 1
    return button
end

function days_counter( group )
    local fontSize = 40
    local obj = display.newText(
    {
        text = '0',
        align = "center",
        x = border_padding, 
        y = border_padding + fontSize*1.5,
        font = font,
        fontSize = fontSize,
    })
    obj.normal_color = unactive_color
    obj.increase_color = active_color
    local function appear_anim( delay )
        if delay == nil then delay = 0 end 
        transition.to( obj, { xScale = 1.1, yScale= 1.1, time=80,delay = delay, transition=easing.inSine} ) 
        transition.to( obj, { xScale = 1, yScale=1, time=80, delay=delay +80, transition=easing.outSine } ) 
    end
    obj:setFillColor(unpack(obj.increase_color)) 
    obj.appear = appear_anim 
    obj.anchorX = 0
    if group ~= nil then group:insert(obj) end
    return obj
end

function buildings_counter( group )
    local fontSize = 40
    local obj = display.newText(
    {
        text = '0',
        align = "center",
        x = display.contentWidth-border_padding-75*0.5, 
        y = display.contentHeight * 0.5 - 75 * 1.5 - border_padding,
        font = font,
        fontSize = fontSize,
    })
    obj.normal_color = unactive_color
    obj.increase_color = active_color
    local function appear_anim( delay )
        if delay == nil then delay = 0 end 
        transition.to( obj, { xScale = 1.1, yScale= 1.1, time=80,delay = delay, transition=easing.inSine} ) 
        transition.to( obj, { xScale = 1, yScale=1, time=80, delay=delay +80, transition=easing.outSine } ) 
    end
    obj:setFillColor(unpack(obj.increase_color)) 
    obj.appear = appear_anim
    if group ~= nil then group:insert(obj) end
    return obj
end

function score_counter( group )
    local fontSize = 40
    local obj = display.newText(
    {
        text = 'SCORE: 00',
        align = "center",
        x = border_padding, 
        y = border_padding + fontSize*0.5,
        font = font,
        fontSize = fontSize,
    })
    obj.normal_color = active_color
    obj.increase_color = active_color_light
    local function appear_anim( delay )
        if delay == nil then delay = 0 end 
        transition.to( obj, { xScale = 1.2, yScale= 1.2, time=80,delay = delay, transition=easing.inSine} ) 
        transition.to( obj, { xScale = 1, yScale=1, time=80, delay=delay +80, transition=easing.outSine } ) 
    end 
    obj.anchorX = 0
    obj:setFillColor(unpack(obj.increase_color))
    obj.appear = appear_anim
    if group ~= nil then group:insert(obj) end
    return obj
end

function game_background(group)
    local obj = display.newImage(game_bg, display.contentCenterX, display.contentCenterY)
    if group ~= nil then group:insert(obj) end
    return obj
end

function menu_background(group)
    local obj = display.newRect(display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight)
    obj:setFillColor(unpack(bg_color))
    if group ~= nil then group:insert(obj) end
    return obj
end

function ratings_text( number, text, group )
    local fontSize = 50
    local obj = display.newText(
    {
        text = number .. ". " .. text,
        align = "left",
        font = font,
        fontSize = fontSize,
        x = display.contentWidth*0.4, y = number * fontSize + (number - 1) * border_padding,
    })
    local function appear_anim( delay )
        if delay == nil then delay = 0 end 
        transition.to( obj, { xScale = 1.2, yScale= 1.2, time=80, delay = delay, transition=easing.inSine} ) 
        transition.to( obj, { xScale = 1, yScale=1, time=80, delay=delay + 80, transition=easing.outSine } ) 
    end
    obj.appear = appear_anim
    obj.anchorX, obj.anchorY = 0, 0.5
    obj:setFillColor(unpack(unactive_color)) 
    if group ~= nil then group:insert(obj) end
    return obj
end

function ratings_button(callback, group)
    local button = image_button(1, 2, callback, group)
    button.x, button.y = display.contentCenterX, display.contentHeight - button.height*button.xScale - border_padding   
    button:setLabel('RETURN')
    return button
end

function results_dialog_text( group )
    local obj = menu_background(group)
    local fontSize = 50
    obj.text = display.newText(
    {
        text = '',
        align = "center",
        font = font,
        fontSize = fontSize,
        x = display.contentCenterX, y=display.contentCenterY - fontSize
    })
    local function appear_anim( delay )
        if delay == nil then delay = 0 end 
        transition.to( obj.text, { xScale = 1.1, yScale= 1.1, time=80, delay = delay, transition=easing.inSine} ) 
        transition.to( obj.text, { xScale = 1, yScale=1, time=80, delay=delay + 80, transition=easing.outSine } ) 
    end
    obj.text.appear = appear_anim
    obj.text:setFillColor(unpack(unactive_color)) 
    if group ~= nil then group:insert(obj) end
    if group ~= nil then group:insert(obj.text) end
    return obj
end

function results_dialog_button(callback, group)
    local button = image_button(1,2, callback, group)
    button.x, button.y = display.contentCenterX, display.contentHeight - button.height*button.xScale - border_padding  
    button:setLabel('SAVE')
    if group ~= nil then group:insert(button) end
    return button
end