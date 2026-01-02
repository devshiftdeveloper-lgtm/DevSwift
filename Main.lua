-- Main.lua
-- Загружается через: loadstring(game:HttpGet("https://raw.githubusercontent.com/devshiftdeveloper-lgtm/DevSwift/main/Main.lua"))()

local MainModule = {}

-- Сервисы
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- RLGL Функции
function MainModule.TPToStartRLGL()
    local character = LocalPlayer.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        character.HumanoidRootPart.CFrame = CFrame.new(-55.3, 1023.1, -545.8)
    end
end

function MainModule.TPToEndRLGL()
    local character = LocalPlayer.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        character.HumanoidRootPart.CFrame = CFrame.new(-214.4, 1023.1, 146.7)
    end
end

-- DALGONA Функции
function MainModule.CompleteDalgona()
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
end

function MainModule.FreeLighter()
    LocalPlayer:SetAttribute("HasLighter", true)
end

-- PENTATHLON (Coming Soon)
function MainModule.PentathlonComingSoon()
    print("Pentathlon features coming soon...")
end

-- HNS (Coming Soon)
function MainModule.HNSComingSoon()
    print("HNS features coming soon...")
end

-- GLASS BRIDGE (Coming Soon)
function MainModule.GlassBridgeComingSoon()
    print("Glass Bridge features coming soon...")
end

-- TUG OF WAR (Coming Soon)
function MainModule.TugOfWarComingSoon()
    print("Tug of War features coming soon...")
end

-- MINGLE (Coming Soon)
function MainModule.MingleComingSoon()
    print("Mingle features coming soon...")
end

-- LAST DINNER (Coming Soon)
function MainModule.LastDinnerComingSoon()
    print("Last Dinner features coming soon...")
end

-- REBEL (Coming Soon)
function MainModule.RebelComingSoon()
    print("Rebel features coming soon...")
end

-- SKY SQUID (Coming Soon)
function MainModule.SkySquidComingSoon()
    print("Sky Squid features coming soon...")
end

return MainModule
