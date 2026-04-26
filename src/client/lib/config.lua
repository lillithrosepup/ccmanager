---@class Definition
---@field description string
---@field type string
---@field default any

---@class CCMConfig
---@field define fun(key: string, definition: Definition)
---@field get fun(key: string, default?: any): any
---@field set fun(key: string, value: any)
---@field exists fun(key: string): boolean

local function get(key, default)
  return settings.get("ccmgr." .. key, default)
end

local function set(key, value)
  settings.set("ccmgr." .. key, value)
  settings.save()
end

local function define(key, definition)
  settings.define("ccmgr." .. key, definition)
end

local function exists(key)
  return settings.get("ccmgr." .. key) ~= nil
end

---@type CCMConfig
local config = {
  get = get,
  set = set,
  define = define,
  exists = exists
}
ccmgr.config = config