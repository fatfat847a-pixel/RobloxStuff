-- Version: 1.3.0

--[[
This module was made by: Zaya_Blaze, https://scriptblox.com/u/Zaya.
]]

--[[
Example Plugin:

local F3XModulePlugin = {}

F3XModulePlugin.Name = "WorldDestroy" --Will be used like: "F3XModule.Name()"
F3XModulePlugin.func = function(F3XModule) --Do not remove F3XModule from the args.
	
end

return F3XModulePlugin
]]

if not getgenv().F3XModule_Settings then
	getgenv().F3XModule_Settings = {
		UseCustomPrint = true,
		UsePlugins = true,
		DoNotUpdate = false
	}
end

local warn = function(words, HasPrintLogo, LogoExtra)
	if getgenv().F3XModule_Settings.UseCustomPrint == false then return warn(words) end
	if not LogoExtra then LogoExtra = "" end
	if HasPrintLogo == nil then HasPrintLogo = true end

	if HasPrintLogo == false then
		warn(words)
	else	
		warn(LogoExtra.."[F3XModule]: "..words)
	end
end

local print = function(words, HasPrintLogo, LogoExtra)
	if getgenv().F3XModule_Settings.UseCustomPrint == false then return print(words) end
	if not LogoExtra then LogoExtra = "" end
	if HasPrintLogo == nil then HasPrintLogo = true end

	if HasPrintLogo == false then
		print(words)
	else	
		print(LogoExtra.."[F3XModule]: "..words)
	end
end

local function LoadUpdates()
	if F3XModule_Settings.DoNotUpdate then return nil end
	local resp = game:HttpGet("https://raw.githubusercontent.com/fatfat847a-pixel/RobloxStuff/refs/heads/main/F3XModule.lua")
	local version,current = nil,nil
	local folderPath,versionfile = "F3XModule", "Version.txt"
	local commenter = string.char(0x002D)..string.char(0x002D)
	
	if resp then
		local str = tostring(resp)

		if isfolder(folderPath) then
			if isfile(folderPath.."/"..versionfile) then
				current = readfile(folderPath.."/"..versionfile)
			end
		end

		if str:match("Version: ") then
			version = (str:match("%-%-%[%[ Version: ([%d%.]+) %]%]") or str:match("Version:%s*([%d%.]+)"))
		end
		
		if version then
			getgenv().F3XModuleVer = version
		end
		
		if version and current and version ~= current then
			print("Outdated version, Updating...",true, "[v"..current.." → v"..version.."]")
			writefile(folderPath.."/F3XModule.btools",str..(commenter.."My reaction when I am up to date: 🫪"))
			writefile(folderPath.."/"..versionfile, version)
			return readfile(folderPath.."/F3XModule.btools") or "Failed to update."
		else
			if isfolder(folderPath) then
				if isfile(folderPath.."/"..versionfile) then
					local old = (isfile(folderPath.."/F3XModule.btools") and readfile(folderPath.."/F3XModule.btools"))
					local oldstr = readfile(folderPath.."/F3XModule.btools")

					if string.match(oldstr, (commenter.."My reaction when I am up to date: 🫪")) then
						return
					else		
						return readfile(folderPath.."/F3XModule.btools") or game:HttpGet("https://raw.githubusercontent.com/fatfat847a-pixel/RobloxStuff/refs/heads/main/F3XModule.lua") or "!Error: Failed to update / Failed to use older version."
					end
				end
			end	
		end
	else	
		if isfolder(folderPath) then
			if isfile(folderPath.."/"..versionfile) then
				local old = (isfile(folderPath.."/F3XModule.btools") and readfile(folderPath.."/F3XModule.btools"))
				print("Could not fetch latest version, using version "..current..".",true)
				return readfile(folderPath.."/F3XModule.btools") or game:HttpGet("https://raw.githubusercontent.com/fatfat847a-pixel/RobloxStuff/refs/heads/main/F3XModule.lua") or "!Error: Failed to update."
			end
		end	
	end
end

local MainMod = function()
	local F3XModule = {}

	F3XModule.IsModuleReady = false
	F3XModule.PluginsLoaded = false

	getgenv().F3XConnections = {}

	local RunService = game:GetService("RunService")
	local CoreGui = game:GetService("CoreGui")
	local HttpService = game:GetService("HttpService")
	local player = game.Players.LocalPlayer
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:WaitForChild("Humanoid")
	local SyncAPI, ServerEndpoint
	local TimeoutWarnings, MaxTimeoutWarnings, ReachedTimeoutWarningMax = 0, 10, false

	local function FindSyncAPI(plr)
		for i,v in pairs(plr.Character:GetDescendants()) do
			if v:IsA("BindableFunction") and v.Name == "SyncAPI" then
				local svendp = v:FindFirstChild("ServerEndpoint") or nil
				if (plr == player and F3XModule.IsModuleReady ~= true) then F3XModule.IsModuleReady = true end
				return v, svendp
			end
		end

		for i,v in pairs(plr:GetDescendants()) do
			if v:IsA("BindableFunction") and v.Name == "SyncAPI" then
				local svendp = v:FindFirstChild("ServerEndpoint") or nil
				if (plr == player and F3XModule.IsModuleReady ~= true) then F3XModule.IsModuleReady = true end
				return v, svendp
			end
		end
		return nil,nil
	end

	local function FindBToolHandle(plr)
		local path = FindSyncAPI(plr)
		if path then
			local path2 = path.Parent
			for i,v in pairs(path2:GetDescendants()) do
				if v:IsA("BasePart") and v.Name == "Handle" then
					return v
				end
			end
		end
		return nil
	end

	local function CapitalizeFirst(str)
		if not str or str == "" then
			return ""
		end

		return string.upper(string.sub(str, 1, 1)) .. string.sub(str, 2)
	end

	SyncAPI, ServerEndpoint = FindSyncAPI(player)

	player.CharacterAdded:Connect(function(char)
		char:WaitForChild("Head")
		character = player.Character or player.CharacterAdded:Wait()
		humanoid = character:WaitForChild("Humanoid")
		SyncAPI = FindSyncAPI(player)
		F3XModule.SyncAPI = FindSyncAPI(player)
	end)

	if (not SyncAPI or SyncAPI == nil) then
		repeat
			task.wait()
			SyncAPI, ServerEndpoint = FindSyncAPI(player)
		until
		SyncAPI

		F3XModule.IsModuleReady = true
	else	
		F3XModule.IsModuleReady = true
	end

	function F3XModule.GetPlayerFromText(text)
		local Players = game.Players
		local playerFound = nil

		if type(text) == "number" then
			for i,v in pairs(Players:GetPlayers()) do
				if v.UserId == text then
					playerFound = v
					break
				end
			end
		elseif type(text) == "string" then
			for i, player1 in ipairs(Players:GetPlayers()) do
				if string.lower(player1.Name):sub(1, #text) == string.lower(text) or string.lower(player1.DisplayName):sub(1, #text) == string.lower(text) then
					playerFound = player1
					break
				end
			end
		end

		return playerFound
	end

	function F3XModule.GetPartFromText(parent, text)
		local Players = game.Players
		local instFound = nil

		if type(text) == "string" then
			for i, inst in ipairs(parent:GetDescendants()) do
				if string.lower(inst.Name):sub(1, #text) == string.lower(text) then
					instFound = inst
					break
				end
			end
		end

		return instFound
	end

	local function IsTable(Obj:any)
		return type(Obj) == "table"
	end

	local function getImageIdFromAssetId(assetId)
		assetId = tonumber(assetId)
		if not assetId then
			warn("Invalid asset ID")
			return nil
		end

		local success, objects = pcall(function()
			return game:GetObjects("rbxassetid://" .. assetId)
		end)

		if not success or not objects or not objects[1] then
			warn("Failed to load asset:", assetId)
			return nil
		end

		local obj = objects[1]

		if obj:IsA("Decal") then
			local texture = obj.Texture
			if texture and texture ~= "" then
				local imageId = texture:match("%d+")
				obj:Destroy()
				return tonumber(imageId)
			end
		end

		for _, desc in ipairs(obj:GetDescendants()) do
			if desc:IsA("Decal") or desc:IsA("Texture") then
				local texture = desc.Texture
				if texture and texture ~= "" then
					local imageId = texture:match("%d+")
					obj:Destroy()
					return tonumber(imageId)
				end
			elseif desc:IsA("ImageLabel") or desc:IsA("ImageButton") then
				local image = desc.Image
				if image and image ~= "" then
					local imageId = image:match("%d+")
					obj:Destroy()
					return tonumber(imageId)
				end
			end
		end

		if obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
			local image = obj.Image
			if image and image ~= "" then
				local imageId = image:match("%d+")
				obj:Destroy()
				return tonumber(imageId)
			end
		end

		obj:Destroy()
		warn("No image/texture found in asset:", assetId)
		return nil
	end

	function F3XModule:WaitForRemotes(Timeout:number|nil):(Instance|nil, Instance|nil)
		local WasNil, WasBelowZero, WasZero, OldTimeout = (Timeout == nil), (Timeout ~= nil and Timeout < 0), (Timeout ~= nil and Timeout == 0), Timeout
		if Timeout == nil then Timeout = 0 end
		local WasTimeoutInputed = (Timeout ~= nil and Timeout <= 0 and Timeout ~= math.huge)
		local timestart = 0

		if WasBelowZero then
			Timeout = math.huge
		elseif WasZero then
			Timeout = math.huge
		end

		if not ReachedTimeoutWarningMax then
			TimeoutWarnings += 1
			if TimeoutWarnings >= 10 then
				ReachedTimeoutWarningMax = true 
				return warn(debug.traceback("Possible infinite yield; (Timeout Seconds:"..Timeout..").\nInfinite Yield warnings disabled. (Reached max warnings of: "..MaxTimeoutWarnings..").\n--------------------------------------------------------------------------------------------"),true,"\n")
			end

			if Timeout > 9999 and not OldTimeout then
				warn(debug.traceback("Possible infinite yield; (Timeout Seconds:"..Timeout..").\n--------------------------------------------------------------------------------------------"),true,"\n")
			else	
				if WasNil then
					warn(debug.traceback("Possible infinite yield; Timeout input was nil.\n--------------------------------------------------------------------------------------------"),true,"\n")
				elseif WasBelowZero or WasZero then
					warn(debug.traceback("Possible infinite yield; Timeout input invalid:("..OldTimeout..").\n--------------------------------------------------------------------------------------------"),true,"\n")
				end
			end
		end

		repeat
			task.wait(0.1)
			timestart += 0.1
			SyncAPI, ServerEndpoint = FindSyncAPI(player)
		until
		((SyncAPI and ServerEndpoint) or (timestart >= Timeout))

		if SyncAPI and ServerEndpoint then
			print("Found all Remotes;(SyncAPI="..SyncAPI:GetFullName()..", ServerEndPoint="..ServerEndpoint:GetFullName()..")\n--------------------------------------------------------------------------------------------",true,"\n")
		elseif SyncAPI and not ServerEndpoint then
			print("Found 1 Remote;("..SyncAPI:GetFullName()..")\n--------------------------------------------------------------------------------------------",true,"\n")
		elseif ServerEndpoint and not SyncAPI then
			warn(debug.traceback("Found 1 Remote;("..ServerEndpoint:GetFullName().."), Needs SyncAPI.\n--------------------------------------------------------------------------------------------",true,"\n"))
			return nil,nil
		end

		return SyncAPI, ServerEndpoint
	end

	function F3XModule.GetLocalInstances():{BToolsInstances:{SyncAPI:RemoteFunction|nil,ServerEndpoint:RemoteFunction|nil,BToolsHandle:BasePart|nil},LocalPlayerInstances:{Player:Player,Character:Model|nil,Humanoid:Humanoid|nil,}}
		local BToolsInstances = {
			SyncAPI = SyncAPI,
			ServerEndpoint = ServerEndpoint,
			BToolsHandle = FindBToolHandle(player),
		}

		local LocalPlayerInstances = {
			Player = player,
			Character = character,
			Humanoid = humanoid,
		}

		return LocalPlayerInstances, BToolsInstances
	end

	function F3XModule.GetUserColor(Player:Player | number | string)
		if typeof(Player) ~= "Instance" then
			Player = F3XModule.GetPlayerFromText(Player)
		end

		local Colors = {
			Color3.new(253/255, 41/255, 67/255),
			Color3.new(1/255, 162/255, 255/255),
			Color3.new(2/255, 184/255, 87/255),
			BrickColor.new("Bright violet").Color,
			BrickColor.new("Bright orange").Color,
			BrickColor.new("Bright yellow").Color,
			BrickColor.new("Light reddish violet").Color,
			BrickColor.new("Bright yellow").Color,
		}

		local function GetNameValue(pName: string): number
			local value = 0
			for index = 1, #pName do
				local cValue = string.byte(string.sub(pName, index, index))
				local reverseIndex = #pName - index + 1
				if #pName % 2 == 1 then
					reverseIndex = reverseIndex - 1
				end
				if reverseIndex % 4 >= 2 then
					cValue = -cValue
				end
				value = value + cValue
			end
			return value
		end

		local function GetChatColor(name: string): Color3
			return Colors[(GetNameValue(name) % #Colors) + 1]
		end

		return GetChatColor(Player.Name)
	end

	function F3XModule.RecolorHandle(BrickColorV:BrickColor)
		task.spawn(function()
			SyncAPI:Invoke(
				"RecolorHandle",
				BrickColorV
			)
		end)
	end

	function F3XModule.CreatePart(CFrameV:CFrame, Parent:Instance, PartType:string)
		local types = {
			"Normal",
			"Truss",
			"Wedge",
			"Corner",
			"Cylinder",
			"Ball",
			"Seat",
			"Vehicle Seat",
			"Spawn"
		}

		local args = {
			"CreatePart",
			PartType,
			CFrameV,
			Parent
		}
		SyncAPI:Invoke(unpack(args))
	end

	function F3XModule.ColorPart(BasePart:BasePart|{BasePart:BasePart}, Color3RGB:Color3)
		if IsTable(BasePart) then
			local tab = {}

			for i,v in pairs(BasePart) do
				tab[i] = {
					Color = Color3RGB,
					Part = v,
					UnionColoring = true
				}
			end

			SyncAPI:Invoke(
				"SyncColor",
				tab
			)
		else	
			SyncAPI:Invoke(
				"SyncColor",
				{
					{
						Color = Color3RGB,
						Part = BasePart,
						UnionColoring = true
					}
				}
			)
		end
	end

	function F3XModule.ResizePart(BasePart:BasePart|{BasePart:BasePart}, CFrameV:CFrame|nil, SizeV:Vector3)
		if IsTable(BasePart) then
			local tab = {}

			for i,v in pairs(BasePart) do
				tab[i] = {
					Part = v,
					CFrame = (CFrameV or v.CFrame),
					Size = SizeV
				}
			end

			SyncAPI:Invoke(
				"SyncResize",
				tab
			)
		else	
			SyncAPI:Invoke(
				"SyncResize",
				{
					{
						Part = BasePart,
						CFrame = (CFrameV or BasePart.CFrame),
						Size = SizeV
					}
				}
			)
		end
	end

	function F3XModule.MovePart(BasePart:BasePart|{BasePart:BasePart}, CFrameV:CFrame|nil)
		if IsTable(BasePart) then
			local tab = {}

			for i,v in pairs(BasePart) do
				tab[i] = {
					Part = v,
					CFrame = (CFrameV or v.CFrame)
				}
			end
			SyncAPI:Invoke(
				"SyncMove",
				tab
			)
		else	
			SyncAPI:Invoke(
				"SyncMove",
				{
					{
						Part = BasePart,
						CFrame = (CFrameV or BasePart.CFrame)
					}
				}
			)
		end
	end

	function F3XModule.RotatePart(BasePart:BasePart|{BasePart:BasePart}, CFrameV:CFrame|nil)
		if IsTable(BasePart) then
			local tab = {}

			for i,v in pairs(BasePart) do
				tab[i] = {
					Part = v,
					CFrame = (CFrameV or v.CFrame)
				}
			end
			SyncAPI:Invoke(
				"SyncRotate",
				tab
			)
		else	
			SyncAPI:Invoke(
				"SyncRotate",
				{
					{
						Part = BasePart,
						CFrame = (CFrameV or BasePart.CFrame)
					}
				}
			)
		end
	end

	function F3XModule.CreateEffect(Parent:Instance|{BasePart:BasePart}, EffectType:string)
		EffectType = CapitalizeFirst(EffectType)

		if IsTable(Parent) then
			local tab = {}

			for i,v in pairs(Parent) do
				tab[i] = {
					Part = v,
					DecorationType = EffectType
				}
			end

			ServerEndpoint:InvokeServer(
				"CreateDecorations",
				tab
			)
		else	
			ServerEndpoint:InvokeServer(
				"CreateDecorations",
				{
					{
						Part = Parent,
						DecorationType = EffectType
					}
				}
			)
		end
	end

	function F3XModule.UpdateEffect(BasePart:BasePart|{BasePart:BasePart}, EffectChanges:{Fire:{Color:Color3|nil,SecondaryColor:Color3|nil,Heat:number|nil,Size:number|nil}|nil,Smoke:{Color:Color3|nil,RiseVelocity:number|nil,Size:number|nil}|nil,Sparkles:{SparkleColor:Color3|nil}|nil})
		if not EffectChanges then return end

		local function buildAndSend(decorationType: string, props: {[string]: any})
			local changes = {}

			if IsTable(BasePart) then
				for _, part in pairs(BasePart) do
					if typeof(part) == "Instance" and part:IsA("BasePart") then
						local entry = {
							Part = part,
							DecorationType = decorationType,
						}
						for k, v in pairs(props) do
							entry[k] = v
						end
						table.insert(changes, entry)
					end
				end
			else
				if typeof(BasePart) == "Instance" and BasePart:IsA("BasePart") then
					local entry = {
						Part = BasePart,
						DecorationType = decorationType,
					}
					for k, v in pairs(props) do
						entry[k] = v
					end
					table.insert(changes, entry)
				end
			end

			if #changes > 0 then
				ServerEndpoint:InvokeServer("SyncDecorate", changes)
			end
		end

		if EffectChanges.Fire then
			local props = {}
			local f = EffectChanges.Fire
			if f.Color or f[1] then props.Color = f.Color or f[1] end
			if f.SecondaryColor or f[2] then props.SecondaryColor = f.SecondaryColor or f[2] end
			if f.Heat or f[3] then props.Heat = f.Heat or f[3] end
			if f.Size or f[4] then props.Size = f.Size or f[4] end
			buildAndSend("Fire", props)
		end

		if EffectChanges.Smoke then
			local props = {}
			local s = EffectChanges.Smoke
			if s.Color or s[1] then props.Color = s.Color or s[1] end
			if s.RiseVelocity or s[2] then props.RiseVelocity = s.RiseVelocity or s[2] end
			if s.Size or s[3] then props.Size = s.Size or s[3] end
			buildAndSend("Smoke", props)
		end

		if EffectChanges.Sparkles then
			local props = {}
			local sp = EffectChanges.Sparkles
			if sp.SparkleColor or sp[1] then props.SparkleColor = sp.SparkleColor or sp[1] end
			buildAndSend("Sparkles", props)
		end
	end

	function F3XModule.FastEffect(BasePart:BasePart|{BasePart:BasePart}, EffectChanges:{Fire:{Color:Color3|nil,SecondaryColor:Color3|nil,Heat:number|nil,Size:number|nil}|nil,Smoke:{Color:Color3|nil,RiseVelocity:number|nil,Size:number|nil}|nil,Sparkles:{SparkleColor:Color3|nil}|nil})
		if not EffectChanges then return end
		if IsTable(BasePart) then
			for _, part in pairs(BasePart) do
				task.spawn(function()
					if EffectChanges.Fire then
						F3XModule.CreateEffect(BasePart, "Fire")	
					end

					if EffectChanges.Smoke then
						F3XModule.CreateEffect(BasePart, "Smoke")	
					end

					if EffectChanges.Sparkles then
						F3XModule.CreateEffect(BasePart, "Sparkles")	
					end

					F3XModule.UpdateEffect(BasePart, EffectChanges)
				end)
			end
		else	
			task.spawn(function()
				if EffectChanges.Fire then
					F3XModule.CreateEffect(BasePart, "Fire")	
				end

				if EffectChanges.Smoke then
					F3XModule.CreateEffect(BasePart, "Smoke")	
				end

				if EffectChanges.Sparkles then
					F3XModule.CreateEffect(BasePart, "Sparkles")	
				end

				F3XModule.UpdateEffect(BasePart, EffectChanges)
			end)
		end
	end

	function F3XModule.Delete(Inst:BasePart|{BasePart:BasePart})
		if type(Inst) == "table" then
			local args = {
				"Remove",
				Inst
			}
			SyncAPI:Invoke(unpack(args))
		else	
			if Inst:IsA("BasePart") then
				if Inst.Locked == true then
					task.spawn(function()
						F3XModule.SetLocked(Inst, false)
					end)
				end

				local args = {
					"Remove",
					{Inst}
				}
				SyncAPI:Invoke(unpack(args))
			end
		end
	end

	function F3XModule.CreateLight(Parent:Instance, LightType:string)
		if IsTable(Parent) then
			local tab = {}
			for i,v in pairs(Parent) do
				tab[i] = {
					Part = v,
					LightType = LightType
				}
			end

			SyncAPI:Invoke(
				"CreateLights",
				tab
			)
		else	
			SyncAPI:Invoke(
				"CreateLights",
				{
					{
						Part = Parent,
						LightType = LightType
					}
				}
			)
		end
	end

	function F3XModule.UpdateLight(BasePart:BasePart|{BasePart:BasePart}, LightChanges:{SpotLight:{Range:number,Brightness:number,Color:Color3,Shadows:boolean,Face:Enum.NormalId,Angle:number},SurfaceLight:{Range:number,Brightness:number,Color:Color3,Shadows:boolean,Face:Enum.NormalId,Angle:number},PointLight:{Range:number,Brightness:number,Color:Color3,Shadows:boolean}})
		if not LightChanges then return end

		local function buildAndSend(lightType: string, props: {[string]: any})
			local changes = {}

			if IsTable(BasePart) then
				for _, part in pairs(BasePart) do
					if typeof(part) == "Instance" and part:IsA("BasePart") then
						local entry = {
							Part = part,
							LightType = lightType,
						}
						for k, v in pairs(props) do
							entry[k] = v
						end
						table.insert(changes, entry)
					end
				end
			else
				if typeof(BasePart) == "Instance" and BasePart:IsA("BasePart") then
					local entry = {
						Part = BasePart,
						LightType = lightType,
					}
					for k, v in pairs(props) do
						entry[k] = v
					end
					table.insert(changes, entry)
				end
			end

			if #changes > 0 then
				ServerEndpoint:InvokeServer("SyncLighting", changes)
			end
		end

		if LightChanges.SpotLight then
			local props = {}
			local l = LightChanges.SpotLight
			if l.Range or l[1] then props.Range = l.Range or l[1] end
			if l.Brightness or l[2] then props.Brightness = l.Brightness or l[2] end
			if l.Color or l[3] then props.Color = l.Color or l[3] end
			if l.Shadows ~= nil or l[4] ~= nil then props.Shadows = l.Shadows or l[4] end
			if l.Face or l[5] then props.Face = l.Face or l[5] end
			if l.Angle or l[6] then props.Angle = l.Angle or l[6] end
			buildAndSend("SpotLight", props)
		end

		if LightChanges.SurfaceLight then
			local props = {}
			local l = LightChanges.SurfaceLight
			if l.Range or l[1] then props.Range = l.Range or l[1] end
			if l.Brightness or l[2] then props.Brightness = l.Brightness or l[2] end
			if l.Color or l[3] then props.Color = l.Color or l[3] end
			if l.Shadows ~= nil or l[4] ~= nil then props.Shadows = l.Shadows or l[4] end
			if l.Face or l[5] then props.Face = l.Face or l[5] end
			if l.Angle or l[6] then props.Angle = l.Angle or l[6] end
			buildAndSend("SurfaceLight", props)
		end

		if LightChanges.PointLight then
			local props = {}
			local l = LightChanges.PointLight
			if l.Range or l[1] then props.Range = l.Range or l[1] end
			if l.Brightness or l[2] then props.Brightness = l.Brightness or l[2] end
			if l.Color or l[3] then props.Color = l.Color or l[3] end
			if l.Shadows ~= nil or l[4] ~= nil then props.Shadows = l.Shadows or l[4] end
			buildAndSend("PointLight", props)
		end
	end

	function F3XModule.FastLight(BasePart:BasePart, LightChanges:{SpotLight:{Range:number,Brightness:number,Color:Color3,Shadows:boolean,Face:Enum.NormalId,Angle:number},SurfaceLight:{Range:number,Brightness:number,Color:Color3,Shadows:boolean,Face:Enum.NormalId,Angle:number},PointLight:{Range:number,Brightness:number,Color:Color3,Shadows:boolean}})
		if not LightChanges then return end
		if IsTable(BasePart) then
			for _, part in pairs(BasePart) do
				task.spawn(function()
					if LightChanges.SpotLight then
						F3XModule.CreateLight(BasePart, "SpotLight")	
					end

					if LightChanges.SurfaceLight then
						F3XModule.CreateLight(BasePart, "SurfaceLight")	
					end

					if LightChanges.PointLight then
						F3XModule.CreateLight(BasePart, "PointLight")	
					end

					F3XModule.UpdateLight(BasePart, LightChanges)
				end)
			end
		else	
			task.spawn(function()
				if LightChanges.SpotLight then
					F3XModule.CreateLight(BasePart, "SpotLight")	
				end

				if LightChanges.SurfaceLight then
					F3XModule.CreateLight(BasePart, "SurfaceLight")	
				end

				if LightChanges.PointLight then
					F3XModule.CreateLight(BasePart, "PointLight")	
				end

				F3XModule.UpdateLight(BasePart, LightChanges)
			end)
		end
	end

	function F3XModule.SetCollision(BasePart:BasePart|{BasePart:BasePart}, CollisionV:boolean)
		if IsTable(BasePart) then
			local tab = {}

			for i,v in pairs(BasePart) do
				tab[i] ={
					Part = v,
					CanCollide = CollisionV
				}
			end

			local args = {
				"SyncCollision",
				tab
			}
			SyncAPI:Invoke(unpack(args))
		else	
			local args = {
				"SyncCollision",
				{
					{
						Part = BasePart,
						CanCollide = CollisionV
					}
				}
			}
			SyncAPI:Invoke(unpack(args))
		end
	end

	function F3XModule.SetAnchor(BasePart:BasePart, AnchoredV:boolean)
		if IsTable(BasePart) then
			local tab = {}

			for i,v in pairs(BasePart) do
				tab[i] ={
					Part = v,
					Anchored = AnchoredV
				}
			end

			local args = {
				"SyncAnchor",
				tab
			}
			SyncAPI:Invoke(unpack(args))
		else	
			local args = {
				"SyncAnchor",
				{
					{
						Part = BasePart,
						Anchored = AnchoredV
					}
				}
			}
			SyncAPI:Invoke(unpack(args))
		end
	end

	function F3XModule.CreateTexture(FaceV:Enum.NormalId, Parent:Instance|{}, TextureTypeV:string)
		if IsTable() then
			local tab = {}
			for i,v in pairs(Parent) do
				tab[i] = {
					Part = Parent,
					Face = FaceV or Enum.NormalId.Front,
					TextureType = TextureTypeV or "Decal"
				}
			end

			local args = {
				"CreateTextures",
				tab
			}

			SyncAPI:Invoke(unpack(args))
		end

		SyncAPI:Invoke(
			"CreateTextures",
			{
				{
					Part = Parent,
					Face = FaceV or Enum.NormalId.Front,
					TextureType = TextureTypeV or "Decal"
				}
			}
		)
	end

	function F3XModule.UpdateTexture(FaceV:Enum.NormalId, Parent:Instance, TextureId:number, TransparencyV:number, TextureTypeV:string)
		if IsTable(Parent) then
			local tab = {}
			for i,v in pairs(Parent) do
				tab[i] = {
					Part = Parent,
					Face = FaceV,
					TextureType = TextureTypeV or "Decal",
					Texture = "rbxassetid://"..getImageIdFromAssetId(TextureId),
					Transparency = TransparencyV
				}
			end

			local args = {
				"SyncTexture",
				tab
			}
			ServerEndpoint:InvokeServer(unpack(args))
		else			
			local args = {
				"SyncTexture",
				{
					{
						Part = Parent,
						Face = FaceV,
						TextureType = TextureTypeV or "Decal",
						Texture = "rbxassetid://"..getImageIdFromAssetId(TextureId),
						Transparency = TransparencyV
					}
				}
			}
			ServerEndpoint:InvokeServer(unpack(args))	
		end
	end

	function F3XModule.QuickTexture(BasePart:BasePart|{BasePart}, TextureId:number, Transparency:number|nil, Face:Enum.NormalId, TextureType:string)
		if IsTable(BasePart) then
			for i,v in pairs(BasePart) do
				if not v:IsA("BasePart") then continue end
				task.spawn(function()
					F3XModule.CreateTexture(Face, v, TextureType)
					F3XModule.UpdateTexture(Face, v, TextureId, Transparency, TextureType)
				end)
			end
		else	
			task.spawn(function()
				F3XModule.CreateTexture(Face, BasePart, TextureType)
				F3XModule.UpdateTexture(Face, BasePart, TextureId, Transparency, TextureType)
			end)
		end
	end

	function F3XModule.MakeWelds(Parts:{BasePart})
		if #Parts < 2 then return warn("F3XModule.MakeWelds() requires more then "..#Parts.." part(s).") end
		local args = {
			"CreateWelds",
			Parts,
			Parts[1]
		}
		ServerEndpoint:InvokeServer(unpack(args))
	end

	function F3XModule.BreakWelds(Parts:{BasePart})
		local foundwelds = {}

		for i,v in pairs(Parts) do
			local welds = v:GetChildren()
			for i,c in pairs(welds) do
				if c:IsA("Weld") then
					table.insert(foundwelds,c)
				end
			end
		end

		if #foundwelds < 1 then return end
		local args = {
			"RemoveWelds",
			foundwelds
		}
		ServerEndpoint:InvokeServer(unpack(args))
	end

	function F3XModule.SetPartTransparency(BasePart:BasePart, TransparencyV:number)
		if IsTable(BasePart) then
			local tab = {}

			for i,v in pairs(BasePart) do
				tab[#tab+1] = {
					Part = v,
					Transparency = TransparencyV
				}
			end
			local args = {
				"SyncMaterial",
				tab
			}

			SyncAPI:Invoke(unpack(args))
		else	
			local args = {
				"SyncMaterial",
				{
					{
						Part = BasePart,
						Transparency = TransparencyV
					}
				}
			}
			SyncAPI:Invoke(unpack(args))
		end
	end

	function F3XModule.SetPartReflectance(BasePart:BasePart, ReflectanceV:number)
		if IsTable(BasePart) then
			local tab = {}

			for i,v in pairs(BasePart) do
				tab[#tab+1] = {
					Part = v,
					Reflectance = ReflectanceV
				}
			end
			local args = {
				"SyncMaterial",
				tab
			}

			SyncAPI:Invoke(unpack(args))
		else	
			SyncAPI:Invoke(
				"SyncMaterial",
				{
					{
						Part = BasePart,
						Reflectance = ReflectanceV
					}
				}
			)
		end
	end

	function F3XModule.SetPartMaterial(BasePart:BasePart, MaterialV:Enum.Material)
		if IsTable(BasePart) then
			local tab = {}

			for i,v in pairs(BasePart) do
				tab[#tab+1] = {
					Part = v,
					Material = MaterialV
				}
			end
			local args = {
				"SyncMaterial",
				tab
			}

			SyncAPI:Invoke(unpack(args))
		else	
			SyncAPI:Invoke(
				"SyncMaterial",
				{
					{
						Part = BasePart,
						Material = MaterialV
					}
				}
			)
		end
	end

	function F3XModule.CreateMesh(BasePart:BasePart)
		if IsTable(BasePart) then
			local tab = {}
			for i,v in pairs(BasePart) do
				tab[#tab+1] = {
					Part = v
				}
			end

			local args = {
				"CreateMeshes",
				tab
			}
			SyncAPI:Invoke(unpack(args))
		else	
			local args = {
				"CreateMeshes",
				{
					{
						"CreateMeshes",
						Part = BasePart
					}
				}
			}
			SyncAPI:Invoke(unpack(args))
		end
	end

	function F3XModule.UpdateMesh(BasePart:BasePart, MeshIdV:number|nil, MeshTextureIdV:number|nil, MeshTypeV:Enum.MeshType|nil, MeshScale:Vector3|nil, MeshOffset:Vector3|nil, VertexColorV:Vector3|nil)
		if IsTable(BasePart) then
			local tab = {}
			for i,v in pairs(BasePart) do
				tab[#tab+1] = {
					Part = v,
					MeshType = MeshTypeV or Enum.MeshType.FileMesh,
					MeshId = "rbxassetid://"..(MeshIdV or 0),
					TextureId = "rbxassetid://"..(MeshTextureIdV or 0),
					Scale = MeshScale or Vector3.new(1,1,1),
					Offset = MeshOffset or Vector3.zero,
					VertexColor = VertexColorV or Vector3.new(1,1,1)
				}
			end
			local args = {
				"SyncMesh",
				tab
			}
			SyncAPI:Invoke(unpack(args))
		else
			task.spawn(function()
				SyncAPI:Invoke(
					"SyncMesh",
					{
						{
							Part = BasePart,
							MeshType = MeshTypeV or Enum.MeshType.FileMesh,
							MeshId = "rbxassetid://"..(MeshIdV or 0),
							TextureId = "rbxassetid://"..(MeshTextureIdV or 0),
							Scale = MeshScale or Vector3.new(1,1,1),
							Offset = MeshOffset or Vector3.zero,
							VertexColor = VertexColorV or Vector3.new(1,1,1)
						}
					}
				)
			end)
		end
	end

	function F3XModule.QuickMesh(BasePart:BasePart|{}, MeshArguments:{MeshIdV:number|nil, MeshTextureIdV:number|nil, MeshTypeV:Enum.MeshType|nil, MeshScale:Vector3|nil, MeshOffset:Vector3|nil, VertexColorV:Vector3|nil})
		if IsTable(BasePart) then
			for i,v in pairs(BasePart) do
				local MeshIdV, MeshTextureIdV, MeshTypeV, MeshScale, MeshOffset, VertexColorV = table.unpack(MeshArguments)
				F3XModule.CreateMesh(BasePart)
				F3XModule.UpdateMesh(v, MeshIdV, MeshTextureIdV, MeshTypeV, MeshScale, MeshOffset, VertexColorV)
			end
		else
			local MeshIdV, MeshTextureIdV, MeshTypeV, MeshScale, MeshOffset, VertexColorV = table.unpack(MeshArguments)
			F3XModule.CreateMesh(BasePart)
			F3XModule.UpdateMesh(BasePart, MeshIdV, MeshTextureIdV, MeshTypeV, MeshScale, MeshOffset, VertexColorV)
		end
	end

	function F3XModule.SetLocked(Inst:BasePart | {BasePart}, IsLocked:boolean)
		if type(Inst) == "table" then
			local args = {
				"SetLocked",
				Inst,
				IsLocked or false
			}
			ServerEndpoint:InvokeServer(unpack(args))
		else	
			local args = {
				"SetLocked",
				{Inst},
				IsLocked or false
			}
			ServerEndpoint:InvokeServer(unpack(args))
		end
	end

	function F3XModule.CreateGroup(Type:string, Parent:Instance, Items:{})
		SyncAPI:Invoke(
			"CreateGroup",
			Type,
			Parent,
			Items
		)
	end

	function F3XModule.Ungroup(Group:{})
		SyncAPI:Invoke(
			"Ungroup",
			Group
		)
	end

	function F3XModule.SetParent(Items:{}, Parent:Instance)
		SyncAPI:Invoke(
			"SetParent",
			Items,
			Parent
		)
	end

	function F3XModule.SetName(Items:{}, Name:string)
		SyncAPI:Invoke(
			"SetName",
			Items,
			Name
		)
	end

	function F3XModule.UndoRemove(Objects:{})
		SyncAPI:Invoke(
			"UndoRemove",
			Objects
		)
	end

	function F3XModule.Export(Parts:{})
		SyncAPI:Invoke(
			"Export",
			Parts
		)
	end

	function F3XModule.SetMouseLockEnabled(Boolean:boolean)
		SyncAPI:Invoke(
			"SetMouseLockEnabled",
			Boolean
		)
	end

	function F3XModule.RemoveFromPlayer(Player:string | Player, PartName:string)
		local plr
		if typeof(Player) == "Instance" then
			plr = Player
		else	
			plr = F3XModule.GetPlayerFromText(Player)
		end

		if plr then
			if plr.Character then
				for i,v in pairs(plr.Character:GetDescendants()) do
					if v:IsA("BasePart") and v.Name:lower():match(PartName) then
						task.spawn(function()
							F3XModule.Delete(v)
						end)
					end
				end
			else	
				task.spawn(function()
					plr.CharacterRemoving:Wait()
					plr.CharacterAdded:Wait()
					for i,v in pairs(plr.Character:GetDescendants()) do
						if v:IsA("BasePart") and v.Name:lower():match(PartName) then
							task.spawn(function()
								F3XModule.Delete(v)
							end)
						end
					end
				end)
			end
		end
	end

	function F3XModule.RemoveToolsFromPlayer(Player:string | Player)
		local plr
		if typeof(Player) == "Instance" then
			plr = Player
		else	
			plr = F3XModule.GetPlayerFromText(Player)
		end

		if plr then
			for i,v in pairs(plr.Backpack:GetChildren()) do
				if v:IsA("Tool") or v:IsA("HopperBin") then
					if v:FindFirstChild("Handle") then
						F3XModule.Delete(v:FindFirstChild("Handle"))
					end
				end
			end
			if plr.Character then
				for i,v in pairs(plr.Character:GetChildren()) do
					if v:IsA("Tool") or v:IsA("HopperBin") then
						if v:FindFirstChild("Handle") then
							F3XModule.Delete(v:FindFirstChild("Handle"))
						end
					end
				end
			end
		end
	end

	function F3XModule.Kill(Player:string | Player)
		local plr
		if typeof(Player) == "Instance" then
			plr = Player
		else	
			plr = F3XModule.GetPlayerFromText(Player)
		end

		if typeof(Player) == "number" then
			plr = F3XModule.GetPlayerFromText(Player)
		elseif typeof(Player) == "string" then
			if Player:lower() == "all" then
				for i,v in pairs(game:GetService("Players"):GetPlayers()) do
					if v then
						if v.Character then
							task.spawn(function()
								local Head = v.Character:FindFirstChild("Head")
								if not Head then return end
								F3XModule.Delete(Head)
							end)
						end
					end
				end
				return
			elseif Player:lower() == "others" then
				for i,v in pairs(game:GetService("Players"):GetPlayers()) do
					if v and v ~= game:GetService("Players").LocalPlayer then
						if v.Character then
							task.spawn(function()
								local Head = v.Character:FindFirstChild("Head")
								if not Head then return end
								F3XModule.Delete(Head)
							end)
						end
					end
				end
				return
			else	
				plr = F3XModule.GetPlayerFromText(Player)
			end
		elseif typeof(Player) == "Instance" then
			plr = Player
		end
		if plr.Character then
			task.spawn(function()
				local Head = plr.Character:FindFirstChild("Head")
				if not Head then return end
				F3XModule.Delete(Head)
			end)
		end
	end

	function F3XModule.KillSilent(Player:string | number | Player)
		local plr
		if typeof(Player) == "Instance" then
			plr = Player
		else	
			plr = F3XModule.GetPlayerFromText(Player)
		end

		if typeof(Player) == "number" then
			plr = F3XModule.GetPlayerFromText(Player)
		elseif typeof(Player) == "string" then
			if Player:lower() == "all" then
				for i,v in pairs(game:GetService("Players"):GetPlayers()) do
					if v then
						if v.Character then
							task.spawn(function()
								local Part = v.Character:FindFirstChild("Torso") or v.Character:FindFirstChild("UpperTorso") or v.Character:FindFirstChild("Head")
								if not Part then return end
								F3XModule.ResizePart(Part, Part.CFrame+Vector3.new(0,0.1,0), (Part.Size*1.025))
								if v.Character.Humanoid.Health > 0 then
									F3XModule.Delete(Part)
								end
							end)
						end
					end
				end
				return
			elseif Player:lower() == "others" then
				for i,v in pairs(game:GetService("Players"):GetPlayers()) do
					if v and v ~= game:GetService("Players").LocalPlayer then
						if v.Character then
							task.spawn(function()
								local Part = v.Character:FindFirstChild("Torso") or v.Character:FindFirstChild("UpperTorso") or v.Character:FindFirstChild("Head")
								if not Part then return end
								F3XModule.ResizePart(Part, Part.CFrame+Vector3.new(0,0.1,0), (Part.Size*1.025))
								if v.Character.Humanoid.Health > 0 then
									F3XModule.Delete(Part)
								end
							end)
						end
					end
				end
				return
			else	
				plr = F3XModule.GetPlayerFromText(Player)
			end
		elseif typeof(Player) == "Instance" then
			plr = Player
		end
		if plr.Character then
			task.spawn(function()
				local Part = plr.Character:FindFirstChild("Torso") or plr.Character:FindFirstChild("UpperTorso") or plr.Character:FindFirstChild("Head")
				if not Part then return end
				F3XModule.ResizePart(Part, Part.CFrame+Vector3.new(0,1,0), (Part.Size*1.025))
				if plr.Character.Humanoid.Health > 0 then
					F3XModule.Delete(Part)
				end
			end)
		end
	end

	function F3XModule.PasteTextures(instance:Instance, DecalId:number, DecalType:string)
		for i,v in pairs(instance:GetDescendants()) do
			if v:IsA("BasePart") then
				for i,face in pairs(Enum.NormalId:GetEnumItems()) do
					task.spawn(function() 
						F3XModule.CreateTexture(face, instance, DecalType)
						F3XModule.UpdateTexture(face, instance, DecalId, 0)
					end)
					task.wait()
				end
			end
		end
	end

	function F3XModule:OnPlayerRespawned(callback: (plr: Player, char: Model) -> nil, plr: Player | string)
		if type(plr) == "string" then
			plr = F3XModule.GetPlayerFromText(plr) or plr
		end

		if type(callback) ~= "function" then
			warn(debug.traceback("Expected 'function', got '" .. type(callback) .. "'.", 1))
			return
		end

		if typeof(plr) ~= "Instance" or not plr:IsA("Player") then
			warn(debug.traceback("Expected 'Player', got '" .. type(plr) .. "'.", 1))
			return
		end

		self._plrtrack = plr

		local connection = plr.CharacterAdded:Connect(function(char)
			task.spawn(function()
				local character = plr.Character or plr.CharacterAdded:Wait()
				local humanoid = character:WaitForChild("Humanoid")
				self.SyncAPI = FindSyncAPI(plr)
			end)
			callback(plr, char)
		end)

		local FakeConnection = {}
		FakeConnection.Connected = true

		local connectionindexpos = #getgenv().F3XConnections +1
		getgenv().F3XConnections[connectionindexpos] = FakeConnection

		function FakeConnection:Disconnect()
			FakeConnection.Connected = false
			self._plrtrack = nil
			connection:Disconnect()
			getgenv().F3XConnections[connectionindexpos] = nil
		end

		return FakeConnection, connectionindexpos
	end

	function F3XModule:OnPlayerDied(callback: (plr: Player, char: Model|nil) -> nil, plr: Player | string)
		if type(plr) == "string" then
			plr = F3XModule.GetPlayerFromText(plr) or plr
		end

		if type(callback) ~= "function" then
			warn(debug.traceback("Expected 'function', got '" .. type(callback) .. "'.", 1))
			return {Connected = false}
		end

		if typeof(plr) ~= "Instance" or not plr:IsA("Player") then
			warn(debug.traceback("Expected 'Player', got '" .. type(plr) .. "'.", 1))
			return {Connected = false}
		end

		self._plrtrackdeath = plr

		local Humanoid = plr.Character:FindFirstChildWhichIsA("Humanoid") or plr.Character:WaitForChild("Humanoid",30)

		if typeof(Humanoid) ~= "Instance" or not Humanoid:IsA("Humanoid") then
			warn(debug.traceback("Expected 'Humanoid', got '" .. type(Humanoid) .. "'.", 1))
			return {Connected = false}
		end

		local connection = Humanoid.Died:Connect(function()
			callback(plr, plr.Character)
		end)

		local FakeConnection = {}
		FakeConnection.Connected = true

		local connectionindexpos = #getgenv().F3XConnections +1
		getgenv().F3XConnections[connectionindexpos] = FakeConnection

		function FakeConnection:Disconnect()
			FakeConnection.Connected = false
			self._plrtrackdeath = nil
			connection:Disconnect()
			getgenv().F3XConnections[connectionindexpos] = nil
		end

		return FakeConnection, connectionindexpos
	end

	function F3XModule.LoopRemoveTools(plr: Player | string)
		local returnedlist = {}
		if type(plr) == "string" then
			if plr:lower() == "others" then
				for _, v in pairs(game.Players:GetPlayers()) do
					if v ~= game.Players.LocalPlayer then
						local con,ind = F3XModule.LoopRemoveTools(v)
						returnedlist[#returnedlist+1] = {Connection = con, Index = ind}
					end
				end
			elseif plr:lower() == "all" then	
				for _, v in pairs(game.Players:GetPlayers()) do
					local con,ind = F3XModule.LoopRemoveTools(v)
					returnedlist[#returnedlist+1] = {Connection = con, Index = ind}
				end
			else	
				plr = F3XModule.GetPlayerFromText(plr) or plr
			end
		end
		if typeof(plr) ~= "Instance" or not plr:IsA("Player") then
			warn(debug.traceback("Expected 'Player', got '" .. type(plr) .. "'.", 1))
			return { Connected = false }
		end

		F3XModule._plrtrackremovetools = plr

		local childAddedConn: RBXScriptConnection? = nil

		local function hookCharacter(character: Model)
			if childAddedConn then
				childAddedConn:Disconnect()
				childAddedConn = nil
			end

			for _, child in character:GetChildren() do
				if child:IsA("Tool") then
					local handle = child:FindFirstChild("Handle")
					if handle then
						F3XModule.Delete(handle)
					end
				end
			end

			childAddedConn = character.ChildAdded:Connect(function(child)
				if child:IsA("Tool") then
					local handle = child:FindFirstChild("Handle")
					if handle then
						F3XModule.Delete(handle)
					end
				end
			end)
		end

		if plr.Character then
			hookCharacter(plr.Character)
		end

		local characterAddedConn = plr.CharacterAdded:Connect(hookCharacter)

		local FakeConnection = {
			Connected = true,
		}

		local connectionindexpos = #getgenv().F3XConnections +1
		getgenv().F3XConnections[connectionindexpos] = FakeConnection

		function FakeConnection:Disconnect()
			if not self.Connected then
				return
			end
			self.Connected = false
			F3XModule._plrtrackremovetools = nil

			if childAddedConn then
				childAddedConn:Disconnect()
				childAddedConn = nil
			end
			characterAddedConn:Disconnect()
			getgenv().F3XConnections[connectionindexpos] = nil
		end

		return FakeConnection, connectionindexpos
	end

	function F3XModule.LoopKill(plr: Player | string)
		local returnedlist = {}
		if type(plr) == "string" then
			if plr:lower() == "others" then
				for _, v in pairs(game.Players:GetPlayers()) do
					if v ~= game.Players.LocalPlayer then
						local con,ind = F3XModule.LoopKill(v)
						returnedlist[#returnedlist+1] = {Connection = con, Index = ind}
					end
				end
			elseif plr:lower() == "all" then	
				for _, v in pairs(game.Players:GetPlayers()) do
					local con,ind = F3XModule.LoopKill(v)
					returnedlist[#returnedlist+1] = {Connection = con, Index = ind}
				end
			else	
				plr = F3XModule.GetPlayerFromText(plr) or plr
			end
		end
		if typeof(plr) ~= "Instance" or not plr:IsA("Player") then
			warn(debug.traceback("Expected 'Player', got '" .. type(plr) .. "'.", 1))
			return { Connected = false }
		end

		F3XModule._plrtrackloopkill = plr

		local function killOnCharacter(character: Model)
			local head = character:FindFirstChild("Head")
			if not head then
				local deadline = os.clock() + 10
				while not head and os.clock() < deadline do
					if not character.Parent then
						return
					end
					task.wait(0.1)
					head = character:FindFirstChild("Head")
				end
			end

			if not head or not character.Parent then
				return
			end
			F3XModule.KillPlayerSilent(plr)
		end

		if plr.Character then
			task.spawn(killOnCharacter, plr.Character)
		end

		local characterAddedConn = plr.CharacterAdded:Connect(function(character)
			task.spawn(killOnCharacter, character)
		end)

		local FakeConnection = {
			Connected = true,
		}
		local connectionindexpos = #getgenv().F3XConnections +1
		getgenv().F3XConnections[connectionindexpos] = FakeConnection

		function FakeConnection:Disconnect()
			if not self.Connected then
				return
			end
			self.Connected = false
			F3XModule._plrtrackloopkill = nil
			characterAddedConn:Disconnect()
			getgenv().F3XConnections[connectionindexpos] = nil
		end

		return FakeConnection, connectionindexpos
	end

	function F3XModule.LoopDelete(plr: Player | string)
		local returnedlist = {}
		if type(plr) == "string" then
			if plr:lower() == "others" then
				for _, v in pairs(game.Players:GetPlayers()) do
					if v ~= game.Players.LocalPlayer then
						local con,ind = F3XModule.LoopDelete(v)
						returnedlist[#returnedlist+1] = {Connection = con, Index = ind}
					end
				end
			elseif plr:lower() == "all" then	
				for _, v in pairs(game.Players:GetPlayers()) do
					local con,ind = F3XModule.LoopDelete(v)
					returnedlist[#returnedlist+1] = {Connection = con, Index = ind}
				end
			else	
				plr = F3XModule.GetPlayerFromText(plr) or plr
			end
		end
		if typeof(plr) ~= "Instance" or not plr:IsA("Player") then
			warn(debug.traceback("Expected 'Player', got '" .. type(plr) .. "'.", 1))
			return { Connected = false }
		end

		F3XModule._plrtrackloopdel = plr

		local function killOnCharacter(character: Model)
			if character.Parent then
				return
			end
			F3XModule.Delete(character)
		end

		if plr.Character then
			task.spawn(killOnCharacter, plr.Character)
		end

		local characterAddedConn = plr.CharacterAdded:Connect(function(character)
			task.spawn(killOnCharacter, character)
		end)

		local FakeConnection = {
			Connected = true,
		}
		local connectionindexpos = #getgenv().F3XConnections +1
		getgenv().F3XConnections[connectionindexpos] = FakeConnection

		function FakeConnection:Disconnect()
			if not self.Connected then
				return
			end
			self.Connected = false
			F3XModule._plrtrackloopdel = nil
			characterAddedConn:Disconnect()
			getgenv().F3XConnections[connectionindexpos] = nil
		end

		return FakeConnection, connectionindexpos
	end

	------------------------------------

	local Plugins = {}
	if getgenv().F3XModule_Settings.UsePlugins == true then
		print("Loading...",true)

		function getfiles(path)
			if not listfiles then return {} end
			local s, result = pcall(function() return listfiles(path) end)
			return s and result or {}
		end

		function addPlugin(name)
			local fileName = name
			if not name:match("%.btoolsmodule$") then
				fileName = name .. ".btoolsmodule"
			end

			local success, source = pcall(readfile, fileName)
			if not success or not source then
				success, source = pcall(readfile, "/" .. fileName)
			end

			if not success or not source then
				warn("Could not read plugin file:", fileName)
				return
			end

			local chunk, compileErr = loadstring(source)
			if not chunk then
				warn("Failed to compile plugin", fileName, compileErr)
				return
			end

			local ok, plugin = pcall(chunk)
			if not ok then
				warn("Error while running plugin", fileName, plugin)
				return
			end

			if type(plugin) ~= "table" then
				warn("Plugin", fileName, "did not return a table")
				return
			end

			if type(plugin.func) ~= "function" then
				warn("Plugin", fileName, "has no .func function")
				return
			end

			local pluginName = plugin.Name or fileName:gsub("%.btoolsmodule$", "")
			Plugins[#Plugins+1] = pluginName
			F3XModule[pluginName] = function(...)
				return plugin.func(F3XModule, ...)
			end
		end

		task.spawn(function()
			if not isfile("F3XModule") then
				makefolder("F3XModule")
			end
			local files = getfiles("F3XModule")

			for _, file in pairs(files) do
				addPlugin(file)
			end

			F3XModule.PluginsLoaded = true
		end)
	end

	local timeout = 30

	if F3XModule.IsModuleReady and F3XModule.PluginsLoaded then
		print("F3XModule Loaded!",true, "["..getgenv().F3XModuleVer.."]")
		return F3XModule
	else	
		print("Loading...",true)
		repeat
			wait(1)
			timeout -= 1
		until
		(F3XModule.IsModuleReady and F3XModule.PluginsLoaded) or timeout <= 0

		if timeout <= 0 then
			warn("Timed out; SyncAPIFound="..tostring((SyncAPI ~= nil)..", ServerEndpointFound="..tostring((ServerEndpoint ~= nil)),true), "["..getgenv().F3XModuleVer.."]")
			return
		end

		if #Plugins > 0 then
			print("F3XModule Loaded with ("..#Plugins..") Plugins:", table.concat(Plugins, ", "),true, "["..getgenv().F3XModuleVer.."]")
		else	
			print("F3XModule Loaded!", true, "["..getgenv().F3XModuleVer.."]")
		end

		getgenv().F3XModule = F3XModule
		return F3XModule
	end
end

local updatesresponse = LoadUpdates()

if updatesresponse then
	if type(updatesresponse) == "string" and updatesresponse:find("!Error: ") then
		return warn(updatesresponse)
	else	
		return loadstring(updatesresponse)()
	end
else	
	return MainMod()
end
