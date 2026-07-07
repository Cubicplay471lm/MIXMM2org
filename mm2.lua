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

-- ==================== ESP (ИНТЕГРИРОВАННАЯ) ====================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera
local cache = {}

local bones = {
    {"Head", "UpperTorso"},
    {"UpperTorso", "RightUpperArm"},
    {"RightUpperArm", "RightLowerArm"},
    {"RightLowerArm", "RightHand"},
    {"UpperTorso", "LeftUpperArm"},
    {"LeftUpperArm", "LeftLowerArm"},
    {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "LowerTorso"},
    {"LowerTorso", "LeftUpperLeg"},
    {"LeftUpperLeg", "LeftLowerLeg"},
    {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"},
    {"RightUpperLeg", "RightLowerLeg"},
    {"RightLowerLeg", "RightFoot"}
}

-- Настройки ESP
local ESP_SETTINGS = {
    BoxOutlineColor = Color3.new(0, 0, 0),
    BoxColor = Color3.new(1, 1, 1),
    NameColor = Color3.new(1, 1, 1),
    HealthOutlineColor = Color3.new(0, 0, 0),
    HealthHighColor = Color3.new(0, 1, 0),
    HealthLowColor = Color3.new(1, 0, 0),
    CharSize = Vector2.new(4, 6),
    Teamcheck = false,
    WallCheck = false,
    Enabled = false,
    ShowBox = false,
    BoxType = "2D",
    ShowName = false,
    ShowHealth = false,
    ShowDistance = false,
    ShowSkeletons = false,
    ShowTracer = false,
    TracerColor = Color3.new(1, 1, 1),
    TracerThickness = 2,
    SkeletonsColor = Color3.new(1, 1, 1),
    TracerPosition = "Bottom",
}

-- Функции создания
local function create(class, properties)
    local drawing = Drawing.new(class)
    for property, value in pairs(properties) do
        drawing[property] = value
    end
    return drawing
end

-- Функция получения роли игрока (для MM2)
local function GetPlayerRole(player)
    if player == localPlayer then
        if localPlayer.Character then
            for _, item in ipairs(localPlayer.Character:GetChildren()) do
                if item:IsA("Tool") then
                    local name = item.Name:lower()
                    if name:find("knife") then return "murderer" end
                    if name:find("gun") or name:find("pistol") or name:find("revolver") then return "sheriff" end
                end
            end
        end
        if localPlayer.Backpack then
            for _, item in ipairs(localPlayer.Backpack:GetChildren()) do
                if item:IsA("Tool") then
                    local name = item.Name:lower()
                    if name:find("knife") then return "murderer" end
                    if name:find("gun") or name:find("pistol") or name:find("revolver") then return "sheriff" end
                end
            end
        end
        return "innocent"
    end
    
    -- Проверка других игроков
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
    if role == "murderer" then return "🔪" end
    if role == "sheriff" then return "⭐" end
    return ""
end

-- Создание ESP
local function createEsp(player)
    local esp = {
        tracer = create("Line", {
            Thickness = ESP_SETTINGS.TracerThickness,
            Color = ESP_SETTINGS.TracerColor,
            Transparency = 0.5
        }),
        boxOutline = create("Square", {
            Color = ESP_SETTINGS.BoxOutlineColor,
            Thickness = 3,
            Filled = false
        }),
        box = create("Square", {
            Color = ESP_SETTINGS.BoxColor,
            Thickness = 1,
            Filled = false
        }),
        name = create("Text", {
            Color = ESP_SETTINGS.NameColor,
            Outline = true,
            Center = true,
            Size = 13
        }),
        healthOutline = create("Line", {
            Thickness = 3,
            Color = ESP_SETTINGS.HealthOutlineColor
        }),
        health = create("Line", {
            Thickness = 1
        }),
        distance = create("Text", {
            Color = Color3.new(1, 1, 1),
            Size = 12,
            Outline = true,
            Center = true
        }),
        roleText = create("Text", {
            Color = Color3.new(1, 1, 1),
            Size = 14,
            Outline = true,
            Center = true
        }),
        boxLines = {},
    }

    cache[player] = esp
    cache[player]["skeletonlines"] = {}
end

local function isPlayerBehindWall(player)
    local character = player.Character
    if not character then return false end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return false end
    local ray = Ray.new(camera.CFrame.Position, (rootPart.Position - camera.CFrame.Position).Unit * (rootPart.Position - camera.CFrame.Position).Magnitude)
    local hit, position = workspace:FindPartOnRayWithIgnoreList(ray, {localPlayer.Character, character})
    return hit and hit:IsA("Part")
end

local function removeEsp(player)
    local esp = cache[player]
    if not esp then return end
    for _, drawing in pairs(esp) do
        if drawing and drawing.Remove then
            pcall(function() drawing:Remove() end)
        end
    end
    if esp.skeletonlines then
        for _, lineData in ipairs(esp.skeletonlines) do
            local skeletonLine = lineData[1]
            if skeletonLine and skeletonLine.Remove then
                pcall(function() skeletonLine:Remove() end)
            end
        end
    end
    cache[player] = nil
end

local function updateEsp()
    for player, esp in pairs(cache) do
        local character = player.Character
        if character and ESP_SETTINGS.Enabled then
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            local head = character:FindFirstChild("Head")
            local humanoid = character:FindFirstChild("Humanoid")
            local isBehindWall = ESP_SETTINGS.WallCheck and isPlayerBehindWall(player)
            local shouldShow = not isBehindWall and ESP_SETTINGS.Enabled
            
            if rootPart and head and humanoid and shouldShow then
                local position, onScreen = camera:WorldToViewportPoint(rootPart.Position)
                if onScreen then
                    local hrp2D = camera:WorldToViewportPoint(rootPart.Position)
                    local charSize = (camera:WorldToViewportPoint(rootPart.Position - Vector3.new(0, 3, 0)).Y - camera:WorldToViewportPoint(rootPart.Position + Vector3.new(0, 2.6, 0)).Y) / 2
                    local boxSize = Vector2.new(math.floor(charSize * 1.8), math.floor(charSize * 1.9))
                    local boxPosition = Vector2.new(math.floor(hrp2D.X - charSize * 1.8 / 2), math.floor(hrp2D.Y - charSize * 1.6 / 2))
                    
                    -- Роль игрока
                    local role = GetPlayerRole(player)
                    local roleColor = GetRoleColor(role)
                    local roleName = GetRoleName(role)
                    
                    -- Имя
                    if ESP_SETTINGS.ShowName and ESP_SETTINGS.Enabled then
                        esp.name.Visible = true
                        local displayName = player.Name
                        if roleName ~= "" then
                            displayName = displayName .. " " .. roleName
                        end
                        esp.name.Text = displayName
                        esp.name.Position = Vector2.new(boxSize.X / 2 + boxPosition.X, boxPosition.Y - 16)
                        esp.name.Color = role ~= "innocent" and roleColor or ESP_SETTINGS.NameColor
                    else
                        esp.name.Visible = false
                    end
                    
                    -- Роль (под именем)
                    if roleName ~= "" then
                        esp.roleText.Visible = true
                        esp.roleText.Text = roleName
                        esp.roleText.Position = Vector2.new(boxSize.X / 2 + boxPosition.X, boxPosition.Y - 30)
                        esp.roleText.Color = roleColor
                    else
                        esp.roleText.Visible = false
                    end
                    
                    -- Бокс
                    if ESP_SETTINGS.ShowBox and ESP_SETTINGS.Enabled then
                        local boxColor = role ~= "innocent" and roleColor or ESP_SETTINGS.BoxColor
                        
                        if ESP_SETTINGS.BoxType == "2D" then
                            esp.boxOutline.Size = boxSize
                            esp.boxOutline.Position = boxPosition
                            esp.box.Size = boxSize
                            esp.box.Position = boxPosition
                            esp.box.Color = boxColor
                            esp.box.Visible = true
                            esp.boxOutline.Visible = true
                            for _, line in ipairs(esp.boxLines) do
                                pcall(function() line:Remove() end)
                            end
                            esp.boxLines = {}
                        elseif ESP_SETTINGS.BoxType == "Corner Box Esp" then
                            local lineW = (boxSize.X / 5)
                            local lineH = (boxSize.Y / 6)
                            local lineT = 1
                            
                            if #esp.boxLines == 0 then
                                for i = 1, 16 do
                                    local boxLine = create("Line", {
                                        Thickness = 1,
                                        Color = boxColor,
                                        Transparency = 1
                                    })
                                    esp.boxLines[#esp.boxLines + 1] = boxLine
                                end
                            end
                            
                            local boxLines = esp.boxLines
                            
                            -- Top left
                            boxLines[1].From = Vector2.new(boxPosition.X - lineT, boxPosition.Y - lineT)
                            boxLines[1].To = Vector2.new(boxPosition.X + lineW, boxPosition.Y - lineT)
                            boxLines[2].From = Vector2.new(boxPosition.X - lineT, boxPosition.Y - lineT)
                            boxLines[2].To = Vector2.new(boxPosition.X - lineT, boxPosition.Y + lineH)
                            
                            -- Top right
                            boxLines[3].From = Vector2.new(boxPosition.X + boxSize.X - lineW, boxPosition.Y - lineT)
                            boxLines[3].To = Vector2.new(boxPosition.X + boxSize.X + lineT, boxPosition.Y - lineT)
                            boxLines[4].From = Vector2.new(boxPosition.X + boxSize.X + lineT, boxPosition.Y - lineT)
                            boxLines[4].To = Vector2.new(boxPosition.X + boxSize.X + lineT, boxPosition.Y + lineH)
                            
                            -- Bottom left
                            boxLines[5].From = Vector2.new(boxPosition.X - lineT, boxPosition.Y + boxSize.Y - lineH)
                            boxLines[5].To = Vector2.new(boxPosition.X - lineT, boxPosition.Y + boxSize.Y + lineT)
                            boxLines[6].From = Vector2.new(boxPosition.X - lineT, boxPosition.Y + boxSize.Y + lineT)
                            boxLines[6].To = Vector2.new(boxPosition.X + lineW, boxPosition.Y + boxSize.Y + lineT)
                            
                            -- Bottom right
                            boxLines[7].From = Vector2.new(boxPosition.X + boxSize.X - lineW, boxPosition.Y + boxSize.Y + lineT)
                            boxLines[7].To = Vector2.new(boxPosition.X + boxSize.X + lineT, boxPosition.Y + boxSize.Y + lineT)
                            boxLines[8].From = Vector2.new(boxPosition.X + boxSize.X + lineT, boxPosition.Y + boxSize.Y - lineH)
                            boxLines[8].To = Vector2.new(boxPosition.X + boxSize.X + lineT, boxPosition.Y + boxSize.Y + lineT)
                            
                            -- Inline
                            for i = 9, 16 do
                                boxLines[i].Thickness = 2
                                boxLines[i].Color = ESP_SETTINGS.BoxOutlineColor
                                boxLines[i].Transparency = 1
                            end
                            
                            boxLines[9].From = Vector2.new(boxPosition.X, boxPosition.Y)
                            boxLines[9].To = Vector2.new(boxPosition.X, boxPosition.Y + lineH)
                            boxLines[10].From = Vector2.new(boxPosition.X, boxPosition.Y)
                            boxLines[10].To = Vector2.new(boxPosition.X + lineW, boxPosition.Y)
                            boxLines[11].From = Vector2.new(boxPosition.X + boxSize.X - lineW, boxPosition.Y)
                            boxLines[11].To = Vector2.new(boxPosition.X + boxSize.X, boxPosition.Y)
                            boxLines[12].From = Vector2.new(boxPosition.X + boxSize.X, boxPosition.Y)
                            boxLines[12].To = Vector2.new(boxPosition.X + boxSize.X, boxPosition.Y + lineH)
                            boxLines[13].From = Vector2.new(boxPosition.X, boxPosition.Y + boxSize.Y - lineH)
                            boxLines[13].To = Vector2.new(boxPosition.X, boxPosition.Y + boxSize.Y)
                            boxLines[14].From = Vector2.new(boxPosition.X, boxPosition.Y + boxSize.Y)
                            boxLines[14].To = Vector2.new(boxPosition.X + lineW, boxPosition.Y + boxSize.Y)
                            boxLines[15].From = Vector2.new(boxPosition.X + boxSize.X - lineW, boxPosition.Y + boxSize.Y)
                            boxLines[15].To = Vector2.new(boxPosition.X + boxSize.X, boxPosition.Y + boxSize.Y)
                            boxLines[16].From = Vector2.new(boxPosition.X + boxSize.X, boxPosition.Y + boxSize.Y - lineH)
                            boxLines[16].To = Vector2.new(boxPosition.X + boxSize.X, boxPosition.Y + boxSize.Y)
                            
                            for _, line in ipairs(boxLines) do
                                line.Visible = true
                                line.Color = boxColor
                            end
                            esp.box.Visible = false
                            esp.boxOutline.Visible = false
                        end
                    else
                        esp.box.Visible = false
                        esp.boxOutline.Visible = false
                        for _, line in ipairs(esp.boxLines) do
                            pcall(function() line:Remove() end)
                        end
                        esp.boxLines = {}
                    end
                    
                    -- Здоровье
                    if ESP_SETTINGS.ShowHealth and ESP_SETTINGS.Enabled then
                        esp.healthOutline.Visible = true
                        esp.health.Visible = true
                        local healthPercentage = humanoid.Health / humanoid.MaxHealth
                        esp.healthOutline.From = Vector2.new(boxPosition.X - 6, boxPosition.Y + boxSize.Y)
                        esp.healthOutline.To = Vector2.new(esp.healthOutline.From.X, esp.healthOutline.From.Y - boxSize.Y)
                        esp.health.From = Vector2.new((boxPosition.X - 5), boxPosition.Y + boxSize.Y)
                        esp.health.To = Vector2.new(esp.health.From.X, esp.health.From.Y - healthPercentage * boxSize.Y)
                        esp.health.Color = ESP_SETTINGS.HealthLowColor:Lerp(ESP_SETTINGS.HealthHighColor, healthPercentage)
                    else
                        esp.healthOutline.Visible = false
                        esp.health.Visible = false
                    end
                    
                    -- Дистанция
                    if ESP_SETTINGS.ShowDistance and ESP_SETTINGS.Enabled then
                        local distance = (camera.CFrame.p - rootPart.Position).Magnitude
                        esp.distance.Text = string.format("%.1f studs", distance)
                        esp.distance.Position = Vector2.new(boxPosition.X + boxSize.X / 2, boxPosition.Y + boxSize.Y + 5)
                        esp.distance.Visible = true
                    else
                        esp.distance.Visible = false
                    end
                    
                    -- Скелет
                    if ESP_SETTINGS.ShowSkeletons and ESP_SETTINGS.Enabled then
                        if #esp["skeletonlines"] == 0 then
                            for _, bonePair in ipairs(bones) do
                                local parentBone, childBone = bonePair[1], bonePair[2]
                                if player.Character and player.Character[parentBone] and player.Character[childBone] then
                                    local skeletonLine = create("Line", {
                                        Thickness = 1,
                                        Color = ESP_SETTINGS.SkeletonsColor,
                                        Transparency = 1
                                    })
                                    esp["skeletonlines"][#esp["skeletonlines"] + 1] = {skeletonLine, parentBone, childBone}
                                end
                            end
                        end
                        
                        for _, lineData in ipairs(esp["skeletonlines"]) do
                            local skeletonLine = lineData[1]
                            local parentBone, childBone = lineData[2], lineData[3]
                            
                            if player.Character and player.Character[parentBone] and player.Character[childBone] then
                                local parentPosition = camera:WorldToViewportPoint(player.Character[parentBone].Position)
                                local childPosition = camera:WorldToViewportPoint(player.Character[childBone].Position)
                                
                                skeletonLine.From = Vector2.new(parentPosition.X, parentPosition.Y)
                                skeletonLine.To = Vector2.new(childPosition.X, childPosition.Y)
                                skeletonLine.Color = ESP_SETTINGS.SkeletonsColor
                                skeletonLine.Visible = true
                            else
                                skeletonLine.Visible = false
                            end
                        end
                    else
                        for _, lineData in ipairs(esp["skeletonlines"]) do
                            local skeletonLine = lineData[1]
                            skeletonLine.Visible = false
                        end
                    end
                    
                    -- Трейсер
                    if ESP_SETTINGS.ShowTracer and ESP_SETTINGS.Enabled then
                        local tracerY
                        if ESP_SETTINGS.TracerPosition == "Top" then
                            tracerY = 0
                        elseif ESP_SETTINGS.TracerPosition == "Middle" then
                            tracerY = camera.ViewportSize.Y / 2
                        else
                            tracerY = camera.ViewportSize.Y
                        end
                        esp.tracer.Visible = true
                        esp.tracer.From = Vector2.new(camera.ViewportSize.X / 2, tracerY)
                        esp.tracer.To = Vector2.new(hrp2D.X, hrp2D.Y)
                        esp.tracer.Color = role ~= "innocent" and roleColor or ESP_SETTINGS.TracerColor
                    else
                        esp.tracer.Visible = false
                    end
                else
                    -- Скрываем всё
                    for _, drawing in pairs(esp) do
                        if drawing and drawing.Visible ~= nil then
                            drawing.Visible = false
                        end
                    end
                    for _, lineData in ipairs(esp["skeletonlines"]) do
                        local skeletonLine = lineData[1]
                        if skeletonLine then
                            skeletonLine.Visible = false
                        end
                    end
                    for _, line in ipairs(esp.boxLines) do
                        pcall(function() line:Remove() end)
                    end
                    esp.boxLines = {}
                end
            else
                -- Скрываем всё
                for _, drawing in pairs(esp) do
                    if drawing and drawing.Visible ~= nil then
                        drawing.Visible = false
                    end
                end
                for _, lineData in ipairs(esp["skeletonlines"]) do
                    local skeletonLine = lineData[1]
                    if skeletonLine then
                        skeletonLine.Visible = false
                    end
                end
                for _, line in ipairs(esp.boxLines) do
                    pcall(function() line:Remove() end)
                end
                esp.boxLines = {}
            end
        else
            -- Скрываем всё
            for _, drawing in pairs(esp) do
                if drawing and drawing.Visible ~= nil then
                    drawing.Visible = false
                end
            end
            for _, lineData in ipairs(esp["skeletonlines"]) do
                local skeletonLine = lineData[1]
                if skeletonLine then
                    skeletonLine.Visible = false
                end
            end
            for _, line in ipairs(esp.boxLines) do
                pcall(function() line:Remove() end)
            end
            esp.boxLines = {}
        end
    end
end

-- Инициализация ESP
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= localPlayer then
        createEsp(player)
    end
end

Players.PlayerAdded:Connect(function(player)
    if player ~= localPlayer then
        createEsp(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    removeEsp(player)
end)

RunService.RenderStepped:Connect(updateEsp)

-- ==================== ОСТАЛЬНЫЕ ПЕРЕМЕННЫЕ ====================
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")

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

-- ==================== GUI ====================
local Window = Rayfield:CreateWindow({
    Name = "MIXWARE | MM2 Script",
    Icon = "skull",
    LoadingTitle = "MIXWARE Loading...",
    LoadingSubtitle = "by KT471 & hokpry",
    Theme = "DarkBlue",
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false,
    ConfigurationSaving = { Enabled = true, FolderName = "mixware", FileName = "config" },
    Discord = { Enabled = false, Invite = "", RememberJoins = true },
    KeySystem = false,
})

-- ==================== ТАБЫ ====================
local MainTab = Window:CreateTab("Main", "swords")
local VisualsTab = Window:CreateTab("Visuals", "eye")
local MovementTab = Window:CreateTab("Movement", "plane")
local TeleportTab = Window:CreateTab("Teleport", "map-pin")
local FarmTab = Window:CreateTab("Farm", "coins")
local MiscTab = Window:CreateTab("Misc", "settings")
local FlingTab = Window:CreateTab("Fling", "zap")
local GunTab = Window:CreateTab("Gun Grab", "target")
local SettingsTab = Window:CreateTab("Settings", "settings")

-- ==================== ФУНКЦИИ (NOCLIP, FLY, FLING, GUN GRAB, KILL AURA) ====================
local function ToggleNoclip(state)
    NoclipEnabled = state
    if state then
        if NoclipConnection then NoclipConnection:Disconnect() end
        NoclipConnection = RunService.Stepped:Connect(function()
            if localPlayer.Character then
                for _, part in ipairs(localPlayer.Character:GetDescendants()) do
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
        if localPlayer.Character then
            for _, part in ipairs(localPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end

local function ToggleFly(state)
    FlyEnabled = state
    if state then
        local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
        local root = character:WaitForChild("HumanoidRootPart")
        local hum = character:WaitForChild("Humanoid")
        hum.PlatformStand = true
        FlyConnection = RunService.RenderStepped:Connect(function()
            if root then
                local dir = Vector3.new()
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= Vector3.new(0,1,0) end
                if dir.Magnitude > 0 then dir = dir.Unit * FlySpeed end
                root.Velocity = dir
            end
        end)
    else
        if FlyConnection then FlyConnection:Disconnect(); FlyConnection = nil end
        if localPlayer.Character then
            local hum = localPlayer.Character:FindFirstChild("Humanoid")
            if hum then hum.PlatformStand = false end
        end
    end
end

local function ToggleFling(state)
    FlingEnabled = state
    
    if state then
        if not localPlayer.Character then return end
        
        FlingParts = {}
        for _, child in pairs(localPlayer.Character:GetDescendants()) do
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
        bambam.Parent = localPlayer.Character.HumanoidRootPart
        bambam.AngularVelocity = Vector3.new(0, 99999, 0)
        bambam.MaxTorque = Vector3.new(0, math.huge, 0)
        bambam.P = math.huge
        
        local hum = localPlayer.Character:FindFirstChild("Humanoid")
        if hum then
            hum.PlatformStand = false
            hum.AutoRotate = false
        end
        
        FlingConnection = RunService.RenderStepped:Connect(function()
            if FlingEnabled and localPlayer.Character then
                local root = localPlayer.Character:FindFirstChild("HumanoidRootPart")
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
        
        if localPlayer.Character then
            local root = localPlayer.Character:FindFirstChild("HumanoidRootPart")
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
            
            local hum = localPlayer.Character:FindFirstChild("Humanoid")
            if hum then
                hum.PlatformStand = false
                hum.AutoRotate = true
            end
        end
        
        ToggleNoclip(false)
    end
end

local function ToggleGunGrab(state)
    GunGrabEnabled = state
    if state then
        GunGrabConnection = RunService.RenderStepped:Connect(function()
            if not localPlayer.Character or not localPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
            for _, model in ipairs(Workspace:GetChildren()) do
                if model.Name == "GunDrop" then
                    local rootPart = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChildWhichIsA("BasePart")
                    if rootPart then
                        local pos = rootPart.Position
                        localPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(pos)
                        task.wait(0.5)
                        localPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(Vector3.new(0, 0, 0))
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

local function GetNearestPlayerForFarm(range)
    local nearest, minDist = nil, range or math.huge
    if not localPlayer.Character or not localPlayer.Character:FindFirstChild("HumanoidRootPart") then return nil end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (localPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
            if dist < minDist then minDist = dist; nearest = player end
        end
    end
    return nearest
end

local function AutoFarmLoop() while AutoFarmEnabled do task.wait(0.1) pcall(function()
    if not localPlayer.Character or not localPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    local t = GetNearestPlayerForFarm(50)
    if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then
        localPlayer.Character.HumanoidRootPart.CFrame = t.Character.HumanoidRootPart.CFrame * CFrame.new(0,0,2)
    end
end) end end

local function ToggleGodMode(state)
    GodModeEnabled = state
    pcall(function()
        if not localPlayer.Character then return end
        local hum = localPlayer.Character:FindFirstChild("Humanoid")
        if hum then hum.MaxHealth = state and math.huge or 100; hum.Health = state and math.huge or 100 end
    end)
end

local function CoinFarmLoop() while CoinFarmEnabled do task.wait(0.1) pcall(function()
    if not localPlayer.Character or not localPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v.Name == "Coin" or v.Name == "CoinContainer" then
            local coin = v:IsA("BasePart") and v or v:FindFirstChildWhichIsA("BasePart")
            if coin then firetouchinterest(localPlayer.Character.HumanoidRootPart, coin, 0); firetouchinterest(localPlayer.Character.HumanoidRootPart, coin, 1) end
        end
    end
end) end end

-- ==================== KILL AURA ====================
local function GetClosestPlayerToCursor()
    local closest = nil
    local minAngle = math.huge
    local mouse = UserInputService:GetMouseLocation()
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local root = player.Character.HumanoidRootPart
            local screenPos, onScreen = camera:WorldToViewportPoint(root.Position)
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
    if not localPlayer.Character or not localPlayer.Character:FindFirstChild("HumanoidRootPart") then return nil end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (localPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
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
    if KillAuraCooldown or not localPlayer.Character then return end
    KillAuraCooldown = true
    
    local myRole = GetPlayerRole(localPlayer)
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
                local direction = (targetRoot.Position - localPlayer.Character.HumanoidRootPart.Position).Unit
                local behindPos = targetRoot.Position - direction * 3
                localPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(behindPos, targetRoot.Position)
                task.wait(0.05)
            end
        end
    else
        KillAuraCooldown = false
        return
    end
    
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        local targetRoot = target.Character.HumanoidRootPart
        local screenPos = camera:WorldToViewportPoint(targetRoot.Position)
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
MainTab:CreateSlider({ Name = "Walk Speed", Range = {16,200}, Increment = 1, CurrentValue = 16, Callback = function(v) WalkSpeed = v; if localPlayer.Character and localPlayer.Character:FindFirstChild("Humanoid") then localPlayer.Character.Humanoid.WalkSpeed = v end end })
MainTab:CreateSlider({ Name = "Jump Power", Range = {50,300}, Increment = 1, CurrentValue = 50, Callback = function(v) JumpPower = v; if localPlayer.Character and localPlayer.Character:FindFirstChild("Humanoid") then localPlayer.Character.Humanoid.JumpPower = v end end })

-- ==================== VISUALS TAB ====================
VisualsTab:CreateSection("ESP Settings")
VisualsTab:CreateToggle({ Name = "ESP Master", CurrentValue = false, Callback = function(s) ESP_SETTINGS.Enabled = s end })

VisualsTab:CreateSection("ESP Types")
VisualsTab:CreateToggle({ Name = "Box ESP", CurrentValue = false, Callback = function(s) ESP_SETTINGS.ShowBox = s end })

VisualsTab:CreateDropdown({
    Name = "Box Type",
    Options = {"2D", "Corner Box Esp"},
    CurrentOption = "2D",
    Callback = function(option)
        ESP_SETTINGS.BoxType = option
    end
})

VisualsTab:CreateToggle({ Name = "Name ESP", CurrentValue = false, Callback = function(s) ESP_SETTINGS.ShowName = s end })
VisualsTab:CreateToggle({ Name = "Health Bar", CurrentValue = false, Callback = function(s) ESP_SETTINGS.ShowHealth = s end })
VisualsTab:CreateToggle({ Name = "Distance", CurrentValue = false, Callback = function(s) ESP_SETTINGS.ShowDistance = s end })
VisualsTab:CreateToggle({ Name = "Tracer", CurrentValue = false, Callback = function(s) ESP_SETTINGS.ShowTracer = s end })

VisualsTab:CreateDropdown({
    Name = "Tracer Position",
    Options = {"Bottom", "Middle", "Top"},
    CurrentOption = "Bottom",
    Callback = function(option)
        ESP_SETTINGS.TracerPosition = option
    end
})

VisualsTab:CreateToggle({ Name = "Skeletons", CurrentValue = false, Callback = function(s) ESP_SETTINGS.ShowSkeletons = s end })

VisualsTab:CreateSection("ESP Colors")
VisualsTab:CreateColorPicker({
    Name = "Box Color",
    Color = Color3.fromRGB(255, 255, 255),
    Callback = function(color)
        ESP_SETTINGS.BoxColor = color
    end
})

VisualsTab:CreateColorPicker({
    Name = "Name Color",
    Color = Color3.fromRGB(255, 255, 255),
    Callback = function(color)
        ESP_SETTINGS.NameColor = color
    end
})

VisualsTab:CreateColorPicker({
    Name = "Tracer Color",
    Color = Color3.fromRGB(255, 255, 255),
    Callback = function(color)
        ESP_SETTINGS.TracerColor = color
    end
})

VisualsTab:CreateColorPicker({
    Name = "Skeleton Color",
    Color = Color3.fromRGB(255, 255, 255),
    Callback = function(color)
        ESP_SETTINGS.SkeletonsColor = color
    end
})

VisualsTab:CreateSlider({
    Name = "Tracer Thickness",
    Range = {1, 5},
    Increment = 1,
    CurrentValue = 2,
    Callback = function(v)
        ESP_SETTINGS.TracerThickness = v
        for _, esp in pairs(cache) do
            if esp.tracer then
                esp.tracer.Thickness = v
            end
        end
    end
})

VisualsTab:CreateSection("Advanced")
VisualsTab:CreateToggle({ Name = "Team Check", CurrentValue = false, Callback = function(s) ESP_SETTINGS.Teamcheck = s end })
VisualsTab:CreateToggle({ Name = "Wall Check", CurrentValue = false, Callback = function(s) ESP_SETTINGS.WallCheck = s end })

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

local function GetPlayerList()
    local names = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= localPlayer then
            table.insert(names, p.Name)
        end
    end
    return names
end

local tpDropdown = TeleportTab:CreateDropdown({
    Name = "Select Player",
    Options = GetPlayerList(),
    CurrentOption = "",
    Callback = function() end
})

TeleportTab:CreateButton({
    Name = "Teleport",
    Callback = function()
        local name = tpDropdown.CurrentOption
        if name and name ~= "" then
            for _, p in ipairs(Players:GetPlayers()) do
                if p.Name == name and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    if localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        localPlayer.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame
                        Rayfield:Notify({
                            Title = "Teleport",
                            Content = "Teleported to " .. name,
                            Duration = 2,
                            Image = "map-pin"
                        })
                        return
                    end
                end
            end
            Rayfield:Notify({
                Title = "Teleport",
                Content = "Player not found!",
                Duration = 2,
                Image = "x"
            })
        end
    end
})

TeleportTab:CreateButton({
    Name = "Refresh Players",
    Callback = function()
        local newList = GetPlayerList()
        tpDropdown:Refresh(newList)
        Rayfield:Notify({
            Title = "Teleport",
            Content = "Список игроков обновлён",
            Duration = 2,
            Image = "refresh"
        })
    end
})

-- ==================== FARM TAB ====================
FarmTab:CreateToggle({ Name = "Auto Coin Farm", CurrentValue = false, Callback = function(s) CoinFarmEnabled = s; if s then task.spawn(CoinFarmLoop) end end })

-- ==================== MISC TAB ====================
MiscTab:CreateButton({ Name = "Rejoin", Callback = function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, localPlayer) end })
MiscTab:CreateButton({ Name = "Server Hop", Callback = function() TeleportService:Teleport(game.PlaceId, localPlayer) end })
MiscTab:CreateButton({ Name = "Destroy GUI", Callback = function() Window:Destroy() end })

-- ==================== SETTINGS TAB ====================
SettingsTab:CreateSection("Внешний вид")

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

SettingsTab:CreateSection("Конфигурации")

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
localPlayer.CharacterAdded:Connect(function(c)
    task.wait(0.5)
    if GodModeEnabled then ToggleGodMode(true) end
    if NoclipEnabled then ToggleNoclip(true) end
    local hum = c:FindFirstChild("Humanoid")
    if hum then hum.WalkSpeed = WalkSpeed; hum.JumpPower = JumpPower end
end)

-- ==================== УВЕДОМЛЕНИЕ ====================
Rayfield:Notify({ Title = "MIXWARE", Content = "MM2 Script Loaded!", Duration = 3, Image = "skull" })
Rayfield:Notify({
    Title = "ESP",
    Content = "Настройки ESP во вкладке Visuals",
    Duration = 3,
    Image = "eye"
})
