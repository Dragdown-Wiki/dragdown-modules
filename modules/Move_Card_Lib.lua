local List = require("pl.List")
local tooltip = require("Tooltip")
local GetImagesWikitext = require("GetImagesWikitext")

local function drawFrame(frames, frameType)
  return List.range(1, tonumber(frames))
      :map(function()
        return mw.html.create("div"):addClass("frame-data frame-data-" .. frameType)
      end)
      :join()
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

local function makeAngleDisplay(angle, flipper)
  local game = mw.title.getCurrentTitle().rootText
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
    game .. "_MoveMode, " .. game .. "_MoveMode__image, " .. game .. "_MoveMode__caption",
    "image=file, caption",
    {
      join = List({
        game .. "_MoveMode__image._rowID = " .. game .. "_MoveMode._ID",
        game .. "_MoveMode__image._rowID = " .. game .. "_MoveMode__caption._rowID",
        game .. "_MoveMode__image._position = " .. game .. "_MoveMode__caption._position"
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
        GetImagesWikitext({ {
          file = game .. "_" .. chara .. "_" .. attack .. "_0.png",
          caption = "NOTE: This is an incomplete card, with data modes planning to be uploaded in the future.",
        } })
      )
    )
  end

  container:wikitext(GetImagesWikitext(results):join())

  return mw.getCurrentFrame():extensionTag({
    name = "tabber",
    content = "|-|Images=" .. tostring(container)
  })
end

local function getModes(chara, attack, fields)
  return mw.ext.cargo.query(
    getGame() .. "_MoveMode",
    fields,
    {
      where = 'chara="' .. chara .. '" and attack="' .. attack .. '"',
      orderBy = "_ID"
    }
  )
end

local function multiSplitLast(text, separators)
  local list = List({ text })

  for _, sep in ipairs(separators) do
    list = List.split(list:pop(), sep)
  end

  return list:pop()
end

local function multiSplitFirst(text, separators)
  local list = List({ text })

  for _, sep in ipairs(separators) do
    list = List.split(list[1], sep)
  end

  return list[1]
end

--- @param text string?
local function parseThing(text)
  if text == nil then
    return List({})
  end

  if tonumber(text) ~= nil then
    return List({ tonumber(text) })
  end

  if text:find("+") and not string.find(text, "%[") then
    return List.split(text, "+")
  end

  return List({})
end

--- @param mode { startup: string }
local function getTotalStartup(mode)
  return List(parseThing(mode.startup)):reduce("+") or 0
end

--- @param mode { totalActive: string?, startup: string }
local function getActive(mode)
  local totalStartup = getTotalStartup(mode)
  local active = List()
  local firstActive = totalStartup + 1

  if not mode.totalActive or mode.totalActive == "N/A" then
    return {}
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

--- @param mode { startup: string, endlag: integer, landingLag: string, totalActive: string? }
local function drawFrameData(mode)
  -- Create container for frame data
  local frameChartDataHtml = mw.html.create("div"):addClass("frameChart-data")

  for k, v in ipairs(parseThing(mode.startup)) do
    local isEven = k % 2 == 0
    frameChartDataHtml:wikitext(
      drawFrame(v, "startup" .. (isEven and "-alt" or ""))
    )
  end

  -- Option for inputting multihits, works for moves with 1+ gaps in the active frames
  local alt = false

  for _, v in ipairs(getActive(mode)) do
    if v < 0 then
      frameChartDataHtml:wikitext(drawFrame(v * -1, "inactive"))
      alt = false
    else
      frameChartDataHtml:wikitext(drawFrame(v, "active" .. (alt and "-alt" or "")))
      alt = not alt
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
        mode.totalActive == nil and "N/A" or getTotalStartup(mode) + 1
      )

  return tostring(html)
      .. mw.getCurrentFrame():extensionTag({
        name = "templatestyles",
        args = { src = "Module:FrameChart/styles.css" },
      })
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
}
