-- Main.lua - DevShift Functions Module
local MainModule = {}

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

-- Local Variables
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
end)

-- RLGL Functions
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

-- Dalgona Functions
function MainModule.Dalgona_Complete()
    task.spawn(function()
        local DalgonaClientModule = ReplicatedStorage:FindFirstChild("Modules") and
                                    ReplicatedStorage.Modules:FindFirstChild("Games") and
                                    ReplicatedStorage.Modules.Games:FindFirstChild("DalgonaClient")
        if not DalgonaClientModule then return end
        
        for _, func in pairs(debug.getregistry()) do
            if typeof(func) == "function" and islclosure(func) then
                local info = debug.getinfo(func)
                if info.nups == 76 then
                    debug.setupvalue(func, 33, 9999)
                    debug.setupvalue(func, 34, 9999)
                end
            end
        end
    end)
end

function MainModule.Dalgona_FreeLighter()
    LocalPlayer:SetAttribute("HasLighter", true)
end

-- Utility function to create buttons
function MainModule.CreateButton(buttonName, functionName, parentFrame)
    local button = Instance.new("TextButton")
    button.Name = buttonName
    button.Size = UDim2.new(1, -20, 0, 40)
    button.Position = UDim2.new(0, 10, 0, 0)
    button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    button.BorderSizePixel = 0
    button.Text = buttonName
    button.TextColor3 = Color3.fromRGB(240, 240, 240)
    button.TextSize = 16
    button.Font = Enum.Font.GothamMedium
    button.AutoButtonColor = true
    button.Parent = parentFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(60, 60, 60)
    stroke.Thickness = 2
    stroke.Parent = button
    
    -- Connect click event
    button.MouseButton1Click:Connect(function()
        if MainModule[functionName] then
            MainModule[functionName]()
        end
    end)
    
    return button
end

-- Function to create game section
function MainModule.CreateGameSection(gameName, functions, parentFrame)
    -- Game title
    local title = Instance.new("TextLabel")
    title.Name = gameName .. "Title"
    title.Size = UDim2.new(1, -20, 0, 35)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = gameName
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 22
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = parentFrame
    
    local titleStroke = Instance.new("UIStroke")
    titleStroke.Color = Color3.fromRGB(100, 100, 100)
    titleStroke.Thickness = 1
    titleStroke.Parent = title
    
    local yOffset = 40
    
    -- Create buttons for each function
    for i, funcInfo in ipairs(functions) do
        local button = MainModule.CreateButton(funcInfo.name, funcInfo.func, parentFrame)
        button.Position = UDim2.new(0, 10, 0, yOffset)
        yOffset = yOffset + 50
    end
    
    return yOffset + 20 -- Return next y position
end

-- Export module
return MainModule
