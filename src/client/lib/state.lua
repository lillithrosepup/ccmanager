---@alias NodeRegistry table<string, Node>
---@class Node
---@field name string
---@field flags string[]

---@alias CompletionRegistry Completion[]
---@class Completion
---@field program string
---@field deps string[]

---@type {nodeRegistry: NodeRegistry, completionRegistry: CompletionRegistry}
ccmgr.state = {
  nodeRegistry = {},
  completionRegistry = {}
}
