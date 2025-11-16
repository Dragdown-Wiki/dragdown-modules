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

-- Cargo queries a single image by 3 unnamed arguments
--- 1 - name of target cargo table
--- 2 - moveId from that cargo table
--- 3 - image index of the move
function p.getMoveImage(frame)
	-- Target cargo table to query
	local cargoTable = frame.args[1]
	-- Target move to query
	local moveId = frame.args[2]
	-- Target image index (is default 1 from template MoveDataCargoImage)
	local imageIndex = frame.args[3]
	-- Boolean to use image or hitbox image
	local useHitbox = mw.text.trim(frame.args[4])
	-- Wikitext to return after function is completed
	local wikitext = ""
	
	-- 'fields' part of the cargo query
	-- We need to grab only the first instance of each image "sorted" by moveId
	local fields = ""
	if useHitbox == "yes" then
		fields = "hitboxes"
	else
		fields = "images"
	end
	
	-- 'args' part of the Lua cargo query
	local args = {
		-- 'whereQuery' from above which goes by moveIds
		where = "moveId = '" .. mw.text.trim(moveId) .. "'"
	}
	
	local result
	
	-- Cargo query
	if useHitbox == "yes" then
		result = cargo.query( cargoTable, fields, args )[1].hitboxes
	else
		result = cargo.query( cargoTable, fields, args )[1].images
	end
	
	-- Turn query into list split by ','
	local listOfImages = mw.text.split(result,',')
	
	-- Get target image based on imageIndex
	local targetImage = listOfImages[tonumber(imageIndex)]
	
	-- Return the image as wikitext
	wikitext = "[[File:" .. targetImage .. "|175px]]"
	return wikitext
end

return p