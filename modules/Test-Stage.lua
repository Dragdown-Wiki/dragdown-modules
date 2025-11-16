local p = {}

-- These are the upper bound limits for each measurement to be in the given range. Values smaller than the XS Limit will be XS, etc.
local roa2_limits = {
	stageLength = { xs = 833,   s = 1415,  m = 1802,  l = 2384 },
	platHeight  = { xs = -70,   s = 260,   m = 480,   l = 810  },
	platLength  = { xs = 120,   s = 300,   m = 420,   l = 600  },
	topBlast    = { xs = 1944,  s = 2092,  m = 2191,  l = 2339 },
	sideBlast   = { xs = 1238,  s = 1493,  m = 1663,  l = 1919 },
	botBlast    = { xs = 1160,  s = 1293,  m = 1382,  l = 1515 }
}

local pplus_limits = {
	stageLength = { xs = 78,   s = 126,  m = 158,  l = 205 },
	platHeight  = { xs = -9,   s = 25,   m = 48,   l = 82  },
	platLength  = { xs = 21,   s = 31,   m = 38,   l = 47  },
	topBlast    = { xs = 157,  s = 183,  m = 201,  l = 227 },
	sideBlast   = { xs = 113,  s = 135,  m = 151,  l = 173 },
	botBlast    = { xs = 84,   s = 108,  m = 125,  l = 149 }
}

local ssbu_limits = {
	stageLength = { xs = 135,  s = 153,  m = 165,  l = 183 },
	platHeight  = { xs = 4,    s = 26,   m = 40,   l = 62  },
	platLength  = { xs = 17,   s = 31,   m = 40,   l = 54  },
	topBlast    = { xs = 162,  s = 180,  m = 192,  l = 210 },
	sideBlast   = { xs = 148,  s = 156,  m = 162,  l = 170 },
	botBlast    = { xs = 90,   s = 120,  m = 140,  l = 170 }
}

local limits = roa2_limits

-- Decides which table to use
local function selectLimits(game)
	local lowerGame = string.lower(game)
    if lowerGame == "pplus" then
        limits = pplus_limits
    elseif lowerGame == "roa2" then
        limits = roa2_limits
    elseif lowerGame == "ssbu" then
        limits = ssbu_limits
    else
    	limits = nil
    end
end

-- Classifies a measurement into the appropriate StageSize range
local function classifyMeasurement(value, measureKey)
	-- If limits aren't defined, return the unformatted value. This will happen if the game isn't supported yet
	if limits == nil then
		return value
	end
	
	if (string.lower(value) == "x" 
		or string.lower(value) == "na" 
		or string.lower(value) == "walkoff") then
			-- Return orange exception category
    		local wikitext = string.format("{{StageSize|NA|%s}}", value)
    		return mw.getCurrentFrame():preprocess(wikitext)
	end
	
    local num = tonumber(value)
    if not num or not limits[measureKey] then
        return ""  -- Return empty string if invalid input or measureKey
    end

    local category = ""
    if num == 0 then
    	category = "NA"
    elseif num < limits[measureKey].xs then
        category = "XS"
    elseif num < limits[measureKey].s then
        category = "S"
    elseif num < limits[measureKey].m then
        category = "M"
    elseif num < limits[measureKey].l then
        category = "L"
    else
        category = "XL"
    end
    local wikitext = string.format("{{StageSize|%s|%s}}", category, num)
    return mw.getCurrentFrame():preprocess(wikitext)
end

-- Processes multiple values given in a semicolon-separated list into StageSize ranges
local function processList(valueList, measureKey)
	if not valueList or valueList == "" then
        return ""
    end
	
	local values = mw.text.split(valueList, "%s*;%s*") -- table of strings
    for i, v in ipairs(values) do
        values[i] = classifyMeasurement(v, measureKey)
    end
    return table.concat(values, "<br>")
end

local function tooltip(title, tip)
	--{{tt|Side Blastzone Distance|This distance is measured from the ledge to the blastzone.}}
	local wikitext = '{{tt|' .. title ..'|'.. tip ..'}}'
	return mw.getCurrentFrame():preprocess(wikitext)
end

local function buildTabber(gameID, stageID, numLayouts, modeID)
	local opening = '<tabber>\n'
    
    local layoutString = ''
    
    if(numLayouts <= 1) then
    	if(modeID ~= nil and modeID ~= '') then
    		layoutString = '|-|Static = [[File:' .. gameID .. '_Stage_' .. stageID .. '_'.. modeID ..'.png|middle|x250px]]'
		else
    		layoutString = '|-|Static = [[File:' .. gameID .. '_Stage_' .. stageID .. '.png|middle|x250px]]'
		end
    else 
    	layoutString = '|-|Base Layout = [[File:' .. gameID .. '_Stage_' .. stageID .. '.png|middle|x250px]]'
		for i=2,numLayouts do
			layoutString = layoutString .. '\n|-|Layout ' .. i .. ' = [[File:' .. gameID .. '_Stage_' .. stageID .. '_'.. (i-1) ..'.png|middle|x250px]]'
	    end
    end

    local closing = table.concat({
    '|-|Animated = [[File:' .. gameID .. '_Stage_' .. stageID .. '_Animated.webm|middle|x500px]]',
    '|-|Collisions = [[File:' .. gameID .. '_Stage_' .. stageID .. '_Collisions.png|middle|x250px]]',
    '</tabber>'
	}, '\n')
	
	return opening .. layoutString .. closing
end

function p.main(frame)
	local args = frame.args

    local game = args.game or mw.text.split(mw.title.getCurrentTitle().prefixedText, "/")[1]
    selectLimits(game)
    
    local stageName = args.name or args.stageID
    local stageLength = args.stageLength or ''
    local platHeight = args.platHeight or ''
    local platLength = args.platLength or ''
    local topBlast = args.topBlastzone or ''
    local sideBlast = args.sideBlastzone or ''
    local botBlast = args.bottomBlastzone or ''
    local notes = args.notes or ''
    local layouts = args.layouts or 1
    local mode = args.mode
    
	local tabberWikitext = buildTabber(game, stageName, tonumber(layouts), mode)

	local tabberProcessed = frame:preprocess(tabberWikitext)
    
    return table.concat({
    	'<div class="stage-data">',
    	'  <div class="stage-tabber">' .. tabberProcessed .. '</div>',
		'<table class="wikitable stage-table">',
		'  <tr>',
		'    <th>[[File:StageIcon StageWidth.png|inline|x25px]] Stage Length</th>',
		'    <th>[[File:StageIcon PlatHeight.png|inline|x25px]] Platform Height</th>',
		'    <th>[[File:StageIcon PlatWidth.png|inline|x25px]] Platform Length</th>',
		'  </tr>',

		'  <tr>',
		'    <td>' .. classifyMeasurement(stageLength, "stageLength") .. '</td>',
		'    <td>' .. processList(platHeight, "platHeight") .. '</td>',
		'    <td>' .. processList(platLength, "platLength") .. '</td>',
		'  </tr>',

		'  <tr>',
		'    <th>[[File:StageIcon Blastzone.png|inline|x25px|class=rotate-90]]' .. tooltip("Side Blastzone Distance", "This distance is measured from the ledge to the blastzone.") .. '</th>',
		'    <th>[[File:StageIcon Blastzone.png|inline|x25px]] Top Blastzone Distance</th>',
		'    <th>[[File:StageIcon Blastzone.png|inline|x25px|class=rotate-180]] ' .. tooltip("Bottom Blastzone Distance", "This distance is measured from the ledge to the blastzone.") .. '</th>',
		'  </tr>',

		'  <tr>',
		'    <td>' .. classifyMeasurement(sideBlast, "sideBlast") .. '</td>',
		'    <td>' .. classifyMeasurement(topBlast, "topBlast") .. '</td>',
		'    <td>' .. classifyMeasurement(botBlast, "botBlast") .. '</td>',
		'  </tr>',

		'  <tr>',
		'    <td colspan="3">' .. notes .. '</td>',
		'  </tr>',
    '  </table>',
    '</div>'
	}, "\n")

end

return p