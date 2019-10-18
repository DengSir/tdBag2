-- Option.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 10/23/2019, 3:14:52 PM

---@type ns
local ns = select(2, ...)
local Addon = ns.Addon
local L = ns.L

local AceConfigRegistry = LibStub('AceConfigRegistry-3.0')
local AceConfigDialog = LibStub('AceConfigDialog-3.0')

local FRAMES = { --
    [ns.BAG_ID.BAG] = {},
    [ns.BAG_ID.BANK] = {},
}

function Addon:SetupOptionFrame()
    local order = 0

    local function orderGen()
        order = order + 1
        return order
    end

    local function toggle(name)
        return {type = 'toggle', width = 'full', name = name, order = orderGen()}
    end

    local function color(name)
        return {type = 'color', name = name, order = orderGen()}
    end

    local function range(name, min, max, step)
        return {type = 'range', width = 'full', order = orderGen(), name = name, min = min, max = max, step = step}
    end

    local function header(name)
        return {type = 'header', order = orderGen(), name = name}
    end

    local function inline(name, args)
        return {type = 'group', name = name, inline = true, order = orderGen(), args = args}
    end

    local function desc(name)
        return {
            type = 'description',
            order = orderGen(),
            name = name,
            fontSize = 'medium',
            image = [[Interface\Common\help-i]],
            imageWidth = 32,
            imageHeight = 32,
            imageCoords = {.2, .8, .2, .8},
        }
    end

    local function separator()
        return {type = 'description', order = orderGen(), name = '\n', fontSize = 'medium'}
    end

    local function drop(opts)
        local old = {}
        local new = {}

        local get, set = opts.get, opts.set
        if opts.values and set then
            opts.set = function(item, value)
                return set(item, old[value])
            end
        end
        if opts.values and get then
            opts.get = function(item)
                return new[get(item)]
            end
        end

        if opts.values then
            local values = {}
            local len = #opts.values
            local F = format('%%%dd\001%%s', len)

            for i, v in ipairs(opts.values) do
                local f = format(F, i, v.value)
                values[f] = v.name
                old[f] = v.value
                new[v.value] = f
            end

            opts.values = values
        end

        opts.type = 'select'
        opts.order = orderGen()

        return opts
    end

    local function group(name, args)
        return {type = 'group', name = name, order = orderGen(), args = args}
    end

    local function frame(bagId, name)
        return {
            type = 'group',
            name = name,
            order = orderGen(),
            set = function(item, value)
                self.db.profile.frames[bagId][item[#item]] = value
                self:UpdateAll()
            end,
            get = function(item)
                return self.db.profile.frames[bagId][item[#item]]
            end,
            args = {
                appearance = inline(L['Appearance'], { --
                    managed = {
                        type = 'toggle',
                        name = L['Blizzard Panel'],
                        width = 'full',
                        order = orderGen(),
                        get = function()
                            return self.db.profile.frames[bagId].managed
                        end,
                        set = function(_, value)
                            self.db.profile.frames[bagId].managed = value
                            self:UpdateAllManaged()
                        end,
                    },
                    reverseBag = toggle(L['Reverse Bag Order']),
                    reverseSlot = toggle(L['Reverse Slot Order']),
                    column = range(L['Columns'], 6, 36, 1),
                }),
                buttons = inline(L['Plugin Buttons'], FRAMES[bagId]),
            },
        }
    end

    local options = {
        type = 'group',
        get = function(item)
            return self.db.profile[item[#item]]
        end,
        set = function(item, value)
            self.db.profile[item[#item]] = value
            self:UpdateAll()
        end,
        args = {
            general = group(GENERAL, {
                desc = desc(L.DESC_GENERAL),
                generalHeader = header(GENERAL),
                lockFrame = toggle(L['Lock Frames']),
                tipCount = {
                    type = 'toggle',
                    name = L['Show Item Count in Tooltip'],
                    width = 'full',
                    order = orderGen(),
                    get = function()
                        return self.db.profile.tipCount
                    end,
                    set = function(_, value)
                        self.db.profile.tipCount = value
                        ns.Tooltip:Update()
                    end,
                },
                appearanceHeader = header(L['Appearance']),
                iconJunk = toggle(L['Show Junk Icon']),
                iconQuestStarter = toggle(L['Show Quest Starter Icon']),
                textOffline = toggle(L['Show Offline Text in Bag\'s Title']),
                tradeBagOrder = drop{
                    name = L['Trade Containers Location'],
                    values = {
                        {name = L['Default'], value = ns.TRADE_BAG_ORDER.NONE}, --
                        {name = L['Top'], value = ns.TRADE_BAG_ORDER.TOP}, --
                        {name = L['Bottom'], value = ns.TRADE_BAG_ORDER.BOTTOM}, --
                    },
                    get = function()
                        return self.db.profile.tradeBagOrder
                    end,
                    set = function(_, value)
                        self.db.profile.tradeBagOrder = value
                        self:UpdateAll()
                    end,
                },
            }),
            colors = group(L['Color Settings'], {
                desc = desc(L.DESC_COLORS),
                glowHeader = header(L['Highlight Border']),
                glowQuality = toggle(L['Highlight Items by Quality']),
                glowQuest = toggle(L['Highlight Quest Items']),
                glowUnusable = toggle(L['Highlight Unusable Items']),
                glowEquipSet = toggle(L['Highlight Equipment Set Items']),
                glowNew = toggle(L['Highlight New Items']),
                glowAlpha = range(L['Highlight Brightness'], 0, 1),
                separator1 = separator(),
                colorHeader = header(L['Slot Colors']),
                colorSlots = toggle(L['Color Empty Slots by Bag Type']),
                colors = {
                    type = 'group',
                    inline = true,
                    name = L['Container Colors'],
                    order = orderGen(),
                    disabled = function()
                        return not self.db.profile.colorSlots
                    end,
                    get = function(item)
                        local color = self.db.profile[item[#item]]
                        return color.r, color.g, color.b
                    end,
                    set = function(item, ...)
                        local color = self.db.profile[item[#item]]
                        color.r, color.g, color.b = ...
                        self:UpdateAll()
                    end,
                    args = {
                        colorNormal = color(L['Normal Color']),
                        colorQuiver = color(L['Quiver Color']),
                        colorSoul = color(L['Soul Color']),
                        colorEnchant = color(L['Enchanting Color']),
                        colorHerb = color(L['Herbalism Color']),
                    },
                },
            }),
            display = group(L['Auto Display'], {
                desc = desc(L.DESC_DISPLAY),
                displayHeader = header(L['Auto Display']),
                displayMail = toggle(L['Visiting the Mail Box']),
                displayAuction = toggle(L['Visiting the Auction House']),
                displayBank = toggle(L['Visiting the Bank']),
                displayMerchant = toggle(L['Visiting a Vendor']),
                displayCharacter = toggle(L['Opening the Character Info']),
                displayCraft = toggle(L['Opening Trade Skills']),
                displayTrade = toggle(L['Trading Items']),
                closeHeader = header(L['Auto Close']),
                closeMail = toggle(L['Leaving the Mail Box']),
                closeAuction = toggle(L['Leaving the Auction House']),
                closeBank = toggle(L['Leaving the Bank']),
                closeMerchant = toggle(L['Leaving a Vendor']),
                closeCharacter = toggle(L['Closing the Character Info']),
                closeCraft = toggle(L['Closing Trade Skills']),
                closeTrade = toggle(L['Completed Trade']),
                closeCombat = toggle(L['Entering Combat']),
            }),
            frame = {
                type = 'group',
                name = L['Frame Settings'],
                order = orderGen(),
                childGroups = 'tab',
                args = {
                    desc = desc(L.DESC_FRAMES),
                    [ns.BAG_ID.BAG] = frame(ns.BAG_ID.BAG, L['Inventory']),
                    [ns.BAG_ID.BANK] = frame(ns.BAG_ID.BANK, L['Bank']),
                },
            },
        },
    }

    AceConfigRegistry:RegisterOptionsTable('tdBag2', options)
    self.options = AceConfigDialog:AddToBlizOptions('tdBag2', 'tdBag2')

    self:RefreshPluginOptions()
end

local OpenToCategory = function(options)
    InterfaceOptionsFrame_OpenToCategory(options)
    InterfaceOptionsFrame_OpenToCategory(options)
    OpenToCategory = InterfaceOptionsFrame_OpenToCategory
end

function Addon:OpenFrameOption(bagId)
    if bagId then
        OpenToCategory(self.options)
        AceConfigDialog:SelectGroup('tdBag2', 'frame', bagId)
    else
        OpenToCategory(self.options)
    end
end

function Addon:RefreshPluginOptions()
    for bagId, args in pairs(FRAMES) do
        wipe(args)

        for i, plugin in Addon:IteratePluginButtons() do
            args[plugin.key] = {
                type = 'toggle',
                name = plugin.text,
                order = i,
                set = function(item, value)
                    self.db.profile.frames[bagId].disableButtons[plugin.key] = not value
                    self:UpdateAll()
                end,
                get = function(item)
                    return not self.db.profile.frames[bagId].disableButtons[plugin.key]
                end,
            }
        end
    end
    AceConfigRegistry:NotifyChange('tdBag2')
end
