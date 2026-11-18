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

		function SW.DayNightThink()
			if GetConVarNumber( "sw_func_master" ) != 1 then return end

			SW.Time = tonumber( SW.Time ) or GetConVarNumber( "sw_time_start" ) or 12
			if GetConVarNumber( "sw_time_pause" ) == 0 then
				SW.Time = SW.Time + FrameTime() * 0.01
			end
			if SW.Time >= 24 then SW.Time = 0 end

			if not SW.NextClientUpdate or CurTime() > SW.NextClientUpdate then
				net.Start( "SW.nSetTime" )
				net.WriteFloat( SW.Time )
				net.Broadcast()
				SW.NextClientUpdate = CurTime() + math.max( GetConVarNumber( "sw_perf_updatedelay_client" ) or 1, 1 )
			end
		end
	end )
end
