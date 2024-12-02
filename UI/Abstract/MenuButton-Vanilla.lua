-- MenuButton-Vanilla.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 11/27/2024, 11:47:04 AM
--
---@class ns
local ns = select(2, ...)

local MenuButton = ns.Addon:NewClass('UI.MenuButton', 'Button')

function MenuButton:Constructor()
    Mixin(self, DropdownButtonMixin)

    self.menuMixin = MenuStyle2Mixin
    self.menuPoint = 'TOPLEFT'
    self.menuRelativePoint = 'BOTTOMLEFT'
    self.menuPointX = self.MENU_OFFSET and self.MENU_OFFSET.xOffset or 0
    self.menuPointY = self.MENU_OFFSET and self.MENU_OFFSET.yOffset or 0

    self:OnLoad_Intrinsic()

    self.TriggerEvent = self.Fire

    self:SetScript('OnHide', self.OnHide)
    self:RegisterForMouse('LeftButtonUp', 'LeftButtonDown', 'RightButtonUp', 'RightButtonDown')
    self:RegisterForClicks('LeftButtonDown', 'RightButtonDown')

    self:SetCallback('OnMenuOpen', self.OnMenuOpen)
    self:SetCallback('OnMenuClose', self.OnMenuClose)
end

function MenuButton:OnHide()
    self:CloseMenu()
    self:UnregisterAllEvents()
end

function MenuButton:ToggleMenu()
    if self:IsMenuOpen() then
        self:CloseMenu()
    else
        self:InitMenu()
        self:OpenMenu()
    end
end

function MenuButton:CreateEnterBlocker()
    local EnterBlocker = CreateFrame('Frame', nil, self)
    EnterBlocker:Hide()
    EnterBlocker:SetScript('OnEnter', function(self)
        return self:GetParent():LockHighlight()
    end)
    EnterBlocker:SetScript('OnLeave', function(self)
        return self:GetParent():UnlockHighlight()
    end)
    -- EnterBlocker:SetMouseClickEnabled(false)
    MenuButton.EnterBlocker = EnterBlocker
    return EnterBlocker
end

function MenuButton:OnMenuOpen()
    local EnterBlocker = self.EnterBlocker or self:CreateEnterBlocker()
    EnterBlocker:SetParent(self)
    EnterBlocker:SetAllPoints(true)
    EnterBlocker:SetFrameLevel(self:GetFrameLevel() + 10)
    EnterBlocker:Show()
end

function MenuButton:OnMenuClose()
    if self.EnterBlocker then
        self.EnterBlocker:Hide()
    end
end

local function optTrue()
    return true
end
local nop = nop

local function GenerateGetter(v)
    if type(v) == 'function' then
        return v
    elseif v then
        return optTrue
    else
        return nop
    end
end

local function GenerateSetter(info)
    if not info.func then
        return nop
    end

    if not info.arg1 and not info.arg2 then
        return info.func
    end

    return function()
        return info.func(info.arg1, info.arg2)
    end
end

local function Generate(root, menuList)
    for _, v in ipairs(menuList) do
        local node
        if v.text == '' then
            node = root:CreateDivider()
        elseif v.isTitle then
            node = root:CreateTitle(v.text)
        elseif v.notCheckable then
            node = root:CreateButton(v.text, v.func)
        elseif v.isNotRadio then
            node = root:CreateCheckbox(v.text, GenerateGetter(v.checked), GenerateSetter(v))
        else
            node = root:CreateRadio(v.text, GenerateGetter(v.checked), GenerateSetter(v))
        end

        if v.hasArrow then
            Generate(node, v.menuList)
        end

        if v.tooltipTitle or v.tooltipText then
            node:SetTitleAndTextTooltip(v.tooltipTitle, v.tooltipText)
        end
    end
end

function MenuButton:InitMenu()
    if self.menuGenerator then
        return
    end

    self:SetupMenu(function(_, root)
        return Generate(root, self:CreateMenu())
    end)
end
