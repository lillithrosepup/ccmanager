ccmgr.completion.setCompletionFunction(
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

ccmgr.completion.setHelpText("Usage: airship <node>")
ccmgr.completion.setHelpText("Control an airship!")

ccmgr.completion.setRequiredArgs(1)

local tArgs = {...}
ccmgr.completion.registerComplDependency({"nodeAddRemove"})

if not ccmgr.completion.check(tArgs) then
  return
end

local node = tArgs[1]

shell.run("/ccmgr/programs/keyfwd.lua", node)
