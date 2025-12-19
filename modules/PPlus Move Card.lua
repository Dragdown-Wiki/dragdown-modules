local List = require("pl.List")
local tooltip = require("Tooltip")
local cargo = mw.ext.cargo
local mysplit = require("Mysplit")
local inspect = require("inspect")
local tblx = require("pl.tablex")
local lib = require("Move_Card_Lib")

-- Replace local implementations with thin delegates

local function getStartupAppendix(mode)
    return lib.startupAppendix(mode.startupNotes)
end

local function getColumnHeaders(mode)
	local headers = List({
		tooltip(
			"Startup",
			'Startup or First Active Frame, the time it takes for an attack to become active. For example, a startup value of "10" means the hitbox or relevant property is active on the 10th frame.'
		),
		tooltip("Total Active", "Frames during which the move is active."),
		tooltip("Endlag", "The amount of frames where the move is no longer active."),
	})

	if mode.landingLag or mode.autocancel then
		headers:append(tooltip(
			"Landing Lag",
			"The amount of frames that the character must wait after landing with this move before becoming actionable. " ..
			mw.getCurrentFrame():preprocess("{{aerial}}") .. " landing lag assumes that the move is L-cancelled."
		))
		headers:append(tooltip(
			"Autocancel",
			"Animation frames where the character lands with standard landing lag, typically much faster than landing regularly."
		))
	end

	headers:append(tooltip("IASA",
		"Interruptible as soon as, the effective range of the move. The full animation can sometimes last longer."))
	headers:append(tooltip("Total Duration", "Total animation length."))
	return headers
end

local function getEndlagColumnValue(mode)
	if mode.endlag and mode.endlag ~= "..." then
		return mode.endlag
	end

	if not mode.totalActive or not tonumber(mode.totalDuration) then
		return "N/A"
	end

	local result = mode.totalDuration

	if mode.iasa then
		result = mode.iasa - 1
	end

	result = result - lib.multiSplitLast(mode.totalActive, { ",", "-" })

	if mode.endlag then
		return result .. mode.endlag
	end

	return result
end

local function getColumnValues(mode)
    local ensuredTotal = lib.computeTotalDuration(mode) or mode.totalDuration
		
    if ensuredTotal then
        mode.totalDuration = ensuredTotal
    end

    local columnValues = {
        landingLag = mode.landingLag,
        totalActive = mode.totalActive,
        endlag = getEndlagColumnValue(mode),
        autocancel = mode.autocancel,
        totalDuration = mode.totalDuration or "N/A",
        iasa = mode.iasa or (tonumber(mode.totalDuration) and (mode.totalDuration + 1) or nil),
        startup = "N/A"
    }

    if mode.totalActive and not mode.startup then
        local firstActive = lib.multiSplitFirst(mode.totalActive, { "+", ",", "-", "..." })
        columnValues.startup = firstActive
        mode.startup = firstActive - 1
    elseif mode.startup ~= nil then
        columnValues.startup = tonumber(mode.startup) and (mode.startup + 1) or mode.startup
        local parts = lib.parseThing(mode.startup)
        if #parts > 1 then
            columnValues.startup = parts:reduce("+") + 1 .. " [" .. columnValues.startup .. "]"
        end
    end

    columnValues.startup = columnValues.startup .. getStartupAppendix(mode)

    if mode.landingLag and mode.landingLag:sub(-1, -1) == "L" then
        columnValues.landingLag = tooltip(
            math.floor(mode.landingLag:sub(0, -2) / 2),
            "When not L-cancelled, this lasts " .. mode.landingLag:sub(0, -2) .. " frames."
        )

        mode.landingLag = tostring(math.floor(mode.landingLag:sub(0, -2) / 2))
    else
        columnValues.landingLag = mode.landingLag
    end

    return columnValues
end

local function getTable(mode, columnValues)
	local columnHeaders = getColumnHeaders(mode)

	local t = mw.html
			.create("table")
			:addClass("frame-window wikitable ")
			:css("width", "100%")
			:css("text-align", "center")

	local headersRow = t:tag("tr"):addClass("frame-window-header")
	local dataRow = t:tag("tr"):addClass("frame-window-data")

	for _, v in ipairs(columnHeaders) do
		headersRow:tag("th"):wikitext(v)
	end


	local columnValuesTags = (mode.landingLag or mode.autocancel)
			and List({ "startup", "totalActive", "endlag", "landingLag", "autocancel", "iasa", "totalDuration" })
			or List({ "startup", "totalActive", "endlag", "iasa", "totalDuration" })

	for _, tag in ipairs(columnValuesTags) do
		local val = columnValues[tag]

		if tag == "endlag" and type(val) == "string" and val:sub(-3) == "..." then
			dataRow:tag("td"):tag("i"):wikitext(val)
		else
			dataRow:tag("td"):wikitext(val or "N/A")
		end
	end


	if mode.notes ~= nil then
		local notes = lib.notesRow(mode.notes)
		if notes then
			t:node(notes)
		end
	end

	return t
end

local function findHitData(mode, hitResults)
	local hitMoves = List(mysplit(mode.hitSubactionID, ";") or {})
	local names = mysplit(mode.hitName, ";")
	local actives = List.split(mode.hitActive, ";")
	local shieldSafetyList = mysplit(mode.customShieldSafety, ";")
	local uniquesList = mysplit(mode.uniqueField, ";")

	for idIndex, id in ipairs(List.split(mode.hitID, ";")) do
		local attackId = hitMoves and hitMoves[idIndex] or mode.attackID

		if hitResults.attack == attackId and hitResults["hit label"] == id then
			return {
				hitID = id,
				move = attackId,
				name = names and names[idIndex] or id,
				active = actives[idIndex],
				shield = shieldSafetyList and shieldSafetyList[idIndex],
				unique = uniquesList and uniquesList[idIndex],
			}
		end
	end
end

local function getHitsAndHitResults(mode)
	if mode.hitID == nil then
		return {}
	end

	local idList = List.split(mode.hitID, ";")
	local hitMoves = mysplit(mode.hitSubactionID, ";")
	local whereList = List()

	for k, v in ipairs(idList) do
		local attackId = hitMoves and hitMoves[k] or mode.attackID

		whereList:append('(attack = "' .. attackId .. '" and hit_label = "' .. v .. '")')
	end

	local hitresults = cargo.query(
		"PPlus_HitData",
		"chara,attack,hit_label,seq_hit_set,damage,trajectory,wdsk,kbg,bkb,shield_damage,hitlag_mult,sdi_mult,hitbox_effect,sound,ground,aerial,clang,special_hit,angle_flipping,hits_fighters,waddle_dee,sse,saturn,wall_hit,stage_misc_hit,bomb,can_be_shielded,can_be_reflected,can_be_absorbed,remain_grabbed,enabled,ignore_invincibility,freeze_frame_disable,flinchless",
		{
			where = 'chara="' .. mode.chara .. '" and (' .. whereList:join(" or ") .. ")",
			orderBy = "_ID"
		}
	)

	return hitresults
end

--- @param weight number
--- @param result { bkb: string, kbg: string, damage: string }
local function calcTumblePercent(weight, result)
	local tumbleThreshold = 80

	if result.kbg == "0" then
		if tonumber(result.bkb) > tumbleThreshold then
			return 0
		else
			return "N/A"
		end
	end

	return math.max(
		0,
		math.ceil(
			((((tumbleThreshold - result.bkb) / (result.kbg / 100)) - 18) / ((200 / (weight + 100)) * 1.4)) /
			(result.damage * 0.05 + 0.1)
		) - result.damage
	)
end

--- @param result { wdsk: string, bkb: string, kbg: string }
local function calcWDSKWeight(result)
	return math.floor(140 * (result.wdsk + 2) / (100 * (80 - result.bkb) / result.kbg - 18) - 100)
end

--- @param result { wdsk: string, bkb: string, kbg: string, damage: string }
local function calcSimpleTumble(result)
	local minWeight = 64 -- Puff Weight
	local maxWeight = 113 -- Bowser Weight

	local tumbleMinWeight = calcTumblePercent(minWeight, result)
	local tumbleMaxWeight = calcTumblePercent(maxWeight, result)

	if result.wdsk ~= "0" then
		local wdskWeight = calcWDSKWeight(result)

		if wdskWeight < minWeight then
			return "Never"
		else
			return "Weight: " .. wdskWeight
		end
	end

	if tumbleMinWeight == "N/A" then
		return "N/A"
	end

	if tumbleMinWeight == tumbleMaxWeight then
		return tumbleMinWeight .. "%"
	end

	return tumbleMinWeight .. " - " .. tumbleMaxWeight .. "%"
end


--- @param mode { attackID: string, endlag: string, totalDuration: string?,
--- landingLag: string, iasa: string? }
--- @param active string
--- @param custom string
--- @param damage number|string
local function calcShieldSafety(mode, active, custom, damage)
	if
			mode.attackID == "Bthrow"
			or mode.attackID == "Uthrow"
			or mode.attackID == "Dthrow"
			or mode.attackID == "Fthrow"
			or mode.attackID == "Grab"
			or mode.attackID == "Pummel"
			or custom == "N/A"
	then
		return "N/A"
	end

	local stun = math.floor(damage * 0.447 + 1.99)

	if active:sub(-1, -1) == "+" then -- PROJECTILES
		local unnamedVar = tonumber(active:sub(1, #active - 1))
		local endlag = mode.totalDuration - unnamedVar
		local hitLag = math.floor(damage * 0.3333334 + 3)
		return string.format("At worst: %+d", hitLag + stun - endlag)
	end

	if mode.landingLag ~= nil then
		return string.format("%+d", stun - mode.landingLag)
	end

	local active2 = List.split(List.split(active, ", "):pop(), "-")
	local base = mode.iasa or mode.totalDuration
	local first = base - active2[1]
	local second = base - active2:pop()

	if first == second then
		return string.format("%+d", stun - first)
	end

	return string.format("%+d to %+d", stun - first, stun - second)
end

--- @param result {
--- ["shield damage"]: string, ["hitlag mult"]: string, ["sdi mult"]: string,
--- ground: string, aerial: string, clang: string }
local function getUniqueRow(result)
	local listOfUniques = List()

	if tonumber(result["shield damage"]) ~= 0 then
		listOfUniques:append("Shield Damage: " .. result["shield damage"])
	end

	if tonumber(result["hitlag mult"]) ~= 1 then
		listOfUniques:append(tooltip("Hitlag", "Applies to only the defender.") .. ": " .. result["hitlag mult"])
	end

	if tonumber(result["sdi mult"]) ~= 1 then
		listOfUniques:append("SDI: " .. result["sdi mult"])
	end

	if result.ground == "False" and result.aerial ~= "False" then
		listOfUniques:append("Airborne Only")
	end

	if result.ground ~= "False" and result.aerial == "False" then
		listOfUniques:append("Grounded Only")
	end

	if result.clang == "False" then
		listOfUniques:append("Transcendent")
	end

	if #listOfUniques > 0 then
		return listOfUniques:join(", ")
	end
end

local function getAdvHits(result, mode)
	local columns = List.split(
		"name,hitlag_mult,shield_stun,shield_damage,shield_kb,shield_hitlag,sdi_mult,hitbox_effect,ground,aerial,clang,angle_flipping,hits_fighters,waddle_dee,sse,saturn,wall_hit,stage_misc_hit,bomb,can_be_shielded,can_be_reflected,can_be_absorbed,remain_grabbed,enabled,ignore_invincibility,freeze_frame_disable,flinchless",
		",")

	local hitRow = mw.html.create("tr")

	for _, col in ipairs(columns) do
		--- @type string|number
		local assignedValue = ""

		if col == "hitlag_mult" then
			assignedValue = math.floor(math.floor(result.damage * 0.3333334 + 3) * result["hitlag mult"])
		elseif col == "sdi_mult" then
			assignedValue = result["sdi mult"] .. "×"
		elseif col == "shield_stun" then
			assignedValue = math.floor(result.damage * 0.447 + 1.99)
		elseif col == "shield_damage" then
			assignedValue = result.damage
		elseif col == "shield_kb" then
			assignedValue = "Shield KB?"
		elseif col == "name" then
			assignedValue = findHitData(mode, result).name
		else
			assignedValue = result[col]
		end

		hitRow:tag("td"):wikitext(assignedValue)
	end

	return hitRow
end

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
		"Tumble",
		"The pre-hit percent that this hit tumbles and knocks down at, from the lightest to the heaviest character. N/A means that the hit can never tumble.<br>If the move is weight dependent set knockback, a maximum weight for tumbling will be displayed instead. Characters with this weight or lower will enter tumble."
	),
	tooltip(
		"Shield Safety",
		"The frame advantage after a move connects on shield. If a move ends prematurely with landing lag like an aerial, the shield safety assumes that the character lands immediately after performing the hit."
	),
}

--- @param mode { landingLag: string, totalActive: string?, startup: string?,
--- endlag: string, frameChart: string?, autocancel: string?, iasa: string?,
--- notes: string?, hitID: string?, hitSubactionID: string?, attackID: string,
--- chara: string?, totalDuration: string? }
local function createMode(mode)
    local columnValues = getColumnValues(mode)
    local t = getTable(mode, columnValues)
    local frameChart = lib.getFrameChart(mode)

    if mode.hitID == nil then
        return tostring(mw.html.create("div"):addClass("numbers-panel"):css("overflow-x", "auto"):node(t):node(frameChart))
    end

    local headersHitRow = mw.html.create("tr")

    for _, v in ipairs(hitHeaders) do
        headersHitRow:tag("th"):wikitext(v)
    end

    local hitsWindow = mw.html.create("table"):addClass("wikitable hits-window"):node(headersHitRow)

    local hitResults = getHitsAndHitResults(mode)

    for _, hitResult in ipairs(hitResults) do
        local hitData = findHitData(mode, hitResult)
        local hitRow = hitsWindow:tag("tr"):addClass("hit-row")

        hitRow:tag("td"):wikitext(
            tonumber(hitData.name) == nil and hitData.name or hitResult.seq_hit_set
        )

        hitRow:tag("td"):wikitext(hitResult.damage .. "%")
				:tag("td"):wikitext(hitData.active)
				:tag("td"):wikitext(hitResult.bkb)
				:tag("td"):wikitext(hitResult.kbg)
				:tag("td"):wikitext(hitResult.wdsk)
				:tag("td"):wikitext(lib.makeAngleDisplay(hitResult.trajectory, hitResult["angle flipping"]))
				:tag("td"):wikitext(calcSimpleTumble(hitResult))
				:tag("td"):wikitext(calcShieldSafety(mode, hitData.active, hitData.shield, hitResult.damage))

		local uniqueRow = getUniqueRow(hitResult)

		if uniqueRow then
			hitsWindow:tag("tr")
					:addClass("unique-row")
					:tag("td"):attr("colspan", 8)
					:css("text-align", "left")
					:wikitext("'''Unique''': " .. uniqueRow)
		end
	end

	local numbersPanel = mw.html.create("div"):addClass("numbers-panel")
			:css("overflow-x", "auto")
			:node(t)
			:node(frameChart)
			:node(hitsWindow)

	return tostring(numbersPanel)
end

local columnHeaders = {
	"Hit / Hitbox ",
	"Hitlag",
	"Shield Stun",
	"Shield Damage",
	"Shield Knockback",
	"Shield Hitlag",
	"SDI Multiplier",
	"Hitbox Effect",
	"Hits Grounded?",
	"Hits Airborne?",
	"Clanks?",
	"Angle Flipping",
	"Hits Characters",
	tooltip("Hits Dees", "Includes Waddle Dees, Waddle Doos, and Pikmin."),
	tooltip("Hits SSE Enemies", "Subspace Emissary. Irrelevant to competitive play."),
	tooltip("Hits Saturn", "Hits Mr Saturn, Snake C4, and Grenade."),
	"Hits Wall, Floor, Ceilings",
	"Hits Other Stage Elements",
	tooltip("Hits Bombs", "Hits Link and Toon Link's bomb, as well as Bo-Bombs."),
	"Can Be Shielded?",
	"Can Be Reflected?",
	"Can Be Absorbed?",
	"Remain Grabbed?",
	"Enabled?",
	"Ignores Invincibility?",
	"Disables Hitlag?",
	"Flinchless?",
}

local function createAdvMode(mode)
	local hitresults = getHitsAndHitResults(mode)

	if #(hitresults) == 0 then
		return tostring(mw.html.create("div"))
	end

	local hitsWindow = mw.html.create("table"):addClass("hits-window wikitable")
	local headersRow = hitsWindow:tag("tr"):addClass("adv-hits-list-header")

	for _, v in ipairs(columnHeaders) do
		headersRow:tag("th"):wikitext(v)
	end

	for _, result in ipairs(hitresults) do
		hitsWindow:node(getAdvHits(result, mode))
	end

	local output = mw.html
			.create("div")
			:tag("div")
			:addClass("toccolours mw-collapsible")
			:css("width", "100%")
			:css("overflow", "auto")
			:css("margin", "1em 0")
			:tag("div")
			:css("font-weight", "bold")
			:css("line-height", "1.6")
			:wikitext("'''Hits: Advanced Data'''")
			:done()
			:tag("div")
			:addClass("mw-collapsible-content")
			:node(hitsWindow)
			:done()
			:done()

	return tostring(output)
end

local function getCardHTML(chara, attack, desc, advDesc)
	local paletteSwap = mw.html.create("div"):addClass("data-palette"):done()

	local nerdSection =
			mw.html.create("div"):addClass("mw-collapsible-content")
			:tag("br"):css("clear", "both"):done()
			:tag("div"):wikitext(advDesc):done()

	local modes = lib.getModes(chara, attack,
		"chara,attack,attackID,mode,startup,startupNotes,totalActive,totalActiveNotes,endlag,endlagNotes,cancel,cancelNotes,landingLag,landingLagNotes,totalDuration,totalDurationNotes,iasa,autocancel,autocancelNotes,hitID,hitSubactionID,hitName,hitActive,customShieldSafety,uniqueField,frameChart,articleID,notes"
	)

	if #modes > 1 then
		local tabberResult = lib.tabber(modes:map(function(mode)
			return { mode.mode, createMode(mode) }
		end))

		local tabberResultAdv = lib.tabber(modes:map(function(mode)
			return { mode.mode, createAdvMode(mode) }
		end))

		paletteSwap:node(tabberResult):addClass("move-mode-tabs")
		nerdSection:node(tabberResultAdv):addClass("move-mode-tabs")
		-- There should be a tabber element both in the frame window and also the advanced element one
	else
		local mode = modes[1]

		if mode then
			paletteSwap:node(createMode(mode))
			nerdSection:node(createAdvMode(mode))
		end
	end

	local nerdHeader = mw.html
			.create("div")
			:addClass("mw-collapsible mw-collapsed")
			:css("width", "100%")
			:css("overflow", "auto")
			:css("margin", "1em 0")
			:attr("data-expandtext", "Show Stats for Nerds")
			:attr("data-collapsetext", "Hide Stats for Nerds")
			--Attack Info Container
			:node(nerdSection)

	return mw.html.create("div"):addClass("attack-container")
			:tag("div"):addClass("attack-gallery"):wikitext(
				lib.getTabberData(chara, attack)
			):done()
			:tag("div"):addClass("attack-info")
			:node(paletteSwap)
			:tag("div"):addClass("move-description")
			:wikitext("\n"):wikitext(desc):wikitext("\n"):done()
			:node(nerdHeader)
			:done()
end

local function main(frame)
	local args = require("Arguments").getArgs(frame)
	local chara = args.chara or mw.title.getCurrentTitle().subpageText
	local desc = args.desc or args.description

	if desc == "" or desc == nil then
		desc =
		"<small>''This move card is missing a move description. The following bullet points should all be one paragraph or more and be included:''\n* Brief 1-2 sentences stating the basic function and utility of the move. Ex: ''\"Excellent anti-air, combo-starter, and combo-extender. The move starts behind before sweeping to the front.\"''\n* Explaining the reward and usefulness of the move and how it functions in her gameplan. Point out non-obvious use cases when relevant.\n* Explaining the shortcomings of the move, i.e. unsafe on shield, susceptible to CC, stubby, slow, etc.\n* Explaining when and where to use the move. Can differentiate between if it's good in neutral, punish, against fastfallers, floaties, etc.\nIf there's something you want to debate leaving it in or out, err on the side of leaving it in. For more details, read [[User:Lynnifer/Brief_Style_Guide#Move_Cards|here]].\n</small>"
	end

	local html = getCardHTML(chara, args.attack, desc, args.advDesc)

	return tostring(html)
			.. mw.getCurrentFrame():extensionTag({
				name = "templatestyles",
				args = { src = "Template:MoveCard/shared/styles.css" },
			})
end

return { main = main }
