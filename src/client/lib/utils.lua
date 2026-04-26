---@class CCMUtils
---@field string {split: fun(self: string, sep?: string): string[]}
---@field list {contains: fun(self: string[], match: string): boolean}

local function split(self, sep)
  local sep, fields = sep or ":", {}
  local pattern = string.format("([^%s]+)", sep)
  self:gsub(
    pattern,
    function(c)
      fields[#fields + 1] = c
    end
  )
  return fields
end

local function listContains(self, match)
  for i, value in ipairs(self) do
    if value == match then
      return true
    end
  end
  return false
end

---@type CCMUtils
local utils = {
  string = {
    split = split
  },
  list = {
    contains = listContains
  }
}
ccmgr.utils = utils