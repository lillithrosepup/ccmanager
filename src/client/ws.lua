local tArgs = {...}

local wsUrl =
  "ws" ..
  (ccmgr.config.get("boot.ssl") and "s" or "") ..
    "://" ..
      ccmgr.config.get("boot.host") .. ":" .. ccmgr.config.get("boot.port") .. "/?nodeName=" .. os.getComputerLabel()

-- if true then
--   wsUrl = wsUrl .. "&flags=testflag"
-- end

if tArgs[1] == "loop" then
  ws.connect()

  pcall(ws.loop)

  print("Websocket crashed, rebooting...")

  sleep(5)

  os.reboot()
end

if ws then
  ws.disconnect()
  os.unloadAPI("ws")
end

socket = nil

function send(data)
  local packet = textutils.serialiseJSON(data)
  if ccmgr.config.get("debug") then
    print("Sending: ", packet)
  end
  socket.send(packet)
end

local packetHandlers = {}

function registerPacketHandler(type, func)
  packetHandlers[type] = func
end

function unregisterPacketHandler(type)
  packetHandlers[type] = nil
end

function handleMessage()
  local event, connUrl, packetString = os.pullEvent("websocket_message")

  if connUrl == wsUrl then
    local packet = textutils.unserialiseJSON(packetString)

    if ccmgr.config.get("debug") and packet.t ~= "heartbeat" then
      print("Received: ", packetString)
    end

    if packetHandlers[packet.t] then
      pcall(packetHandlers[packet.t], packet)
    else
      printError("Unknown packet type: " .. packet.t)
    end
  end
  -- for my sanity incase it gets overwritten
  -- WHY THE FUCK DOES IT CRASH IT
  -- multishell.setTitle(multishell.getCurrent(), "Websocket Runner")
end

function handleClose()
  local event, connUrl, reason, code = os.pullEvent("websocket_closed")

  if connUrl == wsUrl then
    print("Connection closed: ", code, reason)
    local speaker = peripheral.find("speaker")
    if speaker then
      speaker.playSound("minecraft:block.bell.use")
    end
    sleep(5)
    os.reboot()
  end
end

function handleError()
  local event, connUrl, reason, code = os.pullEvent("websocket_error")

  if connUrl == wsUrl then
    printError("Connection error: ", code, reason)
    local speaker = peripheral.find("speaker")
    if speaker then
      speaker.playSound("minecraft:block.bell.use")
    end
    sleep(5)
    os.reboot()
  end
end

function connect()
  if socket and socket.isOpen() then
    return true
  end
  print("Connection URL: " .. wsUrl)
  local newSocket, err = http.websocket(wsUrl)
  if not newSocket then
    printError("Connection Error: ", err)
    sleep(5)
    os.reboot()
  else
    socket = newSocket
    print("Connection established")
    return true
  end
end

function disconnect()
  socket.close()
end

function loopOnce()
  parallel.waitForAny(handleMessage, handleClose, handleError)
end

function loop()
  while true do
    loopOnce()
  end
end
