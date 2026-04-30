-- DIVINE HUB PREMIUM | loadstring ready
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- ==================== VARIABLES DE ESTADO ====================
local ESPEnabled = false
local ESPObjects = {}
local FastAttackEnabled = false
local FastAttackRange = 5000
local FastAttackConnection = nil
local speeds = 1
local nowe = false
local tpwalking = false

-- ==================== ESP ====================
local function ClearESP()
    for _, obj in pairs(ESPObjects) do if obj then obj:Destroy() end end
    ESPObjects = {}
end

local function CreateESP(target)
    if not target:FindFirstChild("Head") then return end
    local b = Instance.new("BillboardGui", target.Head)
    b.Size = UDim2.new(0, 80, 0, 40)
    b.AlwaysOnTop = true
    local l = Instance.new("TextLabel", b)
    l.Size = UDim2.new(1, 0, 1, 0)
    l.BackgroundTransparency = 1
    l.Text = target.Name
    l.TextColor3 = Color3.new(0, 1, 1)
    l.Font = Enum.Font.GothamBold
    l.TextSize = 12
    table.insert(ESPObjects, b)
end

local function UpdateESP()
    ClearESP()
    if not ESPEnabled then return end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then CreateESP(p.Character) end
    end
end

-- ==================== FAST ATTACK ====================
local Net = ReplicatedStorage:WaitForChild("Modules", 5) and ReplicatedStorage.Modules:WaitForChild("Net", 5)
local RegisterHit = Net and pcall(function() return Net["RE/RegisterHit"] end) and Net["RE/RegisterHit"]
local RegisterAttack = Net and pcall(function() return Net["RE/RegisterAttack"] end) and Net["RE/RegisterAttack"]

local function AttackMultipleTargets(targets)
    if not RegisterHit or not RegisterAttack then return end
    pcall(function()
        local allTargets = {}
        for _, char in pairs(targets) do
            local head = char:FindFirstChild("Head")
            if head then table.insert(allTargets, {char, head}) end
        end
        RegisterAttack:FireServer(0)
        RegisterHit:FireServer(allTargets[1][2], allTargets)
    end)
end

local function StartFastAttack()
    if FastAttackConnection then task.cancel(FastAttackConnection) end
    FastAttackConnection = task.spawn(function()
        while FastAttackEnabled do
            RunService.Stepped:Wait()
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then continue end
            local targets = {}
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local h = player.Character:FindFirstChild("HumanoidRootPart")
                    if h and (h.Position - hrp.Position).Magnitude <= FastAttackRange then
                        table.insert(targets, player.Character)
                    end
                end
            end
            if #targets > 0 then AttackMultipleTargets(targets) end
        end
    end)
end

-- ==================== GUI PRINCIPAL ====================
local pgui = LocalPlayer:WaitForChild("PlayerGui")
if pgui:FindFirstChild("DivineHub_Premium") then pgui.DivineHub_Premium:Destroy() end

local screenGui = Instance.new("ScreenGui", pgui)
screenGui.Name = "DivineHub_Premium"
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 420, 0, 550)
mainFrame.Position = UDim2.new(0.5, -210, 0.15, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 28)
mainFrame.Active = true
mainFrame.Draggable = true
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)
local stroke = Instance.new("UIStroke", mainFrame)
stroke.Color = Color3.fromRGB(100, 50, 255)
stroke.Thickness = 2

-- TOP BAR
local topBar = Instance.new("Frame", mainFrame)
topBar.Size = UDim2.new(1, 0, 0, 50)
topBar.BackgroundColor3 = Color3.fromRGB(25, 15, 50)
Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 12)
local title = Instance.new("TextLabel", topBar)
title.Size = UDim2.new(1, 0, 1, 0)
title.Position = UDim2.new(0, 50, 0, 0)
title.Text = "DIVINE HUB PREMIUM"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.BackgroundTransparency = 1
title.TextXAlignment = "Left"

-- CONTENEDOR DE PAGINAS
local tabContainer = Instance.new("Frame", mainFrame)
tabContainer.Size = UDim2.new(1, -20, 0, 45)
tabContainer.Position = UDim2.new(0, 10, 0, 60)
tabContainer.BackgroundTransparency = 1
local tabLayout = Instance.new("UIListLayout", tabContainer)
tabLayout.FillDirection = "Horizontal"
tabLayout.Padding = UDim.new(0, 5)

local contentFrame = Instance.new("Frame", mainFrame)
contentFrame.Size = UDim2.new(1, -20, 1, -130)
contentFrame.Position = UDim2.new(0, 10, 0, 115)
contentFrame.BackgroundTransparency = 1

local function createPage(name)
    local p = Instance.new("ScrollingFrame", contentFrame)
    p.Name = name
    p.Size = UDim2.new(1, 0, 1, 0)
    p.BackgroundTransparency = 1
    p.ScrollBarThickness = 2
    p.Visible = false
    Instance.new("UIListLayout", p).Padding = UDim.new(0, 8)
    return p
end

local combatPage = createPage("Combate")
local movePage = createPage("Movimiento")
local sea2Page = createPage("Sea2")
local sea3Page = createPage("Sea3")
local visualsPage = createPage("Visuals")

local function addBtn(txt, color, parent)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0.95, 0, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(25, 20, 50)
    btn.Text = txt
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = "GothamBold"
    btn.TextSize = 12
    Instance.new("UICorner", btn)
    local s = Instance.new("UIStroke", btn)
    s.Color = color
    s.Thickness = 2
    return btn
end

local function createTab(name, page)
    local b = addBtn(name, Color3.fromRGB(100, 50, 255), tabContainer)
    b.Size = UDim2.new(0, 78, 0, 35)
    b.MouseButton1Click:Connect(function()
        for _, v in pairs(contentFrame:GetChildren()) do v.Visible = false end
        page.Visible = true
    end)
end

createTab("⚔️ Combat", combatPage)
createTab("🏃 Mov", movePage)
createTab("🌊 Sea 2", sea2Page)
createTab("🏰 Sea 3", sea3Page)
createTab("🖥️ Visuals", visualsPage)
combatPage.Visible = true

-- ==================== MINI UI FLY (GUI V3 STYLE) ====================
local flyWindow = Instance.new("Frame", screenGui)
flyWindow.Size = UDim2.new(0, 190, 0, 150)
flyWindow.Position = UDim2.new(0.1, 0, 0.4, 0)
flyWindow.BackgroundColor3 = Color3.fromRGB(163, 255, 137)
flyWindow.Visible = false
flyWindow.Active = true
flyWindow.Draggable = true
Instance.new("UIStroke", flyWindow).Color = Color3.fromRGB(100, 255, 200)

local flyTitle = Instance.new("TextLabel", flyWindow)
flyTitle.Size = UDim2.new(1, 0, 0, 25)
flyTitle.BackgroundColor3 = Color3.fromRGB(242, 60, 255)
flyTitle.Text = "FLY GUI V3 - DIVINE"
flyTitle.TextSize = 12
flyTitle.Font = "SourceSansBold"

local flyOnBtn = Instance.new("TextButton", flyWindow)
flyOnBtn.Size = UDim2.new(0.8, 0, 0, 30)
flyOnBtn.Position = UDim2.new(0.1, 0, 0.2, 0)
flyOnBtn.BackgroundColor3 = Color3.fromRGB(255, 249, 74)
flyOnBtn.Text = "FLY: OFF"

local speedLbl = Instance.new("TextLabel", flyWindow)
speedLbl.Size = UDim2.new(1, 0, 0, 20)
speedLbl.Position = UDim2.new(0, 0, 0.45, 0)
speedLbl.Text = "Speed: 1"
speedLbl.BackgroundTransparency = 1

local plusBtn = Instance.new("TextButton", flyWindow)
plusBtn.Text = "+"; plusBtn.Size = UDim2.new(0.4, 0, 0, 25); plusBtn.Position = UDim2.new(0.55, 0, 0.6, 0); plusBtn.BackgroundColor3 = Color3.fromRGB(133, 145, 255)
local minusBtn = Instance.new("TextButton", flyWindow)
minusBtn.Text = "-"; minusBtn.Size = UDim2.new(0.4, 0, 0, 25); minusBtn.Position = UDim2.new(0.05, 0, 0.6, 0); minusBtn.BackgroundColor3 = Color3.fromRGB(123, 255, 247)

local upBtn = Instance.new("TextButton", flyWindow)
upBtn.Text = "UP"; upBtn.Size = UDim2.new(0.45, 0, 0, 20); upBtn.Position = UDim2.new(0.05, 0, 0.8, 0); upBtn.BackgroundColor3 = Color3.fromRGB(79, 255, 152)
local downBtn = Instance.new("TextButton", flyWindow)
downBtn.Text = "DOWN"; downBtn.Size = UDim2.new(0.45, 0, 0, 20); downBtn.Position = UDim2.new(0.5, 0, 0.8, 0); downBtn.BackgroundColor3 = Color3.fromRGB(215, 255, 121)

-- LÓGICA DE VUELO (SIN BUG DE CLICK)
local function getMoveDirection()
    local dir = Vector3.new(0,0,0)
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += workspace.CurrentCamera.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= workspace.CurrentCamera.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += workspace.CurrentCamera.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= workspace.CurrentCamera.CFrame.RightVector end
    return dir.Unit
end

local function StartTpWalk()
    tpwalking = true
    task.spawn(function()
        while tpwalking do
            local hb = RunService.Heartbeat:Wait()
            local chr = LocalPlayer.Character
            if nowe and chr then
                local dir = getMoveDirection()
                if dir.Magnitude > 0 then
                    chr:TranslateBy(dir * (speeds * 0.5))
                end
            end
        end
    end)
end

flyOnBtn.MouseButton1Click:Connect(function()
    nowe = not nowe
    flyOnBtn.Text = nowe and "FLY: ON" or "FLY: OFF"
    local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if nowe then
        StartTpWalk()
        LocalPlayer.Character.Animate.Disabled = true
        hum:ChangeState(Enum.HumanoidStateType.Swimming)
        task.spawn(function()
            local t = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local bv = Instance.new("BodyVelocity", t); bv.MaxForce = Vector3.new(9e9,9e9,9e9); bv.Velocity = Vector3.new(0,0.1,0)
            while nowe do RunService.RenderStepped:Wait(); bv.Velocity = Vector3.new(0,0.1,0) end
            bv:Destroy()
        end)
    else
        tpwalking = false
        LocalPlayer.Character.Animate.Disabled = false
        hum:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
    end
end)

plusBtn.MouseButton1Click:Connect(function() speeds += 1; speedLbl.Text = "Speed: "..speeds end)
minusBtn.MouseButton1Click:Connect(function() if speeds > 1 then speeds -= 1; speedLbl.Text = "Speed: "..speeds end end)
upBtn.MouseButton1Down:Connect(function() while UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do task.wait(); LocalPlayer.Character.HumanoidRootPart.CFrame *= CFrame.new(0,1,0) end end)
downBtn.MouseButton1Down:Connect(function() while UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do task.wait(); LocalPlayer.Character.HumanoidRootPart.CFrame *= CFrame.new(0,-1,0) end end)

-- ==================== BOTONES COMBATE ====================
addBtn("✈️ Abrir Menú Fly", Color3.fromRGB(0, 255, 150), combatPage).MouseButton1Click:Connect(function()
    flyWindow.Visible = not flyWindow.Visible
end)

local fBtn = addBtn("⚡ Fast Attack: OFF", Color3.fromRGB(255, 200, 0), combatPage)
fBtn.MouseButton1Click:Connect(function()
    FastAttackEnabled = not FastAttackEnabled
    fBtn.Text = FastAttackEnabled and "⚡ Fast Attack: ON" or "⚡ Fast Attack: OFF"
    if FastAttackEnabled then StartFastAttack() end
end)

addBtn("👁️ ESP: OFF", Color3.fromRGB(255, 100, 100), combatPage).MouseButton1Click:Connect(function()
    ESPEnabled = not ESPEnabled
    UpdateESP()
end)

-- ==================== TELEPORTS SEA 3 (Mansion Restaurada) ====================
addBtn("🏰 Castillo", Color3.fromRGB(150, 100, 255), sea3Page).MouseButton1Click:Connect(function()
    LocalPlayer.Character:PivotTo(CFrame.new(-5085, 316, -3156))
end)
addBtn("🏛️ Mansión", Color3.fromRGB(255, 170, 0), sea3Page).MouseButton1Click:Connect(function()
    LocalPlayer.Character:PivotTo(CFrame.new(-12463, 375, -7523)) --
end)

-- ==================== VISUALS (FPS Boost Restaurado) ====================
addBtn("🚀 Boost FPS: OFF", Color3.fromRGB(0, 220, 120), visualsPage).MouseButton1Click:Connect(function()
    local l = game:GetService("Lighting")
    l.GlobalShadows = false; l.Brightness = 2
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("ParticleEmitter") or v:IsA("Fire") or v:IsA("Smoke") then v.Enabled = false end
    end
    settings().Rendering.QualityLevel = 1
    print("FPS Boosted")
end)

-- BOTÓN CERRAR HUB
local closeBtn = Instance.new("TextButton", topBar)
closeBtn.Text = "X"; closeBtn.Size = UDim2.new(0, 30, 0, 30); closeBtn.Position = UDim2.new(1, -40, 0.5, -15); closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.MouseButton1Click:Connect(function() screenGui:Destroy() end)

print("✅ Divine Hub Premium con Fly Menu Independiente")
