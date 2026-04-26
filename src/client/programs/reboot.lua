ccmgr.completion.setCompletionFunction(
  function()
    local ccCompletion = require("cc.shell.completion")
    local possibleNodes = {}

    for name, data in pairs(ccmgr.state.nodeRegistry) do
      table.insert(possibleNodes, name)
    end

    return ccCompletion.build({ccCompletion.choice, possibleNodes})
  end
)

ccmgr.completion.setHelpText("Usage: reboot [node]")
ccmgr.completion.setHelpText("Reboots self, or a specified node")

ccmgr.completion.setRequiredArgs(0)

ccmgr.completion.registerComplDependency({"nodeAddRemove"})

local tArgs = {...}

if not ccmgr.completion.check(tArgs) then
  return
end

if #tArgs == 0 then
  os.reboot()
  return
end

ws.send(
  {
    t = "reboot",
    client = tArgs[1]
  }
)
