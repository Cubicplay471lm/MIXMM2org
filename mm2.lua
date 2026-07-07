--[[
    MM2 Script - Rayfield
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

-- Variables
local ESPEnabled = false
local AutoFarmEnabled = false
local KillAuraEnabled = false
local GodModeEnabled = false
local CoinFarmEnabled = false
local KillAuraRange = 15
local WalkSpeed = 16
local JumpPower = 50
local ESPHighlights = {}

-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

-- ESP
local function CreateESP(player)
    if player == LocalPlayer then return end
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP"
    highlight.FillTransparency = 1
    highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
    highlight.OutlineTransparency = 0
    highlight.Parent = player.Character or nil
    ESPHighlights[player] = highlight
    
    player.CharacterAdded:Connect(function(char)
        if ESPEnabled then
            highlight.Parent = char
        end
    end)
end

local function RemoveESP(player)
    if ESPHighlights[player] then
        ESPHighlights[player]:Destroy()
        ESPHighlights[player] = nil
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

-- Auto Farm
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

-- Kill Aura
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
-- God Mode
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

-- Coin Farm
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

-- Tabs
local MainTab = Window:CreateTab("Main", "swords")
local TeleportTab = Window:CreateTab("Teleport", "map-pin")
local FarmTab = Window:CreateTab("Farm", "coins")
local MiscTab = Window:CreateTab("Misc", "settings")

-- Main Tab
MainTab:CreateSection("ESP")
MainTab:CreateToggle({
    Name = "Player ESP",
    CurrentValue = false,
    Flag = "ESP",
    Callback = function(state)
        ToggleESP(state)
    end,
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
    Callback = function(value)
        KillAuraRange = value
    end,
})

MainTab:CreateSection("Character")
MainTab:CreateToggle({
    Name = "God Mode",
    CurrentValue = false,
    Flag = "GodMode",
    Callback = function(state)
        ToggleGodMode(state)
    end,
})

MainTab:CreateSlider({
    Name = "Walk Speed",
    Range = {16, 200},
    Increment = 1,
    Suffix = "",
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
    Suffix = "",
    CurrentValue = 50,
    Flag = "JumpPower",
    Callback = function(value)
        JumpPower = value
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.JumpPower = value
        end
    end,
})

-- Teleport Tab
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
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Name == name and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame
                end
            end
        end
    end,
})

TeleportTab:CreateButton({
    Name = "Refresh Players",
    Callback = function()
        teleportDropdown:Refresh(GetPlayerNames())
    end,
})

-- Farm Tab
FarmTab:CreateToggle({
    Name = "Auto Coin Farm",
    CurrentValue = false,
    Flag = "CoinFarm",
    Callback = function(state)
        CoinFarmEnabled = state
        if state then task.spawn(CoinFarmLoop) end
    end,
})

-- Misc Tab
MiscTab:CreateButton({
    Name = "Rejoin Server",
    Callback = function()
        local ts = game:GetService("TeleportService")
        ts:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
    end,
})

MiscTab:CreateButton({
    Name = "Server Hop",
    Callback = function()
        local ts = game:GetService("TeleportService")
        ts:Teleport(game.PlaceId, LocalPlayer)
    end,
})

MiscTab:CreateButton({
    Name = "Destroy GUI",
    Callback = function()
        Rayfield:Destroy()
    end,
})

-- Handlers
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    if GodModeEnabled then ToggleGodMode(true) end
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
