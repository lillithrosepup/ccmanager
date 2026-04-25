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