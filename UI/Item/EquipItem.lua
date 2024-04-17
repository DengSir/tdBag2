-- EquipItem.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 1/11/2022, 8:01:14 PM
--
local _G = _G
local select = _G.select

---@type ns
local ns = select(2, ...)

local LE_ITEM_QUALITY_COMMON = _G.LE_ITEM_QUALITY_COMMON or Enum.ItemQuality.Common or Enum.ItemQuality.Standard
local ITEM_QUALITY_COLORS = _G.ITEM_QUALITY_COLORS

local ItemBase = ns.UI.ItemBase

---@class UI.EquipItem: UI.ItemBase
local EquipItem = ns.Addon:NewClass('UI.EquipItem', ItemBase)

EquipItem.pool = {}
EquipItem.GenerateName = ns.NameGenerator('tdBag2EquipItem')
EquipItem.Free = EquipItem.Hide

function EquipItem:GetBorderColor()
    if self.info.id then
        local sets = self.meta.sets
        local quality = self.info.quality
        if sets.glowQuality and quality and quality > LE_ITEM_QUALITY_COMMON then
            local color = ITEM_QUALITY_COLORS[quality]
            return color.r, color.g, color.b
        end
    end
end
