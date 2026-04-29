local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "TOMMY HUB",
   LoadingTitle = "TOMMY HUB",
   LoadingSubtitle = "Cargando interfaz premium...",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "TommyHubConfig", 
      FileName = "Config"
   },
   Discord = {
      Enabled = false,
   },
   KeySystem = false, 
})
-- ===== COMBATE =====
local fBtn = addBtn("⚡ Fast Attack: OFF", Color3.fromRGB(255, 200, 0), combatPage)
fBtn.MouseButton1Click:Connect(function() 
    FastAttackEnabled = not FastAttackEnabled
    fBtn.Text = FastAttackEnabled and "⚡ Fast Attack: ON" or "⚡ Fast Attack: OFF"
    if FastAttackEnabled then StartFastAttack() else if FastAttackConnection then task.cancel(FastAttackConnection) end end 
end)
local HitboxSlider = CombatTab:CreateSlider({
   Name = "📏 Rango de Hitbox",
   Range = {100, 5000},
   Increment = 100,
   Suffix = " studs",
   CurrentValue = 2048,
   Flag = "HitboxRange",
   Callback = function(Value)
      print("Rango: " .. Value)
   end,
})

local ESPToggle = CombatTab:CreateToggle({
   Name = "👁️ ESP",
   CurrentValue = false,
   Flag = "ESP",
   Callback = function(Value)
      print("ESP: " .. tostring(Value))
   end,
})

-- ==================== TAB: MOVIMIENTO ====================
local MovementTab = Window:CreateTab("🏃 Movimiento", 4483362458)

local SpeedSlider = MovementTab:CreateSlider({
   Name = "🚀 Velocidad",
   Range = {16, 500},
   Increment = 10,
   Suffix = " studs/s",
   CurrentValue = 16,
   Flag = "Speed",
   Callback = function(Value)
      print("Velocidad: " .. Value)
   end,
})

local InfiniteJumpToggle = MovementTab:CreateToggle({
   Name = "⬆️ Salto Infinito",
   CurrentValue = false,
   Flag = "InfiniteJump",
   Callback = function(Value)
      print("Salto Infinito: " .. tostring(Value))
   end,
})

local NoClipToggle = MovementTab:CreateToggle({
   Name = "🔥 No Clip",
   CurrentValue = false,
   Flag = "NoClip",
   Callback = function(Value)
      print("No Clip: " .. tostring(Value))
   end,
})

local WalkOnWaterToggle = MovementTab:CreateToggle({
   Name = "💧 Caminar en Agua",
   CurrentValue = false,
   Flag = "WalkOnWater",
   Callback = function(Value)
      print("Caminar en Agua: " .. tostring(Value))
   end,
})

-- ==================== TAB: SEA 2 ====================
local Sea2Tab = Window:CreateTab("🌊 Sea 2", 4483362458)

local Button1 = Sea2Tab:CreateButton({
   Name = "🗺️ Barco Maldito",
   Callback = function()
      if game.Players.LocalPlayer.Character then
         game.Players.LocalPlayer.Character:PivotTo(CFrame.new(923, 126, 32852))
      end
   end,
})

-- ==================== TAB: SEA 3 ====================
local Sea3Tab = Window:CreateTab("🏰 Sea 3", 4483362458)

local Button2 = Sea3Tab:CreateButton({
   Name = "🏰 Castillo",
   Callback = function()
      if game.Players.LocalPlayer.Character then
         game.Players.LocalPlayer.Character:PivotTo(CFrame.new(-5085, 316, -3156))
      end
   end,
})

local Button3 = Sea3Tab:CreateButton({
   Name = "🏛️ Mansión",
   Callback = function()
      if game.Players.LocalPlayer.Character then
         game.Players.LocalPlayer.Character:PivotTo(CFrame.new(-12463, 375, -7523))
      end
   end,
})

-- ==================== LÓGICA DE FUNCIONES ====================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- ESP
local ESPObjects = {}

local function CreateESP(target)
    if not target:FindFirstChild("Head") then return end
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "TommyESP"
    billboard.Adornee = target:FindFirstChild("Head")
    billboard.Size = UDim2.new(0, 100, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = target:FindFirstChild("Head")

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Text = target.Name
    label.Font = "GothamBold"
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
    if not Rayfield:FindFirstChild("Flags").ESP.Value then return end
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= Players.LocalPlayer and p.Character then
            CreateESP(p.Character)
        end
    end
end

-- Actualizar ESP cada 5 segundos
task.spawn(function()
    while true do 
        task.wait(5) 
        UpdateESP()
    end
end)

-- INFINITE JUMP
UserInputService.JumpRequest:Connect(function() 
    if Rayfield:FindFirstChild("Flags").InfiniteJump.Value and Players.LocalPlayer.Character:FindFirstChild("Humanoid") then 
        Players.LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end 
end)

-- NO CLIP
RunService.Stepped:Connect(function() 
    if Rayfield:FindFirstChild("Flags").NoClip.Value then 
        for _, v in pairs(Players.LocalPlayer.Character:GetDescendants()) do 
            if v:IsA("BasePart") then v.CanCollide = false end 
        end 
    end 
end)

-- SPEED
RunService.Heartbeat:Connect(function() 
    if Rayfield:FindFirstChild("Flags").Speed.Value > 16 and Players.LocalPlayer.Character:FindFirstChild("Humanoid") then 
        local hum = Players.LocalPlayer.Character.Humanoid 
        if hum.MoveDirection.Magnitude > 0 then 
            Players.LocalPlayer.Character:TranslateBy(hum.MoveDirection * (Rayfield:FindFirstChild("Flags").Speed.Value/55))
        end 
    end 
end)

-- WALK ON WATER
RunService.RenderStepped:Connect(function()
    local char = Players.LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    
    if Rayfield:FindFirstChild("Flags").WalkOnWater.Value and hrp then
        if hrp.Position.Y >= 9.5 and hrp.Velocity.Y <= 0 then
            local waterPart = workspace:FindFirstChild("TommyWaterSolid")
            if not waterPart then
                waterPart = Instance.new("Part", workspace)
                waterPart.Name = "TommyWaterSolid"
                waterPart.Size = Vector3.new(20, 1, 20)
                waterPart.Transparency = 1
                waterPart.Anchored = true
                waterPart.CanCollide = true
                waterPart.CanQuery = false
            end
            waterPart.CFrame = CFrame.new(hrp.Position.X, 9.2, hrp.Position.Z)
        else
            if workspace:FindFirstChild("TommyWaterSolid") then 
                workspace.TommyWaterSolid:Destroy() 
            end
        end
    else
        if workspace:FindFirstChild("TommyWaterSolid") then 
            workspace.TommyWaterSolid:Destroy() 
        end
    end
end)

Rayfield:LoadConfiguration()
