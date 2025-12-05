-- new cargo module using api.php?action=cargoquery

---@diagnostic disable: need-check-nil
local http_request = require "http.request"
local http_util = require "http.util"
local cjson = require "cjson"
local types = require "tableshape".types
local cookie = require "framework.mw-get-cookie"
local inspect = require "inspect".inspect
local simpleHash = require "framework.simplehash"

local argsTableShape = types.shape {
  where = types.string:is_optional(),
  limit = types.integer:is_optional(),
  groupBy = types.string:is_optional(),
  join = types.string:is_optional(),
  orderBy = types.string:is_optional()
}

--- @param tables string
--- @param fields string
--- @param argsTable {
---  where: string?,
---  limit: integer?,
---  orderBy: string?,
---  join: string?,
---  groupBy: string?,
--- }
--- @return table
local function cargo(tables, fields, argsTable)
  assert(argsTableShape(argsTable))

  local params = {
    action = "cargoquery",
    tables = tables,
    fields = fields,
    format = "json",
    formatversion = "2",
    where = argsTable.where,
    group_by = argsTable.groupBy,
    join_on = argsTable.join
  }

  if argsTable.limit ~= nil then
    params.limit = tostring(argsTable.limit)
  end

  local paramsString = http_util.dict_to_query(params)

  local cacheFile = ".cache/cargo_" .. simpleHash(paramsString)
  local res, err = table.load(cacheFile)

  if err == nil then
    return res
  end

  print("Cargo cache miss, querying tables " .. tables)

  local query = http_request.new_from_uri(
    "https://dragdown.wiki/w/api.php?" .. paramsString
  )

  query.headers:upsert("cookie", cookie)

  local headers, stream = query:go()
  local body = stream:get_body_as_string()

  if headers:get ":status" ~= "200" then
    error(body)
  end

  local ok, json = pcall(function()
    return cjson.decode(body)
  end)

  if not ok then
    error("Failed to decode json. Body:\n\"" .. body .. "\"")
  end

  if json.cargoquery == nil then
    error("cargoquery property is nil. body: \n" .. body .. "\nparams:\n" .. inspect(params))
  end

  local result = {}

  for _, v in ipairs(json.cargoquery) do
    local transformedTable = {}

    for innerKey, innerValue in pairs(v.title) do
      if innerValue == "" then
        transformedTable[innerKey] = nil
      else
        transformedTable[innerKey] = innerValue
      end
    end

    table.insert(result, transformedTable)
  end

  local saveError = table.save(result, cacheFile)
  
  if saveError ~= nil then
    error("cache save error: " .. saveError)
  end

  return result
end

return cargo
