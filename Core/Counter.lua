-- Counter.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 12/3/2019, 2:52:21 PM

---@type ns
local ns = select(2, ...)
local Cache = ns.Cache

---@class tdBag2Counter
local Counter = ns.Addon:NewModule('Counter')

function Counter:OnInitialize()
    self.Cacher = ns.Cacher:New()
    self.Cacher:Patch(self, 'GetOwnerItemCount', true)
    self.GetOwnerItemCount.Cachable = function(info)
        return info.cached
    end
end

function Counter:GetBagItemCount(owner, bag, itemId)
    local info = Cache:GetBagInfo(owner, bag)
    if not info.count or info.count == 0 then
        return 0
    end

    local count = 0
    for slot = 1, info.count do
        local id = Cache:GetItemID(owner, bag, slot)
        if id == itemId then
            count = count + (Cache:GetItemInfo(owner, bag, slot).count or 1)
        end
    end
    return count
end

function Counter:GetOwnerItemCount(owner, itemId)
    local info = Cache:GetOwnerInfo(owner)
    local equip = self:GetBagItemCount(owner, ns.EQUIP_CONTAINER, itemId)
    local mails = self:GetBagItemCount(owner, ns.MAIL_CONTAINER, itemId)
    local bags, banks = 0, 0

    if info.cached then
        for _, bag in ipairs(ns.GetBags(ns.BAG_ID.BAG)) do
            bags = bags + self:GetBagItemCount(owner, bag, itemId)
        end
        for _, bag in ipairs(ns.GetBags(ns.BAG_ID.BANK)) do
            banks = banks + self:GetBagItemCount(owner, bag, itemId)
        end
    else
        local owned = GetItemCount(itemId, true)
        local carrying = GetItemCount(itemId)

        bags = carrying - equip
        banks = owned - carrying
    end
    return {equip = equip, bags = bags, banks = banks, mails = mails, cached = info.cached}
end

function Counter:GetOwnerItemTotal(owner, itemId)
    local info = self:GetOwnerItemCount(owner, itemId)
    return info.equip + info.bags + info.banks + info.mails
end
