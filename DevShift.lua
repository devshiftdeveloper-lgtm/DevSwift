local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local GuiService = game:GetService("GuiService")

if not game:IsLoaded() then
    return
end

if not RunService:IsClient() and not RunService:IsStudio() then
    return
end

local originalMouseIconEnabled = UserInputService.MouseIconEnabled
local isMenuOpen = false

local function blockGameControls()
    UserInputService.MouseIconEnabled = true
    GuiService:SetMenuIsOpen(true)
    
    if CoreGui:FindFirstChild("RobloxGui") then
        local robloxGui = CoreGui:FindFirstChild("RobloxGui")
        if robloxGui then
            local escapeMenu = robloxGui:FindFirstChild("EscapeMenu")
            if escapeMenu then
                escapeMenu.Enabled = false
            end
        end
    end
end

local function restoreGameControls()
    UserInputService.MouseIconEnabled = originalMouseIconEnabled
    GuiService:SetMenuIsOpen(false)
    
    if CoreGui:FindFirstChild("RobloxGui") then
        local robloxGui = CoreGui:FindFirstChild("RobloxGui")
        if robloxGui then
            local escapeMenu = robloxGui:FindFirstChild("EscapeMenu")
            if escapeMenu then
                escapeMenu.Enabled = true
            end
        end
    end
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DevShiftGUI"
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 999999
screenGui.IgnoreGuiInset = true
screenGui.Parent = CoreGui

local blurEffect = Instance.new("BlurEffect")
blurEffect.Size = 0
blurEffect.Enabled = false
blurEffect.Parent = game:GetService("Lighting")

local background = Instance.new("Frame")
background.Name = "Background"
background.Size = UDim2.new(1, 0, 1, 0)
background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
background.BackgroundTransparency = 0.85
background.BorderSizePixel = 0
background.ZIndex = 1
background.Visible = false
background.Parent = screenGui

local mainContainer = Instance.new("Frame")
mainContainer.Name = "MainContainer"
mainContainer.Size = UDim2.new(0, 700, 0, 500)
mainContainer.AnchorPoint = Vector2.new(0.5, 0.5)
mainContainer.Position = UDim2.new(0.5, 0, 0.5, -100)
mainContainer.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
mainContainer.BackgroundTransparency = 1
mainContainer.BorderSizePixel = 0
mainContainer.ZIndex = 100
mainContainer.Visible = false
mainContainer.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 20)
corner.Parent = mainContainer

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(60, 60, 60)
mainStroke.Thickness = 2.5
mainStroke.Transparency = 1
mainStroke.LineJoinMode = Enum.LineJoinMode.Round
mainStroke.Parent = mainContainer

local mainGlow = Instance.new("ImageLabel")
mainGlow.Name = "MainGlow"
mainGlow.Size = UDim2.new(1, 24, 1, 24)
mainGlow.Position = UDim2.new(0, -12, 0, -12)
mainGlow.BackgroundTransparency = 1
mainGlow.Image = "rbxassetid://5554236805"
mainGlow.ImageColor3 = Color3.fromRGB(40, 40, 40)
mainGlow.ImageTransparency = 1
mainGlow.ScaleType = Enum.ScaleType.Slice
mainGlow.SliceCenter = Rect.new(23, 23, 277, 277)
mainGlow.ZIndex = 99
mainGlow.Parent = mainContainer

local innerBackground = Instance.new("Frame")
innerBackground.Size = UDim2.new(1, -12, 1, -12)
innerBackground.Position = UDim2.new(0, 6, 0, 6)
innerBackground.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
innerBackground.BackgroundTransparency = 0.6
innerBackground.BorderSizePixel = 0
innerBackground.ZIndex = 98
innerBackground.Parent = mainContainer

local innerCorner = Instance.new("UICorner")
innerCorner.CornerRadius = UDim.new(0, 16)
innerCorner.Parent = innerBackground

local contentContainer = Instance.new("Frame")
contentContainer.Size = UDim2.new(1, -24, 1, -24)
contentContainer.Position = UDim2.new(0, 12, 0, 12)
contentContainer.BackgroundTransparency = 1
contentContainer.ZIndex = 101
contentContainer.Parent = mainContainer

local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 60)
topBar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
topBar.BackgroundTransparency = 1
topBar.BorderSizePixel = 0
topBar.ZIndex = 102
topBar.Parent = contentContainer

local topBarCorner = Instance.new("UICorner")
topBarCorner.CornerRadius = UDim.new(0, 12)
topBarCorner.Parent = topBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(0, 300, 0, 40)
titleLabel.Position = UDim2.new(0.5, -150, 0.5, -20)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "DevShift 1.0"
titleLabel.TextColor3 = Color3.fromRGB(250, 250, 250)
titleLabel.TextSize = 30
titleLabel.Font = Enum.Font.GothamBlack
titleLabel.TextTransparency = 1
titleLabel.TextXAlignment = Enum.TextXAlignment.Center
titleLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
titleLabel.TextStrokeTransparency = 0.3
titleLabel.ZIndex = 103
titleLabel.Parent = topBar

local mainContent = Instance.new("Frame")
mainContent.Size = UDim2.new(1, 0, 1, -70)
mainContent.Position = UDim2.new(0, 0, 0, 70)
mainContent.BackgroundTransparency = 1
mainContent.ZIndex = 101
mainContent.Parent = contentContainer

local tabsContainer = Instance.new("Frame")
tabsContainer.Size = UDim2.new(0.3, -10, 1, 0)
tabsContainer.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
tabsContainer.BackgroundTransparency = 1
tabsContainer.BorderSizePixel = 0
tabsContainer.ZIndex = 102
tabsContainer.Parent = mainContent

local tabsCorner = Instance.new("UICorner")
tabsCorner.CornerRadius = UDim.new(0, 12)
tabsCorner.Parent = tabsContainer

local tabsList = Instance.new("ScrollingFrame")
tabsList.Size = UDim2.new(1, -10, 1, -20)
tabsList.Position = UDim2.new(0, 5, 0, 10)
tabsList.BackgroundTransparency = 1
tabsList.BorderSizePixel = 0
tabsList.ScrollBarThickness = 4
tabsList.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 60)
tabsList.ZIndex = 103
tabsList.Parent = tabsContainer

local tabsListLayout = Instance.new("UIListLayout")
tabsListLayout.Padding = UDim.new(0, 10)
tabsListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
tabsListLayout.Parent = tabsList

local functionsContainer = Instance.new("Frame")
functionsContainer.Size = UDim2.new(0.7, -10, 1, 0)
functionsContainer.Position = UDim2.new(0.3, 10, 0, 0)
functionsContainer.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
functionsContainer.BackgroundTransparency = 1
functionsContainer.BorderSizePixel = 0
functionsContainer.ZIndex = 102
functionsContainer.Parent = mainContent

local functionsCorner = Instance.new("UICorner")
functionsCorner.CornerRadius = UDim.new(0, 12)
functionsCorner.Parent = functionsContainer

local functionsContent = Instance.new("Frame")
functionsContent.Size = UDim2.new(1, -20, 1, -20)
functionsContent.Position = UDim2.new(0, 10, 0, 10)
functionsContent.BackgroundTransparency = 1
functionsContent.ZIndex = 103
functionsContent.Parent = functionsContainer

local function createTabButton(tabName)
    local tabButton = Instance.new("TextButton")
    tabButton.Name = tabName .. "Tab"
    tabButton.Size = UDim2.new(1, 0, 0, 50)
    tabButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    tabButton.BackgroundTransparency = 1
    tabButton.BorderSizePixel = 0
    tabButton.Text = tabName
    tabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    tabButton.TextSize = 20
    tabButton.Font = Enum.Font.GothamMedium
    tabButton.TextTransparency = 1
    tabButton.ZIndex = 104
    tabButton.AutoButtonColor = false
    tabButton.Parent = tabsList
    
    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 10)
    tabCorner.Parent = tabButton
    
    local tabStroke = Instance.new("UIStroke")
    tabStroke.Color = Color3.fromRGB(60, 60, 60)
    tabStroke.Thickness = 2
    tabStroke.Transparency = 1
    tabStroke.Parent = tabButton
    
    return tabButton
end

local tabNames = {"Games", "Combat", "Misc", "Guards", "Settings"}
local tabButtons = {}

for i, tabName in ipairs(tabNames) do
    local tabButton = createTabButton(tabName)
    tabButtons[tabName] = tabButton
    
    tabButton.MouseButton1Click:Connect(function()
        functionsContent:ClearAllChildren()
        
        local comingSoon = Instance.new("TextLabel")
        comingSoon.Size = UDim2.new(1, 0, 0.5, 0)
        comingSoon.Position = UDim2.new(0, 0, 0.25, 0)
        comingSoon.BackgroundTransparency = 1
        comingSoon.Text = "Coming Soon..."
        comingSoon.TextColor3 = Color3.fromRGB(150, 150, 150)
        comingSoon.TextSize = 32
        comingSoon.Font = Enum.Font.GothamMedium
        comingSoon.TextXAlignment = Enum.TextXAlignment.Center
        comingSoon.TextYAlignment = Enum.TextYAlignment.Center
        comingSoon.ZIndex = 104
        comingSoon.Parent = functionsContent
        
        local description = Instance.new("TextLabel")
        description.Size = UDim2.new(1, 0, 0, 40)
        description.Position = UDim2.new(0, 0, 0.5, 10)
        description.BackgroundTransparency = 1
        description.Text = tabName .. " features will be available soon"
        description.TextColor3 = Color3.fromRGB(120, 120, 120)
        description.TextSize = 20
        description.Font = Enum.Font.Gotham
        description.TextXAlignment = Enum.TextXAlignment.Center
        description.ZIndex = 104
        description.Parent = functionsContent
    end)
end

local function showMenu()
    if isMenuOpen then return end
    isMenuOpen = true
    
    blockGameControls()
    
    mainContainer.Visible = true
    background.Visible = true
    
    local blurTween = TweenService:Create(blurEffect, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {
        Size = 16
    })
    blurTween:Play()
    blurEffect.Enabled = true
    
    local bgTween = TweenService:Create(background, TweenInfo.new(0.4), {
        BackgroundTransparency = 0.7
    })
    bgTween:Play()
    
    task.wait(0.1)
    local containerTween = TweenService:Create(mainContainer, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, 0, 0.5, 0),
        BackgroundTransparency = 0
    })
    containerTween:Play()
    
    local strokeTween = TweenService:Create(mainStroke, TweenInfo.new(0.5), {
        Transparency = 0
    })
    strokeTween:Play()
    
    local glowTween = TweenService:Create(mainGlow, TweenInfo.new(0.4), {
        ImageTransparency = 0.5
    })
    glowTween:Play()
    
    task.wait(0.2)
    local titleTween = TweenService:Create(titleLabel, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        TextTransparency = 0
    })
    titleTween:Play()
    
    local topBarTween = TweenService:Create(topBar, TweenInfo.new(0.4), {
        BackgroundTransparency = 0
    })
    topBarTween:Play()
    
    task.wait(0.15)
    local tabsTween = TweenService:Create(tabsContainer, TweenInfo.new(0.4), {
        BackgroundTransparency = 0
    })
    tabsTween:Play()
    
    local functionsTween = TweenService:Create(functionsContainer, TweenInfo.new(0.4), {
        BackgroundTransparency = 0
    })
    functionsTween:Play()
    
    task.wait(0.1)
    for tabName, tabButton in pairs(tabButtons) do
        task.wait(0.05)
        local tabTween = TweenService:Create(tabButton, TweenInfo.new(0.3), {
            BackgroundTransparency = 0,
            TextTransparency = 0
        })
        tabTween:Play()
        
        local strokeTween = TweenService:Create(tabButton:FindFirstChild("UIStroke"), TweenInfo.new(0.3), {
            Transparency = 0
        })
        strokeTween:Play()
    end
    
    if tabButtons["Games"] then
        tabButtons["Games"]:MouseButton1Click()
    end
end

local function hideMenu()
    if not isMenuOpen then return end
    
    local titleTween = TweenService:Create(titleLabel, TweenInfo.new(0.3), {
        TextTransparency = 1
    })
    titleTween:Play()
    
    local topBarTween = TweenService:Create(topBar, TweenInfo.new(0.3), {
        BackgroundTransparency = 1
    })
    topBarTween:Play()
    
    for tabName, tabButton in pairs(tabButtons) do
        local tabTween = TweenService:Create(tabButton, TweenInfo.new(0.3), {
            BackgroundTransparency = 1,
            TextTransparency = 1
        })
        tabTween:Play()
        
        local strokeTween = TweenService:Create(tabButton:FindFirstChild("UIStroke"), TweenInfo.new(0.3), {
            Transparency = 1
        })
        strokeTween:Play()
    end
    
    local tabsTween = TweenService:Create(tabsContainer, TweenInfo.new(0.3), {
        BackgroundTransparency = 1
    })
    tabsTween:Play()
    
    local functionsTween = TweenService:Create(functionsContainer, TweenInfo.new(0.3), {
        BackgroundTransparency = 1
    })
    functionsTween:Play()
    
    task.wait(0.2)
    local containerTween = TweenService:Create(mainContainer, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Position = UDim2.new(0.5, 0, 0.5, 100),
        BackgroundTransparency = 1
    })
    containerTween:Play()
    
    local strokeTween = TweenService:Create(mainStroke, TweenInfo.new(0.3), {
        Transparency = 1
    })
    strokeTween:Play()
    
    local glowTween = TweenService:Create(mainGlow, TweenInfo.new(0.3), {
        ImageTransparency = 1
    })
    glowTween:Play()
    
    local bgTween = TweenService:Create(background, TweenInfo.new(0.4), {
        BackgroundTransparency = 0.85
    })
    bgTween:Play()
    
    local blurTween = TweenService:Create(blurEffect, TweenInfo.new(0.4), {
        Size = 0
    })
    blurTween:Play()
    
    containerTween.Completed:Wait()
    
    task.wait(0.2)
    blurEffect.Enabled = false
    
    mainContainer.Visible = false
    background.Visible = false
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

if UserInputService.MouseEnabled then
    for tabName, tabButton in pairs(tabButtons) do
        tabButton.MouseEnter:Connect(function()
            local hoverTween = TweenService:Create(tabButton, TweenInfo.new(0.15), {
                BackgroundColor3 = Color3.fromRGB(35, 35, 35),
                Size = UDim2.new(1, 2, 0, 52)
            })
            hoverTween:Play()
            
            local stroke = tabButton:FindFirstChild("UIStroke")
            if stroke then
                local strokeTween = TweenService:Create(stroke, TweenInfo.new(0.15), {
                    Color = Color3.fromRGB(100, 100, 100),
                    Thickness = 2.2
                })
                strokeTween:Play()
            end
        end)
        
        tabButton.MouseLeave:Connect(function()
            local leaveTween = TweenService:Create(tabButton, TweenInfo.new(0.15), {
                BackgroundColor3 = Color3.fromRGB(25, 25, 25),
                Size = UDim2.new(1, 0, 0, 50)
            })
            leaveTween:Play()
            
            local stroke = tabButton:FindFirstChild("UIStroke")
            if stroke then
                local strokeTween = TweenService:Create(stroke, TweenInfo.new(0.15), {
                    Color = Color3.fromRGB(60, 60, 60),
                    Thickness = 2
                })
                strokeTween:Play()
            end
        end)
        
        tabButton.MouseButton1Down:Connect(function()
            local pressTween = TweenService:Create(tabButton, TweenInfo.new(0.1), {
                BackgroundColor3 = Color3.fromRGB(20, 20, 20),
                Size = UDim2.new(1, -2, 0, 48)
            })
            pressTween:Play()
        end)
        
        tabButton.MouseButton1Up:Connect(function()
            local releaseTween = TweenService:Create(tabButton, TweenInfo.new(0.1), {
                BackgroundColor3 = Color3.fromRGB(35, 35, 35),
                Size = UDim2.new(1, 2, 0, 52)
            })
            releaseTween:Play()
        end)
    end
end

local isTyping = false

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.M then
        local textBoxFocused = false
        
        local guis = CoreGui:GetGuiObjectsAtPosition(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)
        for _, gui in ipairs(guis) do
            if gui:IsA("TextBox") then
                textBoxFocused = true
                break
            end
        end
        
        if not textBoxFocused then
            toggleMenu()
        end
    end
end)

showMenu()
print("DevShift loaded successfully")
