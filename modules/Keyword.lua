local p = {}
local mArguments
local cargo
local cache = {}

local splitString = require( 'Module:SplitStringToTable' ).splitStringIntoTable

--- Return the Moves data and cache the data for reuse on the same page
---
--- @return table
local function getGlossaryData( gameSpecifier )
    -- Return cached data
    if #cache > 0 then return cache end

    -- Lazy initalize Module:Cargo
    cargo = require( 'Module:Cargo' )

    local tables = 'Glossary'
    local fields = 'term,definition,gameSpecifier'
    local args = {}
    
    if gameSpecifier then
    	-- mw.log(gameSpecifier)
    	args = {
    		where   = string.format('Glossary.gameSpecifier HOLDS "%s"', gameSpecifier),
    		orderBy = 'Glossary._rowID',
    		limit   = '300',
		}
    else
    	args = {
    		orderBy = 'Glossary._rowID',
    		limit   = '300',
    	}
    end
    local results = cargo.getQueryResults( tables, fields, args, false )

    local items = {}
    for _, result in pairs( results ) do
        items[ string.lower(result.term) ] = result
    end

    -- Save to cache
    cache = items

    return cache
end

local function getTerm( term, gameSpecifier )
    local data = getGlossaryData( gameSpecifier )

	local match = data[ string.lower(term) ]
	if not match then
        error( string.format( 'Could not find matching term: %s', term ) )
	end

    return match
end

local function buildTooltip(term, label)
	-- mw.logObject(term)
	
	local tooltipHTML = mw.html.create('span'):addClass('tooltip')
		tooltipHTML:wikitext(label)
		:tag('span'):addClass('tooltiptext')
			:wikitext(term['definition'])
		:done()
	:done()
	
	return tooltipHTML
end

function p.main(frame)
	mArguments = require( 'Module:Arguments' )
	local args = mArguments.getArgs(frame)
	return p._main(args)
end

--- Return the wikitext needed for the template
---
--- @return string
function p._main( args )
    
    local term = args['term'] or args[1]
    if not term then
        error( 'No term specified for the template' )
    end
    
    local gameSpecifier = args['gameSpecifier']
    local label = args['label'] or args[1] or args['term']

	local term = getTerm( term, gameSpecifier )
	local html = buildTooltip(term, label)
    return tostring(html)
end

return p