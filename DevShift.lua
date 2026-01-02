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

local originalMouseIconEnabled = UserInputService.MouseIconEnabled
local isMenuOpen = false
local isMobile = UserInputService.TouchEnabled

-- Функции блокировки управления
local function blockGameControls()
    if not isMobile then
        UserInputService.MouseIconEnabled = true
        GuiService:SetMenuIsOpen(true)
    end
    
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
    if not isMobile then
        UserInputService.MouseIconEnabled = originalMouseIconEnabled
        GuiService:SetMenuIsOpen(false)
    end
    
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

-- Создание основного GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DevShiftGUI"
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 50
screenGui.IgnoreGuiInset = true
screenGui.Parent = CoreGui

-- Эффект размытия
local blurEffect = Instance.new("BlurEffect")
blurEffect.Size = 0
blurEffect.Enabled = false
blurEffect.Parent = game:GetService("Lighting")

-- Фон
local background = Instance.new("Frame")
background.Name = "Background"
background.Size = UDim2.new(1, 0, 1, 0)
background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
background.BackgroundTransparency = 0.85
background.BorderSizePixel = 0
background.ZIndex = 1
background.Visible = false
background.Parent = screenGui

-- Основной контейнер (увеличен на 20%)
local mainContainer = Instance.new("Frame")
mainContainer.Name = "MainContainer"
mainContainer.Size = isMobile and UDim2.new(0.9, 0, 0.85, 0) or UDim2.new(0, 840, 0, 600)
mainContainer.AnchorPoint = Vector2.new(0.5, 0.5)
mainContainer.Position = UDim2.new(0.5, 0, 0.5, -100)
mainContainer.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
mainContainer.BackgroundTransparency = 1
mainContainer.BorderSizePixel = 0
mainContainer.ZIndex = 10
mainContainer.Visible = false
mainContainer.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, isMobile and 15 or 20)
corner.Parent = mainContainer

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(50, 50, 50)
mainStroke.Thickness = isMobile and 2 or 2.5
mainStroke.Transparency = 1
mainStroke.LineJoinMode = Enum.LineJoinMode.Round
mainStroke.Parent = mainContainer

local mainGlow = Instance.new("ImageLabel")
mainGlow.Name = "MainGlow"
mainGlow.Size = UDim2.new(1, 24, 1, 24)
mainGlow.Position = UDim2.new(0, -12, 0, -12)
mainGlow.BackgroundTransparency = 1
mainGlow.Image = "rbxassetid://5554236805"
mainGlow.ImageColor3 = Color3.fromRGB(30, 30, 30)
mainGlow.ImageTransparency = 1
mainGlow.ScaleType = Enum.ScaleType.Slice
mainGlow.SliceCenter = Rect.new(23, 23, 277, 277)
mainGlow.ZIndex = 9
mainGlow.Parent = mainContainer

-- Внутренний фон
local innerBackground = Instance.new("Frame")
innerBackground.Size = UDim2.new(1, -12, 1, -12)
innerBackground.Position = UDim2.new(0, 6, 0, 6)
innerBackground.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
innerBackground.BackgroundTransparency = 0.6
innerBackground.BorderSizePixel = 0
innerBackground.ZIndex = 8
innerBackground.Parent = mainContainer

local innerCorner = Instance.new("UICorner")
innerCorner.CornerRadius = UDim.new(0, isMobile and 12 or 16)
innerCorner.Parent = innerBackground

-- Контейнер контента
local contentContainer = Instance.new("Frame")
contentContainer.Size = UDim2.new(1, -24, 1, -24)
contentContainer.Position = UDim2.new(0, 12, 0, 12)
contentContainer.BackgroundTransparency = 1
contentContainer.ZIndex = 11
contentContainer.Parent = mainContainer

-- Верхняя панель
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, isMobile and 50 or 60)
topBar.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
topBar.BackgroundTransparency = 1
topBar.BorderSizePixel = 0
topBar.ZIndex = 12
topBar.Parent = contentContainer

local topBarCorner = Instance.new("UICorner")
topBarCorner.CornerRadius = UDim.new(0, isMobile and 10 or 12)
topBarCorner.Parent = topBar

-- Заголовок
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = isMobile and UDim2.new(1, -60, 0, isMobile and 35 or 40) or UDim2.new(1, 0, 0, isMobile and 35 or 40)
titleLabel.Position = isMobile and UDim2.new(0, 20, 0.5, 0) or UDim2.new(0.5, 0, 0.5, 0)
titleLabel.AnchorPoint = isMobile and Vector2.new(0, 0.5) or Vector2.new(0.5, 0.5)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "DevShift 1.0"
titleLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
titleLabel.TextSize = isMobile and 28 or 30
titleLabel.Font = isMobile and Enum.Font.GothamBlack or Enum.Font.GothamBlack
titleLabel.TextTransparency = 1
titleLabel.TextXAlignment = isMobile and Enum.TextXAlignment.Left or Enum.TextXAlignment.Center
titleLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
titleLabel.TextStrokeTransparency = 0.3
titleLabel.ZIndex = 13
titleLabel.Parent = topBar

-- Кнопка закрытия (только для мобильных)
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 40, 0, 40)
closeButton.Position = UDim2.new(1, -45, 0.5, -20)
closeButton.AnchorPoint = Vector2.new(1, 0.5)
closeButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
closeButton.BackgroundTransparency = 1
closeButton.BorderSizePixel = 0
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(220, 220, 220)
closeButton.TextSize = 20
closeButton.Font = Enum.Font.GothamBold
closeButton.TextTransparency = 1
closeButton.ZIndex = 13
closeButton.AutoButtonColor = false
closeButton.Visible = isMobile -- Только на мобильных
closeButton.Parent = topBar

local closeButtonCorner = Instance.new("UICorner")
closeButtonCorner.CornerRadius = UDim.new(0, 8)
closeButtonCorner.Parent = closeButton

local closeButtonStroke = Instance.new("UIStroke")
closeButtonStroke.Color = Color3.fromRGB(60, 60, 60)
closeButtonStroke.Thickness = 2
closeButtonStroke.Transparency = 1
closeButtonStroke.Parent = closeButton

-- Основной контент
local mainContent = Instance.new("Frame")
mainContent.Size = UDim2.new(1, 0, 1, -(isMobile and 60 or 70))
mainContent.Position = UDim2.new(0, 0, 0, isMobile and 60 or 70)
mainContent.BackgroundTransparency = 1
mainContent.ZIndex = 11
mainContent.Parent = contentContainer

-- Контейнер вкладок
local tabsContainer = Instance.new("Frame")
tabsContainer.Size = isMobile and UDim2.new(1, 0, 0.25, 0) or UDim2.new(0.3, -10, 1, 0)
tabsContainer.Position = isMobile and UDim2.new(0, 0, 0, 0) or UDim2.new(0, 0, 0, 0)
tabsContainer.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
tabsContainer.BackgroundTransparency = 1
tabsContainer.BorderSizePixel = 0
tabsContainer.ZIndex = 12
tabsContainer.Parent = mainContent

local tabsCorner = Instance.new("UICorner")
tabsCorner.CornerRadius = UDim.new(0, isMobile and 10 or 12)
tabsCorner.Parent = tabsContainer

-- Контейнер для кнопок вкладок
local tabsList = Instance.new("Frame")
tabsList.Name = "TabsList"
tabsList.Size = isMobile and UDim2.new(1, -10, 1, -10) or UDim2.new(1, -10, 1, -20)
tabsList.Position = isMobile and UDim2.new(0, 5, 0, 5) or UDim2.new(0, 5, 0, 10)
tabsList.BackgroundTransparency = 1
tabsList.BorderSizePixel = 0
tabsList.ZIndex = 13
tabsList.Parent = tabsContainer

-- Layout для вкладок
local tabsListLayout = Instance.new("UIListLayout")
tabsListLayout.Padding = isMobile and UDim.new(0, 8) or UDim.new(0, 10)
tabsListLayout.HorizontalAlignment = isMobile and Enum.HorizontalAlignment.Center or Enum.HorizontalAlignment.Center
tabsListLayout.VerticalAlignment = isMobile and Enum.VerticalAlignment.Center or Enum.VerticalAlignment.Top
tabsListLayout.FillDirection = isMobile and Enum.FillDirection.Horizontal or Enum.FillDirection.Vertical
tabsListLayout.Parent = tabsList

-- Контейнер функций
local functionsContainer = Instance.new("Frame")
functionsContainer.Size = isMobile and UDim2.new(1, 0, 0.75, -10) or UDim2.new(0.7, -10, 1, 0)
functionsContainer.Position = isMobile and UDim2.new(0, 0, 0.25, 10) or UDim2.new(0.3, 10, 0, 0)
functionsContainer.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
functionsContainer.BackgroundTransparency = 1
functionsContainer.BorderSizePixel = 0
functionsContainer.ZIndex = 12
functionsContainer.Parent = mainContent

local functionsCorner = Instance.new("UICorner")
functionsCorner.CornerRadius = UDim.new(0, isMobile and 10 or 12)
functionsCorner.Parent = functionsContainer

local functionsContent = Instance.new("Frame")
functionsContent.Size = UDim2.new(1, -20, 1, -20)
functionsContent.Position = UDim2.new(0, 10, 0, 10)
functionsContent.BackgroundTransparency = 1
functionsContent.ZIndex = 13
functionsContent.Parent = functionsContainer

-- Кнопка открытия на мобильных
local openButton = Instance.new("TextButton")
openButton.Name = "OpenButton"
openButton.Size = UDim2.new(0, isMobile and 70 or 0, 0, isMobile and 70 or 0)
openButton.Position = UDim2.new(0, isMobile and 20 or 0, 1, isMobile and -90 or 0)
openButton.AnchorPoint = Vector2.new(0, 1)
openButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
openButton.BackgroundTransparency = 0.4
openButton.BorderSizePixel = 0
openButton.Text = "OPEN"
openButton.TextColor3 = Color3.fromRGB(240, 240, 240)
openButton.TextSize = isMobile and 18 or 0
openButton.Font = Enum.Font.GothamBold
openButton.Visible = isMobile
openButton.ZIndex = 100
openButton.Parent = screenGui

local openButtonCorner = Instance.new("UICorner")
openButtonCorner.CornerRadius = UDim.new(1, 0)
openButtonCorner.Parent = openButton

local openButtonStroke = Instance.new("UIStroke")
openButtonStroke.Color = Color3.fromRGB(60, 60, 60)
openButtonStroke.Thickness = 3
openButtonStroke.Parent = openButton

-- Функция создания кнопки вкладки
local function createTabButton(tabName)
    local tabButton = Instance.new("TextButton")
    tabButton.Name = tabName .. "Tab"
    tabButton.Size = isMobile and UDim2.new(0, 110, 0, 45) or UDim2.new(1, 0, 0, 55)
    tabButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    tabButton.BackgroundTransparency = 1
    tabButton.BorderSizePixel = 0
    tabButton.Text = tabName
    tabButton.TextColor3 = Color3.fromRGB(220, 220, 220)
    tabButton.TextSize = isMobile and 18 or 22
    tabButton.Font = isMobile and Enum.Font.GothamMedium or Enum.Font.GothamMedium
    tabButton.TextTransparency = 1
    tabButton.ZIndex = 14
    tabButton.AutoButtonColor = false
    tabButton.Parent = tabsList
    
    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, isMobile and 8 or 10)
    tabCorner.Parent = tabButton
    
    local tabStroke = Instance.new("UIStroke")
    tabStroke.Color = Color3.fromRGB(50, 50, 50)
    tabStroke.Thickness = isMobile and 1.5 or 2.5
    tabStroke.Transparency = 1
    tabStroke.Parent = tabButton
    
    return tabButton
end

-- Создание вкладок
local tabNames = {"Games", "Combat", "Misc", "Guards", "Settings"}
local tabButtons = {}

for i, tabName in ipairs(tabNames) do
    local tabButton = createTabButton(tabName)
    tabButtons[tabName] = tabButton
end

-- Функция показа контента вкладки
local function showTabContent(tabName)
    functionsContent:ClearAllChildren()
    
    local comingSoon = Instance.new("TextLabel")
    comingSoon.Size = UDim2.new(1, 0, 0.5, 0)
    comingSoon.Position = UDim2.new(0, 0, 0.25, 0)
    comingSoon.BackgroundTransparency = 1
    comingSoon.Text = "Coming Soon..."
    comingSoon.TextColor3 = Color3.fromRGB(150, 150, 150)
    comingSoon.TextSize = isMobile and 28 or 36
    comingSoon.Font = Enum.Font.GothamMedium
    comingSoon.TextXAlignment = Enum.TextXAlignment.Center
    comingSoon.TextYAlignment = Enum.TextYAlignment.Center
    comingSoon.ZIndex = 14
    comingSoon.Parent = functionsContent
    
    local description = Instance.new("TextLabel")
    description.Size = UDim2.new(1, 0, 0, isMobile and 35 or 45)
    description.Position = UDim2.new(0, 0, 0.5, 15)
    description.BackgroundTransparency = 1
    description.Text = tabName .. " features will be available soon"
    description.TextColor3 = Color3.fromRGB(120, 120, 120)
    description.TextSize = isMobile and 16 or 22
    description.Font = Enum.Font.Gotham
    description.TextXAlignment = Enum.TextXAlignment.Center
    description.ZIndex = 14
    description.Parent = functionsContent
end

-- Функция показа меню
local function showMenu()
    if isMenuOpen then return end
    isMenuOpen = true
    
    blockGameControls()
    
    mainContainer.Visible = true
    background.Visible = true
    if isMobile then
        openButton.Visible = false
    end
    
    local blurTween = TweenService:Create(blurEffect, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {
        Size = isMobile and 8 or 16
    })
    blurTween:Play()
    blurEffect.Enabled = true
    
    local bgTween = TweenService:Create(background, TweenInfo.new(0.4), {
        BackgroundTransparency = isMobile and 0.8 or 0.7
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
    
    -- Кнопка закрытия (только для мобильных)
    if isMobile then
        local closeTween = TweenService:Create(closeButton, TweenInfo.new(0.4), {
            BackgroundTransparency = 0,
            TextTransparency = 0
        })
        closeTween:Play()
        
        local closeStrokeTween = TweenService:Create(closeButtonStroke, TweenInfo.new(0.4), {
            Transparency = 0
        })
        closeStrokeTween:Play()
    end
    
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
        
        local stroke = tabButton:FindFirstChild("UIStroke")
        if stroke then
            local strokeTween = TweenService:Create(stroke, TweenInfo.new(0.3), {
                Transparency = 0
            })
            strokeTween:Play()
        end
    end
    
    -- Показываем первую вкладку
    if tabButtons["Games"] then
        showTabContent("Games")
    end
end

-- Функция скрытия меню
local function hideMenu()
    if not isMenuOpen then return end
    
    local titleTween = TweenService:Create(titleLabel, TweenInfo.new(0.3), {
        TextTransparency = 1
    })
    titleTween:Play()
    
    if isMobile then
        local closeTween = TweenService:Create(closeButton, TweenInfo.new(0.3), {
            BackgroundTransparency = 1,
            TextTransparency = 1
        })
        closeTween:Play()
        
        local closeStrokeTween = TweenService:Create(closeButtonStroke, TweenInfo.new(0.3), {
            Transparency = 1
        })
        closeStrokeTween:Play()
    end
    
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
        
        local stroke = tabButton:FindFirstChild("UIStroke")
        if stroke then
            local strokeTween = TweenService:Create(stroke, TweenInfo.new(0.3), {
                Transparency = 1
            })
            strokeTween:Play()
        end
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
    if isMobile then
        openButton.Visible = true
    end
    isMenuOpen = false
    
    restoreGameControls()
end

-- Функция переключения меню
local function toggleMenu()
    if isMenuOpen then
        hideMenu()
    else
        showMenu()
    end
end

-- Обработчики событий для мобильных устройств
if isMobile then
    openButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            toggleMenu()
        end
    end)
    
    -- Анимация нажатия кнопки OPEN
    openButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            local pressTween = TweenService:Create(openButton, TweenInfo.new(0.1), {
                BackgroundTransparency = 0.6,
                Size = UDim2.new(0, 65, 0, 65)
            })
            pressTween:Play()
            
            local strokeTween = TweenService:Create(openButtonStroke, TweenInfo.new(0.1), {
                Thickness = 2
            })
            strokeTween:Play()
        end
    end)
    
    openButton.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            local releaseTween = TweenService:Create(openButton, TweenInfo.new(0.1), {
                BackgroundTransparency = 0.4,
                Size = UDim2.new(0, 70, 0, 70)
            })
            releaseTween:Play()
            
            local strokeTween = TweenService:Create(openButtonStroke, TweenInfo.new(0.1), {
                Thickness = 3
            })
            strokeTween:Play()
        end
    end)
    
    -- Анимация кнопки X для мобильных
    closeButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            local pressTween = TweenService:Create(closeButton, TweenInfo.new(0.1), {
                BackgroundColor3 = Color3.fromRGB(35, 35, 35),
                Size = UDim2.new(0, 38, 0, 38)
            })
            pressTween:Play()
            
            local strokeTween = TweenService:Create(closeButtonStroke, TweenInfo.new(0.1), {
                Color = Color3.fromRGB(100, 100, 100)
            })
            strokeTween:Play()
        end
    end)
    
    closeButton.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            local releaseTween = TweenService:Create(closeButton, TweenInfo.new(0.1), {
                BackgroundColor3 = Color3.fromRGB(25, 25, 25),
                Size = UDim2.new(0, 40, 0, 40)
            })
            releaseTween:Play()
            
            local strokeTween = TweenService:Create(closeButtonStroke, TweenInfo.new(0.1), {
                Color = Color3.fromRGB(60, 60, 60)
            })
            strokeTween:Play()
            
            hideMenu()
        end
    end)
end

-- Обработчики событий для вкладок
for tabName, tabButton in pairs(tabButtons) do
    tabButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            showTabContent(tabName)
        end
    end)
end

-- Обработчики для ПК
if not isMobile and UserInputService.MouseEnabled then
    -- Анимация вкладок на ПК
    for tabName, tabButton in pairs(tabButtons) do
        tabButton.MouseEnter:Connect(function()
            local hoverTween = TweenService:Create(tabButton, TweenInfo.new(0.15), {
                BackgroundColor3 = Color3.fromRGB(35, 35, 35),
                Size = UDim2.new(1, 2, 0, 57)
            })
            hoverTween:Play()
            
            local stroke = tabButton:FindFirstChild("UIStroke")
            if stroke then
                local strokeTween = TweenService:Create(stroke, TweenInfo.new(0.15), {
                    Color = Color3.fromRGB(100, 100, 100),
                    Thickness = 2.8
                })
                strokeTween:Play()
            end
        end)
        
        tabButton.MouseLeave:Connect(function()
            local leaveTween = TweenService:Create(tabButton, TweenInfo.new(0.15), {
                BackgroundColor3 = Color3.fromRGB(20, 20, 20),
                Size = UDim2.new(1, 0, 0, 55)
            })
            leaveTween:Play()
            
            local stroke = tabButton:FindFirstChild("UIStroke")
            if stroke then
                local strokeTween = TweenService:Create(stroke, TweenInfo.new(0.15), {
                    Color = Color3.fromRGB(50, 50, 50),
                    Thickness = 2.5
                })
                strokeTween:Play()
            end
        end)
        
        tabButton.MouseButton1Down:Connect(function()
            local pressTween = TweenService:Create(tabButton, TweenInfo.new(0.1), {
                BackgroundColor3 = Color3.fromRGB(15, 15, 15),
                Size = UDim2.new(1, -2, 0, 53)
            })
            pressTween:Play()
        end)
        
        tabButton.MouseButton1Up:Connect(function()
            local releaseTween = TweenService:Create(tabButton, TweenInfo.new(0.1), {
                BackgroundColor3 = Color3.fromRGB(35, 35, 35),
                Size = UDim2.new(1, 2, 0, 57)
            })
            releaseTween:Play()
        end)
    end
    
    -- Обработка клавиши M для закрытия меню
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Enum.KeyCode.M then
            -- Проверяем, находится ли пользователь в текстовом поле
            local textBoxFocused = false
            
            local mousePos = UserInputService:GetMouseLocation()
            local guis = CoreGui:GetGuiObjectsAtPosition(mousePos.X, mousePos.Y)
            
            for _, gui in ipairs(guis) do
                if gui:IsA("TextBox") and gui:IsFocused() then
                    textBoxFocused = true
                    break
                end
            end
            
            if not textBoxFocused then
                toggleMenu()
            end
        end
        
        -- ESC для закрытия меню
        if input.KeyCode == Enum.KeyCode.Escape and isMenuOpen then
            hideMenu()
        end
    end)
end

-- Меню автоматически открывается при запуске
task.spawn(function()
    task.wait(1) -- Небольшая задержка для загрузки
    showMenu()
end)

if isMobile then
    openButton.Visible = true
end

print("DevShift loaded successfully")
