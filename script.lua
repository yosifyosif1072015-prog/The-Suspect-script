-- The Suspect Script by yosifyosif (Fixed UI Visibility Version)
-- Features: Detect Killer, Detect Citizens, Speed Control, Range Control, Invisibility with Kill
-- FIX: Replaced deprecated .Draggable with modern UI Dragging to ensure UI opens properly!

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = newChar:WaitForChild("Humanoid")
    rootPart = newChar:WaitForChild("HumanoidRootPart")
end)

local Config = {
    speedEnabled = false,
    currentSpeed = 50,
    rangeEnabled = false,
    currentRange = 50,
    invisibilityEnabled = false,
    killerDetectRadius = 100,
    citizenDetectRadius = 100,
    uiVisible = true
}

local toggleButtons = {}

-- إنشاء واجهة العرض والتأكد من إضافتها فوق كل شيء
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SuspectGui_Fixed"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true -- تضمن عدم تأثر الواجهة بأبعاد الشاشة العلوية
screenGui.DisplayOrder = 999 -- تجعل اللوحة تظهر فوق أي واجهة أخرى باللعبة
screenGui.Parent = player:WaitForChild("PlayerGui")

-- اللوحة الرئيسية بالأبعاد والألوان المطلوبة منك بدقة
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 300, 0, 220)
mainFrame.Position = UDim2.new(0.1, 0, 0.3, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.Active = true
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 6)
mainCorner.Parent = mainFrame

-- شريط علوي صغير لتسهيل السحب والتحريك وضمان عدم التداخل
local titleBar = Instance.new("TextLabel")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
titleBar.TextColor3 = Color3.fromRGB(255, 255, 255)
titleBar.TextSize = 12
titleBar.Font = Enum.Font.GothamBold
titleBar.Text = "  🎮 THE SUSPECT SCRIPT"
titleBar.XAlignment = Enum.TextXAlignment.Left
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 6)
titleCorner.Parent = titleBar

-- حاوية العناصر الداخلية القابلة للتمرير بسلاسة
local containerFrame = Instance.new("ScrollingFrame")
containerFrame.Name = "Container"
containerFrame.Size = UDim2.new(1, -10, 1, -35)
containerFrame.Position = UDim2.new(0, 5, 0, 35)
containerFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
containerFrame.BorderSizePixel = 0
containerFrame.CanvasSize = UDim2.new(0, 0, 0, 480)
containerFrame.ScrollBarThickness = 4
containerFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 140)
containerFrame.Parent = mainFrame

local layout = Instance.new("UIListLayout")
layout.Parent = containerFrame
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 5)

-- دالات التصميم المساعد والديناميكي للواجهة
local function createSectionTitle(text, order)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -6, 0, 22)
    label.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    label.TextColor3 = Color3.fromRGB(0, 255, 140)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 10
    label.Text = "  " .. text
    label.XAlignment = Enum.TextXAlignment.Left
    label.LayoutOrder = order
    label.Parent = containerFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = label
end

local function createButton(text, order, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -6, 0, 28)
    button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.GothamMedium
    button.TextSize = 11
    button.Text = text
    button.LayoutOrder = order
    button.Parent = containerFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = button
    button.MouseButton1Click:Connect(callback)
end

local function createToggleButton(text, configKey, order, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -6, 0, 28)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 11
    button.LayoutOrder = order
    button.Parent = containerFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = button
    
    table.insert(toggleButtons, {button = button, configKey = configKey, baseText = text})
    
    button.MouseButton1Click:Connect(function()
        Config[configKey] = not Config[configKey]
        callback(Config[configKey])
        updateToggleButtonColors()
    end)
end

local function createNumberInput(placeholder, order, onInputChanged)
    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(1, -6, 0, 28)
    textBox.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    textBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 130)
    textBox.PlaceholderText = placeholder
    textBox.Font = Enum.Font.Gotham
    textBox.TextSize = 11
    textBox.Text = ""
    textBox.ClearTextOnFocus = true
    textBox.LayoutOrder = order
    textBox.Parent = containerFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = textBox
    
    textBox.FocusLost:Connect(function(enterPressed)
        local value = tonumber(textBox.Text)
        if value then onInputChanged(value) end
    end)
end

function updateToggleButtonColors()
    for _, data in ipairs(toggleButtons) do
        local state = Config[data.configKey]
        if state then
            data.button.BackgroundColor3 = Color3.fromRGB(0, 150, 80)
            data.button.Text = data.baseText .. " [ON]"
        else
            data.button.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
            data.button.Text = data.baseText .. " [OFF]"
        end
    end
end

-- ====================================================================
-- 🚀 نظام تحريك اللوحة الحديث والسلس (بديلاً عن الإصدار التالف القديم)
-- ====================================================================
local dragging, dragInput, dragStart, startPos
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- زر الاختفاء والإظهار السريع للوحة المفاتيح بالكامل عن طريق زر (RightControl)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.RightControl then
        Config.uiVisible = not Config.uiVisible
        mainFrame.Visible = Config.uiVisible
    end
end)

-- ====================================================================
-- بناء الوظائف والأزرار التفاعلية
-- ====================================================================

createSectionTitle("🕵️ DETECTION SYSTEM", 1)
createButton("Detect Killer", 2, function()
    local found = false
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (p.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude
            if dist <= Config.killerDetectRadius then
                print("⚠️ KILLER DETECTED: " .. p.Name .. " [" .. math.floor(dist) .. "m]")
                found = true
            end
        end
    end
    if not found then print("✅ Area Clear.") end
end)

createButton("Detect Citizens", 3, function()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (p.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude
            if dist <= Config.citizenDetectRadius then
                print("👥 Citizen: " .. p.Name .. " [" .. math.floor(dist) .. "m]")
            end
        end
    end
end)

createSectionTitle("⚡ MOVEMENT SPEED", 4)
createToggleButton("Toggle Speed", "speedEnabled", 5, function(state)
    if not state and humanoid then humanoid.WalkSpeed = 16 end
end)
createNumberInput("Enter Speed (Default: 50)...", 6, function(value)
    Config.currentSpeed = math.clamp(value, 16, 250)
end)

RunService.Stepped:Connect(function()
    if Config.speedEnabled and humanoid then humanoid.WalkSpeed = Config.currentSpeed end
end)

createSectionTitle("🎯 RANGE CONTROL", 7)
createToggleButton("Toggle Range", "rangeEnabled", 8, function(state) end)
createNumberInput("Enter Max Attack Range...", 9, function(value) Config.currentRange = value end)

createSectionTitle("👻 STEALTH MODE", 10)
local savedParts = {}
createToggleButton("Invisibility with Kill", "invisibilityEnabled", 11, function(state)
    if state then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") or part:IsA("Decal") then
                if part.Name ~= "HumanoidRootPart" then
