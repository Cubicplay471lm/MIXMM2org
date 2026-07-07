-- ============================================
-- MIXWARE.LOL | MM2 Script
-- Разработчики: KT471 & hokpry
-- Версия: 2.0 | 2026
-- ============================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- ==================== ВОДЯНОЙ ЗНАК ====================
local function CreateWatermark()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MIXWARE_Watermark"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = game:GetService("CoreGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 340, 0, 35)
    frame.Position = UDim2.new(0, 10, 1, -45)
    frame.BackgroundTransparency = 0.7
    frame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = frame
    
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 40)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(40, 40, 50)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 30, 40))
    })
    gradient.Parent = frame
    
    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.Text = "MIXWARE | MM2 | " .. os.date("%H:%M:%S") .. " | SPEED: 0"
    text.TextColor3 = Color3.fromRGB(200, 200, 220)
    text.TextSize = 14
    text.Font = Enum.Font.GothamBold
    text.TextXAlignment = Enum.TextXAlignment.Center
    text.TextYAlignment = Enum.TextYAlignment.Center
    text.Parent = frame
    
    spawn(function()
        local lastPos = Vector3.new()
        local player = game:GetService("Players").LocalPlayer
        while true do
            task.wait(0.5)
            local speed = 0
            local char = player.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local currentPos = char.HumanoidRootPart.Position
                speed = math.floor((currentPos - lastPos).Magnitude / 0.5)
                lastPos = currentPos
            end
            text.Text = "MIXWARE | MM2 | " .. os.date("%H:%M:%S") .. " | SPEED: " .. speed .. " | KT471 & hokpry"
        end
    end)
    
    return screenGui
end

CreateWatermark()

-- ==================== ЗАГРУЗКА ESP ====================
local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/linemaster2/esp-library/main/library.lua"))();

ESP.Enabled = false
ESP.ShowBox = false
ESP.ShowName = false
ESP.ShowHealth = false
ESP.ShowDistance = false
ESP.ShowTracer = false
ESP.ShowSkeletons = false
ESP.Color = Color3.fromRGB(255, 255, 255)
ESP.MaxDistance = 500
ESP.ShowTeammates = false
ESP.BoxType = "Corner Box Esp"

-- ==================== GUI ====================
local Window = Rayfield:CreateWindow({
    Name = "MIXWARE | MM2 Script",
    Icon = "skull",
    LoadingTitle = "MIXWARE Loading...",
    LoadingSubtitle = "by KT471 & hokpry",
    Theme = "DarkBlue",
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false,
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "mixware",
        FileName = "config"
    },
    Discord = {
        Enabled = false,
        Invite = "",
        RememberJoins = true
    },
    KeySystem = false,
})

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Camera = Workspace.CurrentCamera
local TeleportService = game:GetService("TeleportService")

-- Variables
local AutoFarmEnabled = false
local KillAuraEnabled = false
local GodModeEnabled = false
local CoinFarmEnabled = false
local KillAuraRange = 15
local KillAuraKey = "Q"
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
local KillAuraConnection = nil
local KillAuraCooldown = false

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

local function UpdateESPColor(player)
    if not player then return end
    local role = GetPlayerRole(player)
    local color = GetRoleColor(role)
    ESP:SetColor(color)
end

local function ToggleESP(state)
    ESP.Enabled = state
    if state then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                UpdateESPColor(player)
            end
        end
    end
    ESP.Toggle(state)
end

Players.PlayerAdded:Connect(function(player)
    if ESP.Enabled then
        player.CharacterAdded:Connect(function()
            task.wait(0.5)
            if ESP.Enabled then
                UpdateESPColor(player)
            end
        end)
    end
end)

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

-- ==================== KILL AURA ====================
local function GetClosestPlayerToCursor()
    local closest = nil
    local minAngle = math.huge
    local mouse = UserInputService:GetMouseLocation()
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local root = player.Character.HumanoidRootPart
            local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
            if onScreen then
                local angle = (Vector2.new(screenPos.X, screenPos.Y) - mouse).Magnitude
                if angle < minAngle then
                    minAngle = angle
                    closest = player
                end
            end
        end
    end
    return closest
end

local function GetNearestPlayer(range)
    local nearest, minDist = nil, range or math.huge
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return nil end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
            if dist < minDist then
                minDist = dist
                nearest = player
            end
        end
    end
    return nearest
end

local function SimulateMouseClick()
    local mouse = UserInputService:GetMouseLocation()
    UserInputService.InputBegan:Fire(mouse, Enum.UserInputType.MouseButton1)
    task.wait(0.05)
    UserInputService.InputEnded:Fire(mouse, Enum.UserInputType.MouseButton1)
end

local function KillAuraAction()
    if KillAuraCooldown or not LocalPlayer.Character then return end
    KillAuraCooldown = true
    
    local myRole = GetPlayerRole(LocalPlayer)
    local target = nil
    
    if myRole == "sheriff" then
        target = GetClosestPlayerToCursor()
        if target then
            local targetRole = GetPlayerRole(target)
            if targetRole ~= "murderer" then
                target = nil
            end
        end
    elseif myRole == "murderer" then
        target = GetNearestPlayer(KillAuraRange)
        if target then
            if target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                local targetRoot = target.Character.HumanoidRootPart
                local direction = (targetRoot.Position - LocalPlayer.Character.HumanoidRootPart.Position).Unit
                local behindPos = targetRoot.Position - direction * 3
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(behindPos, targetRoot.Position)
                task.wait(0.05)
            end
        end
    else
        KillAuraCooldown = false
        return
    end
    
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        local targetRoot = target.Character.HumanoidRootPart
        local screenPos = Camera:WorldToViewportPoint(targetRoot.Position)
        if screenPos.Z > 0 then
            UserInputService:SetMouseLocation(screenPos.X, screenPos.Y)
            task.wait(0.05)
            SimulateMouseClick()
            Rayfield:Notify({
                Title = "Kill Aura",
                Content = "Удар по " .. target.Name,
                Duration = 1,
                Image = "swords"
            })
        end
    end
    
    KillAuraCooldown = false
end

local function ToggleKillAura(state)
    KillAuraEnabled = state
    
    if state then
        if KillAuraConnection then KillAuraConnection:Disconnect() end
        
        KillAuraConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            if not KillAuraEnabled then return end
            
            local keyPressed = false
            
            if input.UserInputType == Enum.UserInputType.Keyboard then
                local key = input.KeyCode
                if KillAuraKey == "Q" and key == Enum.KeyCode.Q then
                    keyPressed = true
                elseif KillAuraKey == "Y" and key == Enum.KeyCode.Y then
                    keyPressed = true
                end
            elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
                keyPressed = true
            end
            
            if keyPressed then
                task.spawn(KillAuraAction)
            end
        end)
    else
        if KillAuraConnection then
            KillAuraConnection:Disconnect()
            KillAuraConnection = nil
        end
    end
end

-- ==================== COMBAT ====================
local function GetNearestPlayerForFarm(range)
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
    local t = GetNearestPlayerForFarm(50)
    if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = t.Character.HumanoidRootPart.CFrame * CFrame.new(0,0,2)
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
local SettingsTab = Window:CreateTab("Settings", "settings")

-- ==================== MAIN TAB ====================
MainTab:CreateSection("Combat")
MainTab:CreateToggle({ Name = "Auto Farm", CurrentValue = false, Callback = function(s) AutoFarmEnabled = s; if s then task.spawn(AutoFarmLoop) end end })

MainTab:CreateSection("Kill Aura")
MainTab:CreateToggle({ Name = "Kill Aura", CurrentValue = false, Callback = ToggleKillAura })
MainTab:CreateSlider({ Name = "Kill Aura Range", Range = {5,50}, Increment = 1, Suffix = "studs", CurrentValue = 15, Callback = function(v) KillAuraRange = v end })

local keyOptions = {"Q", "Y"}
MainTab:CreateDropdown({
    Name = "Activation Key",
    Options = keyOptions,
    CurrentOption = "Q",
    Callback = function(option)
        KillAuraKey = option
        Rayfield:Notify({
            Title = "Kill Aura",
            Content = "Клавиша: " .. option,
            Duration = 2,
            Image = "key"
        })
    end
})

MainTab:CreateButton({
    Name = "Attack (Mobile)",
    Callback = function()
        if KillAuraEnabled then
            task.spawn(KillAuraAction)
        else
            Rayfield:Notify({
                Title = "Kill Aura",
                Content = "Сначала включи Kill Aura!",
                Duration = 2,
                Image = "x"
            })
        end
    end
})

MainTab:CreateSection("Character")
MainTab:CreateToggle({ Name = "God Mode", CurrentValue = false, Callback = ToggleGodMode })
MainTab:CreateSlider({ Name = "Walk Speed", Range = {16,200}, Increment = 1, CurrentValue = 16, Callback = function(v) WalkSpeed = v; if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.WalkSpeed = v end end })
MainTab:CreateSlider({ Name = "Jump Power", Range = {50,300}, Increment = 1, CurrentValue = 50, Callback = function(v) JumpPower = v; if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.JumpPower = v end end })

-- ==================== VISUALS TAB ====================
VisualsTab:CreateSection("ESP Settings")
VisualsTab:CreateToggle({ Name = "ESP Master", CurrentValue = false, Callback = ToggleESP })

VisualsTab:CreateSection("ESP Types")
VisualsTab:CreateToggle({ Name = "Box ESP", CurrentValue = false, Callback = function(s) ESP.ShowBox = s end })
VisualsTab:CreateToggle({ Name = "Name ESP", CurrentValue = false, Callback = function(s) ESP.ShowName = s end })
VisualsTab:CreateToggle({ Name = "Health Bar", CurrentValue = false, Callback = function(s) ESP.ShowHealth = s end })
VisualsTab:CreateToggle({ Name = "Distance", CurrentValue = false, Callback = function(s) ESP.ShowDistance = s end })
VisualsTab:CreateToggle({ Name = "Tracer", CurrentValue = false, Callback = function(s) ESP.ShowTracer = s end })

VisualsTab:CreateSection("ESP Colors")
VisualsTab:CreateColorPicker({
    Name = "ESP Color",
    Color = Color3.fromRGB(255, 255, 255),
    Flag = "ESPColor",
    Callback = function(Color)
        ESP.Color = Color
        ESP:SetColor(Color)
    end
})

VisualsTab:CreateSlider({
    Name = "ESP Distance",
    Range = {50, 1000},
    Increment = 50,
    Suffix = "studs",
    CurrentValue = 500,
    Callback = function(v)
        ESP.MaxDistance = v
    end
})

-- ==================== MOVEMENT TAB ====================
MovementTab:CreateSection("Movement")
MovementTab:CreateToggle({ Name = "Noclip", CurrentValue = false, Callback = ToggleNoclip })
MovementTab:CreateToggle({ Name = "Fly", CurrentValue = false, Callback = ToggleFly })
MovementTab:CreateSlider({ Name = "Fly Speed", Range = {20,200}, Increment = 5, CurrentValue = 50, Callback = function(v) FlySpeed = v end })

-- ==================== FLING TAB ====================
FlingTab:CreateSection("Fling")
FlingTab:CreateToggle({ Name = "Fling", CurrentValue = false, Callback = ToggleFling })

-- ==================== GUN TAB ====================
GunTab:CreateSection("Gun Grab")
GunTab:CreateToggle({ Name = "Grab Gun on Drop", CurrentValue = false, Callback = ToggleGunGrab })

-- ==================== TELEPORT TAB ====================
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

-- ==================== FARM TAB ====================
FarmTab:CreateToggle({ Name = "Auto Coin Farm", CurrentValue = false, Callback = function(s) CoinFarmEnabled = s; if s then task.spawn(CoinFarmLoop) end end })

-- ==================== MISC TAB ====================
MiscTab:CreateButton({ Name = "Rejoin", Callback = function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer) end })
MiscTab:CreateButton({ Name = "Server Hop", Callback = function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end })
MiscTab:CreateButton({ Name = "Destroy GUI", Callback = function() Window:Destroy() end })

-- ==================== SETTINGS TAB (НАСТРОЙКИ RAYFIELD) ====================
SettingsTab:CreateSection("Внешний вид меню")

-- Выбор темы
local themes = {"DarkBlue", "Dark", "Light", "Amber", "Midnight", "Ocean", "Crimson", "Purple", "Green", "Galaxy"}
SettingsTab:CreateDropdown({
    Name = "Тема меню",
    Options = themes,
    CurrentOption = "DarkBlue",
    Callback = function(option)
        Rayfield:ChangeTheme(option)
        Rayfield:Notify({
            Title = "Тема",
            Content = "Изменена на: " .. option,
            Duration = 2,
            Image = "palette"
        })
    end
})

SettingsTab:CreateSection("Прозрачность меню")

local TransparencySlider = SettingsTab:CreateSlider({
    Name = "Прозрачность фона",
    Range = {0, 100},
    Increment = 5,
    Suffix = "%",
    CurrentValue = 0,
    Callback = function(v)
        local transparency = v / 100
        -- Применяем прозрачность к основным элементам Rayfield
        pcall(function()
            local mainGui = Rayfield:GetGui()
            if mainGui then
                for _, child in ipairs(mainGui:GetDescendants()) do
                    if child:IsA("Frame") or child:IsA("ImageLabel") then
                        child.BackgroundTransparency = transparency
                    end
                end
            end
        end)
        Rayfield:Notify({
            Title = "Прозрачность",
            Content = "Установлена: " .. v .. "%",
            Duration = 1,
            Image = "eye"
        })
    end
})

SettingsTab:CreateSection("Управление")

SettingsTab:CreateButton({
    Name = "👁️ Скрыть меню (K)",
    Callback = function()
        Rayfield:SetVisibility(false)
        Rayfield:Notify({
            Title = "Меню",
            Content = "Скрыто. Нажми K чтобы показать",
            Duration = 2,
            Image = "eye"
        })
    end
})

SettingsTab:CreateButton({
    Name = "👁️ Показать меню",
    Callback = function()
        Rayfield:SetVisibility(true)
        Rayfield:Notify({
            Title = "Меню",
            Content = "Показано",
            Duration = 2,
            Image = "eye"
        })
    end
})

SettingsTab:CreateSection("Конфигурации")

-- Сохранение конфига
SettingsTab:CreateButton({
    Name = "💾 Сохранить конфигурацию",
    Callback = function()
        Rayfield:SaveConfiguration()
        Rayfield:Notify({
            Title = "Конфигурация",
            Content = "Сохранена!",
            Duration = 2,
            Image = "check"
        })
    end
})

-- Загрузка конфига
SettingsTab:CreateButton({
    Name = "📂 Загрузить конфигурацию",
    Callback = function()
        Rayfield:LoadConfiguration()
        Rayfield:Notify({
            Title = "Конфигурация",
            Content = "Загружена!",
            Duration = 2,
            Image = "check"
        })
    end
})

-- Сброс конфига
SettingsTab:CreateButton({
    Name = "🗑️ Сбросить конфигурацию",
    Callback = function()
        Rayfield:ResetConfiguration()
        Rayfield:Notify({
            Title = "Конфигурация",
            Content = "Сброшена!",
            Duration = 2,
            Image = "x"
        })
    end
})

-- ==================== ОБРАБОТЧИКИ ====================
LocalPlayer.CharacterAdded:Connect(function(c)
    task.wait(0.5)
    if GodModeEnabled then ToggleGodMode(true) end
    if NoclipEnabled then ToggleNoclip(true) end
    local hum = c:FindFirstChild("Humanoid")
    if hum then hum.WalkSpeed = WalkSpeed; hum.JumpPower = JumpPower end
end)

-- ==================== УВЕДОМЛЕНИЕ ====================
Rayfield:Notify({ Title = "MIXWARE", Content = "MM2 Script Loaded!", Duration = 3, Image = "skull" })
Rayfield:Notify({
    Title = "Настройки Rayfield",
    Content = "Перейдите во вкладку Settings",
    Duration = 3,
    Image = "settings"
})
