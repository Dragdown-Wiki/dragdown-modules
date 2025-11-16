local cargo = {}
local extCargo = mw.ext.cargo
local checkType = require( 'libraryUtil' ).checkType
local mArguments
local cache = {}


--- Flatten key value pairs table into string
---
--- @param t table Table to be flatten
--- @return string
local function flattenTableToString( t )
	local stringTable = {}
	for k, v in pairs( t ) do
		table.insert( stringTable, string.format( '%s:%s', k, v ) )
	end
	return table.concat( stringTable, ',' )
end


--- Format results from Cargo query into wikitext for output
---
--- @param results table Results from Cargo query
--- @param format string Format for the Cargo query
--- @return string
local function formatQueryResultsToWikitext( results, format )
	if format == 'debug' then
		return '<pre>' .. mw.dumpObject( results ) .. '</pre>'
	-- Default to table output
	else
		local table = mw.html.create( 'table' ):addClass( 'wikitable' )
		local headerRow = mw.html.create( 'tr' )
		table:node( headerRow )

		for i, result in pairs( results ) do
			local bodyRow = mw.html.create( 'tr' )

			for k, v in pairs( result ) do
				if i == 1 then
					headerRow:tag( 'th' ):wikitext( k )
				end
				bodyRow:tag( 'td' ):wikitext( v )
			end

			table:node( bodyRow )
		end

		return tostring( table )
	end
end


--- Cache Cargo query result
--- TODO: Make it smarter so that it separate the tables and fields into different caches
---
--- @param results table Results from Cargo query
--- @param tables string Tables param from Cargo query
--- @param fields string Fields param from Cargo query
--- @param argsString string Flatten args param from Cargo query
local function cacheQueryResults( results, tables, fields, argsString )
	-- Init index
	if not cache[ tables ] then
		cache[ tables ] = {}
	end
	if not cache[ tables ][ fields ] then
		cache[ tables ][ fields ] = {}
	end
	if not cache[ tables ][ fields ][ argsString ] then
		cache[ tables ][ fields ][ argsString ] = {}
	end
	-- mw.log( string.format( '[Cargo] Cached Cargo query result at: cache[\'%s\'][\'%s\'][\'%s\']', tables, fields, argsString ) )
	cache[ tables ][ fields ][ argsString ] = results
end


--- Return the result of a Cargo query (#cargo_query)
---
--- For info on the parameters:
--- @see https://www.mediawiki.org/wiki/Extension:Cargo/Other_features#Lua_support
---
--- @param tables string The set of Cargo tables to be queried
--- @param fields string The field or set of fields to be displayed
--- @param args table Optional parameters for the query
--- @param shouldCache bool Whether the query should be cached, default to true
--- @return table
function cargo.getQueryResults( tables, fields, args, shouldCache )
	-- args are optional
	args = args or {}

	if shouldCache ~= false then shouldCache = true end

	checkType( 'Module:Cargo/cargo.getQueryResults', 1, tables, 'string' )
	checkType( 'Module:Cargo/cargo.getQueryResults', 2, fields, 'string' )
	checkType( 'Module:Cargo/cargo.getQueryResults', 3, args, 'table' )

	local argsString = flattenTableToString( args )

	if shouldCache and cache[ tables ] and cache[ tables ][ fields ] and cache[ tables ][ fields ][ argsString ] then
		return cache[ tables ][ fields ][ argsString ]
	end

	local success, results = pcall( extCargo.query, tables, fields, args )
	-- mw.logObject( { [ 'tables' ] = tables, [ 'fields' ] =  fields, [ 'args' ] =  args }, '[Cargo] Run Cargo query with the following params' )

	if not success then
		error( 'Failed to query Cargo table' )
	end

	-- mw.logObject( results, '[Cargo] Found Cargo query result' )
	if shouldCache then
		cacheQueryResults( results, tables, fields, argsString )
	end
	return results
end


--- Implement {{Cargo query}} template
--- TODO: Implement formats
---
--- @return string
function cargo.getQueryResultsFromWikitext( frame )
	mArguments = require( 'Module:Arguments' )
	local templateArgs = mArguments.getArgs( frame )

	local tables = templateArgs[ 'tables' ]
	local fields = templateArgs[ 'fields' ]

	if not tables or not fields then
		error( 'Missing tables or fields parameter' )
	end

	local args = {
		[ 'where' ] = templateArgs[ 'where' ],
		[ 'join' ]  = templateArgs[ 'join on' ],
		[ 'groupBy' ]  = templateArgs[ 'group by' ],
		[ 'having' ] = templateArgs[ 'having' ],
		[ 'orderBy' ] = templateArgs[ 'order by' ],
		[ 'limit' ] = templateArgs[ 'limit' ],
		[ 'offset' ] = templateArgs[ 'offset' ]
	}

	-- Get query results
	local results = cargo.getQueryResults( tables, fields, args )

	local format = templateArgs[ 'format' ]
	return formatQueryResultsToWikitext( results, format )
end


--- Debug function
function cargo.test( chara )
	chara = chara or 'Venom'

	local tables = 'MoveData_GGACR'
    local fields = 'chara,name,input,damage,guard,startup,active,recovery,onBlock,onHit,level,images,hitboxes,notes,caption,hitboxCaption,type,gbp,gbm,tension,prorate,invuln,cancel,blockstun,groundHit,airHit,hitstop,gatlings,frcWindow'
    local args = {
        where   = 'MoveData_GGACR.chara="' .. chara .. '"',
        orderBy = 'MoveData_GGACR._rowID',
    }
	local results = cargo.getQueryResults( tables, fields, args )
	mw.logObject( results, '[Cargo] Test function output' )
end


return cargo