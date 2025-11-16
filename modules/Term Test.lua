local p = {}
local mArguments
local cargo = mw.ext.cargo
local cache = {}

local tabber = require( 'Module:Tabber' ).renderTabber
local splitString = require( 'Module:SplitStringToTable' ).splitStringIntoTable
local list = require( 'Module:List' ).makeList
local frame = mw.getCurrentFrame()

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
	:node(mw.html.create('span'):addClass('tooltiptext noexcerpt'):node(hover):done()):done()
	return tostring(n)
end

local function createTerm(game, term, text)
	local host = ''
	local tables = ''
	if(string.upper(game) == 'ROA2') then
		tables = 'Glossary_ROA2'
		host = 'RoA2'
	elseif(string.upper(game) == 'SSBU') then
		tables = 'Glossary_SSBU'
		host = 'SSBU'
	elseif(string.upper(game) == 'NASB2') then
		tables = 'Glossary_NASB2'
		host = 'NASB2'
	elseif(string.upper(game) == 'PPLUS') then
		tables = 'Glossary_PPlus'
		host = 'PPlus'
	else
		--testing
		tables = 'Glossary_ROA2'
		host = 'RoA2'
	end
	local fields = 'term,summary,display,alias'
	local args = {where = 'term="' .. term .. '" or alias HOLDS "' .. term .. '"'}
    local results = cargo.query( tables, fields, args )
    local result = results[1]
    
    local html = mw.html.create('')
    if result == nil then
    	html:wikitext('No matched term could be found in the [['.. host ..'/Glossary|Glossary]].[[Category:Missing Term]]')
	else
	    html:node(mw.html.create('big'):node(mw.html.create('b'):wikitext(result.term)))
	    html:node(mw.html.create('br'))
	    html:node(result.summary)
	    -- This line is causing trouble because manifesting a video creates a div which breaks the formatting of cards.
	    -- NOTE: this is disabled currently because it autoplays on every page like a nightmare, will need to further test before setting this up
	 --   if(result.display ~= nil) then
	 --   	html:node(string.format("[[File:%s|300px|autoplay|mute|loop]]", result.display))
		-- end
	    html:node(mw.html.create('br'))
	    html:wikitext('[['.. host ..'/Glossary#' .. result.term ..'|See in Glossary]]')
    end
	return tooltip(text, html)
end

function p.main(frame)
	mArguments = require( 'Module:Arguments' )
	local args = mArguments.getArgs(frame)
	return p._main(args)
end
	
function p._main( args )

	local game = args[1]
	local term = args[2]
	local text = args[3]
	
	if (tablelength(args) == 2) then
		game = mw.title.getCurrentTitle().rootText
		term = args[1]
		text = args[2]
	end
	if (tablelength(args) == 1) then
		game = mw.title.getCurrentTitle().rootText
		term = args[1]
		text = args[1]
	end
	local html = createTerm(game, term, text)
	return tostring(html)
end

return p