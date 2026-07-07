--[[
    MM2 Script - Rayfield (Полная версия)
    by .ftgs & NF Project
]]

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "MM2 Script",
    Icon = "skull",
    LoadingTitle = "MM2 Script Loading",
    LoadingSubtitle = "by .ftgs & NF",
    Theme = "DarkBlue",
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false,
    ConfigurationSaving = { Enabled = true, FolderName = "mm2script", FileName = "config" },
    Discord = { Enabled = false, Invite = "", RememberJoins = true },
    KeySystem = false,
})

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Camera = Workspace.CurrentCamera
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Variables
local ESPEnabled = false
local ESPBoxEnabled = true
local ESPNameEnabled = true
local ESPHealthEnabled = true
local ESPDistanceEnabled = true
local ESPObjects = {}
local AutoFarmEnabled = false
local KillAuraEnabled = false
local GodModeEnabled = false
local CoinFarmEnabled = false
local KillAuraRange = 15
local WalkSpeed = 16
local JumpPower = 50
local NoclipEnabled = false
local FlyEnabled = false
local FlySpeed = 50
local NoclipConnection = nil
local FlyConnection = nil
local FlingEnabled = false
local FlingConnection = nil
local FlingParts = {}
local GunGrabEnabled = false
local GunGrabConnection = nil

-- ==================== ESP ====================
local function GetPlayerRole(player)
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        for _, item in ipairs(backpack:GetChildren()) do
            if item:IsA("Tool") then
                local name = item.Name:lower()
                if name:find("knife") then return "murderer" end
                if name:find("gun") or name:find("pistol") or name:find("revolver") then return "sheriff" end
            end
        end
    end
    if player.Character then
        for _, item in ipairs(player.Character:GetChildren()) do
            if item:IsA("Tool") then
                local name = item.Name:lower()
                if name:find("knife") then return "murderer" end
                if name:find("gun") or name:find("pistol") or name:find("revolver") then return "sheriff" end
            end
        end
    end
    return "innocent"
end

local function GetRoleColor(role)
    if role == "murderer" then return Color3.fromRGB(255, 0, 0) end
    if role == "sheriff" then return Color3.fromRGB(0, 100, 255) end
    return Color3.fromRGB(128, 128, 128)
end

local function GetRoleName(role)
    if role == "murderer" then return "МАНЬЯК" end
    if role == "sheriff" then return "ШЕРИФ" end
    return ""
end

local function CreateESP(player)
    if player == LocalPlayer then return end
    local espData = { player = player }
    local box = Drawing.new("Square")
    box.Visible = false; box.Thickness = 1.5; box.Filled = false; box.Color = Color3.fromRGB(255,255,255)
    espData.Box = box
    local nameText = Drawing.new("Text")
    nameText.Visible = false; nameText.Size = 13; nameText.Center = true; nameText.Outline = true
    nameText.OutlineColor = Color3.fromRGB(0,0,0); nameText.Color = Color3.fromRGB(255,255,255); nameText.Text = player.Name
    espData.NameText = nameText
    local healthBg = Drawing.new("Square")
    healthBg.Visible = false; healthBg.Filled = true; healthBg.Color = Color3.fromRGB(40,40,40)
    espData.HealthBg = healthBg
    local healthBar = Drawing.new("Square")
    healthBar.Visible = false; healthBar.Filled = true; healthBar.Color = Color3.fromRGB(0,255,0)
    espData.HealthBar = healthBar
    local distanceText = Drawing.new("Text")
    distanceText.Visible = false; distanceText.Size = 12; distanceText.Center = true; distanceText.Outline = true
    distanceText.OutlineColor = Color3.fromRGB(0,0,0); distanceText.Color = Color3.fromRGB(255,255,255)
    espData.DistanceText = distanceText
    ESPObjects[player] = espData
end

local function RemoveESP(player)
    local espData = ESPObjects[player]
    if espData then
        if espData.Box then espData.Box:Remove() end
        if espData.NameText then espData.NameText:Remove() end
        if espData.HealthBg then espData.HealthBg:Remove() end
        if espData.HealthBar then espData.HealthBar:Remove() end
        if espData.DistanceText then espData.DistanceText:Remove() end
        ESPObjects[player] = nil
    end
end

local function UpdateESP()
    for player, espData in pairs(ESPObjects) do
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") and char:FindFirstChild("Head") then
            local root = char.HumanoidRootPart
            local head = char.Head
            local humanoid = char.Humanoid
            local role = GetPlayerRole(player)
            local color = GetRoleColor(role)
            local roleName = GetRoleName(role)
            local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
            local rootPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
            if headPos.Z > 0 then
                local head2D = Vector2.new(headPos.X, headPos.Y)
                local root2D = Vector2.new(rootPos.X, rootPos.Y)
                local height = math.abs(root2D.Y - head2D.Y)
                local width = height * 0.65
                local boxX = head2D.X - width / 2
                local boxY = head2D.Y
                local dist = 0
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    dist = (LocalPlayer.Character.HumanoidRootPart.Position - root.Position).Magnitude
                end
                if ESPBoxEnabled then
                    espData.Box.Visible = true; espData.Box.Position = Vector2.new(boxX, boxY)
                    espData.Box.Size = Vector2.new(width, height); espData.Box.Color = color
                else espData.Box.Visible = false end
                if ESPNameEnabled then
                    espData.NameText.Visible = true; espData.NameText.Position = Vector2.new(head2D.X, boxY - 18)
                    local displayName = player.Name
                    if roleName ~= "" then displayName = player.Name .. " [" .. roleName .. "]" end
                    espData.NameText.Text = displayName; espData.NameText.Color = roleName ~= "" and color or Color3.fromRGB(255,255,255)
                else espData.NameText.Visible = false end
                if ESPHealthEnabled then
                    local hp = humanoid.Health / humanoid.MaxHealth
                    local barX = boxX - 5; local barY = boxY; local barW = 3; local barH = height
                    espData.HealthBg.Visible = true; espData.HealthBg.Position = Vector2.new(barX, barY); espData.HealthBg.Size = Vector2.new(barW, barH)
                    espData.HealthBar.Visible = true; espData.HealthBar.Position = Vector2.new(barX, barY + barH * (1 - hp)); espData.HealthBar.Size = Vector2.new(barW, barH * hp)
                    espData.HealthBar.Color = hp > 0.6 and Color3.fromRGB(0,255,0) or (hp > 0.3 and Color3.fromRGB(255,255,0) or Color3.fromRGB(255,0,0))
                else espData.HealthBg.Visible = false; espData.HealthBar.Visible = false end
                if ESPDistanceEnabled then
                    espData.DistanceText.Visible = true; espData.DistanceText.Position = Vector2.new(head2D.X, boxY + height + 2)
                    espData.DistanceText.Text = math.floor(dist + 0.5) .. "m"; espData.DistanceText.Color = Color3.fromRGB(200,200,200)
                else espData.DistanceText.Visible = false end
            else
                espData.Box.Visible = false; espData.NameText.Visible = false
                espData.HealthBg.Visible = false; espData.HealthBar.Visible = false; espData.DistanceText.Visible = false
            end
        else
            espData.Box.Visible = false; espData.NameText.Visible = false
            espData.HealthBg.Visible = false; espData.HealthBar.Visible = false; espData.DistanceText.Visible = false
        end
    end
end

local function ToggleESP(state)
    ESPEnabled = state
    if state then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and not ESPObjects[player] then CreateESP(player) end
        end
    else
        for player, _ in pairs(ESPObjects) do RemoveESP(player) end
    end
end

task.spawn(function() while true do if ESPEnabled then UpdateESP() end; task.wait() end end)

-- ==================== NOCLIP ====================
local function ToggleNoclip(state)
    NoclipEnabled = state
    if state then
        if NoclipConnection then NoclipConnection:Disconnect() end
        NoclipConnection = RunService.Stepped:Connect(function()
            if LocalPlayer.Character then
                for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if NoclipConnection then
            NoclipConnection:Disconnect()
            NoclipConnection = nil
        end
        if LocalPlayer.Character then
            for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end

-- ==================== FLY ====================
local function ToggleFly(state)
    FlyEnabled = state
    if state then
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local root = character:WaitForChild("HumanoidRootPart")
        local hum = character:WaitForChild("Humanoid")
        hum.PlatformStand = true
        FlyConnection = RunService.RenderStepped:Connect(function()
            if root then
                local dir = Vector3.new()
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += Camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= Camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= Camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += Camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= Vector3.new(0,1,0) end
                if dir.Magnitude > 0 then dir = dir.Unit * FlySpeed end
                root.Velocity = dir
            end
        end)
    else
        if FlyConnection then FlyConnection:Disconnect(); FlyConnection = nil end
        if LocalPlayer.Character then
            local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
            if hum then hum.PlatformStand = false end
        end
    end
end

-- ==================== FLING ====================
local function ToggleFling(state)
    FlingEnabled = state
    
    if state then
        if not LocalPlayer.Character then return end
        
        FlingParts = {}
        for _, child in pairs(LocalPlayer.Character:GetDescendants()) do
            if child:IsA("BasePart") then
                table.insert(FlingParts, {
                    Part = child,
                    CanCollide = child.CanCollide,
                    Massless = child.Massless,
                    CustomPhysicalProperties = child.CustomPhysicalProperties
                })
                child.CustomPhysicalProperties = PhysicalProperties.new(100, 0.3, 0.5)
                child.CanCollide = false
                child.Massless = true
                child.Velocity = Vector3.new(0, 0, 0)
            end
        end
        
        local bambam = Instance.new("BodyAngularVelocity")
        bambam.Name = "Fling_Body"
        bambam.Parent = LocalPlayer.Character.HumanoidRootPart
        bambam.AngularVelocity = Vector3.new(0, 99999, 0)
        bambam.MaxTorque = Vector3.new(0, math.huge, 0)
        bambam.P = math.huge
        
        local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then
            hum.PlatformStand = false
            hum.AutoRotate = false
        end
        
        FlingConnection = RunService.RenderStepped:Connect(function()
            if FlingEnabled and LocalPlayer.Character then
                local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    local bambam = root:FindFirstChild("Fling_Body")
                    if bambam then
                        bambam.AngularVelocity = Vector3.new(0, 99999, 0)
                        task.wait(0.2)
                        bambam.AngularVelocity = Vector3.new(0, 0, 0)
                        task.wait(0.1)
                    end
                end
            end
        end)
        
        ToggleNoclip(true)
        
    else
        if FlingConnection then
            FlingConnection:Disconnect()
            FlingConnection = nil
        end
        
        if LocalPlayer.Character then
            local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local bambam = root:FindFirstChild("Fling_Body")
                if bambam then bambam:Destroy() end
            end
            
            for _, data in ipairs(FlingParts) do
                if data.Part and data.Part.Parent then
                    data.Part.CanCollide = data.CanCollide
                    data.Part.Massless = data.Massless
                    data.Part.CustomPhysicalProperties = data.CustomPhysicalProperties
                    data.Part.Velocity = Vector3.new(0, 0, 0)
                end
            end
            FlingParts = {}
            
            local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
            if hum then
                hum.PlatformStand = false
                hum.AutoRotate = true
            end
        end
        
        ToggleNoclip(false)
    end
end

-- ==================== GUN GRAB ====================
local function ToggleGunGrab(state)
    GunGrabEnabled = state
    if state then
        GunGrabConnection = RunService.RenderStepped:Connect(function()
            if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
            for _, model in ipairs(Workspace:GetChildren()) do
                if model.Name == "GunDrop" then
                    local rootPart = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChildWhichIsA("BasePart")
                    if rootPart then
                        local pos = rootPart.Position
                        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(pos)
                        task.wait(0.5)
                        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(Vector3.new(0, 0, 0))
                        break
                    end
                end
            end
        end)
    else
        if GunGrabConnection then
            GunGrabConnection:Disconnect()
            GunGrabConnection = nil
        end
    end
end

-- ==================== COMBAT ====================
local function GetNearestPlayer(range)
    local nearest, minDist = nil, range or math.huge
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return nil end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
            if dist < minDist then minDist = dist; nearest = player end
        end
    end
    return nearest
end

local function AutoFarmLoop() while AutoFarmEnabled do task.wait(0.1) pcall(function()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    local t = GetNearestPlayer(50)
    if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = t.Character.HumanoidRootPart.CFrame * CFrame.new(0,0,2)
    end
end) end end

local function KillAuraLoop() while KillAuraEnabled do task.wait(0.05) pcall(function()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            if (LocalPlayer.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude <= KillAuraRange then
                LocalPlayer.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame
            end
        end
    end
end) end end

local function ToggleGodMode(state)
    GodModeEnabled = state
    pcall(function()
        if not LocalPlayer.Character then return end
        local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then hum.MaxHealth = state and math.huge or 100; hum.Health = state and math.huge or 100 end
    end)
end

-- ==================== COIN FARM ====================
local function CoinFarmLoop() while CoinFarmEnabled do task.wait(0.1) pcall(function()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v.Name == "Coin" or v.Name == "CoinContainer" then
            local coin = v:IsA("BasePart") and v or v:FindFirstChildWhichIsA("BasePart")
            if coin then firetouchinterest(LocalPlayer.Character.HumanoidRootPart, coin, 0); firetouchinterest(LocalPlayer.Character.HumanoidRootPart, coin, 1) end
        end
    end
end) end end

-- ==================== GUI ====================
local MainTab = Window:CreateTab("Main", "swords")
local VisualsTab = Window:CreateTab("Visuals", "eye")
local MovementTab = Window:CreateTab("Movement", "plane")
local TeleportTab = Window:CreateTab("Teleport", "map-pin")
local FarmTab = Window:CreateTab("Farm", "coins")
local MiscTab = Window:CreateTab("Misc", "settings")
local FlingTab = Window:CreateTab("Fling", "zap")
local GunTab = Window:CreateTab("Gun Grab", "target")

MainTab:CreateSection("Combat")
MainTab:CreateToggle({ Name = "Auto Farm", CurrentValue = false, Callback = function(s) AutoFarmEnabled = s; if s then task.spawn(AutoFarmLoop) end end })
MainTab:CreateToggle({ Name = "Kill Aura", CurrentValue = false, Callback = function(s) KillAuraEnabled = s; if s then task.spawn(KillAuraLoop) end end })
MainTab:CreateSlider({ Name = "Kill Aura Range", Range = {5,50}, Increment = 1, Suffix = "studs", CurrentValue = 15, Callback = function(v) KillAuraRange = v end })

MainTab:CreateSection("Character")
MainTab:CreateToggle({ Name = "God Mode", CurrentValue = false, Callback = ToggleGodMode })
MainTab:CreateSlider({ Name = "Walk Speed", Range = {16,200}, Increment = 1, CurrentValue = 16, Callback = function(v) WalkSpeed = v; if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.WalkSpeed = v end end })
MainTab:CreateSlider({ Name = "Jump Power", Range = {50,300}, Increment = 1, CurrentValue = 50, Callback = function(v) JumpPower = v; if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.JumpPower = v end end })

VisualsTab:CreateSection("ESP")
VisualsTab:CreateToggle({ Name = "ESP Master", CurrentValue = false, Callback = ToggleESP })
VisualsTab:CreateToggle({ Name = "Box ESP", CurrentValue = true, Callback = function(s) ESPBoxEnabled = s end })
VisualsTab:CreateToggle({ Name = "Name ESP", CurrentValue = true, Callback = function(s) ESPNameEnabled = s end })
VisualsTab:CreateToggle({ Name = "Health Bar", CurrentValue = true, Callback = function(s) ESPHealthEnabled = s end })
VisualsTab:CreateToggle({ Name = "Distance", CurrentValue = true, Callback = function(s) ESPDistanceEnabled = s end })

MovementTab:CreateSection("Movement")
MovementTab:CreateToggle({ Name = "Noclip", CurrentValue = false, Callback = ToggleNoclip })
MovementTab:CreateToggle({ Name = "Fly", CurrentValue = false, Callback = ToggleFly })
MovementTab:CreateSlider({ Name = "Fly Speed", Range = {20,200}, Increment = 5, CurrentValue = 50, Callback = function(v) FlySpeed = v end })

FlingTab:CreateSection("Fling")
FlingTab:CreateToggle({ Name = "Fling", CurrentValue = false, Callback = ToggleFling })

GunTab:CreateSection("Gun Grab")
GunTab:CreateToggle({ Name = "Grab Gun on Drop", CurrentValue = false, Callback = ToggleGunGrab })

TeleportTab:CreateSection("Teleport to Player")
local playerList = {}
for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then table.insert(playerList, p.Name) end end
local tpDropdown = TeleportTab:CreateDropdown({ Name = "Select Player", Options = playerList, CurrentOption = playerList[1] or "", Callback = function() end })
TeleportTab:CreateButton({ Name = "Teleport", Callback = function()
    local name = tpDropdown.CurrentOption
    if name and name ~= "" then
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Name == name and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame
                    Rayfield:Notify({ Title = "Teleport", Content = "Teleported to " .. name, Duration = 2, Image = "map-pin" })
                    return
                end
            end
        end
        Rayfield:Notify({ Title = "Teleport", Content = "Player not found!", Duration = 2, Image = "x" })
    end
end })
TeleportTab:CreateButton({ Name = "Refresh", Callback = function()
    local names = {}
    for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then table.insert(names, p.Name) end end
    tpDropdown:Refresh(names)
end })

FarmTab:CreateToggle({ Name = "Auto Coin Farm", CurrentValue = false, Callback = function(s) CoinFarmEnabled = s; if s then task.spawn(CoinFarmLoop) end end })

MiscTab:CreateButton({ Name = "Rejoin", Callback = function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer) end })
MiscTab:CreateButton({ Name = "Server Hop", Callback = function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end })
MiscTab:CreateButton({ Name = "Destroy GUI", Callback = function() Rayfield:Destroy() end })

LocalPlayer.CharacterAdded:Connect(function(c)
    task.wait(0.5)
    if GodModeEnabled then ToggleGodMode(true) end
    if NoclipEnabled then ToggleNoclip(true) end
    local hum = c:FindFirstChild("Humanoid")
    if hum then hum.WalkSpeed = WalkSpeed; hum.JumpPower = JumpPower end
end)

Players.PlayerAdded:Connect(function(p)
    if ESPEnabled then p.CharacterAdded:Connect(function() task.wait(0.5); CreateESP(p) end) end
end)

Rayfield:Notify({ Title = "MM2 Script", Content = "Loaded!", Duration = 3, Image = "skull" })
