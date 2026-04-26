local function get(key, default)
  return settings.get("ccmgr." .. key, default)
end

local function set(key, value)
  settings.set("ccmgr." .. key, value)
  settings.save()
end

---@class Definition
---@field description string
---@field type string
---@field default any

---@param key string
---@param definition Definition
local function define(key, definition)
  settings.define("ccmgr." .. key, definition)
end

local function exists(key)
  return settings.get("ccmgr." .. key) ~= nil
end

ccmgr.config = {
  get = get,
  set = set,
  exists = exists,
  define = define
}
