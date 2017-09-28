spritesheet_game_options =
{
    --required parameters
    width = 75,
    height = 75,
    numFrames = 28,
     
    --optional parameters; used for scaled content support
    sheetContentWidth = 300,  -- width of original 1x size of entire sheet
    sheetContentHeight = 525   -- height of original 1x size of entire sheet
}

local game_tile_visible = 10
local game_tile_size = math.min(display.contentWidth, display.contentHeight)/game_tile_visible
spritesheet_game_options.scale = math.round(game_tile_size * 100 / spritesheet_game_options.width)/100

spritesheet_ui_options = 
{
    frames={
      { x = 0, y = 0, width = 256, height = 64 }, -- button
      { x = 0, y = 65, width = 252, height = 60 }, -- button_on
      { x = 65, y = 321, width = 64, height = 64 }, -- pause
      { x = 0, y = 386, width = 64, height = 64 }, -- pause_on      
      { x = 253, y = 65, width = 64, height = 64 }, -- energy
      { x = 193, y = 130, width = 64, height = 64 }, -- energy_on
      { x = 388, y = 130, width = 64, height = 64 }, -- home
      { x = 0, y = 256, width = 64, height = 64 }, -- home_on
      { x = 99, y = 196, width = 32, height = 32 }, -- settings
      { x = 162, y = 130, width = 32, height = 32 }, -- settings on
      { x = 0, y = 321, width = 64, height = 64 }, -- music
      { x = 65, y = 256, width = 64, height = 64 }, -- music_on

      { x = 0, y = 126, width = 192/3, height = 64 }, -- progress int
      { x = 192/3, y = 126, width = 192/3, height = 64 }, -- progress int
      { x = 192/3*2, y = 126, width = 192/3, height = 64 }, -- progress int
      { x = 0, y = 191, width = 192/3, height = 64 }, -- progress out
      { x = 192/3, y = 191, width = 192/3, height = 64 }, -- progress out
      { x = 192/3*2, y = 191, width = 192/3, height = 64 }, -- progress out
      
      { x = 325, y = 195, width = 64, height = 64 }, -- star 19
      { x = 260, y = 260, width = 64, height = 64 }, -- star_on
      { x = 195, y = 195, width = 64, height = 64 }, -- question
      { x = 65, y = 386, width = 64, height = 64 }, -- question_on
      { x = 130, y = 256, width = 64, height = 64 }, -- play
      { x = 130, y = 321, width = 64, height = 64 }, -- play_on
      { x = 318, y = 65, width = 64, height = 64 }, -- farm
      { x = 258, y = 130, width = 64, height = 64 }, -- farm_on 26
      
      { x = 257, y = 0, width = 192/3, height = 64 }, -- progress_inner_energy
      { x = 257 + 192 / 3, y = 0, width = 192/3, height = 64 }, -- progress_inner_energy
      { x = 257 + 192/3*2, y = 0, width = 192/3, height = 64 }, -- progress_inner_energy
      
      { x = 383, y = 65, width = 64, height = 64 }, -- fire 30
      { x = 323, y = 130, width = 64, height = 64 }, -- fire_on
      { x = 195, y = 260, width = 64, height = 64 }, -- repair
      { x = 260, y = 195, width = 64, height = 64 }, -- repair_on
      { x = 130, y = 386, width = 64, height = 64 }, -- shield
      { x = 195, y = 325, width = 64, height = 64 }, -- shield_on
  },
  --optional parameters; used for scaled content support
    sheetContentWidth = 512,
    sheetContentHeight = 512,
}
--[[
spritesheet_ui_options.frameIndex =
{

    ["green_boxCheckmark"] = 1,
    ["green_boxCross"] = 2,
    ["green_boxTick"] = 3,
}]]--

spritesheet_game = graphics.newImageSheet("assets/art/game.png", spritesheet_game_options )
spritesheet_ui = graphics.newImageSheet("assets/art/ui.png", spritesheet_ui_options )
mask_image_path = "assets/art/circle.png"
game_bg = "assets/art/game_bg.png"
font = "assets/ComicRelief.ttf"

sound_menu = "assets/sound/looperman-l-2247732-0111557-hbsamples-hbs-80s-synth-loop-a-sharp-120bpm.wav"
sound_day = "assets/sound/looperman-l-1319133-0111190-fanto8bc-venezia.wav"
sound_night = "assets/sound/looperman-l-1319133-0111043-fanto8bc-iron-man.wav"