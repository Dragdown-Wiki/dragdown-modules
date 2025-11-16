local p = {}
local mArguments
local cargo = mw.ext.cargo
local cache = {}

local tabber = require( 'Module:Tabber' ).renderTabber
local splitString = require( 'Module:SplitStringToTable' ).splitStringIntoTable
local list = require( 'Module:List' ).makeList

local function dump(o)
	if type(o) == "table" then
		local s = "{ "
		for k, v in pairs(o) do
			if type(k) ~= "number" then
				k = '"' .. k .. '"'
			end
			s = s .. "[" .. k .. "] = " .. dump(v) .. ","
		end
		return s .. "} "
	else
		return tostring(o)
	end
end


local function added_traits(row, search, value, trait, custom)
	if trait == "RollSpeed" or trait == "LedgeStandSpeed" or trait == "LedgeRollSpeed" or trait == "GetupRollSpeed" or trait == "TechRollSpeed" then
		if custom then
			row:tag('td'):wikitext("N/A")
		else
			local frame_limits = {RollSpeed = 32, LedgeStandSpeed = 20, LedgeRollSpeed = 33, GetupRollSpeed = 30, TechRollSpeed = 34}
			local frictions = {RollSpeed = 0.6, LedgeStandSpeed = value["FrictionGround"], LedgeRollSpeed = value["FrictionGround"], GetupRollSpeed = 0.5, TechRollSpeed = 0.5}
			local over_nine_frames = math.ceil((value[trait] - 9)/frictions[trait]/2) + 1
			local under_nine_frames = frame_limits[trait] - over_nine_frames + 1
			
			local over_nine_distance = value[trait] * over_nine_frames - frictions[trait] * (over_nine_frames) * (over_nine_frames - 1)
			local under_nine_distance = (value[trait] - frictions[trait] * (over_nine_frames - 1) * 2) * under_nine_frames - frictions[trait] * (under_nine_frames) * (under_nine_frames + 1) / 2
			
			row:tag('td'):wikitext(under_nine_distance + over_nine_distance)
		end
	
	end
	if trait == "FullHopSpeed" or trait == "ShortHopSpeed" or trait == "DoubleJumpSpeed" or trait == "WallJumpSpeedY" then
		if custom or (tonumber(value[trait]) < 0) then
			row:tag('td'):wikitext("N/A")
		else
			
			local max_height_frame =math.floor(-(value[trait]-value["Gravity"]/2)/(-value["Gravity"]),1)
			
			local max_height =-1*value["Gravity"]/2*(max_height_frame*max_height_frame+max_height_frame)+value[trait]*max_height_frame
			row:tag('td'):wikitext(max_height)
		end
	end
	return row
end

local function createTable(search)
	
	local frame = mw.getCurrentFrame() 
	local tables = 'ROA2_CharacterData'
	local search_q = tostring(table.concat(search, ", "))
	local fields = 'chara,DacusSpeedMultiplier,Weight,FrictionGround,FrictionAir,DashFrames,DashSpeed,DashAcceleration,RunSpeedMax,RunTurnAcceleration,RunTurnFrames,WalkAccelerationMax,WalkSpeedMax,Gravity,HitstunGravity,FallSpeedMax,FastFallSpeed,AirAcceleration,AirSpeedHorizontalMax,JumpSpeedHorizontalMax,FullHopSpeed,ShortHopSpeed,DoubleJumpSpeed,DoubleJumpMaxHorizontalSpeed,AirDodgeSpeed,AirDodgeFriction,RollSpeed,ShieldSizeMultiplier,LedgeStandSpeed,LedgeRollSpeed,LedgeJumpMaxHorizontalAirSpeed,GetupRollSpeed,TechRollSpeed,WallJumpSpeedY,WallJumpSpeedX'
    local results = cargo.query( tables, fields, args)
    
    local custom_tables = 'ROA2_CharacterCustomData,ROA2_CharacterCustomData__attr_keys,ROA2_CharacterCustomData__attr_values,ROA2_CharacterCustomData__attr_analogs'
    local custom_fields = 'chara, attr_keys, attr_values, attr_analogs'
    local custom_args = {join = 'ROA2_CharacterCustomData._ID=ROA2_CharacterCustomData__attr_keys._rowID,ROA2_CharacterCustomData__attr_keys._rowID=ROA2_CharacterCustomData__attr_values._rowID,ROA2_CharacterCustomData__attr_values._rowID=ROA2_CharacterCustomData__attr_analogs._rowID,ROA2_CharacterCustomData__attr_keys._position=ROA2_CharacterCustomData__attr_values._position,ROA2_CharacterCustomData__attr_values._position=ROA2_CharacterCustomData__attr_analogs._position'}
    
    local custom_results = cargo.query( custom_tables, custom_fields, custom_args)
    
    local total_string = {}
    for _, v in ipairs(results) do
    	local char_row = mw.html.create("tr")
    	local char_cell = mw.html.create("td")
    	char_cell:wikitext(frame:expandTemplate{ title = 'StockIcon', args = {v.chara}})
		char_row:node(char_cell)
    	for _, trait in pairs(search) do
    		local char_cell = mw.html.create("td")
    		char_cell:wikitext(v[trait])
    		char_row:node(char_cell)
    		char_row = added_traits(char_row, search_q, v, trait, false)
		end
    	table.insert(total_string, tostring(char_row))
    end
    for _, v in ipairs(custom_results) do
    	local char_row = nil
    	local trait_found = false
    	local past_traits = 0
    	for _, trait in pairs(search) do
    		if v.attr_analogs == trait then
    			if char_row == nil then
    				char_row = mw.html.create("tr")
    				local char_cell = mw.html.create("td")
			    	char_cell:wikitext(frame:expandTemplate{ title = 'StockIcon', args = {v.chara}} .. " (" .. v.attr_keys .. ")")
					char_row:node(char_cell)
    			end
    			if not trait_found then
    				for i = 1, past_traits do
    					char_row:tag("td"):wikitext("N/A")
    				end
					trait_found = true
				end
    			
    			local char_cell = mw.html.create("td")
	    		char_cell:wikitext(v.attr_values)
	    		char_row:node(char_cell)
	    		char_row = added_traits(char_row, search_q, v, trait, true)
	    		table.insert(total_string, tostring(char_row))
    		elseif trait_found then
    			char_row:tag("td"):wikitext("N/A")
			end
    		past_traits = past_traits + 1
    	end
	end
	return table.concat(total_string)
end

function p.main(frame)
	mArguments = require( 'Module:Arguments' )
	local args = mArguments.getArgs(frame)
	return p._main(args)
end
	
function p._main( args )
	local html = ''
	if args[5] then
		html = createTable({args[1], args[2], args[3], args[4], args[5]})
	elseif args[4] then
		html = createTable({args[1], args[2], args[3], args[4]})
	elseif args[3] then
		html = createTable({args[1], args[2], args[3]})
	elseif args[2] then
		html = createTable({args[1], args[2]})
	elseif args[1] then
		html = createTable({args[1]})
	end
	return tostring(html)
end

return p