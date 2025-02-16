--[[
  __  ___   _  ___  
  \ \/ / | | |/ _ \ 
   >  <| |_| | (_) |
  /_/\_\\__, |\___/ 
        |___/   
Found bugs? https://discord.gg/5QtB6CYU77
]]
local player = game.Players.LocalPlayer

local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoidRootPart = newCharacter:WaitForChild("HumanoidRootPart")
    humanoid = newCharacter:WaitForChild("Humanoid")
    humanoid.WalkSpeed = stealthSpeedEnabled and stealthSpeedValue or defaultWalkSpeed
end)

local auraEnabled = false
local attackRadius = 10 
local attackSpeed = "Slow"
local running = true
local speeds = {
    Slow = 0.5,
    Medium = 0.3,
    Fast = 0.02
}

local defaultWalkSpeed = 16
local stealthSpeedValue = 50
local stealthSpeedEnabled = false

local gui = Instance.new("ScreenGui")
gui.Name = "KillAuraGUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local container = Instance.new("Frame")
container.Size = UDim2.new(0, 220, 0, 450)
container.Position = UDim2.new(0, 10, 0, 10)
container.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
container.BorderSizePixel = 0
container.Active = true
container.Draggable = true
container.Parent = gui

local containerCorner = Instance.new("UICorner")
containerCorner.CornerRadius = UDim.new(0, 8)
containerCorner.Parent = container

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 120, 0, 50)
toggleButton.Position = UDim2.new(0, 10, 0, 10)
toggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Font = Enum.Font.Gotham
toggleButton.TextSize = 14
toggleButton.Text = "Aura: OFF"
toggleButton.Parent = container

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 4)
toggleCorner.Parent = toggleButton

local watermark = Instance.new("TextLabel")
watermark.Size = UDim2.new(0, 80, 0, 50)
watermark.Position = UDim2.new(0, 140, 0, 10)
watermark.BackgroundTransparency = 1
watermark.Text = "by xyo"
watermark.TextColor3 = Color3.fromRGB(255, 255, 255)
watermark.Font = Enum.Font.GothamBold
watermark.TextSize = 18
watermark.Parent = container

local radiusSlider = Instance.new("Frame")
radiusSlider.Size = UDim2.new(0, 200, 0, 20)
radiusSlider.Position = UDim2.new(0, 10, 0, 70)
radiusSlider.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
radiusSlider.BorderSizePixel = 0
radiusSlider.Parent = container

local radiusSliderCorner = Instance.new("UICorner")
radiusSliderCorner.CornerRadius = UDim.new(0, 4)
radiusSliderCorner.Parent = radiusSlider

local sliderThumb = Instance.new("Frame")
sliderThumb.Size = UDim2.new(0, 10, 1, 0)
sliderThumb.Position = UDim2.new(0, 0, 0, 0)
sliderThumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
sliderThumb.Parent = radiusSlider

local sliderThumbCorner = Instance.new("UICorner")
sliderThumbCorner.CornerRadius = UDim.new(0, 4)
sliderThumbCorner.Parent = sliderThumb

local radiusLabel = Instance.new("TextLabel")
radiusLabel.Size = UDim2.new(0, 200, 0, 20)
radiusLabel.Position = UDim2.new(0, 10, 0, 95)
radiusLabel.BackgroundTransparency = 1
radiusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
radiusLabel.Font = Enum.Font.Gotham
radiusLabel.TextSize = 14
radiusLabel.Text = "Radius: " .. attackRadius
radiusLabel.Parent = container

local speedButton = Instance.new("TextButton")
speedButton.Size = UDim2.new(0, 200, 0, 30)
speedButton.Position = UDim2.new(0, 10, 0, 120)
speedButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
speedButton.TextColor3 = Color3.fromRGB(255, 255, 255)
speedButton.Font = Enum.Font.Gotham
speedButton.TextSize = 14
speedButton.Text = "Speed: " .. attackSpeed
speedButton.Parent = container

local speedCorner = Instance.new("UICorner")
speedCorner.CornerRadius = UDim.new(0, 4)
speedCorner.Parent = speedButton

local stealthSpeedButton = Instance.new("TextButton")
stealthSpeedButton.Size = UDim2.new(0, 200, 0, 30)
stealthSpeedButton.Position = UDim2.new(0, 10, 0, 160)
stealthSpeedButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
stealthSpeedButton.TextColor3 = Color3.fromRGB(255, 255, 255)
stealthSpeedButton.Font = Enum.Font.Gotham
stealthSpeedButton.TextSize = 14
stealthSpeedButton.Text = "Stealth Speed: OFF"
stealthSpeedButton.Parent = container

local stealthSpeedCorner = Instance.new("UICorner")
stealthSpeedCorner.CornerRadius = UDim.new(0, 4)
stealthSpeedCorner.Parent = stealthSpeedButton

local walkSpeedSlider = Instance.new("Frame")
walkSpeedSlider.Size = UDim2.new(0, 200, 0, 20)
walkSpeedSlider.Position = UDim2.new(0, 10, 0, 200)
walkSpeedSlider.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
walkSpeedSlider.BorderSizePixel = 0
walkSpeedSlider.Parent = container

local walkSpeedSliderCorner = Instance.new("UICorner")
walkSpeedSliderCorner.CornerRadius = UDim.new(0, 4)
walkSpeedSliderCorner.Parent = walkSpeedSlider

local walkSpeedThumb = Instance.new("Frame")
walkSpeedThumb.Size = UDim2.new(0, 10, 1, 0)
walkSpeedThumb.Position = UDim2.new(0, 0, 0, 0)
walkSpeedThumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
walkSpeedThumb.Parent = walkSpeedSlider

local walkSpeedThumbCorner = Instance.new("UICorner")
walkSpeedThumbCorner.CornerRadius = UDim.new(0, 4)
walkSpeedThumbCorner.Parent = walkSpeedThumb

local walkSpeedLabel = Instance.new("TextLabel")
walkSpeedLabel.Size = UDim2.new(0, 200, 0, 20)
walkSpeedLabel.Position = UDim2.new(0, 10, 0, 225)
walkSpeedLabel.BackgroundTransparency = 1
walkSpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
walkSpeedLabel.Font = Enum.Font.Gotham
walkSpeedLabel.TextSize = 14
walkSpeedLabel.Text = "WalkSpeed: " .. stealthSpeedValue
walkSpeedLabel.Parent = container

local tpToggleButton = Instance.new("TextButton")
tpToggleButton.Size = UDim2.new(0, 200, 0, 30)
tpToggleButton.Position = UDim2.new(0, 10, 0, 260)
tpToggleButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
tpToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
tpToggleButton.Font = Enum.Font.Gotham
tpToggleButton.TextSize = 14
tpToggleButton.Text = "Teleport"
tpToggleButton.Parent = container

local tpToggleCorner = Instance.new("UICorner")
tpToggleCorner.CornerRadius = UDim.new(0, 4)
tpToggleCorner.Parent = tpToggleButton

local tpSearchBox = Instance.new("TextBox")
tpSearchBox.Size = UDim2.new(0, 200, 0, 25)
tpSearchBox.Position = UDim2.new(0, 10, 0, 300)
tpSearchBox.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
tpSearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
tpSearchBox.Font = Enum.Font.Gotham
tpSearchBox.TextSize = 14
tpSearchBox.PlaceholderText = "Search Player"
tpSearchBox.ClearTextOnFocus = false
tpSearchBox.Parent = container
tpSearchBox.Visible = false

local tpFrame = Instance.new("ScrollingFrame")
tpFrame.Size = UDim2.new(0, 200, 0, 100)
tpFrame.Position = UDim2.new(0, 10, 0, 330)
tpFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
tpFrame.BorderSizePixel = 0
tpFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
tpFrame.ScrollBarThickness = 6
tpFrame.Visible = false
tpFrame.Parent = container

local tpList = Instance.new("UIListLayout")
tpList.FillDirection = Enum.FillDirection.Vertical
tpList.SortOrder = Enum.SortOrder.LayoutOrder
tpList.Padding = UDim.new(0, 4)
tpList.Parent = tpFrame

local discordLabel = Instance.new("TextLabel")
discordLabel.Size = UDim2.new(1, -10, 0, 20)
discordLabel.Position = UDim2.new(0, 5, 1, -25)
discordLabel.BackgroundTransparency = 1
discordLabel.Text = "https://discord.gg/5QtB6CYU77"
discordLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
discordLabel.Font = Enum.Font.Gotham
discordLabel.TextSize = 14
discordLabel.Parent = container

--------------------------------------------------
-- PLAYER TELEPORT LOGIC
--------------------------------------------------
local function updatePlayerList(filter)
    filter = filter or ""
    for _, child in ipairs(tpFrame:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    for _, plr in ipairs(game.Players:GetPlayers()) do
        if plr ~= player and string.find(string.lower(plr.Name), string.lower(filter)) then
            local plrButton = Instance.new("TextButton")
            plrButton.Size = UDim2.new(1, 0, 0, 30)
            plrButton.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
            plrButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            plrButton.Font = Enum.Font.Gotham
            plrButton.TextSize = 14
            plrButton.Text = plr.Name
            plrButton.Parent = tpFrame
            
            plrButton.MouseButton1Click:Connect(function()
                if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    local targetHRP = plr.Character.HumanoidRootPart
                    local offset = targetHRP.CFrame.LookVector * -5
                    local targetPos = targetHRP.Position
                    humanoidRootPart.CFrame = CFrame.new(targetPos + offset + Vector3.new(0, 3, 0))
                end
                tpFrame.Visible = false
                tpSearchBox.Visible = false
            end)
        end
    end
    task.wait()
    local totalHeight = tpList.AbsoluteContentSize.Y
    tpFrame.CanvasSize = UDim2.new(0, 0, 0, totalHeight)
end

tpSearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    updatePlayerList(tpSearchBox.Text)
end)

tpToggleButton.MouseButton1Click:Connect(function()
    local newVisibility = not tpFrame.Visible
    tpFrame.Visible = newVisibility
    tpSearchBox.Visible = newVisibility
    if newVisibility then
        tpSearchBox.Text = ""
        updatePlayerList("")
    end
end)

game.Players.PlayerAdded:Connect(function()
    if tpFrame.Visible then
        updatePlayerList(tpSearchBox.Text)
    end
end)
game.Players.PlayerRemoving:Connect(function()
    if tpFrame.Visible then
        updatePlayerList(tpSearchBox.Text)
    end
end)
--------------------------------------------------
-- END PLAYER TELEPORT LOGIC
--------------------------------------------------

toggleButton.MouseButton1Click:Connect(function()
    auraEnabled = not auraEnabled
    toggleButton.Text = auraEnabled and "Aura: ON" or "Aura: OFF"
end)

speedButton.MouseButton1Click:Connect(function()
    if attackSpeed == "Slow" then
        attackSpeed = "Medium"
    elseif attackSpeed == "Medium" then
        attackSpeed = "Fast"
    else
        attackSpeed = "Slow"
    end
    speedButton.Text = "Speed: " .. attackSpeed
end)

stealthSpeedButton.MouseButton1Click:Connect(function()
    stealthSpeedEnabled = not stealthSpeedEnabled
    stealthSpeedButton.Text = stealthSpeedEnabled and "Stealth Speed: ON" or "Stealth Speed: OFF"
    if character and humanoid then
        humanoid.WalkSpeed = stealthSpeedEnabled and stealthSpeedValue or defaultWalkSpeed
    end
end)

local UserInputService = game:GetService("UserInputService")
local draggingRadius = false

radiusSlider.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingRadius = true
        container.Draggable = false
    end
end)

radiusSlider.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingRadius = false
        container.Draggable = true
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if draggingRadius and input.UserInputType == Enum.UserInputType.MouseMovement then
        local mousePos = UserInputService:GetMouseLocation()
        local sliderPos = radiusSlider.AbsolutePosition
        local sliderWidth = radiusSlider.AbsoluteSize.X
        local relativeX = math.clamp(mousePos.X - sliderPos.X, 0, sliderWidth)
        sliderThumb.Position = UDim2.new(0, relativeX - (sliderThumb.AbsoluteSize.X / 2), 0, 0)
        local percent = relativeX / sliderWidth
        local newRadius = 10 + (800 * percent)
        attackRadius = math.floor(newRadius)
        radiusLabel.Text = "Radius: " .. attackRadius
    end
end)

local draggingWalkSpeed = false
local walkSpeedMin = 16
local walkSpeedMax = 200

walkSpeedSlider.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingWalkSpeed = true
        container.Draggable = false
    end
end)

walkSpeedSlider.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingWalkSpeed = false
        container.Draggable = true
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if draggingWalkSpeed and input.UserInputType == Enum.UserInputType.MouseMovement then
        local mousePos = UserInputService:GetMouseLocation()
        local sliderPos = walkSpeedSlider.AbsolutePosition
        local sliderWidth = walkSpeedSlider.AbsoluteSize.X
        local relativeX = math.clamp(mousePos.X - sliderPos.X, 0, sliderWidth)
        walkSpeedThumb.Position = UDim2.new(0, relativeX - (walkSpeedThumb.AbsoluteSize.X / 2), 0, 0)
        local percent = relativeX / sliderWidth
        local newWalkSpeed = math.floor(walkSpeedMin + ((walkSpeedMax - walkSpeedMin) * percent))
        stealthSpeedValue = newWalkSpeed
        walkSpeedLabel.Text = "WalkSpeed: " .. newWalkSpeed
        if stealthSpeedEnabled and humanoid then
            humanoid.WalkSpeed = newWalkSpeed
        end
    end
end)

local function getEquippedTool()
    local char = player.Character
    if not char then return nil end
    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") then
            return tool
        end
    end
    return nil
end

local cachedMobs = {}
local lastMobUpdate = tick()

local function updateCachedMobs()
    cachedMobs = workspace.Mobs:GetChildren()
    lastMobUpdate = tick()
end

local mobDebounce = {}

spawn(function()
    while task.wait() do
        if stealthSpeedEnabled and character and humanoid then
            pcall(function()
                humanoid.WalkSpeed = stealthSpeedValue
            end)
        end
    end
end)

while running do
    task.wait(speeds[attackSpeed])
    if tick() - lastMobUpdate >= 1 then
        updateCachedMobs()
    end
    if auraEnabled and character and humanoidRootPart then
        local equippedTool = getEquippedTool()
        if equippedTool then
            for _, mob in ipairs(cachedMobs) do
                local mobRoot = mob:FindFirstChild("HumanoidRootPart")
                if mobRoot then
                    local distance = (mobRoot.Position - humanoidRootPart.Position).Magnitude
                    if distance <= attackRadius then
                        if not mobDebounce[mob] or tick() - mobDebounce[mob] > speeds[attackSpeed] then
                            game:GetService("ReplicatedStorage").Remotes.DamageMob:FireServer(mob, 22, equippedTool.Name)
                            game:GetService("ReplicatedStorage").Remotes.PlayerDamagedMob:FireServer(mob, 22, equippedTool.Name)
                            mobDebounce[mob] = tick()
                        end
                    end
                end
            end
        end
    end
end
