if SERVER then
	timer.Simple( 0, function()
		if not SW then return end

		local function safeLightStyle( value, fallback )
			local conversion = {
				[1] = "a", [2] = "b", [3] = "c", [4] = "d", [5] = "e", [6] = "f",
				[7] = "g", [8] = "h", [9] = "i", [10] = "j", [11] = "k", [12] = "l",
				[13] = "m", [14] = "n", [15] = "o", [16] = "p", [17] = "q", [18] = "r",
				[19] = "s", [20] = "t", [21] = "u", [22] = "v", [23] = "w", [24] = "x",
				[25] = "y", [26] = "z"
			}
			local n = tonumber( value )

			if n then
				return conversion[math.Clamp( math.Round( n ), 1, 26 )] or fallback
			end

			if isstring( value ) and value != "" then
				return value
			end

			return fallback
		end

		SW_LIGHT_DAY = safeLightStyle( GetConVarNumber( "sw_light_day_brightness" ), "y" )
		SW_LIGHT_NIGHT = safeLightStyle( GetConVarNumber( "sw_light_night_brightness" ), "b" )
		SW_LIGHT_STORM = safeLightStyle( GetConVarNumber( "sw_light_storm_brightness" ), "j" )
	end )
end
