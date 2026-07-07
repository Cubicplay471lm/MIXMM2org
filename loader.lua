-- ============ ЗАГРУЗКА RAYFIELD ============
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- ============ СОЗДАНИЕ WINDOW С KEY SYSTEM ============
local Window = Rayfield:CreateWindow({
    Name = "NF Project | MM2",
    Icon = 0,
    LoadingTitle = "Проверка ключа...",
    LoadingSubtitle = "by NF Project",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "NFProject",
        FileName = "NFData"
    },
    KeySystem = true,  -- Включаем систему ключей
    KeySettings = {
        Title = "NF Key System",
        Subtitle = "Введите ключ для доступа",
        Note = "Ключ можно получить в Discord",
        FileName = "NFKey",
        SaveKey = true,  -- Не сохранять ключ
        GrabKeyFromSite = false,
        Key = {"mixmm2ontop", "MIXMM2ONTOP"}  -- Список ключей
    }
})

-- ============ ОСНОВНОЙ GUI ============
local MainTab = Window:CreateTab("Главная", 4483362458)

-- ============ ИНФОРМАЦИЯ ============
MainTab:CreateParagraph({
    Title = "Информация",
    Content = "GameID: " .. game.GameId .. "\nИгра: " .. game.Name
})

-- ============ КНОПКА ЗАГРУЗКИ MM2 ============
MainTab:CreateButton({
    Name = "Загрузить MM2",
    Callback = function()
        local code = game:HttpGet("https://raw.githubusercontent.com/Cubicplay471lm/MIXMM2org/refs/heads/main/mm2.lua")
        loadstring(code)()
        Rayfield:Notify({
            Title = "Успех",
            Content = "MM2 скрипт загружен!",
            Duration = 3
        })
    end
})

-- ============ АВТОМАТИЧЕСКАЯ ПРОВЕРКА ============
task.wait(1)
local gameId = game.GameId

if gameId == 66654135 then
    -- Автоматическая загрузка MM2
    local code = game:HttpGet("https://raw.githubusercontent.com/Cubicplay471lm/MIXMM2org/refs/heads/main/mm2.lua")
    loadstring(code)()
    Rayfield:Notify({
        Title = "Автозагрузка",
        Content = "MM2 скрипт загружен автоматически!",
        Duration = 3
    })
else
    Rayfield:Notify({
        Title = "Выбор",
        Content = "Выберите скрипт вручную",
        Duration = 3
    })
end
