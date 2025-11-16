local p = {}
local tabber = require( 'Module:Tabber' ).renderTabber

local function showTable(traits, hits)
	return mw.html.create("div"):addClass("roa2-percent-table"):done()
end

local function createPercents(notes,host,opp)
	local outputNotes = notes
	if outputNotes == nil then
		outputNotes = "''The following matchup notes are blank. Perhaps you can help add some?''"
	end
	
	local t = tabber({
		label1 = "General Notes",
		content1 = outputNotes,
		label2 = host .. ' Attacks',
		content2 = tostring(showTable(oppTraits, hostHits)),
		label3 = opp .. ' Attacks',
		content3 = tostring(showTable(hostTraits, oppHits))
	})
	if(host == opp) then
		t = tabber({
			label1 = "General Notes",
			content1 = outputNotes,
			label2 = 'Ditto Attacks',
			content2 = tostring(showTable(oppTraits, hostHits)),
		})
	end
	
	return t
end

function p.main(frame)
	local args = require("Module:Arguments").getArgs(frame)
	local host = args['host'] or mw.title.getCurrentTitle().basePageTitle.subpageText
	local opp = args['mu']
	
	local box = mw.html.create("div"):addClass("mu-box")
	
	local header = mw.html.create("div"):addClass("mw-heading")
		:tag("h1"):attr("id", opp):wikitext(opp)
		:tag("span"):addClass("mw-editsection")
		:done()
	
	local portrait = "[[File:PPlus_" .. opp .. "_Portrait.png"
					.. "|link=PPlus/" .. opp
					.. "|x200px]]"
    local nav = mw.html.create("div"):addClass("roa2-mu-nav"):wikitext(portrait)
    nav:tag("div"):addClass("roa2-mu-oneliner"):wikitext(args["oneliner"]):done()
		:tag("div"):addClass("roa2-mu-button"):addClass("highlight-blue"):wikitext("[[PPlus/" .. opp .. "|Overview]]"):done()
		:tag("div"):addClass("roa2-mu-button"):addClass("highlight-red"):wikitext("[[PPlus/" .. opp .. "/Strategy|Counterstrategy]]"):done()
		:tag("div"):addClass("roa2-mu-button"):addClass("highlight-slate"):wikitext("[[PPlus/" .. opp .. "/Data#Character_Stats|Character Stats]]"):done()
		:tag("div"):addClass("roa2-mu-button"):addClass("highlight-yellow"):wikitext("[[PPlus/" .. opp .. "/Matchups#" .. host .. "|Inverse Matchup]]"):done()
box:node(nav)
	box:tag("div"):addClass("roa2-mu-main"):wikitext(tostring(createPercents(args["notes"],host, opp)))
	return tostring(header) .. tostring(box) .. mw.getCurrentFrame():extensionTag({
			name = "templatestyles",
			args = { src = "Template:RoA2-Matchup/styles.css" },
		})
end
return p