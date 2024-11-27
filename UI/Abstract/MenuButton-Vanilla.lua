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
        self:InitializeMenu()
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
    EnterBlocker:SetMouseClickEnabled(false)
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
    print(debugstack())
    if self.EnterBlocker then
        self.EnterBlocker:Hide()
    end
end

local function checked(v)
    if type(v) == 'function' then
        return v()
    else
        return function()
            return v
        end
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
            node = root:CreateCheckbox(v.text, checked(v.checked), v.func, v.value)
        else
            node = root:CreateRadio(v.text, checked(v.checked), v.func, v.value)
        end

        if v.hasArrow then
            Generate(node, v.menuList)
        end
    end
end

function MenuButton:InitializeMenu()
    if self.menuInited then
        return
    end
    self.menuInited = true
    self:SetupMenu(function(_, root)
        return Generate(root, self:CreateMenu())
    end)
end
