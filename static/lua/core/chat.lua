local function tryChatWs(message)
  sharedWs.send("chat", message)
end

lvn.chat = {
  send = function(message)
    print(message)
    if not pcall(tryChatWs, message) then
      lvn.net.post("/api/node/" .. os.getComputerID() .. "/chat", message)
    end
  end,
  waypoint = function(name, initials, x, y, z, dimension)
    if not x or not y or not z then
      x, y, z = gps.locate()
    end
    if not dimension then
      dimension = sharedRednet.commands.getDimension()
    end
    local configStr = lvn.net.get("/api/config")
    local config = textutils.unserializeJSON(configStr)
    -- Get config.waypointMode
    if config.waypointMode == "xaero" then
      lvn.chat.send(
        "xaero-waypoint:" ..
          name:gsub(":", "") ..
            ":" .. initials .. ":" .. x .. ":" .. y .. ":" .. z .. ":0:false:0:Internal-" .. dimension .. "-waypoints"
      )
    elseif config.waypointMode == "journey" then
      lvn.chat.send("[name:" .. name .. ",x:" .. x .. ",y:" .. y .. ",z:" .. z .. ",dim:" .. dimension .. "]")
    else
      lvn.chat.send('waypoint:"' .. name .. '":' .. x .. ":" .. y .. ":" .. z .. ":" .. dimension)
    end
  end
}
