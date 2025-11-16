local p = {}

local currentFrame
local html
local frameChartDataHtml

function merge(to, from)
  for k,v in pairs(from) do to[k] = v end
end

function p.autoChart(s, a, r, t)
	local frameData = {}
	
    merge(frameData, parseStartup(s or ""))
    merge(frameData, parseActive(a or ""))
    merge(frameData, parseRecovery(r or ""))
    frameData.title = t
	
	return p.drawFrameData(mw.getCurrentFrame():newChild{args=frameData})
end

function p.Split(str, delim, maxNb)
   -- Eliminate bad cases...
   if string.find(str, delim) == nil then
      return { str }
   end
   if maxNb == nil or maxNb < 1 then
      maxNb = 0    -- No limit
   end
   local result = {}
   local pat = "(.-)" .. delim .. "()"
   local nb = 0
   local lastPos
   for part, pos in string.gfind(str, pat) do
      nb = nb + 1
      result[nb] = part
      lastPos = pos
      if nb == maxNb then
         break
      end
   end
   -- Handle the last field
   if nb ~= maxNb then
      result[nb + 1] = string.sub(str, lastPos)
   end
   return result
end

function p.tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

function p.drawFrameData(frame)
	currentFrame = 0

	html = mw.html.create('div')
	html:addClass('frameChart')

	-- Optional field to add title
	local title
	if frame.args['title'] ~= nil then
		title = frame.args['title']
	end

	-- Startup is the first active frame. Sets to true if empty. Otherwise it's false.
	local startupIsFirstActive
	if frame.args['startupIsFirstActive'] == nil then
		startupIsFirstActive = false
	else
		startupIsFirstActive = true
	end
  
	-- Startup of move, substract 1 if startupIsFirstActive
	local totalStartup = 0
	local startup = frame.args['startup']
	if tonumber(startup) ~= nil then
		startup = {}
		startup[1] = tonumber(frame.args['startup'])
		totalStartup = startup[1]
	elseif string.find(frame.args['startup'],'+') then 
		startup = {}
		for i=1, p.tablelength(p.Split(frame.args['startup'], '+')) do
			startup[i] = p.Split(frame.args['startup'], '+')[i]
			totalStartup = totalStartup + startup[i]
		end
	end
  
	-- Active of move
	
	active = {}
	first_active_frame = totalStartup + 1
	counter = 1
	if(frame.args['active'] ~= nil) then
		csplit = p.Split(frame.args['active'], ",")
		ATL = p.tablelength(csplit)
		for i = 1, ATL do
			hyphen = p.tablelength(p.Split(csplit[i], "-"))
			startFrame = p.Split(csplit[i], "-")[1]
			endFrame = p.Split(csplit[i], "-")[hyphen]
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
	processedEndlag = frame.args['endlag']
	if string.sub(processedEndlag, -3) == '...' then
		processedEndlag = string.sub(processedEndlag, 1, -4)
	end
	if tonumber(processedEndlag) ~= nil then
		endlag[1] = processedEndlag
		totalEndlag = tonumber(endlag[1])
	elseif string.find(processedEndlag,'+') then 
		for i=1, p.tablelength(p.Split(processedEndlag, '+')) do
			endlag[i] = p.Split(processedEndlag, '+')[i]
			-- if ('...')
			totalEndlag = totalEndlag + endlag[i]
		end
	end
	-- Special Recovery of move
	local landingLag = frame.args['landlag']

	if title ~= nil then
		html:tag('div'):addClass('frameChart-title'):wikitext(title):done()
	end
	-- if active ~= nil then
	-- 	html:tag('div'):addClass('frameChart-FAF'):wikitext(active[1]):done()
	-- end

	-- Create container for frame data
	frameChartDataHtml = mw.html.create('div')
	frameChartDataHtml:addClass('frameChart-data')
	html:node(frameChartDataHtml)
   
	alt = false
	for i=1, p.tablelength(startup) do
		if not alt then
		   drawFrame(startup[i],  "startup")
		else
		   drawFrame(startup[i],  "startup-alt")	
		end
		alt = not alt
	end

	-- Option for inputting multihits, works for moves with 1+ gaps in the active frames
	alt=false
	for i=1, p.tablelength(active) do
		if active[i] < 0 then
			drawFrame(active[i] * -1, "inactive")	
			alt=false
		elseif not alt then
		   drawFrame(active[i],  "active")
		   alt = not alt
		else
		   drawFrame(active[i],  "active-alt")	
		   alt = not alt
	  end
	end
	alt = false
	for i=1, p.tablelength(endlag) do
		if not alt then
		   drawFrame(endlag[i],  "endlag")
		else
		   drawFrame(endlag[i],  "endlag-alt")	
		end
		alt = not alt
	end
	drawFrame(landingLag, "landingLag")
  
	local fdtotal = mw.html.create('div'):addClass('frame-data-total')
	fdtotal:node(mw.html.create('span'):addClass('frame-data-total-label'):wikitext('First Active Frame:'))
		
	if(frame.args['active'] ~= nil) then
		fdtotal:node(mw.html.create('span'):addClass('frame-data-total-value'):wikitext(totalStartup + 1))
	else
		fdtotal:node(mw.html.create('span'):addClass('frame-data-total-value'):wikitext('N/A'))
	end
	fdtotal:done()
	html:node(fdtotal):done()
	
	

	return tostring(html) .. mw.getCurrentFrame():extensionTag{
		name = 'templatestyles', args = { src = 'Module:FrameChart/styles.css' }
	}
end

function drawFrame(frames, frameType)
	if tonumber(frames) ~= nil then
		for i=1, tonumber(frames) do
			currentFrame = currentFrame + 1
			
			local frameDataHtml = mw.html.create('div')
			frameDataHtml:addClass('frame-data'):addClass('frame-data-' .. frameType)
			
			-- if checkCancel() then
			-- 	frameDataHtml:addClass('frame-data-frc')
			-- end
			
			frameDataHtml:done()
			frameChartDataHtml:node(frameDataHtml)
		end
	end
end

-- parses the passed in string to get the active/inactive frames for the move
-- returns nil when parsing failed, and a fancy table otherwise
function parseActive(duration)
  -- The implementation is scary because lua doesn't have good regexes,
  -- and also because I really would rather error than silently misinterpret the data

  if duration == "" then
    return {}
  end

  -- simple number
  if tonumber(duration) ~= nil then
    return {active = tonumber(duration)}
  end

  if string.find(duration, "%d+%s*,") ~= nil then
    -- 1,2,3,4 format -- multihit with no gaps
    local totalActive = 0

    -- first match - just a number
    local firstval, pos = string.match(duration, "^(%d+)%s*()")
    if firstval == nil then
      error("Couldn't parse active frames (didn't start with a number?): " .. duration)
    end
    -- subsequent matches - coma, then number. Might have spaces between them
    totalActive = totalActive + tonumber(firstval)
    for p1, dur, p2 in string.gmatch(duration, "(),%s*(%d+)%s*()") do
      if pos ~= p1 then
        error("Couldn't parse active frames (thought it was a comma separated list but something went wrong): " .. duration)
      end
      pos = p2
      totalActive = totalActive + tonumber(dur)
    end
    if pos ~= string.len(duration)+1 then
      error("Couldn't parse active frames (extra characters at end?): " .. duration)
    end
    -- Done.
    local out = {active = totalActive}
    return out 
  elseif mw.ustring.find(duration, "^%d+[x×]%d+$") ~= nil then
    -- 3x4 format -- also multihit with no gaps
    local a, b = mw.ustring.match(duration, "^(%d+)[x×](%d+)$")
    local out = { active = tonumber(a) * tonumber(b) }
    return out
  elseif string.find(duration, "^%d+%(%d+%)") ~= nil then
    -- 1(2)3(4)5 format -- multihit with gaps
    local out = {}
    -- special handling for the first number
    local firstval, pos = string.match(duration, "^(%d+)()")
    out['active'] = firstval

    local ordinal = 2
    -- then we just have a groups of "(inactive)active"
    for p1, d1, d2, p2 in string.gmatch(duration, "()%((%d+)%)(%d+)()") do
      if pos ~= p1 then
        error("Couldn't parse active frames (thought it was a list like 1(2)3(4)5 but something went wrong): " .. duration)
      end
      out['inactive' .. tostring(ordinal)] = d1
      out['active' .. tostring(ordinal+1)] = d2
      ordinal = ordinal + 2
      pos = p2
    end
    if pos ~= string.len(duration)+1 then
      error("Couldn't parse active frames (extra characters at end?): " .. duration)
    end
    -- Done.
    return out
  end
  -- Until L, for jL and similar
  if string.match(duration, "Until L") ~= nil then
    return {active = 0, isProjectile=true}
  end
  
  -- unrecognized format
  error("Couldn't parse active frames (unknown format): " .. duration)
end

function parseStartup(duration)
  if duration == "" then
    return {}
  end

  -- Simple number.
  if tonumber(duration) ~= nil then
    return {startup = tonumber(duration)}
  end

  -- Complex number, such as 1+2 [3].
  
  if string.find(duration, "^.*%[%d+%].*$") ~= nil then
    local total = string.match(duration, "^.*%[(%d+)%].*$")
    return {startup = tonumber(total)}
  end
  
  error("Couldn't parse startup frames (unknown format): " .. duration)
end

function parseRecovery(duration)
  if duration == "" then
    return {}
  end

  -- simple number
  if tonumber(duration) ~= nil then
    return {recovery = tonumber(duration)}
  end
  
  -- simple cancellables
  if string.find(duration, "^.*%[%d+%].*$") ~= nil then
    local total = string.match(duration, "^.*%[(%d+)%].*$")
    return {recovery = tonumber(total) }
  end

  error("Couldn't parse recovery frames (unknown format): " .. duration)
end

-- Checks if currentFrame is within one of the cancel/FRC windows
-- function checkCancel()
-- 	local i = 1
-- 	while cList[i] ~= nil do
-- 		if currentFrame <= cList[i+1] and currentFrame >= cList[i] then
-- 			return true
-- 		end
-- 		i = i + 2
-- 	end
-- 	return false
-- end

p.drawFrame = drawFrame
-- p.checkCancel = checkCancel

return p