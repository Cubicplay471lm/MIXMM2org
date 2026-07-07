[7/7/2026 9:09 PM] .: --[[
    MM2 Script - Rayfield (Обнова)
    Noclip, Fly, ESP по ролям, ТП фикс
]]

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "MM2 Script",
    Icon = "skull",
    LoadingTitle = "MM2 Script Loading",
    LoadingSubtitle = "by .ftgs",
    Theme = "DarkBlue",
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false,
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "mm2script",
        FileName = "config"
    },
    Discord = {
        Enabled = false,
        Invite = "",
        RememberJoins = true
    },
    KeySystem = false,
})

-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Variables
local ESPEnabled = false
local ESPHighlights = {}
local ESPBillboards = {}
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

-- ==================== ESP ====================
local function GetPlayerRole(player)
    if not player.Character then return "none" end
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        if backpack:FindFirstChild("Knife") then return "murderer" end
        if backpack:FindFirstChild("Gun") then return "sheriff" end
    end
    if player.Character:FindFirstChild("Knife") then return "murderer" end
    if player.Character:FindFirstChild("Gun") then return "sheriff" end
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
    return "НЕВИНОВНЫЙ"
end

local function CreateESP(player)
    if player == LocalPlayer then return end
    
    local highlight = Instance.new("Highlight")
    highlight.FillTransparency = 1
    highlight.OutlineTransparency = 0.2
    highlight.Parent = player.Character or nil
    
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 120, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 3.5, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = player.Character or nil
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    frame.Parent = billboard
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.Name
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextStrokeTransparency = 0
    nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    nameLabel.Font = Enum.Font.SourceSansBold
    nameLabel.TextSize = 13
    nameLabel.Parent = frame
    
    local roleLabel = Instance.new("TextLabel")
    roleLabel.Size = UDim2.new(1, 0, 0.5, 0)
    roleLabel.Position = UDim2.new(0, 0, 0.5, 0)
    roleLabel.BackgroundTransparency = 1
    roleLabel.Text = "..."
    roleLabel.TextStrokeTransparency = 0
    roleLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    roleLabel.Font = Enum.Font.SourceSansBold
    roleLabel.TextSize = 12
    roleLabel.Parent = frame
    
    ESPHighlights[player] = highlight
    ESPBillboards[player] = {billboard = billboard, roleLabel = roleLabel, nameLabel = nameLabel}
[7/7/2026 9:09 PM] .: local function updateESP()
        local role = GetPlayerRole(player)
        local color = GetRoleColor(role)
        highlight.OutlineColor = color
        roleLabel.Text = GetRoleName(role)
        roleLabel.TextColor3 = color
    end
    
    updateESP()
    
    player.CharacterAdded:Connect(function(char)
        highlight.Parent = char
        billboard.Parent = char
        task.wait(0.2)
        if ESPEnabled then updateESP() end
    end)
    
    -- Проверка на обновление роли
    task.spawn(function()
        while ESPEnabled and ESPHighlights[player] do
            updateESP()
            task.wait(1)
        end
    end)
end

local function RemoveESP(player)
    if ESPHighlights[player] then
        ESPHighlights[player]:Destroy()
        ESPHighlights[player] = nil
    end
    if ESPBillboards[player] then
        ESPBillboards[player].billboard:Destroy()
        ESPBillboards[player] = nil
    end
end

local function ToggleESP(state)
    ESPEnabled = state
    if state then
        for _, player in ipairs(Players:GetPlayers()) do
            CreateESP(player)
        end
    else
        for player, _ in pairs(ESPHighlights) do
            RemoveESP(player)
        end
    end
end

-- ==================== NOCLIP ====================
local function ToggleNoclip(state)
    NoclipEnabled = state
    if state then
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
    end
end

-- ==================== FLY ====================
local function ToggleFly(state)
    FlyEnabled = state
    if state then
        local player = LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
        local humanoid = character:WaitForChild("Humanoid")
        
        humanoid.PlatformStand = true
        
        FlyConnection = RunService.RenderStepped:Connect(function()
            if humanoidRootPart then
                local moveDirection = Vector3.new()
                
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    moveDirection += Workspace.CurrentCamera.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    moveDirection -= Workspace.CurrentCamera.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    moveDirection -= Workspace.CurrentCamera.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    moveDirection += Workspace.CurrentCamera.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    moveDirection += Vector3.new(0, 1, 0)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                    moveDirection -= Vector3.new(0, 1, 0)
                end
                
                if moveDirection.Magnitude > 0 then
                    moveDirection = moveDirection.Unit * FlySpeed
                end
                
                humanoidRootPart.Velocity = moveDirection
                humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.Position) * CFrame.Angles(0, math.rad(humanoidRootPart.Orientation.Y), 0)
[7/7/2026 9:09 PM] .: end
        end)
    else
        if FlyConnection then
            FlyConnection:Disconnect()
            FlyConnection = nil
        end
        if LocalPlayer.Character then
            local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
            if humanoid then humanoid.PlatformStand = false end
        end
    end
end

-- ==================== COMBAT ====================
local function GetNearestPlayer(range)
    local nearest = nil
    local minDist = range or math.huge
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

local function AutoFarmLoop()
    while AutoFarmEnabled do
        task.wait(0.1)
        pcall(function()
            if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
            local target = GetNearestPlayer(50)
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 2)
            end
        end)
    end
end

local function KillAuraLoop()
    while KillAuraEnabled do
        task.wait(0.05)
        pcall(function()
            if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local dist = (LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                    if dist <= KillAuraRange then
                        LocalPlayer.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame
                    end
                end
            end
        end)
    end
end

local function ToggleGodMode(state)
    GodModeEnabled = state
    pcall(function()
        if not LocalPlayer.Character then return end
        local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.MaxHealth = state and math.huge or 100
            humanoid.Health = state and math.huge or 100
        end
    end)
end

-- ==================== COIN FARM ====================
local function CoinFarmLoop()
    while CoinFarmEnabled do
        task.wait(0.1)
        pcall(function()
            if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
            for _, v in ipairs(Workspace:GetDescendants()) do
                if v.Name == "Coin" or v.Name == "CoinContainer" then
                    local coin = v:IsA("BasePart") and v or v:FindFirstChildWhichIsA("BasePart")
                    if coin then
                        firetouchinterest(LocalPlayer.Character.HumanoidRootPart, coin, 0)
                        firetouchinterest(LocalPlayer.Character.HumanoidRootPart, coin, 1)
                    end
                end
            end
        end)
    end
end

-- ==================== GUI TABS ====================
local MainTab = Window:CreateTab("Main", "swords")
local MovementTab = Window:CreateTab("Movement", "plane")
local TeleportTab = Window:CreateTab("Teleport", "map-pin")
local FarmTab = Window:CreateTab("Farm", "coins")
local MiscTab = Window:CreateTab("Misc", "settings")
[7/7/2026 9:09 PM] .: -- MAIN TAB
MainTab:CreateSection("ESP")
MainTab:CreateToggle({
    Name = "Player ESP",
    CurrentValue = false,
    Flag = "ESP",
    Callback = function(state) ToggleESP(state) end,
})

MainTab:CreateSection("Combat")
MainTab:CreateToggle({
    Name = "Auto Farm",
    CurrentValue = false,
    Flag = "AutoFarm",
    Callback = function(state)
        AutoFarmEnabled = state
        if state then task.spawn(AutoFarmLoop) end
    end,
})

MainTab:CreateToggle({
    Name = "Kill Aura",
    CurrentValue = false,
    Flag = "KillAura",
    Callback = function(state)
        KillAuraEnabled = state
        if state then task.spawn(KillAuraLoop) end
    end,
})

MainTab:CreateSlider({
    Name = "Kill Aura Range",
    Range = {5, 50},
    Increment = 1,
    Suffix = "studs",
    CurrentValue = 15,
    Flag = "KillAuraRange",
    Callback = function(value) KillAuraRange = value end,
})

MainTab:CreateSection("Character")
MainTab:CreateToggle({
    Name = "God Mode",
    CurrentValue = false,
    Flag = "GodMode",
    Callback = function(state) ToggleGodMode(state) end,
})

MainTab:CreateSlider({
    Name = "Walk Speed",
    Range = {16, 200},
    Increment = 1,
    CurrentValue = 16,
    Flag = "WalkSpeed",
    Callback = function(value)
        WalkSpeed = value
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = value
        end
    end,
})

MainTab:CreateSlider({
    Name = "Jump Power",
    Range = {50, 300},
    Increment = 1,
    CurrentValue = 50,
    Flag = "JumpPower",
    Callback = function(value)
        JumpPower = value
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.JumpPower = value
        end
    end,
})

-- MOVEMENT TAB
MovementTab:CreateSection("Movement")
MovementTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Flag = "Noclip",
    Callback = function(state) ToggleNoclip(state) end,
})

MovementTab:CreateToggle({
    Name = "Fly",
    CurrentValue = false,
    Flag = "Fly",
    Callback = function(state) ToggleFly(state) end,
})

MovementTab:CreateSlider({
    Name = "Fly Speed",
    Range = {20, 200},
    Increment = 5,
    Suffix = "",
    CurrentValue = 50,
    Flag = "FlySpeed",
    Callback = function(value) FlySpeed = value end,
})

-- TELEPORT TAB
TeleportTab:CreateSection("Teleport to Player")

local function GetPlayerNames()
    local names = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            table.insert(names, plr.Name)
        end
    end
    return names
end

local teleportDropdown = TeleportTab:CreateDropdown({
    Name = "Select Player",
    Options = GetPlayerNames(),
    CurrentOption = "",
    Flag = "TeleportPlayer",
    Callback = function(name)
        -- Ничего не делаем при выборе, только сохраняем
    end,
})

TeleportTab:CreateButton({
    Name = "Teleport",
    Callback = function()
        local selectedName = teleportDropdown.CurrentOption
        if selectedName and selectedName ~= "" then
            for _, player in ipairs(Players:GetPlayers()) do
                if player.Name == selectedName and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        LocalPlayer.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame
                        Rayfield:Notify({
                            Title = "Teleport",
                            Content = "Teleported to " .. player.Name,
                            Duration = 2,
                            Image = "map-pin",
[7/7/2026 9:09 PM] .: })
                        return
                    end
                end
            end
        end
        Rayfield:Notify({
            Title = "Teleport",
            Content = "Player not found!",
            Duration = 2,
            Image = "x",
        })
    end,
})

TeleportTab:CreateButton({
    Name = "Refresh Players",
    Callback = function()
        teleportDropdown:Refresh(GetPlayerNames())
    end,
})

-- FARM TAB
FarmTab:CreateToggle({
    Name = "Auto Coin Farm",
    CurrentValue = false,
    Flag = "CoinFarm",
    Callback = function(state)
        CoinFarmEnabled = state
        if state then task.spawn(CoinFarmLoop) end
    end,
})

-- MISC TAB
MiscTab:CreateButton({
    Name = "Rejoin Server",
    Callback = function()
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
    end,
})

MiscTab:CreateButton({
    Name = "Server Hop",
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
    end,
})

MiscTab:CreateButton({
    Name = "Destroy GUI",
    Callback = function()
        Rayfield:Destroy()
    end,
})

-- ==================== HANDLERS ====================
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    if GodModeEnabled then ToggleGodMode(true) end
    if NoclipEnabled then ToggleNoclip(true) end
    local humanoid = char:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = WalkSpeed
        humanoid.JumpPower = JumpPower
    end
end)

Players.PlayerAdded:Connect(function(player)
    if ESPEnabled then
        player.CharacterAdded:Connect(function()
            task.wait(0.5)
            CreateESP(player)
        end)
    end
end)

Rayfield:Notify({
    Title = "MM2 Script",
    Content = "Loaded!",
    Duration = 3,
    Image = "skull",
})
