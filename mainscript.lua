-- DIVINE HUB PREMIUM | Gold Edition
-- loadstring(game:HttpGet("URL_RAW_AQUI"))()

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService  = game:GetService("UserInputService")
local RunService        = game:GetService("RunService")
local TweenService      = game:GetService("TweenService")

-- ══════════════════════════════════════════
-- PALETA DORADA
-- ══════════════════════════════════════════
local GOLD       = Color3.fromRGB(212, 175,  55)
local GOLD_LT    = Color3.fromRGB(255, 220, 100)
local GOLD_DK    = Color3.fromRGB(140, 112,  30)
local GOLD_FAINT = Color3.fromRGB(40,  34,  10)
local BG_MAIN    = Color3.fromRGB(10,   9,  14)
local BG_CARD    = Color3.fromRGB(20,  19,  26)
local BG_HOVER   = Color3.fromRGB(30,  28,  38)
local BG_NAV     = Color3.fromRGB(8,    7,  11)
local WHITE      = Color3.fromRGB(240, 235, 215)
local DIM        = Color3.fromRGB(110, 102,  76)
local RED        = Color3.fromRGB(210,  55,  55)

-- ══════════════════════════════════════════
-- HELPERS
-- ══════════════════════════════════════════
local TS = TweenService
local function tween(obj, t, props)
    TS:Create(obj, TweenInfo.new(t, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

local function corner(p, r)
    local c = Instance.new("UICorner", p)
    c.CornerRadius = UDim.new(0, r or 8)
end

local function stroke(p, col, th)
    local s = Instance.new("UIStroke", p)
    s.Color = col; s.Thickness = th or 1
    return s
end

local function label(parent, txt, size, col, font, xa)
    local l = Instance.new("TextLabel", parent)
    l.BackgroundTransparency = 1
    l.Text = txt
    l.TextSize = size
    l.TextColor3 = col or WHITE
    l.Font = font or Enum.Font.GothamBold
    l.TextXAlignment = xa or Enum.TextXAlignment.Left
    l.TextYAlignment = Enum.TextYAlignment.Center
    return l
end

-- ══════════════════════════════════════════
-- ESP
-- ══════════════════════════════════════════
local ESPEnabled = false
local ESPObjects = {}

local function CreateESP(target)
    if not target:FindFirstChild("Head") then return end
    local bb = Instance.new("BillboardGui")
    bb.Name = "DivineESP"; bb.Adornee = target.Head
    bb.Size = UDim2.new(0,120,0,26); bb.StudsOffset = Vector3.new(0,3,0)
    bb.AlwaysOnTop = true; bb.Parent = target.Head
    local bg = Instance.new("Frame", bb)
    bg.Size = UDim2.new(1,0,1,0)
    bg.BackgroundColor3 = Color3.fromRGB(0,0,0)
    bg.BackgroundTransparency = 0.45
    corner(bg, 4); stroke(bg, GOLD_DK, 1)
    local lbl = Instance.new("TextLabel", bg)
    lbl.Size = UDim2.new(1,0,1,0); lbl.BackgroundTransparency = 1
    lbl.Text = "✦ "..target.Name; lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 11; lbl.TextColor3 = GOLD_LT; lbl.TextStrokeTransparency = 0.5
    table.insert(ESPObjects, bb)
end

local function ClearESP()
    for _, o in pairs(ESPObjects) do if o then o:Destroy() end end
    ESPObjects = {}
end

local function UpdateESP()
    ClearESP()
    if not ESPEnabled then return end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= Players.LocalPlayer and p.Character then CreateESP(p.Character) end
    end
    local en = workspace:FindFirstChild("Enemies")
    if en then for _, n in pairs(en:GetChildren()) do CreateESP(n) end end
end

-- ══════════════════════════════════════════
-- FAST ATTACK
-- ══════════════════════════════════════════
local FastAttackEnabled = false
local FastAttackRange   = 5000
local FAConn            = nil

local Net = ReplicatedStorage:WaitForChild("Modules", 5) and
            ReplicatedStorage.Modules:WaitForChild("Net", 5)
local RegHit  = Net and pcall(function() return Net["RE/RegisterHit"] end)    and Net["RE/RegisterHit"]
local RegAtk  = Net and pcall(function() return Net["RE/RegisterAttack"] end) and Net["RE/RegisterAttack"]

local function DoAttack(targets)
    if not RegHit or not RegAtk then return end
    pcall(function()
        if #targets == 0 then return end
        local all = {}
        for _, c in pairs(targets) do
            local h = c:FindFirstChild("Head")
            if h then table.insert(all, {c, h}) end
        end
        if #all == 0 then return end
        RegAtk:FireServer(0); RegHit:FireServer(all[1][2], all)
    end)
end

local function StartFA()
    if FAConn then task.cancel(FAConn) end
    FAConn = task.spawn(function()
        while FastAttackEnabled do
            RunService.Stepped:Wait()
            local myC = Players.LocalPlayer.Character
            local myH = myC and myC:FindFirstChild("HumanoidRootPart")
            if not myH then continue end
            local t = {}
            for _, pl in pairs(Players:GetPlayers()) do
                if pl ~= Players.LocalPlayer and pl.Character then
                    local hum = pl.Character:FindFirstChild("Humanoid")
                    local hrp = pl.Character:FindFirstChild("HumanoidRootPart")
                    if hum and hrp and hum.Health > 0 and
                        (hrp.Position-myH.Position).Magnitude <= FastAttackRange then
                        table.insert(t, pl.Character)
                    end
                end
            end
            local en = workspace:FindFirstChild("Enemies")
            if en then
                for _, n in pairs(en:GetChildren()) do
                    local hum = n:FindFirstChild("Humanoid")
                    local hrp = n:FindFirstChild("HumanoidRootPart")
                    if hum and hrp and hum.Health > 0 and
                        (hrp.Position-myH.Position).Magnitude <= FastAttackRange then
                        table.insert(t, n)
                    end
                end
            end
            if #t > 0 then DoAttack(t) end
        end
    end)
end

-- ══════════════════════════════════════════
-- GUI ROOT
-- ══════════════════════════════════════════
local pgui = Players.LocalPlayer:WaitForChild("PlayerGui")
if pgui:FindFirstChild("DivineGold") then pgui.DivineGold:Destroy() end

local SG = Instance.new("ScreenGui", pgui)
SG.Name = "DivineGold"; SG.ResetOnSpawn = false
SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- ══════════════════════════════════════════
-- VENTANA PRINCIPAL
-- SIN ClipsDescendants, SIN animación de Size en apertura
-- ══════════════════════════════════════════
local W, H = 430, 530
local FULL = UDim2.new(0,W,0,H)
local MINI = UDim2.new(0,200,0,50)

local win = Instance.new("Frame", SG)
win.Name = "Win"; win.Size = FULL
win.Position = UDim2.new(0.5,-W/2, 0.1, 0)
win.BackgroundColor3 = BG_MAIN
win.Active = true; win.Draggable = true
win.BorderSizePixel = 0
corner(win, 12)
stroke(win, GOLD_DK, 1.5)

-- gradiente de fondo
local bg = Instance.new("UIGradient", win)
bg.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(18,17,24)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 7,12)),
}
bg.Rotation = 130

-- ══════════════════════════════════════════
-- HEADER
-- ══════════════════════════════════════════
local hdr = Instance.new("Frame", win)
hdr.Size = UDim2.new(1,0,0,56); hdr.Position = UDim2.new(0,0,0,0)
hdr.BackgroundColor3 = Color3.fromRGB(8,7,12)
hdr.BorderSizePixel = 0; corner(hdr, 12)

-- línea dorada inferior del header
local hline = Instance.new("Frame", hdr)
hline.Size = UDim2.new(0.78,0,0,1)
hline.Position = UDim2.new(0.11,0,1,-1)
hline.BackgroundColor3 = GOLD; hline.BorderSizePixel = 0
local hlG = Instance.new("UIGradient", hline)
hlG.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0,   Color3.fromRGB(0,0,0)),
    ColorSequenceKeypoint.new(0.3, GOLD),
    ColorSequenceKeypoint.new(0.7, GOLD),
    ColorSequenceKeypoint.new(1,   Color3.fromRGB(0,0,0)),
}

-- ícono crown
local crown = label(hdr, "♛", 22, GOLD, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
crown.Size = UDim2.new(0,34,0,34); crown.Position = UDim2.new(0,12,0.5,-17)

-- título
local ttl = label(hdr, "DIVINE HUB", 16, GOLD_LT)
ttl.Size = UDim2.new(0,180,0,22); ttl.Position = UDim2.new(0,52,0,8)

local sub = label(hdr, "P R E M I U M   ·   G O L D", 8, DIM, Enum.Font.Gotham)
sub.Size = UDim2.new(0,200,0,16); sub.Position = UDim2.new(0,53,0,32)

-- botones X y −
local function mkCtrl(sym, offX, col)
    local b = Instance.new("TextButton", hdr)
    b.Size = UDim2.new(0,26,0,26)
    b.Position = UDim2.new(1,offX,0.5,-13)
    b.Text = sym; b.Font = Enum.Font.GothamBold
    b.TextSize = 13; b.TextColor3 = WHITE
    b.BackgroundColor3 = col; b.BorderSizePixel = 0
    corner(b, 7)
    b.MouseEnter:Connect(function() tween(b,0.12,{BackgroundTransparency=0.3}) end)
    b.MouseLeave:Connect(function() tween(b,0.12,{BackgroundTransparency=0}) end)
    return b
end
local btnClose = mkCtrl("✕", -40, RED)
local btnMin   = mkCtrl("−", -72, Color3.fromRGB(50,45,25))

-- ══════════════════════════════════════════
-- BARRA DE TABS
-- ══════════════════════════════════════════
local navBg = Instance.new("Frame", win)
navBg.Size = UDim2.new(1,-24,0,36); navBg.Position = UDim2.new(0,12,0,64)
navBg.BackgroundColor3 = BG_NAV; navBg.BorderSizePixel = 0
corner(navBg, 9); stroke(navBg, Color3.fromRGB(38,33,14), 1)

local navList = Instance.new("UIListLayout", navBg)
navList.FillDirection = Enum.FillDirection.Horizontal
navList.HorizontalAlignment = Enum.HorizontalAlignment.Center
navList.VerticalAlignment = Enum.VerticalAlignment.Center
navList.Padding = UDim.new(0,2)

-- ══════════════════════════════════════════
-- ÁREA DE CONTENIDO
-- ══════════════════════════════════════════
local content = Instance.new("Frame", win)
content.Size = UDim2.new(1,-24,1,-110)
content.Position = UDim2.new(0,12,0,108)
content.BackgroundTransparency = 1

-- ══════════════════════════════════════════
-- PÁGINAS
-- ══════════════════════════════════════════
local function mkPage(name)
    local sf = Instance.new("ScrollingFrame", content)
    sf.Name = name
    sf.Size = UDim2.new(1,0,1,0)
    sf.BackgroundTransparency = 1; sf.BorderSizePixel = 0
    sf.ScrollBarThickness = 3; sf.ScrollBarImageColor3 = GOLD_DK
    sf.CanvasSize = UDim2.new(0,0,0,0)
    sf.AutomaticCanvasSize = Enum.AutomaticSize.Y
    sf.Visible = false
    local ul = Instance.new("UIListLayout", sf)
    ul.Padding = UDim.new(0,8)
    ul.HorizontalAlignment = Enum.HorizontalAlignment.Center
    ul.SortOrder = Enum.SortOrder.LayoutOrder
    local up = Instance.new("UIPadding", sf)
    up.PaddingTop = UDim.new(0,6); up.PaddingBottom = UDim.new(0,10)
    return sf
end

local pgCombat  = mkPage("Combate")
local pgMove    = mkPage("Mover")
local pgSea2    = mkPage("Sea2")
local pgSea3    = mkPage("Sea3")
local pgVisual  = mkPage("Visual")

-- ══════════════════════════════════════════
-- TABS
-- ══════════════════════════════════════════
local activeTab = nil

local function switchPage(page, btn)
    for _, v in pairs(content:GetChildren()) do
        if v:IsA("ScrollingFrame") then v.Visible = (v == page) end
    end
    if activeTab and activeTab ~= btn then
        tween(activeTab, 0.15, {BackgroundColor3=BG_NAV, TextColor3=DIM})
    end
    activeTab = btn
    tween(btn, 0.15, {BackgroundColor3=GOLD_FAINT, TextColor3=GOLD_LT})
end

local function mkTab(txt, page)
    local b = Instance.new("TextButton", navBg)
    b.Size = UDim2.new(0,74,0,28)
    b.Text = txt; b.Font = Enum.Font.GothamBold
    b.TextSize = 10; b.TextColor3 = DIM
    b.BackgroundColor3 = BG_NAV; b.BorderSizePixel = 0
    corner(b, 7)
    b.MouseButton1Click:Connect(function() switchPage(page, b) end)
    b.MouseEnter:Connect(function()
        if activeTab ~= b then tween(b,0.12,{TextColor3=GOLD}) end
    end)
    b.MouseLeave:Connect(function()
        if activeTab ~= b then tween(b,0.12,{TextColor3=DIM}) end
    end)
    return b
end

local tabCombat = mkTab("⚔ Combate", pgCombat)
local tabMove   = mkTab("🏃 Mover",   pgMove)
local tabSea2   = mkTab("🌊 Sea 2",   pgSea2)
local tabSea3   = mkTab("🏰 Sea 3",   pgSea3)
local tabVisual = mkTab("✦ Visual",  pgVisual)

-- ══════════════════════════════════════════
-- SEPARATOR DE SECCIÓN
-- ══════════════════════════════════════════
local function mkSep(txt, page, ord)
    local f = Instance.new("Frame", page)
    f.Size = UDim2.new(0.96,0,0,20); f.BackgroundTransparency = 1
    f.LayoutOrder = ord or 0

    local line = Instance.new("Frame", f)
    line.Size = UDim2.new(1,0,0,1); line.Position = UDim2.new(0,0,0.5,0)
    line.BackgroundColor3 = Color3.fromRGB(38,34,14); line.BorderSizePixel = 0

    local bg2 = Instance.new("Frame", f)
    bg2.Size = UDim2.new(0,90,1,0); bg2.Position = UDim2.new(0,8,0,0)
    bg2.BackgroundColor3 = BG_MAIN; bg2.BorderSizePixel = 0

    local lbl = label(bg2, "  "..txt.."  ", 8, GOLD_DK, Enum.Font.GothamBold, Enum.TextXAlignment.Left)
    lbl.Size = UDim2.new(1,0,1,0); lbl.TextTracking = 3
end

-- ══════════════════════════════════════════
-- TOGGLE CARD
-- Retorna: botón, setState(bool), getState()
-- ══════════════════════════════════════════
local function mkToggle(txt, page, ord)
    -- card contenedor
    local card = Instance.new("Frame", page)
    card.Size = UDim2.new(0.96,0,0,50)
    card.BackgroundColor3 = BG_CARD
    card.BorderSizePixel = 0; card.LayoutOrder = ord or 1
    corner(card, 10)
    local cS = stroke(card, Color3.fromRGB(40,36,16), 1)

    -- barra izquierda
    local bar = Instance.new("Frame", card)
    bar.Size = UDim2.new(0,3,0,22); bar.Position = UDim2.new(0,0,0.5,-11)
    bar.BackgroundColor3 = GOLD_DK; bar.BorderSizePixel = 0; corner(bar,2)

    -- texto
    local lbl = label(card, txt, 13, WHITE)
    lbl.Size = UDim2.new(0.58,0,1,0); lbl.Position = UDim2.new(0,14,0,0)

    -- fondo del pill
    local pbg = Instance.new("Frame", card)
    pbg.Size = UDim2.new(0,44,0,22); pbg.Position = UDim2.new(1,-52,0.5,-11)
    pbg.BackgroundColor3 = Color3.fromRGB(28,26,16); pbg.BorderSizePixel = 0
    corner(pbg, 11); stroke(pbg, Color3.fromRGB(50,45,18), 1)

    -- círculo del pill
    local pill = Instance.new("Frame", pbg)
    pill.Size = UDim2.new(0,16,0,16); pill.Position = UDim2.new(0,3,0.5,-8)
    pill.BackgroundColor3 = DIM; pill.BorderSizePixel = 0; corner(pill,8)

    local enabled = false

    local function setState(on)
        enabled = on
        if on then
            tween(pill,  0.15, {Position=UDim2.new(0,25,0.5,-8), BackgroundColor3=GOLD_LT})
            tween(pbg,   0.15, {BackgroundColor3=GOLD_DK})
            tween(bar,   0.15, {BackgroundColor3=GOLD})
            tween(lbl,   0.15, {TextColor3=GOLD_LT})
            tween(cS,    0.15, {Color=GOLD_DK})
        else
            tween(pill,  0.15, {Position=UDim2.new(0,3,0.5,-8), BackgroundColor3=DIM})
            tween(pbg,   0.15, {BackgroundColor3=Color3.fromRGB(28,26,16)})
            tween(bar,   0.15, {BackgroundColor3=GOLD_DK})
            tween(lbl,   0.15, {TextColor3=WHITE})
            tween(cS,    0.15, {Color=Color3.fromRGB(40,36,16)})
        end
    end

    -- El botón cubre toda la card — NO usa ZIndex elevado
    local btn = Instance.new("TextButton", card)
    btn.Size = UDim2.new(1,0,1,0); btn.BackgroundTransparency = 1
    btn.Text = ""; btn.BorderSizePixel = 0

    btn.MouseButton1Click:Connect(function()
        setState(not enabled)
    end)
    btn.MouseEnter:Connect(function() tween(card,0.12,{BackgroundColor3=BG_HOVER}) end)
    btn.MouseLeave:Connect(function() tween(card,0.12,{BackgroundColor3=BG_CARD}) end)

    return btn, setState, function() return enabled end
end

-- ══════════════════════════════════════════
-- BOTÓN ACCIÓN (teleport)
-- ══════════════════════════════════════════
local function mkAction(txt, ico, page, ord)
    local card = Instance.new("Frame", page)
    card.Size = UDim2.new(0.96,0,0,48)
    card.BackgroundColor3 = BG_CARD; card.BorderSizePixel = 0
    card.LayoutOrder = ord or 1; corner(card,10)
    local cs = stroke(card, Color3.fromRGB(40,36,16), 1)

    local icoL = label(card, ico, 18, GOLD, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
    icoL.Size = UDim2.new(0,30,1,0); icoL.Position = UDim2.new(0,10,0,0)

    local lbl = label(card, txt, 13, WHITE)
    lbl.Size = UDim2.new(0.65,0,1,0); lbl.Position = UDim2.new(0,46,0,0)

    local arr = label(card, "›", 22, GOLD_DK, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
    arr.Size = UDim2.new(0,18,1,0); arr.Position = UDim2.new(1,-26,0,0)

    local btn = Instance.new("TextButton", card)
    btn.Size = UDim2.new(1,0,1,0); btn.BackgroundTransparency = 1
    btn.Text = ""; btn.BorderSizePixel = 0

    btn.MouseEnter:Connect(function()
        tween(card,0.12,{BackgroundColor3=BG_HOVER})
        tween(cs,  0.12,{Color=GOLD_DK})
        tween(arr, 0.12,{Position=UDim2.new(1,-20,0,0), TextColor3=GOLD})
    end)
    btn.MouseLeave:Connect(function()
        tween(card,0.12,{BackgroundColor3=BG_CARD})
        tween(cs,  0.12,{Color=Color3.fromRGB(40,36,16)})
        tween(arr, 0.12,{Position=UDim2.new(1,-26,0,0), TextColor3=GOLD_DK})
    end)
    btn.MouseButton1Down:Connect(function()
        tween(card,0.07,{BackgroundColor3=Color3.fromRGB(38,34,14)})
    end)
    btn.MouseButton1Up:Connect(function()
        tween(card,0.12,{BackgroundColor3=BG_HOVER})
    end)
    return btn
end

-- ══════════════════════════════════════════
-- COMBATE
-- ══════════════════════════════════════════
mkSep("COMBATE", pgCombat, 1)

local faBtn, faSet, faGet = mkToggle("Fast Attack", pgCombat, 2)
faBtn.MouseButton1Click:Connect(function()
    task.defer(function()
        FastAttackEnabled = faGet()
        if FastAttackEnabled then StartFA()
        elseif FAConn then task.cancel(FAConn) end
    end)
end)

local espBtn, espSet, espGet = mkToggle("Player ESP", pgCombat, 3)
espBtn.MouseButton1Click:Connect(function()
    task.defer(function()
        ESPEnabled = espGet()
        UpdateESP()
    end)
end)

task.spawn(function()
    while true do task.wait(5); if ESPEnabled then UpdateESP() end end
end)

-- ══════════════════════════════════════════
-- MOVIMIENTO
-- ══════════════════════════════════════════
mkSep("MOVIMIENTO", pgMove, 1)

local sBtn, sSet, sGet = mkToggle("Speed Boost", pgMove, 2)
local sVal = 16

-- Panel flotante velocidad
local spanel = Instance.new("Frame", SG)
spanel.Size = UDim2.new(0,160,0,52); spanel.Position = UDim2.new(0,18,0.4,0)
spanel.BackgroundColor3 = BG_CARD; spanel.Visible = false
spanel.Active = true; spanel.Draggable = true; spanel.BorderSizePixel = 0
corner(spanel, 10); stroke(spanel, GOLD_DK, 1)

local spT = label(spanel, "VELOCIDAD", 8, DIM, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
spT.Size = UDim2.new(1,0,0,16); spT.Position = UDim2.new(0,0,0,4)

local function mkSpBtn(sym, px)
    local b = Instance.new("TextButton", spanel)
    b.Size = UDim2.new(0,30,0,24); b.Position = UDim2.new(0,px,1,-30)
    b.Text = sym; b.Font = Enum.Font.GothamBold; b.TextSize = 16
    b.TextColor3 = GOLD; b.BackgroundColor3 = BG_MAIN; b.BorderSizePixel = 0
    corner(b,6); stroke(b,GOLD_DK,1)
    b.MouseEnter:Connect(function() tween(b,0.12,{BackgroundColor3=BG_HOVER}) end)
    b.MouseLeave:Connect(function() tween(b,0.12,{BackgroundColor3=BG_MAIN}) end)
    return b
end
local btnM = mkSpBtn("−", 8)
local sDisp = label(spanel, "16", 14, GOLD_LT, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
sDisp.Size = UDim2.new(0,44,0,24); sDisp.Position = UDim2.new(0.5,-22,1,-30)
local btnP = mkSpBtn("+", 122)

btnP.MouseButton1Click:Connect(function() sVal=math.clamp(sVal+10,16,500); sDisp.Text=tostring(sVal) end)
btnM.MouseButton1Click:Connect(function() sVal=math.clamp(sVal-10,16,500); sDisp.Text=tostring(sVal) end)
sBtn.MouseButton1Click:Connect(function() task.defer(function() spanel.Visible = sGet() end) end)

RunService.Heartbeat:Connect(function()
    if sGet() then
        local char = Players.LocalPlayer.Character
        local hum  = char and char:FindFirstChild("Humanoid")
        if hum and hum.MoveDirection.Magnitude > 0 then
            char:TranslateBy(hum.MoveDirection * (sVal / 55))
        end
    end
end)

local jBtn, jSet, jGet = mkToggle("Infinite Jump", pgMove, 3)
UserInputService.JumpRequest:Connect(function()
    if jGet() then
        local c = Players.LocalPlayer.Character
        local h = c and c:FindFirstChild("Humanoid")
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

local ncBtn, ncSet, ncGet = mkToggle("No Clip", pgMove, 4)
RunService.Stepped:Connect(function()
    if ncGet() then
        local c = Players.LocalPlayer.Character
        if c then for _,v in pairs(c:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end end
    end
end)

local wwBtn, wwSet, wwGet = mkToggle("Walk on Water", pgMove, 5)
RunService.RenderStepped:Connect(function()
    local c = Players.LocalPlayer.Character
    local hrp = c and c:FindFirstChild("HumanoidRootPart")
    if wwGet() and hrp then
        if hrp.Position.Y >= 9.5 and hrp.AssemblyLinearVelocity.Y <= 0 then
            local w = workspace:FindFirstChild("DivineWater")
            if not w then
                w = Instance.new("Part", workspace); w.Name = "DivineWater"
                w.Size = Vector3.new(20,1,20); w.Transparency = 1
                w.Anchored = true; w.CanCollide = true; w.CanQuery = false
            end
            w.CFrame = CFrame.new(hrp.Position.X, 9.2, hrp.Position.Z)
        else
            local w = workspace:FindFirstChild("DivineWater"); if w then w:Destroy() end
        end
    else
        local w = workspace:FindFirstChild("DivineWater"); if w then w:Destroy() end
    end
end)

-- ══════════════════════════════════════════
-- SEA 2
-- ══════════════════════════════════════════
mkSep("TELEPORTS", pgSea2, 1)
local bBtn = mkAction("Barco Maldito", "🗺", pgSea2, 2)
bBtn.MouseButton1Click:Connect(function()
    Players.LocalPlayer.Character:PivotTo(CFrame.new(923,126,32852))
end)

-- ══════════════════════════════════════════
-- SEA 3
-- ══════════════════════════════════════════
mkSep("TELEPORTS", pgSea3, 1)
local castBtn = mkAction("Castillo", "🏰", pgSea3, 2)
castBtn.MouseButton1Click:Connect(function()
    Players.LocalPlayer.Character:PivotTo(CFrame.new(-5085,316,-3156))
end)
local manBtn = mkAction("Mansión", "🏛", pgSea3, 3)
manBtn.MouseButton1Click:Connect(function()
    Players.LocalPlayer.Character:PivotTo(CFrame.new(-12463,375,-7523))
end)

-- ══════════════════════════════════════════
-- VISUALS
-- ══════════════════════════════════════════
mkSep("RENDIMIENTO", pgVisual, 1)

local fpsBtn, fpsSet, fpsGet = mkToggle("Boost FPS", pgVisual, 2)
fpsBtn.MouseButton1Click:Connect(function()
    task.defer(function()
        local on = fpsGet()
        local L = game:GetService("Lighting")
        if on then
            L.GlobalShadows = false; L.FogEnd = 100000
            for _, fx in pairs(L:GetChildren()) do
                if fx:IsA("BlurEffect") or fx:IsA("BloomEffect")
                or fx:IsA("ColorCorrectionEffect") or fx:IsA("SunRaysEffect")
                or fx:IsA("DepthOfFieldEffect") then fx.Enabled = false end
            end
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("ParticleEmitter") or v:IsA("Fire")
                or v:IsA("Smoke") or v:IsA("Sparkles") then v.Enabled = false end
            end
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        else
            L.GlobalShadows = true
            for _, fx in pairs(L:GetChildren()) do
                if fx:IsA("BlurEffect") or fx:IsA("BloomEffect")
                or fx:IsA("ColorCorrectionEffect") or fx:IsA("SunRaysEffect")
                or fx:IsA("DepthOfFieldEffect") then fx.Enabled = true end
            end
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("ParticleEmitter") or v:IsA("Fire")
                or v:IsA("Smoke") or v:IsA("Sparkles") then v.Enabled = true end
            end
            settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
        end
    end)
end)

-- ══════════════════════════════════════════
-- CONTROLES VENTANA
-- ══════════════════════════════════════════
local minimized = false

btnMin.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        tween(win, 0.3, {Size = MINI})
        task.delay(0.15, function()
            navBg.Visible = false; content.Visible = false
        end)
        btnMin.Text = "+"
    else
        navBg.Visible = true; content.Visible = true
        tween(win, 0.3, {Size = FULL})
        btnMin.Text = "−"
    end
end)

btnClose.MouseButton1Click:Connect(function()
    ESPEnabled = false; ClearESP()
    local w = workspace:FindFirstChild("DivineWater"); if w then w:Destroy() end
    spanel:Destroy(); SG:Destroy()
end)

-- ══════════════════════════════════════════
-- INICIO — mostrar tab Combate
-- ══════════════════════════════════════════
switchPage(pgCombat, tabCombat)

-- ══════════════════════════════════════════
-- SHIMMER animado en la línea del header
-- ══════════════════════════════════════════
task.spawn(function()
    local t = 0
    while SG.Parent do
        t = t + task.wait(0.045)
        hlG.Offset = Vector2.new(math.sin(t) * 0.3, 0)
    end
end)

print("✦ Divine Hub Gold Edition — OK")
