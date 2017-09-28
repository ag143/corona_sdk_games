local group
local widgets
local skip = false
local tag = 'tutorial'
local next_tutorial

function skip_current(event)
    if(event.phase == "began" ) then
      skip = true
      transition.cancel( tag )
      next_tutorial()
    end
    return true
end

function tutorial_1(w)
    widgets = w
    
    local myRectangle = display.newRect(0, 0, display.contentWidth, display.contentHeight)
    myRectangle.anchorX=0
    myRectangle.anchorY=0
    myRectangle.blendMode = "multiply" 
    myRectangle:setFillColor(0.5)
    myRectangle:addEventListener( "touch", skip_current)
    myRectangle:addEventListener( "tap", function() return true end)
    group = display.newGroup()
    group:insert(myRectangle)     
    
    skip = false
    next_tutorial = tutorial_2
    
    next_tutorial()
end

function tutorial_2()
    skip = false
    next_tutorial = tutorial_3
    
    local delay = 0
    local mask = graphics.newMask(mask_image_path)
    group:setMask(mask) 
    group.maskX = display.contentCenterX
    group.maskY = display.contentCenterY
    group.maskScaleX = 0.05
    group.maskScaleY = 0.05
    group.isHitTestMasked = false
    transition.to( group, { 
        maskScaleX = 0.5, maskScaleY=0.5, maskX = widgets.score_counter.x + widgets.score_counter.width * 0.9, maskY = widgets.score_counter.y, 
        time=1000, delay=delay, transition=easing.inOutSine, tag = tag} )    
    delay = delay + 1000
    
    group.text = display.newText(
    {
        text = 'THE SCORE\ntry to maximize it by expanding your settlement',
        font = font,
        fontSize = 30,
        align = "center",
        x = display.contentCenterX, y= display.contentCenterY,
    })
    group.text:setFillColor( 1, 1, 1)
    group:insert(group.text) 
    transition.from( group.text, { alpha = 0, delay=delay, time=100, tag = tag, onComplete=next_tutorial } )
end

function tutorial_3()
    skip = false
    next_tutorial = tutorial_4
    
    group.text.alpha = 1
    group.maskX = widgets.score_counter.x+ widgets.score_counter.width * 0.9
    group.maskY = widgets.score_counter.y
    group.maskScaleX = 0.5 
    group.maskScaleY = 0.5
end

function tutorial_4()
    skip = false
    next_tutorial = tutorial_5
    
    local function change_text()
       group.text.text = 'POWER STATIONS\ngive you stronger defence but 0 points'
    end
    local delay = 0    
    transition.to( group.text, { alpha = 0, delay=delay, time=100, tag = tag, onComplete=change_text } )
    delay = delay+100
    
    transition.to( group, { 
        maskScaleX = 0.7, maskScaleY=0.7, maskX = widgets.power_station.x, maskY = widgets.power_station.y, 
        time=1000, delay=delay, transition=easing.inOutSine, tag = tag} ) 
    delay = delay + 1000
    
    transition.from( group.text, { alpha = 0, delay=delay, time=100, tag = tag, onComplete=next_tutorial } )
end

function tutorial_5()
    skip = false
    next_tutorial = tutorial_6    
    
    group.text.alpha = 1
    group.maskX = widgets.power_station.x
    group.maskY = widgets.power_station.y
    group.maskScaleX = 0.7 
    group.maskScaleY = 0.7
end

function tutorial_6()
    skip = false
    next_tutorial = tutorial_7
    
    local function change_text()
       group.text.text = 'HOMES\nhave at least one of them or game will end\n(more profitable buildings are more fragile)'
    end
    local delay = 0    
    transition.to( group.text, { alpha = 0, delay=delay, time=100, tag = tag, onComplete=change_text } )
    delay = delay+100
    
    transition.to( group, { 
        maskScaleX = 0.7, maskScaleY=0.7, maskX = widgets.living_block.x, maskY = widgets.living_block.y, 
        time=1000, delay=delay, transition=easing.inOutSine, tag = tag} ) 
    delay = delay + 1000
    
    transition.from( group.text, { alpha = 0, delay=delay, time=100, tag = tag, onComplete=next_tutorial } )
end

function tutorial_7()
    skip = false
    next_tutorial = tutorial_8    
    
    group.text.alpha = 1
    group.maskX = widgets.living_block.x
    group.maskY = widgets.living_block.y
    group.maskScaleX = 0.7 
    group.maskScaleY = 0.7
end

function tutorial_8()
    skip = false
    next_tutorial = tutorial_9
    
    local function change_text()
       group.text.text = 'NIGHT IS DANGEROUS WITHOUT SATELLITE LASER\ntap the enemy to destroy'
    end
    local delay = 0    
    transition.to( group.text, { alpha = 0, delay=delay, time=100, tag = tag, onComplete=change_text } )
    delay = delay+100
    
    transition.to( group, { 
        maskScaleX = 0.001, maskScaleY=0.001, time=500, delay=delay, transition=easing.inOutSine, tag = tag} ) 
    delay = delay + 500
    
    transition.from( group.text, { alpha = 0, delay=delay, time=100, tag = tag, onComplete=next_tutorial } )
end

function tutorial_9()
    skip = false
    next_tutorial = tutorial_clear    
    
    group.text.alpha = 1
    group.maskX = widgets.living_block.x
    group.maskY = widgets.living_block.y
    group.maskScaleX = 0.01
    group.maskScaleY = 0.01
end

function tutorial_clear()
    group:removeSelf()
    group = nil    
    global.preference.save{tutorial=false}
end