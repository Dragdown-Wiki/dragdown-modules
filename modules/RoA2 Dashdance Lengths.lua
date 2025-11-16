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

local function createDDLengths()
	local bigHtml = ''
	local frame = mw.getCurrentFrame()
	local fields = 'chara, DashSpeed, RunSpeedMax, DashFrames'
	local args = {orderBy = 'chara'}
    local results = cargo.query( 'ROA2_CharacterData', fields, args )
    
    for i, v in ipairs(results) do
    	local row = mw.html.create('tr')
    	row:tag('td'):wikitext(frame:expandTemplate{title = 'StockIcon', args = {'RoA2', v['chara']}})
    	
    	local dash_speed = tonumber(v['DashSpeed'])
    	local run_speed = tonumber(v['RunSpeedMax'])
    	local dash_frames = tonumber(v['DashFrames'])
    	
    	row:tag('td'):wikitext((dash_speed + run_speed) / 2 * dash_frames)
	    row:tag('td'):wikitext((dash_speed + run_speed) / 2)
		row:done()
    	
		bigHtml = bigHtml .. tostring(row)
		
		if(v['chara'] == 'Wrastor') then
			local row = mw.html.create('tr')
	    	row:tag('td'):wikitext(frame:expandTemplate{title = 'StockIcon', args = {'RoA2', v['chara']}} .. ' (Slipstream)')
	    	
	    	local dash_speed = 15.6
	    	local run_speed = 22.6
	    	local dash_frames = tonumber(v['DashFrames'])
	    	
	    	row:tag('td'):wikitext((dash_speed + run_speed) / 2 * dash_frames)
		    row:tag('td'):wikitext((dash_speed + run_speed) / 2)
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

	local html = createDDLengths()
	return tostring(html)
end

return p