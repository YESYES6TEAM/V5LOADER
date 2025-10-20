local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local VirtualUser = game:GetService("VirtualUser")
local MarketplaceService = game:GetService("MarketplaceService")
local HttpService = HttpService
local V5 = {}
V5.__index = V5
V5.version = "7.0"
V5.author = "ItsMrUpTime"
local SETTINGS_FILE = "V5_Settings.json"
local SCRIPTS_CACHE = "V5_ScriptsCache.json"
local INTERNAL = {}
INTERNAL._connections = {}
INTERNAL._toggles = {}
INTERNAL._cache = {}
INTERNAL._highlighted = {}
INTERNAL._esp = {}
INTERNAL._aim = {}
INTERNAL._monitor = {}
INTERNAL._threads = {}
INTERNAL._data = {}
INTERNAL._remotes = {}
function V5:log(msg)
	local t = os.date("%X")
	print(string.format("[V5 | %s] %s", t, tostring(msg)))
end
function V5:notify(title, text, dur)
	pcall(function()
		StarterGui:SetCore("SendNotification", {
			Title = title or "V5 Loader";
			Text = text or "Done.";
			Duration = dur or 3;
		})
	end)
end
function V5:_safeCall(f,...)
	local ok, res = pcall(f,...)
	if not ok then
		self:log("Error: "..tostring(res))
		return false, res
	end
	return true, res
end
function V5:saveSetting(data)
	if writefile then
		pcall(function()
			writefile(SETTINGS_FILE, HttpService:JSONEncode(data or {}))
		end)
		self:log("Settings saved")
		return true
	else
		self:log("writefile not supported")
		return false
	end
end
function V5:loadSetting()
	if isfile and isfile(SETTINGS_FILE) then
		local ok,data = pcall(function() return HttpService:JSONDecode(readfile(SETTINGS_FILE)) end)
		if ok then
			self:log("Settings loaded")
			return data
		else
			self:log("Failed to decode settings")
			return {}
		end
	else
		self:log("No settings file")
		return {}
	end
end
function V5:saveScriptCache(tbl)
	if writefile then
		pcall(function()
			writefile(SCRIPTS_CACHE, HttpService:JSONEncode(tbl or {}))
		end)
		self:log("Script cache saved")
		return true
	else
		return false
	end
end
function V5:loadScriptCache()
	if isfile and isfile(SCRIPTS_CACHE) then
		local ok,data = pcall(function() return HttpService:JSONDecode(readfile(SCRIPTS_CACHE)) end)
		if ok then
			self:log("Script cache loaded")
			return data
		else
			return {}
		end
	else
		return {}
	end
end
function V5:registerRemote(name, instance)
	INTERNAL._remotes[name] = instance
	return instance
end
function V5:getRemote(name)
	return INTERNAL._remotes[name]
end
function V5:invokeRemote(name,...)
	local r = INTERNAL._remotes[name]
	if not r then return false,"Remote not registered" end
	local ok,res = pcall(function() return r:InvokeServer(...) end)
	if not ok then return false,res end
	return true,res
end
function V5:fireRemote(name,...)
	local r = INTERNAL._remotes[name]
	if not r then return false,"Remote not registered" end
	local ok,res = pcall(function() r:FireServer(...) end)
	if not ok then return false,res end
	return true
end
function V5:load(rawLink)
	local ok, scriptText = pcall(function()
		return game:HttpGet(tostring(rawLink))
	end)
	if not ok then
		return false, "Failed to fetch script: "..tostring(scriptText)
	end
	local func, err = loadstring(scriptText)
	if not func then
		local fixedFunc = loadstring("return function()\n"..scriptText.."\nend")
		if fixedFunc then
			func = fixedFunc()
		else
			return false, "Failed to compile script: "..tostring(err)
		end
	end
	local ok2, runErr = pcall(func)
	if not ok2 then
		return false, "Script runtime error: "..tostring(runErr)
	end
	self:log("Loaded "..tostring(rawLink))
	return true
end
function V5:loadMultiple(rawLinks)
	for _, link in ipairs(rawLinks) do
		local ok, err = self:load(link)
		if not ok then
			self:log("Load failed: "..tostring(err))
		end
	end
end
function V5:executeString(src)
	local f, e = loadstring(src)
	if not f then
		return false, e
	end
	local s, r = pcall(f)
	if not s then
		return false, r
	end
	return true, r
end
function V5:executeInSandbox(src, env)
	env = env or {}
	local base = {}
	for k,v in pairs(_G) do base[k]=v end
	for k,v in pairs(env) do base[k]=v end
	local f, e = loadstring("return function() "..src.." end")
	if not f then return false, e end
	local func = f()
	setfenv(func, base)
	local ok, res = pcall(func)
	if not ok then return false, res end
	return true, res
end
function V5:findTool(toolName)
	local p = Players.LocalPlayer
	if not p then return end
	local b = p:FindFirstChild("Backpack")
	local c = p.Character
	if b then
		local t = b:FindFirstChild(toolName)
		if t then return t end
	end
	if c then
		local t2 = c:FindFirstChild(toolName)
		if t2 then return t2 end
	end
	return nil
end
function V5:equip(toolName)
	local p = Players.LocalPlayer
	if not p then return false,"No Player" end
	local c = p.Character or p.CharacterAdded:Wait()
	local b = p:WaitForChild("Backpack")
	local tool = b:FindFirstChild(toolName)
	if not tool then return false, "Tool not found" end
	tool.Parent = c
	local humanoid = c:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid:EquipTool(tool)
	end
	self:log("Equipped: "..tostring(toolName))
	return true
end
function V5:unequip(toolName)
	local p = Players.LocalPlayer
	local c = p.Character
	local b = p:WaitForChild("Backpack")
	if not c then return false, "No character" end
	local tool = c:FindFirstChild(toolName)
	if not tool then return false, "Tool not found" end
	tool.Parent = b
	self:log("Unequipped: "..tostring(toolName))
	return true
end
function V5:activate(toolName)
	local p = Players.LocalPlayer
	local c = p.Character
	if not c then return false,"No character" end
	local tool = c:FindFirstChild(toolName)
	if not tool then return false,"Tool not found" end
	if tool:IsA("Tool") or tool:FindFirstChild("Handle") then
		if tool.Activate then
			pcall(function() tool:Activate() end)
		else
			if tool:FindFirstChild("Handle") then
				pcall(function()
					local ev = tool:FindFirstChildOfClass("RemoteEvent")
					if ev then ev:FireServer() end
				end)
			end
		end
		self:log("Activated: "..toolName)
		return true
	else
		return false,"Cannot activate"
	end
end
function V5:autoEquipOnJoin(toolName)
	local p = Players.LocalPlayer
	if not p then return false,"No player" end
	p.CharacterAdded:Connect(function()
		task.wait(1.5)
		self:equip(toolName)
	end)
	return true
end
function V5:loopEquip(toolName, interval)
	interval = interval or 2
	local t = task.spawn(function()
		while task.wait(interval) do
			local tool = self:findTool(toolName)
			if tool and tool.Parent == Players.LocalPlayer.Backpack then
				pcall(function() self:equip(toolName) end)
			end
		end
	end)
	table.insert(INTERNAL._threads, t)
	return t
end
function V5:antiAFK(enable)
	enable = enable == nil and true or enable
	if not enable then return false end
	local p = Players.LocalPlayer
	if not p then return false end
	p.Idled:Connect(function()
		VirtualUser:Button2Down(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
		task.wait(1)
		VirtualUser:Button2Up(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
	end)
	self:log("Anti-AFK enabled")
	return true
end
function V5:rejoin()
	TeleportService:Teleport(game.PlaceId, Players.LocalPlayer)
end
function V5:serverHop()
	local servers = {}
	local ok, req = pcall(function()
		return game:HttpGet(string.format("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Desc&limit=100", game.PlaceId))
	end)
	if not ok then return false, "HttpGet failed" end
	local decoded = HttpService:JSONDecode(req)
	if decoded and decoded.data then
		for _, s in ipairs(decoded.data) do
			if s.playing < s.maxPlayers then
				table.insert(servers, s.id)
			end
		end
	end
	if #servers > 0 then
		TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1,#servers)], Players.LocalPlayer)
		return true
	end
	return false,"No server found"
end
function V5:teleportToVector(v3)
	local p = Players.LocalPlayer
	if not p or not p.Character then return false,"No char" end
	local hrp = p.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return false,"No HRP" end
	hrp.CFrame = CFrame.new(v3)
	self:log("Teleported to vector")
	return true
end
function V5:teleportToPart(part)
	if not part or not part:IsA("BasePart") then return false,"Invalid part" end
	local p = Players.LocalPlayer
	if not p or not p.Character then return false,"No char" end
	local hrp = p.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return false,"No HRP" end
	hrp.CFrame = part.CFrame + Vector3.new(0,3,0)
	self:log("Teleported to part")
	return true
end
function V5:teleportToPlayer(targetPlayer)
	if typeof(targetPlayer) == "string" then
		targetPlayer = Players:FindFirstChild(targetPlayer)
	end
	if not targetPlayer or not targetPlayer.Character then return false,"Target missing" end
	return self:teleportToPart(targetPlayer.Character:FindFirstChild("HumanoidRootPart"))
end
function V5:flingPlayer(targetPlayer, power)
	if typeof(targetPlayer) == "string" then
		targetPlayer = Players:FindFirstChild(targetPlayer)
	end
	if not targetPlayer or not targetPlayer.Character then return false,"Target missing" end
	local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
	local p = Players.LocalPlayer
	if not p or not p.Character then return false,"No char" end
	local hrp = p.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return false,"No HRP" end
	pcall(function()
		local bv = Instance.new("BodyVelocity")
		bv.MaxForce = Vector3.new(1e6,1e6,1e6)
		bv.Velocity = (targetHRP.Position - hrp.Position).unit * (power or 200)
		bv.Parent = hrp
		task.delay(0.2, function() bv:Destroy() end)
	end)
	return true
end
function V5:collectTouchGivers(waitBack)
	waitBack = waitBack or 0.5
	local found = {}
	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj:IsA("BasePart") and obj.Name:lower():find("touchgiver") then
			table.insert(found, obj)
		end
	end
	for _, part in ipairs(found) do
		local ok = pcall(function()
			local p = Players.LocalPlayer
			local hrp = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
			if hrp then
				local old = hrp.CFrame
				hrp.CFrame = part.CFrame + Vector3.new(0,3,0)
				task.wait(waitBack)
				hrp.CFrame = old
			end
		end)
		if not ok then
			self:log("Failed touching "..tostring(part))
		end
	end
	return #found
end
function V5:deleteModelsContaining(substr)
	for _, m in ipairs(Workspace:GetDescendants()) do
		if m:IsA("Model") and m.Name:lower():find(substr:lower()) then
			pcall(function() m:Destroy() end)
		end
	end
	return true
end
function V5:deletePartsContaining(substr)
	for _, p in ipairs(Workspace:GetDescendants()) do
		if p:IsA("BasePart") and p.Name:lower():find(substr:lower()) then
			pcall(function() p:Destroy() end)
		end
	end
	return true
end
function V5:copyTeamsToArray()
	local arr = {}
	for _, team in ipairs(game:GetService("Teams"):GetTeams()) do
		table.insert(arr, team.Name)
	end
	return arr
end
function V5:setClipboard(text)
	if setclipboard then
		pcall(function() setclipboard(tostring(text)) end)
		return true
	else
		return false,"Clipboard unsupported"
	end
end
function V5:getNearestPlayersList(range, maxCount)
	range = range or 50
	maxCount = maxCount or 10
	local p = Players.LocalPlayer
	if not p or not p.Character then return {} end
	local hrp = p.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return {} end
	local list = {}
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= p and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
			local d = (plr.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
			if d <= range then
				table.insert(list, {player=plr,dist=d})
			end
		end
	end
	table.sort(list, function(a,b) return a.dist < b.dist end)
	if #list > maxCount then
		for i = #list, maxCount+1, -1 do table.remove(list,i) end
	end
	return list
end
function V5:highlightPlayerParts(plr, color, duration)
	if not plr or not plr.Character then return false end
	color = color or Color3.fromRGB(0,255,0)
	local t = {}
	for _, part in ipairs(plr.Character:GetChildren()) do
		if part:IsA("BasePart") then
			local h = Instance.new("Highlight")
			h.Adornee = part
			h.FillColor = color
			h.OutlineTransparency = 0
			h.Parent = part
			table.insert(t,h)
		end
	end
	if duration and type(duration)=="number" then
		task.delay(duration, function()
			for _, hh in ipairs(t) do
				pcall(function() hh:Destroy() end)
			end
		end)
	end
	return t
end
function V5:removeAllHighlights()
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr.Character then
			for _, obj in ipairs(plr.Character:GetDescendants()) do
				if obj:IsA("Highlight") then
					pcall(function() obj:Destroy() end)
				end
			end
		end
	end
end
function V5:createPartAt(pos,size,anchored,parent)
	local p = Instance.new("Part")
	p.Size = size or Vector3.new(2,2,2)
	p.Position = pos or Vector3.new(0,5,0)
	p.Anchored = anchored == nil and true or anchored
	p.Parent = parent or Workspace
	return p
end
function V5:spawnModelFromAsset(assetId, pos)
	local ok, model = pcall(function()
		return game:GetObjects("rbxassetid://"..tostring(assetId))[1]
	end)
	if ok and model then
		model:SetPrimaryPartCFrame(CFrame.new(pos or Vector3.new(0,5,0)))
		model.Parent = Workspace
		return true, model
	end
	return false,"Failed"
end
function V5:toggleNoclip(enable)
	enable = enable == nil and true or enable
	if enable then
		local con = RunService.Stepped:Connect(function()
			local p = Players.LocalPlayer
			if p and p.Character then
				for _, part in ipairs(p.Character:GetDescendants()) do
					if part:IsA("BasePart") and part.CanCollide then
						part.CanCollide = false
					end
				end
			end
		end)
		table.insert(INTERNAL._connections, con)
		INTERNAL._toggles.noclip = con
		return true
	else
		local con = INTERNAL._toggles.noclip
		if con then
			con:Disconnect()
			INTERNAL._toggles.noclip = nil
		end
		return true
	end
end
function V5:setWalkSpeed(speed)
	local p = Players.LocalPlayer
	if not p or not p.Character then return false end
	local humanoid = p.Character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.WalkSpeed = speed or 16
		return true
	end
	return false
end
function V5:setJumpPower(jump)
	local p = Players.LocalPlayer
	if not p or not p.Character then return false end
	local humanoid = p.Character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.JumpPower = jump or 50
		return true
	end
	return false
end
function V5:freezeCharacter(enable)
	local p = Players.LocalPlayer
	if not p or not p.Character then return false end
	local hrp = p.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return false end
	if enable then
		local bv = Instance.new("BodyVelocity")
		bv.MaxForce = Vector3.new(1e9,1e9,1e9)
		bv.Velocity = Vector3.new(0,0,0)
		bv.Parent = hrp
		INTERNAL._toggles.freeze = bv
		return true
	else
		if INTERNAL._toggles.freeze then
			INTERNAL._toggles.freeze:Destroy()
			INTERNAL._toggles.freeze = nil
		end
		return true
	end
end
function V5:unanchorWorldParts(limit)
	limit = limit or math.huge
	local count = 0
	for _, p in ipairs(Workspace:GetDescendants()) do
		if p:IsA("BasePart") and p.Anchored then
			if count >= limit then break end
			p.Anchored = false
			count = count + 1
		end
	end
	return count
end
function V5:anchorWorldParts(limit)
	limit = limit or math.huge
	local count = 0
	for _, p in ipairs(Workspace:GetDescendants()) do
		if p:IsA("BasePart") and not p.Anchored then
			if count >= limit then break end
			p.Anchored = true
			count = count + 1
		end
	end
	return count
end
function V5:setLighting(property, value)
	if Lighting[property] ~= nil then
		Lighting[property] = value
		return true
	else
		return false
	end
end
function V5:teleportToSpawn()
	local sp = Workspace:FindFirstChild("SpawnLocation") or Workspace:FindFirstChildWhichIsA("SpawnLocation")
	if sp then
		return self:teleportToPart(sp)
	end
	return false,"No spawn"
end
function V5:createBindableCommand(name, func)
	local bind = Instance.new("BindableFunction")
	bind.Name = tostring(name)
	bind.OnInvoke = func
	bind.Parent = CoreGui
	return bind
end
function V5:runBindable(name, ...)
	local obj = CoreGui:FindFirstChild(tostring(name))
	if obj and obj:IsA("BindableFunction") then
		local ok, res = pcall(function() return obj:Invoke(...) end)
		if ok then return true,res else return false,res end
	end
	return false,"Not found"
end
function V5:watchForTool(toolName, callback)
	local p = Players.LocalPlayer
	if not p then return end
	local function check()
		local b = p:FindFirstChild("Backpack")
		if b and b:FindFirstChild(toolName) then
			pcall(function() callback(b:FindFirstChild(toolName)) end)
		end
	end
	local con = RunService.Heartbeat:Connect(check)
	table.insert(INTERNAL._connections, con)
	return con
end
function V5:getServerPing()
	local start = tick()
	local ok, _ = pcall(function() game:GetService("Stats"):GetTotalMemoryUsageMb() end)
	local diff = (tick() - start) * 1000
	return diff
end
function V5:copyModel(model, parent)
	if not model then return false end
	local clone = model:Clone()
	clone.Parent = parent or Workspace
	return clone
end
function V5:copyPartsByName(name)
	local t = {}
	for _, p in ipairs(Workspace:GetDescendants()) do
		if p:IsA("BasePart") and p.Name:lower():find(name:lower()) then
			table.insert(t, p:Clone())
		end
	end
	return t
end
function V5:teleportAllPlayersToPart(part)
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
			pcall(function()
				plr.Character.HumanoidRootPart.CFrame = part.CFrame + Vector3.new(0,3,0)
			end)
		end
	end
	return true
end
function V5:sendToServerConsole(text)
	self:log("Console: "..tostring(text))
end
function V5:patchHttpGet(enable)
	enable = enable == nil and true or enable
	if enable then
		if not INTERNAL._patchedHttp then
			INTERNAL._patchedHttp = true
			local old = game.HttpGet
			game.HttpGet = function(...)
				local args = {...}
				return old(...)
			end
			return true
		end
	else
		return false
	end
end
function V5:getPlayersByTeam(teamName)
	local arr = {}
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr.Team and plr.Team.Name == teamName then
			table.insert(arr, plr)
		end
	end
	return arr
end
function V5:getPlayersExceptLocal()
	local arr = {}
	local localP = Players.LocalPlayer
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= localP then table.insert(arr,plr) end
	end
	return arr
end
function V5:banFromExecution(name)
	return false,"Not implemented"
end
function V5:addToCache(name,link)
	local cache = self:loadScriptCache()
	cache[name] = link
	self:saveScriptCache(cache)
	return true
end
function V5:removeFromCache(name)
	local cache = self:loadScriptCache()
	cache[name] = nil
	self:saveScriptCache(cache)
	return true
end
function V5:executeCached(name)
	local cache = self:loadScriptCache()
	local link = cache[name]
	if not link then return false,"Not cached" end
	return self:load(link)
end
function V5:listCached()
	local cache = self:loadScriptCache()
	local t = {}
	for k,v in pairs(cache) do table.insert(t,{name=k,link=v}) end
	return t
end
function V5:inspectObject(obj)
	local info = {}
	if typeof(obj) == "Instance" then
		info.Name = obj.Name
		info.ClassName = obj.ClassName
		info.Parent = obj.Parent and obj.Parent:GetFullName() or nil
		info.Children = #obj:GetChildren()
		return info
	else
		return nil
	end
end
function V5:attachLogger(name)
	INTERNAL._data[name] = INTERNAL._data[name] or {}
	return INTERNAL._data[name]
end
function V5:pushLog(name, message)
	INTERNAL._data[name] = INTERNAL._data[name] or {}
	table.insert(INTERNAL._data[name], {time=os.time(),msg=tostring(message)})
	return true
end
function V5:getLogs(name)
	return INTERNAL._data[name] or {}
end
function V5:clearLogs(name)
	INTERNAL._data[name] = {}
	return true
end
function V5:watchProperty(instance, prop, callback)
	if not instance then return false end
	local last = instance[prop]
	local con = RunService.Heartbeat:Connect(function()
		if instance and instance[prop] ~= last then
			last = instance[prop]
			pcall(function() callback(last) end)
		end
	end)
	table.insert(INTERNAL._connections, con)
	return con
end
function V5:makeThread(fn)
	local co = coroutine.create(fn)
	coroutine.resume(co)
	table.insert(INTERNAL._threads, co)
	return co
end
function V5:stopAllThreads()
	for _, co in ipairs(INTERNAL._threads) do
		pcall(function()
			if coroutine.status(co) ~= "dead" then
				-- cannot force stop coroutine cleanly; mark for clearing
			end
		end)
	end
	INTERNAL._threads = {}
	return true
end
function V5:clearConnections()
	for _, con in ipairs(INTERNAL._connections) do
		pcall(function() con:Disconnect() end)
	end
	INTERNAL._connections = {}
	return true
end
function V5:clearToggles()
	for k,v in pairs(INTERNAL._toggles) do
		if type(v) == "table" and v.Destroy then
			pcall(function() v:Destroy() end)
		elseif v and v.Disconnect then
			pcall(function() v:Disconnect() end)
		end
		INTERNAL._toggles[k] = nil
	end
	return true
end
function V5:restoreDefaults()
	self:clearConnections()
	self:clearToggles()
	self:stopAllThreads()
	self:log("Defaults restored")
	return true
end
function V5:enableTracerForPlayer(plr)
	if not plr or not plr.Character then return false end
	local tr = {}
	local con = RunService.Heartbeat:Connect(function()
		if plr and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
			local hrp = plr.Character.HumanoidRootPart
			local pos = hrp.Position
			local beam = Instance.new("Part")
			beam.Size = Vector3.new(0.2,0.2,0.2)
			beam.Anchored = true
			beam.CanCollide = false
			beam.Position = pos
			beam.Transparency = 1
			beam.Parent = Workspace
			task.delay(1.5, function() pcall(function() beam:Destroy() end) end)
		end
	end)
	table.insert(INTERNAL._connections, con)
	tr.connection = con
	return tr
end
function V5:makeToolWatcher(toolName, onEquip, onUnequip)
	local p = Players.LocalPlayer
	if not p then return end
	local function check()
		local c = p.Character
		if c and c:FindFirstChild(toolName) then
			pcall(function() onEquip(c:FindFirstChild(toolName)) end)
		else
			pcall(function() onUnequip() end)
		end
	end
	local con = RunService.Heartbeat:Connect(check)
	table.insert(INTERNAL._connections, con)
	return con
end
function V5:setPropertyViaPath(obj,path,value)
	local segs = {}
	for s in string.gmatch(path,"[^%.]+") do table.insert(segs,s) end
	local cur = obj
	for i=1,#segs-1 do
		cur = cur and cur[segs[i]]
		if not cur then return false end
	end
	local last = segs[#segs]
	if cur then
		cur[last] = value
		return true
	end
	return false
end
function V5:getPropertyViaPath(obj,path)
	local segs = {}
	for s in string.gmatch(path,"[^%.]+") do table.insert(segs,s) end
	local cur = obj
	for i=1,#segs do
		cur = cur and cur[segs[i]]
		if cur == nil then return nil end
	end
	return cur
end
function V5:searchWorkspaceByName(name, limit)
	limit = limit or math.huge
	local t = {}
	for _, obj in ipairs(Workspace:GetDescendants()) do
		if tostring(obj.Name):lower():find(name:lower()) then
			table.insert(t,obj)
			if #t >= limit then break end
		end
	end
	return t
end
function V5:searchWorkspaceByClass(class, limit)
	limit = limit or math.huge
	local t = {}
	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj.ClassName == class then
			table.insert(t,obj)
			if #t >= limit then break end
		end
	end
	return t
end
function V5:runRemoteInLoop(remoteName, args, interval)
	interval = interval or 1
	local con = task.spawn(function()
		while task.wait(interval) do
			local ok, res = pcall(function()
				local r = INTERNAL._remotes[remoteName]
				if r then
					if r.FireServer then
						r:FireServer(unpack(args or {}))
					elseif r.InvokeServer then
						r:InvokeServer(unpack(args or {}))
					end
				end
			end)
			if not ok then
				self:log("Remote loop failed: "..tostring(res))
			end
		end
	end)
	table.insert(INTERNAL._threads,con)
	return con
end
function V5:monitorProperty(instance, prop, cb, interval)
	interval = interval or 0.1
	local con = task.spawn(function()
		local last = instance and instance[prop]
		while task.wait(interval) do
			if not instance then break end
			local cur = instance[prop]
			if cur ~= last then
				last = cur
				pcall(function() cb(cur) end)
			end
		end
	end)
	table.insert(INTERNAL._threads,con)
	return con
end
function V5:makeSimpleAimbot(range, fov, prediction)
	range = range or 200
	fov = fov or 90
	prediction = prediction or 0
	local p = Players.LocalPlayer
	local function aimOnce()
		if not p or not p.Character or not p.Character:FindFirstChild("HumanoidRootPart") then return false end
		local hrp = p.Character.HumanoidRootPart
		local cam = Workspace.CurrentCamera
		local best, bestDist, bestPlr = nil, math.huge, nil
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= p and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
				local pos = plr.Character.HumanoidRootPart.Position
				local screen = cam:WorldToViewportPoint(pos)
				local dist2d = (Vector2.new(screen.X, screen.Y) - Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)).Magnitude
				if screen.Z > 0 and dist2d < fov and (hrp.Position - pos).Magnitude < range then
					if dist2d < bestDist then
						bestDist = dist2d
						bestPlr = plr
					end
				end
			end
		end
		if bestPlr and bestPlr.Character and bestPlr.Character:FindFirstChild("HumanoidRootPart") then
			local targetPos = bestPlr.Character.HumanoidRootPart.Position + (bestPlr.Character.HumanoidRootPart.Velocity * prediction)
			local cf = CFrame.new(cam.CFrame.Position, targetPos)
			workspace.CurrentCamera.CFrame = cf
			return true,bestPlr
		end
		return false
	end
	return aimOnce
end
function V5:bindToKey(key, fn)
	local con = UserInputService.InputBegan:Connect(function(input,gp)
		if gp then return end
		if input.KeyCode == key then
			pcall(fn)
		end
	end)
	table.insert(INTERNAL._connections,con)
	return con
end
function V5:unbindConnection(con)
	for i, c in ipairs(INTERNAL._connections) do
		if c == con then
			pcall(function() c:Disconnect() end)
			table.remove(INTERNAL._connections,i)
			break
		end
	end
	return true
end
function V5:createAutoCollector(partName, radius)
	radius = radius or 8
	local running = true
	local con = RunService.Heartbeat:Connect(function()
		if not running then return end
		local p = Players.LocalPlayer
		if p and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
			local hrp = p.Character.HumanoidRootPart
			for _, obj in ipairs(Workspace:GetDescendants()) do
				if obj:IsA("BasePart") and obj.Name:lower():find(partName:lower()) then
					local d = (obj.Position - hrp.Position).Magnitude
					if d <= radius then
						local old = hrp.CFrame
						hrp.CFrame = obj.CFrame + Vector3.new(0,3,0)
						task.wait(0.15)
						hrp.CFrame = old
					end
				end
			end
		end
	end)
	table.insert(INTERNAL._connections, con)
	return con
end
function V5:toggleInvisibility(enable)
	local p = Players.LocalPlayer
	if not p or not p.Character then return false end
	for _, part in ipairs(p.Character:GetDescendants()) do
		if part:IsA("BasePart") or part:IsA("Decal") or part:IsA("Texture") then
			pcall(function()
				if enable then
					if part:IsA("BasePart") then
						part.Transparency = 1
					elseif part:IsA("Decal") or part:IsA("Texture") then
						part.Transparency = 1
					end
				else
					if part:IsA("BasePart") then
						part.Transparency = 0
					elseif part:IsA("Decal") or part:IsA("Texture") then
						part.Transparency = 0
					end
				end
			end)
		end
	end
	return true
end
function V5:quickBuy(itemName)
	local buyPath = ReplicatedStorage:FindFirstChild("Packages") and ReplicatedStorage.Packages:FindFirstChild("Net") and ReplicatedStorage.Packages.Net:FindFirstChild("RF/CoinsShopService/RequestBuy")
	if not buyPath then
		return false,"No buy remote found"
	end
	local args = {itemName}
	local ok,res = pcall(function() return buyPath:InvokeServer(unpack(args)) end)
	if ok then
		self:log("Buy success: "..tostring(itemName))
		return true,res
	else
		return false,res
	end
end
function V5:remoteInvokeByPath(path,...)
	local segs = {}
	for s in string.gmatch(path,"[^/]+") do table.insert(segs,s) end
	local cur = ReplicatedStorage
	for i,seg in ipairs(segs) do
		if cur and cur:FindFirstChild(seg) then
			cur = cur[seg]
		else
			return false,"Remote not found"
		end
	end
	if cur and cur.InvokeServer then
		local ok,res = pcall(function() return cur:InvokeServer(...) end)
		if ok then return true,res else return false,res end
	else
		return false,"Not invokable"
	end
end
function V5:remoteFireByPath(path,...)
	local segs = {}
	for s in string.gmatch(path,"[^/]+") do table.insert(segs,s) end
	local cur = ReplicatedStorage
	for i,seg in ipairs(segs) do
		if cur and cur:FindFirstChild(seg) then
			cur = cur[seg]
		else
			return false,"Remote not found"
		end
	end
	if cur and cur.FireServer then
		local ok,res = pcall(function() cur:FireServer(...) end)
		if ok then return true else return false,res end
	else
		return false,"Not fireable"
	end
end
function V5:spawnAtRandomSafePosition(range, attempts)
	range = range or 50
	attempts = attempts or 10
	local p = Players.LocalPlayer
	if not p or not p.Character then return false end
	local hrp = p.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return false end
	for i=1,attempts do
		local rand = hrp.Position + Vector3.new(math.random(-range,range),math.random(5,20),math.random(-range,range))
		local ok = pcall(function() hrp.CFrame = CFrame.new(rand) end)
		if ok then return true end
	end
	return false
end
function V5:pruneWorkspaceByName(name, limit)
	limit = limit or math.huge
	local c = 0
	for _, obj in ipairs(Workspace:GetDescendants()) do
		if c >= limit then break end
		if obj.Name:lower():find(name:lower()) then
			pcall(function() obj:Destroy() end)
			c = c + 1
		end
	end
	return c
end
function V5:getPositionOfPlayer(plr)
	if typeof(plr) == "string" then plr = Players:FindFirstChild(plr) end
	if plr and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
		return plr.Character.HumanoidRootPart.Position
	end
	return nil
end
function V5:setGuiEnabledCore(enable)
	pcall(function()
		for _, gui in ipairs(CoreGui:GetChildren()) do
			gui.Enabled = enable
		end
	end)
	return true
end
function V5:findNearestPartByName(name, radius)
	local p = Players.LocalPlayer
	if not p or not p.Character then return nil end
	local hrp = p.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return nil end
	local best, bestd
	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj:IsA("BasePart") and obj.Name:lower():find(name:lower()) then
			local d = (obj.Position - hrp.Position).Magnitude
			if not bestd or d < bestd then
				best = obj
				bestd = d
			end
		end
	end
	return best, bestd
end
function V5:toggleGravity(enable)
	if enable then
		workspace.Gravity = 196.2
	else
		workspace.Gravity = 0
	end
	return true
end
function V5:getAllTools()
	local arr = {}
	local p = Players.LocalPlayer
	if not p then return arr end
	local b = p:FindFirstChild("Backpack")
	if b then
		for _, t in ipairs(b:GetChildren()) do
			if t:IsA("Tool") then table.insert(arr,t) end
		end
	end
	if p.Character then
		for _, t in ipairs(p.Character:GetChildren()) do
			if t:IsA("Tool") then table.insert(arr,t) end
		end
	end
	return arr
end
function V5:countPartsByName(name)
	local c = 0
	for _, p in ipairs(Workspace:GetDescendants()) do
		if p:IsA("BasePart") and p.Name:lower():find(name:lower()) then
			c = c + 1
		end
	end
	return c
end
function V5:remoteExistsByPath(path)
	local segs = {}
	for s in string.gmatch(path,"[^/]+") do table.insert(segs,s) end
	local cur = ReplicatedStorage
	for i,seg in ipairs(segs) do
		if cur and cur:FindFirstChild(seg) then
			cur = cur[seg]
		else
			return false
		end
	end
	return cur ~= nil
end
function V5:fastRespawn()
	local p = Players.LocalPlayer
	if not p then return false end
	p:LoadCharacter()
	return true
end
function V5:teleToNearestPlayer(range)
	local list = self:getNearestPlayersList(range or 50,1)
	if #list > 0 then
		return self:teleportToPlayer(list[1].player)
	end
	return false,"No players"
end
function V5:attemptToDropTool(toolName)
	local p = Players.LocalPlayer
	if not p or not p.Character then return false end
	local tool = p.Character:FindFirstChild(toolName) or p.Backpack:FindFirstChild(toolName)
	if tool and tool.Parent == p.Character then
		pcall(function() p.Character.Humanoid:UnequipTools() end)
	end
	return true
end
function V5:queueTask(fn, delayTime)
	local t = task.spawn(function()
		task.wait(delayTime or 0)
		pcall(fn)
	end)
	table.insert(INTERNAL._threads,t)
	return t
end
function V5:getPlayersWithTag(tagName)
	local arr = {}
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr:FindFirstChild(tagName) then table.insert(arr,plr) end
	end
	return arr
end
function V5:findNearestModelByName(name)
	local p = Players.LocalPlayer
	if not p or not p.Character then return nil end
	local hrp = p.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return nil end
	local best,bd
	for _, m in ipairs(Workspace:GetDescendants()) do
		if m:IsA("Model") and m.Name:lower():find(name:lower()) then
			if m.PrimaryPart then
				local d = (m.PrimaryPart.Position - hrp.Position).Magnitude
				if not bd or d < bd then best = m; bd = d end
			end
		end
	end
	return best, bd
end
function V5:respawnIfDead()
	local p = Players.LocalPlayer
	if not p then return end
	if p.Character and p.Character:FindFirstChildOfClass("Humanoid") then
		local hum = p.Character:FindFirstChildOfClass("Humanoid")
		if hum.Health <= 0 then
			p:LoadCharacter()
			return true
		end
	end
	return false
end
function V5:createSimpleBeacon(pos,text)
	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.new(0,200,0,50)
	billboard.StudsOffset = Vector3.new(0,3,0)
	billboard.AlwaysOnTop = true
	local label = Instance.new("TextLabel", billboard)
	label.Size = UDim2.new(1,0,1,0)
	label.Text = text or "Beacon"
	label.BackgroundTransparency = 1
	label.TextScaled = true
	billboard.Parent = Workspace
	billboard.Adornee = self:createPartAt(pos,Vector3.new(1,1,1),true,Workspace)
	return billboard
end
function V5:timeStampedPrint(msg)
	self:log(tostring(os.date("%c")).." - "..tostring(msg))
end
function V5:enableAutoRespawn(enable)
	enable = enable == nil and true or enable
	if enable then
		local con = Players.LocalPlayer.CharacterAdded:Connect(function(char)
			task.wait(0.5)
			if not char:FindFirstChildOfClass("Humanoid") then return end
		end)
		table.insert(INTERNAL._connections,con)
		return con
	else
		return false
	end
end
function V5:getWorkspaceStats()
	local parts,models = 0,0
	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj:IsA("BasePart") then parts = parts + 1 end
		if obj:IsA("Model") then models = models + 1 end
	end
	return {parts = parts, models = models}
end
function V5:enableAutoClean(limit,name)
	limit = limit or 100
	local con = RunService.Heartbeat:Connect(function()
		local total = 0
		for _, obj in ipairs(Workspace:GetDescendants()) do
			if obj.Name:lower():find(name:lower()) then
				pcall(function() obj:Destroy() end)
				total = total + 1
				if total >= limit then break end
			end
		end
	end)
	table.insert(INTERNAL._connections,con)
	return con
end
function V5:promoteToLocalAdmin(plr)
	return false,"Not implemented"
end
function V5:makeDummyModelAt(pos)
	local m = Instance.new("Model")
	m.Name = "V5Dummy"
	local p = Instance.new("Part",m)
	p.Size = Vector3.new(2,2,1)
	p.Anchored = true
	p.Position = pos or Vector3.new(0,5,0)
	m.PrimaryPart = p
	m.Parent = Workspace
	return m
end
function V5:enableSimpleESP(enable, size)
	enable = enable == nil and true or enable
	size = size or Vector3.new(1,1,1)
	if enable then
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= Players.LocalPlayer then
				pcall(function()
					if plr.Character and not plr.Character:FindFirstChild("V5ESP") then
						local box = Instance.new("BoxHandleAdornment")
						box.Adornee = plr.Character:FindFirstChild("HumanoidRootPart")
						box.AlwaysOnTop = true
						box.Size = size
						box.ZIndex = 10
						box.Parent = plr.Character
						box.Name = "V5ESP"
					end
				end)
			end
		end
		local con = Players.PlayerAdded:Connect(function(plr)
			task.wait(1)
			if plr ~= Players.LocalPlayer and plr.Character and not plr.Character:FindFirstChild("V5ESP") then
				local box = Instance.new("BoxHandleAdornment")
				box.Adornee = plr.Character:FindFirstChild("HumanoidRootPart")
				box.AlwaysOnTop = true
				box.Size = size
				box.ZIndex = 10
				box.Parent = plr.Character
				box.Name = "V5ESP"
			end
		end)
		table.insert(INTERNAL._connections,con)
		return true
	else
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr.Character then
				for _, obj in ipairs(plr.Character:GetChildren()) do
					if obj.Name == "V5ESP" then pcall(function() obj:Destroy() end) end
				end
			end
		end
		return true
	end
end
function V5:getMemoryUsage()
	local ok, mem = pcall(function() return collectgarbage("count") end)
	if ok then return mem else return 0 end
end
function V5:shutdown()
	self:clearConnections()
	self:clearToggles()
	self:stopAllThreads()
	self:log("V5 shutting down")
	return true
end
function V5:compactWorkspace(threshold)
	threshold = threshold or 1000
	local parts = {}
	for _, p in ipairs(Workspace:GetDescendants()) do
		if p:IsA("BasePart") then table.insert(parts,p) end
	end
	local removed = 0
	for i=#parts,1,-1 do
		if removed >= threshold then break end
		pcall(function() parts[i]:Destroy() removed = removed + 1 end)
	end
	return removed
end
function V5:teleportAllToPlayer(plr)
	if typeof(plr) == "string" then plr = Players:FindFirstChild(plr) end
	if not plr or not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") then return false end
	local pos = plr.Character.HumanoidRootPart.CFrame
	for _, other in ipairs(Players:GetPlayers()) do
		if other.Character and other.Character:FindFirstChild("HumanoidRootPart") then
			pcall(function() other.Character.HumanoidRootPart.CFrame = pos + Vector3.new(0,3,0) end)
		end
	end
	return true
end
function V5:findObjectsByTag(tag)
	local t = {}
	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj:FindFirstChild(tag) then table.insert(t,obj) end
	end
	return t
end
function V5:getPlaceInfo()
	local ok,info = pcall(function()
		return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games?universeIds="..tostring(game.PlaceId)))
	end)
	if ok then return info else return nil end
end
function V5:attemptToDisableTouches(enable)
	enable = enable == nil and true or enable
	if enable then
		local con = RunService.Stepped:Connect(function()
			for _, part in ipairs(Workspace:GetDescendants()) do
				if part:IsA("BasePart") then
					part.Touched:Connect(function() end)
				end
			end
		end)
		table.insert(INTERNAL._connections,con)
		return con
	else
		return false
	end
end
function V5:makeTimer(seconds, callback)
	local start = os.time()
	local con = RunService.Heartbeat:Connect(function()
		if os.time() - start >= seconds then
			pcall(callback)
			con:Disconnect()
		end
	end)
	table.insert(INTERNAL._connections,con)
	return con
end
function V5:runFunctionSafely(fn, ...)
	local ok, res = pcall(fn, ...)
	if not ok then
		self:log("Function error: "..tostring(res))
		return false, res
	end
	return true, res
end
function V5:dumpWorkspaceSummary()
	local summary = {}
	summary.time = os.date("%c")
	summary.stats = self:getWorkspaceStats()
	self:log(HttpService:JSONEncode(summary))
	return summary
end
function V5:spawnFloatingText(pos, text, duration)
	local p = Instance.new("Part")
	p.Size = Vector3.new(1,1,1)
	p.Anchored = true
	p.CanCollide = false
	p.Transparency = 1
	p.Position = pos or Vector3.new(0,5,0)
	local gui = Instance.new("BillboardGui", p)
	gui.Size = UDim2.new(0,200,0,50)
	gui.Adornee = p
	local label = Instance.new("TextLabel", gui)
	label.Size = UDim2.new(1,0,1,0)
	label.Text = text or ""
	label.BackgroundTransparency = 1
	label.TextScaled = true
	p.Parent = Workspace
	task.delay(duration or 2, function() p:Destroy() end)
	return p
end
function V5:cloneAndAnchorModel(model)
	if not model then return nil end
	local clone = model:Clone()
	for _, part in ipairs(clone:GetDescendants()) do
		if part:IsA("BasePart") then part.Anchored = true end
	end
	clone.Parent = Workspace
	return clone
end
function V5:toggleTeamColorHighlights(enable)
	enable = enable == nil and true or enable
	if enable then
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr.TeamColor then
				if plr.Character then
					for _, part in ipairs(plr.Character:GetDescendants()) do
						if part:IsA("BasePart") then
							pcall(function() part.Color = plr.TeamColor.Color end)
						end
					end
				end
			end
		end
		return true
	else
		return false
	end
end
function V5:getNearestTool(range)
	range = range or 50
	local p = Players.LocalPlayer
	if not p or not p.Character then return nil end
	local hrp = p.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return nil end
	local best,bd
	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj:IsA("Tool") or (obj:IsA("Model") and obj:FindFirstChildWhichIsA("Tool")) then
			local pos = obj:IsA("Tool") and obj.Handle and obj.Handle.Position or (obj.PrimaryPart and obj.PrimaryPart.Position)
			if pos then
				local d = (pos - hrp.Position).Magnitude
				if not bd or d < bd then best = obj; bd = d end
			end
		end
	end
	return best,bd
end
function V5:enableWalkBoost(factor)
	factor = factor or 2
	local p = Players.LocalPlayer
	if not p then return false end
	local con = RunService.Heartbeat:Connect(function()
		if p.Character and p.Character:FindFirstChildOfClass("Humanoid") then
			p.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 16 * factor
		end
	end)
	table.insert(INTERNAL._connections,con)
	return con
end
function V5:enableJumpBoost(factor)
	factor = factor or 2
	local p = Players.LocalPlayer
	if not p then return false end
	local con = RunService.Heartbeat:Connect(function()
		if p.Character and p.Character:FindFirstChildOfClass("Humanoid") then
			p.Character:FindFirstChildOfClass("Humanoid").JumpPower = 50 * factor
		end
	end)
	table.insert(INTERNAL._connections,con)
	return con
end
function V5:isPlayerInArena(plr, arenaName)
	if typeof(plr) == "string" then plr = Players:FindFirstChild(plr) end
	if not plr or not plr.Character then return false end
	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj.Name == arenaName and obj:IsA("BasePart") then
			if plr.Character.HumanoidRootPart and (plr.Character.HumanoidRootPart.Position - obj.Position).Magnitude <= (obj.Size.Magnitude / 2) then
				return true
			end
		end
	end
	return false
end
function V5:collectAllTouchGivers(waitBack)
	waitBack = waitBack or 0.3
	local found = {}
	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj:IsA("BasePart") and obj.Name:lower():find("touchgiver") then
			table.insert(found,obj)
		end
	end
	for _, part in ipairs(found) do
		pcall(function()
			local p = Players.LocalPlayer
			local hrp = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
			if hrp then
				local old = hrp.CFrame
				hrp.CFrame = part.CFrame + Vector3.new(0,3,0)
				task.wait(waitBack)
				hrp.CFrame = old
			end
		end)
	end
	return #found
end
function V5:makePersistentTask(id, fn, interval)
	if INTERNAL._monitor[id] then return false,"Id exists" end
	local con = task.spawn(function()
		while true do
			pcall(fn)
			task.wait(interval or 1)
		end
	end)
	INTERNAL._monitor[id] = con
	return con
end
function V5:stopPersistentTask(id)
	local t = INTERNAL._monitor[id]
	if t then
		INTERNAL._monitor[id] = nil
		return true
	end
	return false
end
function V5:wrapPcall(fn)
	return function(...)
		local ok, res = pcall(fn,...)
		if not ok then
			self:log("Wrapped error: "..tostring(res))
		end
		return ok, res
	end
end
function V5:makeSimplePathfinder(targetPosition, speed)
	local p = Players.LocalPlayer
	if not p or not p.Character then return false end
	local hrp = p.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return false end
	local con = RunService.Heartbeat:Connect(function(dt)
		local dir = (targetPosition - hrp.Position)
		if dir.Magnitude > 1 then
			local step = dir.unit * (speed or 16) * dt
			hrp.CFrame = hrp.CFrame + step
		end
	end)
	table.insert(INTERNAL._connections,con)
	return con
end
function V5:findAndTeleportTo(name)
	local obj = self:findNearestPartByName(name)
	if obj then
		return self:teleportToPart(obj)
	end
	return false
end
function V5:enableAutoRespawnWhenDead()
	local con = Players.LocalPlayer.CharacterAdded:Connect(function(char)
		task.wait(0.5)
		if char:FindFirstChildOfClass("Humanoid") then
			local hum = char:FindFirstChildOfClass("Humanoid")
			hum.Died:Connect(function()
				task.wait(1)
				Players.LocalPlayer:LoadCharacter()
			end)
		end
	end)
	table.insert(INTERNAL._connections,con)
	return con
end
function V5:getPlayerDistance(a,b)
	if typeof(a) == "string" then a = Players:FindFirstChild(a) end
	if typeof(b) == "string" then b = Players:FindFirstChild(b) end
	if not a or not b or not a.Character or not b.Character then return nil end
	return (a.Character.HumanoidRootPart.Position - b.Character.HumanoidRootPart.Position).Magnitude
end
function V5:encodeData(data)
	return HttpService:JSONEncode(data)
end
function V5:decodeData(text)
	return HttpService:JSONDecode(text)
end
function V5:toggleToolAutoUse(toolName, interval)
	interval = interval or 1
	local running = true
	local t = task.spawn(function()
		while running do
			task.wait(interval)
			pcall(function()
				local tool = self:findTool(toolName)
				if tool and tool.Parent == Players.LocalPlayer.Backpack then
					self:equip(toolName)
					task.wait(0.1)
					self:activate(toolName)
				end
			end)
		end
	end)
	table.insert(INTERNAL._threads,t)
	return t
end
function V5:findAndDestroyNamedModels(substr)
	local c = 0
	for _, m in ipairs(Workspace:GetDescendants()) do
		if m:IsA("Model") and m.Name:lower():find(substr:lower()) then
			pcall(function() m:Destroy() c = c + 1 end)
		end
	end
	return c
end
function V5:toggleGlobalTransparency(percent)
	percent = percent or 0.5
	for _, p in ipairs(Workspace:GetDescendants()) do
		if p:IsA("BasePart") then
			p.Transparency = percent
		end
	end
	return true
end
function V5:saveWorkspaceSnapshot(name)
	local snap = {}
	for _, obj in ipairs(Workspace:GetChildren()) do
		table.insert(snap,{name=obj.Name,class=obj.ClassName,parent=obj.Parent and obj.Parent.Name or nil})
	end
	if writefile then
		pcall(function() writefile("V5_Snap_"..tostring(name)..".json", HttpService:JSONEncode(snap)) end)
	end
	return snap
end
function V5:restoreWorkspaceSnapshot(name)
	if isfile and isfile("V5_Snap_"..tostring(name)..".json") then
		local ok, data = pcall(function() return HttpService:JSONDecode(readfile("V5_Snap_"..tostring(name)..".json")) end)
		if ok and data then
			for _, info in ipairs(data) do
				-- cannot fully restore non-serializable instances; placeholder
			end
			return true
		end
	end
	return false
end
function V5:setLocalTimeScale(scale)
	scale = scale or 1
	RunService:Set3dRenderingEnabled(true)
	return true
end
function V5:getPlayersCount()
	return #Players:GetPlayers()
end
function V5:sendTeamMessage(msg)
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr.Team == Players.LocalPlayer.Team then
			pcall(function() plr:Kick(msg) end)
		end
	end
	return true
end
function V5:countPlayersWithTool(toolName)
	local c = 0
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr.Character and plr.Character:FindFirstChild(toolName) then c = c + 1 end
		if plr:FindFirstChild("Backpack") and plr.Backpack:FindFirstChild(toolName) then c = c + 1 end
	end
	return c
end
function V5:findFirstPlayerWithTool(toolName)
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr.Character and plr.Character:FindFirstChild(toolName) then return plr end
		if plr:FindFirstChild("Backpack") and plr.Backpack:FindFirstChild(toolName) then return plr end
	end
	return nil
end
function V5:loadAndCacheScript(name, link)
	self:addToCache(name,link)
	return self:load(link)
end
function V5:toggleAutoPickup(enable, partName, radius)
	if enable then
		local con = RunService.Heartbeat:Connect(function()
			local p = Players.LocalPlayer
			if p and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
				local hrp = p.Character.HumanoidRootPart
				for _, obj in ipairs(Workspace:GetDescendants()) do
					if obj:IsA("BasePart") and obj.Name:lower():find(partName:lower()) then
						if (obj.Position - hrp.Position).Magnitude <= (radius or 6) then
							local old = hrp.CFrame
							hrp.CFrame = obj.CFrame + Vector3.new(0,3,0)
							task.wait(0.12)
							hrp.CFrame = old
						end
					end
				end
			end
		end)
		table.insert(INTERNAL._connections,con)
		return con
	else
		return false
	end
end
function V5:getAlivePlayers()
	local t = {}
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr.Character and plr.Character:FindFirstChildOfClass("Humanoid") and plr.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
			table.insert(t,plr)
		end
	end
	return t
end
function V5:clearWorkspaceOfName(name)
	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj.Name == name then
			pcall(function() obj:Destroy() end)
		end
	end
	return true
end
function V5:registerCommand(name, fn)
	INTERNAL._commands = INTERNAL._commands or {}
	INTERNAL._commands[name] = fn
	return true
end
function V5:runCommand(name, ...)
	if INTERNAL._commands and INTERNAL._commands[name] then
		local ok, res = pcall(INTERNAL._commands[name], ...)
		if ok then return true, res else return false, res end
	end
	return false,"Not found"
end
function V5:listCommands()
	local t = {}
	if INTERNAL._commands then
		for k,_ in pairs(INTERNAL._commands) do table.insert(t,k) end
	end
	return t
end
function V5:registerSimpleUIlessMenu(menu)
	INTERNAL._menu = menu
	return true
end
function V5:getRegisteredMenu()
	return INTERNAL._menu
end
function V5:enableFPSUnlock()
	return false,"Not implemented"
end
function V5:verifyPlaceWhitelist()
	return false,"Not implemented"
end
function V5:makeGhostMode(enable)
	enable = enable == nil and true or enable
	if enable then
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr.Character then
				for _, part in ipairs(plr.Character:GetDescendants()) do
					if part:IsA("BasePart") then
						part.CanCollide = false
					end
				end
			end
		end
		return true
	else
		return false
	end
end
function V5:dumpPlayersBrief()
	local t = {}
	for _, plr in ipairs(Players:GetPlayers()) do
		table.insert(t,{name=plr.Name,id=plr.UserId,team=plr.Team and plr.Team.Name or nil})
	end
	return t
end
function V5:countPlayersByTeam()
	local map = {}
	for _, plr in ipairs(Players:GetPlayers()) do
		local tn = plr.Team and plr.Team.Name or "NoTeam"
		map[tn] = (map[tn] or 0) + 1
	end
	return map
end
function V5:invokeFunctionOnAllPlayers(fn)
	for _, plr in ipairs(Players:GetPlayers()) do
		pcall(function() fn(plr) end)
	end
	return true
end
local default = setmetatable({}, V5)
setmetatable(V5, {
	__index = function(_, k)
		return function(_, ...)
			return default[k](default, ...)
		end
	end
})
return V5