--[[
    © 2025 modular442 (Modular Content).
    Unauthorized copying or distribution is prohibited by law.
    Несанкционированное копирование или распространение запрещено законом. --]]

---@class Color
---@field r number @ Red component (0-255)
---@field g number @ Green component (0-255)
---@field b number @ Blue component (0-255)
---@field a number @ Alpha component (0-255), default is 255
local COLOR = {}
COLOR.__index = COLOR

---Safely converts a value to number or returns default if conversion fails
---@param val any @ The value to convert to number (can be string, number, etc.)
---@param default number @ The fallback number if conversion fails or is nil
---@return number @ A valid number, either converted or the fallback
local function SafeNumber(val, default)
    return tonumber(val) or default
end

---Clamps a value between 0 and 255, with default fallback
---@param val any
---@return number
local function ClampByte(val)
    local num = SafeNumber(val, 255)
    return math.min(math.max(num, 0), 255)
end

---Creates a new Color instance with clamped RGBA values
---@param r number|string? @ Red (0-255)
---@param g number|string? @ Green (0-255)
---@param b number|string? @ Blue (0-255)
---@param a number|string|nil? @ Alpha (0-255), defaults to 255
---@return Color
function Color(r, g, b, a)
    return setmetatable({
        r = ClampByte(r),
        g = ClampByte(g),
        b = ClampByte(b),
        a = ClampByte(a or 255),
    }, COLOR)
end

---Checks if the given object is a Color instance
---@param obj any @ Object to check
---@return boolean @ True if the object is a Color, false otherwise
function IsColor(obj)
    return type(obj) == 'table' and getmetatable(obj) == COLOR
end

---Converts a Color object to ANSI 24-bit foreground color escape code
---@param color Color @ The Color object to convert (must be a valid Color)
---@return string @ ANSI escape code string or `tostring(color)` fallback if not valid Color
function ToANSI(color)
    if not IsColor(color) then return tostring(color) end
    -- Alpha channel ignored in ANSI colors
    return string.format('\27[38;2;%d;%d;%dm', color.r, color.g, color.b)
end

---Converts a Color object to ANSI 24-bit background color escape code
---@param color Color @ The Color object to convert (must be a valid Color)
---@return string @ ANSI escape code string for background or fallback
function ToANSIBackground(color)
    if not IsColor(color) then return tostring(color) end
    -- Alpha channel ignored in ANSI colors
    return string.format('\27[48;2;%d;%d;%dm', color.r, color.g, color.b)
end

---Returns hex string representation of the color (ignores alpha)
---@param self Color
---@return string @ Hex string like '#FFA500'
function COLOR:ToHex()
    local r = math.floor(self.r + 0.5)
    local g = math.floor(self.g + 0.5)
    local b = math.floor(self.b + 0.5)
    return string.format('#%02X%02X%02X', r, g, b)
end

---Creates a Color object from hex string like '#FFA500' or '#FA0'
---@param hex string
---@return Color
function ColorFromHex(hex)
    if type(hex) ~= 'string' then return Color(255, 255, 255) end

    -- Try long format #RRGGBB
    local r, g, b = hex:match('#?(%x%x)(%x%x)(%x%x)')
    if r and g and b then
        return Color(tonumber(r, 16), tonumber(g, 16), tonumber(b, 16))
    end

    -- Try short format #RGB
    r, g, b = hex:match('#?(%x)(%x)(%x)')
    if r and g and b then
        r, g, b = tonumber(r .. r, 16), tonumber(g .. g, 16), tonumber(b .. b, 16)
        return Color(r, g, b)
    end

    -- Fallback to white
    return Color(255, 255, 255)
end

---Blend this color with another color by factor t (0-1)
---@param other Color
---@param t number @ Blend factor: 0 = this color, 1 = other color
---@return Color
function COLOR:Blend(other, t)
    t = math.min(math.max(t or 0, 0), 1)
    local r = self.r + (other.r - self.r) * t
    local g = self.g + (other.g - self.g) * t
    local b = self.b + (other.b - self.b) * t
    local a = self.a + (other.a - self.a) * t
    return Color(r, g, b, a)
end

---Inverts the color (ignoring alpha)
---@return Color
function COLOR:Invert()
    return Color(255 - self.r, 255 - self.g, 255 - self.b, self.a)
end

---Lightens the color by factor (0-1)
---@param factor number @ 0 = no change, 1 = white
---@return Color
function COLOR:Lighten(factor)
    factor = math.min(math.max(factor or 0, 0), 1)
    return self:Blend(Color(255, 255, 255, self.a), factor)
end

---Darkens the color by factor (0-1)
---@param factor number @ 0 = no change, 1 = black
---@return Color
function COLOR:Darken(factor)
    factor = math.min(math.max(factor or 0, 0), 1)
    return self:Blend(Color(0, 0, 0, self.a), factor)
end

---Returns color as an 'rgba(r, g, b, a)' string
---@return string
function COLOR:ToRGBAString()
    return string.format('rgba(%d, %d, %d, %d)', self.r, self.g, self.b, self.a)
end

---ANSI text styles supported by MsgC
local styles_codes = {
    reset     = '\27[0m',
    bold      = '\27[1m',
    dim       = '\27[2m',
    italic    = '\27[3m',
    underline = '\27[4m',
    blink     = '\27[5m',
    reverse   = '\27[7m',
    hidden    = '\27[8m',
}

---Generates ANSI codes from a styles table
---@param styles table? @ e.g. {bold=true, underline=true}
---@return string
local function ToANSIStyles(styles)
    if type(styles) ~= 'table' then return '' end
    local result = {}
    for k, v in pairs(styles) do
        if v and styles_codes[k] then
            table.insert(result, styles_codes[k])
        end
    end
    return table.concat(result)
end

---@return string @ ANSI escape code string that resets all applied text styles
function ResetANSI()
    return styles_codes.reset
end

---Enhanced MsgC that supports multiple colors and format strings in sequence
---@vararg any @ Accepts any number of Color/string/style/format/args in sequence
function MsgC(...)
    local args = {...}
    local output = {}
    local currentColor = ''
    local currentStyles = ''
    local reset = ResetANSI()

    local i = 1
    while i <= #args do
        local v = args[i]
        
        if IsColor(v) then
            currentColor = ToANSI(v)
            i = i + 1
        elseif type(v) == 'table' then
            currentStyles = ToANSIStyles(v)
            i = i + 1
        elseif type(v) == 'string' then
            -- Try to match format string
            local numSpecifiers = select(2, v:gsub('%%[^%%]', ''))
            local formatArgs = {}

            for j = 1, numSpecifiers do
                table.insert(formatArgs, args[i + j])
            end

            local formatted = (#formatArgs > 0) and string.format(v, table.unpack(formatArgs)) or v
            table.insert(output, currentColor..currentStyles..formatted..reset)

            i = i + 1 + #formatArgs
        else
            -- Fallback, just tostring()
            table.insert(output, currentColor..currentStyles..tostring(v)..reset)
            i = i + 1
        end
    end

    io.write(table.concat(output)..'\n')
end

return {
    Color = Color,
    IsColor = IsColor,
    ToANSI = ToANSI,
    ToANSIBackground = ToANSIBackground,
    ColorFromHex = ColorFromHex,
    MsgC = MsgC,
}