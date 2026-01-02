local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local GuiService = game:GetService("GuiService")
local HttpService = game:GetService("HttpService")

if not game:IsLoaded() then
    return
end

if not RunService:IsClient() and not RunService:IsStudio() then
    return
end

local originalMouseIconEnabled = UserInputService.MouseIconEnabled

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

local function copyToClipboard(text)
    if setclipboard then
        setclipboard(text)
        return true
    end
    return false
end

local function loadFromRepo()
    local success, result = pcall(function()
        -- Список необходимых файлов
        local scripts = {"DevShift.lua", "OtherModule.lua"}
        
        for _, scriptName in ipairs(scripts) do
            local content = game:HttpGet(scriptName, true)
            local func, err = loadstring(content)
            if func then
                local scriptSuccess, scriptErr = pcall(func)
                if not scriptSuccess then
                    warn("Ошибка в " .. scriptName .. ": " .. tostring(scriptErr))
                end
            else
                warn("Ошибка загрузки " .. scriptName .. ": " .. tostring(err))
            end
        end
        
        return true
    end)
    
    return success, result
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DevShiftGUI"
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 999999
screenGui.IgnoreGuiInset = true
screenGui.Parent = CoreGui

local customCursor = Instance.new("Frame")
customCursor.Name = "DevShiftCursor"
customCursor.Size = UDim2.new(0, 40, 0, 40)
customCursor.AnchorPoint = Vector2.new(0.5, 0.5)
customCursor.BackgroundTransparency = 1
customCursor.Visible = false
customCursor.ZIndex = 1000000
customCursor.Parent = screenGui

local lineLength = 16
local lineThickness = 3.5

local topLine = Instance.new("Frame")
topLine.Name = "TopLine"
topLine.Size = UDim2.new(0, lineThickness, 0, lineLength)
topLine.AnchorPoint = Vector2.new(0.5, 1)
topLine.Position = UDim2.new(0.5, 0, 0.5, -4)
topLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
topLine.BorderSizePixel = 0
topLine.ZIndex = 1000002
topLine.Parent = customCursor

local bottomLine = Instance.new("Frame")
bottomLine.Name = "BottomLine"
bottomLine.Size = UDim2.new(0, lineThickness, 0, lineLength)
bottomLine.AnchorPoint = Vector2.new(0.5, 0)
bottomLine.Position = UDim2.new(0.5, 0, 0.5, 4)
bottomLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
bottomLine.BorderSizePixel = 0
bottomLine.ZIndex = 1000002
bottomLine.Parent = customCursor

local leftLine = Instance.new("Frame")
leftLine.Name = "LeftLine"
leftLine.Size = UDim2.new(0, lineLength, 0, lineThickness)
leftLine.AnchorPoint = Vector2.new(1, 0.5)
leftLine.Position = UDim2.new(0.5, -4, 0.5, 0)
leftLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
leftLine.BorderSizePixel = 0
leftLine.ZIndex = 1000002
leftLine.Parent = customCursor

local rightLine = Instance.new("Frame")
rightLine.Name = "RightLine"
rightLine.Size = UDim2.new(0, lineLength, 0, lineThickness)
rightLine.AnchorPoint = Vector2.new(0, 0.5)
rightLine.Position = UDim2.new(0.5, 4, 0.5, 0)
rightLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
rightLine.BorderSizePixel = 0
rightLine.ZIndex = 1000002
rightLine.Parent = customCursor

local centerHole = Instance.new("Frame")
centerHole.Name = "CenterHole"
centerHole.Size = UDim2.new(0, 5, 0, 5)
centerHole.AnchorPoint = Vector2.new(0.5, 0.5)
centerHole.Position = UDim2.new(0.5, 0, 0.5, 0)
centerHole.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
centerHole.BorderSizePixel = 0
centerHole.ZIndex = 1000003
centerHole.Parent = customCursor

local holeCorner = Instance.new("UICorner")
holeCorner.CornerRadius = UDim.new(1, 0)
holeCorner.Parent = centerHole

local outerGlow = Instance.new("Frame")
outerGlow.Name = "OuterGlow"
outerGlow.Size = UDim2.new(0, 34, 0, 34)
outerGlow.AnchorPoint = Vector2.new(0.5, 0.5)
outerGlow.Position = UDim2.new(0.5, 0, 0.5, 0)
outerGlow.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
outerGlow.BackgroundTransparency = 0.9
outerGlow.BorderSizePixel = 0
outerGlow.ZIndex = 1000001
outerGlow.Parent = customCursor

local glowCorner = Instance.new("UICorner")
glowCorner.CornerRadius = UDim.new(1, 0)
glowCorner.Parent = outerGlow

local cursorText = Instance.new("TextLabel")
cursorText.Name = "CursorText"
cursorText.Size = UDim2.new(0, 60, 0, 14)
cursorText.AnchorPoint = Vector2.new(0.5, 0)
cursorText.BackgroundTransparency = 1
cursorText.Text = "DevShift"
cursorText.TextColor3 = Color3.fromRGB(220, 220, 220)
cursorText.TextSize = 10
cursorText.Font = Enum.Font.GothamBold
cursorText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
cursorText.TextStrokeTransparency = 0.3
cursorText.ZIndex = 1000001
cursorText.Visible = false
cursorText.Parent = screenGui

local cursorAngle = 0
local function updateCustomCursor()
    if not UserInputService.MouseEnabled then return end
    
    local mousePos = UserInputService:GetMouseLocation()
    customCursor.Position = UDim2.new(0, mousePos.X, 0, mousePos.Y)
    cursorText.Position = UDim2.new(0, mousePos.X - 30, 0, mousePos.Y + 22)
    
    cursorAngle = (cursorAngle + 2.5) % 360
    customCursor.Rotation = cursorAngle
    
    local pulse = math.abs(math.sin(os.clock() * 2)) * 0.2 + 0.8
    outerGlow.BackgroundTransparency = 0.9 - (pulse * 0.15)
    outerGlow.Size = UDim2.new(0, 32 + math.sin(os.clock() * 2) * 1.5, 
                                0, 32 + math.sin(os.clock() * 2) * 1.5)
    
    local lineBrightness = 0.7 + math.abs(math.sin(os.clock() * 3)) * 0.3
    local lineColor = Color3.fromRGB(255 * lineBrightness, 255 * lineBrightness, 255 * lineBrightness)
    topLine.BackgroundColor3 = lineColor
    bottomLine.BackgroundColor3 = lineColor
    leftLine.BackgroundColor3 = lineColor
    rightLine.BackgroundColor3 = lineColor
    
    customCursor.Visible = true
    cursorText.Visible = true
end

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
background.Parent = screenGui

local mainContainer = Instance.new("Frame")
mainContainer.Name = "MainContainer"
mainContainer.Size = UDim2.new(0, 520, 0, 520)
mainContainer.AnchorPoint = Vector2.new(0.5, 0.5)
mainContainer.Position = UDim2.new(0.5, 0, 0.5, -100)
mainContainer.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
mainContainer.BackgroundTransparency = 1
mainContainer.BorderSizePixel = 0
mainContainer.ZIndex = 100
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

local titleContainer = Instance.new("Frame")
titleContainer.Size = UDim2.new(1, 0, 0, 140)
titleContainer.Position = UDim2.new(0, 0, 0, 20)
titleContainer.BackgroundTransparency = 1
titleContainer.ZIndex = 101
titleContainer.Parent = contentContainer

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 80)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "DEVSHIFT"
titleLabel.TextColor3 = Color3.fromRGB(250, 250, 250)
titleLabel.TextSize = 52
titleLabel.Font = Enum.Font.GothamBlack
titleLabel.TextTransparency = 1
titleLabel.TextXAlignment = Enum.TextXAlignment.Center
titleLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
titleLabel.TextStrokeTransparency = 0.3
titleLabel.ZIndex = 101
titleLabel.Parent = titleContainer

local subtitleLabel = Instance.new("TextLabel")
subtitleLabel.Size = UDim2.new(1, 0, 0, 40)
subtitleLabel.Position = UDim2.new(0, 0, 0, 85)
subtitleLabel.BackgroundTransparency = 1
subtitleLabel.Text = "ENTER KEY"
subtitleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
subtitleLabel.TextSize = 22
subtitleLabel.Font = Enum.Font.GothamMedium
subtitleLabel.TextTransparency = 1
subtitleLabel.TextXAlignment = Enum.TextXAlignment.Center
subtitleLabel.ZIndex = 101
subtitleLabel.Parent = titleContainer

local inputContainer = Instance.new("Frame")
inputContainer.Size = UDim2.new(0.85, 0, 0, 60)
inputContainer.AnchorPoint = Vector2.new(0.5, 0)
inputContainer.Position = UDim2.new(0.5, 0, 0.42, 0)
inputContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
inputContainer.BackgroundTransparency = 1
inputContainer.BorderSizePixel = 0
inputContainer.ZIndex = 101
inputContainer.Parent = contentContainer

local inputCorner = Instance.new("UICorner")
inputCorner.CornerRadius = UDim.new(0, 14)
inputCorner.Parent = inputContainer

local inputStroke = Instance.new("UIStroke")
inputStroke.Color = Color3.fromRGB(70, 70, 70)
inputStroke.Thickness = 2.5
inputStroke.Transparency = 1
inputStroke.LineJoinMode = Enum.LineJoinMode.Round
inputStroke.Parent = inputContainer

local keyInput = Instance.new("TextBox")
keyInput.Size = UDim2.new(1, -24, 1, -12)
keyInput.Position = UDim2.new(0, 12, 0, 6)
keyInput.BackgroundTransparency = 1
keyInput.Text = ""
keyInput.PlaceholderText = "Enter your key..."
keyInput.PlaceholderColor3 = Color3.fromRGB(140, 140, 140)
keyInput.TextColor3 = Color3.fromRGB(250, 250, 250)
keyInput.TextSize = 22
keyInput.Font = Enum.Font.Gotham
keyInput.TextXAlignment = Enum.TextXAlignment.Center
keyInput.ClearTextOnFocus = false
keyInput.ZIndex = 102
keyInput.Parent = inputContainer

local verifyButton = Instance.new("TextButton")
verifyButton.Name = "VerifyButton"
verifyButton.Size = UDim2.new(0.75, 0, 0, 60)
verifyButton.AnchorPoint = Vector2.new(0.5, 0)
verifyButton.Position = UDim2.new(0.5, 0, 0.62, 0)
verifyButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
verifyButton.BackgroundTransparency = 1
verifyButton.BorderSizePixel = 0
verifyButton.Text = "VERIFY KEY"
verifyButton.TextColor3 = Color3.fromRGB(250, 250, 250)
verifyButton.TextSize = 24
verifyButton.Font = Enum.Font.GothamBold
verifyButton.TextTransparency = 1
verifyButton.ZIndex = 101
verifyButton.AutoButtonColor = false
verifyButton.Parent = contentContainer

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 14)
buttonCorner.Parent = verifyButton

local buttonStroke = Instance.new("UIStroke")
buttonStroke.Color = Color3.fromRGB(90, 90, 90)
buttonStroke.Thickness = 2.5
buttonStroke.Transparency = 1
buttonStroke.LineJoinMode = Enum.LineJoinMode.Round
buttonStroke.Parent = verifyButton

local getKeyButton = Instance.new("TextButton")
getKeyButton.Name = "GetKeyButton"
getKeyButton.Size = UDim2.new(0.38, 0, 0, 45)
getKeyButton.Position = UDim2.new(0.05, 0, 0.85, 0)
getKeyButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
getKeyButton.BackgroundTransparency = 1
getKeyButton.BorderSizePixel = 0
getKeyButton.Text = "GET KEY"
getKeyButton.TextColor3 = Color3.fromRGB(220, 220, 220)
getKeyButton.TextSize = 18
getKeyButton.Font = Enum.Font.GothamBold
getKeyButton.TextTransparency = 1
getKeyButton.ZIndex = 101
getKeyButton.AutoButtonColor = false
getKeyButton.Parent = contentContainer

local getKeyCorner = Instance.new("UICorner")
getKeyCorner.CornerRadius = UDim.new(0, 10)
getKeyCorner.Parent = getKeyButton

local getKeyStroke = Instance.new("UIStroke")
getKeyStroke.Color = Color3.fromRGB(100, 100, 100)
getKeyStroke.Thickness = 2
getKeyStroke.Transparency = 1
getKeyStroke.Parent = getKeyButton

local statusContainer = Instance.new("Frame")
statusContainer.Size = UDim2.new(0.85, 0, 0, 50)
statusContainer.AnchorPoint = Vector2.new(0.5, 0)
statusContainer.Position = UDim2.new(0.5, 0, 0.75, 0)
statusContainer.BackgroundTransparency = 1
statusContainer.ZIndex = 101
statusContainer.Parent = contentContainer

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 1, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = ""
statusLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
statusLabel.TextSize = 19
statusLabel.Font = Enum.Font.GothamMedium
statusLabel.TextTransparency = 1
statusLabel.TextXAlignment = Enum.TextXAlignment.Center
statusLabel.TextYAlignment = Enum.TextYAlignment.Center
statusLabel.ZIndex = 101
statusLabel.Parent = statusContainer

local loadingContainer = Instance.new("Frame")
loadingContainer.Size = UDim2.new(0.85, 0, 0, 40)
loadingContainer.AnchorPoint = Vector2.new(0.5, 0)
loadingContainer.Position = UDim2.new(0.5, 0, 0.75, 0)
loadingContainer.BackgroundTransparency = 1
loadingContainer.Visible = false
loadingContainer.ZIndex = 101
loadingContainer.Parent = contentContainer

local loadingDots = Instance.new("Frame")
loadingDots.Name = "LoadingDots"
loadingDots.Size = UDim2.new(0, 120, 0, 30)
loadingDots.AnchorPoint = Vector2.new(0.5, 0.5)
loadingDots.Position = UDim2.new(0.5, 0, 0.5, 0)
loadingDots.BackgroundTransparency = 1
loadingDots.Visible = false
loadingDots.ZIndex = 102
loadingDots.Parent = loadingContainer

local function createRippleEffect(parent, position)
    local ripple = Instance.new("Frame")
    ripple.Size = UDim2.new(0, 0, 0, 0)
    ripple.Position = position
    ripple.AnchorPoint = Vector2.new(0.5, 0.5)
    ripple.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    ripple.BackgroundTransparency = 0.8
    ripple.BorderSizePixel = 0
    ripple.ZIndex = 103
    ripple.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = ripple
    
    local tween = TweenService:Create(ripple, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {
        Size = UDim2.new(0, 110, 0, 110),
        BackgroundTransparency = 1
    })
    
    tween:Play()
    tween.Completed:Connect(function()
        ripple:Destroy()
    end)
end

local function animateEntrance()
    blockGameControls()
    
    local blurTween = TweenService:Create(blurEffect, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {
        Size = 16
    })
    blurTween:Play()
    blurEffect.Enabled = true
    
    local bgTween = TweenService:Create(background, TweenInfo.new(0.7), {
        BackgroundTransparency = 0.7
    })
    bgTween:Play()
    
    task.wait(0.1)
    local containerTween = TweenService:Create(mainContainer, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, 0, 0.5, 0),
        BackgroundTransparency = 0
    })
    containerTween:Play()
    
    local strokeTween = TweenService:Create(mainStroke, TweenInfo.new(0.6), {
        Transparency = 0
    })
    strokeTween:Play()
    
    local glowTween = TweenService:Create(mainGlow, TweenInfo.new(0.5), {
        ImageTransparency = 0.5
    })
    glowTween:Play()
    
    task.wait(0.2)
    local titleTween = TweenService:Create(titleLabel, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        TextTransparency = 0
    })
    titleTween:Play()
    
    task.wait(0.15)
    local subtitleTween = TweenService:Create(subtitleLabel, TweenInfo.new(0.4), {
        TextTransparency = 0.2
    })
    subtitleTween:Play()
    
    task.wait(0.1)
    local inputTween = TweenService:Create(inputContainer, TweenInfo.new(0.4), {
        BackgroundTransparency = 0
    })
    inputTween:Play()
    
    local inputStrokeTween = TweenService:Create(inputStroke, TweenInfo.new(0.4), {
        Transparency = 0
    })
    inputStrokeTween:Play()
    
    task.wait(0.1)
    local buttonTween = TweenService:Create(verifyButton, TweenInfo.new(0.4), {
        BackgroundTransparency = 0,
        TextTransparency = 0
    })
    buttonTween:Play()
    
    local buttonStrokeTween = TweenService:Create(buttonStroke, TweenInfo.new(0.4), {
        Transparency = 0
    })
    buttonStrokeTween:Play()
    
    task.wait(0.1)
    local getKeyTween = TweenService:Create(getKeyButton, TweenInfo.new(0.4), {
        BackgroundTransparency = 0,
        TextTransparency = 0
    })
    getKeyTween:Play()
    
    local getKeyStrokeTween = TweenService:Create(getKeyStroke, TweenInfo.new(0.4), {
        Transparency = 0
    })
    getKeyStrokeTween:Play()
    
    customCursor.Visible = true
    cursorText.Visible = true
end

local function showLoading()
    loadingContainer.Visible = true
    loadingDots.Visible = true
    loadingDots:ClearAllChildren()
    
    for i = 1, 3 do
        local dot = Instance.new("Frame")
        dot.Size = UDim2.new(0, 10, 0, 10)
        dot.Position = UDim2.new(0.25 * i, 0, 0.5, -5)
        dot.AnchorPoint = Vector2.new(0.5, 0.5)
        dot.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
        dot.BackgroundTransparency = 0
        dot.BorderSizePixel = 0
        dot.ZIndex = 102
        dot.Parent = loadingDots
        
        local dotCorner = Instance.new("UICorner")
        dotCorner.CornerRadius = UDim.new(1, 0)
        dotCorner.Parent = dot
        
        local animation = TweenService:Create(dot, TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, -1, true, i * 0.25), {
            BackgroundTransparency = 0.5,
            Size = UDim2.new(0, 12, 0, 12)
        })
        animation:Play()
    end
end

local function hideLoading()
    loadingContainer.Visible = false
    loadingDots.Visible = false
    loadingDots:ClearAllChildren()
end

local function showStatus(text, color)
    statusLabel.Text = text
    statusLabel.TextColor3 = color
    
    local showTween = TweenService:Create(statusLabel, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
        TextTransparency = 0
    })
    showTween:Play()
end

local function hideStatus()
    local hideTween = TweenService:Create(statusLabel, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
        TextTransparency = 1
    })
    hideTween:Play()
end

local function verifyKey(key)
    local trimmedKey = key:gsub("%s+", ""):upper()
    task.wait(3)
    return trimmedKey == "DEVSHIFT2026"
end

local function loadDevShiftScript()
    local success, result = pcall(function()
        local DevShift = {
            Version = "2026.1.1",
            Status = "Active",
            
            Execute = function(code)
                local func, err = loadstring(code)
                if func then
                    return pcall(func)
                else
                    return false, err
                end
            end,
            
            GetScripts = function()
                return {
                    "Infinite Yield",
                    "CMD-X",
                    "Dark Dex",
                    "Simple Spy",
                    "Remote Spy"
                }
            end,
            
            ClearConsole = function()
            end
        }
        
        getfenv().DevShift = DevShift
        
        return DevShift
    end)
    
    return success, result
end

local function animateExit()
    local titleTween = TweenService:Create(titleLabel, TweenInfo.new(0.3), {
        TextTransparency = 1
    })
    titleTween:Play()
    
    local subtitleTween = TweenService:Create(subtitleLabel, TweenInfo.new(0.3), {
        TextTransparency = 1
    })
    subtitleTween:Play()
    
    local inputTween = TweenService:Create(inputContainer, TweenInfo.new(0.3), {
        BackgroundTransparency = 1
    })
    inputTween:Play()
    
    local inputStrokeTween = TweenService:Create(inputStroke, TweenInfo.new(0.3), {
        Transparency = 1
    })
    inputStrokeTween:Play()
    
    local buttonTween = TweenService:Create(verifyButton, TweenInfo.new(0.3), {
        BackgroundTransparency = 1,
        TextTransparency = 1
    })
    buttonTween:Play()
    
    local buttonStrokeTween = TweenService:Create(buttonStroke, TweenInfo.new(0.3), {
        Transparency = 1
    })
    buttonStrokeTween:Play()
    
    local getKeyTween = TweenService:Create(getKeyButton, TweenInfo.new(0.3), {
        BackgroundTransparency = 1,
        TextTransparency = 1
    })
    getKeyTween:Play()
    
    local getKeyStrokeTween = TweenService:Create(getKeyStroke, TweenInfo.new(0.3), {
        Transparency = 1
    })
    getKeyStrokeTween:Play()
    
    hideStatus()
    
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
    
    mainContainer:Destroy()
    background:Destroy()
    restoreGameControls()
end

local isVerifying = false

verifyButton.MouseButton1Click:Connect(function()
    if isVerifying then return end
    
    local key = keyInput.Text
    local trimmedKey = key:gsub("%s+", "")
    
    if trimmedKey == "" then
        showStatus("Please enter a key", Color3.fromRGB(220, 100, 100))
        
        createRippleEffect(inputContainer, UDim2.new(0.5, 0, 0.5, 0))
        
        local shake1 = TweenService:Create(inputContainer, TweenInfo.new(0.06), {
            Position = UDim2.new(0.5, 6, 0.42, 0)
        })
        local shake2 = TweenService:Create(inputContainer, TweenInfo.new(0.06), {
            Position = UDim2.new(0.5, -6, 0.42, 0)
        })
        local shake3 = TweenService:Create(inputContainer, TweenInfo.new(0.06), {
            Position = UDim2.new(0.5, 0, 0.42, 0)
        })
        
        shake1:Play()
        shake1.Completed:Connect(function()
            shake2:Play()
            shake2.Completed:Connect(function()
                shake3:Play()
            end)
        end)
        
        task.wait(1.5)
        hideStatus()
        return
    end
    
    isVerifying = true
    
    createRippleEffect(verifyButton, UDim2.new(0.5, 0, 0.5, 0))
    
    local verifyingTween = TweenService:Create(verifyButton, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    })
    verifyingTween:Play()
    
    local buttonStrokeTween = TweenService:Create(buttonStroke, TweenInfo.new(0.2), {
        Color = Color3.fromRGB(130, 130, 130)
    })
    buttonStrokeTween:Play()
    
    showStatus("Verifying key...", Color3.fromRGB(220, 220, 220))
    showLoading()
    
    if verifyKey(trimmedKey) then
        hideLoading()
        
        showStatus("Key verified successfully!", Color3.fromRGB(100, 220, 100))
        
        local successButton = TweenService:Create(verifyButton, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(30, 50, 30)
        })
        successButton:Play()
        
        local successStroke = TweenService:Create(buttonStroke, TweenInfo.new(0.2), {
            Color = Color3.fromRGB(80, 180, 80)
        })
        successStroke:Play()
        
        task.wait(0.8)
        
        local loadSuccess = loadDevShiftScript()
        if loadSuccess then
            showStatus("DevShift loaded successfully!", Color3.fromRGB(100, 220, 100))
        else
            showStatus("Failed to load", Color3.fromRGB(220, 100, 100))
        end
        
        task.wait(1)
        
        animateExit()
    else
        hideLoading()
        
        showStatus("Invalid key", Color3.fromRGB(220, 100, 100))
        
        local errorButton = TweenService:Create(verifyButton, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(50, 30, 30)
        })
        errorButton:Play()
        
        local errorStroke = TweenService:Create(buttonStroke, TweenInfo.new(0.2), {
            Color = Color3.fromRGB(180, 80, 80)
        })
        errorStroke:Play()
        
        task.wait(1.5)
        
        local resetButton = TweenService:Create(verifyButton, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        })
        resetButton:Play()
        
        local resetStroke = TweenService:Create(buttonStroke, TweenInfo.new(0.2), {
            Color = Color3.fromRGB(90, 90, 90)
        })
        resetStroke:Play()
        
        hideStatus()
        isVerifying = false
    end
end)

getKeyButton.MouseButton1Click:Connect(function()
    createRippleEffect(getKeyButton, UDim2.new(0.5, 0, 0.5, 0))
    
    local discordLink = "https://discord.gg/nF5f3THe"
    
    if copyToClipboard(discordLink) then
        showStatus("Discord link copied!", Color3.fromRGB(180, 180, 220))
        
        local buttonClick = TweenService:Create(getKeyButton, TweenInfo.new(0.1), {
            BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        })
        buttonClick:Play()
        
        task.wait(0.1)
        
        local buttonReset = TweenService:Create(getKeyButton, TweenInfo.new(0.1), {
            BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        })
        buttonReset:Play()
        
        task.wait(1.5)
        hideStatus()
    else
        showStatus("Discord: nF5f3THe", Color3.fromRGB(180, 180, 220))
        task.wait(2)
        hideStatus()
    end
end)

task.spawn(function()
    task.wait(2)
    loadFromRepo()
end)

if UserInputService.MouseEnabled then
    verifyButton.MouseEnter:Connect(function()
        if isVerifying then return end
        
        local hoverTween = TweenService:Create(verifyButton, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.fromRGB(40, 40, 40),
            Size = UDim2.new(0.78, 0, 0, 62)
        })
        hoverTween:Play()
        
        local strokeTween = TweenService:Create(buttonStroke, TweenInfo.new(0.15), {
            Color = Color3.fromRGB(130, 130, 130),
            Thickness = 3
        })
        strokeTween:Play()
    end)
    
    verifyButton.MouseLeave:Connect(function()
        if isVerifying then return end
        
        local leaveTween = TweenService:Create(verifyButton, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.fromRGB(30, 30, 30),
            Size = UDim2.new(0.75, 0, 0, 60)
        })
        leaveTween:Play()
        
        local strokeTween = TweenService:Create(buttonStroke, TweenInfo.new(0.15), {
            Color = Color3.fromRGB(90, 90, 90),
            Thickness = 2.5
        })
        strokeTween:Play()
    end)
    
    verifyButton.MouseButton1Down:Connect(function()
        if isVerifying then return end
        
        local pressTween = TweenService:Create(verifyButton, TweenInfo.new(0.1), {
            BackgroundColor3 = Color3.fromRGB(25, 25, 25),
            Size = UDim2.new(0.73, 0, 0, 58)
        })
        pressTween:Play()
    end)
    
    verifyButton.MouseButton1Up:Connect(function()
        if isVerifying then return end
        
        local releaseTween = TweenService:Create(verifyButton, TweenInfo.new(0.1), {
            BackgroundColor3 = Color3.fromRGB(40, 40, 40),
            Size = UDim2.new(0.78, 0, 0, 62)
        })
        releaseTween:Play()
    end)
    
    getKeyButton.MouseEnter:Connect(function()
        local hoverTween = TweenService:Create(getKeyButton, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.fromRGB(45, 45, 45),
            Size = UDim2.new(0.40, 0, 0, 47)
        })
        hoverTween:Play()
        
        local strokeTween = TweenService:Create(getKeyStroke, TweenInfo.new(0.15), {
            Color = Color3.fromRGB(150, 150, 150),
            Thickness = 2.2
        })
        strokeTween:Play()
    end)
    
    getKeyButton.MouseLeave:Connect(function()
        local leaveTween = TweenService:Create(getKeyButton, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.fromRGB(35, 35, 35),
            Size = UDim2.new(0.38, 0, 0, 45)
        })
        leaveTween:Play()
        
        local strokeTween = TweenService:Create(getKeyStroke, TweenInfo.new(0.15), {
            Color = Color3.fromRGB(100, 100, 100),
            Thickness = 2
        })
        strokeTween:Play()
    end)
    
    getKeyButton.MouseButton1Down:Connect(function()
        local pressTween = TweenService:Create(getKeyButton, TweenInfo.new(0.1), {
            BackgroundColor3 = Color3.fromRGB(30, 30, 30),
            Size = UDim2.new(0.36, 0, 0, 43)
        })
        pressTween:Play()
    end)
    
    getKeyButton.MouseButton1Up:Connect(function()
        local releaseTween = TweenService:Create(getKeyButton, TweenInfo.new(0.1), {
            BackgroundColor3 = Color3.fromRGB(45, 45, 45),
            Size = UDim2.new(0.40, 0, 0, 47)
        })
        releaseTween:Play()
    end)
    
    keyInput.Focused:Connect(function()
        local focusTween = TweenService:Create(inputContainer, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        })
        focusTween:Play()
        
        local strokeTween = TweenService:Create(inputStroke, TweenInfo.new(0.15), {
            Color = Color3.fromRGB(130, 130, 130),
            Thickness = 3
        })
        strokeTween:Play()
    end)
    
    keyInput.FocusLost:Connect(function()
        local unfocusTween = TweenService:Create(inputContainer, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        })
        unfocusTween:Play()
        
        local strokeTween = TweenService:Create(inputStroke, TweenInfo.new(0.15), {
            Color = Color3.fromRGB(70, 70, 70),
            Thickness = 2.5
        })
        strokeTween:Play()
    end)
end

if UserInputService.MouseEnabled then
    RunService.RenderStepped:Connect(updateCustomCursor)
end

task.wait(1)
keyInput:CaptureFocus()

animateEntrance()
