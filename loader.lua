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
    LoadingSubtitle = "by KT471 & hokpry",
    Theme = "DarkBlue",
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false,
    ConfigurationSaving = { Enabled = true, FolderName = "mixware", FileName = "config" },
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
            "mixware2026",
            "kt471",
            "hokpry",
            "mixmm2ontop",
            "admin123"
        }
    }
})

local LoaderTab = Window:CreateTab("Loader", "download")
local InfoTab = Window:CreateTab("Info", "info")
local CreditsTab = Window:CreateTab("Credits", "users")

-- Информация
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

-- Основная вкладка
LoaderTab:CreateParagraph({
    Title = "MIXWARE LOADER",
    Content = "Нажми кнопку ниже для загрузки MM2 скрипта"
})

LoaderTab:CreateButton({
    Name = "Загрузить MM2 Script",
    Callback = function()
        Window:Destroy()
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
        else
            Rayfield:Notify({
                Title = "MIXWARE",
                Content = "Ошибка загрузки: " .. tostring(result),
                Duration = 5,
                Image = "x"
            })
        end
    end
})

LoaderTab:CreateButton({
    Name = "Закрыть лоадер",
    Callback = function()
        Window:Destroy()
    end
})
