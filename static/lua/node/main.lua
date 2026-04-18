local program = require('/lvn/core/program')

if not lvn.config.get("node.password") then
  print("You do not have a password set.")
  io.write("Please enter a password: ")
  local password = io.read("*l")

  lvn.config.set("node.password", password)
end

-- Register node specific packet handlers
require("/run/ws")


-- Load shared websocket loop
program.run('/run/sharedWs.lua', 'Websocket Runner', true, "loop")

program.run('/run/sharedRednet.lua', 'Rednet Runner', false, "loop")

-- Load turtle module
if turtle then
  print("Running turtle main")
  program.run('/run/turtle/main.lua', 'Turtle', true)
end

if lvn.config.get("sorter") then
  print("Item sorter detected")
  program.run('/run/sorter/main.lua', 'Sorter', true)
end

if lvn.config.get("constellation") then
  print("Constellation node detected")
  program.run('/run/constellation/main.lua', 'Constellation', true)
end

-- local topPeripheralMethods = peripheral.getMethods("top")
-- if topPeripheralMethods then
--   if lvn.utils.list.contains(topPeripheralMethods, "getDestinationDimension") then
--     print("Handles Tardis Interface Detected")
--     program.run('/run/tardis/main.lua', 'Tardis', true)
--   end
-- end