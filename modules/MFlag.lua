local flagTable = {
	default = {
		color = "#4097c0",
		files = {
			roa2 = "Dragdown Notice.png",
			pplus = "PPlus_MFlag_Disclaimer.png"
		},
		content = "'''Disclaimer'''<br>This section has been marked for the following reason: {{{clarifier|}}}[[Category:Verification Needed]]"
	},
	cleanup = {
		color = "#1E90FF",
		files = {
			roa2 = "Cleanup.png",
			pplus = "PPlus_MFlag_Cleanup.png"
		},
		content = "This section/page has been marked for cleanup or revision, possibly due to the following reasons: spelling mistakes, presentation improvements, formatting improvements, wordiness, or any reason that makes it not as accessible to a new reader. {{{clarifier|}}}[[Category:Articles_in_need_of_cleanup]]"
	},
	stub = {
		color = "Blue",
		files = {
			roa2 = "Stub.png",
			pplus = "PPlus_MFlag_Stub.png"
		},
		content = "'''A Stub!'''<br>This page is either still being worked on or is vastly incomplete. You can help by editing it.<br>''Reason: {{{clarifier|}}}''[[Category:Stubs]]"
	},
	delete = {
		color = "#cd683f",
		files = {
			roa2 = "Delete.png",
			pplus = "PPlus_MFlag_Notice.png"
		},
		content = "'''Notice'''<br>This section/page has been flagged for deletion. If you believe this is a mistake, contact the administration on Discord.[[Category:Candidates for deletion]]"
	},
	new_patch = {
		color = "#f4c430",
		files = {
			roa2 = "Outdated.png",
			pplus = "PPlus_MFlag_New_Patch.png"
		},
		content = "'''New Patch Update'''<br>This section was recently changed in the most recent patch. To see the full list of changes, check [[RoA2/Patch Notes]].{{{clarifier|}}}[[Category:Outdated Pages]]"
	},
	research = {
		color = "#f4c430",
		files = {
			roa2 = "Sticker_elliana_icon2.png",
			pplus = "PPlus_MFlag_Needs_more_Research.png"
		},
		content = "'''Needs More Research'''<br>The following aspects require further research or verification.<br>'''Reason:''''' {{{clarifier|}}}''[[Category:Research Needed]]"
	},
	verified = {
		color = "#f4c430",
		files = {
			roa2 = "Verified.png"
		},
		content = "'''Verified'''<br>This page has been verified since {{{REVISIONID|}}}.<br>{{{clarifier|}}}[[Category:Verified]]"
	},
	charproj = {
		color = "#f4c430",
		files = {
			roa2 = "Doa_Digger.png"
		},
		content = "'''RoA2: Awaiting Character Revision'''<br>This page is planned to undergo a major revision via the wiki's RoA2 [[Dragdown:Roadmap/RoA2#Character_Project|character project]]. Until then, consider this page incomplete.[[Category:RoA2_Character_Project]]"
	},
	purge_notice = {
		color = "#f4c430",
		files = {
			roa2 = "RoA2_Emote_Tinderbit_Cute.webm"
		},
		content = "'''Not seeing any notes?'''<br>If this page is only showing patch note links and not plain text, go to the triple dots in the corner of the page and select \"Purge\"."
	},
	starter_kit = {
		color = "#f4c430",
		files = {
			roa2 = "RoA2_Emote_Mudmo_Excited.webm"
		},
		content = "'''Starter Kit'''<br>This page is intended for beginners that generally understand how to move around but may struggle with learning a specific character."
	},
	newchar = {
		color = "#f4c430",
		files = {
			roa2 = "Outdated.png"
		},
		content = "'''Unreleased/New Character'''<br>This character is either unreleased or has been recently released. Missing information will be added as soon as possible.{{{clarifier|}}}[[Category:New_Characters]]"
	},
	factcheck = {
		color = "#f4c430",
		files = {
			roa2 = "RoA2_Emote_Kragg_Mental_Struggle.webm",
			pplus = "PPlus_MFlag_Fact_Check.png"
		},
		content = "'''Fact-check'''<br>This page/section is in need of fact-checking. Before removing this flag, make sure you verify this content with at least one other person, and make note of it in your edit summary. ''(E.G.: \"verified with Ilikepizza107 and Motobug\")''<br> {{{clarifier|}}}[[Category:Pages_in_need_of_fact_checking]]"
	},
	unassigned_char = {
		color = "#f4c430",
		files = {
			roa2 = "RoA2_Emote_Fleet_Squint_Champion.webm",
			pplus = "PPlus_MFlag_Un-Assigned.png"
		},
		content = "'''Unassigned'''<br>This character has yet to be assigned an certified consultant on the character. If you are an expert on the character and want to be assigned, please mention an admin on the server to get approval.<br> {{{clarifier|}}}[[Category:Pages_in_need_of_fact_checking]]"
	},
	assigned_char = {
		color = "#f4c430",
		files = {
			roa2 = "RoA2_Emote_Chef_Loxodont.webm",
			pplus = "PPlus_MFlag_Assigned.png"
		},
		content = "'''Assigned and Being Edited'''<br>This character is currently assigned to {{{user|}}}.<br> {{{clarifier|}}}[[Category:Pages_in_need_of_fact_checking]]"
	},
	revision_char = {
		color = "#f4c430",
		files = {
			roa2 = "RoA2_Emote_Pool_Party_Forsburn.webm",
			pplus = "PPlus_MFlag_Awaiting_Approval.png"
		},
		content = "'''Awaiting Revision'''<br>This character page has been completed and is awaiting revision and approval.<br> {{{clarifier|}}}[[Category:Pages_in_need_of_revision]]"
	},
	approved_char = {
		color = "#f4c430",
		files = {
			roa2 = "Verified.png",
			pplus = "PPlus_MFlag_Good_Standing.png"
		},
		content = "'''Good Standing'''<br>The character page is in good standing. It has been approved by {{{user|}}} since {{{REVISIONID|}}}.<br> {{{clarifier|}}}[[Category:Verified]]"
	},
	wip_page = {
		color = "#f4c430",
		files = {
			roa2 = "RoA2_Emote_Chef_Loxodont.webm"
		},
		content = "'''Work In Progress'''<br>This page is currently being written by {{{user|}}} and may not be fully accurate yet.<br> {{{clarifier|}}}[[Category:Pages_in_need_of_fact_checking]]"
	},
	revision_page = {
		color = "#f4c430",
		files = {
			roa2 = "RoA2_Emote_Pool_Party_Forsburn.webm"
		},
		content = "'''Awaiting Revision'''<br>This page is written by {{{user|}}} but is incomplete without competitive expertise.<br> {{{clarifier|}}}[[Category:Pages_in_need_of_revision]]"
	},
	approved_page = {
		color = "#f4c430",
		files = {
			roa2 = "RoA2_Emote_Salaryman_Kragg.webm"
		},
		content = "'''Good Standing'''<br>The page is in good standing, written and approved by the following users: {{{user|}}}.<br> {{{clarifier|}}}[[Category:Verified]]"
	},
}

local function makeRow(config, args)
	local game = mw.title.getCurrentTitle().rootText:lower() or "roa2"
	local file = config.files[game] or config.files.roa2

	return mw.html.create("tr")
		:tag("td")
			:addClass("mod-mflag-icon")
			:css("border-left", "12px solid "..config.color)
			:node(
				file:find(".webm")
					and "[[File:"..file.."|gif|80x80px]]"
					or  "[[File:"..file.."|80x80px|link=]]"
			)
		:done()
		:tag("td")
			:addClass("mod-mflag-content")
			:node(
				config.content
					:gsub("{{{clarifier|}}}", args.clarifier or "")
					:gsub("{{{user|}}}", args.user or "")
			)
		:done()
end

return {
	main = function(frame)
		local args = require("Arguments").getArgs(frame)

		local tableElem = mw.html.create("table")
			:addClass(args.sticky and "sticky" or "")
			:addClass("mod-mflag-table")
			:css({
				width = "98%",
				margin = "15px auto 16px auto",
				["background-color"] = "var(--color-surface-2)",
				["border-radius"] = "4px",
				padding = "4px",
				["box-shadow"] = "0 2px 2px 0 rgba(0,0,0,.14), "
						.. "0 3px 1px -2px rgba(0,0,0,.12), "
						.. "0 1px 5px 0 rgba(0,0,0,.2)"
			})

		-- for i = 1, #args do
		-- 	tableElem:node(makeRow(flagTable[args[i]]) or flagTable.default, args)
		-- end

		tableElem:node(makeRow(flagTable[args[1]] or flagTable.default, args))

		if args[2] then
			tableElem:node(makeRow(flagTable[args[2]] or flagTable.default, args))
		end

		return tostring(tableElem)
	end
}