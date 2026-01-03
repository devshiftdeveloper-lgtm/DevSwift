local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local GuiService = game:GetService("GuiService")

if not game:IsLoaded() then
    game.Loaded:Wait()
end

if not RunService:IsClient() and not RunService:IsStudio() then
    return
end

local MainModule
local success, err = pcall(function()
    MainModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/devshiftdeveloper-lgtm/DevSwift/main/Main.lua"))()
end)

if not success then
    MainModule = {}
end

local originalMouseIconEnabled = UserInputService.MouseIconEnabled
local isMenuOpen = false
local isMobile = UserInputService.TouchEnabled

local function blockGameControls()
    if not isMobile then
        UserInputService.MouseIconEnabled = true
        GuiService:SetMenuIsOpen(true)
    end
end

local function restoreGameControls()
    if not isMobile then
        UserInputService.MouseIconEnabled = originalMouseIconEnabled
        GuiService:SetMenuIsOpen(false)
    end
end

local function createAimSightGUI()
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")

    local player = Players.LocalPlayer
    local mouse = player:GetMouse()

    local visualState = {
        time = 0,
        rotationProgress = 0,
        currentRotationSpeed = 0.8,
        smoothedRotation = 5,
        lines = {
            top = {Size = UDim2.new(0, 3, 0, 25), Position = UDim2.new(0.5, -1.5, 0, 0), Color = Color3.new(1,1,1)},
            bottom = {Size = UDim2.new(0, 3, 0, 25), Position = UDim2.new(0.5, -1.5, 1, -25), Color = Color3.new(1,1,1)},
            left = {Size = UDim2.new(0, 25, 0, 3), Position = UDim2.new(0, 0, 0.5, -1.5), Color = Color3.new(1,1,1)},
            right = {Size = UDim2.new(0, 25, 0, 3), Position = UDim2.new(1, -25, 0.5, -1.5), Color = Color3.new(1,1,1)},
        },
        text = {
            Text = "DevShift",
            Position = UDim2.new(0, 0, 0, 0),
            Color = Color3.new(1,1,1),
            Font = Enum.Font.Arcade,
            TextScaled = true,
        }
    }

    local screenGui
    local aimContainer
    local topLine, bottomLine, leftLine, rightLine
    local textLabel

    local lineLength = 25
    local lineThickness = 3
    local baseRotationSpeed = 0.8
    local pulseSpeed = 2.5
    local minLength = -10
    local maxLength = -30

    local time = 0
    local rotationProgress = 0
    local currentRotationSpeed = baseRotationSpeed
    local smoothedRotation = 5

    local function createLine(parent, size, position, color)
        local frame = Instance.new("Frame")
        frame.Size = size
        frame.Position = position
        frame.BackgroundColor3 = color
        frame.BorderSizePixel = 0
        frame.ZIndex = 100000
        frame.Parent = parent

        local stroke = Instance.new("UIStroke")
        stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        stroke.Color = Color3.new(0,0,0)
        stroke.Thickness = 1
        stroke.ZIndex = 100000
        stroke.Parent = frame

        return frame
    end

    local function createTextLabel(parent, text, position, color, font, scaled)
        local label = Instance.new("TextLabel")
        label.Text = text
        label.Position = position
        label.TextColor3 = color
        label.Font = font
        label.TextScaled = scaled
        label.BackgroundTransparency = 1
        label.Size = UDim2.new(0, 150, 0, 23)
        label.ZIndex = 100001
        label.Parent = parent

        local stroke = Instance.new("UIStroke")
        stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
        stroke.Color = Color3.new(0,0,0)
        stroke.Thickness = 1
        stroke.LineJoinMode = Enum.LineJoinMode.Round
        stroke.ZIndex = 100001
        stroke.Parent = label

        return label
    end

    local function clearGui()
        if screenGui then
            screenGui:Destroy()
            screenGui = nil
        end
    end

    local function createGui()
        clearGui()

        screenGui = Instance.new("ScreenGui")
        screenGui.Name = "DevShiftAimSight"
        screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        screenGui.ResetOnSpawn = false
        screenGui.DisplayOrder = 99999
        screenGui.Parent = CoreGui

        aimContainer = Instance.new("Frame")
        aimContainer.BackgroundTransparency = 1
        aimContainer.Size = UDim2.new(0, 25, 0, 25)
        aimContainer.AnchorPoint = Vector2.new(0.5, 0.5)
        aimContainer.ZIndex = 100000
        aimContainer.Parent = screenGui

        topLine = createLine(aimContainer, visualState.lines.top.Size, visualState.lines.top.Position, visualState.lines.top.Color)
        bottomLine = createLine(aimContainer, visualState.lines.bottom.Size, visualState.lines.bottom.Position, visualState.lines.bottom.Color)
        leftLine = createLine(aimContainer, visualState.lines.left.Size, visualState.lines.left.Position, visualState.lines.left.Color)
        rightLine = createLine(aimContainer, visualState.lines.right.Size, visualState.lines.right.Position, visualState.lines.right.Color)

        textLabel = createTextLabel(screenGui, visualState.text.Text, visualState.text.Position, visualState.text.Color, visualState.text.Font, visualState.text.TextScaled)
    end

    local function getRainbowColor(t)
        local r = math.sin(t * 0.6) * 0.5 + 0.5
        local g = math.sin(t * 0.6 + 2) * 0.5 + 0.5
        local b = math.sin(t * 0.6 + 4) * 0.5 + 0.5
        return Color3.new(r, g, b)
    end

    local function calculateRotationSpeed(progress)
        local slowdownStart = 0.6
        local slowdownDuration = 0.35
        local minSlowdownSpeed = 0.3
        local baseRotationSpeedLocal = baseRotationSpeed

        if progress >= slowdownStart then
            local slowdownProgress = (progress - slowdownStart) / slowdownDuration
            local easedProgress = slowdownProgress * slowdownProgress
            local slowdownFactor = 1 - (easedProgress * (1 - minSlowdownSpeed))
            return baseRotationSpeedLocal * math.max(slowdownFactor, minSlowdownSpeed)
        else
            return baseRotationSpeedLocal
        end
    end

    local function smoothRotation(currentRot, targetRot, smoothing)
        return currentRot + (targetRot - currentRot) * smoothing
    end

    local function smoothPulse(t, speed)
        local rawPulse = math.sin(t * speed) * 0.5 + 0.5
        return rawPulse * rawPulse
    end

    local function onCharacterAdded(character)
        createGui()
    end

    player.CharacterAdded:Connect(onCharacterAdded)

    if player.Character then
        task.spawn(onCharacterAdded, player.Character)
    end

    RunService.RenderStepped:Connect(function(deltaTime)
        if not (aimContainer and topLine and bottomLine and leftLine and rightLine and textLabel) then
            return
        end

        time = time + deltaTime

        aimContainer.Position = UDim2.new(0, mouse.X, 0, mouse.Y)
        textLabel.Position = UDim2.new(0, mouse.X - 70, 0, mouse.Y + 50)

        rotationProgress = (rotationProgress + currentRotationSpeed * deltaTime) % 1
        currentRotationSpeed = calculateRotationSpeed(rotationProgress)

        local targetRotation = rotationProgress * 360
        smoothedRotation = smoothRotation(smoothedRotation, targetRotation, 1)
        aimContainer.Rotation = smoothedRotation

        local pulse = smoothPulse(time, pulseSpeed)
        local currentLength = minLength + (maxLength - minLength) * pulse

        topLine.Size = UDim2.new(0, lineThickness, 0, currentLength)
        bottomLine.Size = UDim2.new(0, lineThickness, 0, currentLength)
        leftLine.Size = UDim2.new(0, currentLength, 0, lineThickness)
        rightLine.Size = UDim2.new(0, currentLength, 0, lineThickness)

        topLine.Position = UDim2.new(0.5, -lineThickness / 2, 0, 0)
        bottomLine.Position = UDim2.new(0.5, -lineThickness / 2, 1, -currentLength)
        leftLine.Position = UDim2.new(0, 0, 0.5, -lineThickness / 2)
        rightLine.Position = UDim2.new(1, -currentLength, 0.5, -lineThickness / 2)

        local rainbowColor = getRainbowColor(time)

        topLine.BackgroundColor3 = rainbowColor
        bottomLine.BackgroundColor3 = rainbowColor
        leftLine.BackgroundColor3 = rainbowColor
        rightLine.BackgroundColor3 = rainbowColor

        textLabel.TextColor3 = rainbowColor
    end)
end

task.spawn(createAimSightGUI)

-- Создаем основной GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DevShiftGUI"
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 999
screenGui.IgnoreGuiInset = true
screenGui.Parent = CoreGui

local background = Instance.new("Frame")
background.Name = "Background"
background.Size = UDim2.new(1, 0, 1, 0)
background.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
background.BackgroundTransparency = 0.85
background.BorderSizePixel = 0
background.ZIndex = 1
background.Visible = false
background.Parent = screenGui

local mainContainer = Instance.new("Frame")
mainContainer.Name = "MainContainer"
mainContainer.Size = isMobile and UDim2.new(0.85, 0, 0.8, 0) or UDim2.new(0, 700, 0, 450)
mainContainer.AnchorPoint = Vector2.new(0.5, 0.5)
mainContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
mainContainer.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
mainContainer.BackgroundTransparency = 0
mainContainer.BorderSizePixel = 0
mainContainer.ZIndex = 2
mainContainer.Visible = false
mainContainer.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainContainer

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(35, 35, 35)
mainStroke.Thickness = 2
mainStroke.Transparency = 0
mainStroke.LineJoinMode = Enum.LineJoinMode.Round
mainStroke.ZIndex = 2
mainStroke.Parent = mainContainer

local accentStroke = Instance.new("UIStroke")
accentStroke.Color = Color3.fromRGB(80, 80, 80)
accentStroke.Thickness = 1
accentStroke.Transparency = 0
accentStroke.LineJoinMode = Enum.LineJoinMode.Round
accentStroke.ZIndex = 3
accentStroke.Parent = mainContainer

local innerBackground = Instance.new("Frame")
innerBackground.Size = UDim2.new(1, -6, 1, -6)
innerBackground.Position = UDim2.new(0, 3, 0, 3)
innerBackground.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
innerBackground.BackgroundTransparency = 0.3
innerBackground.BorderSizePixel = 0
innerBackground.ZIndex = 2
innerBackground.Parent = mainContainer

local innerCorner = Instance.new("UICorner")
innerCorner.CornerRadius = UDim.new(0, 10)
innerCorner.Parent = innerBackground

local contentContainer = Instance.new("Frame")
contentContainer.Size = UDim2.new(1, -12, 1, -12)
contentContainer.Position = UDim2.new(0, 6, 0, 6)
contentContainer.BackgroundTransparency = 1
contentContainer.ZIndex = 3
contentContainer.Parent = mainContainer

local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, isMobile and 50 or 50)
topBar.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
topBar.BackgroundTransparency = 0
topBar.BorderSizePixel = 0
topBar.ZIndex = 4
topBar.Parent = contentContainer

local topBarCorner = Instance.new("UICorner")
topBarCorner.CornerRadius = UDim.new(0, 8)
topBarCorner.Parent = topBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = isMobile and UDim2.new(1, -80, 1, 0) or UDim2.new(1, -50, 1, 0)
titleLabel.Position = UDim2.new(0, isMobile and 15 or 15, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "DEVSHIFT"
titleLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
titleLabel.TextSize = isMobile and 22 or 24
titleLabel.Font = Enum.Font.GothamBlack
titleLabel.TextTransparency = 0
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.ZIndex = 5
titleLabel.Parent = topBar

local closeButton
if isMobile then
    closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 40, 0, 40)
    closeButton.Position = UDim2.new(1, -10, 0.5, 0)
    closeButton.AnchorPoint = Vector2.new(1, 0.5)
    closeButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    closeButton.BackgroundTransparency = 0
    closeButton.BorderSizePixel = 0
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.fromRGB(220, 220, 220)
    closeButton.TextSize = 20
    closeButton.Font = Enum.Font.GothamBold
    closeButton.TextTransparency = 0
    closeButton.ZIndex = 10
    closeButton.AutoButtonColor = true
    closeButton.Parent = topBar

    local closeButtonCorner = Instance.new("UICorner")
    closeButtonCorner.CornerRadius = UDim.new(0, 8)
    closeButtonCorner.Parent = closeButton

    local closeButtonStroke = Instance.new("UIStroke")
    closeButtonStroke.Color = Color3.fromRGB(60, 60, 60)
    closeButtonStroke.Thickness = 1.5
    closeButtonStroke.Transparency = 0
    closeButtonStroke.ZIndex = 10
    closeButtonStroke.Parent = closeButton
end

local mainContent = Instance.new("Frame")
mainContent.Size = UDim2.new(1, 0, 1, -(isMobile and 60 or 60))
mainContent.Position = UDim2.new(0, 0, 0, isMobile and 60 or 60)
mainContent.BackgroundTransparency = 1
mainContent.ZIndex = 4
mainContent.Parent = contentContainer

local tabsContainer = Instance.new("Frame")
tabsContainer.Size = isMobile and UDim2.new(1, 0, 0, 50) or UDim2.new(0.2, -4, 1, 0)
tabsContainer.Position = isMobile and UDim2.new(0, 0, 0, 0) or UDim2.new(0, 0, 0, 0)
tabsContainer.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
tabsContainer.BackgroundTransparency = 0
tabsContainer.BorderSizePixel = 0
tabsContainer.ZIndex = 6
tabsContainer.Parent = mainContent

local tabsCorner = Instance.new("UICorner")
tabsCorner.CornerRadius = UDim.new(0, 8)
tabsCorner.Parent = tabsContainer

local tabsList = Instance.new("Frame")
tabsList.Name = "TabsList"
tabsList.Size = isMobile and UDim2.new(1, -8, 1, -8) or UDim2.new(1, -8, 1, -8)
tabsList.Position = UDim2.new(0, 4, 0, 4)
tabsList.BackgroundTransparency = 1
tabsList.BorderSizePixel = 0
tabsList.ZIndex = 7
tabsList.Parent = tabsContainer

local tabsListLayout = Instance.new("UIListLayout")
tabsListLayout.Padding = UDim.new(0, 6)
tabsListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
tabsListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
tabsListLayout.FillDirection = isMobile and Enum.FillDirection.Horizontal or Enum.FillDirection.Vertical
tabsListLayout.Parent = tabsList

local functionsContainer = Instance.new("Frame")
functionsContainer.Size = isMobile and UDim2.new(1, 0, 1, -60) or UDim2.new(0.8, -4, 1, 0)
functionsContainer.Position = isMobile and UDim2.new(0, 0, 0, 55) or UDim2.new(0.2, 4, 0, 0)
functionsContainer.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
functionsContainer.BackgroundTransparency = 0
functionsContainer.BorderSizePixel = 0
functionsContainer.ZIndex = 5
functionsContainer.Parent = mainContent

local functionsCorner = Instance.new("UICorner")
functionsCorner.CornerRadius = UDim.new(0, 8)
functionsCorner.Parent = functionsContainer

local openButton
if isMobile then
    openButton = Instance.new("TextButton")
    openButton.Name = "OpenButton"
    openButton.Size = UDim2.new(0, 80, 0, 40)
    openButton.Position = UDim2.new(0, 20, 0, 20)
    openButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    openButton.BackgroundTransparency = 0
    openButton.BorderSizePixel = 0
    openButton.Text = "OPEN"
    openButton.TextColor3 = Color3.fromRGB(240, 240, 240)
    openButton.TextSize = 18
    openButton.Font = Enum.Font.GothamBold
    openButton.Visible = false
    openButton.ZIndex = 1000
    openButton.AutoButtonColor = true
    openButton.Parent = screenGui

    local openButtonCorner = Instance.new("UICorner")
    openButtonCorner.CornerRadius = UDim.new(0, 8)
    openButtonCorner.Parent = openButton

    local openButtonStroke = Instance.new("UIStroke")
    openButtonStroke.Color = Color3.fromRGB(60, 60, 60)
    openButtonStroke.Thickness = 1.5
    openButtonStroke.ZIndex = 1000
    openButtonStroke.Parent = openButton
    
    local isDraggingOpenButton = false
    local dragStartOpenButton
    local startPosOpenButton
    local wasDragged = false
    
    openButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDraggingOpenButton = true
            dragStartOpenButton = input.Position
            startPosOpenButton = openButton.Position
            wasDragged = false
            openButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        end
    end)
    
    openButton.InputChanged:Connect(function(input)
        if isDraggingOpenButton and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStartOpenButton
            
            if math.abs(delta.X) > 10 or math.abs(delta.Y) > 10 then
                wasDragged = true
            end
            
            if wasDragged then
                openButton.Position = UDim2.new(
                    startPosOpenButton.X.Scale, 
                    startPosOpenButton.X.Offset + delta.X,
                    startPosOpenButton.Y.Scale, 
                    startPosOpenButton.Y.Offset + delta.Y
                )
            end
        end
    end)
    
    openButton.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDraggingOpenButton = false
            openButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            
            if not wasDragged then
                showMenu()
            end
        end
    end)
    
    if UserInputService.TouchEnabled then
        openButton.Size = UDim2.new(0, 90, 0, 50)
        openButton.TextSize = 20
    end
end

local toggleElements = {}

local function createModernToggle(parent, text, state, callback)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(1, -10, 0, isMobile and 45 or 40)
    toggleFrame.BackgroundTransparency = 1
    toggleFrame.ZIndex = 10
    toggleFrame.Parent = parent
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundColor3 = state and Color3.fromRGB(35, 35, 35) or Color3.fromRGB(25, 25, 25)
    button.BackgroundTransparency = 0
    button.BorderSizePixel = 0
    button.Text = ""
    button.AutoButtonColor = false
    button.ZIndex = 11
    button.Parent = toggleFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = state and Color3.fromRGB(70, 150, 70) or Color3.fromRGB(60, 60, 60)
    stroke.Thickness = 1.5
    stroke.ZIndex = 11
    stroke.Parent = button
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(0.7, -8, 1, 0)
    textLabel.Position = UDim2.new(0, 12, 0, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = text
    textLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
    textLabel.TextSize = isMobile and 14 or 12
    textLabel.Font = Enum.Font.GothamMedium
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.ZIndex = 12
    textLabel.Parent = button
    
    local toggleSwitch = Instance.new("Frame")
    toggleSwitch.Name = "ToggleSwitch"
    toggleSwitch.Size = UDim2.new(0, isMobile and 50 or 40, 0, isMobile and 25 or 20)
    toggleSwitch.Position = UDim2.new(1, -8, 0.5, 0)
    toggleSwitch.AnchorPoint = Vector2.new(1, 0.5)
    toggleSwitch.BackgroundColor3 = state and Color3.fromRGB(40, 100, 40) or Color3.fromRGB(45, 45, 45)
    toggleSwitch.BorderSizePixel = 0
    toggleSwitch.ZIndex = 12
    toggleSwitch.Parent = button
    
    local switchCorner = Instance.new("UICorner")
    switchCorner.CornerRadius = UDim.new(1, 0)
    switchCorner.Parent = toggleSwitch
    
    local switchStroke = Instance.new("UIStroke")
    switchStroke.Color = Color3.fromRGB(20, 20, 20)
    switchStroke.Thickness = 1
    switchStroke.ZIndex = 12
    switchStroke.Parent = toggleSwitch
    
    local switchHandle = Instance.new("Frame")
    switchHandle.Name = "Handle"
    switchHandle.Size = UDim2.new(0, isMobile and 20 or 16, 0, isMobile and 20 or 16)
    switchHandle.Position = state and UDim2.new(1, -3, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
    switchHandle.AnchorPoint = Vector2.new(state and 1 or 0, 0.5)
    switchHandle.BackgroundColor3 = Color3.fromRGB(250, 250, 250)
    switchHandle.BorderSizePixel = 0
    switchHandle.ZIndex = 13
    switchHandle.Parent = toggleSwitch
    
    local handleCorner = Instance.new("UICorner")
    handleCorner.CornerRadius = UDim.new(1, 0)
    handleCorner.Parent = switchHandle
    
    local handleStroke = Instance.new("UIStroke")
    handleStroke.Color = Color3.fromRGB(30, 30, 30)
    handleStroke.Thickness = 1
    handleStroke.ZIndex = 14
    handleStroke.Parent = switchHandle
    
    local function updateVisual()
        if state then
            button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            stroke.Color = Color3.fromRGB(70, 150, 70)
            toggleSwitch.BackgroundColor3 = Color3.fromRGB(40, 100, 40)
            switchHandle.Position = UDim2.new(1, -3, 0.5, 0)
            switchHandle.AnchorPoint = Vector2.new(1, 0.5)
        else
            button.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            stroke.Color = Color3.fromRGB(60, 60, 60)
            toggleSwitch.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            switchHandle.Position = UDim2.new(0, 3, 0.5, 0)
            switchHandle.AnchorPoint = Vector2.new(0, 0.5)
        end
    end
    
    updateVisual()
    
    button.MouseButton1Click:Connect(function()
        state = not state
        updateVisual()
        if callback then
            callback(state)
        end
    end)
    
    table.insert(toggleElements, {
        frame = toggleFrame,
        getState = function() return state end,
        setState = function(newState)
            state = newState
            updateVisual()
        end,
        callback = callback
    })
    
    return toggleFrame
end

local function createModernButton(parent, text, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -10, 0, isMobile and 45 or 40)
    button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    button.BackgroundTransparency = 0
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = Color3.fromRGB(240, 240, 240)
    button.TextSize = isMobile and 14 or 12
    button.Font = Enum.Font.GothamMedium
    button.AutoButtonColor = true
    button.ZIndex = 10
    button.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(70, 70, 70)
    stroke.Thickness = 1.5
    stroke.ZIndex = 10
    stroke.Parent = button
    
    if callback then
        button.MouseButton1Click:Connect(callback)
    end
    
    return button
end

local function createTabButton(tabName)
    local tabButton = Instance.new("TextButton")
    tabButton.Name = tabName .. "Tab"
    tabButton.Size = isMobile and UDim2.new(0, 85, 0, 36) or UDim2.new(1, 0, 0, 36)
    tabButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    tabButton.BackgroundTransparency = 0
    tabButton.BorderSizePixel = 0
    tabButton.Text = tabName:upper()
    tabButton.TextColor3 = Color3.fromRGB(180, 180, 180)
    tabButton.TextSize = isMobile and 11 or 11
    tabButton.Font = Enum.Font.GothamMedium
    tabButton.TextTransparency = 0
    tabButton.ZIndex = 8
    tabButton.AutoButtonColor = false
    tabButton.Parent = tabsList
    
    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 6)
    tabCorner.Parent = tabButton
    
    local tabStroke = Instance.new("UIStroke")
    tabStroke.Color = Color3.fromRGB(50, 50, 50)
    tabStroke.Thickness = 1.5
    tabStroke.Transparency = 0
    tabStroke.ZIndex = 8
    tabStroke.Parent = tabButton
    
    return tabButton
end

local tabNames = {"Games", "Combat", "Misc", "Guards", "Settings"}
local tabButtons = {}

for i, tabName in ipairs(tabNames) do
    local tabButton = createTabButton(tabName)
    tabButtons[tabName] = tabButton
end

local currentContentFrame
local createdSections = {}

local function createGamesContent()
    if currentContentFrame then
        currentContentFrame:Destroy()
        currentContentFrame = nil
    end
    
    createdSections = {}
    
    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "GamesContent"
    contentFrame.Size = UDim2.new(1, -16, 1, -16)
    contentFrame.Position = UDim2.new(0, 8, 0, 8)
    contentFrame.BackgroundTransparency = 1
    contentFrame.ZIndex = 8
    contentFrame.Parent = functionsContainer
    
    local scrollingFrame = Instance.new("ScrollingFrame")
    scrollingFrame.Name = "GamesScrolling"
    scrollingFrame.Size = UDim2.new(1, 0, 1, 0)
    scrollingFrame.BackgroundTransparency = 1
    scrollingFrame.BorderSizePixel = 0
    scrollingFrame.ScrollBarThickness = isMobile and 10 or 6
    scrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(40, 40, 40)
    scrollingFrame.ScrollBarImageTransparency = 0.5
    scrollingFrame.ZIndex = 9
    scrollingFrame.Parent = contentFrame
    
    local gamesContainer = Instance.new("Frame")
    gamesContainer.Name = "GamesContainer"
    gamesContainer.Size = UDim2.new(1, 0, 0, 0)
    gamesContainer.BackgroundTransparency = 1
    gamesContainer.ZIndex = 10
    gamesContainer.Parent = scrollingFrame
    
    local gamesLayout = Instance.new("UIListLayout")
    gamesLayout.Padding = UDim.new(0, 15)
    gamesLayout.SortOrder = Enum.SortOrder.LayoutOrder
    gamesLayout.Parent = gamesContainer
    
    local sections = {
        {
            title = "RED LIGHT GREEN LIGHT",
            items = {
                {name = "TELEPORT TO START", func = "RLGL_TP_ToStart", type = "button"},
                {name = "TELEPORT TO END", func = "RLGL_TP_ToEnd", type = "button"}
            }
        },
        {
            title = "DALGONA",
            items = {
                {name = "COMPLETE DALGONA", func = "Dalgona_Complete", type = "button"},
                {name = "FREE LIGHTER", func = "Dalgona_FreeLighter", type = "button"}
            }
        },
        {
            title = "GONGGI",
            items = {
                {name = "AUTO GONGGI", func = "ToggleAutoGonggi", type = "toggle", getState = function() return MainModule.AutoGonggi and MainModule.AutoGonggi.Enabled or false end}
            }
        },
        {
            title = "HIDE AND SEEK",
            items = {
                {name = "INFINITY STAMINA", func = "ToggleHNSInfinityStamina", type = "toggle", getState = function() return MainModule.HNS and MainModule.HNS.InfinityStaminaEnabled or false end},
                {name = "SPIKES KILL", func = "ToggleSpikesKill", type = "toggle", getState = function() return MainModule.SpikesKillFeature and MainModule.SpikesKillFeature.Enabled or false end},
                {name = "AUTO DODGE", func = "ToggleAutoDodge", type = "toggle", getState = function() return MainModule.AutoDodge and MainModule.AutoDodge.Enabled or false end},
                {name = "TELEPORT TO HIDER", func = "TeleportToHider", type = "button"}
            }
        },
        {
            title = "TUG OF WAR",
            items = {
                {name = "ANTI MISS", func = "ToggleAntiMiss", type = "toggle", getState = function() return MainModule.TugOfWar and MainModule.TugOfWar.AntiMissEnabled or false end}
            }
        },
        {
            title = "GLASS BRIDGE",
            items = {
                {name = "ANTI BREAK", func = "ToggleAntiBreak", type = "toggle", getState = function() return MainModule.GlassBridge and MainModule.GlassBridge.AntiBreakEnabled or false end},
                {name = "GLASS ESP", func = "ToggleGlassESP", type = "toggle", getState = function() return MainModule.GlassESP and MainModule.GlassESP.Enabled or false end},
                {name = "TELEPORT TO END", func = "GlassBridge_TP_ToEnd", type = "button"}
            }
        },
        {
            title = "JUMP ROPE",
            items = {
                {name = "TELEPORT TO START", func = "TeleportToJumpRopeStart", type = "button"},
                {name = "TELEPORT TO END", func = "TeleportToJumpRopeEnd", type = "button"},
                {name = "DELETE THE ROPE", func = "DeleteJumpRope", type = "button"},
                {name = "ANTIFALL", func = "ToggleJumpRopeAntiFall", type = "toggle", getState = function() return MainModule.JumpRope and MainModule.JumpRope.AntiFallEnabled or false end}
            }
        },
        {
            title = "MINGLE",
            items = {
                {name = "VOID KILL", func = "ToggleMingleVoidKill", type = "toggle", getState = function() return MainModule.MingleVoidKill and MainModule.MingleVoidKill.Enabled or false end}
            }
        },
        {
            title = "REBEL",
            items = {
                {name = "INSTANT REBEL", func = "ToggleRebel", type = "toggle", getState = function() return MainModule.Rebel and MainModule.Rebel.Enabled or false end}
            }
        },
        {
            title = "LAST DINNER",
            items = {
                {name = "ZONE KILL", func = "ToggleZoneKill", type = "toggle", getState = function() return MainModule.ZoneKillFeature and MainModule.ZoneKillFeature.Enabled or false end}
            }
        },
        {
            title = "SKY SQUID GAME",
            items = {
                {name = "ANTIFALL", func = "ToggleSkySquidGameAntiFall", type = "toggle", getState = function() return MainModule.SkySquidGame and MainModule.SkySquidGame.AntiFallEnabled or false end},
                {name = "VOID KILL", func = "ToggleVoidKill", type = "toggle", getState = function() return MainModule.VoidKillFeature and MainModule.VoidKillFeature.Enabled or false end}
            }
        }
    }
    
    for i, section in ipairs(sections) do
        if createdSections[section.title] then continue end
        
        local sectionFrame = Instance.new("Frame")
        sectionFrame.Name = "Section_" .. i
        sectionFrame.Size = UDim2.new(1, 0, 0, 0)
        sectionFrame.BackgroundTransparency = 1
        sectionFrame.LayoutOrder = i
        sectionFrame.ZIndex = 11
        sectionFrame.Parent = gamesContainer
        
        local sectionTitle = Instance.new("TextLabel")
        sectionTitle.Size = UDim2.new(1, 0, 0, isMobile and 35 or 30)
        sectionTitle.Position = UDim2.new(0, 0, 0, 1)
        sectionTitle.BackgroundTransparency = 1
        sectionTitle.Text = section.title
        sectionTitle.TextColor3 = Color3.fromRGB(220, 220, 220)
        sectionTitle.TextSize = isMobile and 16 or 14
        sectionTitle.Font = Enum.Font.GothamBold
        sectionTitle.TextXAlignment = Enum.TextXAlignment.Left
        sectionTitle.ZIndex = 12
        sectionTitle.Parent = sectionFrame
        
        local titleStroke = Instance.new("UIStroke")
        titleStroke.Color = Color3.fromRGB(50, 50, 50)
        titleStroke.Thickness = 1
        titleStroke.ZIndex = 12
        titleStroke.Parent = sectionTitle
        
        local itemsContainer = Instance.new("Frame")
        itemsContainer.Size = UDim2.new(1, 0, 0, 0)
        itemsContainer.Position = UDim2.new(0, 0, 0, isMobile and 40 or 35)
        itemsContainer.BackgroundTransparency = 1
        itemsContainer.ZIndex = 12
        itemsContainer.Parent = sectionFrame
        
        local itemsLayout = Instance.new("UIListLayout")
        itemsLayout.Padding = UDim.new(0, 10)
        itemsLayout.SortOrder = Enum.SortOrder.LayoutOrder
        itemsLayout.Parent = itemsContainer
        
        local itemCount = 0
        
        for _, item in ipairs(section.items) do
            if item.type == "toggle" then
                local toggle = createModernToggle(itemsContainer, item.name, 
                    item.getState and item.getState() or false,
                    function(state)
                        if MainModule[item.func] then
                            MainModule[item.func](state)
                        end
                    end)
                itemCount = itemCount + 1
            elseif item.type == "button" then
                local button = createModernButton(itemsContainer, item.name, function()
                    if MainModule[item.func] then
                        MainModule[item.func]()
                    end
                end)
                itemCount = itemCount + 1
            end
        end
        
        local totalItemHeight = itemCount * (isMobile and 45 or 40) + (itemCount - 1) * 10
        itemsContainer.Size = UDim2.new(1, 0, 0, totalItemHeight)
        sectionFrame.Size = UDim2.new(1, 0, 0, (isMobile and 40 or 35) + totalItemHeight)
        
        createdSections[section.title] = true
    end
    
    gamesLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        gamesContainer.Size = UDim2.new(1, 0, 0, gamesLayout.AbsoluteContentSize.Y)
        scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, gamesLayout.AbsoluteContentSize.Y)
    end)
    
    task.wait(0.1)
    gamesContainer.Size = UDim2.new(1, 0, 0, gamesLayout.AbsoluteContentSize.Y)
    scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, gamesLayout.AbsoluteContentSize.Y)
    
    return contentFrame
end

local function createEmptyContent(tabName)
    local contentFrame = Instance.new("Frame")
    contentFrame.Name = tabName .. "Content"
    contentFrame.Size = UDim2.new(1, -16, 1, -16)
    contentFrame.Position = UDim2.new(0, 8, 0, 8)
    contentFrame.BackgroundTransparency = 1
    contentFrame.ZIndex = 8
    contentFrame.Parent = functionsContainer
    
    local comingSoon = Instance.new("TextLabel")
    comingSoon.Size = UDim2.new(1, 0, 0, 60)
    comingSoon.Position = UDim2.new(0, 0, 0.4, 0)
    comingSoon.BackgroundTransparency = 1
    comingSoon.Text = tabName .. "\nCOMING SOON"
    comingSoon.TextColor3 = Color3.fromRGB(120, 120, 120)
    comingSoon.TextSize = 20
    comingSoon.Font = Enum.Font.GothamBold
    comingSoon.TextXAlignment = Enum.TextXAlignment.Center
    comingSoon.TextYAlignment = Enum.TextYAlignment.Center
    comingSoon.ZIndex = 9
    comingSoon.Parent = contentFrame
    
    return contentFrame
end

local function showTabContent(tabName)
    if currentContentFrame then
        currentContentFrame:Destroy()
        currentContentFrame = nil
    end
    
    if tabName == "Games" then
        currentContentFrame = createGamesContent()
    else
        currentContentFrame = createEmptyContent(tabName)
    end
    
    for otherTabName, otherTabButton in pairs(tabButtons) do
        if otherTabName ~= tabName then
            otherTabButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
            otherTabButton.TextColor3 = Color3.fromRGB(180, 180, 180)
            local stroke = otherTabButton:FindFirstChild("UIStroke")
            if stroke then
                stroke.Color = Color3.fromRGB(50, 50, 50)
            end
        else
            tabButtons[tabName].BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            tabButtons[tabName].TextColor3 = Color3.fromRGB(255, 255, 255)
            local stroke = tabButtons[tabName]:FindFirstChild("UIStroke")
            if stroke then
                stroke.Color = Color3.fromRGB(80, 80, 80)
            end
        end
    end
end

-- Переменные для перемещения GUI
local isDragging = false
local dragStart
local startPos

-- Функция для включения/выключения перемещения
local function setupDragging(frame, handle)
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    
    handle.InputChanged:Connect(function(input)
        if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    handle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = false
        end
    end)
end

-- Настройка перемещения для основного контейнера
setupDragging(mainContainer, topBar)

-- Настройка перемещения для кнопки OPEN на мобильных
if isMobile and openButton then
    setupDragging(openButton, openButton)
end

local function showMenu()
    if isMenuOpen then return end
    isMenuOpen = true
    
    blockGameControls()
    
    -- Центрируем меню при открытии
    mainContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
    mainContainer.Visible = true
    background.Visible = true
    
    if isMobile and openButton then
        openButton.Visible = false
    end
    
    -- Показываем кнопки вкладок
    for _, tabButton in pairs(tabButtons) do
        tabButton.Visible = true
    end
    
    -- Создаем контент
    showTabContent("Games")
end

local function hideMenu()
    if not isMenuOpen then return end
    
    mainContainer.Visible = false
    background.Visible = false
    
    -- Показываем кнопку OPEN на мобильных
    if isMobile and openButton then
        openButton.Visible = true
    end
    
    -- Скрываем кнопки вкладок
    for _, tabButton in pairs(tabButtons) do
        tabButton.Visible = false
    end
    
    if currentContentFrame then
        currentContentFrame:Destroy()
        currentContentFrame = nil
    end
    
    isMenuOpen = false
    restoreGameControls()
end

local function toggleMenu()
    if isMenuOpen then
        hideMenu()
    else
        showMenu()
    end
end

-- Назначаем обработчики кликов на вкладки
for tabName, tabButton in pairs(tabButtons) do
    tabButton.MouseButton1Down:Connect(function()
        if isMenuOpen then
            showTabContent(tabName)
        end
    end)
end

-- Обработчик для кнопки закрытия на мобильных
if closeButton then
    closeButton.MouseButton1Down:Connect(function()
        hideMenu()
    end)
end

-- Обработчик для кнопки открытия на мобильных
if isMobile and openButton then
    openButton.MouseButton1Down:Connect(function()
        showMenu()
    end)
end

-- Hotkeys для ПК
if not isMobile and UserInputService.MouseEnabled then
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Enum.KeyCode.M then
            toggleMenu()
        end
        
        if input.KeyCode == Enum.KeyCode.Escape and isMenuOpen then
            hideMenu()
        end
    end)
end

-- Автоматически показываем меню через 1.5 секунды
task.spawn(function()
    task.wait(1.5)
    showMenu()
end)

print("DevShift GUI loaded successfully")
