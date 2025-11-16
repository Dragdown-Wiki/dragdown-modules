local p = {}
local mArguments
local cargo = mw.ext.cargo
local cache = {}

local tabber = require("Module:Tabber").renderTabber
local splitString = require("Module:SplitStringToTable").splitStringIntoTable
local list = require("Module:List").makeList

local function tooltip(text, hover)
	local n = mw.html.create("span"):addClass("tooltip")
	n:wikitext(text):node(mw.html.create("span"):addClass("tooltiptext"):wikitext(hover):done()):done()
	return tostring(n)
end

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

local function firstToUpper(str)
	if str ~= nil then
		return (str:gsub("^%l", string.upper))
	else
		return str
	end
end
local cargo = mw.ext.cargo
local tables = "ROA2_CharacterData"
local fields = "chara, Weight, HitstunGravity"
local args = { orderBy = "Weight" }
local weightObject = cargo.query(tables, fields, args)

local function mysplit(inputstr, sep)
	if sep == nil then
		sep = "%s"
	end
	if inputstr == nil then
		return nil
	end
	local t = {}
	for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
		table.insert(t, str)
	end
	return t
end

local function readModes(chara, attack)
	local tables = "ROA2_MoveMode"
	local fields =
		"chara, attack, attackID, mode, notes, startup, startupNotes, totalActive, totalActiveNotes, endlag, endlagNotes, cancel, cancelNotes, landingLag, landingLagNotes, totalDuration, totalDurationNotes,hitID,hitMoveID,hitName,hitActive,customShieldSafety,uniqueField,frameChart, articleID"
	local args =
		{ where = 'ROA2_MoveMode.chara="' .. chara .. '" and ROA2_MoveMode.attack="' .. attack .. '"', orderBy = "_ID" }
	local results = cargo.query(tables, fields, args)
	return results
end

local function getImagesWikitext(t)
	local wikitextTable = {}
	for i, data in ipairs(t) do
		-- MediaWiki image syntax
		-- @see https://www.mediawiki.org/wiki/Help:Images/en#Rendering_a_single_image
		local image = string.format("[[File:%s|thumb|center|210x210px]]", data.file)
		local caption = tostring(
			mw.html.create("div"):addClass("gallerytext"):css("text-align", "center"):wikitext(data.caption or "")
		)
		table.insert(wikitextTable, image)
		table.insert(wikitextTable, caption)
	end
	return wikitextTable
end
local function getHitboxesWikitext(t)
	local wikitextTable = {}
	for i, data in ipairs(t) do
		-- MediaWiki image syntax
		-- @see https://www.mediawiki.org/wiki/Help:Images/en#Rendering_a_single_image
		
		local splitstring = mysplit(data.file, '-')
		
		local splitindex = "0"
		if #splitstring > 2 then
			splitindex = splitstring[3]
		end
		
		local host = 'https://dragdown.wiki/wiki/Special:Redirect/file/'

		local modal = tostring(mw.html.create('div'):addClass('fd-modal inline')
			:wikitext(host .. splitstring[1] .. '_' .. splitstring[2] .. '_NHB_' .. splitindex .. '.webm?f=0 && '
			.. host .. splitstring[1] .. '_' .. splitstring[2] .. '_WHB_' .. splitindex .. '.webm?f=0'))
		
		table.insert(wikitextTable, modal)
	end
	
	return wikitextTable
end

local function calcTumblePercent(bkb, kbg, weight, damage, crouch, angle, flipper, grounded)
	local tumbleThreshold = 26
	local crouchReduction = 0.8
	local realTumbleThreshold = tumbleThreshold
	if crouch then
		realTumbleThreshold = realTumbleThreshold / crouchReduction
	end

    local g_spike = 1

	if(flipper == 'SpecifiedAngle' and angle > 180 and angle < 360) then
        if grounded then
            if math.abs(angle - 270) <= 30 then
                g_spike = 1.25
            elseif math.abs(angle - 270) >= 70 then
                g_spike = 1
            else
            	angle_diff_alpha = math.pow(1 - (math.abs(angle - 270) - 30) / 40, 2)
    			g_spike = 1 + 0.25 * angle_diff_alpha
            end
            realTumbleThreshold = realTumbleThreshold * (1 - (90 - math.abs(angle - 270)) / 90 * 0.125)
        else
            realTumbleThreshold = realTumbleThreshold * (1 - (90 - math.abs(angle - 270)) / 90 * 0.25)
        end
	end

	if kbg == 0 then
		if realTumbleThreshold > bkb * 3 then
			return nil
			-- return 2
		else
			return 0
		end
	else
		local percent = (realTumbleThreshold / 3 - bkb) * (weight + 100) / (200 * 0.12 * kbg * g_spike) - damage
		if percent <= 0 then
			return 0
		else
			-- return 3
			return math.ceil(percent)
		end
	end
	return 0
end

function calcFlugPopUpPercent(bkb, kbg, weight, hs_grav, damage, crouch, angle, flipper, asdi_mult, ideal_di)
	local crouchReduction = 1
	local global_asdi = 30
	local kb_decay = 0.54

	local asdi = global_asdi * asdi_mult

	if crouch then
		crouchReduction = 0.8
	end

    local g_spike = 1

	if(flipper == 'SpecifiedAngle' and angle > 180 and angle < 360) then
        if math.abs(angle - 270) <= 30 then
            g_spike = 1.25
        elseif math.abs(angle - 270) >= 70 then
            g_spike = 1
        else
        	angle_diff_alpha = math.pow(1 - (math.abs(angle - 270) - 30) / 40, 2)
			g_spike = 1 + 0.25 * angle_diff_alpha
        end
	end
	
	local transformed_angle = math.abs(angle - 180)
	
	if ideal_di then
		if transformed_angle <= 90 then
			transformed_angle = math.max(0, transformed_angle - 18)
		elseif transformed_angle <= 180 then
			transformed_angle = math.min(180, transformed_angle + 18)
		end
	end

	if kbg == 0 then
		if (((((asdi + hs_grav) / math.sin(math.rad(transformed_angle))) + kb_decay) / (3 * crouchReduction)) - bkb) > 0 then
			return nil
			-- return 2
		else
			return 0
		end
	else    
		local percent = (((((asdi + hs_grav) / math.sin(math.rad(transformed_angle))) + kb_decay) / (3 * crouchReduction)) - bkb) * (weight + 100) / (200 * 0.12 * kbg * g_spike) - damage
		if percent <= 0 then
			return 0
		else
			-- return 3
			return math.ceil(percent)
			-- return dump({asdi, hs_grav,transformed_angle, kb_decay,crouchReduction,bkb,weight,kbg,g_spike,damage})
		end
	end
	return 0
end

local function calcSimpleTumble(result, crouch)
	if result.ForceTumble == "True" then
		return tooltip("☑️", "This always sends into tumble and knocks down.")
	end
	local d = result.Damage
	local bkb = result.BaseKnockback
	local kbg = tonumber(result.KnockbackScaling)
	local angle = tonumber(result.KnockbackAngle)
	local flipper = result.KnockbackAngleMode

	local lWeight = weightObject

	local minWeight = lWeight[1].Weight
	local maxWeight = lWeight[#(lWeight)].Weight

    if(flipper == 'SpecifiedAngle' and angle > 180 and angle < 360) then
        if result.bIgnoresWeight == "True" then
            local t_g = calcTumblePercent(bkb, kbg, 100, d, crouch, angle, flipper, true)
            local t_a = calcTumblePercent(bkb, kbg, 100, d, crouch, angle, flipper, false)
            if t_g ~= nil then
            	if crouch then
					return t_g .. '%'
				else
					return tooltip('⛰️', 'When grounded.') .. t_g .. '%<br>' .. tooltip('☁️', 'When airborne.') .. t_a .. '%'
				end
            else
                return "N/A"
            end
        else
            local min_t_g = calcTumblePercent(bkb, kbg, minWeight, d, crouch, angle, flipper, true)
            local max_t_g = calcTumblePercent(bkb, kbg, maxWeight, d, crouch, angle, flipper, true)
            local min_t_a = calcTumblePercent(bkb, kbg, minWeight, d, crouch, angle, flipper, false)
            local max_t_a = calcTumblePercent(bkb, kbg, maxWeight, d, crouch, angle, flipper, false)

            if min_t_g ~= nil then
            	if crouch then
            		return min_t_g .. ' - ' .. max_t_g .. '%'
            	else
					return tooltip('⛰️', 'When grounded.') .. min_t_g .. ' - ' .. max_t_g .. '%<br>' .. tooltip('☁️', 'When airborne.') .. min_t_a .. ' - ' .. max_t_a  .. "%"
        		end
            else
                return "N/A"
            end
        end
    else
        if result.bIgnoresWeight == "True" then
            local t = calcTumblePercent(bkb, kbg, 100, d, crouch, angle, flipper, true)
            if t ~= nil then
                return t .. '%'
            else
                return "N/A"
            end
        else
            local min_t = calcTumblePercent(bkb, kbg, minWeight, d, crouch, angle, flipper, true)
            local max_t = calcTumblePercent(bkb, kbg, maxWeight, d, crouch, angle, flipper, true)
            if min_t ~= nil then
                return min_t .. " - " .. max_t .. "%"
            else
                return "N/A"
            end
        end
    end
end

function displayFlugPopUp(result, crouch, ideal_di)
	local d = result.Damage
	local bkb = result.BaseKnockback
	local kbg = tonumber(result.KnockbackScaling)
	local angle = tonumber(result.KnockbackAngle)
	local flipper = result.KnockbackAngleMode
	
	if flipper ~= 'SpecifiedAngle' then
		return 'Varies'	
	end

	local asdi = tonumber(result.SDIMultiplier)
	if(tonumber(result.ASDIMultiplier) ~= -1) then
		asdi = tonumber(result.ASDIMultiplier)
	end
	
	local lWeight = weightObject

	local minPop = 999
	local maxPop = -1

	for k, v in ipairs(lWeight) do
		local shown_weight = 100
		if result.bIgnoresWeight == "False" then
			shown_weight = v.Weight
		end
		
		local f = calcFlugPopUpPercent(bkb, kbg, shown_weight, v.HitstunGravity, d, crouch, angle, flipper, asdi, ideal_di)
		if f == nil then
			return 'N/A'
		end
		-- return f
		-- return dump({bkb, kbg, shown_weight, v.HitstunGravity, d, crouch, angle, flipper, asdi})
		minPop = math.min(minPop, f)
		maxPop = math.max(maxPop, f)
	end

	return minPop .. ' - ' .. maxPop .. '%'
end

local function drawFrame(frames, frameType)
	local output = ''
	for i=1, tonumber(frames) do
		local frameDataHtml = mw.html.create('div')
		frameDataHtml:addClass('frame-data frame-data-' .. frameType)
		frameDataHtml:done()
		output = output .. tostring(frameDataHtml)
	end
	return output
end

local function drawFrameData(s1, s2, s3, s4)
	currentFrame = 0

	html = mw.html.create('div')
	html:addClass('frameChart')

	-- Startup of move, substract 1 if startupIsFirstActive
	local totalStartup = 0
	local startup = {}
	if s1 == nil then
	elseif tonumber(s1) ~= nil then
		startup[1] = tonumber(s1)
		totalStartup = startup[1]
	elseif string.find(s1,'+') then 
		for _, v in ipairs(mysplit(s1, '+')) do
			table.insert(startup, v)
			totalStartup = totalStartup + v
		end
	end
  
	-- Active of move
	
	active = {}
	first_active_frame = totalStartup + 1
	counter = 1
	if(s2 and s2 ~= "N/A") then
		csplit = mysplit(s2, ",")
		ATL = #(csplit)
		for i = 1, ATL do
			hyphen = #(mysplit(csplit[i], "-"))
			startFrame = mysplit(csplit[i], "-")[1]
			endFrame = mysplit(csplit[i], "-")[hyphen]
			if tonumber(startFrame) > first_active_frame  + 1 then
				active[counter] = -1 * (tonumber(startFrame) - first_active_frame  - 1)
				counter = counter + 1
			end
			active[counter] = endFrame - startFrame + 1
			counter = counter + 1
			first_active_frame = tonumber(endFrame)
		end
	end
	
	local totalEndlag = 0
	local endlag = {}
	processedEndlag = s3
	if(processedEndlag ~= nil) then
		if string.sub(processedEndlag, -3) == '...' then
			processedEndlag = string.sub(processedEndlag, 1, -4)
		end
		if tonumber(processedEndlag) ~= nil then
			endlag[1] = processedEndlag
			totalEndlag = tonumber(endlag[1])
		elseif string.find(processedEndlag,'+') then 
			for i=1, #(mysplit(processedEndlag, '+')) do
				endlag[i] = mysplit(processedEndlag, '+')[i]
				-- if ('...')
				totalEndlag = totalEndlag + endlag[i]
			end
		end
	end
	-- Special Recovery of move
	local landingLag = s4
	if(tonumber(landingLag) == nil) then
		landingLag = 0
	end

	-- if active ~= nil then
	-- 	html:tag('div'):addClass('frameChart-FAF'):wikitext(active[1]):done()
	-- end

	-- Create container for frame data
	frameChartDataHtml = mw.html.create('div')
	frameChartDataHtml:addClass('frameChart-data')
   
	alt = false
	for i=1, #(startup) do
		if not alt then
			frameChartDataHtml:wikitext(drawFrame(startup[i],  "startup"))
		else
			frameChartDataHtml:wikitext(drawFrame(startup[i],  "startup-alt"))
		end
		alt = not alt
	end

	-- Option for inputting multihits, works for moves with 1+ gaps in the active frames
	alt=false
	for i=1, #(active) do
		if active[i] < 0 then
			frameChartDataHtml:wikitext(drawFrame(active[i] * -1, "inactive"))
			alt=false
		elseif not alt then
			frameChartDataHtml:wikitext(drawFrame(active[i],  "active"))
		   alt = not alt
		else
			frameChartDataHtml:wikitext(drawFrame(active[i],  "active-alt"))
		   alt = not alt
	  end
	end
	alt = false
	for i=1, #(endlag) do
		if not alt then
			frameChartDataHtml:wikitext(drawFrame(endlag[i],  "endlag"))
		else
			frameChartDataHtml:wikitext(drawFrame(endlag[i],  "endlag-alt"))
		end
		alt = not alt
	end
	frameChartDataHtml:wikitext(drawFrame(landingLag, "landingLag"))
  
	local fdtotal = mw.html.create('div'):addClass('frame-data-total')
	fdtotal:node(mw.html.create('span'):addClass('frame-data-total-label'):wikitext('First Active Frame:'))
		
	if(s2 ~= nil) then
		fdtotal:node(mw.html.create('span'):addClass('frame-data-total-value'):wikitext(totalStartup + 1))
	else
		fdtotal:node(mw.html.create('span'):addClass('frame-data-total-value'):wikitext('N/A'))
	end
	fdtotal:done()
	html:node(frameChartDataHtml)
	html:node(fdtotal):done()

	return tostring(html) .. mw.getCurrentFrame():extensionTag{
		name = 'templatestyles', args = { src = 'Module:FrameChart/styles.css' }
	}
end

local function calcShieldSafety(result, mode, active, custom)
	if result.ExtraShieldStun == nil then
		return "N/A"
	end

	if
		mode.attackID == "Bthrow"
		or mode.attackID == "Uthrow"
		or mode.attackID == "Dthrow"
		or mode.attackID == "Fthrow"
	then
		return "N/A"
	end

	if mode.attackID == "Grab" or mode.attackID == "PivotGrab" or mode.attackID == "DashGrab" then
		return "N/A"
	end
	if mode.attackID == "Pummel" or mode.attackID == "PummelSpecial" then
		return "N/A"
	end

	if custom == 'N/A' then
		return 'N/A'
	end
	if custom ~= nil and custom ~= 'JAB' and custom ~= 'GALVAN' and custom ~= '-' then
		return custom
	end

	if tonumber(mode.totalDuration) then

		local stun = math.floor(result.Damage * 0.8 + 1) + result.ExtraShieldStun
		local active1 = mysplit(active, ", ")
		active1 = active1[#(active1)]
		local active2 = mysplit(active1, "-")
		local first = mode.totalDuration - active2[1] + 1
		local second = mode.totalDuration - active2[#(active2)] + 1

		if mode.landingLag ~= nil then
			if(custom == 'GALVAN') then
				local galvan_stan = 2 * stun + 1
				return string.format("%+d", stun - mode.landingLag - 1) .. '<br>' .. tooltip(string.format('[%+d]', galvan_stan - mode.landingLag - 1), "Advantage with drill.")
			else
				return string.format("%+d", stun - mode.landingLag - 1)
			end
		else
			if(custom == 'JAB') then
				local c = tonumber(mysplit(mode.cancel, ':')[2])
				local firstB = c - active2[1]
				local secondB = c - active2[#(active2)]
				if first == second then
					return string.format("%+d", stun - first) .. '<br>' .. tooltip(string.format('[%+d]', stun - firstB), "Advantage when move is cancelled ASAP.")
				else
					return string.format("%+d to %+d", stun - first, stun - second) .. '<br>' .. tooltip(string.format('[%+d to %+d]', stun - firstB, stun - secondB), "Advantage when move is cancelled ASAP.")
				end
			elseif(custom == 'GALVAN') then
				local galvan_stan = 2 * stun + 1
				if first == second then
					return string.format("%+d", stun - first) .. '<br>' .. tooltip(string.format('[%+d]', galvan_stan - first), "Advantage with drill.")
				else
					return string.format("%+d to %+d", stun - first, stun - second) .. '<br>' .. tooltip(string.format('[%+d to %+d]', galvan_stan - first, galvan_stan - second), "Advantage with drill.")
				end
			else
				if first == second then
					return string.format("%+d", stun - first)
				else
					return string.format("%+d to %+d", stun - first, stun - second)
				end
			end
		end
	else
		return 'N/A'
	end
end

-- Calculates floorhug hitstun of a move.
-- TODO: Add extra hitpause and tipstun considerations.
local function calcFloorhugStun(result, mode, hitData, cc)
	if
		mode.attackID == "Bthrow"
		or mode.attackID == "Uthrow"
		or mode.attackID == "Dthrow"
		or mode.attackID == "Fthrow"
		or mode.attackID == "Grab"
		or mode.attackID == "Pummel"
		or mode.attackID == "PummelSpecial"
	then
		return "N/A"
	end
	
	if result.KnockbackAngleMode == 'SpecifiedAngle' and tonumber(result.KnockbackAngle) < 360 and tonumber(result.KnockbackAngle) > 180 then
		return "N/A"
	end

	local flug_stun = 8
	hitstun_cap = 8
	if cc then
		hitstun_cap = 5
	end

	if(tonumber(result.KnockbackScaling) ~= 0) then
		flug_stun = math.min(math.max(((26 * (4.07/3) * result.HitstunMultiplier) - 1)/2, 4), hitstun_cap) + result.ExtraHitpauseForOpponent
		-- flug_stun = (26 * (4.07/3) * result.HitstunMultiplier)
	else
		if not cc then
			flug_stun = math.min(math.max(((3 * (result.BaseKnockback) * (4.07/3) * result.HitstunMultiplier) - 1)/2, 4), hitstun_cap) + result.ExtraHitpauseForOpponent
			-- flug_stun = (3 * tonumber(result.BaseKnockback) * (4.07/3) * tonumber(result.HitstunMultiplier)) - 1
		else
			flug_stun = math.min(math.max(((3 * (result.BaseKnockback) * 0.8 * (4.07/3) * result.HitstunMultiplier) - 1)/2, 4), hitstun_cap) + result.ExtraHitpauseForOpponent
			-- flug_stun = (3 * 0.8 * tonumber(result.BaseKnockback) * (4.07/3) * tonumber(result.HitstunMultiplier)) - 1
		end
	end
	
	flug_stun = math.floor(flug_stun) + result.ExtraHitpauseForOpponent
	if result.SpecialEffect == "TipperStun" and not cc then
		local uniquesList = mysplit(hitData.unique, "\\")
		for k, v in pairs(uniquesList) do
			if v:find("Tipstun: ") then
				flug_stun = flug_stun + tonumber(v:match('%d+'))
			end
		end
	end
	
	return flug_stun
end

local function calcFloorhugSafety(result, mode, active, custom, flug_stun)
	if
		mode.attackID == "Bthrow"
		or mode.attackID == "Uthrow"
		or mode.attackID == "Dthrow"
		or mode.attackID == "Fthrow"
		or mode.attackID == "Grab"
		or mode.attackID == "Pummel"
		or mode.attackID == "PummelSpecial"
	then
		return "N/A"
	end

	if mode.attackID == "Grab" then
		return "N/A"
	end
	if mode.attackID == "Pummel" or mode.attackID == "PummelSpecial" then
		return "N/A"
	end
	
	if result.KnockbackAngleMode == 'SpecifiedAngle' and tonumber(result.KnockbackAngle) < 360 and tonumber(result.KnockbackAngle) > 180 then
		return "N/A"
	end

	if custom == 'N/A' then
		return 'N/A'
	end
	if custom ~= nil and custom ~= 'JAB' and custom ~= '-' then
		return custom
	end

	if tonumber(mode.totalDuration) then
		local stun = flug_stun + 1
		-- done this way so that the code after is the same as the shield safety code

		local active1 = mysplit(active, ", ")
		active1 = active1[#(active1)]
		local active2 = mysplit(active1, "-")
		local first = mode.totalDuration - active2[1] + 1
		local second = mode.totalDuration - active2[#(active2)] + 1

		if mode.landingLag ~= nil then
			return string.format("%+d", stun - mode.landingLag - 1)
		else
			if(custom == 'JAB') then
				local c = tonumber(mysplit(mode.cancel, ':')[2])
				local firstB = c - active2[1]
				local secondB = c - active2[#(active2)]
				if first == second then
					return string.format("%+d", stun - first) .. '<br>' .. tooltip(string.format('[%+d]', stun - firstB), "Advantage when move is cancelled ASAP.")
				else
					return string.format("%+d to %+d", stun - first, stun - second) .. '<br>' .. tooltip(string.format('[%+d to %+d]', stun - firstB, stun - secondB), "Advantage when move is cancelled ASAP.")
				end
				
			else
				if first == second then
					return string.format("%+d", stun - first)
				else
					return string.format("%+d to %+d", stun - first, stun - second)
				end
			end
		end
	else
		return 'N/A'
	end
end

local function makeAngleDisplay(angle, flipper, reverse)
	angle = tonumber(angle)
	if(flipper ~= 'SpecifiedAngle' and flipper ~= nil) then
		return tostring(tooltip('*', 'This move has a unique angle flipper of ' ..  flipper .. '.'))
	else
		local angleColor = mw.html.create('span'):wikitext(angle)
		if(angle <= 45 or angle >= 315) then
			angleColor:css('color', '#1ba6ff')
		elseif(angle > 225) then
			angleColor:css('color', '#ff6b6b')
		elseif(angle > 135) then
			angleColor:css('color', '#de7cd1')
		elseif(angle > 45) then
			angleColor:css('color', '#16df53')
		end

		local display = mw.html.create('span')
		local div1 = mw.html.create('div'):css('position', 'relative'):css('top', '0'):css('max-width', '256px')
			:tag('div'):css('transform', 'rotate(-'.. angle ..'deg)'):css('z-index', '0'):css('position', 'absolute'):css('top', '0'):css('left', '0'):css('transform-origin', 'center center'):wikitext('[[File:ROA2_AngleComplex_BG.png|256px|link=]]'):done()
			:tag('div'):css('z-index', '1'):css('position', 'relative'):css('top', '0'):css('left', '0'):wikitext('[[File:ROA2_AngleComplex_MG.png|256px|link=]]'):done()
			:tag('div'):css('transform', 'rotate(-'.. angle ..'deg)'):css('z-index', '2'):css('position', 'absolute'):css('top', '0'):css('left', '0'):css('transform-origin', 'center center'):wikitext('[[File:ROA2_AngleComplex_FG.png|256px|link=]]'):done()
		if reverse then
			div1:wikitext("This hit can reverse, sending depending on the attacker's position to the defender.")
		else
			div1:wikitext("This hit cannot reverse, sending depending on which way the attacker is facing.")
		end
		div1:done()
		display:node(div1):wikitext('[[File:ROA2_AngleComplex_Key.png|256px|link=]]')
		display:done()
		return tostring(tooltip(tostring(angleColor), tostring(display)))
	end

end

local function showHitUniques(hasArticle, result, unique)
	local listOfUniques = {}

	if unique ~= nil then
		local uniquesList = mysplit(unique, "\\")
		for k, v in pairs(uniquesList) do
			table.insert(listOfUniques, v)
		end
	end

	if(hasArticle) then
		if(result.ParryReaction == 'NoStun') then
			table.insert(listOfUniques, "No Parry Stun (Article)")
		elseif(result.ParryReaction == 'Stun') then
			table.insert(listOfUniques, "Parry Stun (Article)")
		end
	end
	if
		result.SpecialEffect ~= "None"
		and result.SpecialEffect ~= "AutoTipperOnly"
		and result.SpecialEffect ~= "TipperStun"
		and result.SpecialEffect ~= "Zap"
	then
		if result.SpecialEffect == "Poison" then
			table.insert(listOfUniques, "Poison (1)")
		elseif result.SpecialEffect == "DoublePoison" then
			table.insert(listOfUniques, "Poison (2)")
		else
			table.insert(listOfUniques, result.SpecialEffect)
		end
	end

	if
		result.moveID == "Bthrow"
		or result.moveID == "Uthrow"
		or result.moveID == "Dthrow"
		or result.moveID == "Fthrow"
	then
		table.insert(listOfUniques, tooltip("Throw", "ASDI/SSDI is disabled, weight independent."))
		if result.bIgnoresWeight ~= "True" then
			table.insert(listOfUniques, tooltip("Weight Error", "For some reason, this throw is weight dependent."))
		end
	else
		if result.bIgnoresWeight == "True" then
			table.insert(
				listOfUniques,
				tooltip("Ignores Weight", "Treats all characters as if they weigh 100, the same as Orcane.")
			)
		end
		local SDIString = {}
		if result.SDIMultiplier ~= "1" then
			table.insert(SDIString, "SSDI: " .. result.SDIMultiplier .. "×")
			if result.ASDIMultiplier == "-1" then
				table.insert(SDIString, "ASDI: " .. result.SDIMultiplier .. "×")
			elseif result.ASDIMultiplier ~= "1" then
				table.insert(SDIString, "ASDI: " .. result.ASDIMultiplier .. "×")
			end
		elseif result.ASDIMultiplier ~= "-1" then
			table.insert(SDIString, "ASDI: " .. result.ASDIMultiplier .. "×")
		end
		if #(SDIString) > 0 then
			table.insert(listOfUniques, tostring(table.concat(SDIString, ", ")))
		end
	end

	local HitstunString = {}
	if result.HitstunMultiplier ~= "1" then
		table.insert(HitstunString, "Hitstun: " .. result.HitstunMultiplier .. "×")
		if result.HitfallHitstunMultiplier ~= "1" then
			table.insert(
				HitstunString,
				"Hitfall: " .. result.HitstunMultiplier * result.HitfallHitstunMultiplier .. "×"
			)
		end
	else
		if result.HitfallHitstunMultiplier ~= "1" then
			table.insert(HitstunString, "Hitfall: " .. result.HitfallHitstunMultiplier .. "×")
		end
	end
	if #(HitstunString) > 0 then
		table.insert(listOfUniques, tostring(table.concat(HitstunString, ", ")))
	end

	if result.ShieldDamageMultiplier ~= "1" then
		table.insert(listOfUniques, "Shield Damage: " .. result.ShieldDamageMultiplier .. "×")
	end
	if result.ExtraHitpauseForOpponent ~= "0" then
		table.insert(listOfUniques, tooltip("Extra Hitpause", "Only applies to opponent.") ..  ': ' .. result.ExtraHitpauseForOpponent)
	end
	if result.ShieldPushbackMultiplier ~= "1" then
		table.insert(listOfUniques, "Shield Pushback: " .. result.ShieldPushbackMultiplier .. "×")
	end
	if result.ShieldHitpauseMultiplier ~= "1" then
		table.insert(listOfUniques, "Shield Hitpause: " .. result.ShieldHitpauseMultiplier .. "×")
	end
	if result.GroundTechable ~= "True" and result.moveID ~= "Pummel" and result.moveID ~= "PummelSpecial" then
		table.insert(listOfUniques, tooltip("Untechable", "Cannot be ground teched. Can still be wall/ceiling teched."))
	end
	if result.bForceFlinch == "True" then
		table.insert(listOfUniques, "Forces Flinch")
	end

	-- if(result.bAutoFloorhuggable == 'True') then
	-- 	table.insert(listOfUniques, 'Auto-Floorhuggable')
	-- end

	if #(listOfUniques) <= 0 then
		return nil
	else
		return table.concat(listOfUniques, ", ")
	end
	return
end
local function showThrowUniques(result, unique)
	local listOfUniques = {}

	if unique ~= nil then
		local uniquesList = mysplit(unique, "\\")
		for k, v in pairs(uniquesList) do
			table.insert(listOfUniques, v)
		end
	end
	table.insert(listOfUniques, tooltip("True Throw", "No ASDI/SSDI due to no hitpause."))

	if result.bTechable ~= "True" then
		table.insert(listOfUniques, tooltip("Untechable", "Cannot be ground teched. Can still be wall/ceiling teched."))
	end
	if result.HitstunMultiplier ~= "1" then
		table.insert(listOfUniques, "Hitstun: " .. result.HitstunMultiplier .. "×")
	end

	-- if(result.bAutoFloorhuggable == 'True') then
	-- 	table.insert(listOfUniques, 'Auto-Floorhuggable')
	-- end

	if #(listOfUniques) <= 0 then
		return nil
	else
		return table.concat(listOfUniques, ", ")
	end
	return
end

local function getArticles(articleData)
	local fields =
		"ArticleName,bIsProjectile,bRotateWithVelocity,bInheritOwnerChargeValue,bIsAttachedToOwner,ParryReaction,HasHitReaction,GotHitReaction,bCanBeHitByOwner,bCanDetectOwner,GroundCollisionResponse,WallCollisionResponse,CeilingCollisionResponse,ShouldGetOutOfGroundOnSpawn"
	
	local hitRow = mw.html.create("tr")
	for k, v in ipairs(mysplit(fields, ",")) do
		local assignedValue = firstToUpper(articleData[v])
		if assignedValue == nil then
			assignedValue = "N/A"
		end
		local cell = mw.html.create("td"):wikitext(assignedValue):done()
		hitRow:node(cell)
	end

	hitRow:done()
	return hitRow
end

local function getHits(hasArticle, result, mode, hitData)
	--chara, attackID, hitID, hitMoveID, hitName, hitActive, customShieldSafety, uniques
	local hitRow = mw.html.create("tr"):addClass("hit-row")
	hitRow
		:tag("td"):wikitext(hitData.name)
		:tag("td"):wikitext(result.Damage .. "%")
		:tag("td"):wikitext(hitData.active)
	if tonumber(result.FinalBaseKnockback) == 0 then
		hitRow:tag("td"):wikitext(string.format("%.1f", result.BaseKnockback))
	else
		hitRow:tag("td"):wikitext(string.format("%.1f", result.BaseKnockback) .. " - " .. string.format("%.1f", result.FinalBaseKnockback))
	end
	hitRow
		:tag("td"):wikitext(result.KnockbackScaling)
		:tag("td"):wikitext(makeAngleDisplay(result.KnockbackAngle, result.KnockbackAngleMode, result.bCanReverse))
		:tag("td"):wikitext(calcSimpleTumble(result, false))
		:tag("td"):wikitext(calcSimpleTumble(result, true))
		:tag("td"):wikitext(calcShieldSafety(result, mode, hitData.active, hitData.shield))
	:done()
	return hitRow
end

local function getThrows(result, mode, hitData)
	local hitRow = mw.html.create("tr"):addClass("hit-row")
	hitRow
		:tag("td"):wikitext(hitData.name)
		:tag("td"):wikitext(result.Damage .. "%")
		:tag("td"):wikitext(hitData.active)
		:tag("td"):wikitext(string.format("%.1f", result.BaseKnockback))
		:tag("td"):wikitext(string.format("%.1f", result.KnockbackScaling))
		:tag("td"):wikitext(makeAngleDisplay(result.KnockbackAngle))
		:tag("td"):wikitext(calcSimpleTumble(result, false))
		:tag("td"):wikitext("N/A")
		:tag("td"):wikitext("N/A")
		:done()
	return hitRow
end

local function getAdvHits(result, mode, hitData, articleData)
	--chara, attackID, hitID, hitMoveID, hitName, hitActive, customShieldSafety, uniques

	local columns =
		"moveID,SpecialEffect,ParryReaction,HitpauseMultiplier,ExtraHitpauseForOpponent,SDIMultiplier,ASDIMultiplier,ExtraShieldStun,ShieldDamageMultiplier,ShieldPushbackMultiplier,ShieldHitpauseMultiplier,HitstunMultiplier,HitfallHitstunMultiplier,FullChargeKnockbackMultiplier,FullChargeDamageMultiplier,bCanReverse,bForceFlinch,GroundTechable,bIgnoresWeight,bAutoFloorhuggable,ProjectileInteraction,bForceKnockbackInKnockdown,bPreserveFacing,GrabPartnerInteraction,ForceTumble,IgnoreKnockbackArmor,PreventChaingrabsOnHit"

	local hitRow = mw.html.create("tr")
	hitRow:node(mw.html.create("td"):wikitext(hitData.name))
	
	for k, v in ipairs(mysplit(columns, ",")) do
		local assignedValue = ""
		if v == "HitpauseMultiplier" then
			assignedValue = math.min(math.max(math.floor(result["HitpauseMultiplier"] * result.Damage), 3), 24)
		elseif v == "ExtraHitpauseForOpponent" then
			assignedValue = math.min(math.max(math.floor(result["HitpauseMultiplier"] * result.Damage), 3), 24) + result["ExtraHitpauseForOpponent"]
		elseif v == "ASDIMultiplier" then
			if result[v] == "-1" then
				assignedValue = result["SDIMultiplier"] .. "×"
			else
				assignedValue = result[v] .. "×"
			end
		elseif
			v == "HitstunMultiplier"
			or v == "HitfallHitstunMultiplier"
			or v == "SDIMultiplier"
			or v == "FullChargeKnockbackMultiplier"
			or v == "FullChargeDamageMultiplier"
		then
			assignedValue = result[v] .. "×"
		elseif v == "ExtraShieldStun" then
			assignedValue = math.max(2, math.floor(result.Damage * 0.8 + 1) + result.ExtraShieldStun)
		elseif v == "ShieldDamageMultiplier" then
			assignedValue = result.ShieldDamageMultiplier
				* (0.045 * result.Damage * result.Damage + 0.68 * result.Damage)
		elseif v == "ShieldPushbackMultiplier" then
			assignedValue = result.ShieldPushbackMultiplier * (result.Damage * 0.8 + 2)
		elseif v == "ShieldHitpauseMultiplier" then
			assignedValue = math.min(
				math.max(
					math.floor(result["HitpauseMultiplier"] * result.Damage * result.ShieldHitpauseMultiplier),
					3
				),
				24
			)
			if articleData ~= nil and #articleData > 0 then
				-- assignedValue = dump(hitData)
				for _, v in ipairs(articleData) do
					if(v['moveID'] == hitData.move) then
						-- assignedValue = assignedValue .. dump(v)
						if (v['bIsProjectile']) then
							assignedValue = math.min(
								math.max(
									math.floor(result["HitpauseMultiplier"] * result.Damage * result.ShieldHitpauseMultiplier * 0.5),
									3
								),
								24
							)
						end
						break
					end
				end
			end
		else
			assignedValue = result[v]
		end
		local cell = mw.html.create("td"):wikitext(assignedValue):done()
		hitRow:node(cell)
	end

	hitRow:done()
	return hitRow
end

local function getFlugs(result, mode, hitData, articleData)
	--chara, attackID, hitID, hitMoveID, hitName, hitActive, customShieldSafety, uniques

	local hitRow = mw.html.create("tr")
	
	local asdi = tonumber(result.SDIMultiplier)
	if(tonumber(result.ASDIMultiplier) ~= -1) then
		asdi = tonumber(result.ASDIMultiplier)
	end
	
	hitRow:node(mw.html.create("td"):wikitext(hitData.name))

	-- Case #1: The move is a throw and therefore cannot be ASDIed.
	if
		mode.attackID == "Bthrow"
		or mode.attackID == "Uthrow"
		or mode.attackID == "Dthrow"
		or mode.attackID == "Fthrow"
		or mode.attackID == "Grab"
		or mode.attackID == "Pummel"
		or mode.attackID == "PummelSpecial"
	then
		hitRow:tag("td"):wikitext("This hit is actually a throw, so it cannot be floorhugged."):attr("colspan", 8)
	-- Case #2: The move has 0x ASDI. There is literally nothing to show here. Everything is 0.
	elseif asdi == 0 then
		hitRow:tag("td"):wikitext("This hit has 0x ASDI, so it cannot be floorhugged."):attr("colspan", 8)
	-- Case #3: The move is a spike. While stun is not showable, pop ups are still significant to show.
	elseif result.KnockbackAngleMode == 'SpecifiedAngle' and tonumber(result.KnockbackAngle) < 360 and tonumber(result.KnockbackAngle) > 180 then
		hitRow:node(mw.html.create("td"):wikitext('This hit is a spike, so it cannot be floorhugged before knocking down.'):attr("colspan", 4))
		hitRow:node(mw.html.create("td"):wikitext(displayFlugPopUp(result, false, false)))
		hitRow:node(mw.html.create("td"):wikitext(displayFlugPopUp(result, false, true)))
		hitRow:node(mw.html.create("td"):wikitext(displayFlugPopUp(result, true, false)))
		hitRow:node(mw.html.create("td"):wikitext(displayFlugPopUp(result, true, true)))
	-- Case #4: This move is a strong.
	elseif result.bAutoFloorhuggable == 'False' and (mode.attackID == 'Fstrong' or mode.attackID == 'Ustrong' or mode.attackID == 'Dstrong') then
		hitRow:node(mw.html.create("td"):wikitext('This strong hit will always knock down when floorhugged.'):attr("colspan", 4))
		hitRow:node(mw.html.create("td"):wikitext(displayFlugPopUp(result, false, false)))
		hitRow:node(mw.html.create("td"):wikitext(displayFlugPopUp(result, false, true)))
		hitRow:node(mw.html.create("td"):wikitext(displayFlugPopUp(result, true, false)))
		hitRow:node(mw.html.create("td"):wikitext(displayFlugPopUp(result, true, true)))
	-- Case #5: This move always tumbles.
	elseif result.ForceTumble == "True" then
		hitRow:node(mw.html.create("td"):wikitext('This hit will always knock down.'):attr("colspan", 4))
		hitRow:node(mw.html.create("td"):wikitext(displayFlugPopUp(result, false, false)))
		hitRow:node(mw.html.create("td"):wikitext(displayFlugPopUp(result, false, true)))
		hitRow:node(mw.html.create("td"):wikitext(displayFlugPopUp(result, true, false)))
		hitRow:node(mw.html.create("td"):wikitext(displayFlugPopUp(result, true, true)))
	else
		local flug_stun = calcFloorhugStun(result, mode, hitData, false)
		local cc_stun = calcFloorhugStun(result, mode, hitData, true)
		hitRow:node(mw.html.create("td"):wikitext(calcFloorhugSafety(result, mode, hitData.active, hitData.shield, flug_stun)))
		hitRow:node(mw.html.create("td"):wikitext(calcFloorhugSafety(result, mode, hitData.active, hitData.shield, cc_stun)))
		hitRow:node(mw.html.create("td"):wikitext(flug_stun))
		hitRow:node(mw.html.create("td"):wikitext(cc_stun))
		hitRow:node(mw.html.create("td"):wikitext(displayFlugPopUp(result, false, false)))
		hitRow:node(mw.html.create("td"):wikitext(displayFlugPopUp(result, false, true)))
		hitRow:node(mw.html.create("td"):wikitext(displayFlugPopUp(result, true, false)))
		hitRow:node(mw.html.create("td"):wikitext(displayFlugPopUp(result, true, true)))
	end
	hitRow:done()
	return hitRow
end

local function getAdvThrows(result, mode, hitData)
	local fields = "HitstunMultiplier,bTechable,ForceTumble,HitstunAnimationStateOverride,ReleaseOffset"

	local hitRow = mw.html.create("tr")
	hitRow:node(mw.html.create("td"):wikitext(hitData.name))

	for k, v in ipairs(mysplit(fields, ",")) do
		local assignedValue = ""
		if v == "HitstunMultiplier" then
			assignedValue = result[v] .. "×"
		else
			assignedValue = result[v]
		end
		local cell = mw.html.create("td"):wikitext(assignedValue):done()
		hitRow:node(cell)
	end

	hitRow:done()
	return hitRow
end

local function createMode(hasArticle, mode, motherhits, hitresults, throwresults)
	-- Frame Window
	local frameWindow = mw.html.create("tbody")
	local columnHeaders = {
		tooltip("Startup", "Startup or First Active Frame, the time it takes for an attack to become active. For example, a startup value of \"10\" means the hitbox or relevant property is active on the 10th frame."),
		tooltip("Total Active", "Frames during which the move is active."),
		tooltip("Endlag", "The amount of frames where the move is no longer active."),
		tooltip("Cancels", "Ways that the move can be cancelled."),
		tooltip(
			"Landing Lag",
			"The amount of frames that the character has to wait after landing with this move before becoming actionable."
		),
		tooltip("Total Duration", "Currently refers to the amount of frames before the move is considered interruptible, as opposed to the full animation length. Interruptible frames are relevant in only a few situations, including when non-finisher Jabs can be cancelled or when Down Tilts transition into crouch state."),
	}
	local headersRow = mw.html.create("tr"):addClass("frame-window-header")
	for k, v in pairs(columnHeaders) do
		local cell = mw.html.create("th"):wikitext(v):css("width", "16%"):done()
		headersRow:node(cell)
	end
	headersRow:done()

	local columnValues = {}

	local startupSum = 0

 	
	columnValues["startup"] = "N/A"
	
	if mode.startup == nil then
		if mode.totalActive ~= nil then
			local processed_active = mode.totalActive
			if string.find(processed_active, "+") then
				processed_active = mysplit(processed_active, "+")[1]
			end
			columnValues["startup"] = mysplit(mysplit(processed_active, ",")[1], "-")[1]
			mode.startup = mysplit(mysplit(processed_active, ",")[1], "-")[1] - 1
		else
			columnValues["startup"] = "N/A"
		end
	else
		if tonumber(mode.startup) then
			columnValues["startup"] = mode.startup + 1
			startupSum = mode.startup
		else
			columnValues["startup"] = mode.startup
			startupSum = mode.startup
		end
		if string.find(mode.startup, "+") and not string.find(mode.startup, "%[") then
			startupSum = 0
			for i in pairs(mysplit(mode.startup, "+")) do
				startupSum = startupSum + tonumber(mysplit(mode.startup, "+")[i])
			end
	
			columnValues["startup"] = tostring(startupSum + 1) .. " [" .. columnValues["startup"] .. "]"
		end
	end
	if mode.startupNotes then
		if mode.startupNotes == "STRONG" then
			columnValues["startup"] = columnValues["startup"]
				.. " "
				.. tooltip("ⓘ", "Total Uncharged Startup<br>[Pre-Charge Window + Post-Charge Window]")
		elseif mode.startupNotes == "LAVASTRONG" then
			columnValues["startup"] = columnValues["startup"]
				.. " "
				.. tooltip("ⓘ", "Total Minimum Startup<br>[Pre-Charge Window + Minimum Lava Charge + Post-Charge Window]")
		else
			columnValues["startup"] = columnValues["startup"] .. " " .. tooltip("ⓘ", mode.startupNotes)
		end
	end

	columnValues["totalActive"] = 'N/A'
	if mode.totalActive then
		columnValues["totalActive"] = mode.totalActive	
	end
	if mode.totalActiveNotes then
		columnValues["totalActive"] = columnValues["totalActive"] .. " " .. tooltip("ⓘ", mode.totalActiveNotes)
	end
	columnValues["endlag"] = mode.endlag
	if mode.endlag == nil or mode.endlag == "..." then
		if mode.totalActive and tonumber(mode.totalDuration) then
			local catch = mysplit(mode.totalActive, ",")
			local catch2 = mysplit(catch[#catch], "-")
	
			if mode.iasa ~= nil then
				columnValues["endlag"] = mode.iasa - 1 - catch2[#catch2]
				if mode.endlag then
					columnValues["endlag"] = columnValues["endlag"] ..mode.endlag
				end
				mode.endlag = mode.iasa - 1 - catch2[#catch2]
			else
				columnValues["endlag"] = mode.totalDuration - catch2[#catch2]
				if mode.endlag then
					columnValues["endlag"] = columnValues["endlag"] ..mode.endlag
				end
				mode.endlag = mode.totalDuration - catch2[#catch2]
			end
		else
			columnValues["endlag"] = "N/A"
			mode.endlag = 0
		end
	end
	if mode.endlagNotes then
		columnValues["endlag"] = columnValues["endlag"] .. " " .. tooltip("ⓘ", mode.endlagNotes)
	end
	columnValues["cancel"] = mysplit(mode.cancel, "\n")
	if mode.cancelNotes then
		for i, v in ipairs(mysplit(mode.cancelNotes, "\n")) do
			columnValues["cancel"][i] = columnValues["cancel"][i] .. " " .. tooltip("ⓘ", v)
		end
	end
	columnValues["landingLag"] = mode.landingLag
	if mode.landingLagNotes then
		columnValues["landingLag"] = columnValues["landingLag"] .. " " .. tooltip("ⓘ", mode.landingLagNotes)
	end
	if mode.totalDuration == nil then
		local td_active = startupSum
		if mode.totalActive ~= nil then
			local _, _, p = mode.totalActive:reverse():find('(%d+)')
			if p ~= nil then
				td_active = p:reverse()
			end
		end
		local td_endlag = 0
		if mode.endlag ~= nil then
			td_endlag = mode.endlag
			if string.find(mode.endlag, '...') then
				td_endlag = nil
			elseif string.find(mode.endlag, '+') then
				td_endlag = 0
				for _, i in ipairs(mysplit(mode.endlag, '+')) do
					td_endlag = td_endlag + tonumber(i)
				end
			end
		end
		if tonumber(td_endlag) and tonumber(td_active) then
			mode.totalDuration = td_active + td_endlag
		end
	end
	columnValues["totalDuration"] = mode.totalDuration
	if mode.totalDurationNotes then
		columnValues["totalDuration"] = columnValues["totalDuration"] .. " " .. tooltip("ⓘ", mode.totalDurationNotes)
	end

	local dataRow = mw.html.create("tr"):addClass("frame-window-data")
	local columnValuesTags = { "startup", "totalActive", "endlag", "cancel", "landingLag", "totalDuration" }
	for k, v in ipairs(columnValuesTags) do
		local cell = mw.html.create("td")
		if columnValues[v] then
			if v == "endlag" and string.sub(columnValues[v], -3) == "..." then
				cell:tag("i"):wikitext(columnValues[v])
			elseif v == "cancel" then
				for i, v2 in pairs(columnValues[v]) do
					cell:tag("p"):wikitext(v2)
				end
			else
				cell:wikitext(columnValues[v])
			end
		else
			cell:wikitext("N/A")
		end
		cell:done()
		dataRow:node(cell)
	end
	dataRow:done()

	local t = mw.html
		.create("table")
		:addClass("frame-window wikitable ")
		:css("width", "100%")
		:css("text-align", "center")
		:node(headersRow)
		:node(dataRow)
		:done()
		
	if mode.notes ~= nil then
		local notesRow = mw.html
			.create("tr")
			:addClass("notes-row")
			:tag("td")
			:css("text-align", "left")
			:attr("colspan", "100%")
			:wikitext("'''Notes:''' " .. mode.notes)
		t:node(notesRow)
	end
	t:done()

	local frameChart = mw.html
		.create("div")
		:addClass("frame-chart")
		
	if(mode.frameChart ~= nil) then
		if(mode.frameChart == 'N/A') then
			frameChart:wikitext("''This frame chart is currently unavailable and will be added at a later time.''"):done()
		else
			frameChart:wikitext(mode.frameChart):done()
		end
	else
		frameChart:wikitext(drawFrameData(mode.startup,mode.totalActive,mode.endlag,mode.landingLag)):done()
	end

	local numbersPanel = mw.html.create("div"):addClass("numbers-panel"):node(t):node(frameChart)
	if mode.hitID ~= nil then
		local headersHitRow = mw.html.create("tr")
		local hitHeaders = {
			tooltip(
				"Hit / Hitbox",
				"Which hit timing (such as early or late), or hitbox (such as sweetspot or sourspot) of this move that the data to the right is referring to."
			),
			tooltip("Damage", "The raw damage percent value of the listed move/hit."),
			tooltip("Active Frames", "Which frames a move is active and can affect opponents."),
			tooltip("BKB", "Base Knockback. The higher this amount, the more knockback the hit deals at all percents. When this amount is an interval, it means that the base knockback starts at the first number and linearly progresses to the second number across the hit's active frames."),
			tooltip("KBS", "Knockback Scaling. The higher this amount, the more knockback the hit deals at higher percents."),
			tooltip("Angle", "The angle at which the move sends the target."),
			tooltip("Knockdown %", "The percent that sends an opponent into [[RoA2/System_Mechanics/Knockdown|tumble]], aka being knocked down when landing. Can range from the lightest to the heaviest character."),
			tooltip("CC %", "The percent that causes a crouching opponent to enter knockdown when landing from this hit. Can range from the lightest to the heaviest character."),
			tooltip("Shield Safety", "The frame advantage after a move connects on shield. Assumes best case scenario for moves that use landing lag."),
		}

		for k, v in pairs(hitHeaders) do
			local cell = mw.html.create("th"):wikitext(v):css("width", "10%"):done()
			headersHitRow:node(cell)
		end

		local hitsWindow = mw.html.create("table"):addClass("wikitable hits-window"):node(headersHitRow)

		if hitresults ~= nil then 
			for k, v in ipairs(hitresults) do
				hitsWindow:node(getHits(hasArticle, hitresults[k], mode, motherhits[hitresults[k].moveID .. hitresults[k].nameID]))
				local uniqueRow = showHitUniques(hasArticle, hitresults[k], motherhits[hitresults[k].moveID .. hitresults[k].nameID].unique)
				if uniqueRow then
					hitsWindow:tag("tr"):addClass("unique-row"):tag("td"):attr("colspan", 8):css("text-align", "left"):wikitext("'''Unique''': " .. uniqueRow):done()
				end
			end
		end
		if throwresults ~= nil then 
			for k, v in ipairs(throwresults) do
				hitsWindow:node(getThrows(throwresults[k], mode, motherhits[throwresults[k].moveID .. throwresults[k].throwNumber]))
				local uniqueRow = showThrowUniques(throwresults[k], motherhits[throwresults[k].moveID .. throwresults[k].throwNumber].unique)
				if uniqueRow then
					hitsWindow:tag("tr"):addClass("unique-row"):tag("td"):attr("colspan", 8):css("text-align", "left"):wikitext("'''Unique''': " .. uniqueRow):done()
				end
			end
		end
		numbersPanel:node(hitsWindow)
	end

	numbersPanel:done()
	return tostring(numbersPanel)
end

local function createAdvMode(mode, articleList, motherhits, hitresults, throwresults)
	local finalreturn = mw.html.create("div")

	if articleList ~= nil and #articleList > 0 then
		local nerdHeader = mw.html
			.create("div")
			:addClass("toccolours mw-collapsible")
			:css("width", "100%")
			:css("overflow", "auto")
			:css("margin", "1em 0")
			:done()
		local nerdTitle = mw.html
			.create("div")
			:css("font-weight", "bold")
			:css("line-height", "1.6")
			:wikitext("'''Articles:'''")
			:done()
		local c1 = mw.html.create("div"):addClass("mw-collapsible-content")

		local columnHeaders = {
			"Article Name",
			"Projectile?",
			"Rotates with Velocity",
			"Inherits Owner Charge Value",
			"Attached to Owner?",
			"Parry Reaction",
			"Has Hit Reaction",
			"Got Hit Reaction",
			"Hittable By Owner?",
			"Can Detect Owner?",
			"Ground Collision",
			"Wall Collision",
			"Ceiling Collision",
			"Should Get Out of Ground On Spawn",
		}

		local headersRow = mw.html.create("tr"):addClass("adv-arts-list-header")
		for k, v in pairs(columnHeaders) do
			local cell = mw.html.create("th"):wikitext(v):done()
			headersRow:node(cell)
		end
		headersRow:done()

		local artsWindow = mw.html.create("table"):addClass("arts-window wikitable"):node(headersRow)

		for k, v in pairs(articleList) do
			artsWindow:node(getArticles(v))
		end
		artsWindow:done()
		c1:node(artsWindow):done()
		nerdHeader:node(nerdTitle):node(c1)
		finalreturn:node(nerdHeader)
	end

	if mode.hitID ~= nil then		
		if hitresults ~= nil and #(hitresults) ~= 0 then
			local nerdHeader = mw.html
				.create("div")
				:addClass("toccolours mw-collapsible")
				:css("width", "100%")
				:css("overflow", "auto")
				:css("margin", "1em 0")
				:done()
			local nerdTitle = mw.html
				.create("div")
				:css("font-weight", "bold")
				:css("line-height", "1.6")
				:wikitext("'''Hits: Advanced Data'''")
				:done()
			local c1 = mw.html.create("div"):addClass("mw-collapsible-content")

			local columnHeaders = {
				"Hit / Hitbox ",
				"Parent Attack",
				"Special Effect",
				"Parry",
				"Hitpause",
				"Opponent Hitpause",
				"SSDI",
				"ASDI",
				"Shield Stun",
				"Shield Damage",
				"Shield Pushback",
				"Shield Hitpause",
				"Hitstun Multiplier",
				"Hitfall Hitstun Multiplier",
				"Full Charge Knockback Multiplier",
				"Full Charge Damage Multiplier",
				"Reverse Hits?",
				"Forces Flinch?",
				"Ground Techable?",
				"Weight Independent?",
				tooltip("Strong Knockdown Unforced?", "If the hit belongs to a Strong, does it force a knockdown when floorhugged? Changes nothing for non-Strong hits."),
				"Projectile Interaction",
				"Forces Knockback in Knockdown",
				"Preserves Facing?",
				"Grab Partner Interaction",
				"Forces Tumble?",
				"Ignores Knockback Armor?",
				"Prevents Chaingrabs on Hit?",
			}

			local headersRow = mw.html.create("tr"):addClass("adv-hits-list-header")
			for k, v in pairs(columnHeaders) do
				local cell = mw.html.create("th"):wikitext(v):done()
				headersRow:node(cell)
			end
			headersRow:done()
			local hitsWindow = mw.html.create("table"):addClass("hits-window wikitable"):node(headersRow)

			for k, v in ipairs(hitresults) do
				hitsWindow:node(getAdvHits(hitresults[k], mode, motherhits[hitresults[k].moveID .. hitresults[k].nameID], articleList))
			end
			c1:node(hitsWindow):done()
			nerdHeader:node(nerdTitle):node(c1)
			finalreturn:node(nerdHeader)

			-- Display Floorhug Information
			local nerdHeader = mw.html
				.create("div")
				:addClass("toccolours mw-collapsible")
				:css("width", "100%")
				:css("overflow", "auto")
				:css("margin", "1em 0")
				:done()
			local nerdTitle = mw.html
				.create("div")
				:css("font-weight", "bold")
				:css("line-height", "1.6")
				:wikitext("'''Floorhug: Advanced Data'''")
				:done()
			local c1 = mw.html.create("div"):addClass("mw-collapsible-content")

			local columnHeaders = {
				"Hit / Hitbox ",
				"Floorhug Safety " .. tooltip("ⓘ", "Measures frame advantage of attacker if floorhug does not knock down."),
				"CC Safety " .. tooltip("ⓘ", "Measures frame advantage of attacker if crouch cancelled floorhug does not knock down."),
				"Floorhug Hitstun " .. tooltip("ⓘ", "If hit does not knock down, measures amount of landing hitstun post-floorhug. Assumes maximum hitstun possible before knocking down."),
				"CC Hitstun " .. tooltip("ⓘ", "If hit does not knock down, measures amount of landing hitstun post-floorhug after crouch cancel. Assumes maximum hitstun possible before knocking down."),
				"Floorhug Pop Up (No DI) " .. tooltip("ⓘ", "Percent range from minimum weight to maximum weight of when an opponent will be popped up post-floorhug, assuming no DI."),
				"Floorhug Pop Up (Best DI) " .. tooltip("ⓘ", "Percent range from minimum weight to maximum weight of when an opponent will be popped up post-floorhug, assuming best DI."),
				"CC Pop Up (No DI) " .. tooltip("ⓘ", "Percent range from minimum weight to maximum weight of when a crouching opponent will be popped up post-floorhug, assuming no DI."),
				"CC Pop Up (Best DI) " .. tooltip("ⓘ", "Percent range from minimum weight to maximum weight of when a crouching opponent will be popped up post-floorhug, assuming best DI."),
			}

			local headersRow = mw.html.create("tr"):addClass("adv-floorhugs-list-header")
			for k, v in pairs(columnHeaders) do
				local cell = mw.html.create("th"):wikitext(v):done()
				headersRow:node(cell)
			end
			headersRow:done()
			local flugWindow = mw.html.create("table"):addClass("hits-window wikitable"):node(headersRow)

			for k, v in ipairs(hitresults) do
				flugWindow:node(getFlugs(hitresults[k], mode, motherhits[hitresults[k].moveID .. hitresults[k].nameID], articleList))
			end
			c1:node(flugWindow):done()
			nerdHeader:node(nerdTitle):node(c1)
			finalreturn:node(nerdHeader)
		end

		if throwresults ~= nil and #(throwresults) ~= 0 then
			local nerdHeader = mw.html
				.create("div")
				:addClass("toccolours mw-collapsible")
				:css("width", "100%")
				:css("overflow", "auto")
				:css("margin", "1em 0")
				:done()
			local nerdTitle = mw.html
				.create("div")
				:css("font-weight", "bold")
				:css("line-height", "1.6")
				:wikitext("'''Throws: Advanced Data'''")
				:done()
			local c1 = mw.html.create("div"):addClass("mw-collapsible-content")

			local columnHeaders = {
				"Hit / Hitbox ",
				"Hitstun Multiplier",
				"Ground Techable",
				"Forces Tumble",
				"Hitstun Animation State Override",
				"Release Offset",
			}

			local headersRow = mw.html.create("tr"):addClass("adv-throws-list-header")
			for k, v in pairs(columnHeaders) do
				local cell = mw.html.create("th"):wikitext(v):done()
				headersRow:node(cell)
			end
			headersRow:done()
			local hitsWindow = mw.html.create("table"):addClass("throws-window wikitable"):node(headersRow)

			for k, v in pairs(throwresults) do
				hitsWindow:node(
					getAdvThrows(throwresults[k], mode, motherhits[throwresults[k].moveID .. throwresults[k].throwNumber])
				)
			end
			c1:node(hitsWindow):done()
			nerdHeader:node(nerdTitle):node(c1)
			finalreturn:node(nerdHeader)
		end
	end
	
	finalreturn:wikitext("''For full knockdown and crouch cancel percents, please visit the [[RoA2/" .. mode.chara .. "/Matchups|matchup page]] for exact numbers.''")

	finalreturn:done()

	return tostring(finalreturn)
end

local function getImageGallery(chara, attack)
	local tables = "ROA2_MoveMode, ROA2_MoveMode__image, ROA2_MoveMode__caption"
	local fields = "image, caption"
	local args = {
		join = "ROA2_MoveMode__image._rowID=ROA2_MoveMode._ID, ROA2_MoveMode__image._rowID=ROA2_MoveMode__caption._rowID, ROA2_MoveMode__image._position=ROA2_MoveMode__caption._position",
		where = 'ROA2_MoveMode.chara="' .. chara .. '" and ROA2_MoveMode.attack="' .. attack .. '"',
		orderBy = "_ID",
		groupBy = "ROA2_MoveMode__image._value",
	}
	local results = cargo.query(tables, fields, args)

	local imageCaptionPairs = {}

	for k, v in pairs(results) do
		local imageList = mysplit(results[k]["image"], "\\")
		local captionList = mysplit(results[k]["caption"], "\\")
		if imageList ~= nil then
			for k, v in pairs(imageList) do
				if captionList == nil then
					table.insert(imageCaptionPairs, { file = imageList[k], caption = "" })
				else
					table.insert(imageCaptionPairs, { file = imageList[k], caption = captionList[k] })
				end
			end
		end
	end
	local container = mw.html.create("div"):addClass("attack-gallery-image")
	container:wikitext(table.concat(getImagesWikitext(imageCaptionPairs)))

	return tostring(container)
end
local function getHitboxGallery(chara, attack)
	local tables = "ROA2_MoveMode, ROA2_MoveMode__hitbox, ROA2_MoveMode__hitboxCaption"
	local fields = "hitbox, hitboxCaption"
	local args = {
		join = "ROA2_MoveMode__hitbox._rowID=ROA2_MoveMode._ID, ROA2_MoveMode__hitbox._rowID=ROA2_MoveMode__hitboxCaption._rowID, ROA2_MoveMode__hitbox._position=ROA2_MoveMode__hitboxCaption._position",
		where = 'ROA2_MoveMode.chara="' .. chara .. '" and ROA2_MoveMode.attack="' .. attack .. '"',
		orderBy = "_ID",
		groupBy = "ROA2_MoveMode__hitbox._value",
	}
	local results = cargo.query(tables, fields, args)

	local imageCaptionPairs = {}

	for k, v in pairs(results) do
		local imageList = mysplit(results[k]["hitbox"], "\\")
		local captionList = mysplit(results[k]["hitboxCaption"], "\\")
		if imageList ~= nil then
			for k, v in pairs(imageList) do
				if captionList == nil then
					table.insert(imageCaptionPairs, { file = imageList[k], caption = "" })
				else
					table.insert(imageCaptionPairs, { file = imageList[k], caption = captionList[k] })
				end
			end
		end
	end
	
	local container = mw.html.create("div"):addClass("hitbox-gallery-image")
	container:wikitext(table.concat(getHitboxesWikitext(imageCaptionPairs)))

	return tostring(container)
end

local function getCardHTML(chara, attack, desc, advDesc)
	-- Lazy Load automated frame chart generator
	-- local autoChart = require('Module:FrameChart').autoChart
	-- Outer Container of the card
	local card = mw.html.create("div"):addClass("attack-container")

	-- Images
	local acquiredImages = getImageGallery(chara, attack)
	local tabberData
	if acquiredImages ~= '<div class="attack-gallery-image"></div>' then
		tabberData = tabber({
			label1 = "Images",
			content1 = getImageGallery(chara, attack),
			-- label2 = "Hitboxes",
			-- content2 = getHitboxGallery(chara, attack),
		})
	else
		local container = mw.html.create("div"):addClass("attack-gallery-image")
		container:wikitext(
			table.concat(
				getImagesWikitext(
					{{file = "RoA2_" .. chara .. "_" .. attack .. "_0.png", caption = "NOTE: This is an incomplete card, with data modes planning to be uploaded in the future."}}
				)
			)
		)
		
		tabberData = tabber({
			label1 = "Images",
			content1 = tostring(container),
			-- label2 = "Hitboxes",
			-- content2 = getHitboxGallery(chara, attack),
		})
	end
	local imageDiv = mw.html.create("div"):addClass("attack-gallery"):wikitext(tabberData):done()

	local paletteSwap = mw.html.create("div"):addClass("data-palette"):done()

	local description =
		mw.html.create("div"):addClass("move-description"):wikitext("\n"):wikitext(desc):wikitext("\n"):allDone()

	local nerdHeader = mw.html
		.create("div")
		:addClass("mw-collapsible mw-collapsed")
		:css("width", "100%")
		:css("overflow", "auto")
		:css("margin", "1em 0")
		:attr("data-expandtext", "Show Stats for Nerds")
		:attr("data-collapsetext", "Hide Stats for Nerds")
		:done()
	local nerdSection =
		mw.html.create("div"):addClass("mw-collapsible-content"):node(mw.html.create("br"):css("clear", "both"))

	nerdSection:node(mw.html.create("div"):wikitext(advDesc))

	local tableData = readModes(chara, attack)
	if #(tableData) > 1 then
		local object = {}
		local advObject = {}
		for i in pairs(tableData) do
			local mode = tableData[i]
			local hits = {}
			local hit_results = nil
			local throw_results = nil
			if mode.hitID ~= nil then
				local idList = mysplit(mode.hitID, ";")
				local hitMoves = mysplit(mode.hitMoveID, ";")
				local names = mysplit(mode.hitName, ";")
				local actives = mysplit(mode.hitActive, ";")
				local shieldSafetyList = mysplit(mode.customShieldSafety, ";")
				local uniquesList = mysplit(mode.uniqueField, ";")
				for k in ipairs(idList) do
					local attack = mode.attackID
					if hitMoves ~= nil then
						attack = hitMoves[k]
					end
					local v = idList[k]
					hits[attack .. v] = {}
					hits[attack .. v]["hitID"] = idList[k]
					hits[attack .. v]["move"] = attack
					hits[attack .. v]["name"] = idList[k]
					if names ~= nil then
						hits[attack .. v]["name"] = names[k]
					end
					hits[attack .. v]["active"] = actives[k]
					hits[attack .. v]["shield"] = nil
					if shieldSafetyList ~= nil then
						hits[attack .. v]["shield"] = shieldSafetyList[k]
					end
					hits[attack .. v]["unique"] = nil
					if uniquesList ~= nil and uniquesList[k] ~= '-' then
						hits[attack .. v]["unique"] = uniquesList[k]
					end
				end

				local tables = "ROA2_HitData"
				local fields =
					"chara,moveID,nameID,Damage,BaseKnockback,FinalBaseKnockback,KnockbackScaling,KnockbackAngle,KnockbackAngleMode,bCanReverse,bIgnoresWeight,ExtraShieldStun,SpecialEffect,HitpauseMultiplier,ExtraHitpauseForOpponent,SDIMultiplier,ASDIMultiplier,bCanReverse,bForceFlinch,GroundTechable,bAutoFloorhuggable,ProjectileInteraction,bForceKnockbackInKnockdown,bPreserveFacing,HitstunMultiplier,HitfallHitstunMultiplier,ParryReaction,GrabPartnerInteraction,ExtraShieldStun,ShieldDamageMultiplier,ShieldPushbackMultiplier,ShieldHitpauseMultiplier,FullChargeKnockbackMultiplier,FullChargeDamageMultiplier,ForceTumble,IgnoreKnockbackArmor,PreventChaingrabsOnHit"
		
				local whereField = 'chara="' .. mode.chara .. '" and ('
				local whereList = {}
				for k, v in pairs(hits) do
					table.insert(whereList, '(moveID = "' .. v["move"] .. '" and nameID = "' .. v["hitID"] .. '")')
				end
				local whereField = whereField .. table.concat(whereList, " or ") .. ")"
				local args = { where = whereField, orderBy = "_ID" }
				hit_results = cargo.query(tables, fields, args)
				-- hitsWindow:wikitext(dump(args))

				local whereList = {}
				for k, v in pairs(hits) do
					if string.sub(v['hitID'], 0, 5) == 'Throw' then
						table.insert(whereList, '(moveID = "' .. v["move"] .. '" and throwNumber = "' .. v["hitID"] .. '")')
					end
				end
				if #whereList > 0 then
						
					local tables = "ROA2_TrueThrowData"
					local fields =
						"chara,moveID,throwNumber,Damage,BaseKnockback,KnockbackScaling,KnockbackAngle,HitstunMultiplier,bTechable,ForceTumble"
			
					local whereField = 'chara="' .. mode.chara .. '" and ('

					local whereField = whereField .. table.concat(whereList, " or ") .. ")"
					local args = { where = whereField, orderBy = "_ID" }
					throw_results = cargo.query(tables, fields, args)
				end

				if mode.articleID ~= nil then
					local tables = "ROA2_Articles"
					local fields =
						"chara,moveID,ArticleName,bIsProjectile,bRotateWithVelocity,bInheritOwnerChargeValue,bIsAttachedToOwner,ParryReaction,HasHitReaction,GotHitReaction,bCanBeHitByOwner,bCanDetectOwner,GroundCollisionResponse,WallCollisionResponse,CeilingCollisionResponse,ShouldGetOutOfGroundOnSpawn"
			
					local whereField = 'chara="' .. chara .. '" and ('
					local whereList = {}
					for _, v in pairs(mysplit(mode.articleID,';')) do
						table.insert(whereList, '(moveID = "' .. v .. '")')
					end
					local whereField = whereField .. table.concat(whereList, " or ") .. ")"
					local args = { where = whereField, orderBy = "ArticleName" }
					articleList = cargo.query(tables, fields, args)
				end
			end
			object["label" .. i] = tableData[i].mode
			object["content" .. i] = createMode(mode.articleID ~= nil, tableData[i], hits, hit_results, throw_results)
			-- object["content" .. i] = createMode(tableData[i], hits, hit_results, throw_results)
			advObject["label" .. i] = tableData[i].mode
			advObject["content" .. i] = createAdvMode(tableData[i], articleList, hits, hit_results, throw_results)
		end
		local t = tabber(object)
		local t2 = tabber(advObject)
		paletteSwap:node(t):addClass('move-mode-tabs'):done()
		nerdSection:node(t2):addClass('move-mode-tabs'):done()
		-- There should be a tabber element both in the frame window and also the advanced element one
	else
		local mode = tableData[1]
		local hits = {}
		local hit_results = nil
		local throw_results = nil
		local articleList = nil
		if mode then
			if mode.hitID ~= nil then
				local idList = mysplit(mode.hitID, ";")
				local hitMoves = mysplit(mode.hitMoveID, ";")
				local names = mysplit(mode.hitName, ";")
				local actives = mysplit(mode.hitActive, ";")
				local shieldSafetyList = mysplit(mode.customShieldSafety, ";")
				local uniquesList = mysplit(mode.uniqueField, ";")
				for k in ipairs(idList) do
					local attack = mode.attackID
					if hitMoves ~= nil then
						attack = hitMoves[k]
					end
					local v = idList[k]
					hits[attack .. v] = {}
					hits[attack .. v]["hitID"] = idList[k]
					hits[attack .. v]["move"] = attack
					hits[attack .. v]["name"] = idList[k]
					if names ~= nil then
						hits[attack .. v]["name"] = names[k]
					end
					hits[attack .. v]["active"] = actives[k]
					hits[attack .. v]["shield"] = nil
					if shieldSafetyList ~= nil then
						hits[attack .. v]["shield"] = shieldSafetyList[k]
					end
					hits[attack .. v]["unique"] = nil
					if uniquesList ~= nil and uniquesList[k] ~= '-' then
						hits[attack .. v]["unique"] = uniquesList[k]
					end
				end
	
				local tables = "ROA2_HitData"
				local fields =
					"chara,moveID,nameID,Damage,BaseKnockback,FinalBaseKnockback,KnockbackScaling,KnockbackAngle,KnockbackAngleMode,bCanReverse,bIgnoresWeight,ExtraShieldStun,SpecialEffect,HitpauseMultiplier,ExtraHitpauseForOpponent,SDIMultiplier,ASDIMultiplier,bCanReverse,bForceFlinch,GroundTechable,bAutoFloorhuggable,ProjectileInteraction,bForceKnockbackInKnockdown,bPreserveFacing,HitstunMultiplier,HitfallHitstunMultiplier,ParryReaction,GrabPartnerInteraction,ExtraShieldStun,ShieldDamageMultiplier,ShieldPushbackMultiplier,ShieldHitpauseMultiplier,FullChargeKnockbackMultiplier,FullChargeDamageMultiplier,ForceTumble,IgnoreKnockbackArmor,PreventChaingrabsOnHit"
		
				local whereField = 'chara="' .. chara .. '" and ('
				local whereList = {}
				for k, v in pairs(hits) do
					table.insert(whereList, '(moveID = "' .. v["move"] .. '" and nameID = "' .. v["hitID"] .. '")')
				end
				local whereField = whereField .. table.concat(whereList, " or ") .. ")"
				local args = { where = whereField, orderBy = "_ID" }
				hit_results = cargo.query(tables, fields, args)
						
				local tables = "ROA2_TrueThrowData"
				local fields =
					"chara,moveID,throwNumber,Damage,BaseKnockback,KnockbackScaling,KnockbackAngle,HitstunMultiplier,bTechable,ForceTumble"
		
				local whereField = 'chara="' .. chara .. '" and ('
				local whereList = {}
				for k, v in pairs(hits) do
					table.insert(whereList, '(moveID = "' .. v["move"] .. '" and throwNumber = "' .. v["hitID"] .. '")')
				end
				local whereField = whereField .. table.concat(whereList, " or ") .. ")"
				local args = { where = whereField, orderBy = "_ID" }
				throw_results = cargo.query(tables, fields, args)
				
				if mode.articleID ~= nil then
					local tables = "ROA2_Articles"
					local fields =
						"chara,moveID,ArticleName,bIsProjectile,bRotateWithVelocity,bInheritOwnerChargeValue,bIsAttachedToOwner,ParryReaction,HasHitReaction,GotHitReaction,bCanBeHitByOwner,bCanDetectOwner,GroundCollisionResponse,WallCollisionResponse,CeilingCollisionResponse,ShouldGetOutOfGroundOnSpawn"
			
					local whereField = 'chara="' .. chara .. '" and ('
					local whereList = {}
					for _, v in pairs(mysplit(mode.articleID,';')) do
						table.insert(whereList, '(moveID = "' .. v .. '")')
					end
					local whereField = whereField .. table.concat(whereList, " or ") .. ")"
					local args = { where = whereField, orderBy = "ArticleName" }
					articleList = cargo.query(tables, fields, args)
				end
			end
			-- paletteSwap:wikitext(dump())
			paletteSwap:node(createMode(mode.articleID ~= nil, tableData[1], hits, hit_results, throw_results)):done()
			nerdSection:node(createAdvMode(tableData[1], articleList, hits, hit_results, throw_results)):done()
		end
	end

	--Attack Info Container
	nerdHeader:node(nerdSection):done()
	local content =
		mw.html.create("div"):addClass("attack-info"):node(paletteSwap):node(description):node(nerdHeader):done()

	card:node(imageDiv):node(content):done()
	return tostring(card)

end

function p.main(frame)
	mArguments = require("Module:Arguments")
	local args = mArguments.getArgs(frame)
	return p._main(args)
end

function p._main(args)
	local chara = args["chara"]
	local attack = args["attack"]
	local desc = args["desc"]
	if args["desc"] == nil then
		desc = args["description"]
	end
	if desc == '' or desc == nil then
		desc = "<small>''This move card is missing a move description. The following bullet points should all be one paragraph or more and be included:''\n* Brief 1-2 sentences stating the basic function and utility of the move. Ex: ''\"Excellent anti-air, combo-starter, and combo-extender. The move starts behind before sweeping to the front.\"''\n* Explaining the reward and usefulness of the move and how it functions in her gameplan. Point out non-obvious use cases when relevant.\n* Explaining the shortcomings of the move, i.e. unsafe on shield, susceptible to CC, stubby, slow, etc.\n* Explaining when and where to use the move. Can differentiate between if it's good in neutral, punish, against fastfallers, floaties, etc.\nIf there's something you want to debate leaving it in or out, err on the side of leaving it in. For more details, read [[User:Lynnifer/Brief_Style_Guide#Move_Cards|here]].\n</small>"
	end
	local advDesc = args["advDesc"]

	if not chara then
		chara = mw.title.getCurrentTitle().subpageText
	end
	local html = getCardHTML(chara, attack, desc, advDesc)
	return tostring(html)
		.. mw.getCurrentFrame():extensionTag({
			name = "templatestyles",
			args = { src = "Template:MoveCard/shared/styles.css" },
		})
end

return p