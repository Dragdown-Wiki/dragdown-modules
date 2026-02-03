local List = require("pl.List")
local tblx = require("pl.tablex")
local tooltip = require("Tooltip")
local GetImagesWikitext = require("GetImagesWikitext")

--- @param frames number
--- @param frameType string
--- @return string
local function drawFrame(frames, frameType)
	return List.range(1, tonumber(frames))
		:map(function()
			return mw.html.create("div"):addClass("frame-data frame-data-" .. frameType)
		end)
		:join()
end

--- @param angle number
--- @return string
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

--- @param angleArg number|string
--- @param flipper string?
--- @return string
local function makeAngleDisplay(angleArg, flipper)
	local game = mw.title.getCurrentTitle().rootText
	local angle = tonumber(angleArg)
	assert(angle ~= nil)

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
			:wikitext("[[File:" .. game .. "_AngleComplex_BG.svg|256px|link=]]")

		div1:tag("div")
			:css("z-index", "1")
			:css("position", "relative")
			:css("top", "0")
			:css("left", "0")
			:wikitext("[[File:" .. game .. "_AngleComplex_MG.svg|256px|link=]]")

		div1:tag("div")
			:css("transform", "rotate(-" .. angle .. "deg)")
			:css("z-index", "2")
			:css("position", "absolute")
			:css("top", "0")
			:css("left", "0")
			:css("transform-origin", "center center")
			:wikitext("[[File:" .. game .. "_AngleComplex_FG.svg|256px|link=]]")

		if flipper then
			div1:wikitext("Angle Flipper: " .. flipper)
		end

		display:node(div1)
		display:wikitext("[[File:" .. game .. "_AngleComplex_Key.svg|256px|link=]]")
	else
		if flipper then
			div1:wikitext("Angle Flipper: " .. flipper)
		end

		display:node(div1)
	end

	local angleColorElem = mw.html.create("span")
		:wikitext(angle)
		:css("color", getAngleColor(angle))

	return tostring(tooltip(tostring(angleColorElem), tostring(display)))
end

local function getGame()
	return mw.title.getCurrentTitle().rootText
end

local function getTabberData(chara, attack)
	local game = getGame()
	local results = mw.ext.cargo.query(
		game ..
		"_MoveMode, " .. game .. "_MoveMode__image, " .. game .. "_MoveMode__caption",
		"image=file, caption",
		{
			join = List({
				game .. "_MoveMode__image._rowID = " .. game .. "_MoveMode._ID",
				game ..
				"_MoveMode__image._rowID = " .. game .. "_MoveMode__caption._rowID",
				game ..
				"_MoveMode__image._position = " .. game .. "_MoveMode__caption._position",
			}):join(","),
			where = 'chara="' .. chara .. '" and attack="' .. attack .. '"',
			orderBy = "_ID",
			groupBy = game .. "_MoveMode__image._value",
		}
	)

	local container = mw.html.create("div")
		:addClass("attack-gallery-image")

	if #results == 0 then
		container:wikitext(
			table.concat(
				GetImagesWikitext({
					{
						file = game .. "_" .. chara .. "_" .. attack .. "_0.png",
						caption =
						"NOTE: This is an incomplete card, with data modes planning to be uploaded in the future.",
					},
				})
			)
		)
	end

	container:wikitext(GetImagesWikitext(results):join())

	return mw.getCurrentFrame():extensionTag({
		name = "tabber",
		content = "|-|Images=" .. tostring(container),
	})
end

local function getModes(chara, attack, fields)
	return List(mw.ext.cargo.query(
		getGame() .. "_MoveMode",
		fields,
		{
			where = 'chara="' .. chara .. '" and attack="' .. attack .. '"',
			orderBy = "_ID",
		}
	))
end

--- @param text string
--- @param separators string[]
--- @return string
local function multiSplitLast(text, separators)
	local list = List({ text })

	for _, sep in ipairs(separators) do
		list = List.split(list:pop(), sep)
	end

	return list:pop()
end

local function computeEndlag(mode)
	if mode.endlag and mode.endlag ~= "..." then
		return tonumber(mode.endlag)
	end

	if not mode.totalActive or not tonumber(mode.totalDuration) then
		return 0
	end

	local lastActive = multiSplitLast(mode.totalActive, { ",", "-" })

	if mode.iasa then
		return mode.iasa - 1 - lastActive
	end

	return mode.totalDuration - lastActive
end

--- @param text string
--- @param separators string[]
--- @return string
local function multiSplitFirst(text, separators)
	local list = List({ text })

	for _, sep in ipairs(separators) do
		list = List.split(list[1], sep)
	end

	return list[1]
end

--- @param text string|number?
--- @return pl.List<string>
local function parseThing(text)
	if text == nil then
		return List({})
	end

	if type(text) == "number" then
		return List({ tonumber(text) })
	end

	if text:find("+") and not string.find(text, "%[") then
		return List.split(text, "+")
	end

	return List({})
end

--- @param mode { startup: string?, totalActive: string? }
--- @return number|string
local function getStartup(mode)
	if mode.startup == nil and mode.totalActive ~= nil then
		return multiSplitFirst(mode.totalActive, { ",", "-" }) - 1
	end

	return mode.startup
end

--- @param mode { startup: string, totalActive: string? }
--- @return number
local function getTotalStartup(mode)
	local startup = getStartup(mode)
	return List(parseThing(startup)):reduce("+") or 0
end

--- @param mode { totalActive: string?, startup: string }
--- @return pl.List<number>
local function getActive(mode)
	local totalStartup = getTotalStartup(mode)
	local active = List()
	local firstActive = totalStartup + 1

	if not mode.totalActive or mode.totalActive == "N/A" then
		return List()
	end

	for _, v in ipairs(List.split(mode.totalActive, ",")) do
		local splitted = List.split(v, "-"):map(tonumber)
		local start = splitted[1]

		if start > firstActive + 1 then
			active:append(-1 * (start - firstActive - 1))
		end

		local last = splitted:pop()
		active:append(last - start + 1)
		firstActive = last
	end

	return active
end

--- @param mode { startup: string, endlag: string?, landingLag: string, totalActive: string?, totalDuration: string? }
--- @return string
local function drawFrameData(mode)
	-- Trust numeric endlag if provided; otherwise use the shared computation.
	local endlag = tonumber(mode.endlag)
	if not endlag then
		endlag = computeEndlag(mode)
	end

	-- Create container for frame data
	local frameChartDataHtml = mw.html.create("div"):addClass("frameChart-data")

	local parsed = parseThing(getStartup(mode))

	--- @param v number
	--- @param k number
	tblx.foreach(parsed, function(v, k)
		local isEven = k % 2 == 0
		frameChartDataHtml:wikitext(
			drawFrame(v, "startup" .. (isEven and "-alt" or ""))
		)
	end)

	-- Option for inputting multihits, works for moves with 1+ gaps in the active frames
	local alt = false

	--- @param v number
	getActive(mode):foreach(function(v)
		if v < 0 then
			frameChartDataHtml:wikitext(drawFrame(v * -1, "inactive"))
			alt = false
		else
			frameChartDataHtml:wikitext(drawFrame(v, "active" .. (alt and "-alt" or "")))
			alt = not alt
		end
	end)

	frameChartDataHtml:wikitext(drawFrame(endlag, "endlag"))

	-- Special Recovery of move
	local landingLag = tonumber(mode.landingLag) or 0
	-- landingLag = computeEndlag(mode)

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
			mode.totalActive == nil and "N/A" or getTotalStartup(mode) + 1
		)

	return tostring(html)
		.. mw.getCurrentFrame():extensionTag({
			name = "templatestyles",
			args = { src = "Module:FrameChart/styles.css" },
		})
end

local function tabber(keyValuePairs)
	return mw.getCurrentFrame():extensionTag({
		name = "tabber",
		content = List(keyValuePairs):map(function(keyValuePair)
			return "|-|" .. keyValuePair[1] .. "=" .. keyValuePair[2]
		end):join(),
	})
end

local function startupAppendix(note)
	if not note or note == "" then
		return ""
	end

	if note == "SMASH" then
		return " " ..
			tooltip("ⓘ",
				"Total Uncharged Startup<br>[Pre-Charge Window + Post-Charge Window]")
	elseif note == "RAPIDJAB" then
		return " " ..
			tooltip("ⓘ", "[+Rapid Jab Initial Startup] Rapid Jab Loop Startup")
	end

	return " " .. tooltip("ⓘ", note)
end

local function computeTotalDuration(mode)
	if mode.totalDuration then
		return mode.totalDuration
	end

	if not mode.totalActive or not mode.endlag then
		return nil
	end

	local lastActive = multiSplitLast(mode.totalActive, { ",", "-", "..." })

	-- Sum endlag segments only if all parts are numeric; otherwise, bail out.
	local sum = 0
	for _, part in ipairs(List.split(tostring(mode.endlag), "+")) do
		local n = tonumber(part)
		if not n then
			return nil
		end

		sum = sum + n
	end

	return lastActive + sum
end

local function getFrameChart(mode)
	local frameChart = mw.html.create("div"):addClass("frame-chart")

	if (mode.frameChart ~= nil) then
		if (mode.frameChart == "N/A") then
			frameChart:wikitext(
				"''This frame chart is currently unavailable and will be added at a later time.''")
		else
			frameChart:wikitext(mode.frameChart)
		end
	else
		frameChart:wikitext(drawFrameData({
			endlag = computeEndlag(mode),
			landingLag = mode.landingLag,
			startup = mode.startup,
			totalActive = mode.totalActive,
		}))
	end

	return frameChart
end

local function notesRow(text)
	if not text or text == "" then
		return nil
	end

	return mw.html
		.create("tr")
		:addClass("notes-row")
		:tag("td")
		:css("text-align", "left")
		:attr("colspan", "100%")
		:wikitext("'''Notes:''' " .. text)
end

return {
	drawFrame = drawFrame,
	makeAngleDisplay = makeAngleDisplay,
	getTabberData = getTabberData,
	drawFrameData = drawFrameData,
	parseThing = parseThing,
	getModes = getModes,
	getActive = getActive,
	getTotalStartup = getTotalStartup,
	multiSplitLast = multiSplitLast,
	multiSplitFirst = multiSplitFirst,
	tabber = tabber,
	startupAppendix = startupAppendix,
	computeEndlag = computeEndlag,
	computeTotalDuration = computeTotalDuration,
	getFrameChart = getFrameChart,
	notesRow = notesRow,
	getStartup = getStartup,
}
