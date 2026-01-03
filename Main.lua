local MainModule = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
end)

function MainModule.ShowNotification(title, text, duration)
    duration = duration or 3
    task.spawn(function()
        local gui = Instance.new("ScreenGui")
        gui.Name = "NotificationGui"
        gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
        gui.ResetOnSpawn = false
        gui.Parent = game:GetService("CoreGui")

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 350, 0, 0)
        frame.AutomaticSize = Enum.AutomaticSize.Y
        frame.Position = UDim2.new(1, -370, 0, 50)
        frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
        frame.BorderSizePixel = 0
        frame.ZIndex = 9999
        frame.Parent = gui

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = frame

        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(60, 60, 60)
        stroke.Thickness = 2
        stroke.Parent = frame

        local titleLabel = Instance.new("TextLabel")
        titleLabel.Size = UDim2.new(1, -20, 0, 25)
        titleLabel.Position = UDim2.new(0, 10, 0, 10)
        titleLabel.BackgroundTransparency = 1
        titleLabel.Text = title
        titleLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
        titleLabel.TextSize = 18
        titleLabel.Font = Enum.Font.GothamBold
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.ZIndex = 10000
        titleLabel.Parent = frame

        local textLabel = Instance.new("TextLabel")
        textLabel.Size = UDim2.new(1, -20, 0, 0)
        textLabel.Position = UDim2.new(0, 10, 0, 35)
        textLabel.BackgroundTransparency = 1
        textLabel.Text = text
        textLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
        textLabel.TextSize = 14
        textLabel.Font = Enum.Font.Gotham
        textLabel.TextXAlignment = Enum.TextXAlignment.Left
        textLabel.TextYAlignment = Enum.TextYAlignment.Top
        textLabel.TextWrapped = true
        textLabel.AutomaticSize = Enum.AutomaticSize.Y
        textLabel.ZIndex = 10000
        textLabel.Parent = frame

        frame.Size = UDim2.new(0, 350, 0, textLabel.TextBounds.Y + 50)

        TweenService:Create(frame, TweenInfo.new(0.3), {
            Position = UDim2.new(1, -370, 0, 50)
        }):Play()

        task.wait(duration)

        TweenService:Create(frame, TweenInfo.new(0.3), {
            Position = UDim2.new(1, 400, 0, 50)
        }):Play()

        task.wait(0.3)
        gui:Destroy()
    end)
end

local function SafeDestroy(obj)
    if obj and obj.Parent then
        pcall(function() obj:Destroy() end)
    end
end

local function GetCharacter()
    return LocalPlayer.Character
end

local function GetHumanoid(character)
    return character and character:FindFirstChildOfClass("Humanoid")
end

local function GetRootPart(character)
    return character and character:FindFirstChild("HumanoidRootPart")
end

local function playerHasKnife(player)
    if not player or not player.Character then return false end
    for _, tool in pairs(player.Character:GetChildren()) do
        if tool:IsA("Tool") then
            local toolName = tool.Name:lower()
            if toolName:find("knife") or toolName:find("fork") or toolName:find("dagger") or toolName:find("нож") then
                return true, tool
            end
        end
    end
    if player:FindFirstChild("Backpack") then
        for _, tool in pairs(player.Backpack:GetChildren()) do
            if tool:IsA("Tool") then
                local toolName = tool.Name:lower()
                if toolName:find("knife") or toolName:find("fork") or toolName:find("dagger") or toolName:find("нож") then
                    return true, tool
                end
            end
        end
    end
    return false, nil
end

local function GetDistance(position1, position2)
    if not position1 or not position2 then return math.huge end
    return (position1 - position2).Magnitude
end

local function IsHider(player)
    if not player then return false end
    return player:GetAttribute("IsHider") == true
end

local function IsSeeker(player)
    if not player then return false end
    return player:GetAttribute("IsHunter") == true
end

local function IsGameActive(gameName)
    local values = Workspace:FindFirstChild("Values")
    if not values then return false end
    local currentGame = values:FindFirstChild("CurrentGame")
    if not currentGame then return false end
    return currentGame.Value == gameName
end

local function SafeTeleport(position)
    local character = GetCharacter()
    if character then
        local rootPart = GetRootPart(character)
        if rootPart then
            rootPart.CFrame = CFrame.new(position)
            return true
        end
    end
    return false
end

local function GetEnemies()
    local enemies = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(enemies, player.Name)
        end
    end
    return enemies
end

local function KillEnemy(enemyName)
    local enemy = Players:FindFirstChild(enemyName)
    if enemy and enemy.Character then
        local humanoid = enemy.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:TakeDamage(100)
        end
    end
end

function MainModule.RLGL_TP_ToStart()
    task.spawn(function()
        if not IsGameActive("RedLightGreenLight") then
            MainModule.ShowNotification("RLGL", "Game not active", 2)
            return
        end
        if SafeTeleport(Vector3.new(-55.3, 1023.1, -545.8)) then
            MainModule.ShowNotification("RLGL", "Teleported to Start", 2)
        end
    end)
end

function MainModule.RLGL_TP_ToEnd()
    task.spawn(function()
        if not IsGameActive("RedLightGreenLight") then
            MainModule.ShowNotification("RLGL", "Game not active", 2)
            return
        end
        if SafeTeleport(Vector3.new(-214.4, 1023.1, 146.7)) then
            MainModule.ShowNotification("RLGL", "Teleported to End", 2)
        end
    end)
end

function MainModule.Dalgona_Complete()
    task.spawn(function()
        if not IsGameActive("Dalgona") then
            MainModule.ShowNotification("Dalgona", "Game not active", 2)
            return
        end
        local DalgonaClientModule = ReplicatedStorage:FindFirstChild("Modules") and
                                    ReplicatedStorage.Modules:FindFirstChild("Games") and
                                    ReplicatedStorage.Modules.Games:FindFirstChild("DalgonaClient")
        if not DalgonaClientModule then 
            MainModule.ShowNotification("Dalgona", "Module not found", 2)
            return 
        end
        
        pcall(function()
            for _, func in pairs(debug.getregistry()) do
                if typeof(func) == "function" and islclosure(func) then
                    local info = debug.getinfo(func)
                    if info.nups == 76 then
                        debug.setupvalue(func, 33, 9999)
                        debug.setupvalue(func, 34, 9999)
                        MainModule.ShowNotification("Dalgona", "Completed Successfully", 2)
                        return
                    end
                end
            end
            MainModule.ShowNotification("Dalgona", "Failed to complete", 2)
        end)
    end)
end

function MainModule.Dalgona_FreeLighter()
    task.spawn(function()
        if not IsGameActive("Dalgona") then
            MainModule.ShowNotification("Dalgona", "Game not active", 2)
            return
        end
        LocalPlayer:SetAttribute("HasLighter", true)
        MainModule.ShowNotification("Dalgona", "Lighter Unlocked", 2)
    end)
end

MainModule.HNS = {
    InfinityStaminaEnabled = false,
    InfinityStaminaConnection = nil
}

function MainModule.ToggleHNSInfinityStamina(enabled)
    if enabled and not IsGameActive("HideAndSeek") then
        MainModule.ShowNotification("HNS", "Game not active", 2)
        MainModule.HNS.InfinityStaminaEnabled = false
        return
    end
    
    if MainModule.HNS.InfinityStaminaConnection then
        MainModule.HNS.InfinityStaminaConnection:Disconnect()
        MainModule.HNS.InfinityStaminaConnection = nil
    end
    
    MainModule.HNS.InfinityStaminaEnabled = enabled
    
    if enabled then
        MainModule.HNS.InfinityStaminaConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.HNS.InfinityStaminaEnabled then 
                if MainModule.HNS.InfinityStaminaConnection then
                    MainModule.HNS.InfinityStaminaConnection:Disconnect()
                    MainModule.HNS.InfinityStaminaConnection = nil
                end
                return 
            end
            
            if not IsGameActive("HideAndSeek") then
                MainModule.HNS.InfinityStaminaEnabled = false
                if MainModule.HNS.InfinityStaminaConnection then
                    MainModule.HNS.InfinityStaminaConnection:Disconnect()
                    MainModule.HNS.InfinityStaminaConnection = nil
                end
                MainModule.ShowNotification("HNS", "Game ended - Infinity Stamina disabled", 2)
                return
            end
            
            local character = GetCharacter()
            if character then
                local stamina = character:FindFirstChild("StaminaVal")
                if stamina then
                    stamina.Value = 100
                end
            end
        end)
        MainModule.ShowNotification("HNS", "Infinity Stamina: ON", 2)
    else
        MainModule.ShowNotification("HNS", "Infinity Stamina: OFF", 2)
    end
end

MainModule.SpikesKillFeature = {
    Enabled = false,
    AnimationId = "rbxassetid://105341857343164",
    SpikesPosition = nil,
    PlatformHeightOffset = 5,
    ReturnDelay = 0.6,
    OriginalCFrame = nil,
    ActiveAnimation = false,
    AnimationStartTime = 0,
    AnimationConnection = nil,
    CharacterAddedConnection = nil,
    AnimationStoppedConnections = {},
    AnimationCheckConnection = nil,
    TrackedAnimations = {},
    SafetyCheckConnection = nil,
    OriginalSpikes = {},
    SpikesRemoved = false,
    NoKnifeTimer = 0
}

function MainModule.ToggleSpikesKill(enabled)
    if enabled and not IsGameActive("HideAndSeek") then
        MainModule.ShowNotification("Spikes Kill", "Game not active", 2)
        MainModule.SpikesKillFeature.Enabled = false
        return
    end
    
    if MainModule.SpikesKillFeature.AnimationConnection then
        MainModule.SpikesKillFeature.AnimationConnection:Disconnect()
        MainModule.SpikesKillFeature.AnimationConnection = nil
    end
    if MainModule.SpikesKillFeature.CharacterAddedConnection then
        MainModule.SpikesKillFeature.CharacterAddedConnection:Disconnect()
        MainModule.SpikesKillFeature.CharacterAddedConnection = nil
    end
    if MainModule.SpikesKillFeature.SafetyCheckConnection then
        MainModule.SpikesKillFeature.SafetyCheckConnection:Disconnect()
        MainModule.SpikesKillFeature.SafetyCheckConnection = nil
    end
    if MainModule.SpikesKillFeature.AnimationCheckConnection then
        MainModule.SpikesKillFeature.AnimationCheckConnection:Disconnect()
        MainModule.SpikesKillFeature.AnimationCheckConnection = nil
    end
    
    for _, conn in ipairs(MainModule.SpikesKillFeature.AnimationStoppedConnections) do
        pcall(function() conn:Disconnect() end)
    end
    MainModule.SpikesKillFeature.AnimationStoppedConnections = {}
    
    MainModule.SpikesKillFeature.OriginalCFrame = nil
    MainModule.SpikesKillFeature.ActiveAnimation = false
    MainModule.SpikesKillFeature.AnimationStartTime = 0
    MainModule.SpikesKillFeature.TrackedAnimations = {}
    MainModule.SpikesKillFeature.NoKnifeTimer = 0
    
    if not enabled then
        MainModule.ShowNotification("Spikes Kill", "Disabled", 2)
        MainModule.SpikesKillFeature.Enabled = false
        return
    end
    
    pcall(function()
        local hideAndSeekMap = workspace:FindFirstChild("HideAndSeekMap")
        local killingParts = hideAndSeekMap and hideAndSeekMap:FindFirstChild("KillingParts")
        if killingParts then
            MainModule.SpikesKillFeature.OriginalSpikes = {}
            for _, spike in pairs(killingParts:GetChildren()) do
                if spike:IsA("BasePart") then
                    table.insert(MainModule.SpikesKillFeature.OriginalSpikes, spike:Clone())
                    if not MainModule.SpikesKillFeature.SpikesPosition then
                        MainModule.SpikesKillFeature.SpikesPosition = spike.Position
                    end
                    spike:Destroy()
                end
            end
            MainModule.SpikesKillFeature.SpikesRemoved = true
        end
    end)
    
    local function teleportToSpikes(character)
        if not character or not character:FindFirstChild("HumanoidRootPart") then
            return
        end
        
        local spikesPosition = MainModule.SpikesKillFeature.SpikesPosition
        if spikesPosition then
            MainModule.SpikesKillFeature.OriginalCFrame = character:GetPrimaryPartCFrame()
            local targetPosition = spikesPosition + Vector3.new(0, MainModule.SpikesKillFeature.PlatformHeightOffset, 0)
            character:SetPrimaryPartCFrame(CFrame.new(targetPosition))
        end
    end
    
    local function returnToOriginalPosition(character)
        if not character or not character:FindFirstChild("HumanoidRootPart") then
            return
        end
        
        if MainModule.SpikesKillFeature.OriginalCFrame then
            character:SetPrimaryPartCFrame(MainModule.SpikesKillFeature.OriginalCFrame)
            MainModule.SpikesKillFeature.OriginalCFrame = nil
        end
    end
    
    local function setupCharacter(char)
        local humanoid = char:WaitForChild("Humanoid")
        
        MainModule.SpikesKillFeature.AnimationConnection = humanoid.AnimationPlayed:Connect(function(track)
            if not MainModule.SpikesKillFeature.Enabled then return end
            
            if track.Animation and track.Animation.AnimationId == MainModule.SpikesKillFeature.AnimationId then
                MainModule.SpikesKillFeature.TrackedAnimations[track] = true
                
                if not MainModule.SpikesKillFeature.ActiveAnimation then
                    MainModule.SpikesKillFeature.ActiveAnimation = true
                    MainModule.SpikesKillFeature.AnimationStartTime = tick()
                    
                    teleportToSpikes(char)
                    
                    local stoppedConn = track.Stopped:Connect(function()
                        task.wait(MainModule.SpikesKillFeature.ReturnDelay)
                        
                        if MainModule.SpikesKillFeature.OriginalCFrame then
                            returnToOriginalPosition(char)
                            MainModule.SpikesKillFeature.ActiveAnimation = false
                            MainModule.SpikesKillFeature.TrackedAnimations = {}
                        end
                    end)
                    table.insert(MainModule.SpikesKillFeature.AnimationStoppedConnections, stoppedConn)
                end
            end
        end)
    end
    
    local char = LocalPlayer.Character
    if char then
        setupCharacter(char)
    end
    
    MainModule.SpikesKillFeature.CharacterAddedConnection = LocalPlayer.CharacterAdded:Connect(function(newChar)
        task.wait(1)
        setupCharacter(newChar)
    end)
    
    MainModule.SpikesKillFeature.SafetyCheckConnection = RunService.Heartbeat:Connect(function()
        if not MainModule.SpikesKillFeature.Enabled then 
            if MainModule.SpikesKillFeature.SafetyCheckConnection then
                MainModule.SpikesKillFeature.SafetyCheckConnection:Disconnect()
                MainModule.SpikesKillFeature.SafetyCheckConnection = nil
            end
            return 
        end
        
        if not IsGameActive("HideAndSeek") then
            MainModule.SpikesKillFeature.Enabled = false
            MainModule.ShowNotification("Spikes Kill", "Game ended - disabled", 2)
            return
        end
        
        if MainModule.SpikesKillFeature.ActiveAnimation and tick() - MainModule.SpikesKillFeature.AnimationStartTime >= 10 then
            local character = GetCharacter()
            if character and MainModule.SpikesKillFeature.OriginalCFrame then
                returnToOriginalPosition(character)
            end
            MainModule.SpikesKillFeature.ActiveAnimation = false
            MainModule.SpikesKillFeature.TrackedAnimations = {}
        end
    end)
    
    MainModule.SpikesKillFeature.Enabled = true
    MainModule.ShowNotification("Spikes Kill", "Enabled", 2)
end


MainModule.AutoGonggi = {
    Enabled = false,
    CheckInterval = 0.05,
    StoneCheckInterval = 0.5,
    LastProcessedImage = nil,
    IsProcessingQTE = false,
    ProcessingStones = false,
    QTEThread = nil,
    StoneThread = nil
}

local function getGonggiUI()
    local player = game:GetService("Players").LocalPlayer
    if not player then return nil end
    
    local playerGui = player:FindFirstChild("PlayerGui")
    if not playerGui then return nil end
    
    local ui = playerGui:FindFirstChild("Gonggi")
    if not ui and playerGui:FindFirstChild("OtherUIHolder") then
        ui = playerGui.OtherUIHolder:FindFirstChild("Gonggi")
    end
    
    return ui
end

local function processGonggiQTE()
    if MainModule.AutoGonggi.IsProcessingQTE then return end
    
    MainModule.AutoGonggi.IsProcessingQTE = true
    
    local ui = getGonggiUI()
    if not ui then 
        MainModule.AutoGonggi.IsProcessingQTE = false
        return 
    end
    
    local qteScreen = ui:FindFirstChild("QTEScreen")
    if not qteScreen or not qteScreen.Visible then
        MainModule.AutoGonggi.LastProcessedImage = nil
        MainModule.AutoGonggi.IsProcessingQTE = false
        return
    end
    
    local container = qteScreen:FindFirstChild("MainBar")
    container = container and container:FindFirstChild("ButtonContents")
    container = container and container:FindFirstChild("Inner")
    
    local mobileButtons = ui:FindFirstChild("MobileButtons")
    
    if not container or not mobileButtons then
        MainModule.AutoGonggi.LastProcessedImage = nil
        MainModule.AutoGonggi.IsProcessingQTE = false
        return
    end
    
    local foundActive = false
    
    for _, img in pairs(container:GetChildren()) do
        if img:IsA("ImageLabel") and img.ImageTransparency < 0.1 then
            foundActive = true
            
            if img ~= MainModule.AutoGonggi.LastProcessedImage then
                MainModule.AutoGonggi.LastProcessedImage = img
                
                local inputType = img:GetAttribute("InputType")
                if inputType then
                    local btnName = tostring(inputType)
                    local btn = mobileButtons:FindFirstChild(btnName)
                    
                    if btn then
                        if getconnections then
                            for _, conn in pairs(getconnections(btn.MouseButton1Click)) do
                                conn:Fire()
                            end
                        elseif firesignal then
                            firesignal(btn.MouseButton1Click)
                        else
                            btn:Fire("MouseButton1Click")
                        end
                        
                        task.wait(0.1)
                    end
                end
            end
            break
        end
    end
    
    if not foundActive then
        MainModule.AutoGonggi.LastProcessedImage = nil
    end
    
    MainModule.AutoGonggi.IsProcessingQTE = false
end

local function processGonggiStones()
    if MainModule.AutoGonggi.ProcessingStones then return end
    MainModule.AutoGonggi.ProcessingStones = true
    
    local pentathlonMap = workspace:FindFirstChild("PentathlonMap")
    if not pentathlonMap then 
        MainModule.AutoGonggi.ProcessingStones = false
        return 
    end
    
    local stoneNames = {"Stone1", "Stone2", "Stone3", "Stone4", "Stone5", 
                       "GonggiStone1", "GonggiStone2", "GonggiStone3", "GonggiStone4", "GonggiStone5"}
    
    for _, stoneName in ipairs(stoneNames) do
        local stone = pentathlonMap:FindFirstChild(stoneName, true)
        if stone and stone:IsA("BasePart") then
            if not stone.Anchored then
                stone.Anchored = true
            end
            
            if stone.CanCollide then
                stone.CanCollide = false
            end
            
            if not stone:FindFirstChild("AutoHighlight") then
                local highlight = Instance.new("Highlight")
                highlight.Name = "AutoHighlight"
                highlight.FillColor = Color3.new(0, 1, 0)
                highlight.OutlineColor = Color3.new(0, 0.8, 0)
                highlight.FillTransparency = 0.7
                highlight.Parent = stone
            end
        end
    end
    
    local collectionService = game:GetService("CollectionService")
    local stones = collectionService:GetTagged("GonggiStone")
    
    for _, stone in ipairs(stones) do
        if stone:IsA("BasePart") then
            if not stone.Anchored then
                stone.Anchored = true
            end
            
            if stone.CanCollide then
                stone.CanCollide = false
            end
            
            if not stone:FindFirstChild("AutoHighlight") then
                local highlight = Instance.new("Highlight")
                highlight.Name = "AutoHighlight"
                highlight.FillColor = Color3.new(0, 1, 0)
                highlight.OutlineColor = Color3.new(0, 0.8, 0)
                highlight.FillTransparency = 0.7
                highlight.Parent = stone
            end
        end
    end
    
    MainModule.AutoGonggi.ProcessingStones = false
end

function MainModule.ToggleAutoGonggi(enabled)
    if not IsGameActive("Pentathlon") then
        MainModule.ShowNotification("AutoGonggi", "Pentathlon game not active", 2)
        if MainModule.AutoGonggi.Enabled then
            MainModule.ToggleAutoGonggi(false)
        end
        return false
    end
    
    if MainModule.AutoGonggi.Enabled == enabled then
        return MainModule.AutoGonggi.Enabled
    end
    
    if MainModule.AutoGonggi.QTEThread then
        task.cancel(MainModule.AutoGonggi.QTEThread)
        MainModule.AutoGonggi.QTEThread = nil
    end
    
    if MainModule.AutoGonggi.StoneThread then
        task.cancel(MainModule.AutoGonggi.StoneThread)
        MainModule.AutoGonggi.StoneThread = nil
    end
    
    MainModule.AutoGonggi.LastProcessedImage = nil
    MainModule.AutoGonggi.IsProcessingQTE = false
    MainModule.AutoGonggi.ProcessingStones = false
    
    MainModule.AutoGonggi.Enabled = enabled
    
    if enabled then
        MainModule.AutoGonggi.QTEThread = task.spawn(function()
            while MainModule.AutoGonggi.Enabled do
                if not IsGameActive("Pentathlon") then
                    MainModule.AutoGonggi.Enabled = false
                    if MainModule.AutoGonggi.QTEThread then
                        task.cancel(MainModule.AutoGonggi.QTEThread)
                        MainModule.AutoGonggi.QTEThread = nil
                    end
                    if MainModule.AutoGonggi.StoneThread then
                        task.cancel(MainModule.AutoGonggi.StoneThread)
                        MainModule.AutoGonggi.StoneThread = nil
                    end
                    MainModule.SnowNotification("AutoGonggi", "Pentathlon ended - AutoGonggi disabled", 2)
                    return
                end
                
                processGonggiQTE()
                task.wait(MainModule.AutoGonggi.CheckInterval)
            end
        end)
        
        MainModule.AutoGonggi.StoneThread = task.spawn(function()
            while MainModule.AutoGonggi.Enabled do
                if not IsGameActive("Pentathlon") then
                    MainModule.AutoGonggi.Enabled = false
                    return
                end
                
                processGonggiStones()
                task.wait(MainModule.AutoGonggi.StoneCheckInterval)
            end
        end)
        MainModule.SnowNotification("AutoGonggi", "AutoGonggi: ON", 2)
    else
        task.spawn(function()
            local pentathlonMap = workspace:FindFirstChild("PentathlonMap")
            if pentathlonMap then
                for _, obj in pairs(pentathlonMap:GetDescendants()) do
                    if obj:IsA("BasePart") and obj:FindFirstChild("AutoHighlight") then
                        obj.AutoHighlight:Destroy()
                    end
                end
            end
            
            local collectionService = game:GetService("CollectionService")
            local stones = collectionService:GetTagged("GonggiStone")
            for _, stone in ipairs(stones) do
                if stone:IsA("BasePart") and stone:FindFirstChild("AutoHighlight") then
                    stone.AutoHighlight:Destroy()
                end
            end
        end)
        MainModule.SnowNotification("AutoGonggi", "AutoGonggi: OFF", 2)
    end
    
    return MainModule.AutoGonggi.Enabled
end

function MainModule.ForceStopAutoGonggi()
    MainModule.ToggleAutoGonggi(false)
end

MainModule.AutoDodge = {
    Enabled = false,
    AnimationIds = {
        "rbxassetid://88451099342711",
        "rbxassetid://79649041083405", 
        "rbxassetid://73242877658272",
        "rbxassetid://114928327045353",
        "rbxassetid://135690448001690", 
        "rbxassetid://103355259844069",
        "rbxassetid://125906547773381",
        "rbxassetid://121147456137931"
    },
    Connections = {},
    LastDodgeTime = 0,
    DodgeCooldown = 1.24,
    Range = 5,
    RangeSquared = 5 * 5,
    AnimationIdsSet = {},
    
    -- Система перехвата
    CapturedCall = nil,
    LastCapturedCallTime = 0,
    OriginalFireServer = nil,
    Remote = nil,
    
    -- Для отслеживания игроков
    TrackedPlayers = {}
}

-- Заполняем сет анимаций
for _, id in ipairs(MainModule.AutoDodge.AnimationIds) do
    MainModule.AutoDodge.AnimationIdsSet[id] = true
end

-- ============ СИСТЕМА ПЕРЕХВАТА ВЫЗОВОВ ============

local function setupRemoteHook()
    local remote = nil
    local rs = game:GetService("ReplicatedStorage")
    
    if rs:FindFirstChild("Remotes") then
        remote = rs.Remotes:FindFirstChild("UsedTool")
    end
    
    if not remote and rs:FindFirstChild("Events") then
        remote = rs.Events:FindFirstChild("UsedTool")
    end
    
    if not remote then
        local function searchRemote(container)
            for _, child in ipairs(container:GetChildren()) do
                if child:IsA("RemoteEvent") and child.Name == "UsedTool" then
                    return child
                end
                local found = searchRemote(child)
                if found then return found end
            end
            return nil
        end
        remote = searchRemote(rs)
    end
    
    if not remote then
        return false
    end
    
    MainModule.AutoDodge.Remote = remote
    
    MainModule.AutoDodge.OriginalFireServer = hookfunction(remote.FireServer, function(self, ...)
        local args = {...}
        
        for i, arg in ipairs(args) do
            if typeof(arg) == "Instance" and arg:IsA("Tool") then
                if arg.Name == "DODGE!" then
                    MainModule.AutoDodge.CapturedCall = {
                        args = {unpack(args)},
                        timestamp = tick(),
                        tool = arg,
                        remote = self
                    }
                    MainModule.AutoDodge.LastCapturedCallTime = tick()
                    break
                end
            elseif typeof(arg) == "table" then
                for _, v in pairs(arg) do
                    if typeof(v) == "Instance" and v:IsA("Tool") then
                        if v.Name == "DODGE!" then
                            MainModule.AutoDodge.CapturedCall = {
                                args = {unpack(args)},
                                timestamp = tick(),
                                tool = v,
                                remote = self
                            }
                            MainModule.AutoDodge.LastCapturedCallTime = tick()
                            break
                        end
                    end
                end
            end
        end
        
        return MainModule.AutoDodge.OriginalFireServer(self, ...)
    end)
    
    return true
end

-- ============ ИСПРАВЛЕННАЯ ФУНКЦИЯ ВЫПОЛНЕНИЯ ДОДЖА ============

local function executeDodge()
    if not MainModule.AutoDodge.Enabled then 
        return false 
    end
    
    local currentTime = tick()
    local autoDodge = MainModule.AutoDodge
    
    if currentTime - autoDodge.LastDodgeTime < autoDodge.DodgeCooldown then
        return false
    end
    
    if not autoDodge.CapturedCall then
        return false
    end
    
    local player = game:GetService("Players").LocalPlayer
    if not player then 
        return false 
    end
    
    local dodgeTool = nil
    local character = player.Character
    
    if character then
        dodgeTool = character:FindFirstChild("DODGE!")
    end
    
    if not dodgeTool and player:FindFirstChild("Backpack") then
        dodgeTool = player.Backpack:FindFirstChild("DODGE!")
    end
    
    if not dodgeTool then
        return false
    end
    
    local modifiedArgs = {}
    for i, arg in ipairs(autoDodge.CapturedCall.args) do
        if typeof(arg) == "Instance" and arg:IsA("Tool") and arg.Name == "DODGE!" then
            modifiedArgs[i] = dodgeTool
        else
            modifiedArgs[i] = arg
        end
    end
    
    autoDodge.LastDodgeTime = currentTime
    
    local success, err = pcall(function()
        autoDodge.Remote:FireServer(unpack(modifiedArgs))
    end)
    
    if success then
        return true
    else
        task.spawn(function()
            pcall(function()
                autoDodge.Remote:FireServer(dodgeTool)
            end)
        end)
        
        return false
    end
end

-- ============ МОМЕНТАЛЬНАЯ ПРОВЕРКА В РАДИУСЕ ============

local function isInRadius(targetRoot, localRoot)
    if not (targetRoot and localRoot) then
        return false
    end
    
    local pos1 = targetRoot.Position
    local pos2 = localRoot.Position
    
    local dx = pos1.X - pos2.X
    local dy = pos1.Y - pos2.Y
    local dz = pos1.Z - pos2.Z
    
    local distanceSquared = dx*dx + dy*dy + dz*dz
    return distanceSquared <= MainModule.AutoDodge.RangeSquared
end

-- ============ МОМЕНТАЛЬНАЯ ПРОВЕРКА ВЗГЛЯДА ============

local function isLookingAtPlayer(targetPlayer, localPlayer)
    if not targetPlayer or not targetPlayer.Character then return false end
    if not localPlayer or not localPlayer.Character then return false end
    
    local targetHead = targetPlayer.Character:FindFirstChild("Head")
    local localRoot = localPlayer.Character:FindFirstChild("HumanoidRootPart")
    
    if not (targetHead and localRoot) then return false end
    
    local directionToLocal = (localRoot.Position - targetHead.Position).Unit
    local lookVector = targetHead.CFrame.LookVector
    
    local dot = directionToLocal:Dot(lookVector)
    
    -- Угол проверки: игрок должен смотреть в нашу сторону
    -- dot > 0 означает, что смотрит в нашу сторону (даже сбоку или сзади)
    -- Обычно используют 0.3-0.5, но ты сказал "неважно сзади спереди сбоку"
    -- Значит проверяем только что вектор взгляда направлен в нашу сторону
    return dot > -0.7 -- Широкий угол для учета "смотрит в нашу сторону"
end

-- ============ МОМЕНТАЛЬНАЯ ОБРАБОТКА АНИМАЦИИ ============

local function createInstantAnimationHandler(player)
    local LocalPlayer = game:GetService("Players").LocalPlayer
    
    return function(track)
        -- МГНОВЕННЫЙ ОТВЕТ: сразу проверяем все условия
        
        -- 1. Проверка включенности
        if not MainModule.AutoDodge.Enabled then return end
        if player == LocalPlayer then return end
        
        -- 2. Проверка ID анимации (мгновенно)
        local animId
        if track and track.Animation then
            animId = track.Animation.AnimationId
        end
        
        if not animId then return end
        if not MainModule.AutoDodge.AnimationIdsSet[animId] then
            return
        end
        
        -- 3. Проверка кулдауна (мгновенно)
        local currentTime = tick()
        if currentTime - MainModule.AutoDodge.LastDodgeTime < MainModule.AutoDodge.DodgeCooldown then
            return
        end
        
        -- 4. Мгновенная проверка персонажей
        if not LocalPlayer or not LocalPlayer.Character then return end
        if not player or not player.Character then return end
        
        -- 5. Мгновенная проверка взгляда
        if not isLookingAtPlayer(player, LocalPlayer) then
            return -- Не смотрит на нас
        end
        
        -- 6. Мгновенная проверка дистанции
        local localRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
        
        if not (localRoot and targetRoot) then return end
        
        local diff = targetRoot.Position - localRoot.Position
        local distanceSquared = diff.X * diff.X + diff.Y * diff.Y + diff.Z * diff.Z
        
        if distanceSquared > MainModule.AutoDodge.RangeSquared then
            return -- Не в радиусе
        end
        
        -- 7. МГНОВЕННО ДОДЖИМ
        executeDodge()
    end
end

-- ============ МОМЕНТАЛЬНАЯ НАСТРОЙКА ОТСЛЕЖИВАНИЯ ============

local function setupInstantPlayerTracking(player)
    local LocalPlayer = game:GetService("Players").LocalPlayer
    if player == LocalPlayer then return end
    
    local function setupCharacter(character)
        if not character or not MainModule.AutoDodge.Enabled then return end
        
        -- НЕТ ЗАДЕРЖЕК! Мгновенная проверка
        local humanoid = character:FindFirstChild("Humanoid")
        if not humanoid then
            -- Если нет Humanoid, ждем мгновенно без task.wait
            return
        end
        
        local handler = createInstantAnimationHandler(player)
        local conn = humanoid.AnimationPlayed:Connect(handler)
        
        -- Сохраняем соединение
        if not MainModule.AutoDodge.TrackedPlayers[player.Name] then
            MainModule.AutoDodge.TrackedPlayers[player.Name] = {}
        end
        table.insert(MainModule.AutoDodge.TrackedPlayers[player.Name], conn)
        table.insert(MainModule.AutoDodge.Connections, conn)
    end
    
    -- Подключаемся к существующему персонажу МГНОВЕННО
    if player.Character then
        setupCharacter(player.Character)
    end
    
    -- Подключаемся к новому персонажу
    local charConn = player.CharacterAdded:Connect(function(character)
        if not MainModule.AutoDodge.Enabled then return end
        
        -- Очищаем старые соединения для этого игрока
        if MainModule.AutoDodge.TrackedPlayers[player.Name] then
            for _, conn in pairs(MainModule.AutoDodge.TrackedPlayers[player.Name]) do
                pcall(function() conn:Disconnect() end)
            end
            MainModule.AutoDodge.TrackedPlayers[player.Name] = {}
        end
        
        -- Мгновенная настройка (без задержек)
        setupCharacter(character)
    end)
    
    table.insert(MainModule.AutoDodge.Connections, charConn)
end

-- ============ ДОПОЛНИТЕЛЬНЫЙ МОНИТОРИНГ (для надежности) ============

local function setupInstantReactionMonitor()
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local LocalPlayer = Players.LocalPlayer
    
    local function instantCheck()
        if not MainModule.AutoDodge.Enabled then return end
        if not LocalPlayer or not LocalPlayer.Character then return end
        
        local currentTime = tick()
        if currentTime - MainModule.AutoDodge.LastDodgeTime < MainModule.AutoDodge.DodgeCooldown then
            return
        end
        
        local localRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not localRoot then return end
        
        -- Мгновенная проверка всех игроков
        for _, player in pairs(Players:GetPlayers()) do
            if player == LocalPlayer then continue end
            if not player.Character then continue end
            
            -- Проверка взгляда
            if not isLookingAtPlayer(player, LocalPlayer) then
                continue
            end
            
            local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
            if not targetRoot then continue end
            
            -- Проверка радиуса
            local diff = targetRoot.Position - localRoot.Position
            local distanceSquared = diff.X * diff.X + diff.Y * diff.Y + diff.Z * diff.Z
            
            if distanceSquared > MainModule.AutoDodge.RangeSquared then
                continue
            end
            
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if not humanoid then continue end
            
            -- Мгновенная проверка анимаций
            for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
                if track and track.Animation and track.IsPlaying then
                    local animId = track.Animation.AnimationId
                    if MainModule.AutoDodge.AnimationIdsSet[animId] then
                        executeDodge()
                        return
                    end
                end
            end
        end
    end
    
    -- RenderStepped для максимальной скорости
    local renderConn = RunService.RenderStepped:Connect(instantCheck)
    table.insert(MainModule.AutoDodge.Connections, renderConn)
end

-- ============ УПРАВЛЕНИЕ СИСТЕМОЙ ============

function MainModule.ToggleAutoDodge(enabled)
    if enabled and not IsGameActive("HideAndSeek") then
        MainModule.SnowNotification("AutoDodge", "HideAndSeek game not active", 2)
        MainModule.AutoDodge.Enabled = false
        return
    end
    
    MainModule.AutoDodge.Enabled = false
    
    for _, conn in pairs(MainModule.AutoDodge.Connections) do
        if conn then
            pcall(function() conn:Disconnect() end)
        end
    end
    
    MainModule.AutoDodge.Connections = {}
    MainModule.AutoDodge.TrackedPlayers = {}
    MainModule.AutoDodge.LastDodgeTime = 0
    
    if enabled then
        MainModule.AutoDodge.Enabled = true
        
        local Players = game:GetService("Players")
        
        local checkGameActiveConnection = RunService.Heartbeat:Connect(function()
            if not IsGameActive("HideAndSeek") then
                MainModule.AutoDodge.Enabled = false
                for _, conn in pairs(MainModule.AutoDodge.Connections) do
                    if conn then
                        pcall(function() conn:Disconnect() end)
                    end
                end
                MainModule.AutoDodge.Connections = {}
                MainModule.AutoDodge.TrackedPlayers = {}
                MainModule.AutoDodge.LastDodgeTime = 0
                MainModule.SnowNotification("AutoDodge", "HideAndSeek ended - AutoDodge disabled", 2)
            end
        end)
        table.insert(MainModule.AutoDodge.Connections, checkGameActiveConnection)
        
        for _, player in pairs(Players:GetPlayers()) do
            setupInstantPlayerTracking(player)
        end
        
        local playerAddedConn = Players.PlayerAdded:Connect(function(player)
            if MainModule.AutoDodge.Enabled then
                setupInstantPlayerTracking(player)
            end
        end)
        table.insert(MainModule.AutoDodge.Connections, playerAddedConn)
        
        setupInstantReactionMonitor()
        MainModule.SnowNotification("AutoDodge", "AutoDodge: ON", 2)
    else
        MainModule.SnowNotification("AutoDodge", "AutoDodge: OFF", 2)
    end
end

-- ============ ОБРАБОТКА ВЫХОДА ИГРОКА ============

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

Players.PlayerRemoving:Connect(function(player)
    if player == LocalPlayer then
        MainModule.ToggleAutoDodge(false)
        MainModule.SnowNotification("AutoDodge", "AutoDodge disabled - local player left", 2)
    elseif MainModule.AutoDodge.TrackedPlayers[player.Name] then
        for _, conn in pairs(MainModule.AutoDodge.TrackedPlayers[player.Name]) do
            pcall(function() conn:Disconnect() end)
        end
        MainModule.AutoDodge.TrackedPlayers[player.Name] = nil
    end
end)

-- ============ ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ ============

function MainModule.ShowCapturedCall()
    if MainModule.AutoDodge.CapturedCall then
        return MainModule.AutoDodge.CapturedCall
    else
        return nil
    end
end

function MainModule.ClearCapturedCall()
    MainModule.AutoDodge.CapturedCall = nil
end

function MainModule.ForceDodge()
    local result = executeDodge()
    return result
end

-- ============ ИНИЦИАЛИЗАЦИЯ ============

task.wait(0.4)

local hookSuccess = setupRemoteHook()

task.spawn(function()
    if MainModule.AutoDodge.Enabled then
        MainModule.ToggleAutoDodge(true)
    end
end)

function MainModule.TeleportToHider()
    task.spawn(function()
        if not IsGameActive("HideAndSeek") then
            MainModule.ShowNotification("HNS", "Game not active", 2)
            return
        end
        local character = GetCharacter()
        if not character or not character:FindFirstChild("HumanoidRootPart") then
            MainModule.ShowNotification("HNS", "Character not found", 2)
            return
        end
        
        local targetPlayer = nil
        local targetRoot = nil
        
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and IsHider(player) then
                local hiderChar = player.Character
                if hiderChar and hiderChar:FindFirstChild("HumanoidRootPart") then
                    targetPlayer = player
                    targetRoot = hiderChar.HumanoidRootPart
                    break
                end
            end
        end
        
        if not targetRoot then
            MainModule.ShowNotification("HNS", "No hider found", 2)
            return
        end
        
        local targetPos = targetRoot.Position
        local currentRoot = character:FindFirstChild("HumanoidRootPart")
        
        if currentRoot then
            currentRoot.CFrame = CFrame.new(targetPos.X, targetPos.Y + 3, targetPos.Z)
            MainModule.ShowNotification("HNS", "Teleported to hider", 2)
        end
    end)
end

MainModule.TugOfWar = {
    AntiMissEnabled = false,
    Connection = nil
}

function MainModule.ToggleAntiMiss(enabled)
    if enabled and not IsGameActive("TugOfWar") then
        MainModule.ShowNotification("Anti Miss", "Game not active", 2)
        MainModule.TugOfWar.AntiMissEnabled = false
        return
    end
    
    MainModule.TugOfWar.AntiMissEnabled = enabled
    
    if MainModule.TugOfWar.Connection then
        MainModule.TugOfWar.Connection:Disconnect()
        MainModule.TugOfWar.Connection = nil
    end

    if enabled then
        MainModule.TugOfWar.Connection = RunService.Heartbeat:Connect(function()
            if not MainModule.TugOfWar.AntiMissEnabled then 
                if MainModule.TugOfWar.Connection then
                    MainModule.TugOfWar.Connection:Disconnect()
                    MainModule.TugOfWar.Connection = nil
                end
                return 
            end
            
            if not IsGameActive("TugOfWar") then
                MainModule.TugOfWar.AntiMissEnabled = false
                if MainModule.TugOfWar.Connection then
                    MainModule.TugOfWar.Connection:Disconnect()
                    MainModule.TugOfWar.Connection = nil
                end
                MainModule.ShowNotification("Anti Miss", "Game ended - disabled", 2)
                return
            end
            
            local player = Players.LocalPlayer
            local gui = player:FindFirstChild("PlayerGui")
            if gui then
                gui = gui:FindFirstChild("QTEEvents")
                if gui then
                    local progress = gui:FindFirstChild("Progress")
                    if progress then
                        local crossHair = progress:FindFirstChild("CrossHair")
                        local goalDot = progress:FindFirstChild("GoalDot")
                        
                        if crossHair and goalDot and crossHair.Parent and goalDot.Parent then
                            crossHair.Rotation = goalDot.Rotation
                        end
                        
                        local buttons = progress:GetChildren()
                        for _, button in ipairs(buttons) do
                            if button:IsA("TextButton") or button:IsA("ImageButton") then
                                if button.Visible and button.Active then
                                    pcall(function()
                                        button:FireEvent("MouseButton1Click")
                                        button:FireEvent("Activated")
                                    end)
                                end
                            elseif button:IsA("ProximityPrompt") then
                                pcall(function()
                                    fireproximityprompt(button)
                                end)
                            end
                        end
                    end
                end
            end
            
            task.wait(0.01)
        end)
        MainModule.ShowNotification("Anti Miss", "Enabled", 2)
    else
        MainModule.ShowNotification("Anti Miss", "Disabled", 2)
    end
end

MainModule.GlassBridge = {
    AntiBreakEnabled = false,
    GlassAntiBreakConnection = nil,
    SafetyPlatforms = {}
}

function MainModule.ToggleAntiBreak(enabled)
    if enabled and not IsGameActive("GlassBridge") then
        MainModule.ShowNotification("Anti Break", "Game not active", 2)
        MainModule.GlassBridge.AntiBreakEnabled = false
        return
    end
    
    MainModule.GlassBridge.AntiBreakEnabled = enabled
    
    if MainModule.GlassBridge.GlassAntiBreakConnection then
        MainModule.GlassBridge.GlassAntiBreakConnection:Disconnect()
        MainModule.GlassBridge.GlassAntiBreakConnection = nil
    end
    
    for _, platform in pairs(MainModule.GlassBridge.SafetyPlatforms) do
        if platform then
            platform:Destroy()
        end
    end
    MainModule.GlassBridge.SafetyPlatforms = {}
    
    if enabled then
        MainModule.GlassBridge.GlassAntiBreakConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.GlassBridge.AntiBreakEnabled then 
                if MainModule.GlassBridge.GlassAntiBreakConnection then
                    MainModule.GlassBridge.GlassAntiBreakConnection:Disconnect()
                    MainModule.GlassBridge.GlassAntiBreakConnection = nil
                end
                return 
            end
            
            if not IsGameActive("GlassBridge") then
                MainModule.GlassBridge.AntiBreakEnabled = false
                if MainModule.GlassBridge.GlassAntiBreakConnection then
                    MainModule.GlassBridge.GlassAntiBreakConnection:Disconnect()
                    MainModule.GlassBridge.GlassAntiBreakConnection = nil
                end
                MainModule.ShowNotification("Anti Break", "Game ended - disabled", 2)
                return
            end
            
            local GlassHolder = workspace:FindFirstChild("GlassBridge") and workspace.GlassBridge:FindFirstChild("GlassHolder")
            if not GlassHolder then return end
            
            for _, lane in pairs(GlassHolder:GetChildren()) do
                for _, glassModel in pairs(lane:GetChildren()) do
                    if glassModel:IsA("Model") and glassModel.PrimaryPart then
                        if glassModel.PrimaryPart:GetAttribute("exploitingisevil") ~= nil then
                            glassModel.PrimaryPart:SetAttribute("exploitingisevil", nil)
                        end
                        
                        if not MainModule.GlassBridge.SafetyPlatforms[glassModel] then
                            local platform = Instance.new("Part")
                            platform.Name = "GlassSafetyPlatform"
                            platform.Size = Vector3.new(20, 1, 20)
                            platform.Position = glassModel.PrimaryPart.Position + Vector3.new(0, -2, 0)
                            platform.Anchored = true
                            platform.CanCollide = true
                            platform.Transparency = 1
                            platform.Color = Color3.fromRGB(255, 255, 255)
                            platform.Material = Enum.Material.Plastic
                            platform.CanQuery = false
                            platform.CastShadow = false
                            
                            platform.Parent = workspace
                            MainModule.GlassBridge.SafetyPlatforms[glassModel] = platform
                        end
                    end
                end
            end
        end)
        MainModule.ShowNotification("Anti Break", "Enabled", 2)
    else
        MainModule.ShowNotification("Anti Break", "Disabled", 2)
    end
end

MainModule.GlassESP = {
    Enabled = false,
    GlassESPConnections = {}
}

local function isRealGlass(part)
    if part:GetAttribute("GlassPart") then
        if part:GetAttribute("ActuallyKilling") ~= nil then
            return false
        end
        return true
    end
    return false
end

local function updateGlassColors()
    if not workspace:FindFirstChild("GlassBridge") then return end
    
    local GlassHolder = workspace.GlassBridge:FindFirstChild("GlassHolder")
    if not GlassHolder then return end
    
    for _, lane in pairs(GlassHolder:GetChildren()) do
        for _, glassModel in pairs(lane:GetChildren()) do
            if glassModel:IsA("Model") then
                for _, part in pairs(glassModel:GetDescendants()) do
                    if part:IsA("BasePart") and part:GetAttribute("GlassPart") then
                        if MainModule.GlassESP.Enabled then
                            if isRealGlass(part) then
                                part.Color = Color3.fromRGB(0, 255, 0)
                            else
                                part.Color = Color3.fromRGB(255, 0, 0)
                            end
                            part.Material = Enum.Material.Neon
                            part:SetAttribute("ExploitingIsEvil", true)
                        else
                            part.Color = Color3.fromRGB(163, 162, 165)
                            part.Material = Enum.Material.Glass
                            part:SetAttribute("ExploitingIsEvil", nil)
                        end
                    end
                end
            end
        end
    end
end

local function clearGlassESP()
    if workspace:FindFirstChild("GlassBridge") then
        local GlassHolder = workspace.GlassBridge:FindFirstChild("GlassHolder")
        if GlassHolder then
            for _, lane in pairs(GlassHolder:GetChildren()) do
                for _, glassModel in pairs(lane:GetChildren()) do
                    if glassModel:IsA("Model") then
                        for _, part in pairs(glassModel:GetDescendants()) do
                            if part:IsA("BasePart") and part:GetAttribute("GlassPart") then
                                part.Color = Color3.fromRGB(163, 162, 165)
                                part.Material = Enum.Material.Glass
                                part:SetAttribute("ExploitingIsEvil", nil)
                            end
                        end
                    end
                end
            end
        end
    end
end

function MainModule.ToggleGlassESP(enabled)
    if enabled and not IsGameActive("GlassBridge") then
        MainModule.ShowNotification("Glass ESP", "Game not active", 2)
        MainModule.GlassESP.Enabled = false
        return
    end
    
    for _, conn in pairs(MainModule.GlassESP.GlassESPConnections) do
        if conn then
            pcall(function() conn:Disconnect() end)
        end
    end
    MainModule.GlassESP.GlassESPConnections = {}
    
    MainModule.GlassESP.Enabled = enabled
    
    if enabled then
        updateGlassColors()
        
        local conn1 = workspace.ChildAdded:Connect(function(child)
            if child.Name == "GlassBridge" then
                task.wait(1)
                updateGlassColors()
            end
        end)
        table.insert(MainModule.GlassESP.GlassESPConnections, conn1)
        
        local conn2 = RunService.Heartbeat:Connect(function()
            if not MainModule.GlassESP.Enabled then 
                if conn2 then
                    conn2:Disconnect()
                end
                return 
            end
            
            if not IsGameActive("GlassBridge") then
                MainModule.GlassESP.Enabled = false
                MainModule.ShowNotification("Glass ESP", "Game ended - disabled", 2)
                clearGlassESP()
                return
            end
            
            updateGlassColors()
        end)
        table.insert(MainModule.GlassESP.GlassESPConnections, conn2)
        
        MainModule.ShowNotification("Glass ESP", "Enabled", 2)
    else
        clearGlassESP()
        MainModule.ShowNotification("Glass ESP", "Disabled", 2)
    end
end

function MainModule.GlassBridge_TP_ToEnd()
    task.spawn(function()
        if not IsGameActive("GlassBridge") then
            MainModule.ShowNotification("Glass Bridge", "Game not active", 2)
            return
        end
        if SafeTeleport(Vector3.new(-196.372467, 522.192139, -1534.20984)) then
            MainModule.ShowNotification("Glass Bridge", "Teleported to End", 2)
        end
    end)
end

function MainModule.TeleportToJumpRopeStart()
    task.spawn(function()
        if not IsGameActive("JumpRope") then
            MainModule.ShowNotification("Jump Rope", "Game not active", 2)
            return
        end
        if SafeTeleport(Vector3.new(615.284424, 192.274277, 920.952515)) then
            MainModule.ShowNotification("Jump Rope", "Teleported to Start", 2)
        end
    end)
end

function MainModule.TeleportToJumpRopeEnd()
    task.spawn(function()
        if not IsGameActive("JumpRope") then
            MainModule.ShowNotification("Jump Rope", "Game not active", 2)
            return
        end
        if SafeTeleport(Vector3.new(720.896057, 198.628311, 921.170654)) then
            MainModule.ShowNotification("Jump Rope", "Teleported to End", 2)
        end
    end)
end

function MainModule.DeleteJumpRope()
    task.spawn(function()
        if not IsGameActive("JumpRope") then
            MainModule.ShowNotification("Jump Rope", "Game not active", 2)
            return
        end
        
        local ropeFound = false
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj.Name == "Rope" then
                if obj:IsA("Model") or obj:IsA("Part") or obj:IsA("MeshPart") then
                    obj:Destroy()
                    ropeFound = true
                    break
                end
            end
        end
        if not ropeFound then
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj.Name:lower():find("rope") and 
                   (obj:IsA("Model") or obj:IsA("Part") or obj:IsA("MeshPart")) then
                    obj:Destroy()
                    ropeFound = true
                    break
                end
            end
        end
        if not ropeFound then
            local effects = workspace:FindFirstChild("Effects")
            if effects then
                for _, obj in pairs(effects:GetDescendants()) do
                    if obj.Name:lower():find("rope") and 
                       (obj:IsA("Model") or obj:IsA("Part") or obj:IsA("MeshPart")) then
                        obj:Destroy()
                        ropeFound = true
                        break
                    end
                end
            end
        end
        
        if ropeFound then
            MainModule.ShowNotification("Jump Rope", "Rope deleted", 2)
        else
            MainModule.ShowNotification("Jump Rope", "Rope not found", 2)
        end
    end)
end

MainModule.JumpRope = {
    AntiFallEnabled = false,
    AntiFallPlatform = nil,
    Connection = nil
}

function MainModule.ToggleJumpRopeAntiFall(enabled)
    if enabled and not IsGameActive("JumpRope") then
        MainModule.ShowNotification("Jump Rope AntiFall", "Game not active", 2)
        MainModule.JumpRope.AntiFallEnabled = false
        return
    end
    
    MainModule.JumpRope.AntiFallEnabled = enabled
    
    if MainModule.JumpRope.Connection then
        MainModule.JumpRope.Connection:Disconnect()
        MainModule.JumpRope.Connection = nil
    end
    
    if MainModule.JumpRope.AntiFallPlatform then
        MainModule.JumpRope.AntiFallPlatform:Destroy()
        MainModule.JumpRope.AntiFallPlatform = nil
    end
    
    if enabled then
        MainModule.JumpRope.Connection = RunService.Heartbeat:Connect(function()
            if not MainModule.JumpRope.AntiFallEnabled then 
                if MainModule.JumpRope.Connection then
                    MainModule.JumpRope.Connection:Disconnect()
                    MainModule.JumpRope.Connection = nil
                end
                return 
            end
            
            if not IsGameActive("JumpRope") then
                MainModule.JumpRope.AntiFallEnabled = false
                if MainModule.JumpRope.Connection then
                    MainModule.JumpRope.Connection:Disconnect()
                    MainModule.JumpRope.Connection = nil
                end
                MainModule.ShowNotification("Jump Rope AntiFall", "Game ended - disabled", 2)
                return
            end
            
            local character = GetCharacter()
            if not character or not character.PrimaryPart then return end
            
            if not MainModule.JumpRope.AntiFallPlatform then
                local platformPosition = character.PrimaryPart.Position + Vector3.new(0, -4, 0)
                
                MainModule.JumpRope.AntiFallPlatform = Instance.new("Part")
                MainModule.JumpRope.AntiFallPlatform.Name = "JumpRopeAntiFallPlatform"
                MainModule.JumpRope.AntiFallPlatform.Size = Vector3.new(500, 2, 500)
                MainModule.JumpRope.AntiFallPlatform.Position = platformPosition
                MainModule.JumpRope.AntiFallPlatform.Anchored = true
                MainModule.JumpRope.AntiFallPlatform.CanCollide = true
                MainModule.JumpRope.AntiFallPlatform.Transparency = 1
                MainModule.JumpRope.AntiFallPlatform.Color = Color3.fromRGB(255, 255, 255)
                MainModule.JumpRope.AntiFallPlatform.Material = Enum.Material.Plastic
                MainModule.JumpRope.AntiFallPlatform.CanQuery = false
                MainModule.JumpRope.AntiFallPlatform.CastShadow = false
                
                MainModule.JumpRope.AntiFallPlatform.Parent = workspace
            else
                local platformPosition = character.PrimaryPart.Position + Vector3.new(0, -4, 0)
                MainModule.JumpRope.AntiFallPlatform.Position = platformPosition
            end
        end)
        MainModule.ShowNotification("Jump Rope AntiFall", "Enabled", 2)
    else
        MainModule.ShowNotification("Jump Rope AntiFall", "Disabled", 2)
    end
end

MainModule.MingleVoidKill = {
    Enabled = false,
    AnimationId = "rbxassetid://71318091779666",
    OriginalPosition = nil,
    OriginalCFrame = nil,
    Platform = nil,
    AnimationTrack = nil,
    Connections = {},
    PlatformHeight = -30,
    PlatformTeleportYOffset = 3,
    PlatformSize = Vector3.new(100, 10, 100),
    PlatformColor = Color3.fromRGB(0, 170, 255),
    IsOnPlatform = false,
    AnimationStartTime = 0
}

local function createSafetyPlatformMingleVoidKill(position)
    if MainModule.MingleVoidKill.Platform then
        MainModule.MingleVoidKill.Platform:Destroy()
        MainModule.MingleVoidKill.Platform = nil
    end
    
    local platformPosition = Vector3.new(
        position.X,
        position.Y + MainModule.MingleVoidKill.PlatformHeight,
        position.Z
    )
    
    local platform = Instance.new("Part")
    platform.Name = "MingleVoidKillSafetyPlatform"
    platform.Size = MainModule.MingleVoidKill.PlatformSize
    platform.Position = platformPosition
    platform.Anchored = true
    platform.CanCollide = true
    platform.Transparency = 0.7
    platform.Color = MainModule.MingleVoidKill.PlatformColor
    platform.Material = Enum.Material.Neon
    
    local pointLight = Instance.new("PointLight")
    pointLight.Brightness = 0.5
    pointLight.Range = 50
    pointLight.Color = Color3.fromRGB(0, 200, 255)
    pointLight.Parent = platform
    
    platform.Transparency = 0.8
    local selectionBox = Instance.new("SelectionBox")
    selectionBox.Adornee = platform
    selectionBox.Color3 = Color3.fromRGB(0, 255, 255)
    selectionBox.LineThickness = 0.05
    selectionBox.Parent = platform
    
    platform.Parent = workspace
    
    MainModule.MingleVoidKill.Platform = platform
    return platform
end

local function teleportToPlatformMingleVoidKill(originalPosition)
    local player = game:GetService("Players").LocalPlayer
    if not player or not player.Character then
        return false
    end
    
    local character = player.Character
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then
        return false
    end
    
    MainModule.MingleVoidKill.OriginalPosition = originalPosition
    MainModule.MingleVoidKill.OriginalCFrame = CFrame.new(originalPosition)
    
    local platform = createSafetyPlatformMingleVoidKill(originalPosition)
    
    local teleportPosition = Vector3.new(
        platform.Position.X,
        platform.Position.Y + MainModule.MingleVoidKill.PlatformTeleportYOffset,
        platform.Position.Z
    )
    
    humanoidRootPart.CFrame = CFrame.new(teleportPosition)
    MainModule.MingleVoidKill.IsOnPlatform = true
    MainModule.MingleVoidKill.AnimationStartTime = tick()
    
    return true
end

local function returnToOriginalPositionMingleVoidKill()
    local player = game:GetService("Players").LocalPlayer
    if not player or not player.Character then
        return false
    end
    
    local character = player.Character
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then
        return false
    end
    
    if MainModule.MingleVoidKill.OriginalPosition then
        local returnPosition = Vector3.new(
            MainModule.MingleVoidKill.OriginalPosition.X,
            MainModule.MingleVoidKill.OriginalPosition.Y,
            MainModule.MingleVoidKill.OriginalPosition.Z
        )
        
        humanoidRootPart.CFrame = CFrame.new(returnPosition)
    end
    
    MainModule.MingleVoidKill.IsOnPlatform = false
    
    if MainModule.MingleVoidKill.Platform then
        MainModule.MingleVoidKill.Platform:Destroy()
        MainModule.MingleVoidKill.Platform = nil
    end
    
    MainModule.MingleVoidKill.OriginalPosition = nil
    MainModule.MingleVoidKill.OriginalCFrame = nil
    MainModule.MingleVoidKill.AnimationTrack = nil
    
    return true
end

local function setupAnimationTrackerMingleVoidKill()
    local player = game:GetService("Players").LocalPlayer
    if not player then return end
    
    local function onCharacterAdded(character)
        local humanoid = character:WaitForChild("Humanoid", 1)
        if not humanoid then return end
        
        humanoid.AnimationPlayed:Connect(function(track)
            if not MainModule.MingleVoidKill.Enabled then return end
            
            local animId = track.Animation and track.Animation.AnimationId
            if animId == MainModule.MingleVoidKill.AnimationId then
                local currentPosition = nil
                local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                if humanoidRootPart then
                    currentPosition = humanoidRootPart.Position
                else
                    currentPosition = character:GetPivot().Position
                end
                
                teleportToPlatformMingleVoidKill(currentPosition)
                MainModule.MingleVoidKill.AnimationTrack = track
                
                local connection
                connection = game:GetService("RunService").Heartbeat:Connect(function()
                    if not track or not track.IsPlaying then
                        returnToOriginalPositionMingleVoidKill()
                        
                        if connection then
                            connection:Disconnect()
                        end
                    end
                end)
                
                table.insert(MainModule.MingleVoidKill.Connections, connection)
            end
        end)
    end
    
    if player.Character then
        onCharacterAdded(player.Character)
    end
    
    player.CharacterAdded:Connect(onCharacterAdded)
    
    local heartbeatConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if not MainModule.MingleVoidKill.Enabled then return end
        
        local character = player.Character
        if not character then return end
        
        local humanoid = character:FindFirstChild("Humanoid")
        if not humanoid then return end
        
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        
        for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
            if track and track.Animation then
                local animId = track.Animation.AnimationId
                if animId == MainModule.MingleVoidKill.AnimationId then
                    
                    if not MainModule.MingleVoidKill.IsOnPlatform then
                        local currentPosition = nil
                        if humanoidRootPart then
                            currentPosition = humanoidRootPart.Position
                        else
                            currentPosition = character:GetPivot().Position
                        end
                        
                        teleportToPlatformMingleVoidKill(currentPosition)
                        MainModule.MingleVoidKill.AnimationTrack = track
                    end
                end
            end
        end
        
        if MainModule.MingleVoidKill.AnimationTrack and MainModule.MingleVoidKill.IsOnPlatform then
            local shouldReturn = false
            
            if MainModule.MingleVoidKill.AnimationTrack then
                if not MainModule.MingleVoidKill.AnimationTrack.IsPlaying then
                    shouldReturn = true
                end
            else
                if tick() - MainModule.MingleVoidKill.AnimationStartTime > 10 then
                    shouldReturn = true
                end
            end
            
            if shouldReturn then
                returnToOriginalPositionMingleVoidKill()
            end
        end
        
        if MainModule.MingleVoidKill.IsOnPlatform and tick() - MainModule.MingleVoidKill.AnimationStartTime > 15 then
            returnToOriginalPositionMingleVoidKill()
        end
    end)
    
    table.insert(MainModule.MingleVoidKill.Connections, heartbeatConnection)
end

function MainModule.ToggleMingleVoidKill(enabled)
    if enabled and not IsGameActive("Mingle") then
        MainModule.ShowNotification("Void Kill", "Game not active", 2)
        MainModule.MingleVoidKill.Enabled = false
        return
    end
    
    MainModule.MingleVoidKill.Enabled = false
    
    for _, conn in pairs(MainModule.MingleVoidKill.Connections) do
        if conn then
            pcall(function() conn:Disconnect() end)
        end
    end
    MainModule.MingleVoidKill.Connections = {}
    
    if MainModule.MingleVoidKill.Platform then
        MainModule.MingleVoidKill.Platform:Destroy()
        MainModule.MingleVoidKill.Platform = nil
    end
    
    MainModule.MingleVoidKill.OriginalPosition = nil
    MainModule.MingleVoidKill.OriginalCFrame = nil
    MainModule.MingleVoidKill.AnimationTrack = nil
    MainModule.MingleVoidKill.IsOnPlatform = false
    MainModule.MingleVoidKill.AnimationStartTime = 0
    
    if enabled then
        MainModule.MingleVoidKill.Enabled = true
        setupAnimationTrackerMingleVoidKill()
        
        local checkConnection = RunService.Heartbeat:Connect(function()
            if MainModule.MingleVoidKill.Enabled and not IsGameActive("Mingle") then
                MainModule.MingleVoidKill.Enabled = false
                MainModule.ShowNotification("Void Kill", "Game ended - disabled", 2)
                checkConnection:Disconnect()
            end
        end)
        table.insert(MainModule.MingleVoidKill.Connections, checkConnection)
        
        MainModule.ShowNotification("Void Kill", "Enabled", 2)
    else
        MainModule.ShowNotification("Void Kill", "Disabled", 2)
    end
end

MainModule.Rebel = {
    Enabled = false,
    Connection = nil,
    LastCheckTime = 0,
    LastKillTime = 0,
    CheckCooldown = 0.1,
    KillCooldown = 0.05
}

function MainModule.ToggleRebel(enabled)
    MainModule.Rebel.Enabled = enabled
    if MainModule.Rebel.Connection then
        MainModule.Rebel.Connection:Disconnect()
        MainModule.Rebel.Connection = nil
    end
    if enabled then
        MainModule.Rebel.Connection = RunService.Heartbeat:Connect(function()
            if not MainModule.Rebel.Enabled then return end
            local currentTime = tick()
            if currentTime - MainModule.Rebel.LastCheckTime < MainModule.Rebel.CheckCooldown then return end
            MainModule.Rebel.LastCheckTime = currentTime
            local enemies = GetEnemies()
            if #enemies == 0 then return end
            for _, enemyName in pairs(enemies) do
                if currentTime - MainModule.Rebel.LastKillTime < MainModule.Rebel.KillCooldown then
                    task.wait(MainModule.Rebel.KillCooldown)
                end
                KillEnemy(enemyName)
                MainModule.Rebel.LastKillTime = tick()
                task.wait(0.05)
            end
        end)
        MainModule.ShowNotification("Rebel", "Instant Rebel Enabled", 2)
    else
        MainModule.Rebel.LastKillTime = 0
        MainModule.Rebel.LastCheckTime = 0
        MainModule.ShowNotification("Rebel", "Instant Rebel Disabled", 2)
    end
end

MainModule.ZoneKillFeature = {
    Enabled = false,
    AnimationId = "rbxassetid://105341857343164",
    ZonePosition = Vector3.new(197.7, 54.6, -96.3),
    ReturnDelay = 0.6,
    SavedCFrame = nil,
    ActiveAnimation = false,
    AnimationStartTime = 0,
    AnimationConnection = nil,
    CharacterAddedConnection = nil,
    AnimationStoppedConnections = {},
    AnimationCheckConnection = nil,
    TrackedAnimations = {}
}

function MainModule.ToggleZoneKill(enabled)
    MainModule.ZoneKillFeature.Enabled = enabled
    
    if MainModule.ZoneKillFeature.AnimationConnection then
        MainModule.ZoneKillFeature.AnimationConnection:Disconnect()
        MainModule.ZoneKillFeature.AnimationConnection = nil
    end
    if MainModule.ZoneKillFeature.CharacterAddedConnection then
        MainModule.ZoneKillFeature.CharacterAddedConnection:Disconnect()
        MainModule.ZoneKillFeature.CharacterAddedConnection = nil
    end
    if MainModule.ZoneKillFeature.AnimationCheckConnection then
        MainModule.ZoneKillFeature.AnimationCheckConnection:Disconnect()
        MainModule.ZoneKillFeature.AnimationCheckConnection = nil
    end
    
    for _, conn in ipairs(MainModule.ZoneKillFeature.AnimationStoppedConnections) do
        pcall(function() conn:Disconnect() end)
    end
    MainModule.ZoneKillFeature.AnimationStoppedConnections = {}
    
    MainModule.ZoneKillFeature.SavedCFrame = nil
    MainModule.ZoneKillFeature.ActiveAnimation = false
    MainModule.ZoneKillFeature.AnimationStartTime = 0
    MainModule.ZoneKillFeature.TrackedAnimations = {}
    
    if not enabled then
        return
    end
    
    local function checkAnimations()
        if not MainModule.ZoneKillFeature.Enabled then return end
        
        local character = GetCharacter()
        if not character then return end
        local humanoid = GetHumanoid(character)
        if not humanoid then return end
        
        local activeTracks = humanoid:GetPlayingAnimationTracks()
        for _, track in pairs(activeTracks) do
            if track and track.Animation then
                local success, animId = pcall(function()
                    return track.Animation.AnimationId
                end)
                
                if success and animId and animId == MainModule.ZoneKillFeature.AnimationId then
                    if not MainModule.ZoneKillFeature.TrackedAnimations[track] then
                        MainModule.ZoneKillFeature.TrackedAnimations[track] = true
                        
                        if not MainModule.ZoneKillFeature.ActiveAnimation then
                            MainModule.ZoneKillFeature.ActiveAnimation = true
                            MainModule.ZoneKillFeature.AnimationStartTime = tick()
                            
                            local primaryPart = character.PrimaryPart or character:FindFirstChild("HumanoidRootPart")
                            if primaryPart then
                                MainModule.ZoneKillFeature.SavedCFrame = primaryPart.CFrame
                                character:SetPrimaryPartCFrame(CFrame.new(MainModule.ZoneKillFeature.ZonePosition))
                            end
                            
                            local stoppedConn = track.Stopped:Connect(function()
                                task.wait(MainModule.ZoneKillFeature.ReturnDelay)
                                
                                if MainModule.ZoneKillFeature.SavedCFrame then
                                    character:SetPrimaryPartCFrame(MainModule.ZoneKillFeature.SavedCFrame)
                                    MainModule.ZoneKillFeature.SavedCFrame = nil
                                    MainModule.ZoneKillFeature.ActiveAnimation = false
                                    MainModule.ZoneKillFeature.TrackedAnimations = {}
                                end
                            end)
                            table.insert(MainModule.ZoneKillFeature.AnimationStoppedConnections, stoppedConn)
                        end
                    end
                end
            end
        end
    end
    
    local function setupCharacter(char)
        local humanoid = char:WaitForChild("Humanoid", 5)
        if not humanoid then return end
        
        MainModule.ZoneKillFeature.AnimationConnection = humanoid.AnimationPlayed:Connect(function(track)
            if not MainModule.ZoneKillFeature.Enabled then return end
            
            if track and track.Animation then
                local success, animId = pcall(function()
                    return track.Animation.AnimationId
                end)
                
                if success and animId and animId == MainModule.ZoneKillFeature.AnimationId then
                    MainModule.ZoneKillFeature.TrackedAnimations[track] = true
                    
                    if not MainModule.ZoneKillFeature.ActiveAnimation then
                        MainModule.ZoneKillFeature.ActiveAnimation = true
                        MainModule.ZoneKillFeature.AnimationStartTime = tick()
                        
                        local primaryPart = char.PrimaryPart or char:FindFirstChild("HumanoidRootPart")
                        if primaryPart then
                            MainModule.ZoneKillFeature.SavedCFrame = primaryPart.CFrame
                            char:SetPrimaryPartCFrame(CFrame.new(MainModule.ZoneKillFeature.ZonePosition))
                        end
                        
                        local stoppedConn = track.Stopped:Connect(function()
                            task.wait(MainModule.ZoneKillFeature.ReturnDelay)
                            
                            if MainModule.ZoneKillFeature.SavedCFrame then
                                char:SetPrimaryPartCFrame(MainModule.ZoneKillFeature.SavedCFrame)
                                MainModule.ZoneKillFeature.SavedCFrame = nil
                                MainModule.ZoneKillFeature.ActiveAnimation = false
                                MainModule.ZoneKillFeature.TrackedAnimations = {}
                            end
                        end)
                        table.insert(MainModule.ZoneKillFeature.AnimationStoppedConnections, stoppedConn)
                    end
                end
            end
        end)
    end
    
    local char = LocalPlayer.Character
    if char then
        setupCharacter(char)
    end
    
    MainModule.ZoneKillFeature.CharacterAddedConnection = LocalPlayer.CharacterAdded:Connect(function(newChar)
        task.wait(1)
        setupCharacter(newChar)
    end)
    
    MainModule.ZoneKillFeature.AnimationCheckConnection = RunService.Heartbeat:Connect(function()
        if not MainModule.ZoneKillFeature.Enabled then return end
        checkAnimations()
    end)
    
    MainModule.ShowNotification("Last Dinner", "Zone Kill Enabled", 2)
end

MainModule.SkySquidGame = {
    AntiFallEnabled = false,
    AntiFallPlatform = nil,
    Connection = nil
}

function MainModule.ToggleSkySquidGameAntiFall(enabled)
    if enabled and not IsGameActive("SkySquidGame") then
        MainModule.ShowNotification("Sky Squid Game AntiFall", "Game not active", 2)
        MainModule.SkySquidGame.AntiFallEnabled = false
        return
    end
    
    MainModule.SkySquidGame.AntiFallEnabled = enabled
    
    if MainModule.SkySquidGame.Connection then
        MainModule.SkySquidGame.Connection:Disconnect()
        MainModule.SkySquidGame.Connection = nil
    end
    
    if MainModule.SkySquidGame.AntiFallPlatform then
        MainModule.SkySquidGame.AntiFallPlatform:Destroy()
        MainModule.SkySquidGame.AntiFallPlatform = nil
    end
    
    if enabled then
        MainModule.SkySquidGame.Connection = RunService.Heartbeat:Connect(function()
            if not MainModule.SkySquidGame.AntiFallEnabled then 
                if MainModule.SkySquidGame.Connection then
                    MainModule.SkySquidGame.Connection:Disconnect()
                    MainModule.SkySquidGame.Connection = nil
                end
                return 
            end
            
            if not IsGameActive("SkySquidGame") then
                MainModule.SkySquidGame.AntiFallEnabled = false
                if MainModule.SkySquidGame.Connection then
                    MainModule.SkySquidGame.Connection:Disconnect()
                    MainModule.SkySquidGame.Connection = nil
                end
                MainModule.ShowNotification("Sky Squid Game AntiFall", "Game ended - disabled", 2)
                return
            end
            
            local character = GetCharacter()
            if not character or not character.PrimaryPart then return end
            
            if not MainModule.SkySquidGame.AntiFallPlatform then
                local platformPosition = character.PrimaryPart.Position + Vector3.new(0, -4, 0)
                
                MainModule.SkySquidGame.AntiFallPlatform = Instance.new("Part")
                MainModule.SkySquidGame.AntiFallPlatform.Name = "SkySquidGameAntiFallPlatform"
                MainModule.SkySquidGame.AntiFallPlatform.Size = Vector3.new(1000, 2, 1000)
                MainModule.SkySquidGame.AntiFallPlatform.Position = platformPosition
                MainModule.SkySquidGame.AntiFallPlatform.Anchored = true
                MainModule.SkySquidGame.AntiFallPlatform.CanCollide = true
                MainModule.SkySquidGame.AntiFallPlatform.Transparency = 1
                MainModule.SkySquidGame.AntiFallPlatform.Color = Color3.fromRGB(255, 255, 255)
                MainModule.SkySquidGame.AntiFallPlatform.Material = Enum.Material.Plastic
                MainModule.SkySquidGame.AntiFallPlatform.CanQuery = false
                MainModule.SkySquidGame.AntiFallPlatform.CastShadow = false
                
                MainModule.SkySquidGame.AntiFallPlatform.Parent = workspace
            else
                local platformPosition = character.PrimaryPart.Position + Vector3.new(0, -4, 0)
                MainModule.SkySquidGame.AntiFallPlatform.Position = platformPosition
            end
        end)
        MainModule.ShowNotification("Sky Squid Game AntiFall", "Enabled", 2)
    else
        MainModule.ShowNotification("Sky Squid Game AntiFall", "Disabled", 2)
    end
end

MainModule.VoidKillFeature = {
    Enabled = false,
    AnimationIds = {
        "rbxassetid://107989020363293",
        "rbxassetid://71619354165195"
    },
    ZonePosition = Vector3.new(-95.1, 964.6, 67.6),
    PlatformYOffset = -4,
    PlatformSize = Vector3.new(10, 1, 10),
    ReturnDelay = 1,
    SavedCFrame = nil,
    ActiveAnimation = false,
    AnimationStartTime = 0,
    AnimationConnection = nil,
    CharacterAddedConnection = nil,
    AnimationStoppedConnections = {},
    AnimationCheckConnection = nil,
    TrackedAnimations = {},
    AntiFallEnabled = false,
    AntiFallPlatform = nil,
    AnimationIdsSet = {}
}

for _, id in ipairs(MainModule.VoidKillFeature.AnimationIds) do
    MainModule.VoidKillFeature.AnimationIdsSet[id] = true
end

function MainModule.ToggleVoidKill(enabled)
    if enabled and not IsGameActive("SkySquidGame") then
        MainModule.ShowNotification("Void Kill", "Game not active", 2)
        MainModule.VoidKillFeature.Enabled = false
        return
    end
    
    MainModule.VoidKillFeature.Enabled = enabled
    
    if MainModule.VoidKillFeature.AnimationConnection then
        MainModule.VoidKillFeature.AnimationConnection:Disconnect()
        MainModule.VoidKillFeature.AnimationConnection = nil
    end
    if MainModule.VoidKillFeature.CharacterAddedConnection then
        MainModule.VoidKillFeature.CharacterAddedConnection:Disconnect()
        MainModule.VoidKillFeature.CharacterAddedConnection = nil
    end
    if MainModule.VoidKillFeature.AnimationCheckConnection then
        MainModule.VoidKillFeature.AnimationCheckConnection:Disconnect()
        MainModule.VoidKillFeature.AnimationCheckConnection = nil
    end
    
    for _, conn in ipairs(MainModule.VoidKillFeature.AnimationStoppedConnections) do
        pcall(function() conn:Disconnect() end)
    end
    MainModule.VoidKillFeature.AnimationStoppedConnections = {}
    
    MainModule.VoidKillFeature.SavedCFrame = nil
    MainModule.VoidKillFeature.ActiveAnimation = false
    MainModule.VoidKillFeature.AnimationStartTime = 0
    MainModule.VoidKillFeature.TrackedAnimations = {}
    
    if not enabled then
        if MainModule.VoidKillFeature.AntiFallPlatform then
            MainModule.VoidKillFeature.AntiFallPlatform:Destroy()
            MainModule.VoidKillFeature.AntiFallPlatform = nil
        end
        MainModule.VoidKillFeature.AntiFallEnabled = false
        MainModule.ShowNotification("Void Kill", "Disabled", 2)
        return
    end
    
    local function checkAnimations()
        if not MainModule.VoidKillFeature.Enabled then return end
        
        local character = GetCharacter()
        if not character then return end
        local humanoid = GetHumanoid(character)
        if not humanoid then return end
        
        local activeTracks = humanoid:GetPlayingAnimationTracks()
        for _, track in pairs(activeTracks) do
            if track and track.Animation then
                local animId = track.Animation.AnimationId
                
                if MainModule.VoidKillFeature.AnimationIdsSet[animId] then
                    local trackKey = animId .. "_" .. tostring(track)
                    if not MainModule.VoidKillFeature.TrackedAnimations[trackKey] then
                        MainModule.VoidKillFeature.TrackedAnimations[trackKey] = true
                        
                        if not MainModule.VoidKillFeature.ActiveAnimation then
                            MainModule.VoidKillFeature.ActiveAnimation = true
                            MainModule.VoidKillFeature.AnimationStartTime = tick()
                            
                            MainModule.VoidKillFeature.SavedCFrame = character:GetPrimaryPartCFrame()
                            
                            local platformPosition = MainModule.VoidKillFeature.ZonePosition + 
                                                    Vector3.new(0, MainModule.VoidKillFeature.PlatformYOffset, 0)
                            
                            MainModule.VoidKillFeature.AntiFallPlatform = Instance.new("Part")
                            MainModule.VoidKillFeature.AntiFallPlatform.Name = "VoidKillAntiFall"
                            MainModule.VoidKillFeature.AntiFallPlatform.Size = MainModule.VoidKillFeature.PlatformSize
                            MainModule.VoidKillFeature.AntiFallPlatform.Anchored = true
                            MainModule.VoidKillFeature.AntiFallPlatform.CanCollide = true
                            MainModule.VoidKillFeature.AntiFallPlatform.Transparency = 1
                            MainModule.VoidKillFeature.AntiFallPlatform.Material = Enum.Material.Plastic
                            MainModule.VoidKillFeature.AntiFallPlatform.CastShadow = false
                            MainModule.VoidKillFeature.AntiFallPlatform.CanQuery = false
                            MainModule.VoidKillFeature.AntiFallPlatform.Position = platformPosition
                            MainModule.VoidKillFeature.AntiFallPlatform.Parent = workspace
                            
                            character:SetPrimaryPartCFrame(CFrame.new(MainModule.VoidKillFeature.ZonePosition))
                            
                            local stoppedConn = track.Stopped:Connect(function()
                                task.wait(MainModule.VoidKillFeature.ReturnDelay)
                                
                                if MainModule.VoidKillFeature.SavedCFrame then
                                    character:SetPrimaryPartCFrame(MainModule.VoidKillFeature.SavedCFrame)
                                    MainModule.VoidKillFeature.SavedCFrame = nil
                                end
                                
                                MainModule.VoidKillFeature.ActiveAnimation = false
                                MainModule.VoidKillFeature.TrackedAnimations = {}
                                
                                if MainModule.VoidKillFeature.AntiFallPlatform then
                                    MainModule.VoidKillFeature.AntiFallPlatform:Destroy()
                                    MainModule.VoidKillFeature.AntiFallPlatform = nil
                                end
                            end)
                            
                            table.insert(MainModule.VoidKillFeature.AnimationStoppedConnections, stoppedConn)
                        end
                    end
                end
            end
        end
    end
    
    local function setupCharacter(char)
        local humanoid = char:WaitForChild("Humanoid", 5)
        if not humanoid then return end
        
        MainModule.VoidKillFeature.AnimationConnection = humanoid.AnimationPlayed:Connect(function(track)
            if not MainModule.VoidKillFeature.Enabled then return end
            
            if track and track.Animation then
                local animId = track.Animation.AnimationId
                
                if MainModule.VoidKillFeature.AnimationIdsSet[animId] then
                    local trackKey = animId .. "_" .. tostring(track)
                    MainModule.VoidKillFeature.TrackedAnimations[trackKey] = true
                    
                    if not MainModule.VoidKillFeature.ActiveAnimation then
                        MainModule.VoidKillFeature.ActiveAnimation = true
                        MainModule.VoidKillFeature.AnimationStartTime = tick()
                        
                        MainModule.VoidKillFeature.SavedCFrame = char:GetPrimaryPartCFrame()
                        
                        local platformPosition = MainModule.VoidKillFeature.ZonePosition + 
                                                Vector3.new(0, MainModule.VoidKillFeature.PlatformYOffset, 0)
                        
                        MainModule.VoidKillFeature.AntiFallPlatform = Instance.new("Part")
                        MainModule.VoidKillFeature.AntiFallPlatform.Name = "VoidKillAntiFall"
                        MainModule.VoidKillFeature.AntiFallPlatform.Size = MainModule.VoidKillFeature.PlatformSize
                        MainModule.VoidKillFeature.AntiFallPlatform.Anchored = true
                        MainModule.VoidKillFeature.AntiFallPlatform.CanCollide = true
                        MainModule.VoidKillFeature.AntiFallPlatform.Transparency = 1
                        MainModule.VoidKillFeature.AntiFallPlatform.Material = Enum.Material.Plastic
                        MainModule.VoidKillFeature.AntiFallPlatform.CastShadow = false
                        MainModule.VoidKillFeature.AntiFallPlatform.CanQuery = false
                        MainModule.VoidKillFeature.AntiFallPlatform.Position = platformPosition
                        MainModule.VoidKillFeature.AntiFallPlatform.Parent = workspace
                        
                        char:SetPrimaryPartCFrame(CFrame.new(MainModule.VoidKillFeature.ZonePosition))
                        
                        local stoppedConn = track.Stopped:Connect(function()
                            task.wait(MainModule.VoidKillFeature.ReturnDelay)
                            
                            if MainModule.VoidKillFeature.SavedCFrame then
                                char:SetPrimaryPartCFrame(MainModule.VoidKillFeature.SavedCFrame)
                                MainModule.VoidKillFeature.SavedCFrame = nil
                            end
                            
                            MainModule.VoidKillFeature.ActiveAnimation = false
                            MainModule.VoidKillFeature.TrackedAnimations = {}
                            
                            if MainModule.VoidKillFeature.AntiFallPlatform then
                                MainModule.VoidKillFeature.AntiFallPlatform:Destroy()
                                MainModule.VoidKillFeature.AntiFallPlatform = nil
                            end
                        end)
                        
                        table.insert(MainModule.VoidKillFeature.AnimationStoppedConnections, stoppedConn)
                    end
                end
            end
        end)
    end
    
    local char = LocalPlayer.Character
    if char then
        task.spawn(setupCharacter, char)
    end
    
    MainModule.VoidKillFeature.CharacterAddedConnection = LocalPlayer.CharacterAdded:Connect(function(newChar)
        task.wait(1)
        if MainModule.VoidKillFeature.Enabled then
            task.spawn(setupCharacter, newChar)
        end
    end)
    
    MainModule.VoidKillFeature.AnimationCheckConnection = RunService.Heartbeat:Connect(function()
        if not MainModule.VoidKillFeature.Enabled then return end
        
        if not IsGameActive("SkySquidGame") then
            MainModule.VoidKillFeature.Enabled = false
            MainModule.ShowNotification("Void Kill", "Game ended - disabled", 2)
            return
        end
        
        checkAnimations()
    end)
    
    MainModule.ShowNotification("Void Kill", "Enabled", 2)
end

return MainModule
