-- The Suspect Script by yosifyosif (Enhanced GitHub Version)
-- Features: Detect Killer, Detect Citizens, Speed Control, Range Control, Invisibility with Kill
-- UPDATED: Added Draggable GUI + Fixed Invisibility Bug + Color Status Buttons + UI Toggle Key

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- تحديث الشخصية تلقائياً عند إعادة الرسبون
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = newChar:WaitForChild("Humanoid")
    rootPart = newChar:WaitForChild("HumanoidRootPart")
end)

-- الإعدادات الافتراضية
local Config = {
    speedEnabled = false,
    currentSpeed = 50,
    rangeEnabled = false,
    currentRange = 50,
    invisibilityEnabled = false,
    killerDetectRadius = 100,
    citizenDetectRadius = 100,
    uiVisible = true -- حالة ظهور اللوحة
}

local toggleButtons = {}

-- إنشاء الواجهة الأساسية
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SuspectGui_V2"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- تخصيص الإطار الرئيسي بناءً على طلبك المحدد بدقة
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 300, 0, 220) -- الحجم المطلوب
mainFrame.Position = UDim2.new(0.1, 0, 0.3, 0) -- الموضع المطلوب
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30) -- اللون المطلوب
mainFrame.Active = true -- تفعيل التفاعل
mainFrame.Draggable = true -- تفعيل السحب القديم المباشر
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- إضافة حواف دائرية ناعمة لجمالية التصميم
local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 8)
mainCorner.Parent = mainFrame

-- شريط العنوان العلوي
local titleBar = Instance.new("TextLabel")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 35)
titleBar.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
titleBar.TextColor3 = Color3.fromRGB(255, 255, 255)
titleBar.TextSize = 14
titleBar.Font = Enum.Font.GothamBold
titleBar.Text = "  🎮 THE SUSPECT SCRIPT"
titleBar.XAlignment = Enum.TextXAlignment.Left
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = titleBar

-- حاوية العناصر الداخلية القابلة للتمرير لكي تتسع الأحجام الجديدة للوحة
local containerFrame = Instance.new("ScrollingFrame")
containerFrame.Name = "Container"
containerFrame.Size = UDim2.new(1, -10, 1, -40)
containerFrame.Position = UDim2.new(0, 5, 0, 40)
containerFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
containerFrame.BorderSizePixel = 0
containerFrame.CanvasSize = UDim2.new(0, 0, 0, 500)
containerFrame.ScrollBarThickness = 4
containerFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 140)
containerFrame.Parent = mainFrame

local layout = Instance.new("UIListLayout")
layout.Parent = containerFrame
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 6)

-- دالة مساعدة لإنشاء العناوين الفرعية المدمجة
local function createSectionTitle(text, order)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -6, 0, 25)
    label.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    label.TextColor3 = Color3.fromRGB(0, 255, 140)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 11
    label.Text = "  " .. text
    label.XAlignment = Enum.TextXAlignment.Left
    label.LayoutOrder = order
    label.Parent = containerFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = label
end

-- دالة مساعدة لإنشاء الأزرار العادية
local function createButton(text, order, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -6, 0, 32)
    button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.GothamMedium
    button.TextSize = 12
    button.Text = text
    button.LayoutOrder = order
    button.Parent = containerFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = button
    
    button.MouseButton1Click:Connect(callback)
    
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(55, 55, 55)}):Play()
    end)
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(45, 45, 45)}):Play()
    end)
end

-- دالة مساعدة لإنشاء أزرار التفعيل/التعطيل (Toggles)
local function createToggleButton(text, configKey, order, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -6, 0, 32)
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

-- دالة مساعدة لإدخل السرعة والمدى نصياً
local function createNumberInput(placeholder, order, onInputChanged)
    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(1, -6, 0, 32)
    textBox.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
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
        if value then
            onInputChanged(value)
        end
    end)
end

-- تحديث ألوان أزرار التفعيل
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
-- ميزة اختفاء وإظهار لوحة التحكم بالكامل (UI Visibility Toggle Key)
-- ====================================================================
-- يمكنك تغيير الزر المكتوب بالأسفل (RightControl) لأي زر تفضله باللوحة
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.RightControl then
        Config.uiVisible = not Config.uiVisible
        mainFrame.Visible = Config.uiVisible
        print("👁️ UI Visibility Set to: " .. tostring(Config.uiVisible))
    end
end)

-- ====================================================================
-- بناء الأزرار والوظائف داخل اللوحة
-- ====================================================================

-- 1. كشف اللاعبين
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

-- 2. التحكم بالسرعة
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

-- 3. المدى والمسافة
createSectionTitle("🎯 RANGE CONTROL", 7)
createToggleButton("Toggle Range", "rangeEnabled", 8, function(state) end)
createNumberInput("Enter Max Attack Range...", 9, function(value) Config.currentRange = value end)

-- 4. ميزة الاختفاء للاعب (Invisibility System Fixed)
createSectionTitle("👻 STEALTH MODE", 10)
local savedParts = {}
createToggleButton("Invisibility with Kill", "invisibilityEnabled", 11, function(state)
    if state then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") or part:IsA("Decal") then
                if part.Name ~= "HumanoidRootPart" then
