package.path  = "./?.lua;"
              .. "/config/.luarocks/share/lua/5.1/?.lua;"
              .. "/config/.luarocks/share/lua/5.1/?/init.lua;"
              .. "./modules/?.lua;"
              .. package.path

package.cpath = "/config/.luarocks/lib/lua/5.1/?.so;"
              .. package.cpath

require "framework.save-table-to-file"
require "framework.mock-mw"
local inspect = require "inspect".inspect
local tblx = require("pl.tablex")
local List = require("pl.List")

local games = {
  "AFQM",
  "PPlus"
}

return function(callback)
  for _, game in ipairs(games) do
    local moveCard = require("modules." .. game .. " Move Card")

    local allAttacks = mw.ext.cargo.query(
      game .. "_MoveMode",
      "chara,attack",
      {
        limit = 500,
      }
    )

    -- insert a non-existing attack to test graceful failure

    table.insert(allAttacks, {
      chara = allAttacks[1].chara,
      attack = "Foo"
    })

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

    local count = 0

    for i, v in ipairs(allAttacks) do
      -- print(i .. "/" .. #allAttacks)
      
      local success, htmlOrError = xpcall(function()
        mw.title.setCurrentTitle({
          rootText = game,
          subpageText = v.chara
        })

        return moveCard.main({
          args = {
            chara = v.chara,
            attack = v.attack,
            desc = "descPlaceholder",
            advDesc = "advDescPlaceholder"
          },
          getParent = function() end
        })
      end, function(err)
        print("=> failed at " .. game .. " - " .. v.chara .. " - " .. v.attack)
        print(err)
        print(debug.traceback())
        os.exit(1)
      end)
      
      local filePath = "reference_output/" .. game .. "_" .. v.chara .. "_" .. v.attack .. ".html"
      callback(htmlOrError, filePath)
    end
  end
end