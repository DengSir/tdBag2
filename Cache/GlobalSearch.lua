-- GlobalSearch.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 2/9/2020, 2:15:15 AM

local ipairs = ipairs
local wipe = table.wipe or wipe
local tinsert = table.insert

---@type ns
local ns = select(2, ...)

local L = ns.L
local Search = ns.Search

local BAG_ID = ns.BAG_ID
local GLOBAL_SEARCH_OWNER = ns.GLOBAL_SEARCH_OWNER

---@class tdBag2GlobalSearchBagItem
---@field title string
---@field bags string[]

---@type tdBag2GlobalSearchBagItem[]
local BAGS = {
    {title = L.TITLE_BAG, bags = ns.GetBags(BAG_ID.BAG)}, --
    {title = L.TITLE_BANK, bags = ns.GetBags(BAG_ID.BANK)}, --
    {title = L.TITLE_EQUIP, bags = ns.GetBags(BAG_ID.EQUIP)}, --
    {title = L.TITLE_MAIL, bags = {ns.MAIL_CONTAINER}}, --
    {title = L.TITLE_COD, bags = {ns.COD_CONTAINER}}, --
}

---@class tdBag2GlobalSearch
local GlobalSearch = ns.Addon:NewModule('GlobalSearch')

function GlobalSearch:OnInitialize()
    self.results = {}
    self.bags = {}
end

function GlobalSearch:Search(text)
    if text:trim() == '' then
        text = nil
    end

    local Cache = ns.Cache

    local results = wipe(self.results)
    local bags = wipe(self.bags)
    local index = 1

    if text then
        for _, owner in ipairs(Cache:GetOwners()) do
            for i, v in ipairs(BAGS) do
                ---@type tdBag2CacheBagData
                local bagInfo = {}
                ---@type tdBag2CacheItemData[]
                local items = {}

                for _, bag in ipairs(v.bags) do
                    local bagInfo = Cache:GetBagInfo(owner, bag)
                    for slot = 1, bagInfo.count or 0 do
                        local itemInfo = Cache:GetItemInfo(owner, bag, slot)
                        if itemInfo.link then
                            if Search:Matches(itemInfo.link, text) then
                                tinsert(items, {
                                    cached = true,
                                    link = itemInfo.link,
                                    count = itemInfo.count,
                                    icon = itemInfo.icon,
                                    quality = itemInfo.quality,
                                    id = itemInfo.id,
                                    timeout = itemInfo.timeout,
                                })
                            end
                        end
                    end
                end

                local count = #items
                if count > 0 then
                    bagInfo.title = v.title:format(owner)
                    bagInfo.count = count
                    bagInfo.cached = true
                    bagInfo.owned = true
                    bagInfo.items = items

                    local bag = GLOBAL_SEARCH_OWNER .. index
                    index = index + 1

                    tinsert(bags, bag)
                    results[bag] = bagInfo
                end
            end
        end
    end

    ns.Events:Fire('GLOBAL_SEARCH_UPDATE')
end

function GlobalSearch:GetBags()
    return self.bags
end

function GlobalSearch:GetBagInfo(bag)
    return self.results[bag]
end

function GlobalSearch:GetItemInfo(bag, slot)
    local bagInfo = self:GetBagInfo(bag)
    return bagInfo.items[slot]
end
