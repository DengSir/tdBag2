-- GlobalSearchContainer.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 2/11/2020, 2:54:54 PM

---@type ns
local ns = select(2, ...)

---@class tdBag2GlobalSearchContainer: tdBag2TitleContainer
local GlobalSearchContainer = ns.Addon:NewClass('UI.GlobalSearchContainer', ns.UI.TitleContainer)

function GlobalSearchContainer:Constructor()
    self.alwaysShowTitle = true
end

function GlobalSearchContainer:GetBags()
    return ns.GlobalSearch:GetBags()
end
