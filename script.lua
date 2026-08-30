-- The Suspect Script by yosifyosif
-- Features: Detect Killer, Detect Citizens, Speed Control, Range Control, Invisibility with Kill
-- UPDATED: Added Draggable GUI + Fixed Invisibility Bug + Color Status Buttons

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- Configuration
local Config = {
    speedEnabled = false,
    currentSpeed = 50,
    maxSpeed = 200,
    rangeEnabled = false,
    currentRange = 50,
    maxRange = 200,
    invisibilityEnabled = false,
    killerDetectRadius = 100,
    citizenDetectRadius = 100
}

-- Table to store toggle buttons for updating colors
local toggleButtons = {}

-- Create GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SuspectGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Create Main Frame (للتحكم به)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 320, 0, 650)
mainFrame.Position = UDim2.new(0, 10, 0, 10)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.fromRGB(0, 200, 100)
mainFrame.Parent = screenGui

-- Create Title Bar (للحرك)
local titleBar = Instance.new("TextLabel")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.Position = UDim2.new(0, 0, 0, 0)
titleBar.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
titleBar.TextColor3 = Color3.fromRGB(255, 255, 255)
titleBar.BorderSizePixel = 0
titleBar.TextSize = 16
titleBar.Text = "🎮 The Suspect Script"
titleBar.Parent = mainFrame

-- Create Container للعناصر
local containerFrame = Instance.new("ScrollingFrame")
containerFrame.Name = "Container"
containerFrame.Size = UDim2.new(1, 0, 1, -40)
containerFrame.Position = UDim2.new(0, 0, 0, 40)
containerFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
containerFrame.BorderSizePixel = 0
containerFrame.CanvasSize = UDim2.new(0, 0, 0, 800)
containerFrame.ScrollBarThickness = 8
containerFrame.Parent = mainFrame

-- Helper function to create labels
local function createLabel(name, position, text)
    local label = Instance.new("TextLabel")
    label.Name = name
    label.Size = UDim2.new(1, -10, 0, 25)
    label.Position = position
    label.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.BorderSizePixel = 1
    label.BorderColor3 = Color3.fromRGB(0, 200, 100)
    label.TextSize = 13
    label.Text = text
    label.Parent = containerFrame
    return label
end

-- Helper function to create buttons
local function createButton(name, position, text, callback)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = UDim2.new(0.48, 0, 0, 35)
    button.Position = position
    button.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.BorderSizePixel = 1
    button.BorderColor3 = Color3.fromRGB(0, 200, 100)
    button.TextSize = 12
    button.Text = text
    button.Parent = containerFrame
    button.MouseButton1Click:Connect(callback)
    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    end)
    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
    end)
    return button
end

-- Helper function to create toggle buttons (مع تغيير الألوان)
local function createToggleButton(name, position, text, configKey, callback)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = UDim2.new(0.48, 0, 0, 35)
    button.Position = position
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.BorderSizePixel = 1
    button.BorderColor3 = Color3.fromRGB(0, 200, 100)
    button.TextSize = 12
    button.Text = text
    button.Parent = containerFrame
    
    -- تخزين الزر لتحديثه لاحقاً
    table.insert(toggleButtons, {button = button, configKey = configKey})
    
    button.MouseButton1Click:Connect(function()
        Config[configKey] = not Config[configKey]
        callback()
        updateToggleButtonColors()
    end)
    
    return button
end

-- Function to update toggle button colors
function updateToggleButtonColors()
    for _, buttonData in ipairs(toggleButtons) do
        local configValue = Config[buttonData.configKey]
        if configValue then
            -- 🟢 أخضر = مفعل
            buttonData.button.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        else
            -- 🔴 أحمر = معطل
            buttonData.button.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        end
    end
end

-- Dragging Functionality
local dragging = false
local dragStart = Vector2.new(0, 0)
local frameStart = UDim2.new(0, 0, 0, 0)

titleBar.InputBegan:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = UserInputService:GetMouseLocation()
        frameStart = mainFrame.Position
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
        local currentMouse = UserInputService:GetMouseLocation()
        local delta = currentMouse - dragStart
        mainFrame.Position = UDim2.new(
            frameStart.X.Scale, frameStart.X.Offset + delta.X,
            frameStart.Y.Scale, frameStart.Y.Offset + delta.Y
        )
    end
end)

-- Create UI Elements
local yPos = 10

-- Killer Detection Section
createLabel("KillerLabel", UDim2.new(0, 5, 0, yPos), "🔪 Killer Detection")
yPos = yPos + 30
createButton("DetectKillerBtn", UDim2.new(0, 5, 0, yPos), "Detect Killer", function()
    local killers = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local distance = (p.Character:FindFirstChild("HumanoidRootPart").Position - rootPart.Position).Magnitude
            if distance <= Config.killerDetectRadius then
                table.insert(killers, p.Name .. " (" .. math.floor(distance) .. "m)")
            end
        end
    end
    if #killers > 0 then
        print("🔪 Killers Detected: " .. table.concat(killers, ", "))
    else
        print("❌ No Killers in Range!")
    end
end)
yPos = yPos + 40

-- Citizen Detection Section
createLabel("CitizenLabel", UDim2.new(0, 5, 0, yPos), "👥 Citizen Detection")
yPos = yPos + 30
createButton("DetectCitizenBtn", UDim2.new(0, 5, 0, yPos), "Detect Citizens", function()
    local citizens = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local distance = (p.Character:FindFirstChild("HumanoidRootPart").Position - rootPart.Position).Magnitude
            if distance <= Config.citizenDetectRadius then
                table.insert(citizens, p.Name .. " (" .. math.floor(distance) .. "m)")
            end
        end
    end
    if #citizens > 0 then
        print("👥 Citizens Detected: " .. table.concat(citizens, ", "))
    else
        print("❌ No Citizens in Range!")
    end
end)
yPos = yPos + 40

-- Speed Control Section
createLabel("SpeedLabel", UDim2.new(0, 5, 0, yPos), "⚡ Speed: " .. Config.currentSpeed)
yPos = yPos + 30
createButton("IncreaseSpeedBtn", UDim2.new(0, 5, 0, yPos), "➕ Speed", function()
    if Config.currentSpeed < Config.maxSpeed then
        Config.currentSpeed = Config.currentSpeed + 10
    end
end)
createButton("DecreaseSpeedBtn", UDim2.new(0.52, 5, 0, yPos), "➖ Speed", function()
    if Config.currentSpeed > 10 then
        Config.currentSpeed = Config.currentSpeed - 10
    end
end)
yPos = yPos + 40
createToggleButton("EnableSpeedBtn", UDim2.new(0, 5, 0, yPos), "Enable Speed", "speedEnabled", function()
    print((Config.speedEnabled and "✅" or "❌") .. " Speed " .. (Config.speedEnabled and "Enabled" or "Disabled"))
end)
yPos = yPos + 40

-- Range Control Section
createLabel("RangeLabel", UDim2.new(0, 5, 0, yPos), "📏 Range: " .. Config.currentRange)
yPos = yPos + 30
createButton("IncreaseRangeBtn", UDim2.new(0, 5, 0, yPos), "➕ Range", function()
    if Config.currentRange < Config.maxRange then
        Config.currentRange = Config.currentRange + 10
    end
end)
createButton("DecreaseRangeBtn", UDim2.new(0.52, 5, 0, yPos), "➖ Range", function()
    if Config.currentRange > 10 then
        Config.currentRange = Config.currentRange - 10
    end
end)
yPos = yPos + 40
createToggleButton("EnableRangeBtn", UDim2.new(0, 5, 0, yPos), "Enable Range", "rangeEnabled", function()
    print((Config.rangeEnabled and "✅" or "❌") .. " Range " .. (Config.rangeEnabled and "Enabled" or "Disabled"))
end)
yPos = yPos + 40

-- Invisibility Section
createLabel("InvisLabel", UDim2.new(0, 5, 0, yPos), "👻 Invisibility (Can Kill)")
yPos = yPos + 30
createToggleButton("EnableInvisBtn", UDim2.new(0, 5, 0, yPos), "Toggle Invisibility", "invisibilityEnabled", function()
    print((Config.invisibilityEnabled and "✅" or "❌") .. " Invisibility " .. (Config.invisibilityEnabled and "Enabled" or "Disabled"))
end)
yPos = yPos + 40

-- Status Label
local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "StatusLabel"
statusLabel.Size = UDim2.new(1, -10, 0, 80)
statusLabel.Position = UDim2.new(0, 5, 0, yPos)
statusLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
statusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
statusLabel.BorderSizePixel = 1
statusLabel.BorderColor3 = Color3.fromRGB(0, 200, 100)
statusLabel.TextSize = 11
statusLabel.TextWrapped = true
statusLabel.Text = "Status: Ready\nSpeed: " .. Config.currentSpeed .. "\nRange: " .. Config.currentRange
statusLabel.Parent = containerFrame

-- تحديث الألوان في البداية
updateToggleButtonColors()

-- Speed Implementation
RunService.RenderStepped:Connect(function()
    if Config.speedEnabled and character and humanoid and humanoid.Health > 0 then
        local moveDirection = Vector3.new(0, 0, 0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDirection = moveDirection + (rootPart.CFrame.LookVector) end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDirection = moveDirection - (rootPart.CFrame.RightVector) end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDirection = moveDirection - (rootPart.CFrame.LookVector) end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDirection = moveDirection + (rootPart.CFrame.RightVector) end
        
        if moveDirection.Magnitude > 0 then
            rootPart.Velocity = (moveDirection.Unit * Config.currentSpeed) + Vector3.new(0, rootPart.Velocity.Y, 0)
        end
    end
    
    -- Update Status
    statusLabel.Text = "Status: " .. (Config.speedEnabled and "🔥 Speed ON" or "⚪ Ready") .. 
                       "\nSpeed: " .. Config.currentSpeed .. 
                       "\nRange: " .. Config.currentRange ..
                       "\nInvisibility: " .. (Config.invisibilityEnabled and "👻 ON" or "❌ OFF")
end)

-- Invisibility Implementation (محسّن وبدون مشاكل)
RunService.RenderStepped:Connect(function()
    if character then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                if Config.invisibilityEnabled then
                    -- تفعيل الاختفاء بدون تعطيل الحركة
                    if part.Name ~= "HumanoidRootPart" then
                        part.Transparency = 0.7
                        part.CanCollide = false
                    end
                else
                    -- إرجاع الحالة الطبيعية
                    if part.Name ~= "HumanoidRootPart" then
                        part.Transparency = 0
                        part.CanCollide = true
                    end
                end
            end
        end
    end
end)

-- Kill Function (When Invisible/Killer)
local function killPlayer(targetPlayer)
    if targetPlayer and targetPlayer.Character then
        local targetHumanoid = targetPlayer.Character:FindFirstChild("Humanoid")
        if targetHumanoid then
            targetHumanoid.Health = 0
            print("☠️ " .. targetPlayer.Name .. " Eliminated!")
        end
    end
end

-- Kill Nearby Players (E key)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.E and Config.invisibilityEnabled then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character then
                local distance = (p.Character:FindFirstChild("HumanoidRootPart").Position - rootPart.Position).Magnitude
                if distance <= 30 then -- Kill Range
                    killPlayer(p)
                end
            end
        end
    end
end)

print("✅ The Suspect Script Loaded!")
print("📌 Controls:")
print("  - Drag the GUI by the title bar!")
print("  - Detect Killer/Citizens: Click Buttons")
print("  - Speed: ➕➖ Buttons + Enable Button")
print("  - Range: ➕➖ Buttons + Enable Button")
print("  - Invisibility: Click Toggle Button")
print("  - Kill (When Invisible): Press E")
print("  - Toggle Buttons: 🔴 Red (OFF) / 🟢 Green (ON)")
