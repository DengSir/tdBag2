-- PluginFrame.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 1/4/2020, 1:18:14 AM

---@type ns
local ns = select(2, ...)

---@class tdBag2PluginFrame: Frame
---@field meta tdBag2FrameMeta
---@field menuButtons Button[]
---@field pluginButtons table<string, Button>
local PluginFrame = ns.Addon:NewClass('UI.PluginFrame', 'Frame')

function PluginFrame:Constructor(_, meta)
    self.meta = meta
    self.menuButtons = {}
    self.pluginButtons = {}
end

function PluginFrame:Update()
    local menuButtons = self.menuButtons

    for _, button in ipairs(self.menuButtons) do
        button:Hide()
    end

    wipe(menuButtons)

    for _, plugin in ns.Addon:IteratePluginButtons() do
        if not self.meta.profile.disableButtons[plugin.key] then
            tinsert(menuButtons, self.pluginButtons[plugin.key] or self:CreatePluginButton(plugin))
        end
    end

    for i, button in ipairs(menuButtons) do
        button:ClearAllPoints()
        button:SetPoint('RIGHT', -(i - 1) * (button:GetWidth() + 3), 0)
        button:Show()
    end

    self:SetWidth(#menuButtons == 0 and 1 or #menuButtons * (menuButtons[1]:GetWidth() + 3) + 1)
end

function PluginFrame:CreatePluginButton(plugin)
    local button = CreateFrame('CheckButton', nil, self, 'tdBag2ToggleButtonTemplate')
    button.texture:SetTexture(plugin.icon)
    plugin.init(button, self)
    self.pluginButtons[plugin.key] = button
    return button
end
