local p = {}
local mArguments
local cargo = mw.ext.cargo

local tabber = require("Tabber").renderTabber
local tooltip = require("Tooltip")
local GetImagesWikitext = require("GetImagesWikitext")
local utils = require("Move Card Utils")

local function readModes(chara, attack)
	local tables = "AFQM_MoveMode"
	local fields =
		"chara,attack,attackID,mode,image,hitbox,caption,hitboxCaption,notes,startup,startupNotes,totalActive,totalActiveNotes,endlag,endlagNotes,cancel,cancelNotes,landingLag,landingLagNotes,iasa,autocancel,autocancelNotes,totalDuration,totalDurationNotes,frameChart,hitID,hitMoveID,hitName,hitActive,uniqueField,articleID"
	local args = {
		where = 'AFQM_MoveMode.chara="' .. chara .. '" and AFQM_MoveMode.attack="' .. attack .. '"',
		orderBy = "_ID",
	}
	local results = cargo.query(tables, fields, args)
	return results
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

local function getHits(hasArticle, result, mode, hitData)
	--chara, attackID, hitID, hitMoveID, hitName, hitActive,  uniques
	local hitRow = mw.html.create("tr"):addClass("hit-row")
	hitRow:tag("td"):wikitext(hitData.name)
	hitRow:tag("td"):wikitext(result.dmg .. "%")
		:tag("td"):wikitext(hitData.active)
		:tag("td"):wikitext(result.bkb )
		:tag("td"):wikitext(result.kbs )
		:tag("td"):wikitext(result.hitlag )
		:tag("td"):wikitext(utils.makeAngleDisplay(result.angle))
		:done()
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
		-- tooltip(
		-- 	"IASA",
		-- 	"Interruptible as soon as, the effective range of the move. The full animation can sometimes last longer."
		-- ),
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
			-- tooltip(
			-- 	"IASA",
			-- 	"Interruptible as soon as, the effective range of the move. The full animation can sometimes last longer."
			-- ),
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
	if mode.landingLag then
		columnValues["landingLag"] = mode.landingLag
	end
	if mode.landingLagNotes then
		columnValues["landingLag"] = columnValues["landingLag"] .. " " .. tooltip("ⓘ", mode.landingLagNotes)
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
	-- columnValues["iasa"] = "N/A"
	-- if mode.iasa then
	-- 	columnValues["iasa"] = mode.iasa
	-- elseif mode.totalDuration then
	-- 	columnValues["iasa"] = mode.totalDuration + 1
	-- end
	columnValues["totalDuration"] = "N/A"
	if mode.totalDuration then
		columnValues["totalDuration"] = mode.totalDuration
	end
	if mode.totalDurationNotes then
		columnValues["totalDuration"] = columnValues["totalDuration"] .. " " .. tooltip("ⓘ", mode.totalDurationNotes)
	end
	local dataRow = mw.html.create("tr"):addClass("frame-window-data")
	local columnValuesTags = { "startup", "totalActive", "endlag", "totalDuration" }
	-- local columnValuesTags = { "startup", "totalActive", "endlag", "iasa", "totalDuration" }
	if mode.landingLag then
		columnValuesTags = { "startup", "totalActive", "endlag", "landingLag", "totalDuration" }
		-- columnValuesTags = { "startup", "totalActive", "endlag", "landingLag", "iasa", "totalDuration" }
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
		frameChart:wikitext(utils.drawFrameData(mode.startup,mode.totalActive,mode.endlag,mode.landingLag)):done()
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
				"Hitlag",
				"Hitlag - amount of freeze frames."
			),
			tooltip("Angle", "The angle at which the move sends the target."),
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
				local uniqueRow = utils.showHitUniques(hasArticle, hitresults[k], motherhits[k].unique)
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
			hitsWindow:node(p.getAdvHits(hitresults[k], mode, motherhits[hitresults[k]], articleList))
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



local function getCardHTML(chara, attack, desc, advDesc)
	-- Lazy Load automated frame chart generator
	-- local autoChart = require('FrameChart').autoChart
	-- Outer Container of the card
	local card = mw.html.create("div"):addClass("attack-container")

	-- Images
	local acquiredImages = utils.getImageGallery(chara, attack)
	local tabberData
	if acquiredImages ~= '<div class="attack-gallery-image"></div>' then
		tabberData = tabber({
			label1 = "Images",
			content1 = utils.getImageGallery(chara, attack),
			-- label2 = "Hitboxes",
			-- content2 = getHitboxGallery(chara, attack),
		})
	else
		local container = mw.html.create("div"):addClass("attack-gallery-image")
		container:wikitext(
			table.concat(
				utils.getImagesWikitext({
					{
						file = "AFQM_" .. chara .. "_" .. attack .. "_0.png",
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
			local uniquesList = mysplit(mode.uniqueField, ";")
			for k in ipairs(idList) do
				local attack = mode.attack
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
				hits[k]["unique"] = nil
				if uniquesList ~= nil and uniquesList[k] ~= "-" then
					hits[k]["unique"] = uniquesList[k]
				end
			end

			local tables = "AFQM_HitData"
			local fields = "chara,attack,hit_id,dmg,bkb,kbs,hitlag,angle"
			local whereField = 'chara="' .. mode.chara .. '" and ('
			local whereList = {}
			for k, v in pairs(hits) do
				table.insert(whereList, '(attack = "' .. v["move"] .. '" and hit_id = "' .. v["hitID"] .. '")')
			end
			local whereField = whereField .. table.concat(whereList, " or ") .. ")"
			local args = { where = whereField, orderBy = "_ID" }
			hit_results = cargo.query(tables, fields, args)
		end
		queues[mode] = {mode = mode, hits = hits, hit_results = hit_results, articles = articles}
	end
	if #tableData > 1 then
		local object = {}
		local advObject = {}
		for i, _ in ipairs(tableData) do
			object["label" .. i] = tableData[i].mode
			object["content" .. i] = createMode(false, queues[tableData[i]].mode, queues[tableData[i]].hits, queues[tableData[i]].hit_results, nil)
			-- object["content" .. i] = createMode(tableData[i], hits, hit_results, throw_results)
			-- advObject["label" .. i] = tableData[i].mode
			-- advObject["content" .. i] = createAdvMode(queues[tableData[i]].mode, queues[tableData[i]].articles, queues[tableData[i]].hits, queues[tableData[i]].hit_results, queues[tableData[i]].throw_results)
		end
		local t = tabber(object)
		-- local t2 = tabber(advObject)
		paletteSwap:node(t):addClass("move-mode-tabs"):done()
		-- nerdSection:node(t2):addClass("move-mode-tabs"):done()
		-- There should be a tabber element both in the frame window and also the advanced element one
	else
		if(queues[tableData[1]]) then
			paletteSwap:node(createMode(false, queues[tableData[1]].mode, queues[tableData[1]].hits, queues[tableData[1]].hit_results, nil)):done()
			-- nerdSection:node(createAdvMode(queues[tableData[1]].mode, queues[tableData[1]].articles, queues[tableData[1]].hits, queues[tableData[1]].hit_results, queues[tableData[1]].throw_results)):done()
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
	mArguments = require("Arguments")
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