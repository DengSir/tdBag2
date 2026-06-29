-- Addon.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 12/24/2020, 3:37:48 PM
--
local Addon = tdBag2
if not Addon then
    return
end

if not Addon.RegisterPlugin then
    return print('You must update tdBag2 to use Zanza Coin')
end

local ITEMS = {
    [19698] = RED_FONT_COLOR,
    [19699] = RED_FONT_COLOR,
    [19700] = RED_FONT_COLOR,

    [19701] = GREEN_FONT_COLOR,
    [19702] = GREEN_FONT_COLOR,
    [19703] = GREEN_FONT_COLOR,

    [19704] = YELLOW_FONT_COLOR,
    [19705] = YELLOW_FONT_COLOR,
    [19706] = YELLOW_FONT_COLOR,
}

Addon:RegisterPlugin{
    type = 'Item',
    update = function(item)
        local color = ITEMS[item.info.id]
        if not color then
            if item.CoinFlag then
                item.CoinFlag:Hide()
            end
            return
        end

        if not item.CoinFlag then
            item.CoinFlag = item:CreateTexture(nil, 'OVERLAY', nil, 7)
            item.CoinFlag:SetPoint('TOPLEFT', -1, 0)
            item.CoinFlag:SetSize(30, 30)
            item.CoinFlag:SetTexture(131022)
        end

        item.CoinFlag:SetVertexColor(color:GetRGB())
        item.CoinFlag:Show()
    end,
}
