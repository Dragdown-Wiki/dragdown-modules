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

local function createBDLengths()
	local bigHtml = ''
	local frame = mw.getCurrentFrame()
	local fields = 'chara, DashSpeed, FrictionGround'
	local args = {orderBy = 'chara'}
    local results = cargo.query( 'ROA2_CharacterData', fields, args )
    
    for i, v in ipairs(results) do
    	local row = mw.html.create('tr')
    	row:tag('td'):wikitext(frame:expandTemplate{title = 'StockIcon', args = {'RoA2', v['chara']}})
    	
    	local dash_speed = tonumber(v['DashSpeed'])
    	local gf = tonumber(v['FrictionGround'])
    	
    	row:tag('td'):wikitext(math.ceil(dash_speed / gf))
	    row:tag('td'):wikitext((dash_speed * dash_speed) / (gf * 2))
		row:done()
    	
		bigHtml = bigHtml .. tostring(row)
		
    end
	return bigHtml
end

function p.main(frame)
	mArguments = require( 'Module:Arguments' )
	local args = mArguments.getArgs(frame)
	return p._main(args)
end
	
function p._main( args )

	local html = createBDLengths()
	return tostring(html)
end

return p