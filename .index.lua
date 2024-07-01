---@meta
---@class EventsMixin
local EventsMixin = {}

---@param event string
---@param callback? string | function
function EventsMixin:RegisterFrameEvent(event, callback)
end

local AceEvent = LibStub('AceEvent-3.0')

EventsMixin.RegisterEvent = AceEvent.RegisterMessage
EventsMixin.UnregisterEvent = AceEvent.UnregisterMessage
EventsMixin.UnregisterAllEvents = AceEvent.UnregisterAllMessages

---@class MetaMixin
---@field meta FrameMeta
local MetaMixin = {}

---@class tdBag2ButtonPluginOptions
---@field type 'Button'
---@field icon number|string
---@field order? number
---@field init function
---@field key string
---@field text? string

---@class tdBag2ItemPluginOptions
---@field type 'Item'
---@field init function
---@field update function
---@field text string

---@alias tdBag2PluginOptions tdBag2ButtonPluginOptions|tdBag2ItemPluginOptions

---@class tdBag2CacheInfo
---@field cached boolean

---@class tdBag2OwnerInfo: tdBag2CacheInfo
---@field name string
---@field realm string
---@field class string
---@field faction string
---@field race string
---@field gender? integer
---@field money integer
---@field guild boolean

---@class tdBag2BagInfo: tdBag2CacheInfo
---@field free integer
---@field family? integer
---@field count integer
---@field slot integer
---@field link? string
---@field icon? string | integer
---@field owned boolean
---@field cost integer
---@field title string
---@field id integer

---@class tdBag2ItemInfo: tdBag2CacheInfo
---@field id integer
---@field link? string
---@field icon? string | integer
---@field count integer
---@field locked boolean
---@field quality integer
---@field readable boolean
---@field timeout integer

---@class ProfileWatchItem
---@field itemId integer
---@field watchAll boolean
