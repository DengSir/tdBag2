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
