# ModularColor (English README)

> 🎨 Modular color library for Lua — clean RGBA goodness!
>
> Author: **modular442** — head honcho of Modular Content
>
> 🚀 Plug in, write colorful code, live boldly!

---

## What is it?

**ModularColor** is a sleek and handy Lua color library.
Forget about painful RGBA, hex, and ANSI conversions — here it’s clean, simple, and powerful.

* Create colors safely with clamped RGBA values
* Convert colors to hex, rgba strings, and ANSI codes for terminals
* Blend, invert, lighten, and darken colors easily
* Print colored and styled text to the console using ANSI escape sequences

> [!NOTE]
> The library works fully in pure Lua and requires no external dependencies.

> [!TIP]
> Use `Color:Blend` with a factor `t` between 0 and 1 to smoothly transition between two colors.

---

## Installation

Just copy `colorlib.lua` into your project and require it:

```lua
require('colorlib')
```

> [!IMPORTANT]
> Make sure your project includes this file before using any of the library functions.

---

## Quick start

```lua
local red = Color(255, 0, 0)
local semiTransparentBlue = Color(0, 0, 255, 128)

print(red:ToHex()) -- #FF0000
print(semiTransparentBlue:ToRGBAString()) -- rgba(0, 0, 255, 128)

local blended = red:Blend(Color(0, 255, 0), 0.5)
print(blended:ToHex()) -- mixture of red and green

-- Colored console output:
MsgC(red, {bold=true}, 'Bold red text!')
MsgC(red, 'Red text without %s!', 'styles')

-- Parse from hex string
local colorFromHex = ColorFromHex('#1E90FF')
print(colorFromHex:ToRGBAString())
```

> \[!TIP]
> Use `MsgC` for quick and easy colored console output. Supported styles include:
> `{bold=true}`, `{dim=true}`, `{italic=true}`, `{underline=true}`, `{blink=true}`, `{reverse=true}`, `{hidden=true}`.

---

## Functions and methods

* `Color(r, g, b, a)` — creates a color with clamped RGBA
* `ColorFromHex(hex)` — parses color from hex string
* `Color:ToHex()` — returns hex color code
* `Color:ToRGBAString()` — returns `'rgba(r, g, b, a)'` string
* `Color:Blend(otherColor, t)` — blends two colors by factor t
* `Color:Invert()` — inverts color
* `Color:Lighten(factor)` and `Color:Darken(factor)` — lighten or darken color
* `MsgC(color, styles, text, ...)` — print colored & styled text (ANSI)

> [!CAUTION]
> Console coloring with `MsgC` may not work correctly on all terminals, especially on Windows CMD without ANSI support enabled.

---

## Contribution & Feedback

We welcome your suggestions and fixes!  
PRs are accepted **only if they**:

- add new useful features,  
- include documentation in LuaLS format,  
- do not break backward compatibility.

> [!NOTE]
> Please run all tests and keep consistent code style when submitting PRs.

---

## License

© 2025 modular442 (Modular Content).
All rights reserved. No unauthorized copying or redistribution.