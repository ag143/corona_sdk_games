--
-- For more information on config.lua see the Project Configuration Guide at:
-- https://docs.coronalabs.com/guide/basics/configSettings
--

--calculate the aspect ratio of the device:
local aspectRatio = display.pixelHeight / display.pixelWidth
--width = aspectRatio > 1.5 and 640 or math.ceil( 960 / aspectRatio ),
--height = aspectRatio < 1.5 and 960 or math.ceil( 640 * aspectRatio ),

application =
{
	content =
	{
		width = 563,   --768
		height = 1000, --1024
		scale = "letterbox",
		fps = 30,
		
		--[[
		imageSuffix =
		{
			    ["@2x"] = 2,
			    ["@4x"] = 4,
		},
		--]]
	},
}
