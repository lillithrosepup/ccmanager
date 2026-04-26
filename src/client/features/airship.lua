print("This node is registered as an airship: " .. os.getComputerLabel())

ccmgr.config.define(
  "airship.maxspeed",
  {
    description = "Cap for airship speed",
    type = "number",
    default = 15
  }
)

ccmgr.config.define(
  "airship.savedheight",
  {
    description = "DO NOT MANUALLY SET -- The saved hight to persist reboots",
    type = "number",
    default = 0
  }
)

local state = {
  speed = 0, -- 1 - max, 0 is stop
  turning = 0, -- -1 - 1
  reverse = false,
  height = ccmgr.config.get("airship.savedheight"), -- 0 - 15
  horn = false,
  auxiliary = false
}

local keysDown = {
  -- movement
  [keys.w] = false,
  [keys.s] = false,
  -- left right
  [keys.a] = false,
  [keys.d] = false,
  -- reverse
  [keys.r] = false,
  -- brake
  [keys.e] = false,
  -- up down
  [keys.leftShift] = false,
  [keys.space] = false,
  -- full speed
  [keys.f] = false,
  -- debug log
  [keys.m] = false,
  -- HORN
  [keys.tab] = false
}

local function updateOutputs()
  redstone.setAnalogOutput("top", state.height)
  ccmgr.config.set("airship.savedheight", state.height)
  redstone.setOutput("back", state.reverse)
  redstone.setOutput("bottom", state.horn)

  -- speed handler
  local remappedSpeed = state.speed - 1
  if remappedSpeed < 0 then
    remappedSpeed = 15
  end
  redstone.setAnalogOutput("front", remappedSpeed)

  -- turn speed
  redstone.setOutput("left", state.turning < 0)
  redstone.setOutput("right", state.turning > 0)
end

ws.registerPacketHandler(
  "keyDown",
  function(packet)
    keysDown[packet.keyCode] = true

    if packet.keyCode == keys.x then
      state.auxiliary = not state.auxiliary
    end
  end
)
ws.registerPacketHandler(
  "keyUp",
  function(packet)
    keysDown[packet.keyCode] = false
  end
)

local tickIndex = 0

local function updateInputs()
  -- debug
  if keysDown[keys.m] then
    print(textutils.serialiseJSON(state))
  end
  state.horn = keysDown[keys.tab]
  -- brake
  if keysDown[keys.e] then
    print("HAND BRAKE")
    state.speed = 0
    state.turning = 0
    state.reverse = false
    return
  end
  -- full speed
  if keysDown[keys.f] then
    print("full speed ahead!")
    state.speed = ccmgr.config.get("airship.maxspeed")
  end
  state.reverse = keysDown[keys.r]

  if keysDown[keys.a] and not keysDown[keys.d] then
    print("Turning Left")
    state.turning = -1
  else
    if keysDown[keys.d] and not keysDown[keys.a] then
      print("Turning Right")
      state.turning = 1
    else
      state.turning = 0
    end
  end

  if state.auxiliary then
    if keysDown[keys.w] and not keysDown[keys.s] then
      state.speed = 2
      state.reverse = false
    else
      if keysDown[keys.s] and not keysDown[keys.w] then
        state.speed = 2
        state.reverse = true
      else
        state.speed = 0
      end
    end
  else
    if tickIndex % 5 == 0 then
      if keysDown[keys.w] and not keysDown[keys.s] then
        state.speed = math.min(state.speed + 1, ccmgr.config.get("airship.maxspeed"))
        print("Changing speed to " .. state.speed)
      else
        if keysDown[keys.s] and not keysDown[keys.w] then
          state.speed = math.max(state.speed - 1, 0)
          print("Changing speed to " .. state.speed)
        end
      end

      if keysDown[keys.space] and not keysDown[keys.leftShift] then
        state.height = math.min(state.height + 1, 15)
        print("Changing height to " .. state.height)
      else
        if keysDown[keys.leftShift] and not keysDown[keys.space] then
          state.height = math.max(state.height - 1, 0)
          print("Changing height to " .. state.height)
        end
      end
    end
  end
end

while true do
  tickIndex = (tickIndex % 20) + 1
  updateInputs()
  updateOutputs()
  sleep(0.05)
end
