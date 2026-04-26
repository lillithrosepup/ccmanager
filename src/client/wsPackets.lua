ws.registerPacketHandler(
  "reboot",
  function()
    os.reboot()
  end
)

ws.registerPacketHandler(
  "update",
  function()
    ccmgr.program.run("/startup/boot.lua", "Bootloader Update", true, "update")
  end
)

ws.registerPacketHandler(
  "nodeConnect",
  function(packet)
    print("Node Joined Network: " .. packet.name)
    ccmgr.state.nodeRegistry[packet.name] = {name = packet.name, flags = packet.flags}
    ccmgr.completion.updateComplDependency("nodeAddRemove")
  end
)

ws.registerPacketHandler(
  "nodeDisconnect",
  function(packet)
    print("Node Left Network: " .. packet.name)
    ccmgr.state.nodeRegistry[packet.name] = nil
    ccmgr.completion.updateComplDependency("nodeAddRemove")
  end
)
