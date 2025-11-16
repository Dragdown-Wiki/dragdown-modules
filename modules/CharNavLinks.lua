local p = {}

local roa2_character_style = {
	-- Fire Element
	["Zetterburn"] = {offset = 30, color = "#D24300"},
	["Forsburn"] = {offset = 40, color = "#D24300"},
	["Clairen"] = {offset = 30, color = "#D24300"},
	["Loxodont"] = {offset = 50, color = "#D24300"},
	-- Air Element
	["Wrastor"] = {offset = 30, color = "#8D4DC8"},
	["Absa"] = {offset = 25, color = "#8D4DC8"},
	["Fleet"] = {offset = 35, color = "#8D4DC8"},
	-- Earth Element
	["Kragg"] = {offset = 35, color = "#5BC040"},
	["Maypul"] = {offset = 37, color = "#5BC040"},
	["Olympia"] = {offset = 25, color = "#5BC040"},
	["Galvan"] = {offset = 38, color = "#5BC040"},
	-- Water Element
	["Orcane"] = {offset = 25, color = "#0098CA"},
	["Etalus"] = {offset = 20, color = "#0098CA"},
	["Ranno"] = {offset = 15, color = "#0098CA"},
}

local ssbu_character_style = {
	-- Super Smash Bros.
	["Mii Brawler"] = {offset = 18, color = "#fafafa"},
	["Mii Swordfighter"] = {offset = 26, color = "#fafafa"},
	["Mii Gunner"] = {offset = 21, color = "#fafafa"},
	-- Super Mario
	["Mario"] = {offset = 35, color = "#e13622"},
	["Luigi"] = {offset = 22, color = "#e13622"},
	["Peach"] = {offset = 21, color = "#e13622"},
	["Daisy"] = {offset = 18, color = "#e13622"},
	["Bowser"] = {offset = 42, color = "#e13622"},
	["Dr. Mario"] = {offset = 21, color = "#e13622"},
	["Rosalina & Luma"] = {offset = 13, color = "#e13622"},
	["Bowser Jr."] = {offset = 31, color = "#e13622"},
	["Piranha Plant"] = {offset = 16, color = "#e13622"}, -- No eyes moment
	-- Yoshig
	["Yoshi"] = {offset = 10, color = "#96c80d"},
	-- WarioWare
	["Wario"] = {offset = 16, color = "#e7d300"},
	-- Donkey Kong
	["Donkey Kong"] = {offset = 24, color = "#e57800"},
	["Diddy Kong"] = {offset = 25, color = "#e57800"},
	["King K. Rool"] = {offset = 16, color = "#e57800"},
	-- The Legend of Zelda
	["Link"] = {offset = 24, color = "#3aa0c8"},
	["Sheik"] = {offset = 12, color = "#3aa0c8"},
	["Zelda"] = {offset = 7, color = "#3aa0c8"},
	["Ganondorf"] = {offset = 9, color = "#3aa0c8"},
	["Young Link"] = {offset = 23, color = "#3aa0c8"},
	["Toon Link"] = {offset = 41, color = "#3aa0c8"},
	-- Metroid
	["Samus"] = {offset = 17, color = "#5e6ea1"},
	["Dark Samus"] = {offset = 13, color = "#5e6ea1"},
	["Zero Suit Samus"] = {offset = 12, color = "#5e6ea1"},
	["Ridley"] = {offset = 37, color = "#5e6ea1"},
	-- Kirby
	["Kirby"] = {offset = 25, color = "#fe9ace"},
	["Meta Knight"] = {offset = 67, color = "#fe9ace"},
	["King Dedede"] = {offset = 23, color = "#fe9ace"},
	-- Star Fox
	["Fox"] = {offset = 20, color = "#3b82c4"},
	["Falco"] = {offset = 22, color = "#3b82c4"},
	["Wolf"] = {offset = 20, color = "#3b82c4"},
	-- Pokémon
	["Pikachu"] = {offset = 36, color = "#f3b200"},
	["Jigglypuff"] = {offset = 55, color = "#f3b200"},
	["Pichu"] = {offset = 48, color = "#f3b200"},
	["Mewtwo"] = {offset = 18, color = "#f3b200"},
	["Pokemon Trainer"] = {offset = 42, color = "#f3b200"},
	["Squirtle"] = {offset = 15, color = "#f3b200"},
	["Ivysaur"] = {offset = 63, color = "#f3b200"},
	["Charizard"] = {offset = 31, color = "#f3b200"},
	["Lucario"] = {offset = 22, color = "#f3b200"},
	["Greninja"] = {offset = 28, color = "#f3b200"},
	["Incineroar"] = {offset = 17, color = "#f3b200"},
	-- EarthBound
	["Ness"] = {offset = 24, color = "#f41615"},
	["Lucas"] = {offset = 31, color = "#f41615"},
	-- F-Zero
	["Captain Falcon"] = {offset = 9, color = "#8a81b8"},
	-- Ice Climber
	["Ice Climbers"] = {offset = 55, color = "#a0c4e6"},
	-- Fire Emblem
	["Marth"] = {offset = 9, color = "#5aa4bd"},
	["Lucina"] = {offset = 7, color = "#5aa4bd"},
	["Roy"] = {offset = 20, color = "#5aa4bd"},
	["Chrom"] = {offset = 14, color = "#5aa4bd"},
	["Ike"] = {offset = 14, color = "#5aa4bd"},
	["Robin"] = {offset = 18, color = "#5aa4bd"},
	["Corrin"] = {offset = 10, color = "#5aa4bd"},
	["Byleth"] = {offset = 9, color = "#5aa4bd"},
	-- Game & Watch
	["Mr. Game & Watch"] = {offset = 19, color = "#9b9a85"},
	-- Kid Icarus
	["Pit"] = {offset = 25, color = "#8cc8ae"},
	["Dark Pit"] = {offset = 23, color = "#8cc8ae"},
	["Palutena"] = {offset = 17, color = "#8cc8ae"},
	-- Metal Gear
	["Snake"] = {offset = 7, color = "#69819b"},
	-- Sonic the Hedgehog
	["Sonic"] = {offset = 28, color = "#146dff"},
	-- Pikmin
	["Olimar"] = {offset = 37, color = "#b9cb65"},
	-- R.O.B.
	["R.O.B."] = {offset = 12, color = "#9aa3a8"},
	-- Animal Crossing
	["Villager"] = {offset = 34, color = "#48a063"},
	["Isabelle"] = {offset = 41, color = "#48a063"},
	-- Mega Man
	["Mega Man"] = {offset = 26, color = "#0c95ff"},
	-- Wii Fit
	["Wii Fit Trainer"] = {offset = 8, color = "#95c981"},
	-- Punch-Out!!
	["Little Mac"] = {offset = 13, color = "#49775a"},
	-- PAC-MAN
	["Pac-Man"] = {offset = 23, color = "#fbc800"},
	-- Xenoblade Chronicles
	["Shulk"] = {offset = 28, color = "#ea4156"},
	["Pyra & Mythra"] = {offset = 22, color = "#ea4156"},
	["Pyra"] = {offset = 11, color = "#ea4156"},
	["Mythra"] = {offset = 10, color = "#ea4156"},
	-- Duck Hunt
	["Duck Hunt"] = {offset = 66, color = "#8a5a34"},
	-- Street Fighter
	["Ryu"] = {offset = 10, color = "#d73236"},
	["Ken"] = {offset = 8, color = "#d73236"},
	-- Final Fantasy
	["Cloud"] = {offset = 16, color = "#50917d"},
	["Sephiroth"] = {offset = 14, color = "#50917d"},
	-- Bayonetta
	["Bayonetta"] = {offset = 15, color = "#a395c8"},
	-- Splatoon
	["Inkling"] = {offset = 33, color = "#e73ba1"},
	-- Castlevania
	["Simon"] = {offset = 13, color = "#9f453a"},
	["Richter"] = {offset = 18, color = "#9f453a"},
	-- Persona 
	["Joker"] = {offset = 11, color = "#A00C00"},
	-- Dragon Quest
	["Hero"] = {offset = 8, color = "#CDB4F5"},
	-- Banjo-Kazooie
	["Banjo & Kazooie"] = {offset = 43, color = "#FAC75A"},
	-- Fatal Fury
	["Terry"] = {offset = 10, color = "#7DB8FE"},
	-- ARMS
	["Min Min"] = {offset = 28, color = "#D9D80E"},
	-- Minecraft
	["Steve"] = {offset = 15, color = "#5ABDFE"},
	-- Tekken
	["Kazuya"] = {offset = 10, color = "#A52316"},
	-- Kingdom Hearts
	["Sora"] = {offset = 20, color = "#D2D2DC"}
}

local pplus_character_style = {
	-- Mario Series
	["Mario"] = {offset = 22, color = "#a54239"},
	["Luigi"] = {offset = 19, color = "#a54239"},
	["Peach"] = {offset = 15, color = "#a54239"},
	-- Bowser Series (This is the only one improvised. Color from S4 Bowser.)
	["Bowser"] = {offset = 31, color = "#32765c"},
	["Giga Bowser"] = {offset = 27, color = "#32765c"},
	-- Wario Series
	["Wario"] = {offset = 23, color = "#4a4a4a"},
	["Wario-Man"] = {offset = 15, color = "#4a4a4a"},
	-- Yoshi Series
	["Yoshi"] = {offset = 10, color = "#008400"},
	-- Donkey Kong Series
	["Donkey Kong"] = {offset = 26, color = "#8c4a21"},
	["Diddy Kong"] = {offset = 29, color = "#8c4a21"},
	-- Zelda Series
	["Link"] = {offset = 16, color = "#0039b5"},
	["Sheik"] = {offset = 12, color = "#0039b5"},
	["Zelda"] = {offset = 9, color = "#0039b5"},
	["Ganondorf"] = {offset = 8, color = "#0039b5"},
	["Toon Link"] = {offset = 23, color = "#0039b5"},
	-- Metroid Series
	["Samus"] = {offset = 18, color = "#7b847b"},
	["Zero Suit Samus"] = {offset = 20, color = "#7b847b"},
	-- Kirby Series
	["Kirby"] = {offset = 29, color = "#e7e700"},
	["Meta Knight"] = {offset = 79, color = "#e7e700"},
	["King Dedede"] = {offset = 30, color = "#e7e700"},
	-- Star Fox Series
	["Fox"] = {offset = 21, color = "#00b500"},
	["Falco"] = {offset = 11, color = "#00b500"},
	["Wolf"] = {offset = 20, color = "#00b500"},
	-- Pokemon Series
	["Pikachu"] = {offset = 29, color = "#b50000"},
	["Jigglypuff"] = {offset = 45, color = "#b50000"},
	["Mewtwo"] = {offset = 25, color = "#b50000"},
	["Squirtle"] = {offset = 25, color = "#b50000"},
	["Ivysaur"] = {offset = 72, color = "#b50000"},
	["Charizard"] = {offset = 24, color = "#b50000"},
	["Lucario"] = {offset = 21, color = "#b50000"},
	-- Earthbound Series
	["Ness"] = {offset = 26, color = "#ff0000"},
	["Lucas"] = {offset = 30, color = "#ff0000"},
	-- F-Zero Series
	["Captain Falcon"] = {offset = 11, color = "#0052ff"},
	-- Ice Climber Series
	["Ice Climbers"] = {offset = 51, color = "#5200ff"},
	-- Fire Emblem Series
	["Marth"] = {offset = 8, color = "#ad00ff"},
	["Roy"] = {offset = 10, color = "#ad00ff"},
	["Ike"] = {offset = 9, color = "#ad00ff"},
	-- Game & Watch Series
	["Mr. Game & Watch"] = {offset = 8, color = "#000000"},
	-- Kid Icarus Series
	["Pit"] = {offset = 24.5, color = "#b5b500"},
	-- Metal Gear Series
	["Snake"] = {offset = 9, color = "#ffa518"},
	-- Sonic Series
	["Sonic"] = {offset = 26, color = "#185aff"},
	["Knuckles"] = {offset = 17, color = "#185aff"},
	-- Pikmin Series
	["Olimar"] = {offset = 48, color = "#ff5200"},
	-- R.O.B. Series
	["R.O.B."] = {offset = 5, color = "#731021"}
}

local nasb2_character_style = {
	-- SpongeBob
	["SpongeBob"] = {offset = 33, color = "#71EECE"},
	["Patrick"] = {offset = 21, color = "#71EECE"},
	["Squidward"] = {offset = 44, color = "#71EECE"},
	["Mecha Plankton"] = {offset = 46, color = "#71EECE"},
	["Mr. Krabs"] = {offset = 30, color = "#71EECE"},
	-- Rocko's Modern Life
	["Rocko"] = {offset = 24, color = "#E86B89"},
	-- Jimmy Neutron
	["Jimmy Neutron"] = {offset = 50, color = "#BEC077"},
	-- Loud House
	["Lucy Loud"] = {offset = 34, color = "#68A6E1"},
	-- Garfield
	["Garfield"] = {offset = 31, color = "#0DD4AD"},
	-- Avatar
	["Aang"] = {offset = 7, color = "#AAE2FB"},
	["Korra"] = {offset = 10, color = "#AAE2FB"},
	["Azula"] = {offset = 15, color = "#AAE2FB"},
	["Zuko"] = {offset = 29, color = "#AAE2FB"},
	["Iroh"] = {offset = 20, color = "#AAE2FB"},
	-- TMNT
	["Raphael"] = {offset = 13, color = "#ECC96B"},
	["Donatello"] = {offset = 17, color = "#ECC96B"},
	["April"] = {offset = 12, color = "#ECC96B"},
	["Rocksteady"] = {offset = 23, color = "#ECC96B"},
	-- Danny Phantom
	["Danny Phantom"] = {offset = 33, color = "#9AF1A0"},
	["Ember"] = {offset = 26, color = "#9AF1A0"},
	-- Hey Arnold
	["Grandma Gertie"] = {offset = 21, color = "#4DE4DD"},
	["Gerald"] = {offset = 41, color = "#4DE4DD"},
	-- Wild Thornberrys
	["Nigel"] = {offset = 32, color = "#A7E657"},
	-- Invader Zim
	["Zim"] = {offset = 22, color = "#C778C7"},
	-- Teenage Robot
	["Jenny Wakeman"] = {offset = 30, color = "#6E72BC"},
	-- Rugrats
	["Reptar"] = {offset = 30, color = "#B9ACFB"},
	-- Ren & Stimpy
	["Ren & Stimpy"] = {offset = 42, color = "#C7C97E"},
	-- Angry Beavers
	["Angry Beavers"] = {offset = 43, color = "#EFB708"},
	-- El Tigre
	["El Tigre"] = {offset = 56, color = "#E35203"}
}

local afqm_character_style = {
	-- Fire Element
	["Eureka"] = {offset = 25, color = "#D876F8"},
	["Knockt"] = {offset = 5,  color = "#66CC66"},
	["Rend"]   = {offset = 10, color = "#FF6666"},
	["Ninja"]  = {offset = 8,  color = "#ACA2FF"},
}

local rushrev_character_style = {
	-- Fire Element
	["Weishan"] = {offset = 20, color = "#3DEB8C"},
	["Zhurong"] = {offset = 16, color = "#3DEB8C"},
	["Seth"] = {offset = 9, color = "#3DEB8C"},
	["Ashani"] = {offset = 17, color = "#3DEB8C"},
	["Kidd"] = {offset = 25, color = "#3DEB8C"},
	["Velora"] = {offset = 13, color = "#3DEB8C"},
	["Raymer"] = {offset = 20, color = "#3DEB8C"},
	["Reina"] = {offset = 17, color = "#3DEB8C"},
	["Ezzie"] = {offset = 41, color = "#3DEB8C"},
	["Urdah"] = {offset = 10, color = "#3DEB8C"},
	["Afi & Galu"] = {offset = 68, color = "#3DEB8C"},
	["The Torment"] = {offset = 26, color = "#3DEB8C"},
}

function p.main(frame)
    local args = frame.args
    local title = mw.title.getCurrentTitle()
    
    -- Use base title to get "Game/CharacterName", but add option to override for testing
    local baseTitle = args.baseTitle or title.prefixedText
    
    local parts = mw.text.split(baseTitle, "/")
    if #parts < 2 then
        return "Error: page title must be at least Game/CharacterName"
    end

    local game = parts[1]
    local character = parts[2]
    local image = game .. " " .. character .. " Portrait.png"
    
    -- Defaults with optional overrides
    local offset = "30"
    local color = "#301934"
	if game == "RoA2" then
	    local data = roa2_character_style[character]
	    if data then
	        offset = data.offset
	        color = data.color
	    end
    elseif game == "SSBU" then
	    local data = ssbu_character_style[character]
	    if data then
	        offset = data.offset
	        color = data.color
	    end
	elseif game == "PPlus" then
	    local data = pplus_character_style[character]
	    if data then
	        offset = data.offset
	        color = data.color
	    end
	elseif game == "NASB2" then
	    local data = nasb2_character_style[character]
	    if data then
	        offset = data.offset
	        color = data.color
	    end
	elseif game == "AFQM" then
	    local data = afqm_character_style[character]
	    if data then
	        offset = data.offset
	        color = data.color
	    end
	elseif game == "RushRev" then
	    local data = rushrev_character_style[character]
	    if data then
	        offset = data.offset
	        color = data.color
	    end
	end
    	

	-- Assemble template calls
    local navCard = string.format(
        "{{CharNavCard | game=%s | character=%s | image=%s | offset=%s | color=%s}}",
        game, character, image, offset, color
    )
    local links = string.format("{{#lst:%s/Data|Links}}", game .. "/" .. character)

    return frame:preprocess(navCard .. links)
end

return p