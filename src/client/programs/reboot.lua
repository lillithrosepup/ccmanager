local completion = require("/ccmgr/lib/completion")

completion.setCompletionFunction(
  function()
    print("Completion Running")
    local ccCompletion = require("cc.shell.completion")
    local possibleNodes = {}

    for name, data in pairs(ccmgr.state.nodeRegistry) do
      table.insert(possibleNodes, name)
    end

    return ccCompletion.build({ccCompletion.choice, possibleNodes})
  end
)

completion.setHelpText("Usage: reboot [node]")
completion.setHelpText("Reboots self, or a specified node")

completion.setRequiredArgs(0)

completion.registerComplDependency({"nodeAddRemove"})

local tArgs = {...}

if not completion.check(tArgs) then
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
