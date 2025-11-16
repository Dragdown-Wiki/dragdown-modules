return {
	main = function(frame)
	    local results = mw.ext.cargo.query( 'ROA2_CharacterData', 'chara', {orderBy = 'chara'} )
	    local t = {}
	    for _, r in ipairs(results) do
	    	table.insert(t, "[[File:RoA2_" .. r.chara .. "_Stock.png"
					.. "|link=#" .. r.chara
					.. "|85px]]")
	    end
	    return table.concat(t)
	end
}