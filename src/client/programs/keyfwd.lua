local completion = require("/ccmgr/lib/completion")

completion.setCompletionFunction(
  function()
    local ccCompletion = require("cc.shell.completion")
    local possibleNodes = {}

    for name, data in pairs(ccmgr.state.nodeRegistry) do
      table.insert(possibleNodes, name)
    end

    return ccCompletion.build({ccCompletion.choice, possibleNodes})
  end
)

completion.setHelpText("Usage: keyfwd <node>")
completion.setHelpText(
  "Forwards all keys to a specified node. This will be handled differently depending on its features."
)

completion.setRequiredArgs(1)

local tArgs = {...}
completion.registerComplDependency({"nodeAddRemove"})

if not completion.check(tArgs) then
  return
end

local node = tArgs[1]

print("Starting control for node " .. node)

local function send(type, data)
  ws.send(
    {
      t = "send",
      client = node,
      packet = {
        t = type,
        keyCode = data
      }
    }
  )
end

while true do
  -- Read key
  local eventData = {os.pullEvent()}
  local event = eventData[1]

  if event == "key" and eventData[2] and not eventData[3] then
    local key = eventData[2]
    send("keyDown", key)
  end
  if event == "key_up" then
    local key = eventData[2]
    send("keyUp", key)
  end
end
