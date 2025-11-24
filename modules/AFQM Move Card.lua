local tooltip = require("Tooltip")
local getImagesWikitext = require("GetImagesWikitext")
local mysplit = require("Mysplit")
local List = require("pl.List")

local hitHeaders = List({
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
		"Hitlag",
		"Hitlag - amount of freeze frames."
	),
	tooltip("Angle", "The angle at which the move sends the target."),
})

local function drawFrame(frames, frameType)
	return List.range(1, tonumber(frames))
			:map(function()
				return mw.html.create("div"):addClass("frame-data frame-data-" .. frameType)
			end)
			:join()
end

local function getActive(totalActive, totalStartup)
	local active = List()
	local first_active_frame = totalStartup + 1

	for _, value in ipairs(List.split(totalActive or "", ",")) do
		local list = List.split(value, "-"):map(tonumber)
		local startFrame = list[1]

		if startFrame > first_active_frame + 1 then
			active:append(-1 * (startFrame - first_active_frame - 1))
		end

		local endFrame = list:pop()
		active:append(endFrame - startFrame + 1)
		first_active_frame = endFrame
	end

	return active
end

local function drawFrameData(mode)
	-- Create container for frame data
	local frameChartDataHtml = mw.html.create("div"):addClass("frameChart-data")
	local startup = tonumber(mode.startup) and List({ mode.startup }) or List.split(mode.startup or "", "+")

	for k, v in ipairs(startup) do
		local isEven = k % 2 == 0
		frameChartDataHtml:wikitext(drawFrame(v, "startup" .. (isEven and "-alt" or "")))
	end

	local totalStartup = startup:reduce("+") or 0

	-- Option for inputting multihits, works for moves with 1+ gaps in the active frames

	for _, v in pairs(getActive(mode.totalActive, totalStartup)) do
		if v < 0 then
			frameChartDataHtml:wikitext(drawFrame(v * -1, "inactive"))
		else
			frameChartDataHtml:wikitext(drawFrame(v, "active"))
		end
	end

	frameChartDataHtml:wikitext(drawFrame(mode.endlag, "endlag"))

	-- Special Recovery of move
	local landingLag = tonumber(mode.landingLag) or 0

	frameChartDataHtml:wikitext(drawFrame(landingLag, "landingLag"))

	local html = mw.html.create("div"):addClass("frameChart")

	html
			:node(frameChartDataHtml)
			:done()
			:tag("div")
			:addClass("frame-data-total")
			:tag("span")
			:addClass("frame-data-total-label")
			:wikitext("First Active Frame:")
			:done()
			:tag("span")
			:addClass("frame-data-total-value")
			:wikitext(
				mode.totalActive == nil and "N/A" or totalStartup + 1
			)

	return tostring(html)
			.. mw.getCurrentFrame():extensionTag({
				name = "templatestyles",
				args = { src = "Module:FrameChart/styles.css" },
			})
end

local function getDataRow(landingLag, columnValues)
	local dataRow = mw.html.create("tr"):addClass("frame-window-data")
	local columnValuesTags = List({ "startup", "totalActive", "endlag" })

	if landingLag then
		columnValuesTags:append("landingLag")
	end

	columnValuesTags
			:append("totalDuration")
			:foreach(function(tag)
				dataRow:tag("td"):wikitext(columnValues[tag] or "N/A")
			end)

	return dataRow
end

local function getAngleColor(angle)
	if angle > 360 then
		return "#ff0000"
	elseif angle <= 45 or angle >= 315 then
		return "#1ba6ff"
	elseif angle > 225 then
		return "#ff6b6b"
	elseif angle > 135 then
		return "#de7cd1"
	end
	return "#16df53"
end

local function makeAngleDisplay(angle)
	angle = tonumber(angle)

	local display = mw.html.create("span")
	local div1 = mw.html.create("div")
			:css("position", "relative")
			:css("top", "0")
			:css("max-width", "256px")

	if angle < 360 then
		div1:tag("div")
				:css("transform", "rotate(-" .. angle .. "deg)")
				:css("z-index", "0")
				:css("position", "absolute")
				:css("top", "0")
				:css("left", "0")
				:css("transform-origin", "center center")
				:wikitext("[[File:AFQM_AngleComplex_BG.svg|256px|link=]]")
				:done()
				:tag("div")
				:css("z-index", "1")
				:css("position", "relative")
				:css("top", "0")
				:css("left", "0")
				:wikitext("[[File:AFQM_AngleComplex_MG.svg|256px|link=]]")
				:done()
				:tag("div")
				:css("transform", "rotate(-" .. angle .. "deg)")
				:css("z-index", "2")
				:css("position", "absolute")
				:css("top", "0")
				:css("left", "0")
				:css("transform-origin", "center center")
				:wikitext("[[File:AFQM_AngleComplex_FG.svg|256px|link=]]")

		display:node(div1)
		display:wikitext("[[File:AFQM_AngleComplex_Key.svg|256px|link=]]")
	else
		display:node(div1)
	end

	local angleColorElem = mw.html.create("span")
			:wikitext(angle)
			:css("color", getAngleColor(angle))

	return tostring(tooltip(tostring(angleColorElem), tostring(display)))
end

local function getHeadersRow(mode)
	local columnHeaders = List({
		tooltip(
			"Startup",
			'Startup or First Active Frame, the time it takes for an attack to become active. ' ..
			'For example, a startup value of "10" means the hitbox or relevant property is active on the 10th frame.'
		),
		tooltip("Total Active", "Frames during which the move is active."),
		tooltip("Endlag", "The amount of frames where the move is no longer active."),
		mode.landingLag and tooltip(
			"Landing Lag",
			"The amount of frames that the character must wait after landing with this move before becoming actionable. " ..
			mw.getCurrentFrame():preprocess("{{aerial}}") .. " landing lag assumes that the move is L-cancelled."
		),
		tooltip("Total Duration", "Total animation length.")
	})

	local headersRow = mw.html.create("tr"):addClass("frame-window-header")

	for _, v in pairs(columnHeaders) do
		headersRow:tag("th"):wikitext(v)
	end

	return headersRow
end

local function getNumbersPanel(tableElem, mode)
	local numbersPanel = mw.html.create("div")
			:addClass("numbers-panel")
			:css("overflow-x", "auto")
			:node(tableElem)
			:tag("div"):addClass("frame-chart")
			:wikitext(drawFrameData(mode))
			:done()

	if mode.hitID == nil then
		return numbersPanel
	end

	local hitsWindow = numbersPanel:tag("table"):addClass("wikitable hits-window")
	local headersHitRow = hitsWindow:tag("tr")

	for _, v in pairs(hitHeaders) do
		headersHitRow:tag("th"):wikitext(v)
	end

	local results = mw.ext.cargo.query(
		"AFQM_HitData",
		"attack,hit_id,dmg,bkb,kbs,hitlag,angle",
		{
			where =
					'chara = "' .. mode.chara
					.. '" and attack = "' .. mode.attack
					.. '" and hit_id in (' .. List.split(mode.hitID, ";"):join(",") .. ')',
			orderBy = "_ID"
		}
	)

	for k, result in ipairs(results) do
		local hitRow = hitsWindow:tag("tr"):addClass("hit-row")

		hitRow:tag("td"):wikitext(List.split(mode.hitID, ";")[k])

		hitRow:tag("td"):wikitext(result.dmg .. "%")
				:tag("td"):wikitext(List.split(mode.hitActive, ";")[k])
				:tag("td"):wikitext(result.bkb)
				:tag("td"):wikitext(result.kbs)
				:tag("td"):wikitext(result.hitlag)
				:tag("td"):wikitext(makeAngleDisplay(result.angle))
	end

	return numbersPanel
end

local function createMode(mode)
	local columnValues = {
		landingLag = mode.landingLag,
		totalActive = mode.totalActive,
	}

	if mode.startup == nil then
		if mode.totalActive ~= nil then
			local unknownVar = List.split(mysplit(mode.totalActive, ",")[1], "-")[1]
			columnValues.startup = unknownVar
			mode.startup = unknownVar - 1
		end
	else
		columnValues.startup = mode.startup

		if mode.startup:find("+") and not mode.startup:find("%[") then
			local startupSum = List.split(mode.startup, "+"):reduce("+")
			columnValues.startup = tostring(startupSum + 1) .. " [" .. mode.startup .. "]"
		end
	end

	if mode.startupNotes == "SMASH" then
		columnValues.startup = columnValues.startup
				.. " "
				.. tooltip("ⓘ", "Total Uncharged Startup<br>[Pre-Charge Window + Post-Charge Window]")
	end

	local function addNotes(key)
		if mode[key .. "Notes"] then
			columnValues[key] = mode[key] .. " " .. tooltip("ⓘ", mode[key .. "Notes"])
		end
	end

	if mode.endlag == nil or mode.endlag == "..." then
		if mode.totalActive and tonumber(mode.totalDuration) then
			columnValues.endlag = mode.totalDuration - List.split(List.split(mode.totalActive, ","):pop(), "-"):pop()
			mode.endlag = columnValues.endlag
		else
			mode.endlag = 0
		end
	end

	addNotes("totalActive")
	addNotes("endlag")
	addNotes("landingLag")

	mode.totalDuration = mode.totalDuration or List.split(mode.totalActive, "-"):pop()
	columnValues.totalDuration = mode.totalDuration or "N/A"
	addNotes("totalDuration")

	local dataRow = getDataRow(mode.landingLag, columnValues)

	local tableElem = mw.html.create("table")
			:addClass("frame-window wikitable ")
			:css("width", "100%")
			:css("text-align", "center")
			:node(getHeadersRow(mode))
			:node(dataRow)

	if mode.notes ~= nil then
		--- TODO: add <tr class="notes-row"> as wrapping element.
		--- currently, mw just auto-injects a basic <tr>.
		tableElem:tag("td")
				:css("text-align", "left")
				:attr("colspan", "100%")
				:wikitext("'''Notes:''' " .. mode.notes)
	end

	return tostring(getNumbersPanel(tableElem, mode))
end

local function getTabberData(chara, attack)
	local results = mw.ext.cargo.query(
		"AFQM_MoveMode, AFQM_MoveMode__image, AFQM_MoveMode__caption",
		"image=file, caption",
		{
			join = List({
				"AFQM_MoveMode__image._rowID = AFQM_MoveMode._ID",
				"AFQM_MoveMode__image._rowID = AFQM_MoveMode__caption._rowID",
				"AFQM_MoveMode__image._position = AFQM_MoveMode__caption._position"
			}):join(","),
			where = 'chara="' .. chara .. '" and attack="' .. attack .. '"',
			orderBy = "_ID",
			groupBy = "AFQM_MoveMode__image._value",
		}
	)

	local container = mw.html.create("div")
			:addClass("attack-gallery-image")

	if #results == 0 then
		container:wikitext(
			table.concat(
				getImagesWikitext({ {
					file = "AFQM_" .. chara .. "_" .. attack .. "_0.png",
					caption = "NOTE: This is an incomplete card, with data modes planning to be uploaded in the future.",
				} })
			)
		)
	end

	container:wikitext(getImagesWikitext(results):join())

	return mw.getCurrentFrame():extensionTag({
		name = "tabber",
		content = "|-|Images=" .. tostring(container)
	})
end

return {
	main = function(frame)
		local args = require("Arguments").getArgs(frame)
		local chara = args.chara or mw.title.getCurrentTitle().subpageText

		local paletteSwap = mw.html.create("div")
				:addClass("data-palette")

		local modes = mw.ext.cargo.query(
			"AFQM_MoveMode",
			"chara,attack,mode,notes,startup,startupNotes,totalActive," ..
			"landingLag,totalDuration,hitID,hitActive",
			{
				where = 'chara="' .. chara .. '" and attack="' .. args.attack .. '"'
			}
		)

		if #modes > 1 then
			local tabberResult = mw.getCurrentFrame():extensionTag({
				name = "tabber",
				content = List(modes):map(function(mode)
					return "|-|" .. mode.mode .. "=" .. createMode(mode)
				end):join()
			})

			paletteSwap:node(tabberResult):addClass("move-mode-tabs")
		end

		if #modes == 1 then
			paletteSwap:node(createMode(modes[1]))
		end

		local nerdHeader = mw.html.create("div")
				:addClass("mw-collapsible mw-collapsed")
				:css("width", "100%")
				:css("overflow", "auto")
				:css("margin", "1em 0")
				:attr("data-expandtext", "Show Stats for Nerds")
				:attr("data-collapsetext", "Hide Stats for Nerds")

		nerdHeader:tag("div")
				:addClass("mw-collapsible-content")
				:tag("br"):css("clear", "both"):done()
				:tag("div"):wikitext(args.advDesc)

		local card = mw.html.create("div"):addClass("attack-container")

		card:tag("div")
				:addClass("attack-gallery")
				:wikitext(getTabberData(chara, args.attack))

		local attackInfo = card:tag("div"):addClass("attack-info"):node(paletteSwap)

		attackInfo:tag("div"):addClass("move-description")
				:wikitext("\n")
				:wikitext(
					args.desc or (
						"<small>''This move card is missing a move description. "
						.. "The following bullet points should all be one paragraph or more and be included:''\n"
						.. "* Brief 1-2 sentences stating the basic function and utility of the move. "
						.. "Ex: ''\"Excellent anti-air, combo-starter, and combo-extender. "
						.. "The move starts behind before sweeping to the front.\"''\n"
						.. "* Explaining the reward and usefulness of the move and how it functions in her gameplan. "
						.. "Point out non-obvious use cases when relevant.\n"
						.. "* Explaining the shortcomings of the move, i.e. unsafe on shield, stubby, slow, etc.\n"
						.. "* Explaining when and where to use the move. Can differentiate between if it's good in neutral, "
						.. "punish, against fastfallers, floaties, etc.\n"
						.. "If there's something you want to debate leaving it in or out, "
						.. "err on the side of leaving it in. For more details, read "
						.. "[[User:Lynnifer/Brief_Style_Guide#Move_Cards|here]].\n</small>"
					)
				)
				:wikitext("\n")

		attackInfo:node(nerdHeader)

		return tostring(card)
				.. mw.getCurrentFrame():extensionTag({
					name = "templatestyles",
					args = { src = "Template:MoveCard/shared/styles.css" },
				})
	end
}
