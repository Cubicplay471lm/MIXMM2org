-- ============================================
-- MIXWARE.LOL | MM2 Script
-- Разработчики: KT471 & hokpry
-- Версия: 2.0 | 2026
-- ============================================

local loader = {
    Name = "MIXWARE LOADER",
    Version = "2.0",
    Creator = "KT471 & hokpry",
    Date = "07.07.2026",
    Watermark = "NF Project | MM2 Script",
    ScriptURL = "https://raw.githubusercontent.com/Cubicplay471lm/MIXMM2org/refs/heads/main/mm2.lua"
}

print("[MIXWARE] Загрузка...")
print("[MIXWARE] Версия: " .. loader.Version)
print("[MIXWARE] Разработчики: " .. loader.Creator)
print("[MIXWARE] Дата: " .. loader.Date)

-- Водяной знак
local function CreateWatermark()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "Watermark"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = game:GetService("CoreGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 30)
    frame.Position = UDim2.new(0, 10, 1, -40)
    frame.BackgroundTransparency = 0.6
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    local shadow = Instance.new("UIGradient")
    shadow.Rotation = 45
    shadow.Parent = frame
    
    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.Text = "NF Project | MM2 Script | " .. os.date("%H:%M:%S") .. " | " .. game:GetService("RunService").RenderStepped:Wait()
    text.TextColor3 = Color3.fromRGB(180, 180, 200)
    text.TextSize = 14
    text.Font = Enum.Font.GothamBold
    text.TextXAlignment = Enum.TextXAlignment.Center
    text.TextYAlignment = Enum.TextYAlignment.Center
    text.Parent = frame
    
    -- Обновление времени
    spawn(function()
        while true do
            task.wait(1)
            text.Text = "NF Project | MM2 Script | " .. os.date("%H:%M:%S") .. " | MIXWARE"
        end
    end)
    
    return screenGui
end

-- Вызов водяного знака
CreateWatermark()

-- Загрузка основного скрипта
local success, result = pcall(function()
    return game:HttpGet(loader.ScriptURL)
end)

if success then
    loadstring(result)()
    print("[MIXWARE] Скрипт загружен успешно!")
else
    print("[MIXWARE] Ошибка загрузки: " .. tostring(result))
    print("[MIXWARE] Загружаем резервную версию...")
    local backup = game:HttpGet("https://pastebin.com/raw/альтернативная_ссылка")
    loadstring(backup)()
end
