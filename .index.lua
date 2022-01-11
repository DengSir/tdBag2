---@meta
---@class EventsMixin
local EventsMixin = {}

---@param event string
---@param callback string | function
function EventsMixin:RegisterFrameEvent(event, callback)
end

local AceEvent = LibStub('AceEvent-3.0')

EventsMixin.RegisterEvent = AceEvent.RegisterEvent
EventsMixin.UnregisterEvent = AceEvent.UnregisterEvent
EventsMixin.UnregisterAllEvents = AceEvent.UnregisterAllEvents

---@class MetaMixin
---@field meta FrameMeta
local MetaMixin = {}

---@class tdBag2ButtonPluginOptions
---@field type 'Button'
---@field icon number|string
---@field order number
---@field init function
---@field key string
---@field text  string

---@class tdBag2ItemPluginOptions
---@field type 'Item'
---@field init function
---@field update function
---@field text string

---@alias tdBag2PluginOptions tdBag2ButtonPluginOptions|tdBag2ItemPluginOptions
