-- TokenFrame.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 11/29/2019, 11:10:36 AM

local ipairs, select = ipairs, select

local GetItemIcon = GetItemIcon
local GetItemInfo = GetItemInfo
local GetItemQualityColor = GetItemQualityColor

local GameTooltip = GameTooltip

---@type ns
local ns = select(2, ...)

---@class tdBag2TokenFrame: tdBag2MenuButton
---@field private meta tdBag2FrameMeta
---@field private buttons tdBag2Token[]
local TokenFrame = ns.Addon:NewClass('UI.TokenFrame', ns.UI.MenuButton)
TokenFrame.menuOffset = {xOffset = -5}

function TokenFrame:Constructor(_, meta)
    self.meta = meta
    self.buttons = {}
    self:SetScript('OnShow', self.OnShow)
    self:SetScript('OnHide', self.OnHide)
    self:SetScript('OnClick', self.ToggleMenu)
    self:Update()
end

function TokenFrame:OnShow()
    if not self.meta:IsCached() then
        self:RegisterEvent('BAG_UPDATE_DELAYED', 'Update')
    else
        self:UnregisterAllEvents()
    end
    self:RegisterEvent('WATCHED_TOKEN_CHANGED', 'Update')
    self:RegisterFrameEvent('OWNER_CHANGED', 'Update')
    self:Update()
end

function TokenFrame:OnHide()
    self:UnregisterAllEvents()
    self:CloseMenu()
end

function TokenFrame:GetButton(i)
    if not self.buttons[i] then
        local button = ns.UI.Token:New(self)
        if i == 1 then
            button:SetPoint('LEFT', 10, 0)
        else
            button:SetPoint('LEFT', self.buttons[i - 1], 'RIGHT', 5, 0)
        end
        self.buttons[i] = button
    end
    return self.buttons[i]
end

function TokenFrame:Update()
    local index = 0
    for _, itemId in ipairs(ns.TOKENS) do
        if self.meta.sets.tokens[itemId] then
            index = index + 1
            local button = self:GetButton(index)
            button:SetItem(self.meta.owner, itemId)
            button:Show()
        end
    end

    for i = index + 1, #self.buttons do
        self.buttons[i]:Hide()
    end
end

function TokenFrame:CreateMenu()
    local menu = {}
    for i, itemId in ipairs(ns.TOKENS) do
        local name, _, quality = GetItemInfo(itemId)

        menu[i] = {
            text = name or 'item:' .. itemId,
            isNotRadio = true,
            checked = self.meta.sets.tokens[itemId],
            colorCode = quality and '|c' .. select(4, GetItemQualityColor(quality)) or nil,
            icon = GetItemIcon(itemId),
            func = function(_, _, _, checked)
                self.meta.sets.tokens[itemId] = not checked
                ns.Events:Fire('WATCHED_TOKEN_CHANGED')
            end,
        }
    end
    return menu
end
