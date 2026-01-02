local MainModule = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local CollectionService = game:GetService("CollectionService")

local LocalPlayer = Players.LocalPlayer
local Character

if LocalPlayer.Character then
    Character = LocalPlayer.Character
end

LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
end)

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

local function SafeTeleport(position)
    local character = GetCharacter()
    if not character then return false end
    local rootPart = GetRootPart(character)
    if not rootPart then return false end
    local currentPosition = rootPart.Position
    local currentCFrame = rootPart.CFrame
    local tempPart = Instance.new("Part")
    tempPart.Size = Vector3.new(1, 1, 1)
    tempPart.Transparency = 1
    tempPart.Anchored = true
    tempPart.CanCollide = false
    tempPart.Position = currentPosition
    tempPart.Parent = workspace
    Debris:AddItem(tempPart, 0.1)
    local fakeVelocity = Instance.new("BodyVelocity")
    fakeVelocity.Velocity = (position - currentPosition).Unit * 100
    fakeVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
    fakeVelocity.Parent = rootPart
    Debris:AddItem(fakeVelocity, 0.1)
    rootPart.CFrame = CFrame.new(position)
    task.delay(0.05, function()
        if fakeVelocity and fakeVelocity.Parent then
            fakeVelocity:Destroy()
        end
    end)
    return true
end

local function GetSafePositionAbove(currentPosition, height)
    local rayOrigin = currentPosition + Vector3.new(0, 5, 0)
    local rayDirection = Vector3.new(0, -1, 0)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
    local result = workspace:Raycast(rayOrigin, rayDirection * 100, raycastParams)
    if result and result.Position then
        return result.Position + Vector3.new(0, height, 0)
    else
        return currentPosition + Vector3.new(0, height, 0)
    end
end

local function GetPlayerGun()
    local character = GetCharacter()
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if character then
        for _, tool in pairs(character:GetChildren()) do
            if tool:IsA("Tool") and tool:GetAttribute("Gun") then
                return tool
            end
        end
    end
    if backpack then
        for _, tool in pairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and tool:GetAttribute("Gun") then
                return tool
            end
        end
    end
    return nil
end

local function GetEnemies()
    local enemies = {}
    local liveFolder = Workspace:FindFirstChild("Live")
    if not liveFolder then return enemies end
    for _, model in pairs(liveFolder:GetChildren()) do
        if model:IsA("Model") then
            local enemyTag = model:FindFirstChild("Enemy")
            local deadTag = model:FindFirstChild("Dead")
            if enemyTag and not deadTag then
                local isPlayer = false
                for _, player in pairs(Players:GetPlayers()) do
                    if player.Name == model.Name then
                        isPlayer = true
                        break
                    end
                end
                if not isPlayer then
                    table.insert(enemies, model.Name)
                    if #enemies >= 5 then
                        break
                    end
                end
            end
        end
    end
    return enemies
end

local function KillEnemy(enemyName)
    pcall(function()
        local liveFolder = Workspace:FindFirstChild("Live")
        if not liveFolder then return end
        local enemy = liveFolder:FindFirstChild(enemyName)
        if not enemy then return end
        local enemyTag = enemy:FindFirstChild("Enemy")
        local deadTag = enemy:FindFirstChild("Dead")
        if not enemyTag or deadTag then return end
        local gun = GetPlayerGun()
        if not gun then return end
        local args = {
            gun,
            {
                ["ClientRayNormal"] = Vector3.new(-1.1920928955078125e-7, 1.0000001192092896, 0),
                ["FiredGun"] = true,
                ["SecondaryHitTargets"] = {},
                ["ClientRayInstance"] = Workspace:WaitForChild("StairWalkWay"):WaitForChild("Part"),
                ["ClientRayPosition"] = Vector3.new(-220.17489624023438, 183.2957763671875, 301.07257080078125),
                ["bulletCF"] = CFrame.new(-220.5039825439453, 185.22506713867188, 302.133544921875, 0.9551116228103638, 0.2567310333251953, -0.14782091975212097, 7.450581485102248e-9, 0.4989798665046692, 0.8666135668754578, 0.2962462604045868, -0.8277127146720886, 0.4765814542770386),
                ["HitTargets"] = {
                    [enemyName] = "Head"
                },
                ["bulletSizeC"] = Vector3.new(0.009999999776482582, 0.009999999776482582, 4.452499866485596),
                ["NoMuzzleFX"] = false,
                ["FirePosition"] = Vector3.new(-72.88850402832031, -679.4803466796875, -173.31005859375)
            }
        }
        local remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("FiredGunClient")
        remote:FireServer(unpack(args))
    end)
end

function MainModule.RLGL_TP_ToStart()
    if Character and Character:FindFirstChild("HumanoidRootPart") then
        Character.HumanoidRootPart.CFrame = CFrame.new(-55.3, 1023.1, -545.8)
    end
end

function MainModule.RLGL_TP_ToEnd()
    if Character and Character:FindFirstChild("HumanoidRootPart") then
        Character.HumanoidRootPart.CFrame = CFrame.new(-214.4, 1023.1, 146.7)
    end
end

function MainModule.Dalgona_Complete()
    task.spawn(function()
        for _, func in pairs(debug.getregistry()) do
            if typeof(func) == "function" then
                local info = debug.getinfo(func)
                if info.nups == 76 then
                    debug.setupvalue(func, 33, 9999)
                    debug.setupvalue(func, 34, 9999)
                    break
                end
            end
        end
    end)
end

function MainModule.Dalgona_FreeLighter()
    LocalPlayer:SetAttribute("HasLighter", true)
end

local function sendGameAction(guid, action, data)
    local remote = ReplicatedStorage:FindFirstChild("Remote")
    if not remote then
        remote = ReplicatedStorage:FindFirstChild("Remotes"):FindFirstChild("Pentathlon")
    end
    if not remote then
        remote = ReplicatedStorage:FindFirstChild("PentathlonRemote")
    end
    if not remote then
        remote = ReplicatedStorage:FindFirstChild("Events"):FindFirstChild("Pentathlon")
    end
    if remote and remote:IsA("RemoteEvent") then
        remote:FireServer(guid, action, data)
        return true
    end
    return false
end

local function getActiveGameId(minigameName)
    local success, pentathlonModule = pcall(function()
        local modules = ReplicatedStorage:FindFirstChild("Modules")
        if modules then
            local pentathlon = modules:FindFirstChild("Pentathlon")
            if pentathlon then
                return require(pentathlon)
            end
        end
        return nil
    end)
    
    if success and pentathlonModule and pentathlonModule._activeGames then
        for guid, game in pairs(pentathlonModule._activeGames) do
            if game._minigame == minigameName then
                return guid
            end
        end
    end
    
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if playerGui then
        local ui = playerGui:FindFirstChild(minigameName)
        if not ui and playerGui:FindFirstChild("OtherUIHolder") then
            ui = playerGui.OtherUIHolder:FindFirstChild(minigameName)
        end
        if ui and ui.Visible then
            return minigameName .. "_" .. math.floor(tick())
        end
    end
    
    return nil
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
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
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
    local stones = CollectionService:GetTagged("GonggiStone")
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
            local stones = CollectionService:GetTagged("GonggiStone")
            for _, stone in ipairs(stones) do
                if stone:IsA("BasePart") and stone:FindFirstChild("AutoHighlight") then
                    stone.AutoHighlight:Destroy()
                end
            end
        end)
    end
    return MainModule.AutoGonggi.Enabled
end

function MainModule.ForceStopAutoGonggi()
    MainModule.ToggleAutoGonggi(false)
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
    if enabled then
        local hasKnife = MainModule.CheckKnifeInInventory()
        if not hasKnife then
            MainModule.SpikesKillFeature.Enabled = false
            return
        end
        MainModule.SpikesKillFeature.HasKnife = true
    end
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
        return
    end
    MainModule.DisableSpikes(true)
    local function teleportToSpikes(character)
        if not character or not character:FindFirstChild("HumanoidRootPart") then
            return
        end
        local spikesPosition = MainModule.SpikesKillFeature.SpikesPosition
        if not spikesPosition then
            local hideAndSeekMap = workspace:FindFirstChild("HideAndSeekMap")
            local killingParts = hideAndSeekMap and hideAndSeekMap:FindFirstChild("KillingParts")
            if killingParts and killingParts:FindFirstChildWhichIsA("BasePart") then
                local firstSpike = killingParts:FindFirstChildWhichIsA("BasePart")
                if firstSpike then
                    spikesPosition = firstSpike.Position
                    MainModule.SpikesKillFeature.SpikesPosition = spikesPosition
                end
            end
        end
        MainModule.SpikesKillFeature.OriginalCFrame = character:GetPrimaryPartCFrame()
        if spikesPosition then
            local targetPosition = spikesPosition + Vector3.new(0, MainModule.SpikesKillFeature.PlatformHeightOffset, 0)
            character:SetPrimaryPartCFrame(CFrame.new(targetPosition))
        else
            local currentPos = character:GetPrimaryPartCFrame().Position
            local targetPosition = currentPos + Vector3.new(0, MainModule.SpikesKillFeature.PlatformHeightOffset, 0)
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
    local function checkAnimations()
        if not MainModule.SpikesKillFeature.Enabled then return end
        local character = GetCharacter()
        if not character then return end
        local humanoid = GetHumanoid(character)
        if not humanoid then return end
        local activeTracks = humanoid:GetPlayingAnimationTracks()
        for _, track in pairs(activeTracks) do
            if track.Animation and track.Animation.AnimationId == MainModule.SpikesKillFeature.AnimationId then
                if not MainModule.SpikesKillFeature.TrackedAnimations[track] then
                    MainModule.SpikesKillFeature.TrackedAnimations[track] = true
                    if not MainModule.SpikesKillFeature.ActiveAnimation then
                        MainModule.SpikesKillFeature.ActiveAnimation = true
                        MainModule.SpikesKillFeature.AnimationStartTime = tick()
                        teleportToSpikes(character)
                        local stoppedConn = track.Stopped:Connect(function()
                            task.wait(MainModule.SpikesKillFeature.ReturnDelay)
                            if MainModule.SpikesKillFeature.ActiveAnimation and MainModule.SpikesKillFeature.OriginalCFrame then
                                returnToOriginalPosition(character)
                                MainModule.SpikesKillFeature.ActiveAnimation = false
                                MainModule.SpikesKillFeature.TrackedAnimations = {}
                            end
                        end)
                        table.insert(MainModule.SpikesKillFeature.AnimationStoppedConnections, stoppedConn)
                    end
                end
            end
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
    MainModule.SpikesKillFeature.AnimationCheckConnection = RunService.Heartbeat:Connect(function()
        if not MainModule.SpikesKillFeature.Enabled then return end
        checkAnimations()
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
    MainModule.SpikesKillFeature.KnifeCheckConnection = RunService.Heartbeat:Connect(function()
        if not MainModule.SpikesKillFeature.Enabled then return end
        local currentTime = tick()
        if currentTime - MainModule.SpikesKillFeature.LastKnifeCheckTime < MainModule.SpikesKillFeature.KnifeCheckCooldown then
            return
        end
        MainModule.SpikesKillFeature.LastKnifeCheckTime = currentTime
        local hasKnife = MainModule.CheckKnifeInInventory()
        if hasKnife then
            MainModule.SpikesKillFeature.HasKnife = true
            MainModule.SpikesKillFeature.NoKnifeTimer = 0
        else
            MainModule.SpikesKillFeature.NoKnifeTimer = MainModule.SpikesKillFeature.NoKnifeTimer + MainModule.SpikesKillFeature.KnifeCheckCooldown
            if MainModule.SpikesKillFeature.NoKnifeTimer >= MainModule.SpikesKillFeature.NoKnifeTimeout then
                MainModule.ToggleSpikesKill(false)
            end
        end
    end)
end

function MainModule.DisableSpikes(remove)
    pcall(function()
        local hideAndSeekMap = workspace:FindFirstChild("HideAndSeekMap")
        local killingParts = hideAndSeekMap and hideAndSeekMap:FindFirstChild("KillingParts")
        if not killingParts then
            return false
        end
        if remove then
            MainModule.SpikesKillFeature.OriginalSpikes = {}
            MainModule.SpikesKillFeature.SpikesPosition = nil
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
            return true
        else
            return true
        end
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
            task.spawn(function()
                if LocalPlayer.Character then
                    local stamina = LocalPlayer.Character:FindFirstChild("StaminaVal")
                    if stamina then
                        stamina.Value = 100
                    end
                end
            end)
        end)
    end
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
    CapturedCall = nil,
    LastCapturedCallTime = 0,
    OriginalFireServer = nil,
    Remote = nil,
    TrackedPlayers = {}
}

for _, id in ipairs(MainModule.AutoDodge.AnimationIds) do
    MainModule.AutoDodge.AnimationIdsSet[id] = true
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
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local function setupCharacter(character)
                    if not character or not MainModule.AutoDodge.Enabled then return end
                    local humanoid = character:FindFirstChild("Humanoid")
                    if not humanoid then return end
                    local conn = humanoid.AnimationPlayed:Connect(function(track)
                        if not MainModule.AutoDodge.Enabled then return end
                        local animId = track.Animation and track.Animation.AnimationId
                        if not animId then return end
                        if not MainModule.AutoDodge.AnimationIdsSet[animId] then return end
                        local currentTime = tick()
                        if currentTime - MainModule.AutoDodge.LastDodgeTime < MainModule.AutoDodge.DodgeCooldown then return end
                        if not LocalPlayer or not LocalPlayer.Character then return end
                        if not player or not player.Character then return end
                        local localRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
                        if not (localRoot and targetRoot) then return end
                        local diff = targetRoot.Position - localRoot.Position
                        local distanceSquared = diff.X * diff.X + diff.Y * diff.Y + diff.Z * diff.Z
                        if distanceSquared > MainModule.AutoDodge.RangeSquared then return end
                    end)
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
        end
    end
end

function MainModule.TeleportToHider()
    local character = GetCharacter()
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and IsHider(player) and player.Character then
            local hiderRoot = player.Character:FindFirstChild("HumanoidRootPart")
            if hiderRoot then
                character.HumanoidRootPart.CFrame = hiderRoot.CFrame
                return true
            end
        end
    end
    return false
end

function MainModule.Pentathlon_AutoGonggi()
    local currentState = MainModule.AutoGonggi.Enabled
    MainModule.ToggleAutoGonggi(not currentState)
    return not currentState
end

function MainModule.HNS_SpikesKill()
    local currentState = MainModule.SpikesKillFeature.Enabled
    MainModule.ToggleSpikesKill(not currentState)
    return not currentState
end

function MainModule.HNS_InfinityStamina()
    local currentState = MainModule.HNS.InfinityStaminaEnabled
    MainModule.ToggleHNSInfinityStamina(not currentState)
    return not currentState
end

function MainModule.HNS_AutoDodge()
    local currentState = MainModule.AutoDodge.Enabled
    MainModule.ToggleAutoDodge(not currentState)
    return not currentState
end

return MainModule
