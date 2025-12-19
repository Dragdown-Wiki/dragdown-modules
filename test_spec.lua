package.path = os.getenv("HOME") .. "/.luarocks/share/lua/5.1/?.lua;"
	.. os.getenv("HOME") .. "/.luarocks/share/lua/5.1/?/init.lua;"
	.. "./modules/?.lua;"
	.. package.path

package.cpath = os.getenv("HOME") .. "/.luarocks/lib/lua/5.1/?.so;"
	.. package.cpath

require("busted.runner")()
require("framework.save-table-to-file")
require("framework.mock-mw")
local tblx = require("pl.tablex")
local makeDiff = require("./patched_diff")

local games = { "AFQM", "PPlus" }

os.execute("mkdir -p reference_output")

local function capture_output(fn)
	local out = {}
	local old_print = _G.print
	local old_write = _G.io.write

	_G.print = function(...)
		local t = {}
		for i = 1, select("#", ...) do
			t[#t + 1] = tostring(select(i, ...))
		end

		out[#out + 1] = table.concat(t, "\t") .. "\n"
	end

	---@diagnostic disable-next-line: duplicate-set-field
	_G.io.write = function(...)
		for i = 1, select("#", ...) do
			out[#out + 1] = tostring(select(i, ...))
		end
	end

	fn()

	_G.print = old_print
	_G.io.write = old_write
	return table.concat(out)
end

describe("Move Card modules", function()
	for _, game in ipairs(games) do
		local moveCard = require("modules." .. game .. " Move Card")

		local allAttacks = mw.ext.cargo.query(
			game .. "_MoveMode",
			"chara,attack",
			{ limit = 500 }
		)

		-- insert a non-existing attack to test graceful failure

		table.insert(allAttacks, { chara = allAttacks[1].chara, attack = "Foo" })

		-- filter out attacks with currently bad data

		allAttacks = tblx.filter(allAttacks, function(v)
			if game == "PPlus" then
				if (v.chara == "Bowser" and v.attack == "Dspecial")
					or (v.chara == "Fox" and v.attack == "Uspecial") then
					return false
				else
					return true
				end
			else
				return true
			end
		end, nil)

		for _, config in ipairs(allAttacks) do
			it("should have the same output as reference", function()
				local _, moduleOutput = xpcall(function()
					mw.title.setCurrentTitle({ rootText = game, subpageText = config.chara })

					return moveCard.main({
						args = {
							chara = config.chara,
							attack = config.attack,
							desc = "descPlaceholder",
							advDesc = "advDescPlaceholder",
						},
						getParent = function() end,
					})
				end, function(err)
					error(
						"=> failed at " ..
						game .. " - " .. config.chara .. " - " .. config.attack
						.. "\n" .. err
						.. "\n" .. debug.traceback()
					)
				end)

				local filePath = "./reference_output/" ..
					game .. "_" .. config.chara .. "_" .. config.attack .. ".html"

				local file = io.open(filePath, "r")
				local referenceOutput = file:read("*a")
				file:close()

				if moduleOutput ~= referenceOutput then
					local diff = makeDiff(moduleOutput, referenceOutput)

					local diffOutput = capture_output(function()
						diff:print({ color = true, context = 2 })
					end)

					error("Output mismatch\nModule: " ..
						game ..
						" Move Card.lua, Character: " ..
						config.chara .. ", Attack: " .. config.attack ..
						"\nReference output file: " .. filePath ..
						"\nDiff:\n" .. diffOutput)
				end
			end)
		end
	end
end)
