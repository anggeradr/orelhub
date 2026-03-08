-- ============================================================
--  Brainrot Heroes | Script Hub v6
--  Executor : Delta
--  Auto Collect: CollectBrainrotIncome(brainrotObject) per slot
-- ============================================================

local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RS               = game:GetService("ReplicatedStorage")
local Players          = game:GetService("Players")
local LocalPlayer      = Players.LocalPlayer

-- ============================================================
--  REMOTES
-- ============================================================
local Remotes          = RS:WaitForChild("Remotes", 10)
local CollectOneRemote = Remotes and Remotes:FindFirstChild("CollectBrainrotIncome")

-- ============================================================
--  FIND PLAYER BASE
-- ============================================================
local function getPlayerBase()
    local Bases = workspace:FindFirstChild("Bases")
    if not Bases then return nil end
    -- Base dinamai dengan angka, cari base milik player via CurrentBrainrot atau Children
    -- Coba semua base, cari yang punya Brainrots folder dengan isi
    for _, base in pairs(Bases:GetChildren()) do
        local brainrots = base:FindFirstChild("Brainrots")
        if brainrots and #brainrots:GetChildren() > 0 then
            -- Cek apakah ini base milik local player via PlayerSpawn atau tag
            local playerSpawn = base:FindFirstChild("PlayerSpawn")
            if playerSpawn then
                -- Cek via attribute atau StringValue owner
                local owner = base:GetAttribute("Owner") or base:GetAttribute("Player")
                if owner == LocalPlayer.Name or owner == LocalPlayer.UserId then
                    return base
                end
            end
        end
    end
    -- Fallback: ambil base yang ada Brainrots pertama (base sendiri biasanya sudah terisi)
    for _, base in pairs(Bases:GetChildren()) do
        local brainrots = base:FindFirstChild("Brainrots")
        if brainrots and #brainrots:GetChildren() > 0 then
            return base
        end
    end
    return nil
end

-- ============================================================
--  CONSTANTS
-- ============================================================
local MIN_W, MIN_H = 300, 280
local DEF_W, DEF_H = 360, 420
local TITLE_H      = 40
local TAB_H        = 34
local RESIZE_GRIP  = 14

local RARITIES = {"Rare","Epic","Legendary","Mythic","Godly","Secret"}
local RARITY_COLOR = {
    Rare=Color3.fromRGB(0,112,255), Epic=Color3.fromRGB(163,53,238),
    Legendary=Color3.fromRGB(255,165,0), Mythic=Color3.fromRGB(255,50,50),
    Godly=Color3.fromRGB(255,215,0), Secret=Color3.fromRGB(180,180,180),
}
local TABS      = {"Buy Hero","Auto Farm","Fusion","Settings"}
local TAB_ICONS = {"🛒","⚔️","⚗️","⚙️"}

-- ============================================================
--  CLEANUP
-- ============================================================
local cg = game:GetService("CoreGui")
if cg:FindFirstChild("BHHub") then cg:FindFirstChild("BHHub"):Destroy() end

-- ============================================================
--  ROOT GUI
-- ============================================================
local Gui = Instance.new("ScreenGui")
Gui.Name = "BHHub"; Gui.ResetOnSpawn = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; Gui.Parent = cg

-- ============================================================
--  MAIN WINDOW
-- ============================================================
local Win = Instance.new("Frame")
Win.Name = "Window"; Win.Size = UDim2.new(0,DEF_W,0,DEF_H)
Win.Position = UDim2.new(0.5,-DEF_W/2,0.5,-DEF_H/2)
Win.BackgroundColor3 = Color3.fromRGB(13,13,22)
Win.BorderSizePixel = 0; Win.ClipsDescendants = true; Win.Parent = Gui
Instance.new("UICorner",Win).CornerRadius = UDim.new(0,12)
local winStroke = Instance.new("UIStroke",Win)
winStroke.Color = Color3.fromRGB(70,70,160); winStroke.Thickness = 1.5

-- ============================================================
--  TITLE BAR
-- ============================================================
local TitleBar = Instance.new("Frame",Win)
TitleBar.Size = UDim2.new(1,0,0,TITLE_H)
TitleBar.BackgroundColor3 = Color3.fromRGB(22,22,42)
TitleBar.BorderSizePixel = 0; TitleBar.ZIndex = 5
Instance.new("UICorner",TitleBar).CornerRadius = UDim.new(0,12)
local tbFix = Instance.new("Frame",TitleBar)
tbFix.Size=UDim2.new(1,0,0.5,0); tbFix.Position=UDim2.new(0,0,0.5,0)
tbFix.BackgroundColor3=Color3.fromRGB(22,22,42); tbFix.BorderSizePixel=0; tbFix.ZIndex=5

local Logo = Instance.new("TextLabel",TitleBar)
Logo.Size=UDim2.new(0,26,0,26); Logo.Position=UDim2.new(0,8,0.5,-13)
Logo.BackgroundColor3=Color3.fromRGB(80,60,200); Logo.Text="B"
Logo.TextColor3=Color3.fromRGB(255,255,255); Logo.TextSize=14
Logo.Font=Enum.Font.GothamBold; Logo.ZIndex=6
Instance.new("UICorner",Logo).CornerRadius=UDim.new(0,6)

local TitleTxt = Instance.new("TextLabel",TitleBar)
TitleTxt.Size=UDim2.new(1,-110,1,0); TitleTxt.Position=UDim2.new(0,40,0,0)
TitleTxt.BackgroundTransparency=1; TitleTxt.Text="Brainrot Heroes Hub"
TitleTxt.TextColor3=Color3.fromRGB(215,215,255); TitleTxt.TextSize=13
TitleTxt.Font=Enum.Font.GothamBold; TitleTxt.TextXAlignment=Enum.TextXAlignment.Left; TitleTxt.ZIndex=6

local BtnFrame = Instance.new("Frame",TitleBar)
BtnFrame.Size=UDim2.new(0,88,0,28); BtnFrame.Position=UDim2.new(1,-94,0.5,-14)
BtnFrame.BackgroundTransparency=1; BtnFrame.ZIndex=6
local bfl=Instance.new("UIListLayout",BtnFrame)
bfl.FillDirection=Enum.FillDirection.Horizontal; bfl.Padding=UDim.new(0,4)

local function makeWinBtn(sym,col)
    local b=Instance.new("TextButton",BtnFrame)
    b.Size=UDim2.new(0,26,0,26); b.BackgroundColor3=col; b.Text=sym
    b.TextColor3=Color3.fromRGB(255,255,255); b.TextSize=11
    b.Font=Enum.Font.GothamBold; b.BorderSizePixel=0; b.ZIndex=7
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,6)
    return b
end
local MinBtn   = makeWinBtn("—",Color3.fromRGB(200,160,0))
local MaxBtn   = makeWinBtn("⛶",Color3.fromRGB(0,140,80))
local CloseBtn = makeWinBtn("✕",Color3.fromRGB(200,50,50))

-- ============================================================
--  TAB BAR
-- ============================================================
local TabBar = Instance.new("Frame",Win)
TabBar.Size=UDim2.new(1,-16,0,TAB_H); TabBar.Position=UDim2.new(0,8,0,TITLE_H+6)
TabBar.BackgroundColor3=Color3.fromRGB(20,20,38); TabBar.BorderSizePixel=0; TabBar.ZIndex=4
Instance.new("UICorner",TabBar).CornerRadius=UDim.new(0,8)
local tbl=Instance.new("UIListLayout",TabBar)
tbl.FillDirection=Enum.FillDirection.Horizontal; tbl.Padding=UDim.new(0,2)
Instance.new("UIPadding",TabBar).PaddingLeft=UDim.new(0,4)

-- ============================================================
--  CONTENT AREA
-- ============================================================
local ContentY = TITLE_H+TAB_H+14
local Content = Instance.new("Frame",Win)
Content.Name="Content"; Content.Size=UDim2.new(1,-16,1,-ContentY-26)
Content.Position=UDim2.new(0,8,0,ContentY)
Content.BackgroundColor3=Color3.fromRGB(18,18,32)
Content.BorderSizePixel=0; Content.ClipsDescendants=true; Content.ZIndex=3
Instance.new("UICorner",Content).CornerRadius=UDim.new(0,8)

-- ============================================================
--  RESIZE GRIP
-- ============================================================
local Grip = Instance.new("TextButton",Win)
Grip.Size=UDim2.new(0,RESIZE_GRIP,0,RESIZE_GRIP)
Grip.Position=UDim2.new(1,-RESIZE_GRIP,1,-RESIZE_GRIP)
Grip.BackgroundColor3=Color3.fromRGB(80,80,160); Grip.Text=""
Grip.BorderSizePixel=0; Grip.ZIndex=10
Instance.new("UICorner",Grip).CornerRadius=UDim.new(0,4)
for i=1,3 do
    local ln=Instance.new("Frame",Grip)
    ln.BackgroundColor3=Color3.fromRGB(180,180,255); ln.BorderSizePixel=0
    ln.Size=UDim2.new(0,RESIZE_GRIP-2-i*2,0,1)
    ln.Position=UDim2.new(1,-(RESIZE_GRIP-i*2),0,i*4-1); ln.ZIndex=11
end

-- ============================================================
--  STATUS BAR
-- ============================================================
local StatusBar = Instance.new("Frame",Win)
StatusBar.Size=UDim2.new(1,0,0,22); StatusBar.Position=UDim2.new(0,0,1,-22)
StatusBar.BackgroundColor3=Color3.fromRGB(20,20,38); StatusBar.BorderSizePixel=0; StatusBar.ZIndex=4

local StatusTxt = Instance.new("TextLabel",StatusBar)
StatusTxt.Size=UDim2.new(1,-20,1,0); StatusTxt.Position=UDim2.new(0,8,0,0)
StatusTxt.BackgroundTransparency=1; StatusTxt.Text="✅ Siap"
StatusTxt.TextColor3=Color3.fromRGB(100,220,130); StatusTxt.TextSize=11
StatusTxt.Font=Enum.Font.Gotham; StatusTxt.TextXAlignment=Enum.TextXAlignment.Left; StatusTxt.ZIndex=5

local function setStatus(txt,col)
    StatusTxt.Text=txt; StatusTxt.TextColor3=col or Color3.fromRGB(100,220,130)
end

-- ============================================================
--  HELPERS
-- ============================================================
local function makePage(name)
    local p=Instance.new("ScrollingFrame",Content)
    p.Name=name; p.Size=UDim2.new(1,0,1,0)
    p.BackgroundTransparency=1; p.BorderSizePixel=0
    p.ScrollBarThickness=3; p.ScrollBarImageColor3=Color3.fromRGB(80,80,180)
    p.CanvasSize=UDim2.new(0,0,0,0); p.AutomaticCanvasSize=Enum.AutomaticSize.Y
    p.Visible=false; p.ZIndex=4
    local pad=Instance.new("UIPadding",p)
    pad.PaddingLeft=UDim.new(0,8); pad.PaddingRight=UDim.new(0,8); pad.PaddingTop=UDim.new(0,8)
    local lay=Instance.new("UIListLayout",p)
    lay.Padding=UDim.new(0,8); lay.SortOrder=Enum.SortOrder.LayoutOrder
    return p
end

local function makeLabel(parent,text,size,color,order)
    local l=Instance.new("TextLabel",parent)
    l.Size=UDim2.new(1,0,0,size or 20); l.BackgroundTransparency=1
    l.Text=text; l.TextColor3=color or Color3.fromRGB(180,180,220)
    l.TextSize=size or 12; l.Font=Enum.Font.Gotham
    l.TextXAlignment=Enum.TextXAlignment.Left; l.TextWrapped=true
    l.ZIndex=5; l.LayoutOrder=order or 0
    return l
end

local function makeBtn(parent,text,col,order)
    local b=Instance.new("TextButton",parent)
    b.Size=UDim2.new(1,0,0,38); b.BackgroundColor3=col or Color3.fromRGB(60,60,160)
    b.Text=text; b.TextColor3=Color3.fromRGB(255,255,255)
    b.TextSize=13; b.Font=Enum.Font.GothamBold
    b.BorderSizePixel=0; b.ZIndex=5; b.LayoutOrder=order or 0
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,8)
    local base=col or Color3.fromRGB(60,60,160)
    b.MouseEnter:Connect(function() TweenService:Create(b,TweenInfo.new(0.1),{BackgroundColor3=base:Lerp(Color3.fromRGB(255,255,255),0.15)}):Play() end)
    b.MouseLeave:Connect(function() TweenService:Create(b,TweenInfo.new(0.1),{BackgroundColor3=base}):Play() end)
    return b
end

local function makeToggle(parent,label,default,order)
    local row=Instance.new("Frame",parent)
    row.Size=UDim2.new(1,0,0,34); row.BackgroundColor3=Color3.fromRGB(25,25,45)
    row.BorderSizePixel=0; row.ZIndex=5; row.LayoutOrder=order or 0
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,8)
    local lbl=Instance.new("TextLabel",row)
    lbl.Size=UDim2.new(1,-54,1,0); lbl.Position=UDim2.new(0,10,0,0)
    lbl.BackgroundTransparency=1; lbl.Text=label
    lbl.TextColor3=Color3.fromRGB(190,190,230); lbl.TextSize=12
    lbl.Font=Enum.Font.Gotham; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=6
    local togBg=Instance.new("Frame",row)
    togBg.Size=UDim2.new(0,40,0,20); togBg.Position=UDim2.new(1,-48,0.5,-10)
    togBg.BackgroundColor3=default and Color3.fromRGB(60,180,100) or Color3.fromRGB(60,60,80)
    togBg.BorderSizePixel=0; togBg.ZIndex=6
    Instance.new("UICorner",togBg).CornerRadius=UDim.new(0,10)
    local knob=Instance.new("Frame",togBg)
    knob.Size=UDim2.new(0,16,0,16)
    knob.Position=default and UDim2.new(0,22,0.5,-8) or UDim2.new(0,2,0.5,-8)
    knob.BackgroundColor3=Color3.fromRGB(255,255,255); knob.BorderSizePixel=0; knob.ZIndex=7
    Instance.new("UICorner",knob).CornerRadius=UDim.new(0,8)
    local state=default or false
    local callbacks={}
    local btn=Instance.new("TextButton",row)
    btn.Size=UDim2.new(1,0,1,0); btn.BackgroundTransparency=1; btn.Text=""; btn.ZIndex=8
    btn.MouseButton1Click:Connect(function()
        state=not state
        TweenService:Create(togBg,TweenInfo.new(0.15),{BackgroundColor3=state and Color3.fromRGB(60,180,100) or Color3.fromRGB(60,60,80)}):Play()
        TweenService:Create(knob,TweenInfo.new(0.15),{Position=state and UDim2.new(0,22,0.5,-8) or UDim2.new(0,2,0.5,-8)}):Play()
        for _,cb in ipairs(callbacks) do cb(state) end
    end)
    return {frame=row, getState=function() return state end, onChange=function(cb) table.insert(callbacks,cb) end}
end

local function makeSlider(parent,label,minVal,maxVal,default,order)
    local row=Instance.new("Frame",parent)
    row.Size=UDim2.new(1,0,0,52); row.BackgroundColor3=Color3.fromRGB(25,25,45)
    row.BorderSizePixel=0; row.ZIndex=5; row.LayoutOrder=order or 0
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,8)
    local lbl=Instance.new("TextLabel",row)
    lbl.Size=UDim2.new(1,-60,0,22); lbl.Position=UDim2.new(0,10,0,4)
    lbl.BackgroundTransparency=1; lbl.Text=label
    lbl.TextColor3=Color3.fromRGB(190,190,230); lbl.TextSize=12
    lbl.Font=Enum.Font.Gotham; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=6
    local valLbl=Instance.new("TextLabel",row)
    valLbl.Size=UDim2.new(0,50,0,22); valLbl.Position=UDim2.new(1,-58,0,4)
    valLbl.BackgroundTransparency=1; valLbl.Text=default.."s"
    valLbl.TextColor3=Color3.fromRGB(100,220,180); valLbl.TextSize=12
    valLbl.Font=Enum.Font.GothamBold; valLbl.TextXAlignment=Enum.TextXAlignment.Right; valLbl.ZIndex=6
    local track=Instance.new("Frame",row)
    track.Size=UDim2.new(1,-20,0,6); track.Position=UDim2.new(0,10,0,34)
    track.BackgroundColor3=Color3.fromRGB(40,40,70); track.BorderSizePixel=0; track.ZIndex=6
    Instance.new("UICorner",track).CornerRadius=UDim.new(0,3)
    local fill=Instance.new("Frame",track)
    fill.Size=UDim2.new((default-minVal)/(maxVal-minVal),0,1,0)
    fill.BackgroundColor3=Color3.fromRGB(80,160,255); fill.BorderSizePixel=0; fill.ZIndex=7
    Instance.new("UICorner",fill).CornerRadius=UDim.new(0,3)
    local knob=Instance.new("TextButton",track)
    knob.Size=UDim2.new(0,14,0,14); knob.AnchorPoint=Vector2.new(0.5,0.5)
    knob.Position=UDim2.new((default-minVal)/(maxVal-minVal),0,0.5,0)
    knob.BackgroundColor3=Color3.fromRGB(255,255,255); knob.Text=""; knob.BorderSizePixel=0; knob.ZIndex=8
    Instance.new("UICorner",knob).CornerRadius=UDim.new(0,7)
    local value=default; local dragging=false
    knob.InputBegan:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true end end)
    knob.InputEnded:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
    UserInputService.InputChanged:Connect(function(inp)
        if dragging and inp.UserInputType==Enum.UserInputType.MouseMovement then
            local tAbs=track.AbsolutePosition; local tW=track.AbsoluteSize.X
            local relX=math.clamp(inp.Position.X-tAbs.X,0,tW)
            local pct=relX/tW
            value=math.floor(minVal+pct*(maxVal-minVal)+0.5)
            pct=(value-minVal)/(maxVal-minVal)
            fill.Size=UDim2.new(pct,0,1,0); knob.Position=UDim2.new(pct,0,0.5,0)
            valLbl.Text=value.."s"
        end
    end)
    return {frame=row, getValue=function() return value end}
end

local function makeSep(parent,order)
    local s=Instance.new("Frame",parent)
    s.Size=UDim2.new(1,0,0,1); s.BackgroundColor3=Color3.fromRGB(50,50,80)
    s.BorderSizePixel=0; s.ZIndex=5; s.LayoutOrder=order or 0
    return s
end

-- ============================================================
--  TAB SYSTEM
-- ============================================================
local tabBtns,pages={},{}
local function switchTab(idx)
    for i,b in ipairs(tabBtns) do
        TweenService:Create(b,TweenInfo.new(0.15),{
            BackgroundColor3=i==idx and Color3.fromRGB(70,70,200) or Color3.fromRGB(30,30,55),
            TextColor3=i==idx and Color3.fromRGB(255,255,255) or Color3.fromRGB(150,150,200)
        }):Play()
    end
    for i,p in ipairs(pages) do p.Visible=(i==idx) end
end
for i,tabName in ipairs(TABS) do
    local tb=Instance.new("TextButton",TabBar)
    tb.Size=UDim2.new(1/#TABS,-3,1,-4)
    tb.BackgroundColor3=i==1 and Color3.fromRGB(70,70,200) or Color3.fromRGB(30,30,55)
    tb.Text=TAB_ICONS[i].." "..tabName
    tb.TextColor3=i==1 and Color3.fromRGB(255,255,255) or Color3.fromRGB(150,150,200)
    tb.TextSize=11; tb.Font=Enum.Font.GothamBold; tb.BorderSizePixel=0; tb.ZIndex=5
    Instance.new("UICorner",tb).CornerRadius=UDim.new(0,6)
    local idx=i; tb.MouseButton1Click:Connect(function() switchTab(idx) end)
    tabBtns[i]=tb; pages[i]=makePage(tabName)
end
pages[1].Visible=true

-- ============================================================
--  PAGE 1: BUY HERO
-- ============================================================
local buyPage=pages[1]
local selectedRarity="Rare"
local selectedHeroName=""
local dropOpen=false
local buyMode="rarity" -- "rarity" atau "name"

-- Mode selector
local modeRow = Instance.new("Frame",buyPage)
modeRow.Size=UDim2.new(1,0,0,32); modeRow.BackgroundColor3=Color3.fromRGB(20,20,38)
modeRow.BorderSizePixel=0; modeRow.ZIndex=5; modeRow.LayoutOrder=1
Instance.new("UICorner",modeRow).CornerRadius=UDim.new(0,8)
local modeLayout=Instance.new("UIListLayout",modeRow)
modeLayout.FillDirection=Enum.FillDirection.Horizontal; modeLayout.Padding=UDim.new(0,4)
Instance.new("UIPadding",modeRow).PaddingLeft=UDim.new(0,4)
Instance.new("UIPadding",modeRow).PaddingTop=UDim.new(0,4)

local function makeModeBtn(text,active)
    local b=Instance.new("TextButton",modeRow)
    b.Size=UDim2.new(0.5,-6,0,24)
    b.BackgroundColor3=active and Color3.fromRGB(70,70,200) or Color3.fromRGB(30,30,55)
    b.Text=text; b.TextColor3=active and Color3.fromRGB(255,255,255) or Color3.fromRGB(150,150,200)
    b.TextSize=11; b.Font=Enum.Font.GothamBold; b.BorderSizePixel=0; b.ZIndex=6
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,6)
    return b
end
local modeRarityBtn = makeModeBtn("🎲 Rarity",true)
local modeNameBtn   = makeModeBtn("🔤 Nama Hero",false)

-- Rarity section
local raritySection = Instance.new("Frame",buyPage)
raritySection.Size=UDim2.new(1,0,0,38); raritySection.BackgroundTransparency=1
raritySection.BorderSizePixel=0; raritySection.ZIndex=5; raritySection.LayoutOrder=2

local dropBtn=Instance.new("TextButton",raritySection)
dropBtn.Size=UDim2.new(1,0,1,0); dropBtn.BackgroundColor3=Color3.fromRGB(28,28,52)
dropBtn.Text="▼   "..selectedRarity; dropBtn.TextColor3=RARITY_COLOR[selectedRarity]
dropBtn.TextSize=14; dropBtn.Font=Enum.Font.GothamBold
dropBtn.BorderSizePixel=0; dropBtn.ZIndex=5
Instance.new("UICorner",dropBtn).CornerRadius=UDim.new(0,8)
local dropStroke=Instance.new("UIStroke",dropBtn)
dropStroke.Color=RARITY_COLOR[selectedRarity]; dropStroke.Thickness=1.2

local dropList=Instance.new("Frame",Win)
dropList.Size=UDim2.new(1,-16,0,0); dropList.Position=UDim2.new(0,8,0,0)
dropList.BackgroundColor3=Color3.fromRGB(22,22,42); dropList.BorderSizePixel=0
dropList.ClipsDescendants=true; dropList.ZIndex=20; dropList.Visible=false
Instance.new("UICorner",dropList).CornerRadius=UDim.new(0,8)
Instance.new("UIStroke",dropList).Color=Color3.fromRGB(80,80,160)
local dLayout=Instance.new("UIListLayout",dropList); dLayout.Padding=UDim.new(0,2)
Instance.new("UIPadding",dropList).PaddingTop=UDim.new(0,4)

local function closeDropdown()
    dropOpen=false; dropBtn.Text="▼   "..selectedRarity
    TweenService:Create(dropList,TweenInfo.new(0.15),{Size=UDim2.new(1,-16,0,0)}):Play()
    task.wait(0.15); dropList.Visible=false
end
local function openDropdown()
    local relY=dropBtn.AbsolutePosition.Y-Win.AbsolutePosition.Y+40
    dropList.Position=UDim2.new(0,8,0,relY); dropList.Visible=true; dropOpen=true
    dropBtn.Text="▲   "..selectedRarity
    TweenService:Create(dropList,TweenInfo.new(0.15),{Size=UDim2.new(1,-16,0,#RARITIES*34+(#RARITIES-1)*2+8)}):Play()
end
for i,rarity in ipairs(RARITIES) do
    local item=Instance.new("TextButton",dropList)
    item.Size=UDim2.new(1,0,0,34); item.BackgroundColor3=Color3.fromRGB(28,28,52)
    item.Text="  "..rarity; item.TextColor3=RARITY_COLOR[rarity]
    item.TextSize=13; item.Font=Enum.Font.GothamBold
    item.TextXAlignment=Enum.TextXAlignment.Left; item.BorderSizePixel=0; item.LayoutOrder=i; item.ZIndex=21
    Instance.new("UICorner",item).CornerRadius=UDim.new(0,6)
    item.MouseEnter:Connect(function() TweenService:Create(item,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(48,48,85)}):Play() end)
    item.MouseLeave:Connect(function() TweenService:Create(item,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(28,28,52)}):Play() end)
    item.MouseButton1Click:Connect(function()
        selectedRarity=rarity; dropBtn.Text="▼   "..rarity
        dropBtn.TextColor3=RARITY_COLOR[rarity]; dropStroke.Color=RARITY_COLOR[rarity]; closeDropdown()
    end)
end
dropBtn.MouseButton1Click:Connect(function() if dropOpen then closeDropdown() else openDropdown() end end)

-- Hero list
local HERO_NAMES = {
    "Warrior","Archer","Mage","Viking","Ninja","Assassin",
    "Alchemist","Gunslinger","Samurai","Necromancer","Paladin",
    "Bomber","Caveman","Pirate","Chef","Cyborg","Mummy"
}
local selectedHeroes = {} -- table nama hero yang dipilih

-- Name section
local nameSection = Instance.new("Frame",buyPage)
nameSection.Size=UDim2.new(1,0,0,38); nameSection.BackgroundTransparency=1
nameSection.BorderSizePixel=0; nameSection.ZIndex=5; nameSection.LayoutOrder=3
nameSection.Visible=false

local function getSelectedHeroText()
    if #selectedHeroes==0 then return "▼   Pilih Hero..." end
    if #selectedHeroes==1 then return "▼   "..selectedHeroes[1] end
    return "▼   "..selectedHeroes[1].." +"..tostring(#selectedHeroes-1).." lainnya"
end

local nameDropBtn=Instance.new("TextButton",nameSection)
nameDropBtn.Size=UDim2.new(1,0,1,0)
nameDropBtn.BackgroundColor3=Color3.fromRGB(28,28,52)
nameDropBtn.Text=getSelectedHeroText()
nameDropBtn.TextColor3=Color3.fromRGB(180,180,255)
nameDropBtn.TextSize=13; nameDropBtn.Font=Enum.Font.GothamBold
nameDropBtn.BorderSizePixel=0; nameDropBtn.ZIndex=5
Instance.new("UICorner",nameDropBtn).CornerRadius=UDim.new(0,8)
local nameDropStroke=Instance.new("UIStroke",nameDropBtn)
nameDropStroke.Color=Color3.fromRGB(80,80,160); nameDropStroke.Thickness=1.2

-- Multi-select dropdown list
local nameDropList=Instance.new("Frame",Win)
nameDropList.Size=UDim2.new(1,-16,0,0); nameDropList.Position=UDim2.new(0,8,0,0)
nameDropList.BackgroundColor3=Color3.fromRGB(22,22,42); nameDropList.BorderSizePixel=0
nameDropList.ClipsDescendants=true; nameDropList.ZIndex=20; nameDropList.Visible=false
Instance.new("UICorner",nameDropList).CornerRadius=UDim.new(0,8)
Instance.new("UIStroke",nameDropList).Color=Color3.fromRGB(80,80,160)

-- ScrollingFrame agar bisa di-scroll
local nameDropScroll=Instance.new("ScrollingFrame",nameDropList)
nameDropScroll.Size=UDim2.new(1,0,1,0)
nameDropScroll.BackgroundTransparency=1; nameDropScroll.BorderSizePixel=0
nameDropScroll.ScrollBarThickness=4
nameDropScroll.ScrollBarImageColor3=Color3.fromRGB(80,80,180)
nameDropScroll.CanvasSize=UDim2.new(0,0,0,0)
nameDropScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y
nameDropScroll.ZIndex=21
local ndLayout=Instance.new("UIListLayout",nameDropScroll); ndLayout.Padding=UDim.new(0,2)
local ndPad=Instance.new("UIPadding",nameDropScroll)
ndPad.PaddingTop=UDim.new(0,4); ndPad.PaddingRight=UDim.new(0,6)

local NAME_DROP_MAX_H=180

local nameDropOpen=false
local heroItemBtns={}

local function updateNameDropBtn()
    nameDropBtn.Text=getSelectedHeroText()
end

local function closeNameDropdown()
    nameDropOpen=false
    TweenService:Create(nameDropList,TweenInfo.new(0.15),{Size=UDim2.new(1,-16,0,0)}):Play()
    task.wait(0.15); nameDropList.Visible=false
    updateNameDropBtn()
end

local function openNameDropdown()
    local relY=nameDropBtn.AbsolutePosition.Y-Win.AbsolutePosition.Y+40
    nameDropList.Position=UDim2.new(0,8,0,relY)
    nameDropList.Visible=true; nameDropOpen=true
    TweenService:Create(nameDropList,TweenInfo.new(0.15),{Size=UDim2.new(1,-16,0,NAME_DROP_MAX_H)}):Play()
end

-- Populate hero items
for i,heroName in ipairs(HERO_NAMES) do
    local item=Instance.new("Frame",nameDropScroll)
    item.Size=UDim2.new(1,0,0,34); item.BackgroundColor3=Color3.fromRGB(28,28,52)
    item.BorderSizePixel=0; item.LayoutOrder=i; item.ZIndex=21
    Instance.new("UICorner",item).CornerRadius=UDim.new(0,6)

    -- Checkbox
    local checkbox=Instance.new("Frame",item)
    checkbox.Size=UDim2.new(0,18,0,18); checkbox.Position=UDim2.new(0,8,0.5,-9)
    checkbox.BackgroundColor3=Color3.fromRGB(40,40,70); checkbox.BorderSizePixel=0; checkbox.ZIndex=22
    Instance.new("UICorner",checkbox).CornerRadius=UDim.new(0,4)
    Instance.new("UIStroke",checkbox).Color=Color3.fromRGB(80,80,160)

    local checkMark=Instance.new("TextLabel",checkbox)
    checkMark.Size=UDim2.new(1,0,1,0); checkMark.BackgroundTransparency=1
    checkMark.Text="✓"; checkMark.TextColor3=Color3.fromRGB(100,220,130)
    checkMark.TextSize=13; checkMark.Font=Enum.Font.GothamBold
    checkMark.ZIndex=23; checkMark.Visible=false

    local lbl=Instance.new("TextLabel",item)
    lbl.Size=UDim2.new(1,-36,1,0); lbl.Position=UDim2.new(0,34,0,0)
    lbl.BackgroundTransparency=1; lbl.Text=heroName
    lbl.TextColor3=Color3.fromRGB(200,200,240); lbl.TextSize=13
    lbl.Font=Enum.Font.GothamBold; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=22

    local btn=Instance.new("TextButton",item)
    btn.Size=UDim2.new(1,0,1,0); btn.BackgroundTransparency=1; btn.Text=""; btn.ZIndex=23

    local isSelected=false
    local function updateItem()
        if isSelected then
            TweenService:Create(checkbox,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(60,180,100)}):Play()
            checkMark.Visible=true
            lbl.TextColor3=Color3.fromRGB(100,220,130)
        else
            TweenService:Create(checkbox,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(40,40,70)}):Play()
            checkMark.Visible=false
            lbl.TextColor3=Color3.fromRGB(200,200,240)
        end
    end

    btn.MouseButton1Click:Connect(function()
        isSelected=not isSelected
        if isSelected then
            table.insert(selectedHeroes,heroName)
        else
            table.remove(selectedHeroes,table.find(selectedHeroes,heroName))
        end
        updateItem()
        updateNameDropBtn()
    end)

    btn.MouseEnter:Connect(function() TweenService:Create(item,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(38,38,65)}):Play() end)
    btn.MouseLeave:Connect(function() TweenService:Create(item,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(28,28,52)}):Play() end)

    heroItemBtns[heroName]={item=item,isSelected=function() return isSelected end}
end

nameDropBtn.MouseButton1Click:Connect(function()
    if nameDropOpen then closeNameDropdown() else openNameDropdown() end
end)

-- Mode switch logic
local function setMode(mode)
    buyMode=mode
    if mode=="rarity" then
        raritySection.Visible=true; nameSection.Visible=false
        TweenService:Create(modeRarityBtn,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(70,70,200),TextColor3=Color3.fromRGB(255,255,255)}):Play()
        TweenService:Create(modeNameBtn,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(30,30,55),TextColor3=Color3.fromRGB(150,150,200)}):Play()
    else
        raritySection.Visible=false; nameSection.Visible=true
        TweenService:Create(modeNameBtn,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(70,70,200),TextColor3=Color3.fromRGB(255,255,255)}):Play()
        TweenService:Create(modeRarityBtn,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(30,30,55),TextColor3=Color3.fromRGB(150,150,200)}):Play()
    end
end
modeRarityBtn.MouseButton1Click:Connect(function() setMode("rarity") end)
modeNameBtn.MouseButton1Click:Connect(function() setMode("name") end)

makeSep(buyPage,4)

-- ============================================================
--  HELPER: dapatkan rarity dari hero
-- ============================================================
local function getHeroRarity(model)
    local hrp=model:FindFirstChild("HumanoidRootPart"); if not hrp then return nil end
    local bb=hrp:FindFirstChild("HeroBillboard"); if not bb then return nil end
    local rl=bb:FindFirstChild("HeroRarity")
    if rl and rl:IsA("TextLabel") then return rl.Text end
    return nil
end

-- ============================================================
--  HELPER: dapatkan nama hero dari billboard
-- ============================================================
local function getHeroName(model)
    local hrp=model:FindFirstChild("HumanoidRootPart"); if not hrp then return model.Name end
    local bb=hrp:FindFirstChild("HeroBillboard"); if not bb then return model.Name end
    local nl=bb:FindFirstChild("HeroName")
    if nl and nl:IsA("TextLabel") then
        -- HeroName format: "Paladin (30s)", ambil nama saja
        return nl.Text:match("^(.-)%s*%(") or nl.Text
    end
    return model.Name
end

-- ============================================================
--  BUY LOGIC
-- ============================================================
local function doBuyHero()
    if dropOpen then closeDropdown(); return end
    if nameDropOpen then closeNameDropdown(); return end
    local HeroCenter=workspace:FindFirstChild("HeroCenter")
    if not HeroCenter then
        setStatus("❌ HeroCenter tidak ditemukan",Color3.fromRGB(255,80,80)); return
    end

    local found=false
    for _,h in pairs(HeroCenter:GetChildren()) do
        if not h:IsA("Model") then continue end

        local match=false
        if buyMode=="rarity" then
            local r=getHeroRarity(h)
            match = r and r:lower()==selectedRarity:lower()
        else
            -- Mode nama: cocokkan dengan salah satu dari selectedHeroes
            if #selectedHeroes==0 then
                setStatus("❌ Belum ada hero dipilih!",Color3.fromRGB(255,80,80)); return
            end
            local heroName=getHeroName(h)
            for _,target in ipairs(selectedHeroes) do
                if h.Name:lower()==target:lower() or heroName:lower()==target:lower() then
                    match=true; break
                end
            end
        end

        if match then
            local hrp=h:FindFirstChild("HumanoidRootPart")
            local prompt=hrp and hrp:FindFirstChild("HeroPurchasePrompt")
            if prompt then
                local ok,err=pcall(function() fireproximityprompt(prompt) end)
                local heroName=getHeroName(h)
                local r=getHeroRarity(h) or "?"
                if ok then
                    setStatus("✅ Beli "..heroName.." ["..r.."] berhasil!",Color3.fromRGB(50,220,100))
                else
                    setStatus("❌ "..tostring(err),Color3.fromRGB(255,80,80))
                end
                found=true; break
            end
        end
    end

    if not found then
        if buyMode=="rarity" then
            setStatus("❌ Hero '"..selectedRarity.."' tidak ada di circle",Color3.fromRGB(255,80,80))
        else
            setStatus("❌ Hero yang dipilih tidak ada di circle",Color3.fromRGB(255,80,80))
        end
    end
end

-- Toggle Buy Hero
local buyToggle=makeToggle(buyPage,"🛒  Auto Buy Hero",false,5)
local buyRunning=false
buyToggle.onChange(function(state)
    buyRunning=state
    if state then
        local info = buyMode=="rarity" and selectedRarity or (selectedHeroName~="" and selectedHeroName or "?")
        setStatus("🛒 Auto Buy ON — "..(buyMode=="rarity" and "rarity" or "nama")..": "..info,Color3.fromRGB(50,220,100))
        task.spawn(function()
            while buyRunning do
                doBuyHero()
                task.wait(1)
            end
        end)
    else
        setStatus("✅ Auto Buy dimatikan",Color3.fromRGB(100,220,130))
    end
end)

-- ============================================================
--  COLLECT INCOME CORE FUNCTION
-- ============================================================
local function collectAllIncome()
    if not CollectOneRemote then
        return 0, "Remote CollectBrainrotIncome tidak ditemukan"
    end

    local base = getPlayerBase()
    if not base then
        return 0, "Base player tidak ditemukan"
    end

    local brainrots = base:FindFirstChild("Brainrots")
    if not brainrots then
        return 0, "Folder Brainrots tidak ditemukan di base"
    end

    local collected = 0
    local failed = 0
    for _, br in pairs(brainrots:GetChildren()) do
        if br:IsA("Model") then
            local ok, res = pcall(function()
                return CollectOneRemote:InvokeServer(br)
            end)
            if ok and res then
                collected += 1
            else
                failed += 1
            end
            task.wait(0.05) -- jeda kecil antar invoke
        end
    end

    return collected, "Collected "..collected.." brainrot(s)"
end

-- ============================================================
--  PAGE 2: AUTO FARM
-- ============================================================
local farmPage=pages[2]
makeLabel(farmPage,"⚔️  Auto Farm",14,Color3.fromRGB(200,200,255),1)
makeSep(farmPage,2)

local acToggle     = makeToggle(farmPage,"Auto Collect Income",false,3)
local intSlider    = makeSlider(farmPage,"Interval Collect",1,60,10,4)
makeSep(farmPage,5)

-- Info card
local infoCard = Instance.new("Frame",farmPage)
infoCard.Size=UDim2.new(1,0,0,52); infoCard.BackgroundColor3=Color3.fromRGB(20,35,20)
infoCard.BorderSizePixel=0; infoCard.ZIndex=5; infoCard.LayoutOrder=6
Instance.new("UICorner",infoCard).CornerRadius=UDim.new(0,8)
Instance.new("UIStroke",infoCard).Color=Color3.fromRGB(40,120,60)
local infoTxt=Instance.new("TextLabel",infoCard)
infoTxt.Size=UDim2.new(1,-16,1,0); infoTxt.Position=UDim2.new(0,8,0,0)
infoTxt.BackgroundTransparency=1; infoTxt.TextWrapped=true
infoTxt.Text="ℹ️  Collect satu per satu via CollectBrainrotIncome\n✅ Remote: "..(CollectOneRemote and "Ditemukan" or "❌ Tidak ditemukan")
infoTxt.TextColor3=Color3.fromRGB(100,200,120); infoTxt.TextSize=11
infoTxt.Font=Enum.Font.Gotham; infoTxt.TextXAlignment=Enum.TextXAlignment.Left; infoTxt.ZIndex=6

makeSep(farmPage,7)

-- Collect once button
local collectBtn=makeBtn(farmPage,"💰  Collect Sekarang",Color3.fromRGB(180,120,0),8)
collectBtn.MouseButton1Click:Connect(function()
    collectBtn.Active=false; collectBtn.BackgroundColor3=Color3.fromRGB(120,80,0)
    setStatus("🔄 Collecting...",Color3.fromRGB(255,200,50))
    local n, msg = collectAllIncome()
    if n > 0 then
        setStatus("✅ "..msg,Color3.fromRGB(50,220,100))
    else
        setStatus("❌ "..msg,Color3.fromRGB(255,80,80))
    end
    task.wait(0.5)
    collectBtn.Active=true; collectBtn.BackgroundColor3=Color3.fromRGB(180,120,0)
end)

-- Auto collect loop
local collectRunning=false
acToggle.onChange(function(state)
    collectRunning=state
    if state then
        setStatus("💰 Auto Collect ON — interval "..intSlider.getValue().."s",Color3.fromRGB(100,220,130))
        task.spawn(function()
            while collectRunning do
                local interval=intSlider.getValue()
                local n,msg=collectAllIncome()
                if n>0 then
                    setStatus("💰 "..msg.." | tiap "..interval.."s",Color3.fromRGB(50,220,100))
                else
                    setStatus("⚠️ "..msg,Color3.fromRGB(255,150,50))
                end
                task.wait(interval)
            end
        end)
    else
        setStatus("✅ Auto Collect dimatikan",Color3.fromRGB(100,220,130))
    end
end)


-- ============================================================
--  PAGE 3: FUSION
-- ============================================================
local fusePage=pages[3]
local fuseRunning=false
local FuseRemote=Remotes and Remotes:FindFirstChild("AttemptFuseHero")
local GetDataRemote=Remotes and Remotes:FindFirstChild("GetPlayerData")

makeLabel(fusePage,"⚗️  Auto Fuse Hero",14,Color3.fromRGB(200,180,255),1)
makeSep(fusePage,2)
makeLabel(fusePage,"Otomatis fuse hero yang punya 2+ copy di inventory.",11,Color3.fromRGB(130,130,180),3)
makeSep(fusePage,4)

-- Status card
local fuseCard=Instance.new("Frame",fusePage)
fuseCard.Size=UDim2.new(1,0,0,44); fuseCard.BackgroundColor3=Color3.fromRGB(20,18,40)
fuseCard.BorderSizePixel=0; fuseCard.ZIndex=5; fuseCard.LayoutOrder=5
Instance.new("UICorner",fuseCard).CornerRadius=UDim.new(0,8)
Instance.new("UIStroke",fuseCard).Color=Color3.fromRGB(100,60,200)
local fuseTxt=Instance.new("TextLabel",fuseCard)
fuseTxt.Size=UDim2.new(1,-16,1,0); fuseTxt.Position=UDim2.new(0,8,0,0)
fuseTxt.BackgroundTransparency=1; fuseTxt.TextWrapped=true
fuseTxt.Text="⚗️  Remote: "..(FuseRemote and "✅ Ditemukan" or "❌ Tidak ditemukan")
fuseTxt.TextColor3=Color3.fromRGB(180,140,255); fuseTxt.TextSize=11
fuseTxt.Font=Enum.Font.Gotham; fuseTxt.TextXAlignment=Enum.TextXAlignment.Left; fuseTxt.ZIndex=6

makeSep(fusePage,6)

-- Fuse once button
local fuseOnceBtn=makeBtn(fusePage,"⚗️  Fuse Sekarang",Color3.fromRGB(100,50,200),7)

local PlaceHeroRemote  = Remotes and Remotes:FindFirstChild("PlaceHero")
local PickUpHeroRemote = Remotes and Remotes:FindFirstChild("PickUpHero")

local function doFuse()
    if not FuseRemote or not GetDataRemote or not PlaceHeroRemote or not PickUpHeroRemote then
        setStatus("❌ Remote Error", Color3.fromRGB(255,80,80)); return 0
    end

    -- 1. CEK JARAK (PENTING!)
    -- Banyak game membatalkan Remote jika player jauh dari mesin
    local fm = workspace:FindFirstChild("FuseMachine")
    local mainPart = fm and (fm:FindFirstChild("Control") and fm.Control:FindFirstChild("Main") or fm:FindFirstChild("Main"))
    
    if mainPart then
        local dist = (LocalPlayer.Character.HumanoidRootPart.Position - mainPart.Position).Magnitude
        if dist > 15 then
            setStatus("📍 Dekati Fuse Machine dulu!", Color3.fromRGB(255,150,50))
            return 0
        end
    end

    -- 2. AMBIL DATA HERO TERBARU
    local ok, data = pcall(function() return GetDataRemote:InvokeServer() end)
    if not ok or not data or not data.Heroes then
        setStatus("❌ Gagal ambil data", Color3.fromRGB(255,80,80)); return 0
    end

    -- 3. GROUPING BERDASARKAN HEROID (Nama Jenis Hero)
    local groups = {}
    for _, hero in pairs(data.Heroes) do
        local id = hero.HeroId or hero.Name -- Cek mana yang dipakai game
        if id then
            if not groups[id] then groups[id] = {} end
            table.insert(groups[id], hero)
        end
    end

    local fuseCount = 0
    for id, group in pairs(groups) do
        local rank = group[1].Rank or 1
        local needed = rank + 1
        
        if #group >= needed then
            setStatus("⚗️ Menyiapkan " .. id .. "...", Color3.fromRGB(180,140,255))
            
            -- 4. PROSES TARUH HERO (PLACE)
            local successPlaced = 0
            for i = 1, needed do
                local heroData = group[i]
                -- Gunakan UUID jika ada, jika tidak pakai tabel heroData langsung
                local identifier = heroData.UUID or heroData.Id or heroData

                -- Kita coba PickUp dulu baru Place (urutan standar simulator)
                pcall(function() PickUpHeroRemote:FireServer(identifier) end)
                task.wait(0.3) 
                
                local pOk, pErr = pcall(function() return PlaceHeroRemote:FireServer(identifier) end)
                if pOk then
                    successPlaced += 1
                end
                task.wait(0.3)
            end
            
            -- 5. EKSEKUSI FUSE JIKA SEMUA SUDAH DI SLOT
            if successPlaced >= needed then
                task.wait(0.5)
                -- Trigger tombol fisik mesin (opsional tapi disarankan)
                local prompt = mainPart:FindFirstChildOfClass("ProximityPrompt")
                if prompt then fireproximityprompt(prompt) end
                
                task.wait(0.5)
                local fOk, fRes = pcall(function() 
                    return FuseRemote:InvokeServer(group[1].UUID or group[1]) 
                end)
                
                if fOk then
                    fuseCount += 1
                    setStatus("✅ Fuse " .. id .. " Berhasil!", Color3.fromRGB(50,220,100))
                else
                    setStatus("⚠️ Fuse Gagal: " .. tostring(fRes), Color3.fromRGB(255,100,100))
                end
            else
                setStatus("⚠️ Gagal menaruh hero di slot", Color3.fromRGB(255,150,50))
            end
            task.wait(1)
        end
    end
    return fuseCount
end

fuseOnceBtn.MouseButton1Click:Connect(function()
    fuseOnceBtn.Active=false; fuseOnceBtn.BackgroundColor3=Color3.fromRGB(60,30,120)
    doFuse()
    task.wait(0.5)
    fuseOnceBtn.Active=true; fuseOnceBtn.BackgroundColor3=Color3.fromRGB(100,50,200)
end)

makeSep(fusePage,8)

-- Auto fuse toggle
local fuseToggle=makeToggle(fusePage,"⚗️  Auto Fuse",false,9)
fuseToggle.onChange(function(state)
    fuseRunning=state
    if state then
        setStatus("⚗️ Auto Fuse ON",Color3.fromRGB(180,140,255))
        task.spawn(function()
            while fuseRunning do
                doFuse()
                task.wait(5)
            end
        end)
    else
        setStatus("✅ Auto Fuse dimatikan",Color3.fromRGB(100,220,130))
    end
end)

-- ============================================================
--  PAGE 4: SETTINGS
-- ============================================================
local setPage=pages[4]
makeLabel(setPage,"⚙️  Settings",14,Color3.fromRGB(200,200,255),1)
makeSep(setPage,2)
makeToggle(setPage,"Tampilkan Notifikasi",true,3)
makeSep(setPage,4)
local resetBtn=makeBtn(setPage,"🔄  Reset Posisi Window",Color3.fromRGB(80,80,160),5)
resetBtn.MouseButton1Click:Connect(function()
    TweenService:Create(Win,TweenInfo.new(0.3,Enum.EasingStyle.Back),
        {Position=UDim2.new(0.5,-DEF_W/2,0.5,-DEF_H/2),Size=UDim2.new(0,DEF_W,0,DEF_H)}):Play()
    setStatus("✅ Posisi di-reset",Color3.fromRGB(100,220,130))
end)
local closeAllBtn=makeBtn(setPage,"❌  Tutup Hub",Color3.fromRGB(180,40,40),6)
closeAllBtn.MouseButton1Click:Connect(function() collectRunning=false; fuseRunning=false; Gui:Destroy() end)

-- ============================================================
--  WINDOW CONTROLS
-- ============================================================
local minimized,savedH=false,DEF_H
MinBtn.MouseButton1Click:Connect(function()
    minimized=not minimized
    if minimized then
        savedH=Win.AbsoluteSize.Y
        TweenService:Create(Win,TweenInfo.new(0.2),{Size=UDim2.new(0,Win.AbsoluteSize.X,0,TITLE_H)}):Play()
        MinBtn.Text="▲"
    else
        TweenService:Create(Win,TweenInfo.new(0.2),{Size=UDim2.new(0,Win.AbsoluteSize.X,0,savedH)}):Play()
        MinBtn.Text="—"
    end
end)

local maximized,savedSize,savedPos=false,nil,nil
MaxBtn.MouseButton1Click:Connect(function()
    maximized=not maximized
    if maximized then
        savedSize=Win.Size; savedPos=Win.Position
        TweenService:Create(Win,TweenInfo.new(0.2),
            {Size=UDim2.new(0,500,0,520),Position=UDim2.new(0.5,-250,0.5,-260)}):Play()
        MaxBtn.Text="⧉"
    else
        TweenService:Create(Win,TweenInfo.new(0.2),{Size=savedSize,Position=savedPos}):Play()
        MaxBtn.Text="⛶"
    end
end)

CloseBtn.MouseButton1Click:Connect(function() collectRunning=false; Gui:Destroy() end)

-- ============================================================
--  DRAG
-- ============================================================
local dragging,dragStart,startPos2=false,nil,nil

-- Drag: deteksi klik di title bar via UserInputService
UserInputService.InputBegan:Connect(function(inp, processed)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
        local mousePos = UserInputService:GetMouseLocation()
        local winPos   = Win.AbsolutePosition
        local relX = mousePos.X - winPos.X
        local relY = mousePos.Y - winPos.Y
        -- Cek apakah klik di dalam area title bar
        if relX >= 0 and relX <= Win.AbsoluteSize.X
        and relY >= 0 and relY <= TITLE_H then
            dragging   = true
            dragStart  = mousePos
            startPos2  = Win.Position
        end
    end
end)
UserInputService.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)
UserInputService.InputChanged:Connect(function(inp)
    if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
        local mousePos = UserInputService:GetMouseLocation()
        local d = mousePos - dragStart
        Win.Position = UDim2.new(
            startPos2.X.Scale, startPos2.X.Offset + d.X,
            startPos2.Y.Scale, startPos2.Y.Offset + d.Y
        )
    end
end)

-- ============================================================
--  RESIZE
-- ============================================================
local resizing,resizeStart,startSize3=false,nil,nil
Grip.InputBegan:Connect(function(inp)
    if inp.UserInputType==Enum.UserInputType.MouseButton1 then
        resizing=true
        resizeStart=UserInputService:GetMouseLocation()
        startSize3=Win.AbsoluteSize
    end
end)
Grip.InputEnded:Connect(function(inp)
    if inp.UserInputType==Enum.UserInputType.MouseButton1 then resizing=false end
end)
UserInputService.InputChanged:Connect(function(inp)
    if resizing and inp.UserInputType==Enum.UserInputType.MouseMovement then
        local mousePos=UserInputService:GetMouseLocation()
        local d=mousePos-resizeStart
        Win.Size=UDim2.new(0,math.max(MIN_W,startSize3.X+d.X),0,math.max(MIN_H,startSize3.Y+d.Y))
    end
end)

print("[Brainrot Heroes Hub] v6 Loaded!")
print("  CollectOne:", CollectOneRemote and "✅" or "❌")
setStatus("✅ Hub v6 siap!",Color3.fromRGB(100,220,130))
