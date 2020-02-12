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
---@field lastSearch string
local GlobalSearch = ns.Addon:NewModule('GlobalSearch')

function GlobalSearch:OnInitialize()
    self.results = {}
    self.bags = {}
end

function GlobalSearch:Search(text)
    if text:trim() == '' then
        text = nil
    end

    if self.lastSearch ~= text then
        self.lastSearch = text
        self:DoSearch()
        ns.Events:Fire('GLOBAL_SEARCH_UPDATE')
    end
end

function GlobalSearch:DoSearch()
    local results = wipe(self.results)
    local bags = wipe(self.bags)

    if self.lastSearch then
        local Cache = ns.Cache
        local index = 1

        for _, owner in ipairs(Cache:GetOwners()) do
            for i, v in ipairs(BAGS) do
                ---@type tdBag2CacheBagData
                local bagInfo = {}
                ---@type tdBag2CacheItemData[]
                local items = {}

                for _, bag in ipairs(v.bags) do
                    local info = Cache:GetBagInfo(owner, bag)
                    for slot = 1, info.count or 0 do
                        local itemInfo = Cache:GetItemInfo(owner, bag, slot)
                        if itemInfo.link and Search:Matches(itemInfo.link, self.lastSearch) then
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

                local count = #items
                if count > 0 then
                    bagInfo.cached = true
                    bagInfo.owned = true
                    bagInfo.title = v.title:format(owner)
                    bagInfo.count = count
                    bagInfo.items = items

                    local bag = GLOBAL_SEARCH_OWNER .. index
                    bags[index] = bag
                    results[bag] = bagInfo
                    index = index + 1
                end
            end
        end
    end
end

function GlobalSearch:GetBags()
    return self.bags
end

function GlobalSearch:GetBagInfo(bag)
    return self.results[bag]
end

function GlobalSearch:GetItemInfo(bag, slot)
    local bagInfo = self:GetBagInfo(bag)
    return bagInfo and bagInfo.items[slot]
end
