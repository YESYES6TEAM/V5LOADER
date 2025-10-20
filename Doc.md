V5 LOADER — Documentation

Overview

V5 LOADER is a lightweight tool management and script-loading system for Roblox local players. It allows you to equip, unequip, activate tools, and load remote Lua scripts easily.


---

API Reference

1. V5:equip(toolName : string) -> (boolean, string?)

Moves a tool from the player’s Backpack into the Character and equips it.

Example:

local ok, err = V5:equip("Medusa's Head")
if not ok then
    warn("Equip failed:", err)
end

Notes:

Tool must exist in the Backpack.

Requires a Humanoid in the character.



---

2. V5:unequip(toolName : string) -> (boolean, string?)

Moves a tool from the Character back to the Backpack.

Example:

V5:unequip("Medusa's Head")

Notes:

Tool must be in the Character.

Returns an error if the tool is not found.



---

3. V5:activate(toolName : string) -> (boolean, string?)

Activates a tool, simulating the player clicking with it.

Example:

V5:activate("Medusa's Head")

Notes:

Tool must be in the Character.

Only works for tools that implement the Activated event.



---

4. V5:load(rawLink : string) -> (boolean, string?)

Fetches a Lua script from a raw URL and runs it safely.

Example:

local ok, err = V5:load("https://raw.githubusercontent.com/You/Repo/main/script.lua")
if not ok then
    warn("Load failed:", err)
end

Notes:

Requires the execution environment to support game:HttpGet.

Runs the script safely inside pcall to catch runtime errors.

Attempts a simple wrapper if the script fails to compile.



---

Usage Patterns

Equip → Activate → Unequip

V5:equip("Quantum Cloner")
wait(0.1)
V5:activate("Quantum Cloner")
wait(0.2)
V5:unequip("Quantum Cloner")

Load and run a remote script

local ok, err = V5:load("https://raw.githubusercontent.com/You/Repo/main/toolScript.lua")
if not ok then
    warn(err)
end


---

Common Errors

Tool not found in Backpack — The tool isn’t in the Backpack or the name is incorrect.

Humanoid not found — Character hasn’t loaded yet or doesn’t have a Humanoid.

Tool cannot be activated — Tool doesn’t implement Activated.

Failed to fetch script — Environment may not allow HttpGet or URL is invalid.

Failed to compile script — Script contains syntax errors. V5 tries a simple wrapper, but complex errors must be fixed in the source.



---

Tips

Auto-equip tools before activation for convenience.

Only load trusted remote scripts; V5:load runs arbitrary code.

Use consistent tool names (case-sensitive) to avoid errors.

Wait briefly after equipping tools before activating them if needed.



---

Changelog

v1 — Added equip and unequip.

v2 — Added activate.

v3 — Added load with HttpGet and error handling.
