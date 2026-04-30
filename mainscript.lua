-- DIVINE HUB PREMIUM | Gold Edition
-- loadstring(game:HttpGet("URL_RAW_AQUI"))()

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService  = game:GetService("UserInputService")
local RunService        = game:GetService("RunService")
local TweenService      = game:GetService("TweenService")

-- ==================== PALETA ====================
local C = {
    black     = Color3.fromRGB(6,   6,   8),
    darkBg    = Color3.fromRGB(12,  11,  16),
    panelBg   = Color3.fromRGB(16,  15,  21),
    cardBg    = Color3.fromRGB(22,  21,  28),
    cardHover = Color3.fromRGB(30,  28,  38),
    gold      = Color3.fromRGB(212, 175,  55),
    goldLight = Color3.fromRGB(255, 220, 100),
    goldDark  = Color3.fromRGB(140, 112,  30),
    goldFaint = Color3.fromRGB(55,  46,  12),
    white     = Color3.fromRGB(240, 235, 215),
    dim       = Color3.fromRGB(120, 112,  85),
    danger    = Color3.fromRGB(210,  60,  60),
    dimBtn    = Color3.fromRGB(35,  33,  26),
}

-- ==================== TWEEN HELPERS ====================
local function tw(obj, t, style, dir, props)
    TweenService:Create(obj, TweenInfo.new(t, style or Enum.EasingStyle.Quad,
        dir or Enum.EasingDirection.Out), props):Play()
end
local function twFast(obj, props)  tw(obj, 0.16, Enum.EasingStyle.Quad,  Enum.EasingDirection.Out, props) end
local function twMed(obj, props)   tw(obj, 0.32, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, props) end
local function twSlow(obj, props)  tw(obj, 0.55, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, props) end

local function mkCorner(p, r)
    local c = Instance.new("UICorner", p); c.CornerRadius = UDim.new(0, r or 8); return c
end
local function mkStroke(p, col, th)
    local s = Instance.new("UIStroke", p); s.Color = col or C.gold; s.Thickness = th or 1; return s
end

-- ==================== ESP ====================
local ESPEnabled = false
local ESPObjects = {}

local function CreateESP(target)
    if not target:FindFirstChild("Head") then return end
    local bb = Instance.new("BillboardGui")
    bb.Name        = "DivineESP"
    bb.Adornee     = target.Head
    bb.Size        = UDim2.new(0, 120, 0, 28)
    bb.StudsOffset = Vector3.new(0, 3, 0)
    bb.AlwaysOnTop = true
    bb.Parent      = target.Head
    local bg = Instance.new("Frame", bb)
    bg.Size = UDim2.new(1,0,1,0)
    bg.BackgroundColor3 = Color3.fromRGB(0,0,0)
    bg.BackgroundTransparency = 0.4
    mkCorner(bg, 4); mkStroke(bg, C.goldDark, 1)
    local lbl = Instance.new("TextLabel", bg)
    lbl.Size = UDim2.new(1,0,1,0)
    lbl.BackgroundTransparency = 1
    lbl.Text = "✦ " .. target.Name
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 11
    lbl.TextColor3 = C.goldLight
    lbl.TextStrokeTransparency = 0.5
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

-- ==================== FAST ATTACK ====================
local FastAttackEnabled    = false
local FastAttackRange      = 5000
local FastAttackConnection = nil

local Net = ReplicatedStorage:WaitForChild("Modules", 5) and
            ReplicatedStorage.Modules:WaitForChild("Net", 5)
local RegisterHit    = Net and pcall(function() return Net["RE/RegisterHit"] end)    and Net["RE/RegisterHit"]
local RegisterAttack = Net and pcall(function() return Net["RE/RegisterAttack"] end) and Net["RE/RegisterAttack"]

local function AttackMultipleTargets(targets)
    if not RegisterHit or not RegisterAttack then return end
    pcall(function()
        if not targets or #targets == 0 then return end
        local all = {}
        for _, c in pairs(targets) do
            local h = c:FindFirstChild("Head")
            if h then table.insert(all, {c, h}) end
        end
        if #all == 0 then return end
        RegisterAttack:FireServer(0)
        RegisterHit:FireServer(all[1][2], all)
    end)
end

local function StartFastAttack()
    if FastAttackConnection then task.cancel(FastAttackConnection) end
    FastAttackConnection = task.spawn(function()
        while FastAttackEnabled do
            RunService.Stepped:Wait()
            local myChar = Players.LocalPlayer.Character
            local myHRP  = myChar and myChar:FindFirstChild("HumanoidRootPart")
            if not myHRP then continue end
            local targets = {}
            for _, pl in pairs(Players:GetPlayers()) do
                if pl ~= Players.LocalPlayer and pl.Character then
                    local hum = pl.Character:FindFirstChild("Humanoid")
                    local hrp = pl.Character:FindFirstChild("HumanoidRootPart")
                    if hum and hrp and hum.Health > 0 and
                        (hrp.Position - myHRP.Position).Magnitude <= FastAttackRange then
                        table.insert(targets, pl.Character)
                    end
                end
            end
            local en = workspace:FindFirstChild("Enemies")
            if en then
                for _, n in pairs(en:GetChildren()) do
                    local hum = n:FindFirstChild("Humanoid")
                    local hrp = n:FindFirstChild("HumanoidRootPart")
                    if hum and hrp and hum.Health > 0 and
                        (hrp.Position - myHRP.Position).Magnitude <= FastAttackRange then
                        table.insert(targets, n)
                    end
                end
            end
            if #targets > 0 then AttackMultipleTargets(targets) end
        end
    end)
end

-- ==================== GUI ROOT ====================
local pgui = Players.LocalPlayer:WaitForChild("PlayerGui")
if pgui:FindFirstChild("DivineHub_Gold") then pgui.DivineHub_Gold:Destroy() end

local screenGui = Instance.new("ScreenGui", pgui)
screenGui.Name            = "DivineHub_Gold"
screenGui.ResetOnSpawn    = false
screenGui.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling

-- ==================== VENTANA ====================
local W, H       = 430, 540
local normalSize = UDim2.new(0, W, 0, H)
local miniSize   = UDim2.new(0, 190, 0, 50)

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Name             = "Main"
mainFrame.Size             = UDim2.new(0, W, 0, 0)   -- abre animado
mainFrame.Position         = UDim2.new(0.5, -W/2, 0.1, 0)
mainFrame.BackgroundColor3 = C.darkBg
mainFrame.Active           = true
mainFrame.Draggable        = true
mainFrame.ClipsDescendants = true
mainFrame.BorderSizePixel  = 0
mkCorner(mainFrame, 14)
mkStroke(mainFrame, C.goldDark, 1.5)

-- gradiente de fondo
local bgG = Instance.new("UIGradient", mainFrame)
bgG.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0,   Color3.fromRGB(18, 17, 24)),
    ColorSequenceKeypoint.new(1,   Color3.fromRGB(9,   8, 13)),
}
bgG.Rotation = 130

-- animación de entrada
task.defer(function()
    twSlow(mainFrame, {Size = normalSize})
end)

-- ==================== HEADER ====================
local header = Instance.new("Frame", mainFrame)
header.Size             = UDim2.new(1, 0, 0, 58)
header.BackgroundColor3 = C.black
header.BorderSizePixel  = 0
mkCorner(header, 14)

-- línea dorada animada al fondo del header
local divider = Instance.new("Frame", header)
divider.Size             = UDim2.new(0.8, 0, 0, 1)
divider.Position         = UDim2.new(0.1, 0, 1, -1)
divider.BackgroundColor3 = C.gold
divider.BorderSizePixel  = 0
local divG = Instance.new("UIGradient", divider)
divG.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0,   Color3.fromRGB(0,0,0)),
    ColorSequenceKeypoint.new(0.25, C.gold),
    ColorSequenceKeypoint.new(0.75, C.gold),
    ColorSequenceKeypoint.new(1,   Color3.fromRGB(0,0,0)),
}

-- crown
local crownLbl = Instance.new("TextLabel", header)
crownLbl.Size               = UDim2.new(0, 34, 0, 34)
crownLbl.Position           = UDim2.new(0, 14, 0.5, -17)
crownLbl.Text               = "♛"
crownLbl.TextSize           = 24
crownLbl.TextColor3         = C.gold
crownLbl.BackgroundTransparency = 1
crownLbl.Font               = Enum.Font.GothamBold

-- título + sub
local titleLbl = Instance.new("TextLabel", header)
titleLbl.Size               = UDim2.new(0, 190, 0, 24)
titleLbl.Position           = UDim2.new(0, 54, 0, 8)
titleLbl.Text               = "DIVINE HUB"
titleLbl.Font               = Enum.Font.GothamBold
titleLbl.TextSize           = 16
titleLbl.TextColor3         = C.goldLight
titleLbl.BackgroundTransparency = 1
titleLbl.TextXAlignment     = Enum.TextXAlignment.Left

local subLbl = Instance.new("TextLabel", header)
subLbl.Size                 = UDim2.new(0, 220, 0, 16)
subLbl.Position             = UDim2.new(0, 55, 0, 34)
subLbl.Text                 = "P R E M I U M   ·   G O L D   E D I T I O N"
subLbl.Font                 = Enum.Font.Gotham
subLbl.TextSize             = 8
subLbl.TextColor3           = C.dim
subLbl.BackgroundTransparency = 1
subLbl.TextXAlignment       = Enum.TextXAlignment.Left

-- botones de control
local function mkCtrl(sym, offX, bgCol)
    local b = Instance.new("TextButton", header)
    b.Size             = UDim2.new(0, 26, 0, 26)
    b.Position         = UDim2.new(1, offX, 0.5, -13)
    b.Text             = sym
    b.Font             = Enum.Font.GothamBold
    b.TextSize         = 13
    b.TextColor3       = C.white
    b.BackgroundColor3 = bgCol
    b.BorderSizePixel  = 0
    mkCorner(b, 7)
    b.MouseEnter:Connect(function() twFast(b, {BackgroundTransparency = 0.3}) end)
    b.MouseLeave:Connect(function() twFast(b, {BackgroundTransparency = 0}) end)
    return b
end
local closeBtn    = mkCtrl("✕", -40,  C.danger)
local minimizeBtn = mkCtrl("−", -73,  C.dimBtn)

-- ==================== NAVEGACIÓN ====================
local navBar = Instance.new("Frame", mainFrame)
navBar.Size             = UDim2.new(1, -24, 0, 38)
navBar.Position         = UDim2.new(0, 12, 0, 66)
navBar.BackgroundColor3 = C.black
navBar.BorderSizePixel  = 0
mkCorner(navBar, 10)
mkStroke(navBar, Color3.fromRGB(40, 36, 18), 1)

local navLayout = Instance.new("UIListLayout", navBar)
navLayout.FillDirection        = Enum.FillDirection.Horizontal
navLayout.HorizontalAlignment  = Enum.HorizontalAlignment.Center
navLayout.VerticalAlignment    = Enum.VerticalAlignment.Center
navLayout.Padding              = UDim.new(0, 2)

-- ==================== PÁGINAS ====================
local contentArea = Instance.new("Frame", mainFrame)
contentArea.Size             = UDim2.new(1, -24, 1, -116)
contentArea.Position         = UDim2.new(0, 12, 0, 112)
contentArea.BackgroundTransparency = 1

local function mkPage(name)
    local sf = Instance.new("ScrollingFrame", contentArea)
    sf.Name                = name
    sf.Size                = UDim2.new(1, 0, 1, 0)
    sf.BackgroundTransparency = 1
    sf.BorderSizePixel     = 0
    sf.ScrollBarThickness  = 3
    sf.ScrollBarImageColor3 = C.goldDark
    sf.CanvasSize          = UDim2.new(0,0,0,0)
    sf.AutomaticCanvasSize = Enum.AutomaticSize.Y
    sf.Visible             = false
    local ul = Instance.new("UIListLayout", sf)
    ul.Padding             = UDim.new(0, 8)
    ul.HorizontalAlignment = Enum.HorizontalAlignment.Center
    ul.SortOrder           = Enum.SortOrder.LayoutOrder
    local up = Instance.new("UIPadding", sf)
    up.PaddingTop    = UDim.new(0, 4)
    up.PaddingBottom = UDim.new(0, 10)
    return sf
end

local combatPage  = mkPage("Combate")
local movePage    = mkPage("Movimiento")
local sea2Page    = mkPage("Sea2")
local sea3Page    = mkPage("Sea3")
local visualsPage = mkPage("Visuals")

-- ==================== SISTEMA DE TABS ====================
local activeTabBtn = nil

local function showPage(page, tabBtn)
    -- ocultar páginas anteriores
    for _, v in pairs(contentArea:GetChildren()) do
        if v:IsA("ScrollingFrame") and v ~= page then
            v.Visible = false
        end
    end
    page.Visible = true
    -- fade in
    local orig = page.GroupTransparency
    page.GroupTransparency = 1
    twMed(page, {GroupTransparency = 0})

    -- deactivate old tab
    if activeTabBtn and activeTabBtn ~= tabBtn then
        twFast(activeTabBtn, {BackgroundColor3 = C.black, TextColor3 = C.dim})
    end
    activeTabBtn = tabBtn
    twFast(tabBtn, {BackgroundColor3 = C.goldFaint, TextColor3 = C.goldLight})
end

local function mkTab(label, page)
    local b = Instance.new("TextButton", navBar)
    b.Size             = UDim2.new(0, 74, 0, 30)
    b.Text             = label
    b.Font             = Enum.Font.GothamBold
    b.TextSize         = 10
    b.TextColor3       = C.dim
    b.BackgroundColor3 = C.black
    b.BorderSizePixel  = 0
    mkCorner(b, 7)
    b.MouseButton1Click:Connect(function() showPage(page, b) end)
    b.MouseEnter:Connect(function()
        if activeTabBtn ~= b then twFast(b, {TextColor3 = C.gold}) end
    end)
    b.MouseLeave:Connect(function()
        if activeTabBtn ~= b then twFast(b, {TextColor3 = C.dim}) end
    end)
    return b
end

local tabCombat  = mkTab("⚔ Combate",  combatPage)
local tabMove    = mkTab("🏃 Mover",    movePage)
local tabSea2    = mkTab("🌊 Sea 2",    sea2Page)
local tabSea3    = mkTab("🏰 Sea 3",    sea3Page)
local tabVisual  = mkTab("✦ Visual",   visualsPage)

-- ==================== SECCIÓN LABEL ====================
local function mkSection(text, page, order)
    local row = Instance.new("Frame", page)
    row.Size             = UDim2.new(0.96, 0, 0, 22)
    row.BackgroundTransparency = 1
    row.LayoutOrder      = order or 0

    local line = Instance.new("Frame", row)
    line.Size             = UDim2.new(1, 0, 0, 1)
    line.Position         = UDim2.new(0, 0, 0.5, 0)
    line.BackgroundColor3 = Color3.fromRGB(38, 34, 16)
    line.BorderSizePixel  = 0

    local lbl = Instance.new("TextLabel", row)
    lbl.Size              = UDim2.new(0, 100, 1, 0)
    lbl.Position          = UDim2.new(0, 6, 0, 0)
    lbl.Text              = "  " .. text .. "  "
    lbl.Font              = Enum.Font.GothamBold
    lbl.TextSize          = 8
    lbl.TextColor3        = C.goldDark
    lbl.BackgroundColor3  = C.darkBg
    lbl.BackgroundTransparency = 0
    lbl.BorderSizePixel   = 0
    lbl.TextTracking      = 4
end

-- ==================== BOTÓN TOGGLE (CARD) ====================
-- Retorna el botón clicable, la función setState y la función getState
local function mkToggle(label, page, order)
    local card = Instance.new("Frame", page)
    card.Size             = UDim2.new(0.96, 0, 0, 50)
    card.BackgroundColor3 = C.cardBg
    card.BorderSizePixel  = 0
    card.LayoutOrder      = order or 1
    mkCorner(card, 10)
    local cStroke = mkStroke(card, Color3.fromRGB(42, 38, 18), 1)

    -- barra lateral izquierda
    local bar = Instance.new("Frame", card)
    bar.Size             = UDim2.new(0, 3, 0, 22)
    bar.Position         = UDim2.new(0, 0, 0.5, -11)
    bar.BackgroundColor3 = C.goldDark
    bar.BorderSizePixel  = 0
    mkCorner(bar, 2)

    -- label texto
    local lbl = Instance.new("TextLabel", card)
    lbl.Size             = UDim2.new(0.6, 0, 1, 0)
    lbl.Position         = UDim2.new(0, 16, 0, 0)
    lbl.Text             = label
    lbl.Font             = Enum.Font.GothamBold
    lbl.TextSize         = 13
    lbl.TextColor3       = C.white
    lbl.BackgroundTransparency = 1
    lbl.TextXAlignment   = Enum.TextXAlignment.Left

    -- pill toggle
    local pillBg = Instance.new("Frame", card)
    pillBg.Size             = UDim2.new(0, 44, 0, 22)
    pillBg.Position         = UDim2.new(1, -54, 0.5, -11)
    pillBg.BackgroundColor3 = Color3.fromRGB(30, 28, 18)
    pillBg.BorderSizePixel  = 0
    mkCorner(pillBg, 11)
    mkStroke(pillBg, Color3.fromRGB(55, 50, 22), 1)

    local pill = Instance.new("Frame", pillBg)
    pill.Size             = UDim2.new(0, 16, 0, 16)
    pill.Position         = UDim2.new(0, 3, 0.5, -8)
    pill.BackgroundColor3 = C.dim
    pill.BorderSizePixel  = 0
    mkCorner(pill, 8)

    local enabled = false

    local function setState(on)
        enabled = on
        if on then
            twFast(pill,    {Position = UDim2.new(0, 25, 0.5, -8), BackgroundColor3 = C.goldLight})
            twFast(pillBg,  {BackgroundColor3 = C.goldDark})
            twFast(bar,     {BackgroundColor3 = C.gold})
            twFast(lbl,     {TextColor3 = C.goldLight})
            twFast(cStroke, {Color = C.goldDark})
        else
            twFast(pill,    {Position = UDim2.new(0, 3, 0.5, -8), BackgroundColor3 = C.dim})
            twFast(pillBg,  {BackgroundColor3 = Color3.fromRGB(30, 28, 18)})
            twFast(bar,     {BackgroundColor3 = C.goldDark})
            twFast(lbl,     {TextColor3 = C.white})
            twFast(cStroke, {Color = Color3.fromRGB(42, 38, 18)})
        end
    end

    local clickBtn = Instance.new("TextButton", card)
    clickBtn.Size             = UDim2.new(1, 0, 1, 0)
    clickBtn.BackgroundTransparency = 1
    clickBtn.Text             = ""
    clickBtn.ZIndex           = 5

    clickBtn.MouseButton1Click:Connect(function()
        setState(not enabled)
        -- micro bounce
        twFast(card, {BackgroundColor3 = Color3.fromRGB(32, 30, 18)})
        task.delay(0.1, function() twFast(card, {BackgroundColor3 = C.cardBg}) end)
    end)
    card.MouseEnter:Connect(function() twFast(card, {BackgroundColor3 = C.cardHover}) end)
    card.MouseLeave:Connect(function() twFast(card, {BackgroundColor3 = C.cardBg}) end)

    return clickBtn, setState, function() return enabled end
end

-- ==================== BOTÓN ACCIÓN (TELEPORT) ====================
local function mkAction(label, icon, page, order)
    local card = Instance.new("Frame", page)
    card.Size             = UDim2.new(0.96, 0, 0, 48)
    card.BackgroundColor3 = C.cardBg
    card.BorderSizePixel  = 0
    card.LayoutOrder      = order or 1
    mkCorner(card, 10)
    local cs = mkStroke(card, Color3.fromRGB(42, 38, 18), 1)

    local ico = Instance.new("TextLabel", card)
    ico.Size             = UDim2.new(0, 30, 1, 0)
    ico.Position         = UDim2.new(0, 12, 0, 0)
    ico.Text             = icon
    ico.TextSize         = 18
    ico.TextColor3       = C.gold
    ico.BackgroundTransparency = 1
    ico.Font             = Enum.Font.GothamBold

    local lbl = Instance.new("TextLabel", card)
    lbl.Size             = UDim2.new(0.65, 0, 1, 0)
    lbl.Position         = UDim2.new(0, 48, 0, 0)
    lbl.Text             = label
    lbl.Font             = Enum.Font.GothamBold
    lbl.TextSize         = 13
    lbl.TextColor3       = C.white
    lbl.BackgroundTransparency = 1
    lbl.TextXAlignment   = Enum.TextXAlignment.Left

    local arrow = Instance.new("TextLabel", card)
    arrow.Size           = UDim2.new(0, 18, 1, 0)
    arrow.Position       = UDim2.new(1, -28, 0, 0)
    arrow.Text           = "›"
    arrow.TextSize       = 22
    arrow.TextColor3     = C.goldDark
    arrow.BackgroundTransparency = 1
    arrow.Font           = Enum.Font.GothamBold

    local btn = Instance.new("TextButton", card)
    btn.Size             = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text             = ""
    btn.ZIndex           = 5

    btn.MouseEnter:Connect(function()
        twFast(card,  {BackgroundColor3 = C.cardHover})
        twFast(cs,    {Color = C.goldDark})
        twFast(arrow, {TextColor3 = C.gold, Position = UDim2.new(1, -22, 0, 0)})
    end)
    btn.MouseLeave:Connect(function()
        twFast(card,  {BackgroundColor3 = C.cardBg})
        twFast(cs,    {Color = Color3.fromRGB(42, 38, 18)})
        twFast(arrow, {TextColor3 = C.goldDark, Position = UDim2.new(1, -28, 0, 0)})
    end)
    btn.MouseButton1Down:Connect(function()
        twFast(card, {BackgroundColor3 = Color3.fromRGB(40, 36, 16)})
    end)
    btn.MouseButton1Up:Connect(function()
        twFast(card, {BackgroundColor3 = C.cardHover})
    end)
    return btn
end

-- ==================== COMBATE ====================
mkSection("COMBATE", combatPage, 1)

local faBtn, faSet, faGet = mkToggle("Fast Attack", combatPage, 2)
faBtn.MouseButton1Click:Connect(function()
    task.defer(function()
        FastAttackEnabled = faGet()
        if FastAttackEnabled then StartFastAttack()
        elseif FastAttackConnection then task.cancel(FastAttackConnection) end
    end)
end)

local espBtn, espSet, espGet = mkToggle("Player ESP", combatPage, 3)
espBtn.MouseButton1Click:Connect(function()
    task.defer(function()
        ESPEnabled = espGet()
        UpdateESP()
    end)
end)

task.spawn(function()
    while true do
        task.wait(5)
        if ESPEnabled then UpdateESP() end
    end
end)

-- ==================== MOVIMIENTO ====================
mkSection("MOVIMIENTO", movePage, 1)

local sBtn, sSet, sGet = mkToggle("Speed Boost", movePage, 2)
local sVal = 16

-- Panel flotante de velocidad
local speedPanel = Instance.new("Frame", screenGui)
speedPanel.Size             = UDim2.new(0, 162, 0, 54)
speedPanel.Position         = UDim2.new(0, 18, 0.4, 0)
speedPanel.BackgroundColor3 = C.darkBg
speedPanel.Visible          = false
speedPanel.Active           = true
speedPanel.Draggable        = true
speedPanel.BorderSizePixel  = 0
mkCorner(speedPanel, 10)
mkStroke(speedPanel, C.goldDark, 1)

local spTitle = Instance.new("TextLabel", speedPanel)
spTitle.Size             = UDim2.new(1, 0, 0, 16)
spTitle.Position         = UDim2.new(0, 0, 0, 4)
spTitle.Text             = "V E L O C I D A D"
spTitle.Font             = Enum.Font.GothamBold
spTitle.TextSize         = 8
spTitle.TextColor3       = C.dim
spTitle.BackgroundTransparency = 1
spTitle.TextTracking     = 3

local function mkSpBtn(sym, posX)
    local b = Instance.new("TextButton", speedPanel)
    b.Size             = UDim2.new(0, 30, 0, 24)
    b.Position         = UDim2.new(posX, 0, 1, -30)
    b.Text             = sym
    b.Font             = Enum.Font.GothamBold
    b.TextSize         = 15
    b.TextColor3       = C.gold
    b.BackgroundColor3 = C.cardBg
    b.BorderSizePixel  = 0
    mkCorner(b, 6)
    mkStroke(b, C.goldDark, 1)
    b.MouseEnter:Connect(function() twFast(b, {BackgroundColor3 = C.cardHover}) end)
    b.MouseLeave:Connect(function() twFast(b, {BackgroundColor3 = C.cardBg}) end)
    return b
end
local btnM  = mkSpBtn("−", 0.06)
local sDisp = Instance.new("TextLabel", speedPanel)
sDisp.Size             = UDim2.new(0, 44, 0, 24)
sDisp.Position         = UDim2.new(0.5, -22, 1, -30)
sDisp.Text             = "16"
sDisp.Font             = Enum.Font.GothamBold
sDisp.TextSize         = 14
sDisp.TextColor3       = C.goldLight
sDisp.BackgroundTransparency = 1
local btnP  = mkSpBtn("+", 0.67)

btnP.MouseButton1Click:Connect(function() sVal = math.clamp(sVal+10, 16, 500); sDisp.Text = tostring(sVal) end)
btnM.MouseButton1Click:Connect(function() sVal = math.clamp(sVal-10, 16, 500); sDisp.Text = tostring(sVal) end)
sBtn.MouseButton1Click:Connect(function() task.defer(function() speedPanel.Visible = sGet() end) end)

RunService.Heartbeat:Connect(function()
    if sGet() then
        local char = Players.LocalPlayer.Character
        local hum  = char and char:FindFirstChild("Humanoid")
        if hum and hum.MoveDirection.Magnitude > 0 then
            char:TranslateBy(hum.MoveDirection * (sVal / 55))
        end
    end
end)

local jBtn, jSet, jGet = mkToggle("Infinite Jump", movePage, 3)
UserInputService.JumpRequest:Connect(function()
    if jGet() then
        local char = Players.LocalPlayer.Character
        local hum  = char and char:FindFirstChild("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

local ncBtn, ncSet, ncGet = mkToggle("No Clip", movePage, 4)
RunService.Stepped:Connect(function()
    if ncGet() then
        local char = Players.LocalPlayer.Character
        if char then
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        end
    end
end)

local wwBtn, wwSet, wwGet = mkToggle("Walk on Water", movePage, 5)
RunService.RenderStepped:Connect(function()
    local char = Players.LocalPlayer.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if wwGet() and hrp then
        if hrp.Position.Y >= 9.5 and hrp.AssemblyLinearVelocity.Y <= 0 then
            local w = workspace:FindFirstChild("DivineWaterSolid")
            if not w then
                w = Instance.new("Part", workspace)
                w.Name = "DivineWaterSolid"; w.Size = Vector3.new(20,1,20)
                w.Transparency = 1; w.Anchored = true
                w.CanCollide = true; w.CanQuery = false
            end
            w.CFrame = CFrame.new(hrp.Position.X, 9.2, hrp.Position.Z)
        else
            local w = workspace:FindFirstChild("DivineWaterSolid"); if w then w:Destroy() end
        end
    else
        local w = workspace:FindFirstChild("DivineWaterSolid"); if w then w:Destroy() end
    end
end)

-- ==================== SEA 2 ====================
mkSection("TELEPORTS", sea2Page, 1)
local bBtn = mkAction("Barco Maldito", "🗺", sea2Page, 2)
bBtn.MouseButton1Click:Connect(function()
    Players.LocalPlayer.Character:PivotTo(CFrame.new(923, 126, 32852))
end)

-- ==================== SEA 3 ====================
mkSection("TELEPORTS", sea3Page, 1)
local castBtn = mkAction("Castillo", "🏰", sea3Page, 2)
castBtn.MouseButton1Click:Connect(function()
    Players.LocalPlayer.Character:PivotTo(CFrame.new(-5085, 316, -3156))
end)
local manBtn = mkAction("Mansión", "🏛", sea3Page, 3)
manBtn.MouseButton1Click:Connect(function()
    Players.LocalPlayer.Character:PivotTo(CFrame.new(-12463, 375, -7523))
end)

-- ==================== VISUALS ====================
mkSection("RENDIMIENTO", visualsPage, 1)

local fpsBtn, fpsSet, fpsGet = mkToggle("Boost FPS", visualsPage, 2)
fpsBtn.MouseButton1Click:Connect(function()
    task.defer(function()
        local on = fpsGet()
        local lighting = game:GetService("Lighting")
        if on then
            lighting.GlobalShadows = false
            lighting.FogEnd = 100000
            for _, fx in pairs(lighting:GetChildren()) do
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
            lighting.GlobalShadows = true
            for _, fx in pairs(lighting:GetChildren()) do
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

-- ==================== CONTROLES VENTANA ====================
local minimized = false

minimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        twMed(mainFrame, {Size = miniSize})
        task.delay(0.2, function()
            navBar.Visible      = false
            contentArea.Visible = false
        end)
        minimizeBtn.Text = "+"
    else
        navBar.Visible      = true
        contentArea.Visible = true
        twMed(mainFrame, {Size = normalSize})
        minimizeBtn.Text = "−"
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    ESPEnabled = false; ClearESP()
    local w = workspace:FindFirstChild("DivineWaterSolid"); if w then w:Destroy() end
    twFast(mainFrame, {Size = UDim2.new(0, W, 0, 0)})
    task.delay(0.2, function() screenGui:Destroy() end)
end)

-- ==================== PÁGINA INICIAL ====================
showPage(combatPage, tabCombat)

-- ==================== SHIMMER EN DIVIDER (loop) ====================
task.spawn(function()
    local t = 0
    while screenGui.Parent do
        t = t + task.wait(0.045)
        divG.Offset = Vector2.new(math.sin(t) * 0.35, 0)
    end
end)

print("✦ Divine Hub Gold Edition cargado correctamente")
