local completion = {
  helpText = {},
  requiredArgs = 0,
  completionFunction = nil
}

completion.setHelpText = function(text)
  table.insert(completion.helpText, text)
end

completion.setRequiredArgs = function(args)
  completion.requiredArgs = args
end

completion.setCompletionFunction = function(func)
  completion.completionFunction = func
end

---@param deps string[]
completion.registerComplDependency = function(deps)
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

-- TODO: why the fuck is this not being called
completion.updateComplDependency = function(dep)
  for _, compl in ipairs(ccmgr.state.completionRegistry) do
    if ccmgr.utils.list.contains(compl.deps, dep) then
      shell.run(compl.program .. " completion")
    end
  end
end

completion.check = function(args)
  if #args == 1 and args[1] == "completion" then
    local completionFunction = completion.completionFunction()
    shell.setCompletionFunction(shell.getRunningProgram(), completionFunction)
    return false
  end

  local isHelp = false
  for i, arg in ipairs(args) do
    if arg == "--help" then
      isHelp = true
      break
    end
  end

  if isHelp or #args < completion.requiredArgs then
    -- Split by \n
    for i, line in pairs(completion.helpText) do
      print(line)
    end
    return false
  end

  return true
end

return completion
