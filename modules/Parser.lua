local p = {}
local cargo = mw.ext.cargo

-- Create a wikitext hyperlink that links to the frame data page section of a move
-- Assumes the section header is the same as moveInput
function p.createFrameDataLink(frame)
	-- Target cargo table to query
	local cargoTable = frame.args['cargoTable']
	-- MoveId to query
	local moveId = frame.args['moveId']
	-- Field in to return in query
	local fields = "input"
	-- Args for query
	local args = { where = "moveId = '" .. moveId .. "'"}
	
	-- Beginning of wikitext to return
	local wikitext = "[[/Data#"
	
	-- Cargo query for moveInput
	local results = cargo.query( cargoTable, fields, args )
	local moveInput = results[1]['input']
	
	-- Replaces any left and right square brackets with their ascii code to make it wikitext compatible
	moveInput = string.gsub(moveInput, '%[', "&#91;")
	moveInput = string.gsub(moveInput, "%]", "&#93;")
	
	-- TODO: Maybe add alternate text instead of it just saying '/Data#moveInput'?
	-- Concatenates 'wikitext' with 'moveInput' and ending square brackets
	wikitext = wikitext .. moveInput .. "]]"
	
	-- Returns the wikitext
	return wikitext 
end

-- TODO: I might delete this one? I dunno. I'll take a look at it again later. Not going to bother comment it for the time being as it's not really being used except for displaying on the frame data page, which I might change?
-- Take a list of comma separated files names and transcribe them to wikitext file markup
function p.parseImages(frame)
	local listOfFiles = frame.args[1] -- List of files
	local extraParameters = frame.args[2] -- Extra parameters to use in each file
	local addLineBreaks = frame.args['addLineBreaks'] -- Add extra line breaks if set to "true"
	local lineBreak = ""
	local wikitextFiles = ""
	
	if addLineBreaks == "true" then lineBreak = "<br>" end
	
	if listOfFiles and string.len(listOfFiles) > 0 then
		if extraParameters and string.len(extraParameters) > 0 then
			extraParameters = "|" .. string.gsub(extraParameters, ",", "|")
		else
			extraParameters = ""
		end
		
		-- Replaces any left and right square brackets with their ascii code to make it wikitext compatible
		wikitextFiles = string.gsub(listOfFiles, '%[', "&#91;")
		wikitextFiles = string.gsub(listOfFiles, '%]', "&#93;")
		wikitextFiles = string.gsub(listOfFiles,",", extraParameters .. "]]" .. lineBreak .. "[[File:")
		wikitextFiles = "[[File:" .. wikitextFiles .. extraParameters .. "]]"
	end
	
	return wikitextFiles
end

-- Cargo queries a comma separated list of moveIds and returns their images as wikitext
function p.parseImagesQuery(frame)
	-- Target cargo table to query
	local cargoTable = frame.args['cargoTable']
	-- List of moves queried by their arbitrary moveId
	local moves = frame.args['moveIds']
	-- List of captions entered by the user on function call
	-- In other words, these captions are not queried from cargos
	local captions = frame.args['captions']
	-- TODO: Figure out how I want to implement hitbox images
	--local listOfHitboxCaptions = frame.args['hitboxCaptions']
	-- Wikitext to return after function is completed
	local wikitext = ""
	-- List of moves as a table
	local listOfMoves = {}
	-- List of captions as a table
	local listOfCaptions = {}
	
	-- Assign listOfMoves with the values 'moves' split by the delimiter ','
	listOfMoves = split(moves,",")
	-- If captions exist
	if captions then
		-- Assign listOfCaptions with the values 'captions' split by the delimiter ','
		listOfCaptions = split(captions, ",")
	end
	
	-- 'where' part of the cargo query
	local whereQuery = ""
	-- boolean just to track if it's the first where argument and if we should add ' OR ' to the query
	local firstWhere = true
	
	-- Iterate through every value in 'listOfMoves'
	for i,v in ipairs(listOfMoves) do
		-- If it's the first where argument, don't prefix with ' OR '
		if firstWhere then
			firstWhere = false
		else
			whereQuery = whereQuery .. " OR "
		end
		
		-- Concatenate the current whereQuery with the current moveId
		whereQuery = whereQuery .. "moveId = '" .. trim(v) .. "'"
	end
	
	-- 'fields' part of the cargo query
	-- We need to grab only the first instance of each image "sorted" by moveId
	local fields = "images, MIN(moveId)=sort"
	
	-- 'args' part of the Lua cargo query
	local args = {
		-- 'whereQuery' from above which goes by moveIds
		where = whereQuery,
		-- 'order by' goes off of the first instance based on moveId
		orderBy = "sort",
		-- 'group by' is used to remove duplicate images from this query
		groupBy = "images"
	}
	
	-- Cargo query
	local results = cargo.query( cargoTable, fields, args )
	
	-- Iterate through results
	for r = 1, #results do
		-- The item at the current index
		local result = results[r]
		
		-- The caption to add below the image
		local caption = ""
		
		-- If the caption exists
		if listOfCaptions[r] and string.len(listOfCaptions[r]) >0 then
			-- Then assign 'caption'
			caption = "<br>" .. trim(listOfCaptions[r])
		end
		
		-- Add this item's image and caption to the wikitext
		wikitext = wikitext .. "<div>[[File:" .. result.images .. "|175px]]" .. caption .. "</div>"
	end
	
	-- Return the wikitext
	return wikitext
end

-- Cargo queries for a list of comma separated moveIds
function p.parseFrameData(frame)
	-- Target cargo table to query
	local cargoTable = frame.args['cargoTable']
	-- 'fields' part of the cargo query
	local fields = frame.args['fields']
	-- moveIds to query
	local moveIds = frame.args['moveIds']
	-- template to use for the result of this query
	local template = frame.args['template']
	-- descriptions to display below template
	local descriptions = frame.args['descriptions']
	
	-- A table made from splitting 'moveIds' at every ','
	local listOfMoves = split(moveIds, ",")
	-- A table made from splitting 'fields' at every ','
	local listOfFields = split(fields,",")
	-- A table made from splitting 'descriptions' at every ';'
	local listOfDescriptions = {}
	
	-- If descriptions exist
	if descriptions then
		-- Assign listOfDescriptions with the values 'descriptions' split by the delimiter ';'
		listOfDescriptions = split(descriptions, ";")
	end
	
	-- Wikitext to return at the end
	local wikitext = ""
	
	-- 'where' part of the cargo query
	local whereQuery = ""
	-- boolean just to track if it's the first where argument and if we should add ' OR ' to the query
	local firstWhere = true
	
	-- Iterate through every value in 'listOfMoves'
	for i,v in ipairs(listOfMoves) do
		-- If it's the first where argument, don't prefix with ' OR '
		if firstWhere then
			firstWhere = false
		else
			whereQuery = whereQuery .. " OR "
		end
		
		-- Concatenate the current whereQuery with the current moveId
		whereQuery = whereQuery .. "moveId = '" .. trim(v) .. "'"
	end
	
	-- 'args' portion of cargo query
	local args = {
		-- 'whereQuery' from above
		where = whereQuery,
		-- 'order by' moveId
		orderBy = "moveId"
	}
	-- Cargo query
	local results = cargo.query( cargoTable, fields, args )
	
	-- Iterate through all results of the query to put them into the target template
	for r = 1, #results do
		-- Arguments for the template
		local arguments = {}
		
		-- Iterate through all values in listOfFields
		for j,k in ipairs(listOfFields) do
			-- Remove all leading and trailing spaces in the value
			local item = trim(k)
			-- Add the passed in arguments of the current move into arguments
			arguments[item] = results[r][item]
		end
		
		-- If the a description exists
		if listOfDescriptions[r] and string.len(listOfDescriptions[r]) >0 then
			-- Then assign the argument of index 'descriptions'
			arguments['descriptions'] = trim(listOfDescriptions[r])
		end
		
		-- Add the move expanded into the target template into the wikitext
		wikitext = wikitext .. frame:expandTemplate{ title = template, args = arguments }
	end
	
	-- Return the wikitext
	return wikitext
end

-- Split string 's' at every 'delimiter' into an array
function split(s, delimiter)
	-- Array to return
	local result = {}
	
	-- Iterate through the string finding every section split with delimiter
	for match in (s..delimiter):gmatch("(.-)"..delimiter) do
		-- Add the match to the result array
		table.insert(result, match)
	end
	
	-- Return the result
	return result
end

-- Split string 's' at every 'delimiter' into an array
function splitKeepDelimiter(s, delimiter)
	-- Array to return
	local result = {}
	
	-- Boolean to check if this is the firstSplit (only applicable when keeping delimiter)
	local firstSplit = true
	
	-- Iterate through the string finding every section split with delimiter
	for match in (s..delimiter):gmatch("(.-)"..delimiter) do
		-- Don't add the delimiter until after the first split
		if firstSplit then
			firstSplit = false
		else
			table.insert(result, delimiter)
		end
		
		-- Remove a '%' character if it's leftover from a delimiter
		local matchWithEscapedRemoved = match
		if string.find(string.sub(match,-1, string.len(match)),"%%") then
			mw.log(match)
			matchWithEscapedRemoved = string.sub(match, 1, -2)
		end
		
		-- Add the match to the result array
		table.insert(result, matchWithEscapedRemoved)
	end
	
	-- Return the result
	return result
end

-- Return string 's' with all leading and trailing spaces trimmed away
function trim(s)
	return (string.gsub(s, "^%s*(.-)%s*$", "%1"))
end

return p