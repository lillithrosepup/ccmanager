---@class Node
---@field name string
---@field flags string[]

---@class Completion
---@field program string
---@field deps string[]

---@class CCMState
---@field nodeRegistry table<string, Node>
---@field completionRegistry Completion[]

---@type CCMState
ccmgr.state = {
  nodeRegistry = {},
  completionRegistry = {}
}