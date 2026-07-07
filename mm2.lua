[7/7/2026 6:35 PM] .: --[[
    MM2 Script - WindUI
    by .ftgs hub
]]

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- CloneRef
local cloneref = (cloneref or clonereference or function(instance)
    return instance
end)

-- Load WindUI
local WindUI
local ok, result = pcall(function()
    return require("./src/Init")
end)
if ok then
    WindUI = result
else
    WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
end

-- Colors
local Purple = Color3.fromHex("#7775F2")
local Yellow = Color3.fromHex("#ECA201")
local Green = Color3.fromHex("#10C550")
local Grey = Color3.fromHex("#83889E")
local Blue = Color3.fromHex("#257AF7")
local Red = Color3.fromHex("#EF4F1D")

-- ============ VARIABLES ============
local ESPEnabled = false
local ESPObjects = {}
local AutoFarmEnabled = false
local KillAuraEnabled = false
local GodModeEnabled = false
local TeleportEnabled = false
local CoinFarmEnabled = false

local KillAuraRange = 15
local WalkSpeed = 16
local JumpPower = 50

-- ============ FUNCTIONS ============

-- ESP
local function CreateESP(player)
    local esp = {}
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP_" .. player.Name
    highlight.FillTransparency = 1
    highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
    highlight.OutlineTransparency = 0
    highlight.Parent = player.Character or nil
    esp.Highlight = highlight

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_Billboard_" .. player.Name
    billboard.Size = UDim2.new(0, 100, 0, 20)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = player.Character or nil
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = player.Name
    label.TextColor3 = Color3.fromRGB(255, 0, 0)
    label.TextStrokeTransparency = 0
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 14
    label.Parent = billboard
    esp.Billboard = billboard

    table.insert(ESPObjects, esp)

    player.CharacterAdded:Connect(function(char)
        highlight.Parent = char
        billboard.Parent = char
    end)
end

local function RemoveESP(player)
    for i, esp in ipairs(ESPObjects) do
        if esp.Highlight.Parent == player.Character then
            esp.Highlight:Destroy()
            esp.Billboard:Destroy()
            table.remove(ESPObjects, i)
            break
        end
    end
end

local function UpdateESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if player.Character and not player.Character:FindFirstChild("ESP_" .. player.Name) then
                CreateESP(player)
            end
        end
    end
end

local function ToggleESP(state)
    ESPEnabled = state
    if state then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                CreateESP(player)
            end
        end
        Players.PlayerAdded:Connect(function(player)
            if ESPEnabled then
                player.CharacterAdded:Connect(function()
                    task.wait(0.5)
                    CreateESP(player)
                end)
            end
        end)
    else
        for _, esp in ipairs(ESPObjects) do
            esp.Highlight:Destroy()
            esp.Billboard:Destroy()
        end
        ESPObjects = {}
    end
end

-- Auto Farm (Kill nearest player)
[7/7/2026 6:35 PM] .: local function GetNearestPlayer(range)
    local nearest = nil
    local minDist = range or math.huge
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

local function AttackPlayer(player)
    if not player or not player.Character then return end
    local args = {
        [1] = "MurdererAttack",
        [2] = player.Character
    }
    for _, v in ipairs(getconnections(player.Character.HumanoidRootPart:GetPropertyChangedSignal("Position"))) do
        -- Attack logic depends on MM2 remotes
    end
end

local function AutoFarmLoop()
    while AutoFarmEnabled do
        task.wait(0.1)
        if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then continue end

        local target = GetNearestPlayer(50)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 2)
        end
    end
end

-- Kill Aura
local function KillAuraLoop()
    while KillAuraEnabled do
        task.wait(0.05)
        if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then continue end

        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local dist = (LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                if dist <= KillAuraRange then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame
                    task.wait(0.05)
                    -- Attack logic
                end
            end
        end
    end
end

-- God Mode
local function ToggleGodMode(state)
    GodModeEnabled = state
    if not LocalPlayer.Character then return end
    local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
    if not humanoid then return end
    if state then
        humanoid.MaxHealth = math.huge
        humanoid.Health = math.huge
    else
        humanoid.MaxHealth = 100
        humanoid.Health = 100
    end
end

-- Teleport to player
local function TeleportToPlayer(playerName)
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Name:lower() == playerName:lower() and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame
                return true
            end
        end
    end
    return false
end

-- Coin Farm (Auto Collect Coins)
local function CoinFarmLoop()
    while CoinFarmEnabled do
        task.wait(0.1)
        if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then continue end

        for _, v in ipairs(Workspace:GetDescendants()) do
            if v.Name == "Coin" or v.Name == "CoinContainer" then
                if v:IsA("BasePart") or v:FindFirstChild("MeshPart") then
                    local coin = v:IsA("BasePart") and v or v:FindFirstChildWhichIsA("BasePart")
                    if coin then
                        firetouchinterest(LocalPlayer.Character.HumanoidRootPart, coin, 0)
                        firetouchinterest(LocalPlayer.Character.HumanoidRootPart, coin, 1)
                    end
                end
            end
        end
    end
end
[7/7/2026 6:35 PM] .: -- ============ GUI ============
local Window = WindUI:CreateWindow({
    Title = "MM2 Script | .ftgs hub",
    Folder = "mm2script",
    Icon = "solar:folder-2-bold-duotone",
    NewElements = true,
    OpenButton = {
        Title = "MM2 Script",
        CornerRadius = UDim.new(1, 0),
        Enabled = true,
        Draggable = true,
        Color = ColorSequence.new(Color3.fromHex("#FF0000"), Color3.fromHex("#8B0000")),
    },
})

Window:Tag({
    Title = "v1.0",
    Icon = "github",
    Color = Color3.fromHex("#1c1c1c"),
    Border = true,
})

-- ============ MAIN TAB ============
local MainTab = Window:Tab({
    Title = "Main",
    Icon = "solar:home-2-bold",
    IconColor = Grey,
    IconShape = "Square",
    Border = true,
})

MainTab:Section({ Title = "ESP" })
MainTab:Toggle({
    Title = "Player ESP",
    Desc = "Show players through walls",
    Callback = function(state)
        ToggleESP(state)
    end,
})

MainTab:Space()
MainTab:Section({ Title = "Combat" })

MainTab:Toggle({
    Title = "Auto Farm",
    Desc = "Automatically kill nearest player",
    Callback = function(state)
        AutoFarmEnabled = state
        if state then
            task.spawn(AutoFarmLoop)
        end
    end,
})

MainTab:Space()

MainTab:Toggle({
    Title = "Kill Aura",
    Desc = "Kill players within range",
    Callback = function(state)
        KillAuraEnabled = state
        if state then
            task.spawn(KillAuraLoop)
        end
    end,
})

MainTab:Slider({
    Title = "Kill Aura Range",
    Value = { Min = 5, Max = 50, Default = 15 },
    Step = 1,
    Callback = function(value)
        KillAuraRange = value
    end,
})

MainTab:Space()
MainTab:Section({ Title = "Character" })

MainTab:Toggle({
    Title = "God Mode",
    Desc = "Infinite health",
    Callback = function(state)
        ToggleGodMode(state)
    end,
})

MainTab:Space()

MainTab:Slider({
    Title = "Walk Speed",
    Value = { Min = 16, Max = 200, Default = 16 },
    Step = 1,
    Callback = function(value)
        WalkSpeed = value
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = value
        end
    end,
})

MainTab:Space()

MainTab:Slider({
    Title = "Jump Power",
    Value = { Min = 50, Max = 300, Default = 50 },
    Step = 1,
    Callback = function(value)
        JumpPower = value
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.JumpPower = value
        end
    end,
})

-- ============ TELEPORT TAB ============
local TeleportTab = Window:Tab({
    Title = "Teleport",
    Icon = "solar:square-transfer-horizontal-bold",
    IconColor = Blue,
    IconShape = "Square",
    Border = true,
})

TeleportTab:Section({ Title = "Teleport to Player" })

local playerNames = {}
for _, plr in ipairs(Players:GetPlayers()) do
    if plr ~= LocalPlayer then
        table.insert(playerNames, plr.Name)
    end
end

local teleportDropdown = TeleportTab:Dropdown({
    Title = "Select Player",
    Values = playerNames,
    Value = nil,
    Callback = function(name)
        if name then
            TeleportToPlayer(name)
        end
    end,
})

TeleportTab:Button({
    Title = "Refresh Players",
    Icon = "refresh-cw",
    Justify = "Center",
    Callback = function()
        local names = {}
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                table.insert(names, plr.Name)
            end
        end
        teleportDropdown:Refresh(names)
    end,
})

-- ============ FARM TAB ============
local FarmTab = Window:Tab({
    Title = "Farm",
    Icon = "solar:folder-with-files-bold",
    IconColor = Yellow,
    IconShape = "Square",
    Border = true,
})

FarmTab:Toggle({
    Title = "Auto Coin Farm",
    Desc = "Auto collect coins",
    Callback = function(state)
        CoinFarmEnabled = state
        if state then
            task.spawn(CoinFarmLoop)
        end
    end,
})
[7/7/2026 6:35 PM] .: -- ============ MISC TAB ============
local MiscTab = Window:Tab({
    Title = "Misc",
    Icon = "solar:info-square-bold",
    IconColor = Purple,
    IconShape = "Square",
    Border = true,
})

MiscTab:Button({
    Title = "Rejoin Server",
    Icon = "rotate-cw",
    Justify = "Center",
    Color = Blue,
    Callback = function()
        local ts = game:GetService("TeleportService")
        ts:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
    end,
})

MiscTab:Space()

MiscTab:Button({
    Title = "Server Hop",
    Icon = "server",
    Justify = "Center",
    Color = Green,
    Callback = function()
        local ts = game:GetService("TeleportService")
        ts:Teleport(game.PlaceId, LocalPlayer)
    end,
})

MiscTab:Space()

MiscTab:Button({
    Title = "Destroy GUI",
    Icon = "shredder",
    Justify = "Center",
    Color = Red,
    Callback = function()
        Window:Destroy()
    end,
})

-- Character added handler
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    if GodModeEnabled then
        ToggleGodMode(true)
    end
    local humanoid = char:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = WalkSpeed
        humanoid.JumpPower = JumpPower
    end
end)

-- Update ESP on new players
Players.PlayerAdded:Connect(function(player)
    if ESPEnabled then
        player.CharacterAdded:Connect(function()
            task.wait(0.5)
            CreateESP(player)
        end)
    end
end)

WindUI:Notify({
    Title = "MM2 Script",
    Content = "Script loaded!",
    Icon = "solar:bell-bold",
    Duration = 3,
})