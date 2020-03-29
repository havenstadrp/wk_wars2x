local DATASAVE = {}
DATASAVE.dir = "logs"

-- Change this to whatever ID type you want to use for saving user data 
-- Options are:
--  - steam
--  - license
--  - xbl 
--  - live
--  - discord
--  - fivem
--  - ip 
DATASAVE.idType = "steam"

-- Saves the data for the given player into the saves folder within the resource
function DATASAVE:SavePlayerData( src, data )
	-- Get the player's identifier
    local id = self:GetIdentifier( src )
    
    local rawData = LoadResourceFile( GetCurrentResourceName(), self.dir .. "/" .. id .. ".json" )

    if ( rawData ~= nil ) then 
        local fileData = json.decode( rawData )

        table.insert( fileData, data )

        -- Save the JSON file into the saves folder
        SaveResourceFile( GetCurrentResourceName(), self.dir .. "/" .. id .. ".json", json.encode( fileData ), -1 )
        
        -- Print out a message in the console to say the player's UI data has been saved
        self:Print( "Saved logs for " .. GetPlayerName( src ) .. " (ID: " .. src .. ")" )
    else 
        -- Save the JSON file into the saves folder
        SaveResourceFile( GetCurrentResourceName(), self.dir .. "/" .. id .. ".json", json.encode( data ), -1 )
        
        -- Print out a message in the console to say the player's UI data has been saved
        self:Print( "Saved logs for " .. GetPlayerName( src ) .. " (ID: " .. src .. ")" )
    end 
end 

-- Gets the identifier for the given player based on the identifier type specified at the top 
function DATASAVE:GetIdentifier( src )
	-- Get the number of identifiers the player has
	local max = GetNumPlayerIdentifiers( src )

	-- Iterate through the identifier numerical range 
	for i = 0, max do
		-- Get the current identifier 
		local id = GetPlayerIdentifier( src, i )

		-- In the event the identifier is nil, report it to the server console and return nil 
		if ( id == nil ) then 
			self:Print( "^1It appears there was an error trying to find the specified ID (" .. self.idType .. ") for player " .. GetPlayerName( source ) )
			return nil
		end 
		
		-- If we find the identifier type set in DATASAVE.idType, then we have the identifier
		if ( string.find( id, self.idType, 1 ) ) then 
			-- Split the identifier so we just get the actual identifier
			local split = self:SplitString( id, ":" )

			-- Return the identifier
			return split[2]
		end 
	end 

	-- In the event we get nothing, return nil 
	return nil
end  

-- Your typical split string function! 
function DATASAVE:SplitString( inputstr, sep )
	if ( sep == nil ) then
		sep = "%s"
	end

	local t = {}
	local i = 1
	
	for str in string.gmatch( inputstr, "([^" .. sep .. "]+)" ) do
		t[i] = str
		i = i + 1
	end

	return t
end

-- Prints the given message with the resource name attached
function DATASAVE:Print( msg )
	print( "^3[wk_wars2x] ^0" .. msg .. "^0" )
end 

-- Serverside event for saving a player's UI data
RegisterServerEvent( "wk:logVehDebugData" )
AddEventHandler( "wk:logVehDebugData", function( data ) 
	if ( type( data ) == "table" ) then 
		DATASAVE:SavePlayerData( source, data )
	else 
		DATASAVE:Print( "^1Log data being sent from " .. GetPlayerName( source ) .. " (ID: " .. source .. ") is not valid." )
	end 
end ) 