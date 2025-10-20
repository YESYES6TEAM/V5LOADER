# ⚙️ V5 LOADER — Full Documentation

Author: ItsMrUpTime


---

# 🧾 Overview

V5 LOADER is a fully modular tool and system handler for Roblox local players.
It allows equipping, unequipping, activating tools, buying items, managing scripts, scanning the environment, and running advanced player-based functions.


---

# 📦 Loading the Library
```lua
local V5 = loadstring(game:HttpGet('https://raw.githubusercontent.com/YESYES6TEAM/V5LOADER/refs/heads/main/Source.lua'))()
```

---

# ⚔️ 1. Tool Functions

V5:equip(toolName)

Moves a tool from the player’s Backpack into their Character.
```lua
local ok, err = V5:equip("Medusa's Head")
if not ok then
    warn("Equip failed:", err)
end
```

---

V5:unequip(toolName)

Moves a tool from Character to Backpack.
```lua
V5:unequip("Medusa's Head")
```

---

V5:activate(toolName)

Activates a tool manually (like clicking it).
```lua
V5:activate("Quantum Cloner")
```

---

V5:getToolList()

Returns all tools found in the Backpack and Character.
```lua
for _, name in ipairs(V5:getToolList()) do
    print("Found tool:", name)
end
```

---

V5:hasTool(toolName)

Checks if a player has a specific tool.
```lua
if V5:hasTool("Medusa's Head") then
    print("Player owns Medusa's Head!")
end
```

---

V5:autoEquip(toolNames)

Automatically equips tools from a list when available.
```lua
V5:autoEquip({"Quantum Cloner", "Medusa's Head"})
```

---

V5:massActivate(toolNames)

Activates multiple tools one by one.
```lua
V5:massActivate({"Quantum Cloner", "Medusa's Head"})
```

---

V5:loopActivate(toolName, times, delay)

Repeatedly activates a tool with delay between uses.
```lua
V5:loopActivate("Quantum Cloner", 5, 0.3)
```

---

# 🌐 2. Script Loading

V5:load(url)

Fetches and executes a remote script.
```lua
local ok, err = V5:load("https://raw.githubusercontent.com/User/Repo/main/script.lua")
if not ok then
    warn("Load failed:", err)
end
```

---

V5:secureLoad(url)

Loads a remote script but checks syntax and wraps in a safe sandbox.
```lua
V5:secureLoad("https://raw.githubusercontent.com/User/ScriptHub/main/utility.lua")
```

---

# 👥 3. Player Interaction

V5:getNearestPlayer(radius)

Finds the closest player to you.
```lua
local player = V5:getNearestPlayer(40)
if player then
    print("Nearest player:", player.Name)
end
```

---

V5:teleportToPlayer(name)

Instantly teleports to another player.
```lua
V5:teleportToPlayer("Player123")
```

---

V5:followPlayer(name, speed)

Follows a player automatically.
```lua
V5:followPlayer("Player123", 10)
```

---

V5:trackPlayer(name)

Prints position logs as the target moves.
```lua
V5:trackPlayer("Player123")
```

---

# 🌍 4. World & Environment

V5:removeModelByName(keyword)

Deletes all models containing a word.
```lua
V5:removeModelByName("door")
```

---

V5:deleteDoors()

Shortcut for removing every door model.
```lua
V5:deleteDoors()
```

---

V5:highlightTeamPlayers()

Highlights everyone using their team color.
```lua
V5:highlightTeamPlayers()
```

---

V5:wallCheck()

Checks if your body is close to a wall.
```lua
if V5:wallCheck() then
    print("Wall detected nearby!")
end
```

---

V5:lightingModifier(preset)

Changes lighting to various presets.
```lua
V5:lightingModifier("Night")   -- Dark mode
V5:lightingModifier("Bright")  -- Full daylight
V5:lightingModifier("Foggy")   -- Fog world
```

---

# 🧠 5. System Utilities

V5:autoBuy(itemName)

Automatically buys a shop item.
```lua
V5:autoBuy("Quantum Cloner")
```

---

V5:autoRejoin()

Instantly rejoins the same server if disconnected.
```lua
V5:autoRejoin()
```

---

V5:fpsUnlocker(limit)

Attempts to raise your FPS limit (client-side only).
```lua
V5:fpsUnlocker(240)
```

---

V5:systemInfo()

Returns server data like FPS, Ping, and JobID.
```lua
local info = V5:systemInfo()
print("FPS:", info.FPS)
print("Ping:", info.Ping)
print("JobID:", info.JobID)
````

---

V5:logActions(enable)

Logs every V5 action in output.
```lua
V5:logActions(true)
```

---

V5:saveState() & V5:loadState()

Saves tools and position, then restores them.
```lua
V5:saveState()
wait(2)
V5:loadState()
```

---

# 🧩 6. Misc & Debug

V5:dumpPlayerData()

Prints all known player and tool info.
```lua
V5:dumpPlayerData()
```

---

V5:checkGameIntegrity()

Scans for missing or broken objects.
```lua
V5:checkGameIntegrity()
```

---

V5:antiAFK()

Prevents Roblox’s AFK timeout.
```lua
V5:antiAFK()
```

---

V5:notify(text)

Displays a console message.
```lua
V5:notify("Medusa's Head Equipped!")
```

---

V5:credits()

Shows info about the library and author.
```lua
V5:credits()
```
Output Example:

V5 Loader v5.3
Author: ItsMrUpTime
Modules Loaded: 38
All systems functional.


---

# 🔁 Usage Pattern Example
```lua
V5:autoBuy("Quantum Cloner")
wait(0.3)
V5:equip("Quantum Cloner")
wait(0.2)
V5:activate("Quantum Cloner")
V5:unequip("Quantum Cloner")
```

---

# 🪶 Changelog

v1.0: Equip / Unequip

v2.0: Activate / Load

v3.0: Environment Tools

v4.0: Player & Tracking

v5.0: Secure Loader & AntiAFK

v5.3: Major system overhaul by ItsMrUpTime

# Tips

Auto-equip tools before activation for convenience.

Only load trusted remote scripts; V5:load runs arbitrary code.

Use consistent tool names (case-sensitive) to avoid errors.

Wait briefly after equipping tools before activating them if needed.



---

# Changelog

v1 — Added equip and unequip.

v2 — Added activate.

v3 — Added load with HttpGet and error handling.
