-- Counter.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 12/3/2019, 2:52:21 PM

---@type ns
local ns = select(2, ...)

local Cache = ns.Cache

---@class tdBag2Counter
local Counter = {}
ns.Counter = Counter

Counter.cache = {}

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
    if self.cache[owner] and self.cache[owner][itemId] then
        return unpack(self.cache[owner][itemId])
    end

    local info = Cache:GetOwnerInfo(owner)
    local equip = self:GetBagItemCount(owner, 'equip', itemId)
    local bags, banks = 0, 0

    if info.cached then
        for _, bag in ipairs(ns.GetBags(ns.BAG_ID.BAG)) do
            bags = bags + self:GetBagItemCount(owner, bag, itemId)
        end
        for _, bag in ipairs(ns.GetBags(ns.BAG_ID.BANK)) do
            banks = banks + self:GetBagItemCount(owner, bag, itemId)
        end

        self.cache[owner] = self.cache[owner] or {}
        self.cache[owner][itemId] = {equip, bags, banks}
    else
        local owned = GetItemCount(itemId, true)
        local carrying = GetItemCount(itemId)

        bags = carrying - equip
        banks = owned - carrying
    end
    return equip, bags, banks
end

function Counter:GetOwnerItemTotal(owner, itemId)
    local equip, bags, banks = self:GetOwnerItemCount(owner, itemId)
    return equip + bags + banks
end
