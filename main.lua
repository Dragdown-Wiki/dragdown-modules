require "save-table-to-file"
require "mock-mw"
local inspect = require "inspect".inspect

package.path = package.path .. ";./modules/?.lua"

local afqmMoveCard = require "modules.AFQM Move Card"

local allAttacks = mw.ext.cargo.query(
  "AFQM_MoveMode",
  "chara,attack",
  {
    limit = 500,
  }
)

-- TODO add a module call with a non-existing attack to test graceful failure.

for _, v in ipairs(allAttacks) do
  local success, htmlOrError = xpcall(function()
    return afqmMoveCard.main({
      args = {
        chara = v.chara,
        attack = v.attack,
        desc = "descPlaceholder",
        advDesc = "advDescPlaceholder"
      },
      getParent = function() end
    })
  end, function(err)
    print("=> failed at " .. v.chara .. " - " .. v.attack)
    print(err)
    print(debug.traceback())
  end)

  if not success then
    os.exit(1)
  end

  local file = io.open(
    "reference_output/AFQM_" .. v.chara .. "_" .. v.attack .. ".html",
    "r"
  )

  local reference = file:read("*a")

  if reference ~= htmlOrError then
    error("mismatch at " .. inspect(v))
  end

  -- file:write(htmlOrError)
  file:close()
end

print("done :)")
