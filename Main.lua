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
        gui.ResetOnSpawn = false
        gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
        gui.DisplayOrder = 1000
        gui.Parent = game:GetService("CoreGui")

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 300, 0, 0)
        frame.Position = UDim2.new(1, -320, 0, 50)
        frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
        frame.BorderSizePixel = 0
        frame.ClipsDescendants = true
        frame.ZIndex = 1001
        frame.Parent = gui

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = frame

        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(60, 60, 60)
        stroke.Thickness = 2
        stroke.ZIndex = 1001
        stroke.Parent = frame

        local titleLabel = Instance.new("TextLabel")
        titleLabel.Size = UDim2.new(1, -20, 0, 30)
        titleLabel.Position = UDim2.new(0, 10, 0, 10)
        titleLabel.BackgroundTransparency = 1
        titleLabel.Text = title
        titleLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
        titleLabel.TextSize = 16
        titleLabel.Font = Enum.Font.GothamBold
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.ZIndex = 1002
        titleLabel.Parent = frame

        local textLabel = Instance.new("TextLabel")
        textLabel.Size = UDim2.new(1, -20, 1, -45)
        textLabel.Position = UDim2.new(0, 10, 0, 45)
        textLabel.BackgroundTransparency = 1
        textLabel.Text = text
        textLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
        textLabel.TextSize = 12
        textLabel.Font = Enum.Font.Gotham
        textLabel.TextXAlignment = Enum.TextXAlignment.Left
        textLabel.TextYAlignment = Enum.TextYAlignment.Top
        textLabel.TextWrapped = true
        textLabel.ZIndex = 1002
        textLabel.Parent = frame

        textLabel:GetPropertyChangedSignal("TextBounds"):Connect(function()
            local textHeight = textLabel.TextBounds.Y + 55
            frame.Size = UDim2.new(0, 300, 0, math.min(textHeight, 150))
            TweenService:Create(frame, TweenInfo.new(0.3), {
                Position = UDim2.new(1, -320, 0, 50)
            }):Play()
        end)

        local textHeight = textLabel.TextBounds.Y + 55
        frame.Size = UDim2.new(0, 300, 0, math.min(textHeight, 150))
        TweenService:Create(frame, TweenInfo.new(0.3), {
            Position = UDim2.new(1, -320, 0, 50)
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

function MainModule.RLGL_TP_ToStart()
    task.spawn(function()
        local character = GetCharacter()
        if character and character:FindFirstChild("HumanoidRootPart") then
            character.HumanoidRootPart.CFrame = CFrame.new(-55.3, 1023.1, -545.8)
            MainModule.ShowNotification("RLGL", "Teleported to Start", 2)
        end
    end)
end

function MainModule.RLGL_TP_ToEnd()
    task.spawn(function()
        local character = GetCharacter()
        if character and character:FindFirstChild("HumanoidRootPart") then
            character.HumanoidRootPart.CFrame = CFrame.new(-214.4, 1023.1, 146.7)
            MainModule.ShowNotification("RLGL", "Teleported to End", 2)
        end
    end)
end

function MainModule.Dalgona_Complete()
    task.spawn(function()
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
        LocalPlayer:SetAttribute("HasLighter", true)
        MainModule.ShowNotification("Dalgona", "Lighter Unlocked", 2)
    end)
end

MainModule.HNS = {
    InfinityStaminaEnabled = false,
    InfinityStaminaConnection = nil
}

function MainModule.ToggleHNSInfinityStamina(enabled)
    MainModule.HNS.InfinityStaminaEnabled = enabled
    
    if MainModule.HNS.InfinityStaminaConnection then
        MainModule.HNS.InfinityStaminaConnection:Disconnect()
        MainModule.HNS.InfinityStaminaConnection = nil
    end
    
    if enabled then
        MainModule.HNS.InfinityStaminaConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.HNS.InfinityStaminaEnabled then return end
            
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

function MainModule.CheckKnifeInInventory()
    local character = GetCharacter()
    if not character then return false end
    
    for _, tool in pairs(character:GetChildren()) do
        if tool:IsA("Tool") then
            local toolName = tool.Name:lower()
            if toolName:find("knife") or toolName:find("fork") or toolName:find("dagger") or toolName:find("нож") then
                return true, tool
            end
        end
    end
    
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        for _, tool in pairs(backpack:GetChildren()) do
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
    KnifeCheckConnection = nil,
    LastKnifeCheckTime = 0,
    KnifeCheckCooldown = 0.5,
    HasKnife = false,
    NoKnifeTimer = 0,
    NoKnifeTimeout = 2
}

function MainModule.ToggleSpikesKill(enabled)
    MainModule.SpikesKillFeature.Enabled = enabled
    
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
    if MainModule.SpikesKillFeature.KnifeCheckConnection then
        MainModule.SpikesKillFeature.KnifeCheckConnection:Disconnect()
        MainModule.SpikesKillFeature.KnifeCheckConnection = nil
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
        MainModule.SpikesKillFeature.HasKnife = false
        MainModule.ShowNotification("Spikes Kill", "Disabled", 2)
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
        if not MainModule.SpikesKillFeature.ActiveAnimation then return end
        if tick() - MainModule.SpikesKillFeature.AnimationStartTime >= 10 then
            local character = GetCharacter()
            if character and MainModule.SpikesKillFeature.OriginalCFrame then
                returnToOriginalPosition(character)
            end
            MainModule.SpikesKillFeature.ActiveAnimation = false
            MainModule.SpikesKillFeature.TrackedAnimations = {}
        end
    end)
    
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
                        pcall(function()
                            btn:Fire("MouseButton1Click")
                        end)
                        
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
            pcall(function()
                if not stone.Anchored then
                    stone.Anchored = true
                end
                
                if stone.CanCollide then
                    stone.CanCollide = false
                end
            end)
        end
    end
    
    MainModule.AutoGonggi.ProcessingStones = false
end

function MainModule.ToggleAutoGonggi(enabled)
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
                processGonggiQTE()
                task.wait(MainModule.AutoGonggi.CheckInterval)
            end
        end)
        
        MainModule.AutoGonggi.StoneThread = task.spawn(function()
            while MainModule.AutoGonggi.Enabled do
                processGonggiStones()
                task.wait(MainModule.AutoGonggi.StoneCheckInterval)
            end
        end)
        
        MainModule.ShowNotification("Auto Gonggi", "Enabled", 2)
    else
        MainModule.ShowNotification("Auto Gonggi", "Disabled", 2)
    end
    
    return MainModule.AutoGonggi.Enabled
end

MainModule.AutoDodge = {
    Enabled = false,
    AnimationIds = {
        "rbxassetid://88451099342711",
        "rbxassetid://79649041083405", 
        "rbxassetid://73242877658272",
        "rbxassetid://114928327045353"
    },
    Connections = {},
    LastDodgeTime = 0,
    DodgeCooldown = 1.24,
    Range = 5,
    RangeSquared = 5 * 5,
    AnimationIdsSet = {},
    
    CapturedCall = nil,
    LastCapturedCallTime = 0,
    OriginalFireServer = nil,
    Remote = nil,
    
    TrackedPlayers = {}
}

for _, id in ipairs(MainModule.AutoDodge.AnimationIds) do
    MainModule.AutoDodge.AnimationIdsSet[id] = true
end

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
    
    return true
end

local function executeDodge()
    if not MainModule.AutoDodge.Enabled then 
        return false 
    end
    
    local currentTime = tick()
    local autoDodge = MainModule.AutoDodge
    
    if currentTime - autoDodge.LastDodgeTime < autoDodge.DodgeCooldown then
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
    
    autoDodge.LastDodgeTime = currentTime
    
    pcall(function()
        local remote = MainModule.AutoDodge.Remote
        if remote then
            remote:FireServer(dodgeTool)
        end
    end)
    
    return true
end

local function isLookingAtPlayer(targetPlayer, localPlayer)
    if not targetPlayer or not targetPlayer.Character then return false end
    if not localPlayer or not localPlayer.Character then return false end
    
    local targetHead = targetPlayer.Character:FindFirstChild("Head")
    local localRoot = localPlayer.Character:FindFirstChild("HumanoidRootPart")
    
    if not (targetHead and localRoot) then return false end
    
    local directionToLocal = (localRoot.Position - targetHead.Position).Unit
    local lookVector = targetHead.CFrame.LookVector
    
    local dot = directionToLocal:Dot(lookVector)
    
    return dot > -0.7
end

local function createInstantAnimationHandler(player)
    local LocalPlayer = game:GetService("Players").LocalPlayer
    
    return function(track)
        if not MainModule.AutoDodge.Enabled then return end
        if player == LocalPlayer then return end
        
        local animId
        if track and track.Animation then
            animId = track.Animation.AnimationId
        end
        
        if not animId then return end
        if not MainModule.AutoDodge.AnimationIdsSet[animId] then
            return
        end
        
        local currentTime = tick()
        if currentTime - MainModule.AutoDodge.LastDodgeTime < MainModule.AutoDodge.DodgeCooldown then
            return
        end
        
        if not LocalPlayer or not LocalPlayer.Character then return end
        if not player or not player.Character then return end
        
        if not isLookingAtPlayer(player, LocalPlayer) then
            return
        end
        
        local localRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
        
        if not (localRoot and targetRoot) then return end
        
        local diff = targetRoot.Position - localRoot.Position
        local distanceSquared = diff.X * diff.X + diff.Y * diff.Y + diff.Z * diff.Z
        
        if distanceSquared > MainModule.AutoDodge.RangeSquared then
            return
        end
        
        executeDodge()
    end
end

local function setupInstantPlayerTracking(player)
    local LocalPlayer = game:GetService("Players").LocalPlayer
    if player == LocalPlayer then return end
    
    local function setupCharacter(character)
        if not character or not MainModule.AutoDodge.Enabled then return end
        
        local humanoid = character:FindFirstChild("Humanoid")
        if not humanoid then
            return
        end
        
        local handler = createInstantAnimationHandler(player)
        local conn = humanoid.AnimationPlayed:Connect(handler)
        
        if not MainModule.AutoDodge.TrackedPlayers[player.Name] then
            MainModule.AutoDodge.TrackedPlayers[player.Name] = {}
        end
        table.insert(MainModule.AutoDodge.TrackedPlayers[player.Name], conn)
        table.insert(MainModule.AutoDodge.Connections, conn)
    end
    
    if player.Character then
        setupCharacter(player.Character)
    end
    
    local charConn = player.CharacterAdded:Connect(function(character)
        if not MainModule.AutoDodge.Enabled then return end
        
        if MainModule.AutoDodge.TrackedPlayers[player.Name] then
            for _, conn in pairs(MainModule.AutoDodge.TrackedPlayers[player.Name]) do
                pcall(function() conn:Disconnect() end)
            end
            MainModule.AutoDodge.TrackedPlayers[player.Name] = {}
        end
        
        setupCharacter(character)
    end)
    
    table.insert(MainModule.AutoDodge.Connections, charConn)
end

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
        
        for _, player in pairs(Players:GetPlayers()) do
            if player == LocalPlayer then continue end
            if not player.Character then continue end
            
            if not isLookingAtPlayer(player, LocalPlayer) then
                continue
            end
            
            local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
            if not targetRoot then continue end
            
            local diff = targetRoot.Position - localRoot.Position
            local distanceSquared = diff.X * diff.X + diff.Y * diff.Y + diff.Z * diff.Z
            
            if distanceSquared > MainModule.AutoDodge.RangeSquared then
                continue
            end
            
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if not humanoid then continue end
            
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
    
    local renderConn = RunService.RenderStepped:Connect(instantCheck)
    table.insert(MainModule.AutoDodge.Connections, renderConn)
end

function MainModule.ToggleAutoDodge(enabled)
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
        setupRemoteHook()
        
        MainModule.ShowNotification("Auto Dodge", "Enabled", 2)
    else
        MainModule.ShowNotification("Auto Dodge", "Disabled", 2)
    end
end

function MainModule.TeleportToHider()
    task.spawn(function()
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
    AutoPull = false,
    Connection = nil
}

function MainModule.AntiMiss(enabled)
    MainModule.TugOfWar.AutoPull = enabled
    
    if MainModule.TugOfWar.Connection then
        MainModule.TugOfWar.Connection:Disconnect()
        MainModule.TugOfWar.Connection = nil
    end

    if enabled then
        MainModule.TugOfWar.Connection = RunService.Heartbeat:Connect(function()
            if not MainModule.TugOfWar.AutoPull then return end
            
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
    end
end

MainModule.GlassBridge = {
    AntiBreakEnabled = false,
    AntiBreakConnection = nil,
    GlassESPEnabled = false,
    GlassESPConnections = {},
    GlassESPConnection2 = nil
}

function MainModule.GlassBridgeAntiBreak(state)
    MainModule.GlassBridge.AntiBreakEnabled = state
    if not state then
        if MainModule.GlassBridge.AntiBreakConnection then
            MainModule.GlassBridge.AntiBreakConnection:Disconnect()
            MainModule.GlassBridge.AntiBreakConnection = nil
        end
        return
    end
    
    local function createSafetyPlatforms()
        local GlassHolder = workspace:FindFirstChild("GlassBridge") and workspace.GlassBridge:FindFirstChild("GlassHolder")
        if not GlassHolder then return end
        
        for _, lane in pairs(GlassHolder:GetChildren()) do
            for _, glassModel in pairs(lane:GetChildren()) do
                if glassModel:IsA("Model") and glassModel.PrimaryPart then
                    if not glassModel:FindFirstChild("SafetyPlatform") then
                        local part = glassModel.PrimaryPart
                        local platformPosition = Vector3.new(
                            part.Position.X,
                            part.Position.Y - 6,
                            part.Position.Z
                        )
                        
                        local platform = Instance.new("Part")
                        platform.Name = "SafetyPlatform"
                        platform.Size = Vector3.new(10, 1, 10)
                        platform.Position = platformPosition
                        platform.Anchored = true
                        platform.CanCollide = true
                        platform.Transparency = 0.5
                        platform.Color = Color3.fromRGB(255, 255, 255)
                        platform.Material = Enum.Material.SmoothPlastic
                        platform.Parent = glassModel
                    end
                end
            end
        end
    end
    
    MainModule.GlassBridge.AntiBreakConnection = RunService.Heartbeat:Connect(function()
        local GlassHolder = workspace:FindFirstChild("GlassBridge") and workspace.GlassBridge:FindFirstChild("GlassHolder")
        if not GlassHolder then return end
        
        createSafetyPlatforms()
        
        for _, v in pairs(GlassHolder:GetChildren()) do
            for _, j in pairs(v:GetChildren()) do
                if j:IsA("Model") and j.PrimaryPart then
                    if j.PrimaryPart:GetAttribute("exploitingisevil") ~= nil then
                        j.PrimaryPart:SetAttribute("exploitingisevil", nil)
                    end
                end
            end
        end
    end)
end

local function updateGlassESP()
    if not workspace:FindFirstChild("GlassBridge") then return end
    
    local GlassHolder = workspace.GlassBridge:FindFirstChild("GlassHolder")
    if not GlassHolder then return end
    
    for _, lane in pairs(GlassHolder:GetChildren()) do
        for _, glassModel in pairs(lane:GetChildren()) do
            if glassModel:IsA("Model") and glassModel.PrimaryPart then
                if not glassModel:FindFirstChild("GlassESP") then
                    local part = glassModel.PrimaryPart
                    
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "GlassESP"
                    highlight.Adornee = part
                    highlight.FillColor = Color3.fromRGB(0, 150, 255)
                    highlight.FillTransparency = 0.7
                    highlight.OutlineColor = Color3.fromRGB(0, 100, 200)
                    highlight.OutlineTransparency = 0
                    highlight.Parent = glassModel
                    
                    local billboard = Instance.new("BillboardGui")
                    billboard.Name = "GlassESPBillboard"
                    billboard.Size = UDim2.new(0, 100, 0, 40)
                    billboard.StudsOffset = Vector3.new(0, 3, 0)
                    billboard.AlwaysOnTop = true
                    billboard.Adornee = part
                    billboard.Parent = glassModel
                    
                    local textLabel = Instance.new("TextLabel")
                    textLabel.Size = UDim2.new(1, 0, 1, 0)
                    textLabel.BackgroundTransparency = 1
                    textLabel.Text = "🪟 Glass"
                    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                    textLabel.TextStrokeTransparency = 0
                    textLabel.Font = Enum.Font.SourceSansBold
                    textLabel.TextScaled = true
                    textLabel.Parent = billboard
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
                        local esp = glassModel:FindFirstChild("GlassESP")
                        if esp then esp:Destroy() end
                        
                        local billboard = glassModel:FindFirstChild("GlassESPBillboard")
                        if billboard then billboard:Destroy() end
                    end
                end
            end
        end
    end
end

function MainModule.EnableGlassESP(state)
    MainModule.GlassBridge.GlassESPEnabled = state
    
    if state then
        updateGlassESP()
        
        MainModule.GlassBridge.GlassESPConnections["workspace"] = workspace.ChildAdded:Connect(function(child)
            if child.Name == "GlassBridge" then
                task.wait(1)
                updateGlassESP()
            end
        end)
        
        MainModule.GlassBridge.GlassESPConnection2 = RunService.Heartbeat:Connect(function()
            if MainModule.GlassBridge.GlassESPEnabled then
                updateGlassESP()
            end
        end)
    else
        clearGlassESP()
        
        for name, conn in pairs(MainModule.GlassBridge.GlassESPConnections) do
            if conn then
                conn:Disconnect()
            end
        end
        MainModule.GlassBridge.GlassESPConnections = {}
        
        if MainModule.GlassBridge.GlassESPConnection2 then
            MainModule.GlassBridge.GlassESPConnection2:Disconnect()
            MainModule.GlassBridge.GlassESPConnection2 = nil
        end
    end
end

function MainModule.GlassBridgeTeleportToEnd()
    task.spawn(function()
        local character = GetCharacter()
        if character and character:FindFirstChild("HumanoidRootPart") then
            character.HumanoidRootPart.CFrame = CFrame.new(-196.372467, 522.192139, -1534.20984)
            MainModule.ShowNotification("Glass Bridge", "Teleported to End", 2)
        end
    end)
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
                })
                
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
    end
end

local function isGameActive(gameName)
    local values = workspace:FindFirstChild("Values")
    if not values then return false end
    
    local currentGame = values:FindFirstChild("CurrentGame")
    if not currentGame then return false end
    
    return currentGame.Value == gameName
end

function MainModule.checkGameActive(gameName, funcName)
    if not isGameActive(gameName) then
        MainModule.ShowNotification(funcName, gameName .. " is not active", 3)
        return false
    end
    return true
end

return MainModule
