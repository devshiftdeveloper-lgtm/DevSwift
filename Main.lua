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

-- Исправленная функция уведомлений с улучшенной анимацией и Z-индексами
function MainModule.ShowNotification(title, text, duration)
    duration = duration or 3
    task.spawn(function()
        local gui = Instance.new("ScreenGui")
        gui.Name = "NotificationGui"
        gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
        gui.ResetOnSpawn = false
        gui.Parent = game:GetService("CoreGui")

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 320, 0, 0) -- Уменьшен размер
        frame.AutomaticSize = Enum.AutomaticSize.Y
        frame.Position = UDim2.new(1, 400, 0.05, 0) -- Начальная позиция за пределами экрана
        frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
        frame.BorderSizePixel = 0
        frame.ZIndex = 9999 -- Увеличен ZIndex
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
        titleLabel.TextSize = 16 -- Уменьшен размер текста
        titleLabel.Font = Enum.Font.GothamBold
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.ZIndex = 10000 -- Увеличен ZIndex
        titleLabel.Parent = frame

        local textLabel = Instance.new("TextLabel")
        textLabel.Size = UDim2.new(1, -20, 0, 0)
        textLabel.Position = UDim2.new(0, 10, 0, 35)
        textLabel.BackgroundTransparency = 1
        textLabel.Text = text
        textLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
        textLabel.TextSize = 13 -- Уменьшен размер текста
        textLabel.Font = Enum.Font.Gotham
        textLabel.TextXAlignment = Enum.TextXAlignment.Left
        textLabel.TextYAlignment = Enum.TextYAlignment.Top
        textLabel.TextWrapped = true
        textLabel.AutomaticSize = Enum.AutomaticSize.Y
        textLabel.ZIndex = 10000 -- Увеличен ZIndex
        textLabel.Parent = frame

        frame.Size = UDim2.new(0, 320, 0, textLabel.TextBounds.Y + 45)

        -- Анимация выезда
        local slideIn = TweenService:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Position = UDim2.new(1, -340, 0.05, 0)
        })
        slideIn:Play()

        task.wait(duration)

        -- Анимация выезда обратно
        local slideOut = TweenService:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
            Position = UDim2.new(1, 400, 0.05, 0)
        })
        slideOut:Play()

        task.wait(0.4)
        gui:Destroy()
    end)
end

-- Исправление опечаток в коде (замена SnowNotification на ShowNotification)
-- В оригинальном коде исправлено в строках 620, 947 и других местах

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

local function GetHider()
    for _, player in pairs(Players:GetPlayers()) do
        if IsHider(player) and player.Character then
            return player.Character
        end
    end
    return nil
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

-- ============ KILLAURA ============
MainModule.Killaura = {
    Enabled = false,
    TeleportAnimations = {
        "79649041083405",
        "73242877658272", 
        "85793691404836",
        "86197206792061",
        "99157505926076"
    },
    Connections = {},
    CurrentTarget = nil,
    IsAttached = false,
    IsLifted = false,
    LiftHeight = 10,
    TargetAnimationsSet = {},
    
    BehindDistance = 2,
    FrontDistance = 19,
    SpeedThreshold = 18,
    
    MovementSpeed = 120,
    RotationSpeed = 30,
    Smoothness = 0.95,
    JumpSyncSmoothness = 0.98,
    
    MaxVelocity = 350,
    VelocitySmoothness = 0.98,
    HumanizeFactor = 0.001,
    NaturalNoise = 0.001,
    AntiDetectionMode = true,
    
    LastPosition = Vector3.new(),
    TargetLastVelocity = Vector3.new(),
    LastHeight = 0,
    JumpSync = false,
    IsJumping = false,
    JumpStartTime = 0,
    TimeOffset = 0,
    
    JumpData = {
        TargetJumping = false,
        JumpStartY = 0,
        JumpPeakReached = false,
        JumpVelocity = 0,
        JumpGravity = 196.2,
        JumpDuration = 0
    },
    
    AnimationLiftActive = false,
    AnimationStartTime = 0,
    OriginalGroundHeight = 0,
    WasInFrontBeforeLift = false,
    LastAnimationState = false,
    
    CurrentVelocity = Vector3.new(),
    TargetVelocity = Vector3.new(),
    LastTargetPosition = Vector3.new(),
    LastTargetVelocity = Vector3.new(),
    LastDirectionCheckTime = 0,
    
    JumpStartAttachment = "behind",
    JumpStartDistance = 2
}

for _, animId in pairs(MainModule.Killaura.TeleportAnimations) do
    MainModule.Killaura.TargetAnimationsSet[animId] = true
end

local function findClosestPlayer()
    local players = game:GetService("Players")
    local localPlayer = players.LocalPlayer
    if not localPlayer then return nil end
    
    local character = localPlayer.Character
    if not character then return nil end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return nil end
    
    local myPos = rootPart.Position
    
    local hiderCharacter = GetHider()
    if hiderCharacter then
        local targetRoot = hiderCharacter:FindFirstChild("HumanoidRootPart")
        local humanoid = hiderCharacter:FindFirstChildOfClass("Humanoid")
        
        if targetRoot and humanoid and humanoid.Health > 0 then
            for _, player in pairs(players:GetPlayers()) do
                if player.Character == hiderCharacter then
                    return player
                end
            end
        end
    end
    
    local closestPlayer = nil
    local closestDistance = math.huge
    
    for _, player in pairs(players:GetPlayers()) do
        if player ~= localPlayer and player.Character then
            local targetChar = player.Character
            local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
            local humanoid = targetChar:FindFirstChildOfClass("Humanoid")
            
            if targetRoot and humanoid and humanoid.Health > 0 then
                local distance = (targetRoot.Position - myPos).Magnitude
                if distance < closestDistance then
                    closestDistance = distance
                    closestPlayer = player
                end
            end
        end
    end
    
    return closestPlayer
end

local animationCache = {}
local function checkTargetAnimationsInstant(targetPlayer)
    if not targetPlayer then return false end
    
    local character = targetPlayer.Character
    if not character then return false end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false end
    
    local tracks = humanoid:GetPlayingAnimationTracks()
    if not tracks then return false end
    
    for _, track in pairs(tracks) do
        if track and track.Animation then
            local animId = tostring(track.Animation.AnimationId)
            local cleanId = animId:match("%d+")
            
            if cleanId and MainModule.Killaura.TargetAnimationsSet[cleanId] then
                return true
            end
        end
    end
    
    return false
end

local function checkTargetJumping(targetRoot)
    if not targetRoot then return false end
    
    local config = MainModule.Killaura
    local currentTime = tick()
    
    local isJumpingNow = targetRoot.Velocity.Y > 8
    
    if isJumpingNow and not config.JumpData.TargetJumping then
        config.JumpData.TargetJumping = true
        config.JumpData.JumpStartY = targetRoot.Position.Y
        config.JumpData.JumpPeakReached = false
        config.JumpData.JumpVelocity = targetRoot.Velocity.Y
        config.JumpData.JumpStartTime = currentTime
        config.JumpSync = true
        config.IsJumping = true
        
        local targetVel = targetRoot.Velocity
        local targetLook = targetRoot.CFrame.LookVector
        local horizontalVel = Vector3.new(targetVel.X, 0, targetVel.Z)
        local horizontalSpeed = horizontalVel.Magnitude
        
        if horizontalSpeed > 2 then
            local lookDirection = Vector3.new(targetLook.X, 0, targetLook.Z).Unit
            local moveDirection = horizontalVel.Unit
            local dotProduct = lookDirection:Dot(moveDirection)
            
            if dotProduct > 0.7 and horizontalSpeed >= config.SpeedThreshold then
                config.JumpStartAttachment = "front"
                config.JumpStartDistance = config.FrontDistance
            else
                config.JumpStartAttachment = "behind"
                config.JumpStartDistance = config.BehindDistance
            end
        else
            config.JumpStartAttachment = "behind"
            config.JumpStartDistance = config.BehindDistance
        end
        
    elseif config.JumpData.TargetJumping then
        config.JumpData.JumpDuration = currentTime - config.JumpData.JumpStartTime
        
        if targetRoot.Velocity.Y < 0 and not config.JumpData.JumpPeakReached then
            config.JumpData.JumpPeakReached = true
        end
        
        if targetRoot.Velocity.Y > -2 and targetRoot.Velocity.Y < 2 and 
           math.abs(targetRoot.Position.Y - config.JumpData.JumpStartY) < 1 then
            config.JumpData.TargetJumping = false
            config.JumpSync = false
            config.IsJumping = false
            config.JumpStartAttachment = "behind"
            config.JumpStartDistance = config.BehindDistance
        end
    end
    
    return config.JumpData.TargetJumping
end

local function getTargetMovementDirection(targetRoot)
    if not targetRoot then return "idle" end
    
    local targetVel = targetRoot.Velocity
    local targetLook = targetRoot.CFrame.LookVector
    
    local horizontalVel = Vector3.new(targetVel.X, 0, targetVel.Z)
    local horizontalSpeed = horizontalVel.Magnitude
    
    if horizontalSpeed < 2 then
        return "idle"
    end
    
    local lookDirection = Vector3.new(targetLook.X, 0, targetLook.Z).Unit
    local moveDirection = horizontalVel.Unit
    
    local dotProduct = lookDirection:Dot(moveDirection)
    
    if dotProduct > 0.7 then
        return "forward"
    elseif dotProduct < -0.7 then
        return "backward"
    elseif math.abs(dotProduct) < 0.3 then
        return "sideways"
    else
        return "diagonal"
    end
end

local function handleAnimationLift(localRoot, targetPos, targetLook, targetVel, deltaTime)
    local config = MainModule.Killaura
    
    if not config.CurrentTarget then 
        config.AnimationLiftActive = false
        config.IsLifted = false
        config.LastAnimationState = false
        return false 
    end
    
    local isAnimating = checkTargetAnimationsInstant(config.CurrentTarget)
    
    local animationStateChanged = isAnimating ~= config.LastAnimationState
    config.LastAnimationState = isAnimating
    
    if isAnimating and not config.AnimationLiftActive then
        config.AnimationLiftActive = true
        config.OriginalGroundHeight = localRoot.Position.Y
        
        local targetRoot = config.CurrentTarget.Character:FindFirstChild("HumanoidRootPart")
        if targetRoot then
            local horizontalSpeed = Vector3.new(targetVel.X, 0, targetVel.Z).Magnitude
            local movementDir = getTargetMovementDirection(targetRoot)
            config.WasInFrontBeforeLift = (movementDir == "forward") and horizontalSpeed >= config.SpeedThreshold
        else
            config.WasInFrontBeforeLift = false
        end
        
        config.IsLifted = true
        
        local targetHeight = config.OriginalGroundHeight + config.LiftHeight
        local currentPos = localRoot.Position
        local newPos = Vector3.new(currentPos.X, targetHeight, currentPos.Z)
        localRoot.CFrame = CFrame.new(newPos, targetPos)
        
        return true
        
    elseif not isAnimating and config.AnimationLiftActive then
        config.AnimationLiftActive = false
        
        local currentHeight = localRoot.Position.Y
        local targetGroundHeight = config.OriginalGroundHeight
        
        if currentHeight > targetGroundHeight + 0.1 then
            local descentSpeed = 100
            local newHeight = currentHeight - descentSpeed * deltaTime
            
            if newHeight < targetGroundHeight then
                newHeight = targetGroundHeight
                config.IsLifted = false
                config.WasInFrontBeforeLift = false
            end
            
            local newPos = Vector3.new(localRoot.Position.X, newHeight, localRoot.Position.Z)
            localRoot.CFrame = CFrame.new(newPos, targetPos)
            return true
        else
            config.IsLifted = false
            config.WasInFrontBeforeLift = false
            return false
        end
    end
    
    if config.AnimationLiftActive and config.IsLifted then
        local targetHeight = config.OriginalGroundHeight + config.LiftHeight
        local currentHeight = localRoot.Position.Y
        
        if math.abs(currentHeight - targetHeight) > 0.1 then
            local correctionSpeed = 200
            local heightDiff = targetHeight - currentHeight
            local newHeight = currentHeight + heightDiff * correctionSpeed * deltaTime
            
            local newPos = Vector3.new(localRoot.Position.X, newHeight, localRoot.Position.Z)
            localRoot.CFrame = CFrame.new(newPos, targetPos)
        end
        
        return true
    end
    
    return config.AnimationLiftActive
end

local function syncJumpHeight(localRoot, targetRoot, targetPos, deltaTime)
    local config = MainModule.Killaura
    
    if not config.JumpSync or not config.IsJumping then
        return false
    end
    
    local targetHeight = targetRoot.Position.Y
    local myHeight = localRoot.Position.Y
    local heightDiff = targetHeight - myHeight
    
    if not config.JumpStartPosition then
        config.JumpStartPosition = localRoot.Position
    end
    
    if math.abs(heightDiff) > 0.05 then
        local jumpForce = heightDiff * deltaTime * 200
        
        local newHeight = myHeight + jumpForce
        
        local horizontalPos = Vector3.new(
            localRoot.Position.X,
            newHeight,
            localRoot.Position.Z
        )
        
        localRoot.CFrame = CFrame.new(horizontalPos, Vector3.new(targetPos.X, newHeight, targetPos.Z))
        return true
    end
    
    return false
end

local function getSmartPositioning(targetRoot)
    local config = MainModule.Killaura
    
    if not targetRoot then 
        return "behind", config.BehindDistance
    end
    
    local targetVel = targetRoot.Velocity
    local targetLook = targetRoot.CFrame.LookVector
    
    local horizontalVel = Vector3.new(targetVel.X, 0, targetVel.Z)
    local horizontalSpeed = horizontalVel.Magnitude
    
    if config.IsJumping then
        return config.JumpStartAttachment, config.JumpStartDistance
    end
    
    if horizontalSpeed < config.SpeedThreshold then
        return "behind", config.BehindDistance
    end
    
    local movementDir = getTargetMovementDirection(targetRoot)
    
    if movementDir == "forward" and horizontalSpeed >= config.SpeedThreshold then
        return "front", config.FrontDistance
    else
        return "behind", config.BehindDistance
    end
end

local function ultraFastMovement(localRoot, targetPos, targetLook, deltaTime, isAnimationLift)
    local config = MainModule.Killaura
    
    local targetRoot = nil
    if config.CurrentTarget and config.CurrentTarget.Character then
        targetRoot = config.CurrentTarget.Character:FindFirstChild("HumanoidRootPart")
    end
    
    local attachmentType, desiredDistance = getSmartPositioning(targetRoot)
    
    if isAnimationLift and config.WasInFrontBeforeLift then
        attachmentType = "front"
        desiredDistance = config.FrontDistance
    end
    
    local desiredOffset = (attachmentType == "front") and (targetLook * desiredDistance) or (-targetLook * desiredDistance)
    local targetGroundPos = targetPos + desiredOffset
    
    if isAnimationLift then
        targetGroundPos = Vector3.new(
            targetGroundPos.X,
            config.OriginalGroundHeight + config.LiftHeight,
            targetGroundPos.Z
        )
    end
    
    local currentPos = localRoot.Position
    local direction = targetGroundPos - currentPos
    local distance = direction.Magnitude
    
    if distance > 0.01 then
        local targetSpeed = math.min(config.MovementSpeed, distance * 100)
        
        config.CurrentVelocity = direction.Unit * targetSpeed
        
        local moveStep = config.CurrentVelocity * deltaTime
        
        if moveStep.Magnitude > distance then
            moveStep = direction
        end
        
        local newPos = currentPos + moveStep
        
        if isAnimationLift then
            local targetHeight = config.OriginalGroundHeight + config.LiftHeight
            newPos = Vector3.new(newPos.X, targetHeight, newPos.Z)
        end
        
        local lookAtPos = Vector3.new(targetPos.X, newPos.Y, targetPos.Z)
        local targetCF = CFrame.new(newPos, lookAtPos)
        
        localRoot.CFrame = localRoot.CFrame:Lerp(targetCF, config.RotationSpeed * deltaTime)
        
        localRoot.Velocity = config.CurrentVelocity
        
    else
        if isAnimationLift then
            local targetHeight = config.OriginalGroundHeight + config.LiftHeight
            local fixedPos = Vector3.new(targetGroundPos.X, targetHeight, targetGroundPos.Z)
            localRoot.CFrame = CFrame.new(fixedPos, targetPos)
        else
            localRoot.CFrame = CFrame.new(targetGroundPos, targetPos)
        end
        
        config.CurrentVelocity = Vector3.new(0, 0, 0)
        localRoot.Velocity = config.CurrentVelocity
    end
    
    config.LastTargetPosition = targetPos
end

local function ultraFastSync(targetRoot, targetHumanoid, localRoot, deltaTime)
    local config = MainModule.Killaura
    
    local targetPos = targetRoot.Position
    local targetVel = targetRoot.Velocity
    local targetLook = targetRoot.CFrame.LookVector
    
    local isTargetJumping = checkTargetJumping(targetRoot)
    
    local isAnimationLift = handleAnimationLift(localRoot, targetPos, targetLook, targetVel, deltaTime)
    
    if isTargetJumping and not isAnimationLift then
        syncJumpHeight(localRoot, targetRoot, targetPos, deltaTime)
    elseif config.IsJumping and not isTargetJumping then
        config.IsJumping = false
        config.JumpSync = false
        config.JumpStartPosition = nil
        config.JumpStartAttachment = "behind"
        config.JumpStartDistance = config.BehindDistance
    end
    
    ultraFastMovement(localRoot, targetPos, targetLook, deltaTime, isAnimationLift)
    
    if not isAnimationLift and not config.IsJumping and not config.IsLifted then
        local rayOrigin = localRoot.Position + Vector3.new(0, 1, 0)
        local ray = Ray.new(rayOrigin, Vector3.new(0, -4, 0))
        local hit = workspace:FindPartOnRayWithIgnoreList(ray, {localRoot.Parent})
        
        if hit then
            local heightDiff = localRoot.Position.Y - rayOrigin.Y + 4
            if heightDiff > 3.0 then
                localRoot.Velocity = Vector3.new(0, -80, 0)
            elseif heightDiff < 2.0 then
                localRoot.Velocity = Vector3.new(0, 50, 0)
            end
        end
    end
    
    config.LastPosition = localRoot.Position
    config.TargetLastVelocity = targetVel
    config.LastDirectionCheckTime = tick()
end

local function checkAndSwitchTarget()
    local config = MainModule.Killaura
    
    if not config.Enabled then return false end
    
    local currentTarget = config.CurrentTarget
    
    if currentTarget then
        local targetChar = currentTarget.Character
        if not targetChar then return false end
        
        local humanoid = targetChar:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then return false end
        
        local localPlayer = game:GetService("Players").LocalPlayer
        if localPlayer and localPlayer.Character then
            local localRoot = localPlayer.Character:FindFirstChild("HumanoidRootPart")
            local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
            
            if localRoot and targetRoot then
                local distance = (targetRoot.Position - localRoot.Position).Magnitude
                if distance > 250 then return false end
            end
        end
        
        return true
    end
    
    return false
end

local function updateUltraFastSync(deltaTime)
    if not MainModule.Killaura.Enabled then return end
    
    local localPlayer = game:GetService("Players").LocalPlayer
    if not localPlayer then return end
    
    local character = localPlayer.Character
    if not character then return end
    
    local localRoot = character:FindFirstChild("HumanoidRootPart")
    if not localRoot then return end
    
    local config = MainModule.Killaura
    
    if not checkAndSwitchTarget() then
        config.CurrentTarget = nil
        config.IsAttached = false
        config.AnimationLiftActive = false
        config.IsLifted = false
        config.IsJumping = false
        config.JumpSync = false
        config.JumpStartPosition = nil
        config.JumpStartAttachment = "behind"
        config.JumpStartDistance = config.BehindDistance
        
        local closestPlayer = findClosestPlayer()
        if closestPlayer then
            config.CurrentTarget = closestPlayer
            config.IsAttached = true
            config.LastAnimationState = false
            
            local targetChar = closestPlayer.Character
            local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
            
            if localRoot and targetRoot then
                local targetLook = targetRoot.CFrame.LookVector
                local targetVel = targetRoot.Velocity
                local horizontalSpeed = Vector3.new(targetVel.X, 0, targetVel.Z).Magnitude
                
                local attachmentType, desiredDistance
                if horizontalSpeed >= config.SpeedThreshold and getTargetMovementDirection(targetRoot) == "forward" then
                    attachmentType = "front"
                    desiredDistance = config.FrontDistance
                else
                    attachmentType = "behind"
                    desiredDistance = config.BehindDistance
                end
                
                local desiredOffset = (attachmentType == "front") and (targetLook * desiredDistance) or (-targetLook * desiredDistance)
                local startPos = targetRoot.Position + desiredOffset
                
                localRoot.CFrame = CFrame.new(startPos, targetRoot.Position)
                
                config.LastPosition = startPos
                config.OriginalGroundHeight = startPos.Y
                config.CurrentVelocity = Vector3.new(0, 0, 0)
                config.JumpStartAttachment = attachmentType
                config.JumpStartDistance = desiredDistance
            end
        else
            task.delay(0.05, function()
                if config.Enabled and not config.CurrentTarget then
                    MainModule.ToggleKillaura(false)
                end
            end)
            return
        end
    end
    
    if not config.CurrentTarget or not config.IsAttached then return end
    
    local targetChar = config.CurrentTarget.Character
    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
    local targetHumanoid = targetChar:FindFirstChildOfClass("Humanoid")
    
    if not targetRoot or not targetHumanoid or targetHumanoid.Health <= 0 then
        config.CurrentTarget = nil
        config.IsAttached = false
        return
    end
    
    ultraFastSync(targetRoot, targetHumanoid, localRoot, deltaTime)
end

function MainModule.ToggleKillaura(enabled)
    local config = MainModule.Killaura
    
    if config.Enabled == enabled then return end
    
    if enabled then
        if not findClosestPlayer() then return end
    end
    
    config.Enabled = enabled

    if enabled then
        MainModule.ShowNotification("Killaura", "Killaura Enabled", 3)
    else
        MainModule.ShowNotification("Killaura", "Killaura Disabled", 3)
    end
    
    for _, conn in pairs(config.Connections) do
        if conn then conn:Disconnect() end
    end
    config.Connections = {}
    
    if not enabled then
        config.CurrentTarget = nil
        config.IsAttached = false
        config.IsLifted = false
        config.IsJumping = false
        config.AnimationLiftActive = false
        config.LastAnimationState = false
        config.JumpSync = false
        config.JumpStartPosition = nil
        config.CurrentVelocity = Vector3.new(0, 0, 0)
        config.JumpStartAttachment = "behind"
        config.JumpStartDistance = config.BehindDistance
        return
    end
    
    local closestPlayer = findClosestPlayer()
    if closestPlayer then
        config.CurrentTarget = closestPlayer
        config.IsAttached = true
        config.LastAnimationState = false
        
        config.AnimationLiftActive = false
        config.IsLifted = false
        config.IsJumping = false
        config.JumpSync = false
        config.JumpStartPosition = nil
        config.CurrentVelocity = Vector3.new(0, 0, 0)
        config.JumpStartAttachment = "behind"
        config.JumpStartDistance = config.BehindDistance
        
        local localPlayer = game:GetService("Players").LocalPlayer
        if localPlayer and localPlayer.Character then
            local localRoot = localPlayer.Character:FindFirstChild("HumanoidRootPart")
            local targetChar = closestPlayer.Character
            local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
            
            if localRoot and targetRoot then
                local targetLook = targetRoot.CFrame.LookVector
                local targetVel = targetRoot.Velocity
                local horizontalSpeed = Vector3.new(targetVel.X, 0, targetVel.Z).Magnitude
                
                local attachmentType, desiredDistance
                if horizontalSpeed >= config.SpeedThreshold and getTargetMovementDirection(targetRoot) == "forward" then
                    attachmentType = "front"
                    desiredDistance = config.FrontDistance
                else
                    attachmentType = "behind"
                    desiredDistance = config.BehindDistance
                end
                
                local desiredOffset = (attachmentType == "front") and (targetLook * desiredDistance) or (-targetLook * desiredDistance)
                local startPos = targetRoot.Position + desiredOffset
                
                localRoot.CFrame = CFrame.new(startPos, targetRoot.Position)
                
                config.LastPosition = startPos
                config.OriginalGroundHeight = startPos.Y
                config.CurrentVelocity = Vector3.new(0, 0, 0)
                config.JumpStartAttachment = attachmentType
                config.JumpStartDistance = desiredDistance
            end
        end
    else
        config.Enabled = false
        return
    end
    
    local heartbeatConn = game:GetService("RunService").Heartbeat:Connect(function(deltaTime)
        if not config.Enabled then return end
        updateUltraFastSync(deltaTime)
    end)
    
    table.insert(config.Connections, heartbeatConn)
    
    local players = game:GetService("Players")
    local localPlayer = players.LocalPlayer
    
    if localPlayer then
        local charConn = localPlayer.CharacterAdded:Connect(function()
            if not config.Enabled then return end
            
            task.wait(0.1)
            
            config.CurrentTarget = nil
            config.IsAttached = false
            config.IsLifted = false
            config.IsJumping = false
            config.AnimationLiftActive = false
            config.LastAnimationState = false
            config.JumpSync = false
            config.JumpStartPosition = nil
            config.CurrentVelocity = Vector3.new(0, 0, 0)
            config.JumpStartAttachment = "behind"
            config.JumpStartDistance = config.BehindDistance
            
            local closestPlayer = findClosestPlayer()
            if closestPlayer then
                config.CurrentTarget = closestPlayer
                config.IsAttached = true
            else
                MainModule.ToggleKillaura(false)
            end
        end)
        table.insert(config.Connections, charConn)
    end
    
    local removeConn = players.PlayerRemoving:Connect(function(player)
        if config.Enabled and config.CurrentTarget == player then
            config.CurrentTarget = nil
            config.IsAttached = false
            config.AnimationLiftActive = false
            config.LastAnimationState = false
            config.JumpSync = false
            config.JumpStartPosition = nil
            config.CurrentVelocity = Vector3.new(0, 0, 0)
            config.JumpStartAttachment = "behind"
            config.JumpStartDistance = config.BehindDistance
            
            local closestPlayer = findClosestPlayer()
            if closestPlayer then
                config.CurrentTarget = closestPlayer
                config.IsAttached = true
            else
                task.delay(0.1, function()
                    if config.Enabled and not config.CurrentTarget then
                        MainModule.ToggleKillaura(false)
                    end
                end)
            end
        end
    end)
    table.insert(config.Connections, removeConn)
end

-- ============ ESP ============
MainModule.Misc = {
    InstaInteract = false,
    NoCooldownProximity = false,
    ESPEnabled = false,
    ESPPlayers = true,
    ESPHiders = true,
    ESPSeekers = true,
    ESPCandies = false,
    ESPKeys = true,
    ESPDoors = true,
    ESPEscapeDoors = true,
    ESPGuards = true,
    ESPHighlight = true,
    ESPDistance = true,
    ESPNames = true,
    ESPBoxes = true,
    ESPFillTransparency = 0.7,
    ESPOutlineTransparency = 0,
    ESPTextSize = 18,
    BypassRagdollEnabled = false,
    RemoveInjuredEnabled = false,
    RemoveStunEnabled = false,
    UnlockDashEnabled = false,
    UnlockPhantomStepEnabled = false,
    LastInjuredNotify = 0,
    LastESPUpdate = 0
}

MainModule.ESP = {
    Players = {},
    Objects = {},
    Connections = {},
    Folder = nil,
    MainConnection = nil,
    UpdateRate = 0.1
}

function MainModule.ToggleESP(enabled)
    MainModule.Misc.ESPEnabled = enabled

    if enabled then
        MainModule.ShowNotification("ESP", "ESP Enabled", 3)
    else
        MainModule.ShowNotification("ESP", "ESP Disabled", 3)
    end
    
    if MainModule.ESP.MainConnection then
        MainModule.ESP.MainConnection:Disconnect()
        MainModule.ESP.MainConnection = nil
    end
    MainModule.ClearESP()
    if enabled then
        MainModule.ESP.Folder = Instance.new("Folder")
        MainModule.ESP.Folder.Name = "CreonXESP"
        MainModule.ESP.Folder.Parent = game:GetService("CoreGui")
        
        local function UpdatePlayerESP(player)
            if not player or player == LocalPlayer then return end
            local character = player.Character
            if not character then return end
            local humanoid = GetHumanoid(character)
            local rootPart = GetRootPart(character)
            if not (humanoid and rootPart and humanoid.Health > 0) then return end
            
            local localCharacter = GetCharacter()
            local localRoot = localCharacter and GetRootPart(localCharacter)
            local espData = MainModule.ESP.Players[player]
            
            if not espData then
                espData = {
                    Player = player,
                    Highlight = nil,
                    Billboard = nil,
                    Label = nil
                }
                MainModule.ESP.Players[player] = espData
            end
            
            if not espData.Highlight then
                espData.Highlight = Instance.new("Highlight")
                espData.Highlight.Name = player.Name .. "_ESP"
                espData.Highlight.Adornee = character
                espData.Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                espData.Highlight.Enabled = MainModule.Misc.ESPHighlight
                espData.Highlight.Parent = MainModule.ESP.Folder
            end
            
            if IsHider(player) and MainModule.Misc.ESPHiders then
                espData.Highlight.FillColor = Color3.fromRGB(0, 255, 0)
                espData.Highlight.OutlineColor = Color3.fromRGB(0, 200, 0)
            elseif IsSeeker(player) and MainModule.Misc.ESPSeekers then
                espData.Highlight.FillColor = Color3.fromRGB(255, 0, 0)
                espData.Highlight.OutlineColor = Color3.fromRGB(200, 0, 0)
            elseif MainModule.Misc.ESPPlayers then
                espData.Highlight.FillColor = Color3.fromRGB(0, 120, 255)
                espData.Highlight.OutlineColor = Color3.fromRGB(0, 100, 200)
            else
                espData.Highlight.Enabled = false
            end
            
            espData.Highlight.FillTransparency = MainModule.Misc.ESPFillTransparency
            espData.Highlight.OutlineTransparency = MainModule.Misc.ESPOutlineTransparency
            
            if MainModule.Misc.ESPNames then
                if not espData.Billboard then
                    espData.Billboard = Instance.new("BillboardGui")
                    espData.Billboard.Name = player.Name .. "_Text"
                    espData.Billboard.Adornee = rootPart
                    espData.Billboard.AlwaysOnTop = true
                    espData.Billboard.Size = UDim2.new(0, 200, 0, 50)
                    espData.Billboard.StudsOffset = Vector3.new(0, 3, 0)
                    espData.Billboard.Parent = MainModule.ESP.Folder
                    
                    espData.Label = Instance.new("TextLabel")
                    espData.Label.Size = UDim2.new(1, 0, 1, 0)
                    espData.Label.BackgroundTransparency = 1
                    espData.Label.TextColor3 = espData.Highlight.FillColor
                    espData.Label.TextSize = MainModule.Misc.ESPTextSize
                    espData.Label.Font = Enum.Font.GothamBold
                    espData.Label.TextStrokeColor3 = Color3.new(0, 0, 0)
                    espData.Label.TextStrokeTransparency = 0.5
                    espData.Label.Parent = espData.Billboard
                end
                
                espData.Billboard.Enabled = true
                local distanceText = ""
                if MainModule.Misc.ESPDistance and localRoot then
                    local distance = math.floor(GetDistance(rootPart.Position, localRoot.Position))
                    distanceText = string.format(" [%dm]", distance)
                end
                
                local healthText = string.format("HP: %d/%d", math.floor(humanoid.Health), math.floor(humanoid.MaxHealth))
                local nameText = player.DisplayName or player.Name
                espData.Label.Text = string.format("%s\n%s%s", nameText, healthText, distanceText)
                espData.Label.TextColor3 = espData.Highlight.FillColor
                espData.Label.TextSize = MainModule.Misc.ESPTextSize
            elseif espData.Billboard then
                espData.Billboard.Enabled = false
            end
        end
        
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                UpdatePlayerESP(player)
                player.CharacterAdded:Connect(function()
                    task.wait(0.5)
                    UpdatePlayerESP(player)
                end)
            end
        end
        
        MainModule.ESP.Connections.PlayerAdded = Players.PlayerAdded:Connect(function(player)
            if MainModule.Misc.ESPEnabled and player ~= LocalPlayer then
                task.wait(0.5)
                UpdatePlayerESP(player)
            end
        end)
        
        MainModule.ESP.MainConnection = RunService.RenderStepped:Connect(function()
            if not MainModule.Misc.ESPEnabled then return end
            for player, espData in pairs(MainModule.ESP.Players) do
                if player and player.Parent and player.Character then
                    UpdatePlayerESP(player)
                else
                    if espData.Highlight then
                        SafeDestroy(espData.Highlight)
                    end
                    if espData.Billboard then
                        SafeDestroy(espData.Billboard)
                    end
                    MainModule.ESP.Players[player] = nil
                end
            end
        end)
    end
end

function MainModule.ClearESP()
    for player, espData in pairs(MainModule.ESP.Players) do
        if espData.Highlight then
            SafeDestroy(espData.Highlight)
        end
        if espData.Billboard then
            SafeDestroy(espData.Billboard)
        end
    end
    MainModule.ESP.Players = {}
    
    if MainModule.ESP.Connections then
        for name, connection in pairs(MainModule.ESP.Connections) do
            if connection then
                pcall(function() connection:Disconnect() end)
                MainModule.ESP.Connections[name] = nil
            end
        end
    end
    
    if MainModule.ESP.Folder then
        SafeDestroy(MainModule.ESP.Folder)
        MainModule.ESP.Folder = nil
    end
    
    if MainModule.ESP.MainConnection then
        MainModule.ESP.MainConnection:Disconnect()
        MainModule.ESP.MainConnection = nil
    end
end

-- ============ FAN FUNCTIONS ============
MainModule.FreeDash = {
    Enabled = false,
    RemoteAddedConnection = nil,
    ChildAddedHook = nil,
    RemoteEventConnection = nil,
    OriginalSprintValue = nil,
    OriginalRemote = nil,
    FakeRemote = nil,
    OriginalParent = nil,
    OriginalIndex = nil,
    OriginalNewIndex = nil,
    SecureTable = nil
}

local antiStunConnection = nil
MainModule.AutoQTE = {
    AntiStunEnabled = false
}

local bypassRagdollConnection = nil

local function DeepRemoveDashRequest()
    local Environment = (getgenv or function() return _G end)()
    local CoreServices = game:GetService("ReplicatedStorage")

    local function ProcessTargetObject()
        local RemoteContainer = CoreServices:FindFirstChild("Remotes")
        local TargetRemote = RemoteContainer and RemoteContainer:FindFirstChild("DashRequest")
        
        if TargetRemote then
            if type(setrawmetatable) == "function" then
                local SecureTable = {
                    __index = function(self, key)
                        if key == "FireServer" or key == "InvokeServer" then
                            return function() end
                        end
                        return nil
                    end,
                    __newindex = function() end,
                    __call = function() end,
                    __metatable = "Protected"
                }
                setrawmetatable(TargetRemote, SecureTable)
                MainModule.FreeDash.SecureTable = SecureTable
            end
            
            local RemoteMethods = {"FireServer", "InvokeServer", "OnClientEvent", "OnClientInvoke"}
            for _, MethodName in ipairs(RemoteMethods) do
                pcall(function()
                    local original = TargetRemote[MethodName]
                    if original then
                        MainModule.FreeDash["Original" .. MethodName] = original
                        if setrawmetatable then
                            local mt = debug.getmetatable(TargetRemote)
                            if mt then
                                local originalIndex = mt.__index
                                mt.__index = function(self, key)
                                    if key == MethodName then
                                        return function() end
                                    end
                                    return originalIndex(self, key)
                                end
                            end
                        end
                    end
                end)
            end
            
            if type(getconnections) == "function" then
                local EventHandlers = {"Changed", "AncestryChanged"}
                for _, EventName in ipairs(EventHandlers) do
                    local EventSignal = TargetRemote[EventName]
                    if EventSignal then
                        for _, Handler in ipairs(getconnections(EventSignal)) do
                            Handler:Disconnect()
                        end
                    end
                end
            end
            
            pcall(function()
                TargetRemote.Archivable = false
                MainModule.FreeDash.OriginalParent = TargetRemote.Parent
                local FakeRemote = Instance.new("RemoteEvent")
                FakeRemote.Name = "DashRequest"
                for _, descendant in ipairs(TargetRemote:GetChildren()) do
                    descendant:Clone().Parent = FakeRemote
                end
                FakeRemote.Parent = TargetRemote.Parent
                MainModule.FreeDash.OriginalRemote = TargetRemote
                TargetRemote.Parent = nil
                MainModule.FreeDash.FakeRemote = FakeRemote
            end)
            
            if type(getrawmetatable) == "function" then
                local ObjectMeta = getrawmetatable(TargetRemote)
                if ObjectMeta then
                    MainModule.FreeDash.OriginalIndex = ObjectMeta.__index
                    MainModule.FreeDash.OriginalNewIndex = ObjectMeta.__newindex
                    
                    ObjectMeta.__index = function(self, Property)
                        if Property == "FireServer" or Property == "InvokeServer" then
                            return function() end
                        end
                        return MainModule.FreeDash.OriginalIndex(self, Property)
                    end
                    
                    ObjectMeta.__newindex = function(self, Property, Value)
                        if Property == "Parent" and Value == nil then
                            return
                        end
                        return MainModule.FreeDash.OriginalNewIndex(self, Property, Value)
                    end
                end
            end
        end
    end

    ProcessTargetObject()
    
    local remoteFolder = CoreServices:WaitForChild("Remotes", 1)
    if remoteFolder then
        MainModule.FreeDash.RemoteAddedConnection = remoteFolder.ChildAdded:Connect(function(child)
            if child.Name == "DashRequest" then
                task.wait(0.1)
                pcall(function()
                    if setrawmetatable then
                        local SecureTable = {
                            __index = function() return function() end end,
                            __newindex = function() end,
                            __metatable = "Protected"
                        }
                        setrawmetatable(child, SecureTable)
                    end
                    child.Archivable = false
                    child.Parent = nil
                end)
            end
        end)
    end
end

local function BlockNewDashRequests()
    local CoreServices = game:GetService("ReplicatedStorage")
    local remoteFolder = CoreServices:WaitForChild("Remotes", 1)
    if remoteFolder then
        MainModule.FreeDash.ChildAddedHook = remoteFolder.ChildAdded:Connect(function(child)
            if child.Name == "DashRequest" then
                task.spawn(function()
                    task.wait(0.05)
                    pcall(function()
                        if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
                            if setrawmetatable then
                                local mt = {
                                    __index = function() return function() end end,
                                    __newindex = function() end
                                }
                                setrawmetatable(child, mt)
                            end
                            child.Archivable = false
                            child.Parent = nil
                        end
                    end)
                end)
            end
        end)
    end
end

function MainModule.ToggleFreeDash(enabled)
    MainModule.FreeDash.Enabled = enabled

    if enabled then
        MainModule.ShowNotification("Free Dash", "Free Dash Enabled", 3)
    else
        MainModule.ShowNotification("Free Dash", "Free Dash Disabled", 3)
    end
    
    if enabled then
        DeepRemoveDashRequest()
        BlockNewDashRequests()

        local boosts = LocalPlayer:FindFirstChild("Boosts")
        if boosts then
            local fasterSprint = boosts:FindFirstChild("Faster Sprint")
            if fasterSprint then
                MainModule.FreeDash.OriginalSprintValue = fasterSprint.Value
                fasterSprint.Value = 8
            end
        end
        
        local remote = ReplicatedStorage:FindFirstChild("Remotes")
        if remote then
            remote = remote:FindFirstChild("DashRequest")
            if remote then
                MainModule.FreeDash.RemoteEventConnection = remote:GetPropertyChangedSignal("Parent"):Connect(function()
                    pcall(function()
                        if remote.Parent == nil then
                            if MainModule.FreeDash.FakeRemote then
                                MainModule.FreeDash.FakeRemote.Parent = MainModule.FreeDash.OriginalParent
                            end
                        end
                    end)
                end)
            end
        end
        
    else
        if MainModule.FreeDash.RemoteAddedConnection then
            MainModule.FreeDash.RemoteAddedConnection:Disconnect()
            MainModule.FreeDash.RemoteAddedConnection = nil
        end
        
        if MainModule.FreeDash.ChildAddedHook then
            MainModule.FreeDash.ChildAddedHook:Disconnect()
            MainModule.FreeDash.ChildAddedHook = nil
        end
        
        if MainModule.FreeDash.RemoteEventConnection then
            MainModule.FreeDash.RemoteEventConnection:Disconnect()
            MainModule.FreeDash.RemoteEventConnection = nil
        end
        
        local boosts = LocalPlayer:FindFirstChild("Boosts")
        if boosts then
            local fasterSprint = boosts:FindFirstChild("Faster Sprint")
            if fasterSprint then
                fasterSprint.Value = MainModule.FreeDash.OriginalSprintValue
            end
        end
        
        if MainModule.FreeDash.OriginalRemote and MainModule.FreeDash.OriginalParent then
            pcall(function()
                MainModule.FreeDash.OriginalRemote.Parent = MainModule.FreeDash.OriginalParent
            end)
        end
        
        if MainModule.FreeDash.FakeRemote then
            pcall(function() MainModule.FreeDash.FakeRemote:Destroy() end)
            MainModule.FreeDash.FakeRemote = nil
        end
        
        if MainModule.FreeDash.OriginalIndex then
            local remote = ReplicatedStorage:FindFirstChild("Remotes")
            if remote then
                remote = remote:FindFirstChild("DashRequest")
                if remote and getrawmetatable then
                    local mt = getrawmetatable(remote)
                    if mt then
                        mt.__index = MainModule.FreeDash.OriginalIndex
                        if MainModule.FreeDash.OriginalNewIndex then
                            mt.__newindex = MainModule.FreeDash.OriginalNewIndex
                        end
                    end
                end
            end
        end
        
        local methods = {"FireServer", "InvokeServer", "OnClientEvent", "OnClientInvoke"}
        for _, method in ipairs(methods) do
            local original = MainModule.FreeDash["Original" .. method]
            if original then
                local remote = ReplicatedStorage:FindFirstChild("Remotes")
                if remote then
                    remote = remote:FindFirstChild("DashRequest")
                    if remote then
                        pcall(function()
                            remote[method] = original
                        end)
                    end
                end
            end
        end
    end
end

function MainModule.ToggleAntiStunQTE(enabled)
    MainModule.AutoQTE.AntiStunEnabled = enabled

    if enabled then
        MainModule.ShowNotification("Anti-Stun QTE", "Anti-Stun QTE Enabled", 3)
    else
        MainModule.ShowNotification("Anti-Stun QTE", "Anti-Stun QTE Disabled", 3)
    end
    
    if antiStunConnection then
        antiStunConnection:Disconnect()
        antiStunConnection = nil
    end
    if enabled then
        antiStunConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.AutoQTE.AntiStunEnabled then return end
            pcall(function()
                local playerGui = LocalPlayer:WaitForChild("PlayerGui")
                local impactFrames = playerGui:FindFirstChild("ImpactFrames")
                if not impactFrames then return end
                local replicatedStorage = ReplicatedStorage
                local success, hbgModule = pcall(function()
                    return require(replicatedStorage.Modules.HBGQTE)
                end)
                if not success then return end
                for _, child in pairs(impactFrames:GetChildren()) do
                    if child.Name == "OuterRingTemplate" and child:IsA("Frame") then
                        for _, innerChild in pairs(impactFrames:GetChildren()) do
                            if innerChild.Name == "InnerTemplate" and innerChild.Position == child.Position 
                               and not innerChild:GetAttribute("Failed") and not innerChild:GetAttribute("Tweening") then
                                pcall(function()
                                    local qteData = {
                                        Inner = innerChild,
                                        Outer = child,
                                        Duration = 2,
                                        StartedAt = tick()
                                    }
                                    hbgModule.Pressed(false, qteData)
                                end)
                                break
                            end
                        end
                    end
                end
            end)
        end)
    end
end

local harmfulEffectsList = {
    "RagdollStun", "Stun", "Stunned", "StunEffect", "StunHit",
    "Knockback", "Knockdown", "Knockout", "KB_Effect",
    "Dazed", "Paralyzed", "Paralyze", "Freeze", "Frozen", 
    "Sleep", "Sleeping", "SleepEffect", "Confusion", "Confused",
    "Slow", "Slowed", "Root", "Rooted", "Immobilized",
    "Bleed", "Bleeding", "Poison", "Poisoned", "Burn", "Burning",
    "Shock", "Shocked", "Electrocuted", "Silence", "Silenced",
    "Disarm", "Disarmed", "Blind", "Blinded", "Fear", "Feared",
    "Taunt", "Taunted", "Charm", "Charmed", "Petrify", "Petrified"
}

local enhancedProtectionConnection = nil
local jointCleaningConnection = nil
local ragdollBlockConnection = nil

local function CleanNegativeEffects(character)
    if not character or not MainModule.Misc.BypassRagdollEnabled then return end
    pcall(function()
        for _, effectName in ipairs(harmfulEffectsList) do
            local effect = character:FindFirstChild(effectName)
            if effect then
                if effect:IsA("BasePart") then
                    task.spawn(function()
                        for i = 1, 5 do
                            if effect and effect.Parent then
                                effect.Transparency = effect.Transparency + 0.2
                                task.wait(0.02)
                            end
                        end
                        pcall(function() effect:Destroy() end)
                    end)
                else
                    pcall(function() effect:Destroy() end)
                end
            end
        end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            local badAttributes = {"Stunned", "Paralyzed", "Frozen", "Asleep", "Confused", 
                                   "Slowed", "Rooted", "Silenced", "Disarmed", "Blinded", "Feared"}
            for _, attr in ipairs(badAttributes) do
                if humanoid:GetAttribute(attr) then
                    humanoid:SetAttribute(attr, false)
                end
            end
        end
    end)
end

local function CleanJointsAndConstraints(character)
    if not character then return end
    pcall(function()
        local Humanoid = character:FindFirstChild("Humanoid")
        local HumanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        local Torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
        if not (Humanoid and HumanoidRootPart and Torso) then return end
        for _, child in ipairs(character:GetChildren()) do
            if child.Name == "Ragdoll" then
                pcall(function() child:Destroy() end)
            end
        end
        for _, folderName in pairs({"Stun", "RotateDisabled", "RagdollWakeupImmunity", "InjuredWalking"}) do
            local folder = character:FindFirstChild(folderName)
            if folder then
                folder:Destroy()
            end
        end
        for _, obj in pairs(HumanoidRootPart:GetChildren()) do
            if obj:IsA("BallSocketConstraint") or obj.Name:match("^CacheAttachment") then
                obj:Destroy()
            end
        end
        local joints = {"Left Hip", "Left Shoulder", "Neck", "Right Hip", "Right Shoulder"}
        for _, jointName in pairs(joints) do
            local motor = Torso:FindFirstChild(jointName)
            if motor and motor:IsA("Motor6D") and not motor.Part0 then
                motor.Part0 = Torso
            end
        end
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("BasePart") and part:FindFirstChild("BoneCustom") then
                part.BoneCustom:Destroy()
            end
        end
    end)
end

local function SetupRagdollListener(character)
    if not character then return end
    if ragdollBlockConnection then
        ragdollBlockConnection:Disconnect()
        ragdollBlockConnection = nil
    end
    local Humanoid = character:FindFirstChild("Humanoid")
    if not Humanoid then return end
    ragdollBlockConnection = character.ChildAdded:Connect(function(child)
        if child.Name == "Ragdoll" then
            pcall(function() child:Destroy() end)
            pcall(function()
                Humanoid.PlatformStand = false
                Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
                Humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
                Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
            end)
        end
    end)
end

function MainModule.StartEnhancedProtection()
    if enhancedProtectionConnection then
        enhancedProtectionConnection:Disconnect()
    end
    enhancedProtectionConnection = RunService.Heartbeat:Connect(function()
        if not MainModule.Misc.BypassRagdollEnabled then return end
        local character = GetCharacter()
        if character then
            CleanNegativeEffects(character)
        end
    end)
end

function MainModule.StopEnhancedProtection()
    if enhancedProtectionConnection then
        enhancedProtectionConnection:Disconnect()
        enhancedProtectionConnection = nil
    end
end

function MainModule.StartJointCleaning()
    if jointCleaningConnection then
        jointCleaningConnection:Disconnect()
    end
    local character = GetCharacter()
    if character then
        CleanJointsAndConstraints(character)
        SetupRagdollListener(character)
    end
    jointCleaningConnection = RunService.Heartbeat:Connect(function()
        if not MainModule.Misc.BypassRagdollEnabled then return end
        local character = GetCharacter()
        if character then
            CleanJointsAndConstraints(character)
        end
    end)
    LocalPlayer.CharacterAdded:Connect(function(newChar)
        task.wait(1)
        SetupRagdollListener(newChar)
        CleanJointsAndConstraints(newChar)
    end)
end

function MainModule.StopJointCleaning()
    if jointCleaningConnection then
        jointCleaningConnection:Disconnect()
        jointCleaningConnection = nil
    end
    if ragdollBlockConnection then
        ragdollBlockConnection:Disconnect()
        ragdollBlockConnection = nil
    end
end

function MainModule.FullCleanup()
    local character = GetCharacter()
    if character then
        CleanNegativeEffects(character)
        CleanJointsAndConstraints(character)
        return true
    end
    return false
end

function MainModule.ToggleBypassRagdoll(enabled)
    MainModule.Misc.BypassRagdollEnabled = enabled

    if enabled then
        MainModule.ShowNotification("Bypass Ragdoll", "Bypass Ragdoll Enabled", 3)
    else
        MainModule.ShowNotification("Bypass Ragdoll", "Bypass Ragdoll Disabled", 3)
    end
    
    if bypassRagdollConnection then
        bypassRagdollConnection:Disconnect()
        bypassRagdollConnection = nil
    end
    if enabled then
        bypassRagdollConnection = RunService.Stepped:Connect(function()
            if not MainModule.Misc.BypassRagdollEnabled then return end
            pcall(function()
                local Character = GetCharacter()
                if not Character then return end
                local Humanoid = GetHumanoid(Character)
                local HumanoidRootPart = GetRootPart(Character)
                if not (Humanoid and HumanoidRootPart) then return end
                
                local moveDirection = Humanoid.MoveDirection
                local isPlayerControlling = moveDirection.Magnitude > 0
                local playerVelocity = HumanoidRootPart.Velocity
                local playerSpeed = Vector3.new(playerVelocity.X, 0, playerVelocity.Z).Magnitude
                
                for _, child in ipairs(Character:GetChildren()) do
                    if child.Name == "Ragdoll" then
                        task.spawn(function()
                            for i = 1, 10 do
                                if child and child.Parent then
                                    for _, part in pairs(child:GetChildren()) do
                                        if part:IsA("BasePart") then
                                            part.Transparency = part.Transparency + 0.1
                                        end
                                    end
                                    task.wait(0.05)
                                end
                            end
                            pcall(function() child:Destroy() end)
                        end)
                        Humanoid.PlatformStand = false
                        Humanoid:ChangeState(Enum.HumanoidStateType.Running)
                    end
                end
                local harmfulFolders = {"RotateDisabled", "RagdollWakeupImmunity"}
                for _, folderName in pairs(harmfulFolders) do
                    local folder = Character:FindFirstChild(folderName)
                    if folder then
                        folder:Destroy()
                    end
                end
                for _, part in pairs(Character:GetChildren()) do
                    if part:IsA("BasePart") then
                        local currentVelocity = part.Velocity
                        local horizontalSpeed = Vector3.new(currentVelocity.X, 0, currentVelocity.Z).Magnitude
                        
                        local speedThreshold = isPlayerControlling and 150 or 50
                        
                        if horizontalSpeed > speedThreshold and part ~= HumanoidRootPart then
                            local newVelocity = Vector3.new(
                                currentVelocity.X * 0.8,
                                currentVelocity.Y,
                                currentVelocity.Z * 0.8
                            )
                            part.Velocity = newVelocity
                        end
                        for _, force in pairs(part:GetChildren()) do
                            if force:IsA("BodyForce") then
                                local forceMagnitude = force.Force.Magnitude
                                if forceMagnitude > 1000 then
                                    force:Destroy()
                                end
                            elseif force:IsA("BodyVelocity") then
                                if force.Velocity.Magnitude > 30 and not isPlayerControlling then
                                    force:Destroy()
                                end
                            end
                        end
                    end
                end
                local playerInputVelocity = HumanoidRootPart.Velocity
                local externalForces = {}
                for _, force in pairs(HumanoidRootPart:GetChildren()) do
                    if force:IsA("BodyForce") or force:IsA("BodyVelocity") then
                        table.insert(externalForces, force)
                    end
                end
                
                local shouldFilterVelocity = #externalForces > 0 and not isPlayerControlling
                
                if shouldFilterVelocity then
                    local filteredVelocity = Vector3.new(
                        playerInputVelocity.X,
                        HumanoidRootPart.Velocity.Y,
                        playerInputVelocity.Z
                    )
                    HumanoidRootPart.Velocity = filteredVelocity
                    for _, force in pairs(externalForces) do
                        task.spawn(function()
                            if force:IsA("BodyVelocity") then
                                for i = 1, 5 do
                                    if force and force.Parent then
                                        force.Velocity = force.Velocity * 0.5
                                        task.wait(0.02)
                                    end
                                end
                            end
                            pcall(function() force:Destroy() end)
                        end)
                    end
                end
            end)
        end)
        local char = GetCharacter()
        if char then
            char.ChildAdded:Connect(function(child)
                if child.Name == "Ragdoll" and MainModule.Misc.BypassRagdollEnabled then
                    task.wait(0.1)
                    pcall(function() child:Destroy() end)
                    local humanoid = GetHumanoid(char)
                    if humanoid then
                        humanoid.PlatformStand = false
                        humanoid:ChangeState(Enum.HumanoidStateType.Running)
                    end
                end
            end)
        end
        task.wait(0.5)
        MainModule.StartEnhancedProtection()
        MainModule.StartJointCleaning()
    else
        MainModule.StopEnhancedProtection()
        MainModule.StopJointCleaning()
    end
end

function MainModule.ToggleRemoveStun(enabled)
    MainModule.Misc.RemoveStunEnabled = enabled

    if enabled then
        MainModule.ShowNotification("Remove Stun", "Remove Stun Enabled", 3)
    end
    
    if not enabled then return end
    
    local function removeStunEffects()
        local character = GetCharacter()
        if not character then return end
        
        for _, effectName in ipairs(harmfulEffectsList) do
            local effect = character:FindFirstChild(effectName)
            if effect then
                pcall(function() effect:Destroy() end)
            end
        end
        
        local humanoid = GetHumanoid(character)
        if humanoid then
            if humanoid:GetAttribute("Stunned") then
                humanoid:SetAttribute("Stunned", false)
            end
        end
    end
    
    removeStunEffects()
    
    if MainModule.Misc.RemoveStunEnabled then
        local connection = RunService.Heartbeat:Connect(function()
            if not MainModule.Misc.RemoveStunEnabled then 
                connection:Disconnect()
                return 
            end
            removeStunEffects()
        end)
    end
end

function MainModule.TeleportUp100()
    local character = GetCharacter()
    if character then
        local rootPart = GetRootPart(character)
        if rootPart then
            local targetPos = rootPart.Position + Vector3.new(0, 100, 0)
            SafeTeleport(targetPos)
        end
    end
end

function MainModule.TeleportDown40()
    local character = GetCharacter()
    if character then
        local rootPart = GetRootPart(character)
        if rootPart then
            local targetPos = rootPart.Position + Vector3.new(0, -40, 0)
            SafeTeleport(targetPos)
        end
    end
end

-- ============ GAMEPASS FUNCTIONS ============
function MainModule.EnablePermanentGuard()
    LocalPlayer:SetAttribute("__OwnsPermGuard", true)
    MainModule.ShowNotification("GamePass", "Permanent Guard: Successfully granted", 3)
end

function MainModule.EnableGlassManufacturerVision()
    LocalPlayer:SetAttribute("__OwnsGlassManufacturerVision", true)
    MainModule.ShowNotification("GamePass", "Glass Manufacturer Vision: Successfully granted", 3)
end

function MainModule.EnableFreeVIP()
    LocalPlayer:SetAttribute("__OwnsVIPGamepass", true)
    LocalPlayer:SetAttribute("VIPChatTag", true)
    MainModule.ShowNotification("GamePass", "Free VIP: Successfully granted", 3)
end

function MainModule.EnableEmotePages()
    LocalPlayer:SetAttribute("__OwnsEmotePages", true)
    MainModule.ShowNotification("GamePass", "Emote Pages: Successfully granted", 3)
end

function MainModule.EnableCustomPlayerTag()
    LocalPlayer:SetAttribute("__OwnsCustomPlayerTag", true)
    MainModule.ShowNotification("GamePass", "Custom Player Tag: Successfully granted", 3)
end

function MainModule.EnablePrivateServerPlus()
    LocalPlayer:SetAttribute("__OwnsPSPlus", true)
    MainModule.ShowNotification("GamePass", "Private Server Plus: Successfully granted", 3)
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

вот запомни авто додж

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
    MainModule.AutoDodge.Enabled = false
    
    -- Очистка всех соединений
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
        -- Добавляем уведомление
        MainModule.ShowNotification("Auto Dodge", "Auto Dodge Enabled", 3)
        
        local Players = game:GetService("Players")
        
        -- Мгновенная инициализация всех игроков
        for _, player in pairs(Players:GetPlayers()) do
            setupInstantPlayerTracking(player)
        end
        
        -- Отслеживание новых игроков
        local playerAddedConn = Players.PlayerAdded:Connect(function(player)
            if MainModule.AutoDodge.Enabled then
                setupInstantPlayerTracking(player)
            end
        end)
        table.insert(MainModule.AutoDodge.Connections, playerAddedConn)
        
        -- Дополнительный мониторинг для максимальной скорости
        setupInstantReactionMonitor()
    else
        -- Добавляем уведомление при выключении
        MainModule.ShowNotification("Auto Dodge", "Auto Dodge Disabled", 3)
    end
end

-- ============ ОБРАБОТКА ВЫХОДА ИГРОКА ============

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

Players.PlayerRemoving:Connect(function(player)
    if player == LocalPlayer then
        MainModule.ToggleAutoDodge(false)
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
