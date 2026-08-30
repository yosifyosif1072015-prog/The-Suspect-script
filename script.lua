-- The Suspect Script by yosifyosif
-- Features: Detect Killer, Detect Citizens, Speed Control, Range Control, Invisibility with Kill

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

-- Create GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SuspectGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Helper function to create labels
local function createLabel(name, position, text)
    local label = Instance.new("TextLabel")
    label.Name = name
    label.Size = UDim2.new(0, 300, 0, 30)
    label.Position = position
    label.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.BorderSizePixel = 1
    label.BorderColor3 = Color3.fromRGB(0, 200, 100)
    label.TextSize = 14
    label.Text = text
    label.Parent = screenGui
    return label
end

-- Helper function to create buttons
local function createButton(name, position, text, callback)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = UDim2.new(0, 150, 0, 35)
    button.Position = position
    button.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.BorderSizePixel = 1
    button.BorderColor3 = Color3.fromRGB(0, 200, 100)
    button.TextSize = 14
    button.Text = text
    button.Parent = screenGui
    button.MouseButton1Click:Connect(callback)
    return button
end

-- Create UI Elements
createLabel("Title", UDim2.new(0, 10, 0, 10), "=== The Suspect Script ===")

-- Killer Detection Section
createLabel("KillerLabel", UDim2.new(0, 10, 0, 50), "🔪 Killer Detection")
createButton("DetectKillerBtn", UDim2.new(0, 10, 0, 85), "Detect Killer", function()
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

-- Citizen Detection Section
createLabel("CitizenLabel", UDim2.new(0, 10, 0, 130), "👥 Citizen Detection")
createButton("DetectCitizenBtn", UDim2.new(0, 10, 0, 165), "Detect Citizens", function()
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

-- Speed Control Section
createLabel("SpeedLabel", UDim2.new(0, 10, 0, 210), "⚡ Speed Control: " .. Config.currentSpeed)
createButton("IncreaseSpeedBtn", UDim2.new(0, 10, 0, 245), "➕ Speed", function()
    if Config.currentSpeed < Config.maxSpeed then
        Config.currentSpeed = Config.currentSpeed + 10
    end
end)
createButton("DecreaseSpeedBtn", UDim2.new(0, 170, 0, 245), "➖ Speed", function()
    if Config.currentSpeed > 10 then
        Config.currentSpeed = Config.currentSpeed - 10
    end
end)
createButton("EnableSpeedBtn", UDim2.new(0, 10, 0, 285), "Enable Speed", function()
    Config.speedEnabled = not Config.speedEnabled
    print((Config.speedEnabled and "✅" or "❌") .. " Speed " .. (Config.speedEnabled and "Enabled" or "Disabled"))
end)

-- Range Control Section
createLabel("RangeLabel", UDim2.new(0, 10, 0, 330), "📏 Range Control: " .. Config.currentRange)
createButton("IncreaseRangeBtn", UDim2.new(0, 10, 0, 365), "➕ Range", function()
    if Config.currentRange < Config.maxRange then
        Config.currentRange = Config.currentRange + 10
    end
end)
createButton("DecreaseRangeBtn", UDim2.new(0, 170, 0, 365), "➖ Range", function()
    if Config.currentRange > 10 then
        Config.currentRange = Config.currentRange - 10
    end
end)
createButton("EnableRangeBtn", UDim2.new(0, 10, 0, 405), "Enable Range", function()
    Config.rangeEnabled = not Config.rangeEnabled
    print((Config.rangeEnabled and "✅" or "❌") .. " Range " .. (Config.rangeEnabled and "Enabled" or "Disabled"))
end)

-- Invisibility Section
createLabel("InvisLabel", UDim2.new(0, 10, 0, 450), "👻 Invisibility (Can Kill)")
createButton("EnableInvisBtn", UDim2.new(0, 10, 0, 485), "Toggle Invisibility", function()
    Config.invisibilityEnabled = not Config.invisibilityEnabled
    print((Config.invisibilityEnabled and "✅" or "❌") .. " Invisibility " .. (Config.invisibilityEnabled and "Enabled" or "Disabled"))
end)

-- Status Label
local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "StatusLabel"
statusLabel.Size = UDim2.new(0, 300, 0, 100)
statusLabel.Position = UDim2.new(0, 10, 0, 530)
statusLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
statusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
statusLabel.BorderSizePixel = 1
statusLabel.BorderColor3 = Color3.fromRGB(0, 200, 100)
statusLabel.TextSize = 12
statusLabel.TextWrapped = true
statusLabel.Text = "Status: Ready\nSpeed: " .. Config.currentSpeed .. "\nRange: " .. Config.currentRange
statusLabel.Parent = screenGui

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

-- Invisibility Implementation
RunService.RenderStepped:Connect(function()
    if character then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                if Config.invisibilityEnabled then
                    part.Transparency = 0.5
                    part.CanCollide = false
                else
                    if part.Name ~= "HumanoidRootPart" then
                        part.Transparency = 0
                    end
                    part.CanCollide = true
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
print("  - Detect Killer/Citizens: Click Buttons")
print("  - Speed: ➕➖ Buttons + Enable Button")
print("  - Range: ➕➖ Buttons + Enable Button")
print("  - Invisibility: Click Toggle Button")
print("  - Kill (When Invisible): Press E")
