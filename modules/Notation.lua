local function basic(name)
	local size = "x25"

	if name == "GCN_B" then
      size = "18"
    elseif name == "GCN_Y" or name == "GCN_Z" or name == "GCN_L" or name == "GCN_R" then
      size = "28"
    end

	return "[[File:ROA2_" .. name .. "_Prompt.PNG|" .. size .. "px|link=]]"
end

local function basicPair(type, variant)
	return type .. ": " .. basic((type == "KB" and "Keyboard" or type) .. "_" .. variant)
end

local function dpad(direction)
	-- takes Neutral, Up, LeftRight, Down
	return "[[File:Notation_DPad-" .. direction .. ".svg|x25px|link=]]"
end

-- table values under LS, RS, ATTACK etc get joined using <br/>
local gameConfig = {
	roa2 = {
		ls = {
			"Xbox/GCN: Left Analog Stick",
			basicPair("KB", "Up") ..
			" / " .. basic("Keyboard_Down") .. " / " .. basic("Keyboard_Left") .. " / " .. basic("Keyboard_Right")
		},
		rs = { "Xbox/GCN: Right Analog Stick", "KB: Not set" },
		attack = { basicPair("Xbox", "A"), basicPair("GCN", "A"), basicPair("KB", "A") },
		special = { basicPair("Xbox", "X"), basicPair("GCN", "B"), basicPair("KB", "S") },
		jump = { basicPair("Xbox", "Y"), basicPair("GCN", "Y"), basicPair("KB", "Spacebar") },
		grab = { basicPair("Xbox", "RB"), basicPair("GCN", "Z"), basicPair("KB", "E") },
		shield = { basicPair("Xbox", "LT") .. " /" .. basic("Xbox_RT"), basicPair("GCN", "L") .. " /" .. basic("GCN_R"), basicPair("KB", "F") },
		strong = { basicPair("Xbox", "B"), basicPair("GCN", "X"), basicPair("KB", "D") },
		parry = { basicPair("Xbox", "LB"), basicPair("GCN", "L") .. " /" .. basic("GCN_R") .. " + " .. basic("GCN_B"), basicPair("KB", "Q") },
		walkmod = basicPair("KB", "LeftShift")
	},
	ssbu = {
		ls = "Left Analog Stick",
		rs = { "Switch: Right Analog Stick", "GCN: C-Stick" },
		attack = { "Switch: A", "GCN: A" },
		special = { "Switch: B", "GCN: B" },
		jump = { "Switch: X/Y", "GCN: X/Y" },
		grab = { "Switch: L/R", "GCN: Z" },
		shield = { "Switch: ZL/ZR", "GCN: L/R" },
		taunt = "Switch/GCN: " .. dpad("Neutral"), -- TODO: REPLACE W/ GLYPH
		uptaunt = "Switch/GCN: " .. dpad("Up"),    -- TODO: REPLACE W/ PROPER DESC + GLYPH
		sidetaunt = "Switch/GCN: " .. dpad("LeftRight"), -- TODO: REPLACE W/ PROPER DESC + GLYPH
		downtaunt = "Switch/GCN: " .. dpad("Down"), -- TODO: REPLACE W/ PROPER DESC + GLYPH
	},
	nasb2 = { -- TODO: REPLACE W/ PROPER BADGEs
		ls = "test - left stick NASB2",
		rs = "test - right stick NASB2",
		attack = { basicPair("Xbox", "A"), basicPair("GCN", "A"), basicPair("KB", "A") },
		special = { basicPair("Xbox", "X"), basicPair("GCN", "B"), basicPair("KB", "S") },
		jump = { basicPair("Xbox", "Y"), basicPair("GCN", "Y"), basicPair("KB", "Spacebar") },
		grab = { basicPair("Xbox", "RB"), basicPair("GCN", "Z"), basicPair("KB", "E") },
		shield = { basicPair("Xbox", "LT") .. " /" .. basic("Xbox_RT"), basicPair("GCN", "R"), basicPair("KB", "F") },
		strong = { basicPair("Xbox", "B"), basicPair("GCN", "X"), basicPair("KB", "D") },
		slime = "slime test - LT NASB2"
	},
	pplus = {
		ls = "Left Analog Stick",
		rs = "GCN: C-Stick",
		attack = basicPair("GCN", "A"),
		special = basicPair("GCN", "B"),
		jump = basicPair("GCN", "X") ..
				" / " .. basic("GCN_Y") .. " / Tap Jump " .. "[[File:Notation_LSUpTap_Direction.svg|x25px|link=]]",
		grab = basicPair("GCN", "Z"),
		shield = basicPair("GCN", "L") .. " /" .. basic("GCN_R"),
		taunt = "GCN: " .. dpad("Neutral"),
		uptaunt = "GCN: " .. dpad("Up"),
		sidetaunt = "GCN: " .. dpad("LeftRight"),
		downtaunt = "GCN: " .. dpad("Down"),
	},
	afqm = { -- TODO: REPLACE W/ PROPER BADGEs
		ls = "test - left stick NASB2",
		rs = "test - right stick NASB2",
		attack = { basicPair("Xbox", "A"), basicPair("GCN", "A"), basicPair("KB", "A") },
		special = { basicPair("Xbox", "X"), basicPair("GCN", "B"), basicPair("KB", "S") },
		jump = { basicPair("Xbox", "Y"), basicPair("GCN", "Y"), basicPair("KB", "Spacebar") },
		airdash = "test",
		bidou = "test",
		parry = { basicPair("Xbox", "RT"), basicPair("GCN", "R"), basicPair("KB", "F") },
		smash = { basicPair("Xbox", "B"), basicPair("GCN", "X"), basicPair("KB", "D") },
	},
}

local gameToImageNamespace = {
	ssbu = 'SSBU',
	roa2 = 'RoA2',
	nasb2 = 'NASB2', -- TODO: CHANGE THIS
	pplus = 'PPlus',
	afqm = 'AFQM'
}

local inputData = {
	neutral = 'Neutral',
	up = 'Up',
	down = 'Down',
	left = 'Left',
	right = 'Right',
	downright = 'DownRight',
	downleft = 'DownLeft',
	upright = 'UpRight',
	upleft = 'UpLeft',
	leftright = 'LeftRight',
	updown = 'UpDown',
	uptap = 'UpTap',
	downtap = 'DownTap',
	lefttap = 'LeftTap',
	righttap = 'RightTap',
	leftrighttap = 'LeftRightTap',
	updowntap = 'UpDownTap'
}

local moveData = {
	ls = { name = "Left Stick" },
	rs = { name = "Right Stick" },
	attack = { name = "Attack", color = "tilt" },
	special = { name = "Special", color = "special" },
	jump = { name = "Jump", color = "aerial" },
	grab = { name = "Grab", color = "grab" },
	shield = { name = "Shield" },
	strong = { name = "Strong", color = "strong" },
	smash = { name = "Smash", color = "smash" },
	airdash = { name = "Air Dash"},
	bidou = { name = "Bidou"},
	parry = { name = "Parry" },
	walkmod = { name = "WalkMod" },
	taunt = { name = 'Taunt' },
	uptaunt = { name = 'Up Taunt' },
	sidetaunt = { name = 'Side Taunt' },
	downtaunt = { name = 'Down Taunt' },
	slime = { name = 'Slime', color = "slime"},
}

local function getDescription(params)
	local tapText = params.move:lower():find("tap") and "Quickly Tap " or ""
	local isRS = params.move:lower():find("^rs\\-")

	if params.game == "ssbu" then
		return isRS and
				("Switch: " .. tapText .. "Right Analog Stick<br>GCN: " .. tapText .. "C-Stick") or
				(tapText .. "Left Analog Stick")
	end

	if params.game == "pplus" then
		return isRS and ("GCN: " .. tapText .. "C-Stick") or
				(tapText .. "Left Analog Stick")
	end

	local p1 = "Xbox/GCN: " .. tapText

	if isRS then
		return p1 .. "Right Analog Stick<br>KB: Not set"
	else
		return p1 .. "Left Analog Stick<br>KB: " ..
				basic("Keyboard_Up") ..
				" / " ..
				basic("Keyboard_Down") ..
				" / " .. basic("Keyboard_Left") .. " / " .. basic("Keyboard_Right")
	end
end

local function addMove(params)
	local badge = gameConfig[params.game][params.move:lower()]
	local move = moveData[params.move:lower()]

	if params.game == "nasb2" and move.name == "Attack" then
		move.name = "Light"
	end

	local fileName = "Notation_" ..
			params.move ..
			(params.size == "inline" and "inline_" or "_") .. gameToImageNamespace[params.game] .. ".svg"

	params.tooltip
			:addClass(params.game:upper() .. "-" .. (move.color or "other") .. "-move")
			:addClass("move-colored-text")
			:wikitext("[[File:" ..
			fileName .. (params.size == "inline" and "|inline|x25px" or ("|" .. params.size)) .. "|link=]] ")
			:tag("u"):wikitext(move.name)

	params.tooltipContent:node("<b><u>Default Controls</u></b><br/>" .. (type(badge) == "table" and table.concat(badge, "<br/>") or badge))
end

local function addInput(params)
	local input = inputData[params.move:lower()] or inputData[params.move:lower():sub(4)] or
			error("invalid input '" .. params.move .. "'")

	local iconFileName = 'Notation_' ..
			(params.move:lower():find("^rs\\-") and "RS" or "LS") .. input .. '_Direction.svg'

	params.tooltip:wikitext("[[File:" ..
		iconFileName .. (params.size == "inline" and "|inline|x25px" or ("|" .. params.size)) .. "|link=]] ")

	params.tooltipContent:node("<b><u>Default Controls</u></b><br/>" .. getDescription(params))
end

return {
	main = function(frame)
		local args = require('Module:Arguments').getArgs(frame)
		local rootText = mw.title.getCurrentTitle().rootText
		local secondArgLower = args[2] and args[2]:lower()
		local gameByArg = gameConfig[secondArgLower] and secondArgLower
		local gameByRootText = gameConfig[rootText:lower()] and rootText:lower()

		local params = {
			move = args[1],
			game = gameByArg or gameByRootText or "roa2",
			tooltip = mw.html.create('span')
		}

		params.tooltip:addClass('tooltip'):css("border-bottom", "0")
		params.size = args[3] or (args[2] == "inline" and "inline" or "x42px")
		params.tooltipContent = params.tooltip:tag("span"):addClass("tooltiptext"):css("font-weight", "bold")

		local game = gameConfig[params.game]

		if game and game[params.move:lower()] then
			addMove(params)
		else
			addInput(params)
		end

		return tostring(params.tooltip)
	end
}