-- FrameMeta.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 11/8/2019, 2:20:54 PM

---@type ns
local ns = select(2, ...)
local Cache = ns.Cache
local BAG_ID = ns.BAG_ID

---@class tdBag2FrameMeta
---@field bagId number
---@field owner string
---@field bags number[]
---@field profile tdBag2FrameProfile
---@field frame tdBag2Frame
---@field sets tdBag2Profile
local FrameMeta = ns.Addon:NewClass('FrameMeta')

function FrameMeta:Constructor(bagId, frame)
    self.bagId = bagId
    self.bags = ns.GetBags(bagId)
    self.frame = frame
    self:Update()
end

function FrameMeta:Update()
    self.profile = ns.Addon:GetFrameProfile(self.bagId)
    self.sets = ns.Addon.db.profile
end

function FrameMeta:HasBag(bag)
    if bag == KEYRING_CONTAINER then
        return not self:IsCached()
    end
    return self.bagId == ns.GetBagId(bag)
end

function FrameMeta:IsBank()
    return self.bagId == BAG_ID.BANK
end

function FrameMeta:IsBag()
    return self.bagId == BAG_ID.BAG
end

function FrameMeta:IsCached()
    return Cache:IsOwnerCached(Cache:GetOwnerAddress(self.owner))
end

function FrameMeta:IsSelf()
    return ns.IsSelf(self.owner)
end

function FrameMeta:ToggleBagHidden(bag)
    self.profile.hiddenBags[bag] = not self.profile.hiddenBags[bag] or nil
    ns.Events:Fire('UPDATE_ALL')
end

function FrameMeta:IsBagHidden(bag)
    return self.profile.hiddenBags[bag]
end
