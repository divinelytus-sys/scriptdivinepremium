-- DIVINE HUB PREMIUM | loadstring ready
-- loadstring(game:HttpGet("URL_RAW_AQUI"))()

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
local FlyEnabled = false
local FlySpeed = 50
local FlyControl = {f = 0, b = 0, l = 0, r = 0}

-- ==================== LÓGICA DE VUELO (FLY) ====================
-- Optimizada para no buguear el Fast Attack
local function StartFly()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    
    local bg = Instance.new("BodyGyro", hrp)
    bg.P = 9e4
    bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
    bg.cframe = hrp.CFrame
    
    local bv = Instance.new("BodyVelocity", hrp)
    bv.velocity = Vector3.new(0, 0.1, 0)
    bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
    
    hum.PlatformStand = true

    task.spawn(function()
        while FlyEnabled and char.Parent and hum.Health > 0 do
            RunService.RenderStepped:Wait()
            
            -- Detectar dirección de cámara para el vuelo
            local camera = workspace.CurrentCamera
            if FlyControl.l + FlyControl.r ~= 0 or FlyControl.f + FlyControl.b ~= 0 then
                bv.velocity = ((camera.CFrame.LookVector * (FlyControl.f + FlyControl.b)) + 
                              ((camera.CFrame * CFrame.new(FlyControl.l + FlyControl.r, (FlyControl.f + FlyControl.b) * 0.2, 0).Position) - 
                              camera.CFrame.Position)) * FlySpeed
            else
                bv.velocity = Vector3.new(0, 0.1, 0)
            end
            bg.CFrame = camera.CFrame
        end
        -- Limpieza al apagar
        bg:Destroy()
        bv:Destroy()
        hum.PlatformStand = false
    end)
end

-- Controles de teclado para el Fly
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.W then FlyControl.f = 1
    elseif input.KeyCode == Enum.KeyCode.S then FlyControl.b = -1
    elseif input.KeyCode == Enum.KeyCode.A then FlyControl.l = -1
    elseif input.KeyCode == Enum.KeyCode.D then FlyControl.r = 1 end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.W then FlyControl.f = 0
    elseif input.KeyCode == Enum.KeyCode.S then FlyControl.b = 0
    elseif input.KeyCode == Enum.KeyCode.A then FlyControl.l = 0
    elseif input.KeyCode == Enum.KeyCode.D then FlyControl.r = 0 end
end)

-- ==================== ESP ====================
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
    for _, obj in pairs(ESPObjects) do if obj then obj:Destroy() end end
    ESPObjects = {}
end

local function UpdateESP()
    ClearESP()
    if not ESPEnabled then return end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then CreateESP(p.Character) end
    end
end

-- ==================== FAST ATTACK ====================
-- Se mantiene tu lógica original, solo aseguramos compatibilidad
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
            local myChar = LocalPlayer.Character
            local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
            if not myHRP then continue end
            local targets = {}
            -- Buscar jugadores y NPCs
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                    if hrp and (hrp.Position - myHRP.Position).Magnitude <= FastAttackRange then
                        table.insert(targets, player.Character)
                    end
                end
            end
            if #targets > 0 then AttackMultipleTargets(targets) end
        end
    end)
end

-- ==================== GUI (ESTILO MEJORADO) ====================
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

local corner = Instance.new("UICorner", mainFrame)
corner.CornerRadius = UDim.new(0, 12)

local stroke = Instance.new("UIStroke", mainFrame)
stroke.Color = Color3.fromRGB(100, 50, 255)
stroke.Thickness = 2

-- TOP BAR
local topBar = Instance.new("Frame", mainFrame)
topBar.Size = UDim2.new(1, 0, 0, 50)
topBar.BackgroundColor3 = Color3.fromRGB(25, 15, 50)

local titleLabel = Instance.new("TextLabel", topBar)
titleLabel.Size = UDim2.new(1, -100, 1, 0)
titleLabel.Position = UDim2.new(0, 55, 0, 0)
titleLabel.Text = "DIVINE HUB PREMIUM"
titleLabel.TextColor3 = Color3.new(1, 1, 1)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 16
titleLabel.BackgroundTransparency = 1
titleLabel.TextXAlignment = Enum.TextXAlignment.Left

-- CONTENEDOR DE PAGINAS
local contentFrame = Instance.new("Frame", mainFrame)
contentFrame.Size = UDim2.new(1, -20, 1, -130)
contentFrame.Position = UDim2.new(0, 10, 0, 115)
contentFrame.BackgroundTransparency = 1

local combatPage = Instance.new("ScrollingFrame", contentFrame)
combatPage.Size = UDim2.new(1, 0, 1, 0)
combatPage.BackgroundTransparency = 1
combatPage.ScrollBarThickness = 2
local layout = Instance.new("UIListLayout", combatPage)
layout.Padding = UDim.new(0, 8)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- FUNCION PARA AGREGAR BOTONES
local function addBtn(txt, color, parent)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0.95, 0, 0, 45)
    btn.BackgroundColor3 = Color3.fromRGB(25, 20, 50)
    btn.Text = txt
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    local c = Instance.new("UICorner", btn)
    local s = Instance.new("UIStroke", btn)
    s.Color = color
    s.Thickness = 2
    return btn
end

-- ==================== INTEGRACIÓN DE BOTONES ====================

-- BOTÓN FLY (En Combate como pediste)
local flyBtn = addBtn("✈️ Fly: OFF", Color3.fromRGB(0, 255, 150), combatPage)
flyBtn.MouseButton1Click:Connect(function()
    FlyEnabled = not FlyEnabled
    flyBtn.Text = FlyEnabled and "✈️ Fly: ON" or "✈️ Fly: OFF"
    if FlyEnabled then
        StartFly()
    end
end)

-- BOTÓN FAST ATTACK
local fBtn = addBtn("⚡ Fast Attack: OFF", Color3.fromRGB(255, 200, 0), combatPage)
fBtn.MouseButton1Click:Connect(function()
    FastAttackEnabled = not FastAttackEnabled
    fBtn.Text = FastAttackEnabled and "⚡ Fast Attack: ON" or "⚡ Fast Attack: OFF"
    if FastAttackEnabled then StartFastAttack() end
end)

-- BOTÓN ESP
local espBtn = addBtn("👁️ ESP: OFF", Color3.fromRGB(255, 50, 50), combatPage)
espBtn.MouseButton1Click:Connect(function()
    ESPEnabled = not ESPEnabled
    espBtn.Text = ESPEnabled and "👁️ ESP: ON" or "👁️ ESP: OFF"
    UpdateESP()
end)

-- BOTÓN CERRAR
local closeBtn = Instance.new("TextButton", topBar)
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -40, 0.5, -15)
closeBtn.Text = "✕"
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.MouseButton1Click:Connect(function()
    FlyEnabled = false
    screenGui:Destroy()
end)

print("✅ Divine Hub Premium con FLY integrado correctamente")
