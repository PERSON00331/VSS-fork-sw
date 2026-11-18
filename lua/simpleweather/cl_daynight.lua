
AddCSLuaFile()

SW_TIME_DAWN = 6
SW_TIME_AFTERNOON = 12
SW_TIME_DUSK = 18
SW_TIME_NIGHT = 20

SW_TIME_WEATHER = 1
SW_TIME_WEATHER_NIGHT = 2
SW_TIME_FOG = 3

SW.CurFogDensity = 1

SW.Time = GetConVarNumber("sw_time_start")
if SW.Time == -1 then

	SW.Time = math.Rand( 0 , 23 )

end

local function GetDaylightFactor( time )

	if time < SW_TIME_DAWN - 2 or time >= SW_TIME_DUSK + 2 then
		return 0
	elseif time < SW_TIME_DAWN then
		return ( time - ( SW_TIME_DAWN - 2 ) ) / 2
	elseif time >= SW_TIME_DUSK then
		return 1 - ( time - SW_TIME_DUSK ) / 2
	end

	return 1

end

local function GetFogBrightness()

	return Lerp( GetDaylightFactor( SW.Time or 0 ), 0.2, 1 )

end

function SW.nInitFogSettings( len )

	SW.FogSettings = { }

	SW.FogSettings["FogStart"] = net.ReadUInt( 32 )
	SW.FogSettings["FogEnd"] = net.ReadUInt( 32 )
	SW.FogSettings["MaxDensity"] = net.ReadFloat()
	SW.FogSettings["r"] = net.ReadUInt( 8 )
	SW.FogSettings["g"] = net.ReadUInt( 8 )
	SW.FogSettings["b"] = net.ReadUInt( 8 )

end
net.Receive( "SW.nInitFogSettings", SW.nInitFogSettings )

function SW.nInitSkyboxFogSettings( len )

	SW.SkyboxFogSettings = { }

	SW.SkyboxFogSettings["FogStart"] = net.ReadUInt( 32 )
	SW.SkyboxFogSettings["FogEnd"] = net.ReadUInt( 32 )
	SW.SkyboxFogSettings["MaxDensity"] = net.ReadFloat()
	SW.SkyboxFogSettings["r"] = net.ReadUInt( 8 )
	SW.SkyboxFogSettings["g"] = net.ReadUInt( 8 )
	SW.SkyboxFogSettings["b"] = net.ReadUInt( 8 )

end
net.Receive( "SW.nInitSkyboxFogSettings", SW.nInitSkyboxFogSettings )

function SW.nSetTime( len )

	SW.Time = net.ReadFloat()

	if( !system.HasFocus() ) then

		SW.RequiresLightRefresh = true

	elseif( SW.RequiresLightRefresh ) then

		SW.RequiresLightRefresh = false

		timer.Simple( 1, function()
			render.RedownloadAllLightmaps()
		end )

	end

end
net.Receive( "SW.nSetTime", SW.nSetTime )

function SW.DayNightThink()

	-- If SimpleWeather is disabled...
	if GetConVarNumber("sw_func_master") != 1 then return end

	if( !system.HasFocus() ) then

		SW.RequiresLightRefresh = true

	elseif( SW.RequiresLightRefresh ) then

		SW.RequiresLightRefresh = false
		render.RedownloadAllLightmaps()

	end

	if( GetConVarNumber("sw_func_fog") == 0 ) then return end
	if( !SW.Time ) then return end

	local targetDensity = Lerp(
		GetDaylightFactor( SW.Time ),
		GetConVarNumber("sw_fog_densitynight"),
		GetConVarNumber("sw_fog_densityday")
	)

	if( GetConVarNumber("sw_fog_indoors") == 0 and !SW.IsOutsideFrame ) then

		SW.CurFogDensity = math.Approach( SW.CurFogDensity, 0, GetConVarNumber("sw_fog_speed") )

	elseif( SW.SkyboxVisible ) then

		SW.CurFogDensity = math.Approach( SW.CurFogDensity, targetDensity, GetConVarNumber("sw_fog_speed") )

	end

end

function SW.SetupWorldFog()

	-- If SimpleWeather is disabled...
	if GetConVarNumber("sw_func_master") != 1 then return end

	if( SW.GetCurrentWeather().FogColor ) then
		
		local w = SW.GetCurrentWeather()
		
		render.FogMode( MATERIAL_FOG_LINEAR )
		render.FogStart( w.FogStart )
		render.FogEnd( w.FogEnd )
		render.FogMaxDensity( w.FogMaxDensity * SW.CurFogDensity )
		
		local c = w.FogColor
		local brightness = GetFogBrightness()
		
		render.FogColor( c.r * brightness, c.g * brightness, c.b * brightness )
		
	else
		
		if( !SW.FogSettings or SW.CurFogDensity == 1 ) then return false end
		
		render.FogMode( MATERIAL_FOG_LINEAR )
		render.FogStart( SW.FogSettings["FogStart"] )
		render.FogEnd( SW.FogSettings["FogEnd"] )
		render.FogMaxDensity( SW.CurFogDensity * SW.FogSettings["MaxDensity"] )
		local brightness = GetFogBrightness()
		render.FogColor(
			SW.FogSettings["r"] * brightness,
			SW.FogSettings["g"] * brightness,
			SW.FogSettings["b"] * brightness
		)
		
	end
	
	return true
	
end
hook.Add( "SetupWorldFog", "SW.SetupWorldFog", SW.SetupWorldFog )

function SW.SetupSkyboxFog( scale )

	-- If SimpleWeather is disabled...
	if GetConVarNumber("sw_func_master") != 1 then return end

	if( SW.GetCurrentWeather().FogColor ) then
		
		local w = SW.GetCurrentWeather()
		
		render.FogMode( MATERIAL_FOG_LINEAR )
		render.FogStart( 0 )
		render.FogEnd( 10 )
		render.FogMaxDensity( w.FogMaxDensity * SW.CurFogDensity )
		
		local c = w.FogColor
		local brightness = GetFogBrightness()
		
		render.FogColor( c.r * brightness, c.g * brightness, c.b * brightness )
		
	elseif( SW.FogSettings ) then
		
		if( !SW.SkyboxFogSettings or SW.CurFogDensity == 1 ) then return false end
		
		render.FogMode( MATERIAL_FOG_LINEAR )
		render.FogStart( SW.SkyboxFogSettings["FogStart"] )
		render.FogEnd( SW.SkyboxFogSettings["FogEnd"] )
		render.FogMaxDensity( SW.CurFogDensity * SW.SkyboxFogSettings["MaxDensity"] )
		local brightness = GetFogBrightness()
		render.FogColor(
			SW.SkyboxFogSettings["r"] * brightness,
			SW.SkyboxFogSettings["g"] * brightness,
			SW.SkyboxFogSettings["b"] * brightness
		)
		
	end
	
	return true
	
end
hook.Add( "SetupSkyboxFog", "SW.SetupSkyboxFog", SW.SetupSkyboxFog )