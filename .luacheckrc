std = 'lua51'

exclude_files = { --
    'Libs', 'Localization', '.index.lua', '.emmy',
}

ignore = {
    '212', -- Unused argument.
    '432', -- Shadowing an upvalue argument.
    '213', -- Unused loop variable.
    '542', -- An empty if branch.
    '631', -- Line is too long.
}

globals = {'LibStub', 'Enum', 'L'}
