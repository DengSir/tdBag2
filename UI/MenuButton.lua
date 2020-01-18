-- MenuButton.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 11/29/2019, 2:59:16 PM

---- LUA
local _G = _G
local pairs = pairs

---- WOW
local CreateFrame = CreateFrame
local PlaySound = PlaySound
local CloseDropDownMenus = CloseDropDownMenus
local ToggleDropDownMenu = ToggleDropDownMenu
local EasyMenu_Initialize = EasyMenu_Initialize

---- UI
local DropDownList1 = DropDownList1
local UIParent = UIParent

---@type ns
local ns = select(2, ...)

---@class tdBag2MenuButton: Button
---@field private EnterBlocker Frame
local MenuButton = ns.Addon:NewClass('UI.MenuButton', 'Button')
MenuButton.GenerateName = ns.NameGenerator('tdBag2DropMenu')

function MenuButton:ToggleMenu()
    if self:IsMenuOpened() then
        CloseDropDownMenus()
        PlaySound(851) -- IG_MAINMENU_CLOSE
    else
        MenuButton.LastDropdown = self
        CloseDropDownMenus()
        ToggleDropDownMenu(1, nil, self:GetDropMenu(), self, 0, 0, self:CreateMenu())
        self:OnMenuOpened()
        PlaySound(850) -- IG_MAINMENU_OPEN
    end
end

function MenuButton:CloseMenu()
    if self:IsMenuOpened() then
        CloseDropDownMenus(1)
    end
end

function MenuButton:IsMenuOpened()
    return self.DropMenu and self.LastDropdown == self and _G.UIDROPDOWNMENU_OPEN_MENU == self.DropMenu and
               DropDownList1:IsShown()
end

function MenuButton:GetDropMenu()
    if not self.DropMenu then
        local frame = CreateFrame('Frame', self:GenerateName(), UIParent, 'UIDropDownMenuTemplate')
        frame.displayMode = 'MENU'
        frame.initialize = EasyMenu_Initialize
        frame.onHide = function(id)
            if id <= 2 then
                self:OnMenuClosed()
            end
        end

        if self.menuOffset then
            for k, v in pairs(self.menuOffset) do
                frame[k] = v
            end
        end

        self:GetType().DropMenu = frame
    end
    return self.DropMenu
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

function MenuButton:OnMenuOpened()
    local EnterBlocker = self.EnterBlocker or self:CreateEnterBlocker()
    EnterBlocker:SetParent(self)
    EnterBlocker:SetAllPoints(true)
    EnterBlocker:SetFrameLevel(self:GetFrameLevel() + 10)
    EnterBlocker:Show()
end

function MenuButton:OnMenuClosed()
    if self.EnterBlocker then
        self.EnterBlocker:Hide()
    end
end
