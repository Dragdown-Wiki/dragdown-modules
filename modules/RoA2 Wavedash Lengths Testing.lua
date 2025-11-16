local p = {}
local mArguments
local cargo = mw.ext.cargo
local cache = {}

local tabber = require( 'Module:Tabber' ).renderTabber
local splitString = require( 'Module:SplitStringToTable' ).splitStringIntoTable
local list = require( 'Module:List' ).makeList

function dump(o)
	if type(o) == 'table' then
	   local s = '{ '
	   for k,v in pairs(o) do
		  if type(k) ~= 'number' then k = '"'..k..'"' end
		  s = s .. '['..k..'] = ' .. dump(v) .. ','
	   end
	   return s .. '} '
	else
	   return tostring(o)
	end
 end

function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

local function tooltip(text, hover)
	local n = mw.html.create('span'):addClass('tooltip')
	n:wikitext(text)
	:node(mw.html.create('span'):addClass('tooltiptext'):node(hover):done()):done()
	return tostring(n)
end

local function createWavedashLengths()
	local bigHtml = ''
	local frame = mw.getCurrentFrame()
	local fields = 'chara, FrictionGround, AirDodgeSpeed'
	local args = {orderBy = 'chara'}
    local results = cargo.query( 'ROA2_CharacterData', fields, args )
    
    for i, v in ipairs(results) do
    	local row = mw.html.create('tr')
    	row:tag('td'):wikitext(frame:expandTemplate{title = 'StockIcon', args = {'RoA2', v['chara']}})
    	
    	local ad = tonumber(v['AirDodgeSpeed'])
    	local gf = tonumber(v['FrictionGround'])
    	
    	local currentSpeed = ad
    	local dist = 0
    	local wd_frames = 0

    	for a=1, 8 do
    		dist = dist + currentSpeed
    		wd_frames = wd_frames + 1
    		if currentSpeed > 9 then
    			currentSpeed = currentSpeed - 2 * gf
			else
				currentSpeed = currentSpeed - gf
			end
    	end
	
    	local currentSpeed10 = ad
    	local dist10 = 0

    	for a=1, 10 do
    		dist10 = dist10 + currentSpeed10
    		if currentSpeed10 > 9 then
    			currentSpeed10 = currentSpeed10 - 2 * gf
			else
				currentSpeed10 = currentSpeed10 - gf
			end
    	end
    	
    	local total_dist = dist
    	local total_speed = currentSpeed
	
		while total_speed > 0 do
    		total_dist = total_dist + total_speed
    		if total_speed > 9 then
    			total_speed = total_speed - 2 * gf
			else
				total_speed = total_speed - gf
    		end
    		if total_speed > 1 then 
    			wd_frames = wd_frames + 1
    		end
		end
			
    	
		row:tag('td'):wikitext(dist)
	    row:tag('td'):wikitext(currentSpeed)
		row:tag('td'):wikitext(dist10)
	    row:tag('td'):wikitext(currentSpeed10)
	    row:tag('td'):wikitext(total_dist)
	    row:tag('td'):wikitext(wd_frames)
		row:done()
    	
		bigHtml = bigHtml .. tostring(row)
		
		if(v['chara'] == 'Etalus') then
			local row = mw.html.create('tr')
	    	row:tag('td'):wikitext(frame:expandTemplate{title = 'StockIcon', args = {'RoA2', v['chara']}} .. ' (Ice)')
	    	
	    	local ad = tonumber(v['AirDodgeSpeed'])
	    	local gf = 0.15 -- Etalus on Ice
	    	
	    	local currentSpeed = ad
	    	local dist = 0
	    	local wd_frames = 0
	
	    	for a=1, 8 do
	    		dist = dist + currentSpeed
	    		wd_frames = wd_frames + 1
	    		if currentSpeed > 9 then
	    			currentSpeed = currentSpeed - 2 * gf
				else
					currentSpeed = currentSpeed - gf
				end
	    	end
		
	    	local currentSpeed10 = ad
	    	local dist10 = 0
	
	    	for a=1, 10 do
	    		dist10 = dist10 + currentSpeed10
	    		if currentSpeed10 > 9 then
	    			currentSpeed10 = currentSpeed10 - 2 * gf
				else
					currentSpeed10 = currentSpeed10 - gf
				end
	    	end
	    	
	    	local total_dist = dist
	    	local total_speed = currentSpeed
		
			while total_speed > 0 do
	    		total_dist = total_dist + total_speed
	    		if total_speed > 9 then
	    			total_speed = total_speed - 2 * gf
				else
					total_speed = total_speed - gf
	    		end
	    		if total_speed > 1 then 
	    			wd_frames = wd_frames + 1
	    		end
			end
				
	    	
			row:tag('td'):wikitext(dist)
		    row:tag('td'):wikitext(currentSpeed)
			row:tag('td'):wikitext(dist10)
		    row:tag('td'):wikitext(currentSpeed10)
		    row:tag('td'):wikitext(total_dist)
		    row:tag('td'):wikitext(wd_frames)
			row:done()
	    	
			bigHtml = bigHtml .. tostring(row)	
		elseif(v['chara'] == 'Wrastor') then
			local row = mw.html.create('tr')
	    	row:tag('td'):wikitext(frame:expandTemplate{title = 'StockIcon', args = {'RoA2', v['chara']}} .. ' (Slipstream)')
	    	
	    	local ad = 26.8 -- Air Dodge speed
	    	local gf = tonumber(v['FrictionGround'])
	    	
	    	
	    	local currentSpeed = ad
	    	local dist = 0
	    	local wd_frames = 0
	
	    	for a=1, 8 do
	    		dist = dist + currentSpeed
	    		wd_frames = wd_frames + 1
	    		if currentSpeed > 9 then
	    			currentSpeed = currentSpeed - 2 * gf
				else
					currentSpeed = currentSpeed - gf
				end
	    	end
		
	    	local currentSpeed10 = ad
	    	local dist10 = 0
	
	    	for a=1, 10 do
	    		dist10 = dist10 + currentSpeed10
	    		if currentSpeed10 > 9 then
	    			currentSpeed10 = currentSpeed10 - 2 * gf
				else
					currentSpeed10 = currentSpeed10 - gf
				end
	    	end
	    	
	    	local total_dist = dist
	    	local total_speed = currentSpeed
		
			while total_speed > 0 do
	    		total_dist = total_dist + total_speed
	    		if total_speed > 9 then
	    			total_speed = total_speed - 2 * gf
				else
					total_speed = total_speed - gf
	    		end
	    		if total_speed > 1 then 
	    			wd_frames = wd_frames + 1
	    		end
			end
				
	    	
			row:tag('td'):wikitext(dist)
		    row:tag('td'):wikitext(currentSpeed)
			row:tag('td'):wikitext(dist10)
		    row:tag('td'):wikitext(currentSpeed10)
		    row:tag('td'):wikitext(total_dist)
		    row:tag('td'):wikitext(wd_frames)
			row:done()
	    	
			bigHtml = bigHtml .. tostring(row)	
		end
    end
	return bigHtml
end

function p.main(frame)
	mArguments = require( 'Module:Arguments' )
	local args = mArguments.getArgs(frame)
	return p._main(args)
end
	
function p._main( args )

	local html = createWavedashLengths()
	return tostring(html)
end

return p