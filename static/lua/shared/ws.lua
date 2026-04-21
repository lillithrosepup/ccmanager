local tArgs = { ... }

if tArgs[1] == "loop" then
  sharedWs.connect()

  pcall(sharedWs.loop)

  lvn.chat.send("Websocket crashed, rebooting...")

  print("Websocket crashed, rebooting...")

  sleep(5)

  os.reboot()
end


if sharedWs then
  sharedWs.disconnect()
  os.unloadAPI("sharedWs")
end


socket = nil

function sendRaw(string)
  socket.send(string)
end

function send(type, data)
  local packet = textutils.serialiseJSON({ type = type, data = data })
  if lvn.config.get("debug") and type ~= "heartbeat" then
    print("Sending: ", packet)
  end
  sendRaw(packet)
end

local packetHandlers = {}

function registerPacketHandler(type, func)
  packetHandlers[type] = func
end

function unregisterPacketHandler(type)
  packetHandlers[type] = nil
end

registerPacketHandler("register", function(data)
  if data.success then
    print("Registered successfully")
  else
    printError("Registration failed: ", data.message)
    lvn.chat.send("Registration failed: " .. data.message)
    sleep(5)
    os.reboot()
  end
end)

registerPacketHandler("heartbeat", function(data)
  send("heartbeat", data)
end)

registerPacketHandler("reboot", function()
  os.reboot()
end)

registerPacketHandler("eval", function(data)
  local func, err = loadstring(data.code)
    if not func then
      send("eval", {
        nonce = data.nonce,
        success = false,
        output = err
      })
    else
      local result = { pcall(func) }
      if not result[1] then
        send("eval", {
          nonce = data.nonce,
          success = false,
          output = result[2]
        })
      else
        table.remove(result, 1)
        send("eval", {
          nonce = data.nonce,
          success = true,
          output = result[1]
        })
      end
    end
end)


registerPacketHandler("update", function()
  os.run({}, "/startup/boot.lua", "update")
end)


registerPacketHandler("setDebug", function(data)
  lvn.config.set("debug", data)
end)

registerPacketHandler("command", function(data)
  local success, logs = commands.exec(data.command)
  send("command", {
    nonce = data.nonce,
    success = success,
    logs = logs
  })
end)



function handleMessage()
  local event, connUrl, packetString = os.pullEvent("websocket_message")

  if connUrl == lvn.urls.ws then
    local packet = textutils.unserialiseJSON(packetString)

    if lvn.config.get("debug") and packet.type ~= "heartbeat" then
      print("Received: ", packetString)
    end

    if packetHandlers[packet.type] then
      pcall(packetHandlers[packet.type], packet.data)
    else
      printError("Unknown packet type: " .. packet.type)
    end
  end
end

function handleClose()
  local event, connUrl, reason, code = os.pullEvent("websocket_closed")

  if connUrl == lvn.urls.ws then
    print("Connection closed: ", code, reason)
    local speaker = peripheral.find("speaker")
    if speaker then
      speaker.playSound("minecraft:block.bell.use")
    end
    lvn.chat.send("Connection closed: " .. code and code or "code unknown" .. " " .. reason)
    sleep(5)
    os.reboot()
  end
end

function handleError()
  local event, connUrl, reason, code = os.pullEvent("websocket_error")

  if connUrl == lvn.urls.ws then
    printError("Connection error: ", code, reason)
    local speaker = peripheral.find("speaker")
    if speaker then
      speaker.playSound("minecraft:block.bell.use")
    end
    lvn.chat.send("Connection error: " .. code .. " " .. reason)
    sleep(5)
    os.reboot()
  end
end





function connect()
  if socket and socket.isOpen() then
    return true
  end
  lvn.net.get("/api/render")
  local newSocket, err = http.websocket(lvn.urls.ws)
  if not newSocket then
    printError("Connection Error: ", err)
    sleep(5)
    os.reboot()
  else
    socket = newSocket
    print('Connection established')
    send("register", {
      type = lvn.config.get("boot.type"),
      id = os.getComputerID(),
      name = os.getComputerLabel(),
      password = lvn.config.get(lvn.config.get("boot.type") .. ".password"),
      debug = lvn.config.get("debug"),
      turtle = turtle ~= nil,
      command = commands ~= nil,
      airship = lvn.config.get("airship")
    })
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