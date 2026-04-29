-- DIVINE HUB PREMIUM | loadstring ready
-- loadstring(game:HttpGet("URL_RAW_AQUI"))()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- ==================== ESP ====================
local ESPEnabled = false
local ESPObjects = {}

local function CreateESP(target)
    if not target:FindFirstChild("Head") then return end
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "DivineESP"
    billboard.Adornee = target:FindFirstChild("Head")
    billboard.Size = UDim2.new(0, 100, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = target:FindFirstChild("Head")
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Text = target.Name
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.TextColor3 = Color3.new(0, 1, 1)
    label.TextStrokeTransparency = 0
    label.Parent = billboard
    table.insert(ESPObjects, billboard)
end

local function ClearESP()
    for _, obj in pairs(ESPObjects) do
        if obj then obj:Destroy() end
    end
    ESPObjects = {}
end

local function UpdateESP()
    ClearESP()
    if not ESPEnabled then return end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= Players.LocalPlayer and p.Character then
            CreateESP(p.Character)
        end
    end
    local enemies = workspace:FindFirstChild("Enemies")
    if enemies then
        for _, npc in pairs(enemies:GetChildren()) do
            CreateESP(npc)
        end
    end
end

-- ==================== FAST ATTACK ====================
local FastAttackEnabled = false
local FastAttackRange = 5000
local FastAttackConnection = nil

local Net = ReplicatedStorage:WaitForChild("Modules", 5) and
            ReplicatedStorage.Modules:WaitForChild("Net", 5)
local RegisterHit = Net and pcall(function() return Net["RE/RegisterHit"] end) and Net["RE/RegisterHit"]
local RegisterAttack = Net and pcall(function() return Net["RE/RegisterAttack"] end) and Net["RE/RegisterAttack"]

local function AttackMultipleTargets(targets)
    if not RegisterHit or not RegisterAttack then return end
    pcall(function()
        if not targets or #targets == 0 then return end
        local allTargets = {}
        for _, char in pairs(targets) do
            local head = char:FindFirstChild("Head")
            if head then table.insert(allTargets, {char, head}) end
        end
        if #allTargets == 0 then return end
        RegisterAttack:FireServer(0)
        RegisterHit:FireServer(allTargets[1][2], allTargets)
    end)
end

local function StartFastAttack()
    if FastAttackConnection then task.cancel(FastAttackConnection) end
    FastAttackConnection = task.spawn(function()
        while FastAttackEnabled do
            RunService.Stepped:Wait()
            local myChar = Players.LocalPlayer.Character
            local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
            if not myHRP then continue end
            local targets = {}
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= Players.LocalPlayer and player.Character then
                    local hum = player.Character:FindFirstChild("Humanoid")
                    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                    if hum and hrp and hum.Health > 0 and
                        (hrp.Position - myHRP.Position).Magnitude <= FastAttackRange then
                        table.insert(targets, player.Character)
                    end
                end
            end
            local enemies = workspace:FindFirstChild("Enemies")
            if enemies then
                for _, npc in pairs(enemies:GetChildren()) do
                    local hum = npc:FindFirstChild("Humanoid")
                    local hrp = npc:FindFirstChild("HumanoidRootPart")
                    if hum and hrp and hum.Health > 0 and
                        (hrp.Position - myHRP.Position).Magnitude <= FastAttackRange then
                        table.insert(targets, npc)
                    end
                end
            end
            if #targets > 0 then AttackMultipleTargets(targets) end
        end
    end)
end

-- ==================== GUI ====================
local pgui = Players.LocalPlayer:WaitForChild("PlayerGui")
if pgui:FindFirstChild("DivineHub_Premium") then pgui.DivineHub_Premium:Destroy() end

local screenGui = Instance.new("ScreenGui", pgui)
screenGui.Name = "DivineHub_Premium"
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame", screenGui)
local normalSize = UDim2.new(0, 420, 0, 550)
local minimizedSize = UDim2.new(0, 150, 0, 40)
mainFrame.Size = normalSize
mainFrame.Position = UDim2.new(0.5, -210, 0.15, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 28)
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.BorderSizePixel = 0

local gradient = Instance.new("UIGradient", mainFrame)
gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 40)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 25))
}

local corner = Instance.new("UICorner", mainFrame)
corner.CornerRadius = UDim.new(0, 12)

local stroke = Instance.new("UIStroke", mainFrame)
stroke.Color = Color3.fromRGB(100, 50, 255)
stroke.Thickness = 2

local topBar = Instance.new("Frame", mainFrame)
topBar.Size = UDim2.new(1, 0, 0, 50)
topBar.BackgroundColor3 = Color3.fromRGB(25, 15, 50)
topBar.BorderSizePixel = 0

local topBarGradient = Instance.new("UIGradient", topBar)
topBarGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 50, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 25, 150))
}

local topCorner = Instance.new("UICorner", topBar)
topCorner.CornerRadius = UDim.new(0, 12)

local logoLabel = Instance.new("TextLabel", topBar)
logoLabel.Size = UDim2.new(0, 40, 0, 40)
logoLabel.Position = UDim2.new(0, 10, 0.5, -20)
logoLabel.Text = "👑"
logoLabel.TextSize = 28
logoLabel.BackgroundTransparency = 1
logoLabel.Font = Enum.Font.GothamBold

local titleLabel = Instance.new("TextLabel", topBar)
titleLabel.Size = UDim2.new(0.6, 0, 1, 0)
titleLabel.Position = UDim2.new(0, 55, 0, 0)
titleLabel.Text = "DIVINE HUB PREMIUM"
titleLabel.TextColor3 = Color3.new(1, 1, 1)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 16
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.BackgroundTransparency = 1

local versionLabel = Instance.new("TextLabel", topBar)
versionLabel.Size = UDim2.new(0.3, 0, 0.5, 0)
versionLabel.Position = UDim2.new(0, 55, 0.5, 0)
versionLabel.Text = "v1.0 PREMIUM"
versionLabel.TextColor3 = Color3.fromRGB(150, 100, 255)
versionLabel.Font = Enum.Font.GothamBold
versionLabel.TextSize = 10
versionLabel.TextXAlignment = Enum.TextXAlignment.Left
versionLabel.BackgroundTransparency = 1

local function createControlBtn(text, position, color)
    local btn = Instance.new("TextButton", topBar)
    btn.Size = UDim2.new(0, 30, 0, 30)
    btn.Position = position
    btn.Text = text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.BackgroundColor3 = color
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 16
    btn.BorderSizePixel = 0
    local c = Instance.new("UICorner", btn)
    c.CornerRadius = UDim.new(0, 6)
    return btn
end

local closeBtn    = createControlBtn("✕", UDim2.new(1, -40,  0.5, -15), Color3.fromRGB(200, 50, 50))
local minimizeBtn = createControlBtn("−", UDim2.new(1, -75,  0.5, -15), Color3.fromRGB(100, 100, 150))
local maximizeBtn = createControlBtn("+", UDim2.new(1, -110, 0.5, -15), Color3.fromRGB(100, 100, 150))

local tabContainer = Instance.new("Frame", mainFrame)
tabContainer.Size = UDim2.new(1, -20, 0, 45)
tabContainer.Position = UDim2.new(0, 10, 0, 60)
tabContainer.BackgroundTransparency = 1

local tabLayout = Instance.new("UIListLayout", tabContainer)
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.Padding = UDim.new(0, 5)
tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local contentFrame = Instance.new("Frame", mainFrame)
contentFrame.Size = UDim2.new(1, -20, 1, -130)
contentFrame.Position = UDim2.new(0, 10, 0, 115)
contentFrame.BackgroundTransparency = 1

local function createPage(name)
    local p = Instance.new("ScrollingFrame", contentFrame)
    p.Name = name
    p.Size = UDim2.new(1, 0, 1, 0)
    p.BackgroundTransparency = 1
    p.BorderSizePixel = 0
    p.ScrollBarThickness = 4
    p.ScrollBarImageColor3 = Color3.fromRGB(100, 50, 255)
    p.Visible = false
    local layout = Instance.new("UIListLayout", p)
    layout.Padding = UDim.new(0, 8)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    return p
end

local combatPage = createPage("Combate")
local movePage   = createPage("Movimiento")
local sea2Page   = createPage("Sea2")
local sea3Page   = createPage("Sea3")

local function showPage(page)
    for _, v in pairs(contentFrame:GetChildren()) do
        if v:IsA("ScrollingFrame") then v.Visible = false end
    end
    page.Visible = true
end

local function createTab(name, page)
    local b = Instance.new("TextButton", tabContainer)
    b.Size = UDim2.new(0, 90, 0, 38)
    b.Text = name
    b.BackgroundColor3 = Color3.fromRGB(30, 20, 60)
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 11
    b.BorderSizePixel = 0
    local c = Instance.new("UICorner", b)
    c.CornerRadius = UDim.new(0, 8)
    local s = Instance.new("UIStroke", b)
    s.Color = Color3.fromRGB(100, 50, 255)
    s.Thickness = 1
    b.MouseButton1Click:Connect(function() showPage(page) end)
end

createTab("⚔️ Combate", combatPage)
createTab("🏃 Mov",     movePage)
createTab("🌊 Sea 2",   sea2Page)
createTab("🏰 Sea 3",   sea3Page)

showPage(combatPage)

local function addBtn(txt, color, parent)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0.95, 0, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(25, 20, 50)
    btn.Text = txt
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.BorderSizePixel = 0
    local c = Instance.new("UICorner", btn)
    c.CornerRadius = UDim.new(0, 8)
    local s = Instance.new("UIStroke", btn)
    s.Color = color
    s.Thickness = 2
    btn.MouseEnter:Connect(function()
        btn:TweenSize(UDim2.new(0.98, 0, 0, 42), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
    end)
    btn.MouseLeave:Connect(function()
        btn:TweenSize(UDim2.new(0.95, 0, 0, 40), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
    end)
    return btn
end

-- ===== COMBATE =====
local fBtn = addBtn("⚡ Fast Attack: OFF", Color3.fromRGB(255, 200, 0), combatPage)
fBtn.MouseButton1Click:Connect(function()
    FastAttackEnabled = not FastAttackEnabled
    fBtn.Text = FastAttackEnabled and "⚡ Fast Attack: ON" or "⚡ Fast Attack: OFF"
    if FastAttackEnabled then
        StartFastAttack()
    else
        if FastAttackConnection then task.cancel(FastAttackConnection) end
    end
end)

local espBtn = addBtn("👁️ ESP: OFF", Color3.fromRGB(255, 150, 100), combatPage)
espBtn.MouseButton1Click:Connect(function()
    ESPEnabled = not ESPEnabled
    espBtn.Text = ESPEnabled and "👁️ ESP: ON" or "👁️ ESP: OFF"
    UpdateESP()
end)

task.spawn(function()
    while true do
        task.wait(5)
        if ESPEnabled then UpdateESP() end
    end
end)

-- ===== MOVIMIENTO =====
local sBtn = addBtn("🚀 Speed Controller: OFF", Color3.fromRGB(0, 200, 200), movePage)

local speedPanel = Instance.new("Frame", screenGui)
speedPanel.Size = UDim2.new(0, 150, 0, 50)
speedPanel.Position = UDim2.new(0, 20, 0.45, 0)
speedPanel.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
speedPanel.Visible = false
speedPanel.Active = true
speedPanel.Draggable = true
speedPanel.BorderSizePixel = 0
local speedCorner = Instance.new("UICorner", speedPanel)
speedCorner.CornerRadius = UDim.new(0, 8)
local speedStroke = Instance.new("UIStroke", speedPanel)
speedStroke.Color = Color3.fromRGB(100, 200, 255)
speedStroke.Thickness = 2

local btnM = Instance.new("TextButton", speedPanel)
btnM.Size = UDim2.new(0, 35, 0, 35)
btnM.Position = UDim2.new(0.05, 0, 0.5, -17)
btnM.Text = "−"
btnM.BackgroundColor3 = Color3.fromRGB(50, 50, 100)
btnM.TextColor3 = Color3.new(1, 1, 1)
btnM.Font = Enum.Font.GothamBold
btnM.TextSize = 18
btnM.BorderSizePixel = 0
local btnMCorner = Instance.new("UICorner", btnM)
btnMCorner.CornerRadius = UDim.new(0, 6)

local sDisp = Instance.new("TextLabel", speedPanel)
sDisp.Size = UDim2.new(0, 50, 1, 0)
sDisp.Position = UDim2.new(0.35, 0, 0, 0)
sDisp.Text = "16"
sDisp.TextColor3 = Color3.fromRGB(100, 200, 255)
sDisp.Font = Enum.Font.GothamBold
sDisp.TextSize = 16
sDisp.BackgroundTransparency = 1

local btnP = Instance.new("TextButton", speedPanel)
btnP.Size = UDim2.new(0, 35, 0, 35)
btnP.Position = UDim2.new(0.6, 0, 0.5, -17)
btnP.Text = "+"
btnP.BackgroundColor3 = Color3.fromRGB(50, 50, 100)
btnP.TextColor3 = Color3.new(1, 1, 1)
btnP.Font = Enum.Font.GothamBold
btnP.TextSize = 18
btnP.BorderSizePixel = 0
local btnPCorner = Instance.new("UICorner", btnP)
btnPCorner.CornerRadius = UDim.new(0, 6)

local sVal, sAct = 16, false
sBtn.MouseButton1Click:Connect(function()
    sAct = not sAct
    speedPanel.Visible = sAct
    sBtn.Text = sAct and "🚀 Speed Controller: ON" or "🚀 Speed Controller: OFF"
end)
btnP.MouseButton1Click:Connect(function()
    sVal = math.clamp(sVal + 10, 16, 500)
    sDisp.Text = tostring(sVal)
end)
btnM.MouseButton1Click:Connect(function()
    sVal = math.clamp(sVal - 10, 16, 500)
    sDisp.Text = tostring(sVal)
end)

RunService.Heartbeat:Connect(function()
    if sAct then
        local char = Players.LocalPlayer.Character
        local hum = char and char:FindFirstChild("Humanoid")
        if hum and hum.MoveDirection.Magnitude > 0 then
            char:TranslateBy(hum.MoveDirection * (sVal / 55))
        end
    end
end)

local jBtn = addBtn("⬆️ Infinite Jump: OFF", Color3.fromRGB(100, 200, 255), movePage)
local iJ = false
jBtn.MouseButton1Click:Connect(function()
    iJ = not iJ
    jBtn.Text = iJ and "⬆️ Infinite Jump: ON" or "⬆️ Infinite Jump: OFF"
end)
UserInputService.JumpRequest:Connect(function()
    if iJ then
        local char = Players.LocalPlayer.Character
        local hum = char and char:FindFirstChild("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

local nBtn = addBtn("🔥 No Clip: OFF", Color3.fromRGB(200, 100, 255), movePage)
local ncl = false
nBtn.MouseButton1Click:Connect(function()
    ncl = not ncl
    nBtn.Text = ncl and "🔥 No Clip: ON" or "🔥 No Clip: OFF"
end)
RunService.Stepped:Connect(function()
    if ncl then
        local char = Players.LocalPlayer.Character
        if char then
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        end
    end
end)

local wowBtn = addBtn("💧 Walk on Water: OFF", Color3.fromRGB(0, 200, 255), movePage)
local walkWaterEnabled = false
wowBtn.MouseButton1Click:Connect(function()
    walkWaterEnabled = not walkWaterEnabled
    wowBtn.Text = walkWaterEnabled and "💧 Walk on Water: ON" or "💧 Walk on Water: OFF"
end)
RunService.RenderStepped:Connect(function()
    local char = Players.LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if walkWaterEnabled and hrp then
        if hrp.Position.Y >= 9.5 and hrp.AssemblyLinearVelocity.Y <= 0 then
            local waterPart = workspace:FindFirstChild("DivineWaterSolid")
            if not waterPart then
                waterPart = Instance.new("Part", workspace)
                waterPart.Name = "DivineWaterSolid"
                waterPart.Size = Vector3.new(20, 1, 20)
                waterPart.Transparency = 1
                waterPart.Anchored = true
                waterPart.CanCollide = true
                waterPart.CanQuery = false
            end
            waterPart.CFrame = CFrame.new(hrp.Position.X, 9.2, hrp.Position.Z)
        else
            local w = workspace:FindFirstChild("DivineWaterSolid")
            if w then w:Destroy() end
        end
    else
        local w = workspace:FindFirstChild("DivineWaterSolid")
        if w then w:Destroy() end
    end
end)

-- ===== TELEPORTS SEA 2 =====
addBtn("🗺️ Barco Maldito", Color3.fromRGB(0, 200, 150), sea2Page).MouseButton1Click:Connect(function()
    Players.LocalPlayer.Character:PivotTo(CFrame.new(923, 126, 32852))
end)

-- ===== TELEPORTS SEA 3 =====
addBtn("🏰 Castillo", Color3.fromRGB(150, 100, 255), sea3Page).MouseButton1Click:Connect(function()
    Players.LocalPlayer.Character:PivotTo(CFrame.new(-5085, 316, -3156))
end)
addBtn("🏛️ Mansión", Color3.fromRGB(255, 170, 0), sea3Page).MouseButton1Click:Connect(function()
    Players.LocalPlayer.Character:PivotTo(CFrame.new(-12463, 375, -7523))
end)

-- ===== CONTROLES VENTANA =====
closeBtn.MouseButton1Click:Connect(function()
    ESPEnabled = false
    ClearESP()
    local w = workspace:FindFirstChild("DivineWaterSolid")
    if w then w:Destroy() end
    screenGui:Destroy()
end)
minimizeBtn.MouseButton1Click:Connect(function()
    contentFrame.Visible = false
    tabContainer.Visible = false
    mainFrame:TweenSize(minimizedSize, Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.3, true)
end)
maximizeBtn.MouseButton1Click:Connect(function()
    mainFrame:TweenSize(normalSize, Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.3, true)
    task.wait(0.2)
    contentFrame.Visible = true
    tabContainer.Visible = true
end)

print("✅ Divine Hub Premium cargado correctamente")
