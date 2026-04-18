local completion = require('/lvn/core/completion')

local possibleModes = {"idle", "goto", "spin", "mine", "mobgrinder"}

local nodes = textutils.unserializeJSON(lvn.net.get("/api/admin/nodes"))

completion.setCompletionFunction(function()
  local ccCompletion = require("cc.shell.completion")
  
  -- nodes: array of {name: string, id: string}
  -- allow param 1 to be a node name or id
  -- add the node name and id to the possibleNodes list
  local possibleNodes = {}
  
  for i, node in ipairs(nodes) do
    if node.turtle then
      table.insert(possibleNodes, node.name)
      table.insert(possibleNodes, tostring(node.id))
    end
  end

  local possibleTurtlesChoice = { ccCompletion.choice, possibleNodes }
  local possibleTurtlesModes = possibleNodes
  for i, mode in ipairs(possibleModes) do
    table.insert(possibleTurtlesModes, mode)
  end

  return ccCompletion.build({ ccCompletion.choice, { "mode", "control"}}, 
    {
      ccCompletion.choice, possibleTurtlesModes
    },
    possibleTurtlesChoice,
    possibleTurtlesChoice,
    possibleTurtlesChoice,
    possibleTurtlesChoice,
    possibleTurtlesChoice,
    possibleTurtlesChoice,
    possibleTurtlesChoice,
    possibleTurtlesChoice,
    possibleTurtlesChoice,
    possibleTurtlesChoice
  )
end)

completion.setHelpText("Usage: turtle <mode | control> [mode] [--turtles ...turtles]")
completion.setHelpText("Set a turtle's mode")

completion.setRequiredArgs(2)

local tArgs = { ... }

if not completion.check(tArgs) then
  return
end

local turtleNames = {}

for i, arg in ipairs(tArgs) do
  if arg == "--turtles" then
    turtleNames = table.pack(table.unpack(tArgs, i + 1))

    for a = i+1, #tArgs do
      tArgs[a] = nil
    end
    break
  end
end

if #turtleNames == 0 then
  print("No turtles specified")
end

if tArgs[1] == "control" then
  print("Starting control")

  local function sendAll(type, data)
    for i, turtle in ipairs(turtleNames) do
      sharedWs.send("packet", {
        node = turtle,
        packet = {
          type = type,
          data = data
        },
      })
    end
  end

  local function handleKey()

    while true do
      -- Read key
      local event, key = os.pullEvent("key")
      if key == keys.w then
        sendAll("move", "forward")
      elseif key == keys.s then
        sendAll("move", "backward")
      elseif key == keys.a then
        sendAll("move", "left")
      elseif key == keys.d then
        sendAll("move", "right")
      elseif key == keys.space then
        sendAll("move", "up")
      elseif key == keys.leftShift then
        sendAll("move", "down")
      elseif key == keys.e then
        print("Digging")
        sendAll("dig", "forward")
      elseif key == keys.r then
        print("Refueling")
        sendAll("refuel", {})
      end
    end
  end

  handleKey()
  return
end

if tArgs[1] == "mode" then

  if tArgs[2] == "goto" and not tArgs[3] then
    local x, y, z = gps.locate()
    tArgs[3] = math.floor(x)
    tArgs[4] = math.floor(y)
    tArgs[5] = math.floor(z)

    -- Pocket computers are one above the player
    if pocket then tArgs[4] = tArgs[4] - 1 end
  end
  
  for i, name in ipairs(turtleNames) do
    local res = lvn.net.post("/api/admin/nodes/" .. name .. "/turtle/mode", textutils.serialiseJSON({
      mode = tArgs[2],
      args = {table.unpack(tArgs, 3)}
    }))

    if not res then
      print("Failed to set mode")
    end
  end
  print("Set mode to " .. tArgs[2])
  return
end