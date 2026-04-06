local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local ProximityPromptService = game:GetService("ProximityPromptService")

local ProtectGui = (gethui and gethui()) or CoreGui

if ProtectGui:FindFirstChild("RebootedMenu") then 
    ProtectGui.RebootedMenu:Destroy() 
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RebootedMenu"
screenGui.ResetOnSpawn = false 
screenGui.Parent = ProtectGui

-- === BIẾN HỆ THỐNG ===
_G.AutoRoll = _G.AutoRoll or false
_G.MainFarm = _G.MainFarm or false
_G.AutoSkillE = _G.AutoSkillE or false
_G.AutoSkillR = _G.AutoSkillR or false
_G.AutoSkillT = _G.AutoSkillT or false
_G.AutoSkillF = _G.AutoSkillF or false
_G.AutoSkillZ = _G.AutoSkillZ or false
_G.AutoSkillX = _G.AutoSkillX or false

local SelectedNPCData = { Name = "NONE" }
local arrowOptions = {"Charged Arrow", "Stand Arrow"}
local arrowName = arrowOptions[1]
local keepAttri = {["Scourge"] = true, ["Hacker"] = true, ["Legendary"] = true, ["Glass Cannon"] = true}
local flySpeed = 150 
local currentTween = nil
local POS_MAIN_STABMAN = Vector3.new(-40.3, 67.1, -468.7) 
local POS_APEX = Vector3.new(-312.9, 66.8, 144.7)

-- ====================== GIAO DIỆN CHÍNH ======================
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 750, 0, 500)
mainFrame.Position = UDim2.new(0.5, -375, 0.5, -250)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)

local leftFrame = Instance.new("Frame")
leftFrame.Size = UDim2.new(0, 220, 1, -20)
leftFrame.Position = UDim2.new(0, 10, 0, 10)
leftFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
leftFrame.Parent = mainFrame
Instance.new("UICorner", leftFrame).CornerRadius = UDim.new(0, 8)
local leftLayout = Instance.new("UIListLayout", leftFrame)
leftLayout.Padding = UDim.new(0, 8)
leftLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local rightFrame = Instance.new("Frame")
rightFrame.Size = UDim2.new(1, -250, 1, -20)
rightFrame.Position = UDim2.new(0, 240, 0, 10)
rightFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
rightFrame.Parent = mainFrame
Instance.new("UICorner", rightFrame).CornerRadius = UDim.new(0, 12)

-- === CONTAINERS (CÁC TRANG) ===
local infoContainer = Instance.new("ScrollingFrame")
infoContainer.Size = UDim2.new(1, -10, 1, -10)
infoContainer.Position = UDim2.new(0, 5, 0, 5)
infoContainer.BackgroundTransparency = 1
infoContainer.ScrollBarThickness = 4
infoContainer.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
infoContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
infoContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
infoContainer.Parent = rightFrame
infoContainer.Visible = true 

local rollContainer = Instance.new("Frame")
rollContainer.Size = UDim2.new(1, 0, 1, 0)
rollContainer.BackgroundTransparency = 1
rollContainer.Parent = rightFrame
rollContainer.Visible = false

local lairContainer = Instance.new("Frame")
lairContainer.Size = UDim2.new(1, 0, 1, 0)
lairContainer.BackgroundTransparency = 1
lairContainer.Parent = rightFrame
lairContainer.Visible = false

local skillContainer = Instance.new("ScrollingFrame")
skillContainer.Size = UDim2.new(1, -10, 1, -10)
skillContainer.Position = UDim2.new(0, 5, 0, 5)
skillContainer.BackgroundTransparency = 1
skillContainer.ScrollBarThickness = 4
skillContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
skillContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
skillContainer.Parent = rightFrame
skillContainer.Visible = false

-- Layouts
local function addLayout(parent, padding)
    local layout = Instance.new("UIListLayout", parent)
    layout.Padding = UDim.new(0, padding)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
end
addLayout(infoContainer, 8)
addLayout(rollContainer, 12)
addLayout(lairContainer, 12)
addLayout(skillContainer, 10)

-- === NỘI DUNG TRANG INFO ===
local function addInfoText(txt, color, font, size)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.9, 0, 0, 25)
    label.Text = txt
    label.TextColor3 = color or Color3.new(1, 1, 1)
    label.Font = font or Enum.Font.GothamSemibold
    label.TextSize = size or 14
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = infoContainer
end

addInfoText("AegisVN SUR v1", Color3.fromRGB(0, 120, 255), Enum.Font.GothamBold, 18)
addInfoText("Welcome " .. player.Name, Color3.fromRGB(200, 200, 200))
addInfoText("Made in VietNam 🇻🇳", Color3.fromRGB(255, 50, 50))
addInfoText("-------------------------------------------", Color3.fromRGB(80, 80, 80))

addInfoText("⭐ KEEP STANDS", Color3.fromRGB(255, 200, 0), Enum.Font.GothamBold, 16)
addInfoText("  • DIO's The World", Color3.new(1, 1, 1))

addInfoText("✨ KEEP ATTRIBUTES", Color3.fromRGB(0, 255, 150), Enum.Font.GothamBold, 16)
for attr, _ in pairs(keepAttri) do
    addInfoText("  • " .. attr, Color3.new(1, 1, 1))
end

addInfoText("-------------------------------------------", Color3.fromRGB(80, 80, 80))
addInfoText("🛠️ MODULES DETAIL", Color3.fromRGB(0, 180, 90), Enum.Font.GothamBold, 16)
addInfoText("● Auto Roll: Automatic Arrows and Rokakaka", Color3.fromRGB(180, 180, 180))
addInfoText("● Auto Lair: Boss Kill & NPC Quest Farm.", Color3.fromRGB(180, 180, 180))
addInfoText("● Auto Skill: Hold E & Spam E,R,T,F,Z,X", Color3.fromRGB(180, 180, 180))
addInfoText("-------------------------------------------", Color3.fromRGB(80, 80, 80))
addInfoText("⌨️ HOTKEYS", Color3.fromRGB(255, 80, 80), Enum.Font.GothamBold, 16)
addInfoText("  • [ L ] : Toggle Menu Visibility", Color3.new(1, 1, 1))

-- === HÀM HỖ TRỢ MENU ===
local function showPage(page)
    infoContainer.Visible = false
    rollContainer.Visible = false
    lairContainer.Visible = false
    skillContainer.Visible = false
    page.Visible = true
end

local function createMenuBtn(txt, target)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 190, 0, 50)
    btn.Text = txt
    btn.TextSize = 18
    btn.Font = Enum.Font.GothamBold
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Parent = leftFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    btn.MouseButton1Click:Connect(function() showPage(target) end)
end

createMenuBtn("Info", infoContainer)
createMenuBtn("Auto Roll", rollContainer)
createMenuBtn("Auto Lair", lairContainer)
createMenuBtn("Auto Skill", skillContainer)

-- === HÀM TẠO TOGGLE ===
local function createToggle(parent, txt, globalVar)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(0.92, 0, 0, 60)
    holder.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    holder.Parent = parent
    Instance.new("UICorner", holder).CornerRadius = UDim.new(0, 10)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.Position = UDim2.new(0, 15, 0, 0)
    label.Text = txt
    label.TextSize = 18
    label.Font = Enum.Font.GothamBold
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.Parent = holder
    
    local switchBg = Instance.new("Frame")
    switchBg.Size = UDim2.new(0, 60, 0, 30)
    switchBg.Position = UDim2.new(1, -75, 0.5, -15)
    switchBg.BackgroundColor3 = _G[globalVar] and Color3.fromRGB(0, 180, 90) or Color3.fromRGB(60, 60, 60)
    switchBg.Parent = holder
    Instance.new("UICorner", switchBg).CornerRadius = UDim.new(1, 0)
    
    local switchCircle = Instance.new("Frame")
    switchCircle.Size = UDim2.new(0, 24, 0, 24)
    switchCircle.Position = _G[globalVar] and UDim2.new(1, -27, 0.5, -12) or UDim2.new(0, 3, 0.5, -12)
    switchCircle.BackgroundColor3 = Color3.new(1, 1, 1)
    switchCircle.Parent = switchBg
    Instance.new("UICorner", switchCircle).CornerRadius = UDim.new(1, 0)

    local clickBtn = Instance.new("TextButton")
    clickBtn.Size = UDim2.new(1, 0, 1, 0)
    clickBtn.BackgroundTransparency = 1
    clickBtn.Text = ""
    clickBtn.ZIndex = 10 -- Đảm bảo nằm trên cùng để nhận click
    clickBtn.Active = true
    clickBtn.Parent = holder
    
    -- Cập nhật UI liên tục nếu biến bị thay đổi từ bên ngoài (Logic tự tắt)
    task.spawn(function()
        while task.wait(0.5) do
            if not holder or not holder.Parent then break end
            local isOn = _G[globalVar]
            local targetColor = isOn and Color3.fromRGB(0, 180, 90) or Color3.fromRGB(60, 60, 60)
            local targetPos = isOn and UDim2.new(1, -27, 0.5, -12) or UDim2.new(0, 3, 0.5, -12)
            
            if switchBg.BackgroundColor3 ~= targetColor then
                TweenService:Create(switchBg, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
                TweenService:Create(switchCircle, TweenInfo.new(0.2), {Position = targetPos}):Play()
            end
        end
    end)

    clickBtn.MouseButton1Click:Connect(function()
        _G[globalVar] = not _G[globalVar]
    end)
    
    return holder
end

-- === THIẾT LẬP CÁC TRANG CÒN LẠI ===
createToggle(rollContainer, "AUTO ROLL", "AutoRoll")

local arrowFrame = Instance.new("Frame")
arrowFrame.Size = UDim2.new(0.92, 0, 0, 80)
arrowFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
arrowFrame.Parent = rollContainer
Instance.new("UICorner", arrowFrame).CornerRadius = UDim.new(0, 10)

local arrowButtons = {} 

local function createArrowBtn(name, xPos)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.45, 0, 0, 40)
    btn.Position = UDim2.new(xPos, 0, 0.25, 0)
    btn.Text = name:upper()
    btn.TextSize = 16 
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.Parent = arrowFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    
    table.insert(arrowButtons, btn) 
    
    if arrowName == name then
        btn.BackgroundColor3 = Color3.fromRGB(0, 120, 255) 
    end

    btn.MouseButton1Click:Connect(function() 
        for _, otherBtn in pairs(arrowButtons) do
            otherBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        end
        arrowName = name 
        btn.BackgroundColor3 = Color3.fromRGB(0, 120, 255) 
    end)
end
createArrowBtn("Charged Arrow", 0.03)
createArrowBtn("Stand Arrow", 0.52)

createToggle(lairContainer, "AUTO FARM", "MainFarm")
local lairButtons = {}

local function npcSelect(name, id)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.92, 0, 0, 50)
    btn.Text = name:upper()
    btn.TextSize = 16 
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.Parent = lairContainer
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    
    table.insert(lairButtons, btn)
    
    if SelectedNPCData.Name == id then
        btn.BackgroundColor3 = Color3.fromRGB(0, 120, 255) 
    end

    btn.MouseButton1Click:Connect(function() 
        for _, otherBtn in pairs(lairButtons) do
            otherBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        end
        SelectedNPCData.Name = id 
        btn.BackgroundColor3 = Color3.fromRGB(0, 120, 255) 
    end)
end
npcSelect("Apex LVL 500", "Apex_Lvl500")
npcSelect("Istabman Lvl 200", "i_stabman")

createToggle(skillContainer, "SKILL E (HOLD)", "AutoSkillE")
createToggle(skillContainer, "SKILL R", "AutoSkillR")
createToggle(skillContainer, "SKILL T", "AutoSkillT")
createToggle(skillContainer, "SKILL F", "AutoSkillF")
createToggle(skillContainer, "SKILL Z", "AutoSkillZ")
createToggle(skillContainer, "SKILL X", "AutoSkillX")

-- ====================== LOGIC HỆ THỐNG ======================

local function FlyTo(targetCF)
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local dist = (hrp.Position - targetCF.Position).Magnitude
    if dist < 4 then if currentTween then currentTween:Cancel() end hrp.CFrame = targetCF return end
    if currentTween then currentTween:Cancel() end
    currentTween = TweenService:Create(hrp, TweenInfo.new(dist/flySpeed, Enum.EasingStyle.Linear), {CFrame = targetCF})
    currentTween:Play()
end

-- 1. Auto Roll Stand
task.spawn(function()
    while task.wait(0.7) do
        if _G.AutoRoll then
            pcall(function()
                local data = player:FindFirstChild("Data")
                local stand = data:FindFirstChild("Stand")
                local attr = data:FindFirstChild("Attri")
                if standData and (standData.Value == "DIO's The World" or (attriData and keepAttri[attriData.Value])) then
                    _G.AutoRoll = false return
                end
                local toolName = (not stand or stand.Value == "" or stand.Value == "None") and arrowName or "Rokakaka"
                local tool = player.Backpack:FindFirstChild(toolName) or player.Character:FindFirstChild(toolName)
                if tool then
                    player.Character.Humanoid:EquipTool(tool)
                    tool:Activate()
                    if toolName == "Rokakaka" then 
                        task.wait(0.4)
                        for _, v in pairs(playerGui:GetDescendants()) do 
                            if v:IsA("TextButton") and v.Visible and (v.Text:lower():find("yes") or v.Text:lower():find("accept")) then v:Activate() end 
                        end 
                    end
                end
            end)
        end
    end
end)

-- ====================== FUNCTION SUMMON STAND ======================
local function handleStandLogic(char)
    local aura = char:FindFirstChild("Aura")
    -- Nếu aura.Value == false nghĩa là Stand chưa lấy ra
    if aura and aura.Value == false then
        if char:FindFirstChild("StandEvents") and char.StandEvents:FindFirstChild("Summon") then
            char.StandEvents.Summon:FireServer()
            task.wait(0.5) -- Đợi một chút để Stand kịp xuất hiện
        end
    end
end

-- ====================== AUTO FARM LAIR + SUMMON ======================
task.spawn(function()
    local wasFightingBoss = false
    while task.wait(0.2) do 
        if _G.MainFarm then
            pcall(function()
                local char = player.Character
                if not char or not char:FindFirstChild("HumanoidRootPart") then return end
                local hrp = char.HumanoidRootPart
                
                -- GỌI STAND RA TRƯỚC KHI LÀM BẤT CỨ VIỆC GÌ
                handleStandLogic(char)

                -- 1. TÌM BOSS
                local myBoss = nil
                local living = workspace:FindFirstChild("Living")
                if living then
                    for _, v in pairs(living:GetChildren()) do
                        if v.Name == "Boss" and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
                            if v.Humanoid.Health > 0 and (hrp.Position - v.HumanoidRootPart.Position).Magnitude < 500 then
                                myBoss = v 
                                break
                            end
                        end
                    end
                end

                -- 2. ĐÁNH BOSS
                if myBoss then
                    wasFightingBoss = true
                    hrp.Velocity = Vector3.new(0,0,0)
                    
                    local bossTargetCF = myBoss.HumanoidRootPart.CFrame * CFrame.new(0, -8, 2.5) * CFrame.Angles(math.rad(90), 0, 0)
                    FlyTo(bossTargetCF)
                    
                    if char:FindFirstChild("StandEvents") and char.StandEvents:FindFirstChild("M1") then 
                        char.StandEvents.M1:FireServer() 
                    else 
                        VirtualUser:ClickButton1(Vector2.new(0,0)) 
                    end
                
                -- 3. DI CHUYỂN & TƯƠNG TÁC NPC
                else
                    if wasFightingBoss then 
                        wasFightingBoss = false 
                        task.wait(1.5) 
                        return 
                    end
                    
                    if SelectedNPCData.Name ~= "NONE" then
                        local p_main = SelectedNPCData.Name == "i_stabman" and POS_MAIN_STABMAN or POS_APEX
                        
                        if hrp.Position.X < 5000 then 
                            -- Ở Map chính
                            if (hrp.Position - p_main).Magnitude > 15 then
                                FlyTo(CFrame.new(p_main) * CFrame.new(0, 2, 0))
                            end
                        else
                            -- Ở trong Lair
                            local myNPC = nil
                            for _, v in pairs(workspace:GetDescendants()) do
                                if v:IsA("Model") and v.Name == SelectedNPCData.Name then
                                    if (hrp.Position - v:GetModelCFrame().Position).Magnitude < 500 then
                                        myNPC = v
                                        break
                                    end
                                end
                            end

                            if myNPC then
                                if (hrp.Position - myNPC:GetModelCFrame().Position).Magnitude > 10 then
                                    FlyTo(myNPC:GetModelCFrame() * CFrame.new(0, 2, 3))
                                end
                            else
                                -- Xong Lair -> Về map chính
                                if currentTween then currentTween:Cancel() end
                                hrp.CFrame = CFrame.new(p_main) * CFrame.new(0, 5, 0)
                                task.wait(1)
                            end
                        end

                        -- Kích hoạt NPC (Fix lỗi Interact)
                        for _, v in pairs(workspace:GetDescendants()) do
                            if v:IsA("Model") and v.Name == SelectedNPCData.Name and (hrp.Position - v:GetModelCFrame().Position).Magnitude < 30 then
                                local r = v:FindFirstChild("Done") or v:FindFirstChild("Click") or v:FindFirstChildOfClass("RemoteEvent")
                                if r then r:FireServer() end
                            end
                        end

                        -- Auto nhấn Yes/Accept
                        for _, v in pairs(playerGui:GetDescendants()) do
                            if v:IsA("TextButton") and v.Visible then
                                local t = v.Text:lower()
                                if t:find("yes") or t:find("accept") or t:find("ok") then
                                    v:Activate()
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)
-- Hàm hỗ trợ click GUI chính xác hơn
function GuiClick(btn)
    pcall(function()
        local pos = btn.AbsolutePosition
        local size = btn.AbsoluteSize
        VirtualInputManager:SendMouseButtonEvent(pos.X + size.X/2, pos.Y + size.Y/2 + 50, 0, true, game, 1)
        VirtualInputManager:SendMouseButtonEvent(pos.X + size.X/2, pos.Y + size.Y/2 + 50, 0, false, game, 1)
    end)
end

-- ====================== LOGIC AUTO SKILL (FIX GIỮ E) ======================
local VirtualInputManager = game:GetService("VirtualInputManager")
local isHoldingE = false

task.spawn(function()
    while true do
        task.wait(0.1) -- Tốc độ quét trạng thái
        pcall(function()
            -- 1. XỬ LÝ GIỮ PHÍM E (Dành cho chiêu vận công/gồng)
            if _G.AutoSkillE then 
                if not isHoldingE then
                    -- Chỉ gửi tín hiệu nhấn xuống 1 lần duy nhất khi bật toggle
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                    isHoldingE = true
                end
                -- Ghi chú: Một số game yêu cầu gửi lại tín hiệu "giữ" định kỳ
                -- Nếu game của bạn bị nhả E sau vài giây, hãy bỏ comment dòng dưới:
                -- VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
            else
                if isHoldingE then
                    -- Gửi tín hiệu nhả phím khi tắt toggle
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                    isHoldingE = false
                end
            end

            -- 2. XỬ LÝ SPAM CÁC PHÍM KHÁC (R, T, F, Z, X)
            -- Lưu ý: Các chiêu này sẽ được nhấn khi E đang được giữ
            local skills = {
                {toggle = _G.AutoSkillR, key = Enum.KeyCode.R},
                {toggle = _G.AutoSkillT, key = Enum.KeyCode.T},
                {toggle = _G.AutoSkillF, key = Enum.KeyCode.F},
                {toggle = _G.AutoSkillZ, key = Enum.KeyCode.Z},
                {toggle = _G.AutoSkillX, key = Enum.KeyCode.X},
            }

            for _, skill in ipairs(skills) do
                if skill.toggle then
                    VirtualInputManager:SendKeyEvent(true, skill.key, false, game)
                    task.wait(0.02) -- Nhấn cực nhanh
                    VirtualInputManager:SendKeyEvent(false, skill.key, false, game)
                end
            end
        end)
    end
end)

-- 4. Hệ thống (NoClip & Hotkey L)
RunService.Stepped:Connect(function()
    if (_G.MainFarm or _G.AutoRoll) and player.Character then
        for _, v in pairs(player.Character:GetChildren()) do 
            if v:IsA("BasePart") then 
                v.CanCollide = false 
            end 
        end
    end
end)

UserInputService.InputBegan:Connect(function(i, g)
    if not g and i.KeyCode == Enum.KeyCode.L then 
        mainFrame.Visible = not mainFrame.Visible 
    end
end)
