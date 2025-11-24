local luassert  = require("luassert")
local cargo     = require("cargo2")
local inspect = require("inspect").inspect

-- this is probably sufficient for mocking dragdown modules,
-- but if needed, mw source code is here:
-- https://github.com/wikimedia/mediawiki-extensions-Scribunto/blob/master/includes/Engines/LuaCommon/lualib

local node_mt   = {}
node_mt.__index = node_mt

function node_mt:addClass(cls)
  luassert.is.string(cls)

  self._class = cls
  return self
end

function node_mt:css(nameOrTable, maybeValue)
  if type(nameOrTable) == "string" then
    luassert.is_string(maybeValue)

    self._css = nameOrTable .. ": " .. maybeValue .. "; "
  else
    luassert.is_table(nameOrTable)
    luassert.is_nil(maybeValue)

    for k, v in pairs(nameOrTable) do
      self._css = k .. ": " .. v .. "; "
    end
  end

  return self
end

function node_mt:attr(name, value)
  luassert.is.string(name)
  luassert.is.string(value)

  self._attr[name] = value
  return self
end

function node_mt:node(node)
  assert(
    type(node) == "string"
    or getmetatable(node) == getmetatable(self)
  )

  if type(node) ~= "string" then
    node._parent = self
  end

  table.insert(self._nodes, node)
  return self
end

function node_mt:tag(tag)
  luassert.is_string(tag)

  local node = setmetatable({
    _tag = tag,
    _css = "",
    _attr = {},
    _nodes = {},
    _parent = self
  }, node_mt)

  self:node(node)

  return node
end

function node_mt:wikitext(wikitext)
  if wikitext == nil then
    return self
  end

  local t = type(wikitext)

  if t ~= "number" and t ~= "string" then
    error("assert failed. got type: " .. t)
  end

  table.insert(self._nodes, wikitext)
  return self
end

function node_mt:allDone()
  local parent = self._parent

  while parent ~= nil do
    parent = parent._parent
  end

  return parent or self
end

function node_mt:done()
  return self._parent or self
end

function node_mt:__tostring()
  local r = "<" .. self._tag

  if self._class then
    r = r .. " class=\"" .. self._class .. "\""
  end

  if self._css ~= "" then
    r = r .. " style=\""

    if type(self._css) == "string" then
      r = r .. self._css
    else
      for k, v in pairs(self._css) do
        r = r .. k .. ": " .. v .. "; "
      end
    end

    r = r .. "\""
  end

  for k, v in pairs(self._attr) do
    r = r .. " " .. k .. "=\"" .. v .. "\""
  end

  r = r .. ">"

  for k, v in pairs(self._nodes) do
    r = r .. "\n  " .. tostring(v)
  end

  r = r .. "</" .. self._tag .. ">"

  return r
end

_G.mw = {
  html = {
    create = function(tag)
      luassert.is.string(tag)

      return setmetatable({
        _tag = tag,
        _css = "",
        _attr = {},
        _nodes = {},
        _parent = nil
      }, node_mt)
    end
  },
  title = {
    getCurrentTitle = function()
      return {
        rootText = "AFQM",
        subpageText = "Rend"
      }
    end
  },
  getCurrentFrame = function()
    return {
      preprocess = function(self, str)
        return str
      end,
      extensionTag = function(self, tbl)
        if tbl and tbl.name == "tabber" then
          return [[
<div class="tabber tabber--live">
  <header class="tabber__header">
    <button
      class="tabber__header__prev"
      tabindex="-1"
      type="button"
      aria-hidden="true"
    ></button>
    <nav class="tabber__tabs" role="tablist">
      <a
        class="tabber__tab"
        role="tab"
        id="tabber-Images-label"
        href="#tabber-Images"
        aria-controls="tabber-Images"
        tabindex="0"
        aria-selected="true"
        >Images</a
      >
    </nav>
    <button
      class="tabber__header__next"
      tabindex="-1"
      type="button"
      aria-hidden="true"
    ></button>
  </header>
  <section class="tabber__section" style="height: 514px">
    <article
      class="tabber__panel"
      role="tabpanel"
      tabindex="0"
      id="tabber-Images"
      aria-labelledby="tabber-Images-label"
    >
]] .. tbl.content .. [[
    </article>
  </section>
</div>
          ]]
        end

        if tbl and tbl.name == "templatestyles" then
          return "<templatestyles src='".. tbl.args.src .."'/>"
        end

        error("cant handle this extensionTag call: " .. inspect(tbl))
      end
    }
  end,
  ext = {
    cargo = {
      query = cargo
    }
  },
  ustring = {
    find = function(str, pattern, init, plain)
      return string.find(str, pattern, init, plain)
    end
  }
}
