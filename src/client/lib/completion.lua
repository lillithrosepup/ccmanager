---@class CCMCompletion
---@field helpText string[]
---@field requiredArgs number
---@field completionFunction nil|fun(): string[]
---@field setHelpText fun(text: string)
---@field setRequiredArgs fun(args: number)
---@field setCompletionFunction fun(func: fun(): string[]|nil)
---@field registerComplDependency fun(deps: string[])
---@field updateComplDependency fun(dep: string)
---@field check fun(args: string[]): boolean

local state = {
  helpText = {},
  requiredArgs = 0,
  completionFunction = nil
}

local function setHelpText(text)
  table.insert(state.helpText, text)
end

local function setRequiredArgs(args)
  state.requiredArgs = args
end

local function setCompletionFunction(func)
  state.completionFunction = func
end

local function registerComplDependency(deps)
  for _, compl in ipairs(ccmgr.state.completionRegistry) do
    if compl.program == shell.getRunningProgram() then
      return
    end
  end
  table.insert(
    ccmgr.state.completionRegistry,
    {
      program = shell.getRunningProgram(),
      deps = deps
    }
  )
end

local function updateComplDependency(dep)
  for _, compl in ipairs(ccmgr.state.completionRegistry) do
    if ccmgr.utils.list.contains(compl.deps, dep) then
      shell.run(compl.program .. " completion")
    end
  end
end

local function check(args)
  if #args == 1 and args[1] == "completion" then
    local f = state.completionFunction()
    shell.setCompletionFunction(shell.getRunningProgram(), f)
    return false
  end

  local isHelp = false
  for i, arg in ipairs(args) do
    if arg == "--help" then
      isHelp = true
      break
    end
  end

  if isHelp or #args < state.requiredArgs then
    for i, line in pairs(state.helpText) do
      print(line)
    end
    return false
  end

  return true
end

return {
  helpText = state.helpText,
  requiredArgs = state.requiredArgs,
  completionFunction = state.completionFunction,
  setHelpText = setHelpText,
  setRequiredArgs = setRequiredArgs,
  setCompletionFunction = setCompletionFunction,
  registerComplDependency = registerComplDependency,
  updateComplDependency = updateComplDependency,
  check = check
}