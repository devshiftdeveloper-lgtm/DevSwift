-- Main.lua for DevShift
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

-- Основной модуль DevShift
local DevShift = {}

-- Функция загрузки GUI
function DevShift:LoadGUI()
    -- Загрузка DevShift.lua из GitHub
    local success, err = pcall(function()
        local DevShiftSource = game:HttpGet("https://raw.githubusercontent.com/devshiftdeveloper-lgtm/DevSwift/main/DevShift.lua")
        local func = loadstring(DevShiftSource)
        if func then
            func()
        end
    end)
    
    if not success then
        warn("Failed to load DevShift GUI:", err)
    end
end

-- Функции для игры RLGL
local RLGLFunctions = {
    ["TP TO START"] = function()
        if LocalPlayer.Character then
            local humanoidRootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                humanoidRootPart.CFrame = CFrame.new(-55.3, 1023.1, -545.8)
                return true
            end
        end
        return false
    end,
    
    ["TP TO END"] = function()
        if LocalPlayer.Character then
            local humanoidRootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                humanoidRootPart.CFrame = CFrame.new(-214.4, 1023.1, 146.7)
                return true
            end
        end
        return false
    end
}

-- Функции для игры DALGONA
local DalgonaFunctions = {
    ["Complete Dalgona"] = function()
        task.spawn(function()
            local DalgonaClientModule = ReplicatedStorage:FindFirstChild("Modules") and
                                        ReplicatedStorage.Modules:FindFirstChild("Games") and
                                        ReplicatedStorage.Modules.Games:FindFirstChild("DalgonaClient")
            if not DalgonaClientModule then return end
            for _, func in pairs(getreg()) do
                if typeof(func) == "function" and islclosure(func) then
                    local info = getinfo(func)
                    if info.nups == 76 then
                        setupvalue(func, 33, 9999)
                        setupvalue(func, 34, 9999)
                    end
                end
            end
        end)
        return true
    end,
    
    ["Free Lighter"] = function()
        LocalPlayer:SetAttribute("HasLighter", true)
        return true
    end
}

-- Список всех игр
local GamesList = {
    "RLGL",
    "DALGONA", 
    "PENTATHLON",
    "HNS",
    "GLASS BRIDGE",
    "TUG OF WAR",
    "MINGLE",
    "LAST DINNER",
    "REBEL",
    "SKY SQUID"
}

-- Создание интерфейса для игр
function DevShift:CreateGamesTab()
    -- Эта функция будет вызываться когда пользователь нажимает на вкладку Games
    -- В реальном DevShift.lua это будет интегрировано в GUI
    
    return {
        RLGL = RLGLFunctions,
        DALGONA = DalgonaFunctions,
        GamesList = GamesList
    }
end

-- Основная функция инициализации
function DevShift:Init()
    print("DevShift Main loaded successfully")
    
    -- Загружаем GUI
    self:LoadGUI()
    
    -- Создаем модуль игр
    self.GamesModule = self:CreateGamesTab()
    
    -- Возвращаем основной модуль
    return self
end

-- Инициализируем DevShift
return DevShift:Init()
