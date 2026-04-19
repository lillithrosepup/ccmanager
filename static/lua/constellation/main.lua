if not lvn.config.get("constellation.x") then
  print("You do not have an X coordinate set.")
  io.write("Please enter an X coordinate: ")
  local x = tonumber(io.read("*l"))
  lvn.config.set("constellation.x", x)
  return
end
print("X: " .. lvn.config.get("constellation.x"))

if not lvn.config.get("constellation.y") then
  print("You do not have a Y coordinate set.")
  io.write("Please enter a Y coordinate: ")
  local y = tonumber(io.read("*l"))
  lvn.config.set("constellation.y", y)
  return
end
print("Y: " .. lvn.config.get("constellation.y"))

if not lvn.config.get("constellation.z") then
  print("You do not have a Z coordinate set.")
  io.write("Please enter a Z coordinate: ")
  local z = tonumber(io.read("*l"))
  lvn.config.set("constellation.z", z)
  return
end
print("Z: " .. lvn.config.get("constellation.z"))

if not lvn.config.get("constellation.dimension") then
  print("You do not have a dimension set.")
  io.write("Please enter a dimension: ")
  local dim = io.read("*l")
  lvn.config.set("constellation.dimension", dim)
  return
end
print("Dimension: " .. lvn.config.get("constellation.dimension"))



local gpsId = multishell.launch(getfenv(), "/rom/programs/gps.lua", "host", lvn.config.get("constellation.x"), lvn.config.get("constellation.y"), lvn.config.get("constellation.z"))
multishell.setTitle(gpsId, "GPS")

-- Load packet handlers
require("/run/constellation/rednet")
require("/run/constellation/ws")

print("Listening...")

while true do
  sleep(1)
end