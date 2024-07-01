read_globals = (function()
    local e = {}
    local f = loadfile('default.luacheckrc', 't', e)
    if not f then return end
    if setfenv then setfenv(f, e) end
    f()
    return e.read_globals
end)()


std = 'lua51'

exclude_files = { --
    '**/Libs', '**/Localization', '.index.lua', '.emmy',
}

ignore = {
    -- '212', -- Unused argument.
    -- '432', -- Shadowing an upvalue argument.
    '213/i', -- Unused loop variable.
    '213/k', -- Unused loop variable.
    '213/v', -- Unused loop variable.
    '542', -- An empty if branch.
    '631', -- Line is too long.

    '11./SLASH_.*', -- Setting an undefined (Slash handler) global variable
    '11./BINDING_.*', -- Setting an undefined (Keybinding header) global variable
    -- "113/LE_.*", -- Accessing an undefined (Lua ENUM type) global variable
    -- "113/NUM_LE_.*", -- Accessing an undefined (Lua ENUM type) global variable
    '122/StaticPopupDialogs', -- Setting a read-only field of a global variable "StaticPopupDialogs"
    -- "211", -- Unused local variable
    -- "212", -- Unused argument
    '212/self', -- Unused argument "self"
    -- "213", -- Unused loop variable
    -- "231", -- Set but never accessed
    -- "311", -- Value assigned to a local variable is unused
    -- "314", -- Value of a field in a table literal is unused
    '42.', -- Shadowing a local variable, an argument, a loop variable.
    '43.', -- Shadowing an upvalue, an upvalue argument, an upvalue loop variable.
}

globals = {
    'C_Engraving',
    'GetCraftItemLink',
    'GetCraftReagentItemLink',
    'CursorCanGoInSlot',
    'PutKeyInKeyRing',
    'HasKey',
    'MAX_WATCHED_TOKENS',
    'MAX_CONTAINER_ITEMS',
    'ContainerFrame_UpdateCooldown',
    'LE_ITEM_QUALITY_COMMON',
}
