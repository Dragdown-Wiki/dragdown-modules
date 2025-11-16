local p = {}
local mArguments
local cargo = mw.ext.cargo

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
	mArguments = require( 'Arguments' )
	local args = mArguments.getArgs(frame)
	return p._main(args)
end
	
function p._main( args )

	local html = createBDLengths()
	return tostring(html)
end

return p