-- DevShift GUI - Advanced Roblox Executor Interface
-- Проверка выполнения в Roblox
if not game:IsLoaded() then
    return
end

-- Проверка, что мы в Roblox
if not game:GetService("RunService"):IsStudio() and not game:GetService("RunService"):IsClient() then
    return
end

-- Основные сервисы
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TextService = game:GetService("TextService")

-- Проверка мобильного устройства
local isMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled
local isDesktop = UserInputService.MouseEnabled

-- Создание основного GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DevShiftGUI"
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 999

if RunService:IsClient() then
    screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
else
    screenGui.Parent = game:GetService("CoreGui")
end

-- Функция создания анимированных элементов
local function createParticleEffect(parent, position)
    local particle = Instance.new("Frame")
    particle.Size = UDim2.new(0, 8, 0, 8)
    particle.Position = position
    particle.AnchorPoint = Vector2.new(0.5, 0.5)
    particle.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    particle.BackgroundTransparency = 0.3
    particle.BorderSizePixel = 0
    particle.ZIndex = 10
    particle.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = particle
    
    local glow = Instance.new("UIStroke")
    glow.Color = Color3.fromRGB(0, 200, 255)
    glow.Thickness = 2
    glow.Transparency = 0.5
    glow.Parent = particle
    
    local tweenInfo = TweenInfo.new(
        0.8,
        Enum.EasingStyle.Quint,
        Enum.EasingDirection.Out,
        0,
        false,
        0
    )
    
    local tween1 = TweenService:Create(particle, tweenInfo, {
        Size = UDim2.new(0, 20, 0, 20),
        BackgroundTransparency = 1,
        Rotation = 45
    })
    
    local tween2 = TweenService:Create(glow, tweenInfo, {
        Transparency = 1,
        Thickness = 0
    })
    
    tween1:Play()
    tween2:Play()
    
    tween1.Completed:Connect(function()
        particle:Destroy()
    end)
    
    return particle
end

-- Функция пульсации
local function pulseAnimation(frame)
    local tweenInfo = TweenInfo.new(
        0.5,
        Enum.EasingStyle.Sine,
        Enum.EasingDirection.InOut,
        -1,
        true,
        0
    )
    
    local tween = TweenService:Create(frame, tweenInfo, {
        Size = UDim2.new(0.22, 0, 0.07, 0)
    })
    
    tween:Play()
    return tween
end

-- Создание фонового блюра
local background = Instance.new("Frame")
background.Size = UDim2.new(1, 0, 1, 0)
background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
background.BackgroundTransparency = 0.7
background.BorderSizePixel = 0
background.ZIndex = 1
background.Parent = screenGui

-- Анимация появления фона
local bgTween = TweenService:Create(background, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {
    BackgroundTransparency = 0.4
})
bgTween:Play()

-- Основной контейнер
local mainContainer = Instance.new("Frame")
mainContainer.Size = UDim2.new(0, 400, 0, 500)
mainContainer.AnchorPoint = Vector2.new(0.5, 0.5)
mainContainer.Position = UDim2.new(0.5, 0, 0.5, -50)
mainContainer.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
mainContainer.BackgroundTransparency = 1
mainContainer.BorderSizePixel = 0
mainContainer.ZIndex = 2
mainContainer.Parent = screenGui

-- Скругление углов
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainContainer

-- Обводка с градиентом
local gradientStroke = Instance.new("UIStroke")
gradientStroke.Color = Color3.fromRGB(40, 40, 60)
gradientStroke.Thickness = 2
gradientStroke.Parent = mainContainer

-- Внутренняя тень
local innerShadow = Instance.new("Frame")
innerShadow.Size = UDim2.new(1, 0, 1, 0)
innerShadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
innerShadow.BackgroundTransparency = 0.9
innerShadow.BorderSizePixel = 0
innerShadow.ZIndex = 3
innerShadow.Parent = mainContainer

local innerCorner = Instance.new("UICorner")
innerCorner.CornerRadius = UDim.new(0, 12)
innerCorner.Parent = innerShadow

-- Заголовок DevShift с анимацией
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 80)
titleLabel.Position = UDim2.new(0, 0, 0, -100)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "DevShift"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = isMobile and 36 or 48
titleLabel.Font = Enum.Font.GothamBlack
titleLabel.TextTransparency = 1
titleLabel.ZIndex = 4
titleLabel.Parent = mainContainer

-- Подзаголовок
local subtitleLabel = Instance.new("TextLabel")
subtitleLabel.Size = UDim2.new(1, 0, 0, 30)
subtitleLabel.Position = UDim2.new(0, 0, 0, -40)
subtitleLabel.BackgroundTransparency = 1
subtitleLabel.Text = "Premium Roblox Executor"
subtitleLabel.TextColor3 = Color3.fromRGB(180, 180, 220)
subtitleLabel.TextSize = isMobile and 16 or 18
subtitleLabel.Font = Enum.Font.GothamMedium
subtitleLabel.TextTransparency = 1
subtitleLabel.ZIndex = 4
subtitleLabel.Parent = mainContainer

-- Контейнер для поля ввода
local inputContainer = Instance.new("Frame")
inputContainer.Size = UDim2.new(0.8, 0, 0, 60)
inputContainer.AnchorPoint = Vector2.new(0.5, 0)
inputContainer.Position = UDim2.new(0.5, 0, 0.4, 0)
inputContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
inputContainer.BackgroundTransparency = 1
inputContainer.BorderSizePixel = 0
inputContainer.ZIndex = 4
inputContainer.Parent = mainContainer

local inputCorner = Instance.new("UICorner")
inputCorner.CornerRadius = UDim.new(0, 8)
inputCorner.Parent = inputContainer

local inputStroke = Instance.new("UIStroke")
inputStroke.Color = Color3.fromRGB(50, 50, 70)
inputStroke.Thickness = 2
inputStroke.Parent = inputContainer

-- Поле ввода ключа
local keyInput = Instance.new("TextBox")
keyInput.Size = UDim2.new(1, -20, 1, -10)
keyInput.Position = UDim2.new(0, 10, 0, 5)
keyInput.BackgroundTransparency = 1
keyInput.Text = ""
keyInput.PlaceholderText = "Enter your license key..."
keyInput.PlaceholderColor3 = Color3.fromRGB(100, 100, 130)
keyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
keyInput.TextSize = isMobile and 18 or 20
keyInput.Font = Enum.Font.Gotham
keyInput.TextXAlignment = Enum.TextXAlignment.Left
keyInput.ClearTextOnFocus = false
keyInput.ZIndex = 5
keyInput.Parent = inputContainer

-- Кнопка Verify
local verifyButton = Instance.new("TextButton")
verifyButton.Size = UDim2.new(0.6, 0, 0, 55)
verifyButton.AnchorPoint = Vector2.new(0.5, 0)
verifyButton.Position = UDim2.new(0.5, 0, 0.6, 0)
verifyButton.BackgroundColor3 = Color3.fromRGB(0, 100, 255)
verifyButton.BackgroundTransparency = 1
verifyButton.BorderSizePixel = 0
verifyButton.Text = "VERIFY KEY"
verifyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
verifyButton.TextSize = isMobile and 18 or 22
verifyButton.Font = Enum.Font.GothamBold
verifyButton.TextTransparency = 1
verifyButton.ZIndex = 4
verifyButton.AutoButtonColor = false
verifyButton.Parent = mainContainer

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 8)
buttonCorner.Parent = verifyButton

local buttonStroke = Instance.new("UIStroke")
buttonStroke.Color = Color3.fromRGB(0, 150, 255)
buttonStroke.Thickness = 2
buttonStroke.Transparency = 1
buttonStroke.Parent = verifyButton

-- Индикатор загрузки
local loadingFrame = Instance.new("Frame")
loadingFrame.Size = UDim2.new(0, 0, 0, 4)
loadingFrame.AnchorPoint = Vector2.new(0, 1)
loadingFrame.Position = UDim2.new(0.5, 0, 1, -10)
loadingFrame.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
loadingFrame.BorderSizePixel = 0
loadingFrame.Visible = false
loadingFrame.ZIndex = 5
loadingFrame.Parent = mainContainer

local loadingCorner = Instance.new("UICorner")
loadingCorner.CornerRadius = UDim.new(1, 0)
loadingCorner.Parent = loadingFrame

-- Сообщение об ошибке
local errorLabel = Instance.new("TextLabel")
errorLabel.Size = UDim2.new(0.8, 0, 0, 40)
errorLabel.AnchorPoint = Vector2.new(0.5, 0)
errorLabel.Position = UDim2.new(0.5, 0, 0.75, 0)
errorLabel.BackgroundTransparency = 1
errorLabel.Text = ""
errorLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
errorLabel.TextSize = isMobile and 14 or 16
errorLabel.Font = Enum.Font.Gotham
errorLabel.TextTransparency = 1
errorLabel.ZIndex = 4
errorLabel.Parent = mainContainer

-- Анимация появления
local function animateEntrance()
    -- Появление контейнера
    local containerTween = TweenService:Create(mainContainer, TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0.2), {
        Position = UDim2.new(0.5, 0, 0.5, 0),
        BackgroundTransparency = 0
    })
    containerTween:Play()
    
    -- Появление обводки
    local strokeTween = TweenService:Create(gradientStroke, TweenInfo.new(0.8, Enum.EasingStyle.Quad), {
        Color = Color3.fromRGB(0, 150, 255)
    })
    strokeTween:Play()
    
    -- Появление заголовка
    local titleTween = TweenService:Create(titleLabel, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {
        TextTransparency = 0,
        Position = UDim2.new(0, 0, 0, 30)
    })
    titleTween:Play()
    
    -- Появление подзаголовка с задержкой
    task.wait(0.3)
    local subtitleTween = TweenService:Create(subtitleLabel, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {
        TextTransparency = 0,
        Position = UDim2.new(0, 0, 0, 80)
    })
    subtitleTween:Play()
    
    -- Появление поля ввода
    task.wait(0.2)
    local inputTween = TweenService:Create(inputContainer, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
        BackgroundTransparency = 0
    })
    inputTween:Play()
    
    -- Появление кнопки
    task.wait(0.1)
    local buttonTween = TweenService:Create(verifyButton, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
        BackgroundTransparency = 0,
        TextTransparency = 0
    })
    buttonTween:Play()
    
    local buttonStrokeTween = TweenService:Create(buttonStroke, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
        Transparency = 0
    })
    buttonStrokeTween:Play()
    
    -- Создание частиц
    spawn(function()
        for i = 1, 15 do
            local x = math.random(-200, 200)
            local y = math.random(-250, 250)
            createParticleEffect(mainContainer, UDim2.new(0.5, x, 0.5, y))
            task.wait(0.1)
        end
    end)
end

-- Анимация исчезновения
local function animateExit()
    -- Исчезновение кнопки
    local buttonTween = TweenService:Create(verifyButton, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
        BackgroundTransparency = 1,
        TextTransparency = 1
    })
    buttonTween:Play()
    
    local buttonStrokeTween = TweenService:Create(buttonStroke, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
        Transparency = 1
    })
    buttonStrokeTween:Play()
    
    -- Исчезновение поля ввода
    local inputTween = TweenService:Create(inputContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
        BackgroundTransparency = 1
    })
    inputTween:Play()
    
    -- Исчезновение текстов
    local subtitleTween = TweenService:Create(subtitleLabel, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
        TextTransparency = 1,
        Position = UDim2.new(0, 0, 0, -40)
    })
    subtitleTween:Play()
    
    local titleTween = TweenService:Create(titleLabel, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
        TextTransparency = 1,
        Position = UDim2.new(0, 0, 0, -100)
    })
    titleTween:Play()
    
    -- Исчезновение контейнера
    task.wait(0.2)
    local containerTween = TweenService:Create(mainContainer, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Position = UDim2.new(0.5, 0, 0.5, 50),
        BackgroundTransparency = 1
    })
    containerTween:Play()
    
    -- Исчезновение фона
    local bgTween = TweenService:Create(background, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
        BackgroundTransparency = 1
    })
    bgTween:Play()
    
    containerTween.Completed:Wait()
    screenGui:Destroy()
end

-- Функция проверки ключа
local function verifyKey(key)
    -- Здесь будет ваша логика проверки ключа
    -- Для примера, допустим правильный ключ: "DEVSHIFT-2024-PREMIUM"
    
    local validKeys = {
        "DEVSHIFT-2024-PREMIUM",
        "DEVSHIFT-PRO-ACCESS",
        "DEVSHIFT-VIP-KEY",
        "TEST-KEY-12345"
    }
    
    for _, validKey in ipairs(validKeys) do
        if key == validKey then
            return true
        end
    end
    
    return false
end

-- Функция загрузки Keyless.lua
local function loadKeylessScript()
    -- Здесь должна быть ваша логика загрузки Keyless.lua
    -- Например:
    
    print("[DevShift] Loading Keyless.lua...")
    
    -- Симуляция загрузки скрипта
    local fakeLoad = function()
        -- Ваш код Keyless.lua будет здесь
        print("[DevShift] Keyless.lua loaded successfully!")
        
        -- Пример функционала executor
        local DevShift = {
            Execute = function(code)
                loadstring(code)()
            end,
            
            GetScripts = function()
                return {"Script 1", "Script 2", "Script 3"}
            end
        }
        
        return DevShift
    end
    
    -- Создаем глобальный объект DevShift
    getfenv().DevShift = fakeLoad()
    
    print("[DevShift] Ready to execute scripts!")
end

-- Обработчики событий для кнопки
local isVerifying = false

verifyButton.MouseButton1Click:Connect(function()
    if isVerifying then return end
    
    local key = keyInput.Text:gsub("%s+", "")
    
    if key == "" then
        -- Анимация ошибки для пустого поля
        errorLabel.Text = "Please enter a license key"
        
        local errorTween = TweenService:Create(errorLabel, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
            TextTransparency = 0
        })
        errorTween:Play()
        
        task.wait(2)
        
        local hideTween = TweenService:Create(errorLabel, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
            TextTransparency = 1
        })
        hideTween:Play()
        return
    end
    
    isVerifying = true
    loadingFrame.Visible = true
    
    -- Анимация загрузки
    local loadTween = TweenService:Create(loadingFrame, TweenInfo.new(1, Enum.EasingStyle.Linear), {
        Size = UDim2.new(0.8, 0, 0, 4),
        Position = UDim2.new(0.1, 0, 1, -10)
    })
    loadTween:Play()
    
    -- Симуляция проверки ключа
    task.wait(1.5)
    
    if verifyKey(key) then
        -- Успешная проверка
        errorLabel.TextColor3 = Color3.fromRGB(80, 255, 80)
        errorLabel.Text = "Key verified successfully!"
        
        local successTween = TweenService:Create(errorLabel, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
            TextTransparency = 0
        })
        successTween:Play()
        
        -- Анимация успеха для кнопки
        local buttonSuccessTween = TweenService:Create(verifyButton, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
            BackgroundColor3 = Color3.fromRGB(0, 200, 80)
        })
        buttonSuccessTween:Play()
        
        local strokeSuccessTween = TweenService:Create(buttonStroke, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
            Color = Color3.fromRGB(0, 255, 100)
        })
        strokeSuccessTween:Play()
        
        task.wait(1)
        
        -- Загрузка Keyless.lua
        loadKeylessScript()
        
        -- Анимация исчезновения GUI
        animateExit()
    else
        -- Неверный ключ
        errorLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
        errorLabel.Text = "Invalid license key. Please try again."
        
        local errorTween = TweenService:Create(errorLabel, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
            TextTransparency = 0
        })
        errorTween:Play()
        
        -- Анимация ошибки для кнопки
        local buttonErrorTween = TweenService:Create(verifyButton, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
            BackgroundColor3 = Color3.fromRGB(255, 60, 60)
        })
        buttonErrorTween:Play()
        
        local strokeErrorTween = TweenService:Create(buttonStroke, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
            Color = Color3.fromRGB(255, 100, 100)
        })
        strokeErrorTween:Play()
        
        -- Сброс анимации кнопки
        task.wait(1.5)
        
        local resetTween = TweenService:Create(verifyButton, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
            BackgroundColor3 = Color3.fromRGB(0, 100, 255)
        })
        resetTween:Play()
        
        local strokeResetTween = TweenService:Create(buttonStroke, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
            Color = Color3.fromRGB(0, 150, 255)
        })
        strokeResetTween:Play()
        
        local hideTween = TweenService:Create(errorLabel, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
            TextTransparency = 1
        })
        hideTween:Play()
        
        loadingFrame.Visible = false
        loadingFrame.Size = UDim2.new(0, 0, 0, 4)
        isVerifying = false
    end
end)

-- Анимация при наведении на кнопку (только для ПК)
if isDesktop then
    verifyButton.MouseEnter:Connect(function()
        if isVerifying then return end
        
        local hoverTween = TweenService:Create(verifyButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            BackgroundColor3 = Color3.fromRGB(0, 120, 255),
            Size = UDim2.new(0.62, 0, 0, 58)
        })
        hoverTween:Play()
    end)
    
    verifyButton.MouseLeave:Connect(function()
        if isVerifying then return end
        
        local leaveTween = TweenService:Create(verifyButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            BackgroundColor3 = Color3.fromRGB(0, 100, 255),
            Size = UDim2.new(0.6, 0, 0, 55)
        })
        leaveTween:Play()
    end)
end

-- Анимация при нажатии на кнопку
verifyButton.MouseButton1Down:Connect(function()
    if isVerifying then return end
    
    local pressTween = TweenService:Create(verifyButton, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
        BackgroundColor3 = Color3.fromRGB(0, 80, 220),
        Size = UDim2.new(0.58, 0, 0, 52)
    })
    pressTween:Play()
end)

verifyButton.MouseButton1Up:Connect(function()
    if isVerifying then return end
    
    local releaseTween = TweenService:Create(verifyButton, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
        BackgroundColor3 = Color3.fromRGB(0, 120, 255),
        Size = UDim2.new(0.6, 0, 0, 55)
    })
    releaseTween:Play()
end)

-- Запуск анимации входа
task.wait(0.5)
animateEntrance()

-- Адаптация для мобильных устройств
if isMobile then
    mainContainer.Size = UDim2.new(0, 350, 0, 450)
    keyInput.TextSize = 18
    verifyButton.TextSize = 20
    titleLabel.TextSize = 36
    subtitleLabel.TextSize = 16
end

-- Плавное закрытие по клавише ESC (только для ПК)
if isDesktop then
    UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == Enum.KeyCode.Escape then
            animateExit()
        end
    end)
end

print("[DevShift] GUI initialized successfully!")
