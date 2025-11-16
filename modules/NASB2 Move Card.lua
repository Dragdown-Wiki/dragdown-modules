local p = {}
local mArguments
local cargo = mw.ext.cargo

local tabber = require("Module:Tabber").renderTabber

local tooltip = require("tooltip")

local function readModes(chara, attack)
	local tables = "NASB2_MoveMode"
	local fields =
		"chara, attack, attackID, mode, startup, startupNotes, totalActive, totalActiveNotes, endlag, endlagNotes, cancel, cancelNotes, landingLag, landingLagNotes, totalDuration, totalDurationNotes,iasa,autocancel,autocancelNotes,hitID,hitMoveID,hitName,hitActive,customShieldSafety,uniqueField,frameChart, articleID, notes"
	local args = {
		where = 'NASB2_MoveMode.chara="' .. chara .. '" and NASB2_MoveMode.attack="' .. attack .. '"',
		orderBy = "_ID",
	}
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

local function drawFrame(frames, frameType)
	local output = ""
	for i = 1, tonumber(frames) do
		local frameDataHtml = mw.html.create("div")
		frameDataHtml:addClass("frame-data frame-data-" .. frameType)
		frameDataHtml:done()
		output = output .. tostring(frameDataHtml)
	end
	return output
end

local function drawFrameData(s1, s2, s3, s4)
	currentFrame = 0

	html = mw.html.create("div")
	html:addClass("frameChart")

	-- Startup of move, substract 1 if startupIsFirstActive
	local totalStartup = 0
	local startup = {}
	if s1 == nil then
	elseif tonumber(s1) ~= nil then
		startup[1] = tonumber(s1)
		totalStartup = startup[1]
	elseif string.find(s1, "+") and not string.find(s1, "%[") then
		for _, v in ipairs(mysplit(s1, "+")) do
			table.insert(startup, v)
			totalStartup = totalStartup + v
		end
	elseif string.find(s1, "+") and string.find(s1, "%[") then
		-- for _, v in ipairs(mysplit(mysplit(s1, "[+")[2], " ]")) do
		-- 	table.insert(startup, v)
		-- 	totalStartup = totalStartup + v
		-- end
	end

	-- Active of move

	active = {}
	first_active_frame = totalStartup + 1
	counter = 1
	if s2 and s2 ~= "N/A" then
		csplit = mysplit(s2, ",")
		ATL = #csplit
		for i = 1, ATL do
			hyphen = #(mysplit(csplit[i], "-"))
			startFrame = mysplit(csplit[i], "-")[1]
			endFrame = mysplit(csplit[i], "-")[hyphen]
			if tonumber(startFrame) > first_active_frame + 1 then
				active[counter] = -1 * (tonumber(startFrame) - first_active_frame - 1)
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
	if processedEndlag ~= nil then
		if string.sub(processedEndlag, -3) == "..." then
			processedEndlag = string.sub(processedEndlag, 1, -4)
		end
		if tonumber(processedEndlag) ~= nil then
			endlag[1] = processedEndlag
			totalEndlag = tonumber(endlag[1])
		elseif string.find(processedEndlag, "+") then
			for i = 1, #(mysplit(processedEndlag, "+")) do
				endlag[i] = mysplit(processedEndlag, "+")[i]
				-- if ('...')
				totalEndlag = totalEndlag + endlag[i]
			end
		end
	end
	-- Special Recovery of move
	local landingLag = s4
	if tonumber(landingLag) == nil then
		landingLag = 0
	end

	-- if active ~= nil then
	-- 	html:tag('div'):addClass('frameChart-FAF'):wikitext(active[1]):done()
	-- end

	-- Create container for frame data
	frameChartDataHtml = mw.html.create("div")
	frameChartDataHtml:addClass("frameChart-data")

	alt = false
	for i = 1, #startup do
		if not alt then
			frameChartDataHtml:wikitext(drawFrame(startup[i], "startup"))
		else
			frameChartDataHtml:wikitext(drawFrame(startup[i], "startup-alt"))
		end
		alt = not alt
	end

	-- Option for inputting multihits, works for moves with 1+ gaps in the active frames
	alt = false
	for i = 1, #active do
		if active[i] < 0 then
			frameChartDataHtml:wikitext(drawFrame(active[i] * -1, "inactive"))
			alt = false
		elseif not alt then
			frameChartDataHtml:wikitext(drawFrame(active[i], "active"))
			alt = not alt
		else
			frameChartDataHtml:wikitext(drawFrame(active[i], "active-alt"))
			alt = not alt
		end
	end
	alt = false
	for i = 1, #endlag do
		if not alt then
			frameChartDataHtml:wikitext(drawFrame(endlag[i], "endlag"))
		else
			frameChartDataHtml:wikitext(drawFrame(endlag[i], "endlag-alt"))
		end
		alt = not alt
	end
	frameChartDataHtml:wikitext(drawFrame(landingLag, "landingLag"))

	local fdtotal = mw.html.create("div"):addClass("frame-data-total")
	fdtotal:node(mw.html.create("span"):addClass("frame-data-total-label"):wikitext("First Active Frame:"))

	if s2 ~= nil then
		fdtotal:node(mw.html.create("span"):addClass("frame-data-total-value"):wikitext(totalStartup + 1))
	else
		fdtotal:node(mw.html.create("span"):addClass("frame-data-total-value"):wikitext("N/A"))
	end
	fdtotal:done()
	html:node(frameChartDataHtml)
	html:node(fdtotal):done()

	return tostring(html)
		.. mw.getCurrentFrame():extensionTag({
			name = "templatestyles",
			args = { src = "Module:FrameChart/styles.css" },
		})
end

local function calcShieldSafety(result, mode, active, custom)
	if
		mode.attackID == "Bthrow"
		or mode.attackID == "Uthrow"
		or mode.attackID == "Dthrow"
		or mode.attackID == "Fthrow"
		or mode.attackID == "Grab"
		or mode.attackID == "Pummel"
	then
		return "N/A"
	end

	if custom == "N/A" then
		return "N/A"
	end
	if mode.endlag == "..." then
		return "N/A"
	end
	if custom ~= nil and custom ~= "JAB" and custom ~= "-" then
		return custom
	end
	
	if tonumber(mode.totalDuration) then
		local stun = result.BlockStun
		
		local active1 = mysplit(active, ", ")
		active1 = active1[#active1]
		local active2 = mysplit(active1, "-")
		local first = mode.totalDuration - active2[1]
		local second = mode.totalDuration - active2[#active2]
		if mode.iasa then
			first = mode.iasa - active2[1]
			second = mode.iasa - active2[#active2]
		end

		if mode.landingLag ~= nil then
			local realLandingLag = mode.landingLag

			return string.format("%+d", stun - realLandingLag)

		else
			if first == second then
				return string.format("%+d", stun - first)
			else
				return string.format("%+d to %+d", stun - first, stun - second)
			end
		end
	else
		return "N/A"
	end
end

local function makeAngleDisplay(angle, flipper)
	angle = tonumber(angle)
	local angleColor = mw.html.create("span"):wikitext(angle)
	if angle > 360 then
		angleColor:css("color", "#ff0000")
	elseif angle <= 45 or angle >= 315 then
		angleColor:css("color", "#1ba6ff")
	elseif angle > 225 then
		angleColor:css("color", "#ff6b6b")
	elseif angle > 135 then
		angleColor:css("color", "#de7cd1")
	elseif angle > 45 then
		angleColor:css("color", "#16df53")
	end

	local display = mw.html.create("span")
	local div1 = mw.html.create("div"):css("position", "relative"):css("top", "0"):css("max-width", "256px")

	if angle < 360 then
		div1:tag("div")
			:css("transform", "rotate(-" .. angle .. "deg)")
			:css("z-index", "0")
			:css("position", "absolute")
			:css("top", "0")
			:css("left", "0")
			:css("transform-origin", "center center")
			:wikitext("[[File:NASB2_AngleComplex_BG.svg|256px|link=]]")
			:done()
			:tag("div")
			:css("z-index", "1")
			:css("position", "relative")
			:css("top", "0")
			:css("left", "0")
			:wikitext("[[File:NASB2_AngleComplex_MG.svg|256px|link=]]")
			:done()
			:tag("div")
			:css("transform", "rotate(-" .. angle .. "deg)")
			:css("z-index", "2")
			:css("position", "absolute")
			:css("top", "0")
			:css("left", "0")
			:css("transform-origin", "center center")
			:wikitext("[[File:NASB2_AngleComplex_FG.svg|256px|link=]]")
			:done()
		div1:wikitext("Angle Flipper: " .. flipper)
		div1:done()
		display:node(div1):wikitext("[[File:NASB2_AngleComplex_Key.svg|256px|link=]]")
		display:done()
	else
		div1:wikitext("Angle Flipper: " .. flipper)
		div1:done()
		display:node(div1)
		display:done()
	end
	return tostring(tooltip(tostring(angleColor), tostring(display)))
end

local function showHitUniques(hasArticle, result, unique)
	local listOfUniques = {}

	if unique ~= nil then
		local uniquesList = mysplit(unique, "\\")
		for k, v in pairs(uniquesList) do
			table.insert(listOfUniques, v)
		end
	end

	if tonumber(result.DirectionalInfluenceMultiplier ) ~= 1 then
		table.insert(listOfUniques, "DI: " .. result.DirectionalInfluenceMultiplier .. '×')
	end
	
	if tonumber(result.SmashDirectionalInfluenceMultiplier ) ~= 1 then
		table.insert(listOfUniques, "DI: " .. result.SmashDirectionalInfluenceMultiplier .. '×'  )
	end
	
	if tonumber(result.HitStunMinimum ) ~= 1 then
		table.insert(listOfUniques, "Min Hitstun: " .. result.HitStunMinimum)
	end
	if tonumber(result.HitStunMultiplier  ) ~= 1 then
		table.insert(listOfUniques, "Hitstun: " .. result.HitStunMultiplier  .. '×'  )
	end
	
	if #listOfUniques <= 0 then
		return nil
	else
		return table.concat(listOfUniques, ", ")
	end
end

local function getHits(hasArticle, result, mode, hitData)
	--chara, attackID, hitID, hitMoveID, hitName, hitActive, customShieldSafety, uniques
	local hitRow = mw.html.create("tr"):addClass("hit-row")
	if(tonumber(hitData.name)) then
		hitRow:tag("td"):wikitext(result.hitName)
	else
		hitRow:tag("td"):wikitext(hitData.name)
	end
	hitRow:tag("td"):wikitext(result.Damage .. "%")
		:tag("td"):wikitext(hitData.active)
		:tag("td"):wikitext(result.BaseKnockback )
		:tag("td"):wikitext(result.KnockbackGain )
		:tag("td"):wikitext(result.FixedKnockback )
		:tag("td"):wikitext(makeAngleDisplay(result.KnockbackAngle , result.SpecialAngle ))
		-- :tag("td"):wikitext("T")
		:tag("td"):wikitext(calcShieldSafety(result, mode, hitData.active, hitData.shield))
		:done()
	return hitRow
end

local function getAdvHits(result, mode, hitData, articleData)
	--chara, attackID, hitID, hitMoveID, hitName, hitActive, customShieldSafety, uniques

	local columns = "hitName,SpecialAngle,DirectionalInfluenceMultiplier,SmashDirectionalInfluenceMultiplier,HitStunMinimum,HitStunMultiplier,HitlagBaseOnBlock,HitlagBaseOnHit,InstigatorAdvantageOnBlock,InstigatorAdvantageOnHit,BlockStun,BlockPush,BlockDamage,Priority,PushBackInstigatorOnHit,KnockbackIgnoreDownState,Aerial,Flinchless,ForceSpinOut,Reversible,Unblockable,UntechableIfGrounded,CannotRebound,CanRedirectProjectiles,CanReflectProjectiles,PreventSlimeBurst,SlimeMultiplier,InstigatorPushbackVelocity,UniqueNotes"

	local hitRow = mw.html.create("tr")
	for k, v in ipairs(mysplit(columns, ",")) do
		local assignedValue = ""
		assignedValue = result[v]
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
		tooltip(
			"Startup",
			'Startup or First Active Frame, the time it takes for an attack to become active. For example, a startup value of "10" means the hitbox or relevant property is active on the 10th frame.'
		),
		tooltip("Total Active", "Frames during which the move is active."),
		tooltip("Endlag", "The amount of frames where the move is no longer active."),
		tooltip(
			"IASA",
			"Interruptible as soon as, the effective range of the move. The full animation can sometimes last longer."
		),
		tooltip("Total Duration", "Total animation length."),
	}
	local frame = mw.getCurrentFrame()
	if mode.landingLag or mode.autocancel then
		columnHeaders = {
			tooltip(
				"Startup",
				'Startup or First Active Frame, the time it takes for an attack to become active. For example, a startup value of "10" means the hitbox or relevant property is active on the 10th frame.'
			),
			tooltip("Total Active", "Frames during which the move is active."),
			tooltip("Endlag", "The amount of frames where the move is no longer active."),
			tooltip(
				"Landing Lag",
				"The amount of frames that the character must wait after landing with this move before becoming actionable. ".. frame:preprocess("{{aerial}}") .." landing lag assumes that the move is L-cancelled."
			),
			tooltip(
				"Autocancel",
				"Animation frames where the character lands with standard landing lag, typically much faster than landing regularly."
			),
			tooltip(
				"IASA",
				"Interruptible as soon as, the effective range of the move. The full animation can sometimes last longer."
			),
			tooltip("Total Duration", "Total animation length."),
		}
	end
	local headersRow = mw.html.create("tr"):addClass("frame-window-header")
	for k, v in pairs(columnHeaders) do
		local cell = mw.html.create("th"):wikitext(v):done()
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
		if mode.startupNotes == "SMASH" then
			columnValues["startup"] = columnValues["startup"]
				.. " "
				.. tooltip("ⓘ", "Total Uncharged Startup<br>[Pre-Charge Window + Post-Charge Window]")
		elseif mode.startupNotes == "RAPIDJAB" then
			columnValues["startup"] = columnValues["startup"]
				.. " "
				.. tooltip("ⓘ", "[+Rapid Jab Initial Startup] Rapid Jab Loop Startup")
		else
			columnValues["startup"] = columnValues["startup"] .. " " .. tooltip("ⓘ", mode.startupNotes)
		end
	end

	columnValues["totalActive"] = "N/A"
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
				mode.endlag = mode.iasa - 1 - catch2[#catch2]
			else
				columnValues["endlag"] = mode.totalDuration - catch2[#catch2]
				mode.endlag = mode.totalDuration - catch2[#catch2]
			end
		else
			columnValues["endlag"] = "N/A"
			mode.endlag = 0
		end
	end
	if mode.endlag == "..." then
		columnValues["endlag"] = "''" .. columnValues["endlag"] .. "...'' " .. tooltip("ⓘ", "This character enters special fall after.") 
	end
	if mode.endlagNotes then
		columnValues["endlag"] = columnValues["endlag"] .. " " .. tooltip("ⓘ", mode.endlagNotes)
	end
	columnValues["landingLag"] = 'N/A'
	if mode.landingLag and mode.landingLag:sub(-1, -1) == "L" then
		columnValues["landingLag"] = tooltip(
			math.floor(mode.landingLag:sub(0, -2) / 2),
			"When not L-cancelled, this lasts " .. mode.landingLag:sub(0, -2) .. " frames."
		)
		mode.landingLag = math.floor(mode.landingLag:sub(0, -2) / 2)
	else
		columnValues["landingLag"] = mode.landingLag
	end
	if mode.landingLagNotes then
		columnValues["landingLag"] = columnValues["landingLag"] .. " " .. tooltip("ⓘ", mode.landingLagNotes)
	end
	columnValues["autocancel"] = "N/A"
	if mode.autocancel then
		columnValues["autocancel"] = mode.autocancel
	end
	if mode.totalDuration == nil then
		local td_active = startupSum
		if mode.totalActive ~= nil then
			local _, _, p = mode.totalActive:reverse():find("(%d+)")
			if p ~= nil then
				td_active = p:reverse()
			end
		end
		local td_endlag = 0
		if mode.endlag ~= nil then
			td_endlag = mode.endlag
			if string.find(mode.endlag, "...") then
				td_endlag = nil
			elseif string.find(mode.endlag, "+") then
				td_endlag = 0
				for _, i in ipairs(mysplit(mode.endlag, "+")) do
					td_endlag = td_endlag + tonumber(i)
				end
			end
		end
		if tonumber(td_endlag) and tonumber(td_active) then
			mode.totalDuration = td_active + td_endlag
		end
	end
	columnValues["iasa"] = "N/A"
	if mode.iasa then
		columnValues["iasa"] = mode.iasa
	elseif mode.totalDuration then
		columnValues["iasa"] = mode.totalDuration + 1
	end
	columnValues["totalDuration"] = "N/A"
	if mode.totalDuration then
		columnValues["totalDuration"] = mode.totalDuration
	end
	if mode.totalDurationNotes then
		columnValues["totalDuration"] = columnValues["totalDuration"] .. " " .. tooltip("ⓘ", mode.totalDurationNotes)
	end
	local dataRow = mw.html.create("tr"):addClass("frame-window-data")
	local columnValuesTags = { "startup", "totalActive", "endlag", "iasa", "totalDuration" }
	if mode.landingLag then
		columnValuesTags = { "startup", "totalActive", "endlag", "landingLag", "autocancel", "iasa", "totalDuration" }
	end
	if mode.autocancel then
		columnValuesTags = { "startup", "totalActive", "endlag", "landingLag", "autocancel", "iasa", "totalDuration" }
	end
	
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

	local frameChart = mw.html.create("div"):addClass("frame-chart")

	if(mode.frameChart ~= nil) then
		if(mode.frameChart == 'N/A') then
			frameChart:wikitext("''This frame chart is currently unavailable and will be added at a later time.''"):done()
		else
			frameChart:wikitext(mode.frameChart):done()
		end
	else
		frameChart:wikitext(drawFrameData(mode.startup,mode.totalActive,mode.endlag,mode.landingLag)):done()
	end

	local numbersPanel = mw.html.create("div"):addClass("numbers-panel"):css("overflow-x","auto"):node(t):node(frameChart)
	if mode.hitID ~= nil then
		local headersHitRow = mw.html.create("tr")
		local hitHeaders = {
			tooltip(
				"Hit / Hitbox",
				"Which hit timing (such as early or late), or hitbox (such as sweetspot or sourspot) of this move that the data to the right is referring to."
			),
			tooltip("Damage", "The raw damage percent value of the listed move/hit."),
			tooltip("Active Frames", "Which frames a move is active and can affect opponents."),
			tooltip(
				"BKB",
				"Base knockback - this determines the general strength of knockback the move will deal across all percents."
			),
			tooltip(
				"KBG",
				"Knockback growth - this determines how much knockback generally increases at higher percents."
			),
			tooltip(
				"WDSK",
				"Fixed knockback - when not 0, moves will deal weight-dependent set knockback."
			),
			tooltip("Angle", "The angle at which the move sends the target."),
			tooltip(
				"Shield Safety",
				"The frame advantage after a move connects on shield. If a move ends prematurely with landing lag like an aerial, the shield safety assumes that the character lands immediately after performing the hit."
			),
		}
		for k, v in pairs(hitHeaders) do
			local cell = mw.html.create("th"):wikitext(v):done()
			headersHitRow:node(cell)
		end

		local hitsWindow = mw.html.create("table"):addClass("wikitable hits-window"):node(headersHitRow)

		if hitresults ~= nil then
			for k, v in pairs(hitresults) do
				hitsWindow:node(
					getHits(
						hasArticle,
						hitresults[k],
						mode,
						motherhits[k]
					)
				)
				local uniqueRow = showHitUniques(hasArticle, hitresults[k], motherhits[k].unique)
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
			"Name",
			"Special Angle",
			"DI Multiplier",
			"SDI Multiplier",
			"HitStun Minimum",
			"HitStun Multiplier",
			"Hitlag Base On Block",
			"Hitlag Base On Hit",
			"Instigator Advantage On Block",
			"Instigator Advantage On Hit",
			"Block Stun",
			"Block Push",
			"Block Damage",
			"Priority",
			"PushBack Instigator On Hit",
			"Knockback Ignore Down State",
			"Aerial",
			"Flinchless",
			"Force Spin Out",
			"Reversible",
			"Unblockable",
			"Untechable If Grounded",
			"Cannot Rebound",
			"Can Redirect Projectiles",
			"Can Reflect Projectiles",
			"Prevent Slime Burst",
			"Slime Multiplier",
			"Instigator Pushback Velocity",
			"Unique Notes",
		}

		local headersRow = mw.html.create("tr"):addClass("adv-hits-list-header")
		for k, v in pairs(columnHeaders) do
			local cell = mw.html.create("th"):wikitext(v):done()
			headersRow:node(cell)
		end
		headersRow:done()
		local hitsWindow = mw.html.create("table"):addClass("hits-window wikitable"):node(headersRow)

		for k, v in ipairs(hitresults) do
			hitsWindow:node(getAdvHits(hitresults[k], mode, motherhits[hitresults[k]], articleList))
			-- tumbleTable:node(calcFullTumble(hitresults[k], false, false, motherhits[hitresults[k].moveID .. hitresults[k].nameID].name))
			-- CCTable:node(calcFullTumble(hitresults[k], true, false, motherhits[hitresults[k].moveID .. hitresults[k].nameID].name))
		end
		c1:node(hitsWindow):done()
		nerdHeader:node(nerdTitle):node(c1)
		finalreturn:node(nerdHeader)
	end

	
	finalreturn:done()

	return tostring(finalreturn)
end

local function getImageGallery(chara, attack)
	local tables = "NASB2_MoveMode, NASB2_MoveMode__image, NASB2_MoveMode__caption"
	local fields = "image, caption"
	local args = {
		join = "NASB2_MoveMode__image._rowID=NASB2_MoveMode._ID, NASB2_MoveMode__image._rowID=NASB2_MoveMode__caption._rowID, NASB2_MoveMode__image._position=NASB2_MoveMode__caption._position",
		where = 'NASB2_MoveMode.chara="' .. chara .. '" and NASB2_MoveMode.attack="' .. attack .. '"',
		orderBy = "_ID",
		groupBy = "NASB2_MoveMode__image._value",
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
				getImagesWikitext({
					{
						file = "NASB2_" .. chara .. "_" .. attack .. "_0.png",
						caption = "NOTE: This is an incomplete card, with data modes planning to be uploaded in the future.",
					},
				})
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
	local queues = {}
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
				hits[k] = {}
				hits[k]["hitID"] = idList[k]
				hits[k]["move"] = attack
				hits[k]["name"] = idList[k]
				if names ~= nil then
					hits[k]["name"] = names[k]
				end
				hits[k]["active"] = actives[k]
				hits[k]["shield"] = nil
				if shieldSafetyList ~= nil then
					hits[k]["shield"] = shieldSafetyList[k]
				end
				hits[k]["unique"] = nil
				if uniquesList ~= nil and uniquesList[k] ~= "-" then
					hits[k]["unique"] = uniquesList[k]
				end
			end

			local tables = "NASB2_HitData"
			local fields = "chara,hitName,hitID,Damage,BaseKnockback,KnockbackGain,FixedKnockback,KnockbackAngle,SpecialAngle,DirectionalInfluenceMultiplier,SmashDirectionalInfluenceMultiplier,HitStunMinimum,HitStunMultiplier,HitlagBaseOnBlock,HitlagBaseOnHit,InstigatorAdvantageOnBlock,InstigatorAdvantageOnHit,BlockStun,BlockPush,BlockDamage,Priority,PushBackInstigatorOnHit,KnockbackIgnoreDownState,Aerial,Flinchless,ForceSpinOut,Reversible,Unblockable,UntechableIfGrounded,CannotRebound,CanRedirectProjectiles,CanReflectProjectiles,PreventSlimeBurst,SlimeMultiplier,InstigatorPushbackVelocity,UniqueNotes"
			local whereField = 'chara="' .. mode.chara .. '" and ('
			local whereList = {}
			for k, v in pairs(hits) do
				table.insert(whereList, '(hitID = "' .. v["hitID"] .. '")')
			end
			local whereField = whereField .. table.concat(whereList, " or ") .. ")"
			local args = { where = whereField, orderBy = "_ID" }
			hit_results = cargo.query(tables, fields, args)
			-- hitsWindow:wikitext(dump(args))

			local whereList = {}
			for k, v in pairs(hits) do
				table.insert(whereList, '(attack = "' .. v["move"] .. '")')
			end
		end
		queues[mode] = {mode = mode, hits = hits, hit_results = hit_results, articles = articles}
	end
	if #tableData > 1 then
		local object = {}
		local advObject = {}
		for i in pairs(tableData) do
			object["label" .. i] = queues[tableData[i]].mode
			object["content" .. i] = createMode(false, queues[tableData[i]].mode, queues[tableData[i]].hits, queues[tableData[i]].hit_results, queues[tableData[i]].throw_results)
			-- object["content" .. i] = createMode(tableData[i], hits, hit_results, throw_results)
			advObject["label" .. i] = tableData[i].mode
			advObject["content" .. i] = createAdvMode(queues[tableData[i]].mode, queues[tableData[i]].articles, queues[tableData[i]].hits, queues[tableData[i]].hit_results, queues[tableData[i]].throw_results)
		end
		local t = tabber(object)
		local t2 = tabber(advObject)
		paletteSwap:node(t):addClass("move-mode-tabs"):done()
		nerdSection:node(t2):addClass("move-mode-tabs"):done()
		-- There should be a tabber element both in the frame window and also the advanced element one
	else
		if(queues[tableData[1]]) then
			paletteSwap:node(createMode(false, queues[tableData[1]].mode, queues[tableData[1]].hits, queues[tableData[1]].hit_results, queues[tableData[1]].throw_results)):done()
			nerdSection:node(createAdvMode(queues[tableData[1]].mode, queues[tableData[1]].articles, queues[tableData[1]].hits, queues[tableData[1]].hit_results, queues[tableData[1]].throw_results)):done()
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
	if desc == "" or desc == nil then
		desc =
			"<small>''This move card is missing a move description. The following bullet points should all be one paragraph or more and be included:''\n* Brief 1-2 sentences stating the basic function and utility of the move. Ex: ''\"Excellent anti-air, combo-starter, and combo-extender. The move starts behind before sweeping to the front.\"''\n* Explaining the reward and usefulness of the move and how it functions in her gameplan. Point out non-obvious use cases when relevant.\n* Explaining the shortcomings of the move, i.e. unsafe on shield, stubby, slow, etc.\n* Explaining when and where to use the move. Can differentiate between if it's good in neutral, punish, against fastfallers, floaties, etc.\nIf there's something you want to debate leaving it in or out, err on the side of leaving it in. For more details, read [[User:Lynnifer/Brief_Style_Guide#Move_Cards|here]].\n</small>"
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