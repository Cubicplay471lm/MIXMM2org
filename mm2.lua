-- ============ ОПТИМИЗАЦИЯ ДЛЯ ЭКЗЕКУТОРА ============
-- Обёртка для безопасной загрузки
local function safeRequire(module)
    local success, result = pcall(function()
        return require(module)
    end)
    return success, result
end

local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

-- Если WindUI не загрузился - создаём минимальный GUI
if not WindUI then
    print("[NF] Создание резервного GUI")
    WindUI = {
        CreateWindow = function(config)
            return {
                Tab = function() return {} end,
                Notify = function() end,
                Destroy = function() end
            }
        end
    }
end

-- ============ ПОДКЛЮЧЕНИЕ СЕРВИСОВ (С ЗАЩИТОЙ) ============
local Services = {
    RunService = game:GetService("RunService"),
    Players = game:GetService("Players"),
    Workspace = game:GetService("Workspace"),
    UserInputService = game:GetService("UserInputService"),
    TweenService = game:GetService("TweenService"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    TeleportService = game:GetService("TeleportService"),
    VirtualUser = game:GetService("VirtualUser") -- Для эмуляции ввода
}

local LocalPlayer = Services.Players.LocalPlayer
local RunService = Services.RunService
local Players = Services.Players
local Workspace = Services.Workspace
local ReplicatedStorage = Services.ReplicatedStorage

-- ============ КЛОН REF (ДЛЯ ОБХОДА АНТИЧИТА) ============
local cloneref = cloneref or clonereference or function(instance)
    return instance
end

-- Клонируем важные объекты для обхода античита
local clonedRemote = ReplicatedStorage and cloneref(ReplicatedStorage) or nil
local clonedPlayers = cloneref(Players)

-- ============ ПЕРЕМЕННЫЕ ============
local ESPEnabled = false
local ESPObjects = {}
local AutoFarmEnabled = false
local KillAuraEnabled = false
local GodModeEnabled = false
local TeleportEnabled = false
local CoinFarmEnabled = false
local FastJumpEnabled = false
local AntiAFKEnabled = false

local KillAuraRange = 15
local WalkSpeed = 16
local JumpPower = 50
local AttackCooldown = false
local CoinsCollected = 0

-- ============ ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ ============
local function getCharacter(plr)
    if not plr then return nil end
    local char = plr.Character
    if char and char.Parent == Workspace then
        return char
    end
    return nil
end

local function getRootPart(char)
    if not char then return nil end
    local root = char:FindFirstChild("HumanoidRootPart")
    if root and root.Parent == char then
        return root
    end
    return nil
end

local function getHumanoid(char)
    if not char then return nil end
    local hum = char:FindFirstChild("Humanoid")
    if hum and hum.Parent == char then
        return hum
    end
    return nil
end

-- ============ ESP (С ИСПРАВЛЕНИЯМИ ДЛЯ ЭКЗЕКУТОРА) ============
local function CreateESP(player)
    if not player or not player.Character then return end
    
    local char = player.Character
    local name = player.Name
    
    -- Создаём Highlight через Drawing (для некоторых экзекуторов)
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP_" .. name
    highlight.FillTransparency = 1
    highlight.OutlineColor = Color3.fromRGB(255, 50, 50)
    highlight.OutlineTransparency = 0
    highlight.Parent = char
    
    -- Billboard
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_Billboard_" .. name
    billboard.Size = UDim2.new(0, 100, 0, 20)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = char
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(255, 50, 50)
    label.TextStrokeTransparency = 0
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 14
    label.Parent = billboard
    
    table.insert(ESPObjects, {
        Highlight = highlight,
        Billboard = billboard,
        Player = player
    })
end

local function ToggleESP(state)
    ESPEnabled = state
    
    if state then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                CreateESP(player)
            end
        end
        
        -- Следим за новыми игроками
        Players.PlayerAdded:Connect(function(player)
            if ESPEnabled then
                player.CharacterAdded:Connect(function(char)
                    task.wait(0.5)
                    if ESPEnabled then
                        CreateESP(player)
                    end
                end)
            end
        end)
    else
        for _, esp in ipairs(ESPObjects) do
            pcall(function()
                esp.Highlight:Destroy()
                esp.Billboard:Destroy()
            end)
        end
        ESPObjects = {}
    end
end

-- ============ АТАКА (С РАБОЧИМ УДАРОМ) ============
local function AttackPlayer(player)
    if not player or not player.Character or AttackCooldown then return end
    AttackCooldown = true
    
    local char = player.Character
    local root = getRootPart(char)
    if not root then return end
    
    -- Метод 1: Remote
    local remoteNames = {"RemoteEvent", "AttackRemote", "MurdererAttack", "KnifeRemote", "HitRemote"}
    local foundRemote = false
    
    for _, name in ipairs(remoteNames) do
        local remote = ReplicatedStorage:FindFirstChild(name)
        if remote then
            pcall(function()
                remote:FireServer(char)
                print("[NF] Атака через " .. name)
                foundRemote = true
            end)
            break
        end
    end
    
    -- Метод 2: Через инструмент
    if not foundRemote then
        local tools = {
            LocalPlayer.Backpack:GetChildren(),
            LocalPlayer.Character:GetChildren()
        }
        
        for _, toolList in ipairs(tools) do
            for _, tool in ipairs(toolList) do
                if tool:IsA("Tool") then
                    pcall(function()
                        tool:Activate()
                        task.wait(0.05)
                        tool:Deactivate()
                        print("[NF] Атака через " .. tool.Name)
                        foundRemote = true
                    end)
                    break
                end
            end
            if foundRemote then break end
        end
    end
    
    -- Метод 3: FireTouchInterest
    if not foundRemote then
        local localRoot = getRootPart(LocalPlayer.Character)
        if localRoot then
            pcall(function()
                firetouchinterest(localRoot, root, 0)
                task.wait()
                firetouchinterest(localRoot, root, 1)
            end)
        end
    end
    
    task.wait(0.15)
    AttackCooldown = false
end

-- ============ AUTOFARM ============
local function GetNearestPlayer(range)
    local nearest = nil
    local minDist = range or 50
    local localRoot = getRootPart(LocalPlayer.Character)
    
    if not localRoot then return nil end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local root = getRootPart(player.Character)
            if root then
                local dist = (localRoot.Position - root.Position).Magnitude
                if dist < minDist then
                    minDist = dist
                    nearest = player
                end
            end
        end
    end
    return nearest
end

local function AutoFarmLoop()
    while AutoFarmEnabled do
        task.wait(0.2)
        local localRoot = getRootPart(LocalPlayer.Character)
        if not localRoot then continue end
        
        local target = GetNearestPlayer(50)
        if target then
            local targetRoot = getRootPart(target.Character)
            if targetRoot then
                localRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 2)
                task.wait(0.1)
                AttackPlayer(target)
            end
        end
    end
end

-- ============ KILLAURA ============
local function KillAuraLoop()
    while KillAuraEnabled do
        task.wait(0.1)
        local localRoot = getRootPart(LocalPlayer.Character)
        if not localRoot then continue end
        
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local targetRoot = getRootPart(player.Character)
                if targetRoot then
                    local dist = (localRoot.Position - targetRoot.Position).Magnitude
                    if dist <= KillAuraRange then
                        AttackPlayer(player)
                        task.wait(0.05)
                    end
                end
            end
        end
    end
end

-- ============ GODMODE ============
local GodModeConnection = nil

local function ToggleGodMode(state)
    GodModeEnabled = state
    
    if GodModeConnection then
        GodModeConnection:Disconnect()
        GodModeConnection = nil
    end
    
    if state then
        -- Блокировка урона через Heartbeat
        GodModeConnection = RunService.Heartbeat:Connect(function()
            local hum = getHumanoid(LocalPlayer.Character)
            if hum then
                hum.Health = hum.MaxHealth
            end
        end)
        
        -- Дополнительная защита через Remote
        pcall(function()
            local damageRemote = ReplicatedStorage:FindFirstChild("DamageRemote")
            if damageRemote then
                damageRemote.OnClientEvent:Connect(function(damage)
                    if GodModeEnabled then
                        return -- Игнорируем урон
                    end
                end)
            end
        end)
    end
end

-- ============ COINFARM (УЛУЧШЕННЫЙ) ============
local function CoinFarmLoop()
    while CoinFarmEnabled do
        task.wait(0.15)
        local localRoot = getRootPart(LocalPlayer.Character)
        if not localRoot then continue end
        
        local coinObjects = {}
        
        -- Собираем все монеты
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("BasePart") and (v.Name:lower():find("coin") or v.Name:lower():find("gem") or v.Name:lower():find("cash")) then
                local dist = (localRoot.Position - v.Position).Magnitude
                if dist < 30 then
                    table.insert(coinObjects, v)
                end
            end
        end
        
        -- Собираем монеты
        for _, coin in ipairs(coinObjects) do
            pcall(function()
                -- Touch метод
                firetouchinterest(localRoot, coin, 0)
                task.wait()
                firetouchinterest(localRoot, coin, 1)
                
                -- Remote метод
                local coinRemote = ReplicatedStorage:FindFirstChild("CoinRemote") 
                    or ReplicatedStorage:FindFirstChild("Collect")
                    or ReplicatedStorage:FindFirstChild("Pickup")
                
                if coinRemote then
                    coinRemote:FireServer(coin)
                end
            end)
            CoinsCollected = CoinsCollected + 1
        end
    end
end

-- ============ ANTI-AFK ============
local function AntiAFKLoop()
    while AntiAFKEnabled do
        task.wait(60)
        pcall(function()
            local vu = Services.VirtualUser
            if vu then
                vu:CaptureController()
                vu:ClickButton2(Vector2.new())
            end
        end)
    end
end

-- ============ GUI (С АДАПТАЦИЕЙ) ============
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
    Title = "v2.0 (Executor Optimized)",
    Icon = "github",
    Color = Color3.fromHex("#1c1c1c"),
    Border = true,
})

-- ============ MAIN TAB ============
local MainTab = Window:Tab({
    Title = "Main",
    Icon = "solar:home-2-bold",
    IconColor = Color3.fromHex("#83889E"),
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
        local hum = getHumanoid(LocalPlayer.Character)
        if hum then
            hum.WalkSpeed = value
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
        local hum = getHumanoid(LocalPlayer.Character)
        if hum then
            hum.JumpPower = value
        end
    end,
})

-- ============ TELEPORT TAB ============
local TeleportTab = Window:Tab({
    Title = "Teleport",
    Icon = "solar:square-transfer-horizontal-bold",
    IconColor = Color3.fromHex("#257AF7"),
    IconShape = "Square",
    Border = true,
})

TeleportTab:Section({ Title = "Teleport to Player" })

local teleportDropdown = TeleportTab:Dropdown({
    Title = "Select Player",
    Values = {},
    Value = nil,
    Callback = function(name)
        if name then
            for _, player in ipairs(Players:GetPlayers()) do
                if player.Name:lower() == name:lower() then
                    local targetRoot = getRootPart(player.Character)
                    local localRoot = getRootPart(LocalPlayer.Character)
                    if targetRoot and localRoot then
                        localRoot.CFrame = targetRoot.CFrame
                    end
                    break
                end
            end
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
    IconColor = Color3.fromHex("#ECA201"),
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

-- ============ MISC TAB ============
local MiscTab = Window:Tab({
    Title = "Misc",
    Icon = "solar:info-square-bold",
    IconColor = Color3.fromHex("#7775F2"),
    IconShape = "Square",
    Border = true,
})

MiscTab:Toggle({
    Title = "Anti-AFK",
    Desc = "Prevent auto-disconnect",
    Callback = function(state)
        AntiAFKEnabled = state
        if state then
            task.spawn(AntiAFKLoop)
        end
    end,
})

MiscTab:Space()

MiscTab:Button({
    Title = "Rejoin Server",
    Icon = "rotate-cw",
    Justify = "Center",
    Color = Color3.fromHex("#257AF7"),
    Callback = function()
        pcall(function()
            local ts = Services.TeleportService
            ts:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
        end)
    end,
})

MiscTab:Space()

MiscTab:Button({
    Title = "Server Hop",
    Icon = "server",
    Justify = "Center",
    Color = Color3.fromHex("#10C550"),
    Callback = function()
        pcall(function()
            local ts = Services.TeleportService
            ts:Teleport(game.PlaceId, LocalPlayer)
        end)
    end,
})

MiscTab:Space()

MiscTab:Button({
    Title = "Destroy GUI",
    Icon = "shredder",
    Justify = "Center",
    Color = Color3.fromHex("#EF4F1D"),
    Callback = function()
        Window:Destroy()
    end,
})

-- ============ ПОСТОЯННЫЕ ОБНОВЛЕНИЯ (ДЛЯ ЭКЗЕКУТОРА) ============
RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    
    local hum = getHumanoid(char)
    if not hum then return end
    
    -- Поддержание скорости
    if hum.WalkSpeed ~= WalkSpeed then
        hum.WalkSpeed = WalkSpeed
    end
    
    if hum.JumpPower ~= JumpPower then
        hum.JumpPower = JumpPower
    end
end)

-- ============ ПЕРЕЗАГРУЗКА ПРИ РЕСПАВНЕ ============
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    
    if GodModeEnabled then
        ToggleGodMode(true)
    end
    
    local hum = getHumanoid(char)
    if hum then
        hum.WalkSpeed = WalkSpeed
        hum.JumpPower = JumpPower
    end
end)

-- ============ УВЕДОМЛЕНИЕ ============
WindUI:Notify({
    Title = "MM2 Script",
    Content = "Script loaded successfully! (Executor Optimized)",
    Icon = "solar:bell-bold",
    Duration = 3,
})

print("[NF] MM2 Script v2.0 загружен!")
print("[NF] Игрок: " .. LocalPlayer.Name)
print("[NF] GameId: " .. game.GameId)
