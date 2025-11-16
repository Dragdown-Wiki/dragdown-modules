local p = {}

-- Pages and their associated display names & background colors. Modify as needed to add new supported pages, but don't remove existing pages from the hierarchy.
local stylemap = {
	-- Main Pages
	["Starter Kit"] = {displayName = "Starter Kit", colorClass = "green"},
	["Combos"] = {displayName = "Combos", colorClass = "cyan"},
	["Techniques"] = {displayName = "Tech", colorClass = "orange"},
	["Strategy"] = {displayName = "Strategy / Counterstrategy", colorClass = "red"},
	["Matchups"] = {displayName = "Matchups", colorClass = "yellow"},
	["Setplay"] = {displayName = "Setplay", colorClass = "purple"},
	["Resources"] = {displayName = "Resources", colorClass = "teal"},
	["Data"] = {displayName = "Data", colorClass = "slate"},
	["Patch Notes"] = {displayName = "Patch Notes", colorClass = "magenta"},
	-- Social / External Links
	["Videos"] = {displayName = "Video Archive", colorClass = "lime"},
	["Discord"] = {displayName = "Discord", colorClass = "indigo"},
	["Twitter"] = {displayName = "Twitter", colorClass = "gray"},
	-- Character Specific Styling, if desired over the base color
	["Copy Abilities"] = {displayName = "Copy Abilities", colorClass = "pink"}
}

-- This table determines the order the pages are listed. These pages are valid for all characters.
local subpageOrder = {
	-- First Pages & Character Related
    "Starter Kit", 
    -- Meta Pages
    "Combos", "Techniques", "Strategy", "Matchups", "Setplay", "Resources", 
    -- Data Pages
    "Data", "Patch Notes"
}

local baseTitle = ""

-- Processes multiple values given in a semicolon-separated list
local function processList(valueList, game, character)
	if not valueList or valueList == "" then
        return ""
	end

	local values = mw.text.split(valueList, "%s*;%s*") -- table of strings
    for i, v in ipairs(values) do
    	local style = stylemap[v]
    	if style ~= nil then
    		values[i] = '[[' .. mw.title.new(game .. '/' .. character .. "/" .. v).fullText .. '|<div class="subpage-btn highlight-' ..
	            style.colorClass .. '">' .. style.displayName .. '</div>]]'
        else 
        	-- Apply default styling if none is given in the stylemap.
    		values[i] = '[[' .. mw.title.new(game .. '/' .. character .. "/" .. v).fullText .. '|<div class="subpage-btn">' .. 
    			v .. '</div>]]'
    	end
    end
    
    return table.concat(values, "")
end

function p.main(frame)
    local args = frame.args
    local title = mw.title.getCurrentTitle()
    
    -- Use base title to get "Game/CharacterName", but add option to override for testing
    baseTitle = title.prefixedText
    if args.baseTitle ~= "" then
    	baseTitle = args.baseTitle
	end
    
    local videos = args.videos
    local discord = args.discord
    local twitter = args.twitter
    local prefixPages = args.prefixPages
    local suffixPages = args.suffixPages
    
    local parts = mw.text.split(baseTitle, "/")
    if #parts < 2 then
        return "Error: page title must be at least Game/CharacterName"
    end

    local game = parts[1]
    local character = parts[2]
    
    -- Initialize wikitext with Overview page first
    local wikitext = '<div class="plainlinks">[[' .. game .. '/' .. character .. '|<div class="subpage-btn highlight-blue">Overview</div>]]'
    local deadLinks = {}
    
    -- Character-specific pages to be placed at the start of the list, before the main pages but after Overview.
	if prefixPages ~= nil and prefixPages ~= "" then
		wikitext = wikitext .. processList(prefixPages, game, character)
	end
    
	-- Loop through the pages in order. If they exist, add them to the string. If not, queue them.
	for _, key in ipairs(subpageOrder) do
	    local value = stylemap[key]
	    local page = mw.title.new(game .. '/' .. character .. "/" .. key)
	    if page and page.exists then
	        -- Add to the winners
	        wikitext = wikitext ..
	            '[[' .. page.fullText .. '|<div class="subpage-btn highlight-' ..
	            value.colorClass .. '">' .. value.displayName .. '</div>]]'
	    else
            -- Missing pages
            table.insert(deadLinks, '[[' .. page.fullText .. '|' .. value.displayName .. ']]')
        end
	end
	
	-- Character-specific pages to be tacked onto the end of the list, after the main pages but before the social links.
	if suffixPages ~= nil and suffixPages ~= "" then
		wikitext = wikitext .. processList(suffixPages, game, character)
	end
	
	-- Add Videos link to the end, if given
	if videos ~= nil and videos ~= "" then
		wikitext = wikitext .. '[' .. videos .. ' <div class="subpage-btn highlight-' ..
	            stylemap["Videos"].colorClass .. '">' .. stylemap["Videos"].displayName .. '</div>]'
	end
	
	-- Add Discord link to the end, if given
	if discord ~= nil and discord ~= "" then
		wikitext = wikitext .. '[' .. discord .. ' <div class="subpage-btn highlight-' ..
	            stylemap["Discord"].colorClass .. '">' .. stylemap["Discord"].displayName .. '</div>]'
	end
	
	-- Add Twitter link to the end, if given
	if twitter ~= nil and twitter ~= "" then
		wikitext = wikitext .. '[https://twitter.com/search?q=%23' .. twitter .. ' <div class="subpage-btn highlight-' ..
	            stylemap["Twitter"].colorClass .. '">' ..stylemap["Twitter"].displayName .. '</div>]'
	end
	
	-- Extra Page Handler
	if #deadLinks > 0 then
        local extraBox = mw.html.create('div')
            :addClass('subpage-btn highlight-gray mw-collapsible mw-collapsed')

        extraBox:wikitext('+')

        local content = extraBox:tag('div'):addClass('mw-collapsible-content')

        if #deadLinks > 0 then
            content:tag('p'):addClass('charlinks-minitext'):wikitext("'''Suggested subpages:''' " .. table.concat(deadLinks, ' • '))
        end

        wikitext = wikitext .. tostring(extraBox) .. "</div>"
    end
	
    return frame:preprocess(wikitext)
end

return p