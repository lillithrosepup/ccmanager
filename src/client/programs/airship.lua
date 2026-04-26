local completion = require("/ccmgr/lib/completion")

completion.setCompletionFunction(
  function()
    local ccCompletion = require("cc.shell.completion")
    local possibleNodes = {}

    for name, data in pairs(ccmgr.state.nodeRegistry) do
      if ccmgr.utils.list.contains(data.flags, "airship") then
        table.insert(possibleNodes, name)
      end
    end

    return ccCompletion.build({ccCompletion.choice, possibleNodes})
  end
)

completion.setHelpText("Usage: airship <node>")
completion.setHelpText("Control an airship!")

completion.setRequiredArgs(1)

local tArgs = {...}
completion.registerComplDependency({"nodeAddRemove"})

if not completion.check(tArgs) then
  return
end

local node = tArgs[1]

shell.run("/ccmgr/programs/keyfwd.lua", node)
