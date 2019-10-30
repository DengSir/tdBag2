-- Api.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 10/18/2019, 1:11:20 PM

---- LUA
local pairs = pairs
local select = select
local format = string.format
local tinsert = table.insert

---- WOW
local ContainerIDToInventoryID = ContainerIDToInventoryID
local UnitName = UnitName
local GetScreenWidth = GetScreenWidth

---- UI
local GameTooltip = GameTooltip

---- G
local RAID_CLASS_COLORS = RAID_CLASS_COLORS
local BACKPACK_CONTAINER = BACKPACK_CONTAINER
local BANK_CONTAINER = BANK_CONTAINER
local NUM_BAG_SLOTS = NUM_BAG_SLOTS
local NUM_BANKBAGSLOTS = NUM_BANKBAGSLOTS

---@type ns
local ns = select(2, ...)

ns.ITEM_SIZE = 37
ns.ITEM_SPACING = 2

ns.LEFT_MOUSE_BUTTON = [[|TInterface\TutorialFrame\UI-Tutorial-Frame:12:12:0:0:512:512:10:65:228:283|t]]
ns.RIGHT_MOUSE_BUTTON = [[|TInterface\TutorialFrame\UI-Tutorial-Frame:12:12:0:0:512:512:10:65:330:385|t]]

-- @debug@
local L = LibStub('AceLocale-3.0'):GetLocale('tdBag2')
-- @end-debug@
--[===[@non-debug@
local L = LibStub('AceLocale-3.0'):GetLocale('tdBag2', true)
--@end-non-debug@]===]
ns.L = L

local BAG_ID = { --
    BAG = 'bag',
    BANK = 'bank',
}

local BAGS = { --
    [BAG_ID.BAG] = {BACKPACK_CONTAINER},
    [BAG_ID.BANK] = {BANK_CONTAINER},
}
local BAG_SETS = {}
local INV_IDS = {}
do
    for i = 1, NUM_BAG_SLOTS do
        local id = i
        tinsert(BAGS[BAG_ID.BAG], id)

        INV_IDS[ContainerIDToInventoryID(id)] = id
    end

    for i = 1, NUM_BANKBAGSLOTS do
        local id = i + NUM_BAG_SLOTS
        tinsert(BAGS[BAG_ID.BANK], id)

        INV_IDS[ContainerIDToInventoryID(id)] = id
    end

    for bagId, v in pairs(BAGS) do
        for _, bag in pairs(v) do
            BAG_SETS[bag] = bagId
        end
    end
end

ns.BAG_ID = BAG_ID
ns.BAG_ICONS = { --
    [BAG_ID.BAG] = [[Interface\Buttons\Button-Backpack-Up]],
    [BAG_ID.BANK] = [[Interface\ICONS\INV_Misc_Bag_13]],
}

ns.FRAME_TITLES = { --
    [BAG_ID.BAG] = L.TITLE_BAG,
    [BAG_ID.BANK] = L.TITLE_BANK,
}

ns.BAG_FAMILY = { --
    [1] = 'Quiver',
    [2] = 'Quiver',
    [3] = 'Soul',
    [4] = 'Soul',
    [6] = 'Herb',
    [7] = 'Enchant',
}

ns.TRADE_BAG_ORDER = { --
    NONE = 'none',
    TOP = 'top',
    BOTTOM = 'bottom',
}

local function riter(t, i)
    i = i - 1
    if i > 0 then
        return i, t[i]
    end
end

function ns.ripairs(t)
    return riter, t, #t + 1
end

function ns.GetBags(bagId)
    return BAGS[bagId]
end

function ns.GetBagId(bag)
    return BAG_SETS[bag]
end

function ns.GetBag(bag)
    return BAG_SETS[bag] == BAG_ID.BAG
end

function ns.IsBag(bag)
    return BAG_SETS[bag] == BAG_ID.BAG
end

function ns.IsBank(bag)
    return BAG_SETS[bag] == BAG_ID.BANK
end

function ns.InvToBag(inv)
    return INV_IDS[inv]
end

function ns.IsSelf(owner)
    return not owner or owner == UnitName('player')
end

function ns.AnchorTooltip(frame)
    if frame:GetRight() >= (GetScreenWidth() / 2) then
        GameTooltip:SetOwner(frame, 'ANCHOR_LEFT')
    else
        GameTooltip:SetOwner(frame, 'ANCHOR_RIGHT')
    end
end

function ns.GetOwnerColoredName(owner)
    local color = RAID_CLASS_COLORS[owner.class or 'PRIEST']
    return format('|cff%02x%02x%02x%s|r', color.r * 0xFF, color.g * 0xFF, color.b * 0xFF, owner.name)
end

function ns.LeftButtonTip(text)
    return ns.LEFT_MOUSE_BUTTON .. text, 1, 1, 1
end

function ns.RightButtonTip(text)
    return ns.RIGHT_MOUSE_BUTTON .. text, 1, 1, 1
end
