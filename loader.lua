-- ============================================
-- MIXWARE.LOL | LOADER
-- Разработчики: KT471 & hokpry
-- Версия: 2.0 | 2026
-- ============================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- ==================== KEY SYSTEM ====================
local Window = Rayfield:CreateWindow({
    Name = "MIXWARE LOADER",
    Icon = "download",
    LoadingTitle = "MIXWARE LOADER",
    LoadingSubtitle = "by KT471 & Lmeron",
    Theme = "DarkBlue",
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false,
    ConfigurationSaving = { Enabled = true, FolderName = "mixware", FileName = "loader_config" },
    Discord = { Enabled = false, Invite = "", RememberJoins = true },
    KeySystem = true,
    KeySettings = {
        Title = "MIXWARE | Key System",
        Subtitle = "Введите ключ для доступа",
        Note = "Ключ можно получить у разработчиков",
        FileName = "mixware_key",
        SaveKey = true,
        GrabKeyFromSite = false,
        Key = {
            "mixwareontop"
        }
    }
})

local LoaderTab = Window:CreateTab("Loader", "download")
local InfoTab = Window:CreateTab("Info", "info")
local CreditsTab = Window:CreateTab("Credits", "users")
local SettingsTab = Window:CreateTab("Settings", "settings")

-- ==================== ПЕРЕМЕННЫЕ ====================
local AutoLoadEnabled = true
local LoaderClosed = false

-- ==================== ФУНКЦИЯ ЗАГРУЗКИ ====================
local function LoadMM2Script()
    if LoaderClosed then return end
    
    Rayfield:Notify({
        Title = "MIXWARE",
        Content = "Загрузка MM2 Script...",
        Duration = 2,
        Image = "download"
    })
    
    local success, result = pcall(function()
        return game:HttpGet("https://raw.githubusercontent.com/Cubicplay471lm/MIXMM2org/refs/heads/main/mm2.lua")
    end)
    
    if success then
        loadstring(result)()
        Rayfield:Notify({
            Title = "MIXWARE",
            Content = "MM2 Script загружен!",
            Duration = 3,
            Image = "check"
        })
        -- Закрываем лоадер после загрузки
        task.wait(1)
        Window:Destroy()
    else
        Rayfield:Notify({
            Title = "MIXWARE",
            Content = "Ошибка загрузки: " .. tostring(result),
            Duration = 5,
            Image = "x"
        })
    end
end

-- ==================== АВТОМАТИЧЕСКАЯ ЗАГРУЗКА ====================
-- Функция для автозагрузки с задержкой
local function AutoLoad()
    if not AutoLoadEnabled then return end
    
    -- Проверяем, что ключ уже был введён (сохранён)
    local keyFile = "mixware_key"
    local hasKey = false
    
    pcall(function()
        local content = readfile(keyFile)
        if content and content ~= "" then
            hasKey = true
        end
    end)
    
    if hasKey then
        -- Если ключ сохранён - загружаем сразу
        task.wait(0.5)
        LoadMM2Script()
    else
        -- Если ключа нет - ждём ввода и загружаем через 3 секунды после успешного ввода
        task.wait(3)
        if not LoaderClosed then
            LoadMM2Script()
        end
    end
end

-- ==================== GUI ====================
InfoTab:CreateParagraph({
    Title = "MIXWARE LOADER",
    Content = "Версия: 2.0\nДата: 07.07.2026\nСтатус: ONLINE\n\nРазработчики: KT471 & hokpry"
})

InfoTab:CreateParagraph({
    Title = "MIXWARE",
    Content = "Добро пожаловать в MIXWARE!\nНаш сайт: mixware.lol"
})

CreditsTab:CreateParagraph({
    Title = "Разработчики",
    Content = "KT471 (Главный разработчик)\nhokpry (Соразработчик)"
})

CreditsTab:CreateParagraph({
    Title = "Благодарности",
    Content = "Спасибо за использование MIXWARE!\n\nНаш сайт: mixware.lol"
})

-- ==================== ВКЛАДКА НАСТРОЕК ====================
SettingsTab:CreateSection("Автозагрузка")

SettingsTab:CreateToggle({
    Name = "🔄 Автоматическая загрузка",
    CurrentValue = AutoLoadEnabled,
    Callback = function(value)
        AutoLoadEnabled = value
        Rayfield:Notify({
            Title = "Автозагрузка",
            Content = value and "Включена" or "Выключена",
            Duration = 2,
            Image = "refresh"
        })
    end
})

SettingsTab:CreateSection("Настройки")

local themes = {"DarkBlue", "Dark", "Light", "Amber", "Midnight", "Ocean", "Crimson", "Purple", "Green", "Galaxy"}
SettingsTab:CreateDropdown({
    Name = "Тема",
    Options = themes,
    CurrentOption = "DarkBlue",
    Callback = function(option)
        Rayfield:ChangeTheme(option)
    end
})

-- ==================== КНОПКИ ====================
LoaderTab:CreateParagraph({
    Title = "MIXWARE LOADER",
    Content = "Нажми кнопку ниже для загрузки MM2 скрипта\n\nАвтозагрузка: " .. (AutoLoadEnabled and "✅ ВКЛ" or "❌ ВЫКЛ")
})

LoaderTab:CreateButton({
    Name = "🚀 Загрузить MM2 Script",
    Callback = LoadMM2Script
})

LoaderTab:CreateButton({
    Name = "📦 Загрузить MM2 Script (Резерв)",
    Callback = function()
        if LoaderClosed then return end
        
        Rayfield:Notify({
            Title = "MIXWARE",
            Content = "Загрузка резервной версии...",
            Duration = 2,
            Image = "download"
        })
        
        local success, result = pcall(function()
            return game:HttpGet("https://pastebin.com/raw/альтернативная_ссылка")
        end)
        
        if success then
            loadstring(result)()
            Rayfield:Notify({
                Title = "MIXWARE",
                Content = "Резервная версия загружена!",
                Duration = 3,
                Image = "check"
            })
            task.wait(1)
            Window:Destroy()
        else
            Rayfield:Notify({
                Title = "MIXWARE",
                Content = "Ошибка загрузки резерва!",
                Duration = 5,
                Image = "x"
            })
        end
    end
})

LoaderTab:CreateButton({
    Name = "❌ Закрыть лоадер",
    Callback = function()
        LoaderClosed = true
        Window:Destroy()
    end
})

-- ==================== ЗАПУСК АВТОЗАГРУЗКИ ====================
-- Запускаем автозагрузку после того, как интерфейс полностью загрузится
task.spawn(function()
    task.wait(1) -- Ждём инициализацию Rayfield
    AutoLoad()
end)

-- Если пользователь ввёл ключ вручную через интерфейс, тоже запускаем автозагрузку
-- Rayfield сам вызывает KeySystem, мы просто ждём
