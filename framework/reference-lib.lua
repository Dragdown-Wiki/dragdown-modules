package.path = os.getenv("HOME") .. "/.luarocks/share/lua/5.1/?.lua;"
	.. os.getenv("HOME") .. "/.luarocks/share/lua/5.1/?/init.lua;"
	.. "./modules/?.lua;"
	.. package.path

package.cpath = os.getenv("HOME") .. "/.luarocks/lib/lua/5.1/?.so;"
	.. package.cpath

-- what i needed for code-server:
-- package.path  = "./?.lua;"
--               .. "/config/.luarocks/share/lua/5.1/?.lua;"
--               .. "/config/.luarocks/share/lua/5.1/?/init.lua;"
--               .. "./modules/?.lua;"
--               .. package.path

require("framework.save-table-to-file")
require("framework.mock-mw")
local tblx = require("pl.tablex")

local games = { "AFQM", "PPlus" }

os.execute("mkdir -p reference_output")

return function(callback)
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
		end)

		for _, config in ipairs(allAttacks) do
			-- print(i .. "/" .. #allAttacks)

			local _, htmlOrError = xpcall(function()
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
				print("=> failed at " ..
					game .. " - " .. config.chara .. " - " .. config.attack)
				print(err)
				print(debug.traceback())
				os.exit(1)
			end)

			local filePath = "reference_output/" ..
				game .. "_" .. config.chara .. "_" .. config.attack .. ".html"
				
			callback(htmlOrError, filePath, config)
		end
	end
end
