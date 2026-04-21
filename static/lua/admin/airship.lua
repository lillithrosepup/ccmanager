local completion = require('/lvn/core/completion')

completion.setCompletionFunction(function()
  local ccCompletion = require("cc.shell.completion")

  local nodes = textutils.unserializeJSON(lvn.net.get("/api/admin/nodes"))

  -- nodes: array of {name: string, id: string}
  -- allow param 1 to be a node name or id
  -- add the node name and id to the possibleNodes list
  local possibleNodes = {}

  for i, node in ipairs(nodes) do
    if node.airship then
      table.insert(possibleNodes, node.name)
      table.insert(possibleNodes, tostring(node.id))
    end
  end

  return ccCompletion.build({ ccCompletion.choice, possibleNodes })
end)

completion.setHelpText("Usage: redremote <node>")
completion.setHelpText("Toggles redstone output on a node")

completion.setRequiredArgs(1)

local tArgs = { ... }

if not completion.check(tArgs) then
  return
end

if not tArgs[2] then
  tArgs[2] = "front"
end

local node = tArgs[1]


-- local res = lvn.net.post("/api/admin/nodes/" .. node .. "/toggle", direction)

-- if not res then
--   print("Failed to toggle node")
--   return
-- end

print("Starting control for node " .. node)

local function send(type, data)
  sharedWs.send("packet", {
    node = node,
    packet = {
      type = type,
      data = data
    },
  })
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
