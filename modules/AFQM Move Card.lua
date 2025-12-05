local tooltip = require("Tooltip")
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

local lib = require("Move_Card_Lib")

local drawFrameData = lib.drawFrameData

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

local makeAngleDisplay = lib.makeAngleDisplay

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

local getTabberData = lib.getTabberData

return {
	main = function(frame)
		local args = require("Arguments").getArgs(frame)
		local chara = args.chara or mw.title.getCurrentTitle().subpageText

		local paletteSwap = mw.html.create("div")
				:addClass("data-palette")

		local modes = lib.getModes(chara, args.attack,
			"chara,attack,mode,notes,startup,startupNotes,totalActive," ..
			"landingLag,totalDuration,hitID,hitActive"
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
