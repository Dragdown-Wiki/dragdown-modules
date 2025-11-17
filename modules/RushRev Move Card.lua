local p = {}
local mArguments
local cargo = mw.ext.cargo
local utils = require("Move Card Utils")

local function readModes(chara, attack)
	local tables = "RushRev_MoveMode"
	local fields =
		"chara, attack, attackID, mode, startup, startupNotes, totalActive, totalActiveNotes, endlag, endlagNotes, cancel, cancelNotes, landingLag, landingLagNotes, totalDuration, totalDurationNotes,iasa,autocancel,autocancelNotes,hitID,hitMoveID,hitName,hitActive,customShieldSafety,uniqueField,frameChart, articleID, notes"
	local args = {
		where = 'RushRev_MoveMode.chara="' .. chara .. '" and RushRev_MoveMode.attack="' .. attack .. '"',
		orderBy = "_ID",
	}
	local results = cargo.query(tables, fields, args)
	return results
end

function p.main(frame)
	mArguments = require("Arguments")
	local args = mArguments.getArgs(frame)
	return p._main(args)
end

function p._main(args)
	local chara = args["chara"]
	local attack = args["attack"]
	local desc = args["desc"]
	if args["desc"] == nil then
		desc = args["description"]
	end
	if desc == "" or desc == nil then
		desc =
			"<small>''This move card is missing a move description. The following bullet points should all be one paragraph or more and be included:''\n* Brief 1-2 sentences stating the basic function and utility of the move. Ex: ''\"Excellent anti-air, combo-starter, and combo-extender. The move starts behind before sweeping to the front.\"''\n* Explaining the reward and usefulness of the move and how it functions in her gameplan. Point out non-obvious use cases when relevant.\n* Explaining the shortcomings of the move, i.e. unsafe on shield, stubby, slow, etc.\n* Explaining when and where to use the move. Can differentiate between if it's good in neutral, punish, against fastfallers, floaties, etc.\nIf there's something you want to debate leaving it in or out, err on the side of leaving it in. For more details, read [[User:Lynnifer/Brief_Style_Guide#Move_Cards|here]].\n</small>"
	end
	local advDesc = args["advDesc"]

	if not chara then
		chara = mw.title.getCurrentTitle().subpageText
	end
	local html = utils.getCardHTML(chara, attack, desc, advDesc, readModes)
	return tostring(html)
		.. mw.getCurrentFrame():extensionTag({
			name = "templatestyles",
			args = { src = "Template:MoveCard/shared/styles.css" },
		})
end

return p