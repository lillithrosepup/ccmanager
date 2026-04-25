function string.split(self, sep)
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

function listContains(self, match)
  for i, value in ipairs(self) do
    if value == match then
      return true
    end
  end
  return false
end

ccmgr.utils = {
  string = {
    split = string.split
  },
  list = {
    contains = listContains
  }
}
