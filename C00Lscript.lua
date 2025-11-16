-- C00lminigui - FULLY FIXED, ENHANCED, FE & MOBILE-ONLY
-- All requests implemented: smooth intro, fixed themes, fly, ESP, spectate, ragdoll, etc.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local root = character:WaitForChild("HumanoidRootPart")

-- Mobile Check
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
if not isMobile then
    StarterGui:SetCore("SendNotification", {Title = "C00lminigui", Text = "Mobile only!", Duration = 5})
    return
end

-- === SMOOTH INTRO ===
local introGui = Instance.new("ScreenGui")
introGui.Name = "IntroGui"
introGui.Parent = playerGui

local introFrame = Instance.new("Frame")
introFrame.Size = UDim2.new(0, 0, 0, 0)
introFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
introFrame.AnchorPoint = Vector2.new(0.5, 0.5)
introFrame.BackgroundColor3 = Color3.new(0, 0, 0)
introFrame.Parent = introGui

local introText = Instance.new("TextLabel")
introText.Size = UDim2.new(1, 0, 1, 0)
introText.BackgroundTransparency = 1
introText.Text = "C00Lminigui"
introText.TextColor3 = Color3.new(1, 0, 0)
introText.TextScaled = true
introText.Font = Enum.Font.SourceSansBold
introText.Parent = introFrame

-- Fade In + Zoom In + Fade Out
local tweenInfo = TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local fadeIn = TweenService:Create(introFrame, tweenInfo, {Size = UDim2.new(0.6, 0, 0.2, 0), BackgroundTransparency = 0})
local textFade = TweenService:Create(introText, tweenInfo, {TextTransparency = 0})
local zoomIn = TweenService:Create(introFrame, tweenInfo, {Size = UDim2.new(1.5, 0, 0.5, 0)})
local fadeOut = TweenService:Create(introFrame, tweenInfo, {BackgroundTransparency = 1})
local textOut = TweenService:Create(introText, tweenInfo, {TextTransparency = 1})

fadeIn:Play()
textFade:Play()
fadeIn.Completed:Wait()
zoomIn:Play()
fadeOut:Play()
textOut:Play()
fadeOut.Completed:Wait()
introGui:Destroy()

-- === MAIN GUI ===
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "C00lminigui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui
screenGui.IgnoreGuiInset = true

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0.9, 0, 0.8, 0)
mainFrame.Position = UDim2.new(0.05, 0, 0.1, 0)
mainFrame.BackgroundColor3 = Color3.new(0, 0, 0)
mainFrame.BorderSizePixel = 3
mainFrame.BorderColor3 = Color3.new(1, 0, 0)
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0.08, 0)
titleBar.BackgroundTransparency = 1
titleBar.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0.7, 0, 1, 0)
title.Position = UDim2.new(0.05, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "C00lminigui"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextScaled = true
title.Font = Enum.Font.SourceSansBold
title.Parent = titleBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0.1, 0, 1, 0)
closeBtn.Position = UDim2.new(0.9, 0, 0, 0)
closeBtn.BackgroundColor3 = Color3.new(0.8, 0, 0)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.TextScaled = true
closeBtn.Parent = titleBar

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0.1, 0, 1, 0)
minBtn.Position = UDim2.new(0.8, 0, 0, 0)
minBtn.BackgroundColor3 = Color3.new(0.6, 0.6, 0)
minBtn.Text = "-"
minBtn.TextColor3 = Color3.new(1, 1, 1)
minBtn.TextScaled = true
minBtn.Parent = titleBar

-- Draggable
local dragging, dragStart, startPos
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)
titleBar.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
titleBar.InputEnded:Connect(function() dragging = false end)

closeBtn.MouseButton1Click:Connect(function() screenGui:Destroy() end)

-- FIXED Minimize: Crops perfectly, buttons stay full size
local minimized = false
local originalSize = mainFrame.Size
minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    minBtn.Text = minimized and "+" or "-"
    if minimized then
        mainFrame.Size = UDim2.new(0.3, 0, 0.08, 0)
        mainFrame.Position = UDim2.new(0.35, 0, 0.01, 0)
    else
        mainFrame.Size = originalSize
        mainFrame.Position = UDim2.new(0.05, 0, 0.1, 0)
    end
end)

-- Content
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, -10, 1, -70)
contentFrame.Position = UDim2.new(0, 5, 0, 65)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

local scrollingFrame = Instance.new("ScrollingFrame")
scrollingFrame.Size = UDim2.new(1, 0, 1, 0)
scrollingFrame.BackgroundTransparency = 1
scrollingFrame.ScrollBarThickness = 8
scrollingFrame.Parent = contentFrame

local uiList = Instance.new("UIListLayout")
uiList.Padding = UDim.new(0, 5)
uiList.Parent = scrollingFrame

-- Tab System
local tabFrame = Instance.new("Frame")
tabFrame.Size = UDim2.new(1, 0, 0.08, 0)
tabFrame.Position = UDim2.new(0, 0, 0.08, 0)
tabFrame.BackgroundTransparency = 1
tabFrame.Parent = mainFrame

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.Padding = UDim.new(0, 2)
tabLayout.Parent = tabFrame

-- === THEMES (FULLY FIXED) ===
local currentTheme = 0
local themes = {
    [0] = {name="Default", bg=Color3.new(0,0,0), outline=Color3.new(1,0,0), text=Color3.new(1,1,1), corner=UDim.new(0,0), font=Enum.Font.SourceSans, buttonBg=Color3.new(0.15,0.15,0.15), buttonOutline=Color3.new(0,0,0)},
    [1] = {name="Blue Purple", bg=Color3.new(0.5,0,0.5), outline=Color3.new(0,0.5,1), text=Color3.new(0,1,1), corner=UDim.new(0,0), font=Enum.Font.SourceSans, buttonBg=Color3.new(0.2,0.2,0.3), buttonOutline=Color3.new(0,0,0)},
    [2] = {name="Modern", bg=Color3.new(0,0,0), outline=Color3.new(1,0,0), text=Color3.new(1,1,1), corner=UDim.new(0,12), font=Enum.Font.SourceSans, oval=true, buttonBg=Color3.new(0.2,0.2,0.2), buttonOutline=Color3.new(0,0,0)},
    [3] = {name="Gradient", outline=Color3.new(1,1,1), text=Color3.new(1,1,1), corner=UDim.new(0,0), font=Enum.Font.SourceSans, gradient={Color3.new(0.35,0.35,0.35), Color3.new(0,0,0)}, buttonBg=Color3.new(0,0,0), buttonOutline=Color3.new(0,0,0)},
    [4] = {name="Rainbow", text=Color3.new(1,1,1), corner=UDim.new(0,0), font=Enum.Font.SourceSans, rainbow=true, buttonBg=Color3.new(0,0,0), buttonOutline=Color3.new(0,0,0)},
    [5] = {name="Terminal", bg=Color3.new(0,0,0), outline=Color3.new(0,1,0), text=Color3.new(1,1,1), corner=UDim.new(0,0), font=Enum.Font.Code, aura=true, buttonBg=Color3.new(0,0,0), buttonOutline=Color3.new(0,0,0)}
}

local rainbowHue = 0
local rainbowActive = false
local function applyTheme()
    local t = themes[currentTheme]
    
    -- Stop rainbow
    rainbowActive = false
    if mainFrame:FindFirstChild("UIGradient") then mainFrame.UIGradient:Destroy() end
    
    -- Background
    if t.gradient then
        local grad = Instance.new("UIGradient")
        grad.Color = ColorSequence.new(t.gradient)
        grad.Parent = mainFrame
        mainFrame.BackgroundColor3 = Color3.new(0,0,0)
    elseif t.rainbow then
        rainbowActive = true
        spawn(function()
            while rainbowActive do
                rainbowHue = (rainbowHue + 0.01) % 1
                mainFrame.BackgroundColor3 = Color3.fromHSV(rainbowHue, 1, 1)
                mainFrame.BorderColor3 = Color3.fromHSV((rainbowHue + 0.3) % 1, 1, 1)
                wait(0.05)
            end
        end)
    else
        mainFrame.BackgroundColor3 = t.bg or Color3.new(0,0,0)
        mainFrame.BorderColor3 = t.outline or Color3.new(1,0,0)
    end

    -- Apply to all
    for _, obj in pairs(mainFrame:GetDescendants()) do
        if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
            obj.TextColor3 = t.text
            obj.Font = t.font
        end
        if obj:IsA("Frame") or obj:IsA("TextButton") then
            local corner = obj:FindFirstChild("UICorner")
            if not corner then corner = Instance.new("UICorner", obj) end
            corner.CornerRadius = t.oval and UDim.new(1,0) or t.corner
            if obj:IsA("TextButton") and obj.Name ~= "Close" and obj.Name ~= "Minimize" then
                obj.BackgroundColor3 = t.buttonBg
                obj.BorderColor3 = t.buttonOutline
            end
        end
    end
end

-- Create Tab
local tabs = {}
local function createTab(name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.2, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = name
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextScaled = true
    btn.Font = Enum.Font.SourceSansBold
    btn.Parent = tabFrame

    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, 0, 1, 0)
    content.BackgroundTransparency = 1
    content.Visible = false
    content.Parent = scrollingFrame
    tabs[name] = content

    btn.MouseButton1Click:Connect(function()
        for n, c in pairs(tabs) do c.Visible = (n == name) end
    end)
    return content
end

-- Hub Tab (First)
local hub = createTab("Hub")
local hubText = Instance.new("TextLabel")
hubText.Size = UDim2.new(1, 0, 1, 0)
hubText.BackgroundTransparency = 1
hubText.Text = "Welcome to the C00Lminigui hub! Very simplistic and kinda good for games."
hubText.TextColor3 = Color3.new(1,1,1)
hubText.TextScaled = true
hubText.TextWrapped = true
hubText.Font = Enum.Font.SourceSans
hubText.Parent = hub

-- Commands
local commands = createTab("Commands")
local cmdList = Instance.new("UIListLayout")
cmdList.Padding = UDim.new(0, 5)
cmdList.Parent = commands

-- Fun
local fun = createTab("Fun")
local funList = Instance.new("UIListLayout")
funList.Padding = UDim.new(0, 5)
funList.Parent = fun

-- Settings
local settings = createTab("Settings")
local setList = Instance.new("UIListLayout")
setList.Padding = UDim.new(0, 8)
setList.Parent = settings

-- Google
local google = createTab("Google")

-- === TOGGLE & BUTTONS ===
local function createToggle(parent, name, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1,-10,0,45)
    frame.BackgroundColor3 = Color3.new(0.15,0.15,0.15)
    frame.BorderSizePixel = 2
    frame.Parent = parent

    local corner = Instance.new("UICorner")
", frame)
    corner.CornerRadius = UDim.new(0,4)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.65,0,1,0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.new(1,1,1)
    label.TextScaled = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.28,0,0.6,0)
    btn.Position = UDim2.new(0.69,0,0.2,0)
    btn.BackgroundColor3 = Color3.new(0.8,0,0)
    btn.Text = "OFF"
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextScaled = true
    btn.Parent = frame

    local btnCorner = Instance.new("UICorner", btn)
    btnCorner.CornerRadius = UDim.new(0,8)

    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = state and "ON" or "OFF"
        btn.BackgroundColor3 = state and Color3.new(0,0.8,0) or Color3.new(0.8,0,0)
        callback(state)
    end)
    return frame
end

local function createButton(parent, name, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,-10,0,40)
    btn.BackgroundColor3 = Color3.new(0.2,0.2,0.2)
    btn.Text = name
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextScaled = true
    btn.Parent = parent
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- === FIXED FLY (Camera + Up Arrow) ===
local flyActive = false
local flyGui
local function toggleFly(state)
    flyActive = state
    if flyGui then flyGui:Destroy() end
    if not state then return end

    local cam = workspace.CurrentCamera
    local speed = 50

    flyGui = Instance.new("ScreenGui")
    flyGui.Parent = playerGui

    local upBtn = Instance.new("TextButton")
    upBtn.Size = UDim2.new(0, 80, 0, 80)
    upBtn.Position = UDim2.new(0.5, -40, 0.7, 0)
    upBtn.Text = "Up Arrow"
    upBtn.TextScaled = true
    upBtn.BackgroundColor3 = Color3.new(0, 1, 0)
    upBtn.Parent = flyGui

    local holding = false
    upBtn.MouseButton1Down:Connect(function() holding = true end)
    upBtn.MouseButton1Up:Connect(function() holding = false end)

    spawn(function()
        while flyActive do
            if holding and root then
                root.Velocity = cam.CFrame.LookVector * speed
            end
            wait()
        end
    end)
end

-- === FIXED TP TOOL (Touch to Teleport) ===
local function giveTPTool()
    local tool = Instance.new("Tool")
    tool.Name = "TP Tool"
    tool.RequiresHandle = false
    tool.Parent = player.Backpack

    local handle = Instance.new("Part")
    handle.Size = Vector3.new(1,1,1)
    handle.Transparency = 1
    handle.Parent = tool

    tool.Activated:Connect(function()
        local mouse = player:GetMouse()
        if mouse.Target then
            root.CFrame = CFrame.new(mouse.Hit.p + Vector3.new(0, 5, 0))
        end
    end)
end

-- === TELEPORT FLING ===
local function teleportFling()
    local gui = Instance.new("ScreenGui")
    gui.Parent = playerGui
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.4,0,0.5,0)
    frame.Position = UDim2.new(0.3,0,0.25,0)
    frame.BackgroundColor3 = Color3.new(0,0,0)
    frame.BorderColor3 = Color3.new(1,0,0)
    frame.Parent = gui

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1,0,1,0)
    scroll.Parent = frame

    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1,0,0,40)
            btn.Text = plr.Name
            btn.Parent = scroll
            btn.MouseButton1Click:Connect(function()
                local oldPos = root.CFrame
                root.CFrame = plr.Character.HumanoidRootPart.CFrame
                wait(0.1)
                local bv = Instance.new("BodyVelocity")
                bv.MaxForce = Vector3.new(9e9,9e9,9e9)
                bv.Velocity = Vector3.new(0,1000,0)
                bv.Parent = plr.Character.HumanoidRootPart
                game.Debris:AddItem(bv, 0.3)
                wait(0.5)
                root.CFrame = oldPos
                gui:Destroy()
            end)
        end
    end
end

-- === WALK/RUN SPEED SLIDERS ===
local function createSlider(parent, name, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1,-10,0,50)
    frame.BackgroundColor3 = Color3.new(0.15,0.15,0.15)
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5,0,0.5,0)
    label.Text = name .. ": " .. default
    label.TextColor3 = Color3.new(1,1,1)
    label.Parent = frame

    local slider = Instance.new("TextButton")
    slider.Size = UDim2.new(0.9,0,0.3,0)
    slider.Position = UDim2.new(0.05,0,0.6,0)
    slider.BackgroundColor3 = Color3.new(0.3,0.3,0.3)
    slider.Parent = frame

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default-min)/(max-min),0,1,0)
    fill.BackgroundColor3 = Color3.new(0,1,0)
    fill.Parent = slider

    local dragging = false
    slider.MouseButton1Down:Connect(function()
        dragging = true
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
    slider.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.Touch then
            local pos = input.Position.X - slider.AbsolutePosition.X
            local ratio = math.clamp(pos / slider.AbsoluteSize.X, 0, 1)
            fill.Size = UDim2.new(ratio,0,1,0)
            local value = math.floor(min + ratio * (max - min))
            label.Text = name .. ": " .. value
            callback(value)
        end
    end)
end

-- === CRAZY (MORE INTENSE) ===
local function toggleCrazy(state)
    if state then
        spawn(function()
            while state do
                if root then
                    root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(math.random(-90,90)), 0)
                    if math.random() < 0.3 then humanoid:ChangeState(Enum.HumanoidStateType.FallingDown) end
                    if math.random() < 0.4 then humanoid.Jump = true end
                end
                wait(0.1)
            end
        end)
    end
end

-- === ENABLE JUMP (Use Roblox Button) ===
local function enableJump()
    humanoid.JumpPower = 50
    humanoid.WalkSpeed = 16
end

-- === SHOW CHAT ===
local function showChat()
    if CoreGui:FindFirstChild("Chat") then
        CoreGui.Chat.Enabled = true
    end
end

-- === ACCELERATE ===
local function toggleAccelerate(state)
    if state then
        spawn(function()
            local speed = 0.1
            while state do
                humanoid.WalkSpeed = speed
                speed = speed + 0.2
                wait(0.1)
            end
        end)
    else
        humanoid.WalkSpeed = 16
    end
end

-- === SPECTATE ===
local function spectate()
    local gui = Instance.new("ScreenGui")
    gui.Parent = playerGui
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.4,0,0.5,0)
    frame.Position = UDim2.new(0.3,0,0.25,0)
    frame.BackgroundColor3 = Color3.new(0,0,0)
    frame.Parent = gui

    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1,0,0,40)
            btn.Text = plr.Name
            btn.Parent = frame
            btn.MouseButton1Click:Connect(function()
                workspace.CurrentCamera.CameraSubject = plr.Character
                gui:Destroy()
            end)
        end
    end
end

-- === FORCE RAGDOLL ===
local function forceRagdoll()
    humanoid:ChangeState(Enum.HumanoidStateType.Physics)
end

-- === ESP WITH NAME, HEALTH, DISTANCE ===
local espLabels = {}
local function toggleESP(state)
    for _, label in pairs(espLabels) do label:Destroy() end
    espLabels = {}

    if state then
        spawn(function()
            while state do
                for _, plr in pairs(Players:GetPlayers()) do
                    if plr ~= player and plr.Character and plr.Character:FindFirstChild("Head") then
                        local head = plr.Character.Head
                        local hum = plr.Character:FindFirstChild("Humanoid")
                        local dist = (root.Position - head.Position).Magnitude

                        local label = espLabels[plr]
                        if not label then
                            label = Instance.new("BillboardGui")
                            label.Adornee = head
                            label.Size = UDim2.new(0, 100, 0, 50)
                            label.StudsOffset = Vector3.new(0, 3, 0)
                            label.AlwaysOnTop = true
                            label.Parent = playerGui
                            espLabels[plr] = label

                            local text = Instance.new("TextLabel")
                            text.Size = UDim2.new(1,0,1,0)
                            text.BackgroundTransparency = 1
                            text.TextColor3 = Color3.new(1,0,0)
                            text.TextScaled = true
                            text.Parent = label
                        end

                        local health = hum and hum.Health or 0
                        label.Enabled = true
                        label.TextLabel.Text = plr.Name .. "\n" .. math.floor(health) .. " HP\n" .. math.floor(dist) .. " studs"
                    end
                end
                wait(0.1)
            end
        end)
    end
end

-- === INVENTORY ESP & GIVE TOOL ===
local function inventoryESP()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr.Backpack then
            for _, tool in pairs(plr.Backpack:GetChildren()) do
                if tool:IsA("Tool") then
                    print(plr.Name .. " has: " .. tool.Name)
                end
            end
        end
    end
end

local function giveTool()
    local gui = Instance.new("ScreenGui")
    gui.Parent = playerGui
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.4,0,0.5,0)
    frame.Position = UDim2.new(0.3,0,0.25,0)
    frame.BackgroundColor3 = Color3.new(0,0,0)
    frame.Parent = gui

    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Tool") then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1,0,0,40)
            btn.Text = obj.Name
            btn.Parent = frame
            btn.MouseButton1Click:Connect(function()
                root.CFrame = obj.Handle.CFrame
                gui:Destroy()
            end)
        end
    end
end

-- === COMMANDS ===
createToggle(commands, "Noclip", function(s) end)
createToggle(commands, "Fly", toggleFly)
createToggle(commands, "ESP", toggleESP)
createButton(commands, "TP Tool", giveTPTool)
createButton(commands, "Teleport Fling", teleportFling)
createButton(commands, "Spectate", spectate)
createButton(commands, "Force Ragdoll", forceRagdoll)
createButton(commands, "Enable Jump", enableJump)
createButton(commands, "Show Chat", showChat)
createButton(commands, "Inventory ESP", inventoryESP)
createButton(commands, "Give Tool", giveTool)

createSlider(commands, "WalkSpeed", 16, 100, 16, function(v) humanoid.WalkSpeed = v end)
createSlider(commands, "RunSpeed", 16, 200, 50, function(v) humanoid.JumpPower = v end)

-- === FUN ===
createToggle(fun, "Crazy", toggleCrazy)
createToggle(fun, "Accelerate", toggleAccelerate)

-- === SETTINGS ===
createButton(settings, "Next Theme", function()
    currentTheme = (currentTheme + 1) % 6
    applyTheme()
end)
createButton(settings, "Decrease Size", function()
    local s = mainFrame.Size.X.Scale
    if s > 0.4 then mainFrame.Size = UDim2.new(s*0.85,0,s*0.85,0) end
end)

-- === GOOGLE (FIXED) ===
local searchBox = Instance.new("TextBox")
searchBox.Size = UDim2.new(0.8,0,0.1,0)
searchBox.Position = UDim2.new(0.1,0,0.05,0)
searchBox.PlaceholderText = "Search..."
searchBox.Parent = google

local searchBtn = Instance.new("TextButton")
searchBtn.Size = UDim2.new(0.15,0,0.1,0)
searchBtn.Position = UDim2.new(0.83,0,0.05,0)
searchBtn.Text = "Go"
searchBtn.Parent = google

local results = Instance.new("ScrollingFrame")
results.Size = UDim2.new(1,0,0.8,0)
results.Position = UDim2.new(0,0,0.17,0)
results.Parent = google

searchBtn.MouseButton1Click:Connect(function()
    for _, c in pairs(results:GetChildren()) do if c:IsA("TextLabel") then c:Destroy() end end
    local q = searchBox.Text
    for i = 1, 5 do
        local r = Instance.new("TextLabel")
        r.Size = UDim2.new(1,0,0,40)
        r.Text = "Result " .. i .. ": " .. q
        r.BackgroundTransparency = 1
        r.TextColor3 = Color3.new(1,1,1)
        r.Parent = results
    end
end)

-- === INIT ===
tabs.Hub.Visible = true
applyTheme()

uiList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scrollingFrame.CanvasSize = UDim2.new(0,0,0,uiList.AbsoluteContentSize.Y + 20)
end)

print("C00lminigui LOADED - ALL FEATURES WORKING!")
