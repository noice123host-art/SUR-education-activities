local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

-- Dùng gethui() nếu executor hỗ trợ, nếu không thì xài CoreGui để chống game tự xóa UI
local ProtectGui = (gethui and gethui()) or CoreGui

-- Kiểm tra nếu đã có Menu thì xóa
if ProtectGui:FindFirstChild("RebootedMenu") then 
    ProtectGui.RebootedMenu:Destroy() 
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RebootedMenu"
screenGui.ResetOnSpawn = false 
screenGui.Parent = ProtectGui

-- Biến Global
_G.AutoRoll = _G.AutoRoll or false
_G.MainFarm = _G.MainFarm or false

local SelectedNPCData = { Name = "NONE" }
local arrowOptions = {"Charged Arrow", "Stand Arrow"}
local arrowName = arrowOptions[1]
local keepAttri = {["Scourge"] = true, ["Hacker"] = true, ["Legendary"] = true, ["Glass Cannon"] = true}
local flySpeed = 150 
local currentTween = nil
local POS_MAIN_STABMAN = Vector3.new(-40.3, 67.1, -468.7) 
local POS_APEX = Vector3.new(-312.9, 66.8, 144.7)

-- ====================== GIAO DIỆN ======================
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

-- === CONTAINERS CỦA TỪNG TRANG ===
local rollContainer = Instance.new("Frame")
rollContainer.Size = UDim2.new(1, 0, 1, 0)
rollContainer.BackgroundTransparency = 1
rollContainer.Parent = rightFrame
rollContainer.Visible = true

local lairContainer = Instance.new("Frame")
lairContainer.Size = UDim2.new(1, 0, 1, 0)
lairContainer.BackgroundTransparency = 1
lairContainer.Parent = rightFrame
lairContainer.Visible = false

local skillContainer = Instance.new("Frame")
skillContainer.Size = UDim2.new(1, 0, 1, 0)
skillContainer.BackgroundTransparency = 1
skillContainer.Parent = rightFrame
skillContainer.Visible = false

-- UIListLayout cho các container bên phải
local rollLayout = Instance.new("UIListLayout", rollContainer)
rollLayout.Padding = UDim.new(0, 12)
rollLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local lairLayout = Instance.new("UIListLayout", lairContainer)
lairLayout.Padding = UDim.new(0, 12)
lairLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local skillLayout = Instance.new("UIListLayout", skillContainer)
skillLayout.Padding = UDim.new(0, 8)
skillLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- === NÚT MENU BÊN TRÁI ===
local menuOrder = {[rollContainer] = 1, [lairContainer] = 2, [skillContainer] = 3}
local function createMenuBtn(txt, target)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 55)
    btn.Text = txt
    btn.TextSize = 20
    btn.Font = Enum.Font.GothamBold
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Parent = leftFrame
    btn.LayoutOrder = menuOrder[target] or 99
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    return btn
end

-- === HÀM TẠO NÚT TOGGLE ON/OFF ===
local function createToggle(parent, txt, globalVar)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(0.92, 0, 0, 60)
    holder.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    holder.Parent = parent
    Instance.new("UICorner", holder).CornerRadius = UDim.new(0, 10)
    
    -- Label bên trái
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
    
    -- Nút ON/OFF bên phải (kiểu switch)
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

    -- Click toàn bộ holder để toggle
    local clickBtn = Instance.new("TextButton")
    clickBtn.Size = UDim2.new(1, 0, 1, 0)
    clickBtn.BackgroundTransparency = 1
    clickBtn.Text = ""
    clickBtn.Parent = holder
    
    clickBtn.MouseButton1Click:Connect(function()
        _G[globalVar] = not _G[globalVar]
        local isOn = _G[globalVar]
        
        TweenService:Create(switchBg, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            BackgroundColor3 = isOn and Color3.fromRGB(0, 180, 90) or Color3.fromRGB(60, 60, 60)
        }):Play()
        TweenService:Create(switchCircle, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            Position = isOn and UDim2.new(1, -27, 0.5, -12) or UDim2.new(0, 3, 0.5, -12)
        }):Play()
    end)
    
    return holder
end

-- === HÀM CHUYỂN TRANG ===
local function showPage(page)
    rollContainer.Visible = false
    lairContainer.Visible = false
    skillContainer.Visible = false
    page.Visible = true
end

-- === TẠO MENU ===
local rollBtn = createMenuBtn("ROLL STAND", rollContainer)
local lairBtn = createMenuBtn("AUTO LAIR", lairContainer)
local skillBtn = createMenuBtn("AUTO SKILL", skillContainer)
rollBtn.MouseButton1Click:Connect(function() showPage(rollContainer) end)
lairBtn.MouseButton1Click:Connect(function() showPage(lairContainer) end)
skillBtn.MouseButton1Click:Connect(function() showPage(skillContainer) end)

-- === TOGGLE + CHỌN ARROW BÊN PHẢI (trong rollContainer) ===
createToggle(rollContainer, "AUTO ROLL", "AutoRoll")

-- Chọn Arrow Type (bên phải, trong rollContainer)
local arrowSelectorFrame = Instance.new("Frame")
arrowSelectorFrame.Size = UDim2.new(0.92, 0, 0, 90)
arrowSelectorFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
arrowSelectorFrame.Parent = rollContainer
Instance.new("UICorner", arrowSelectorFrame).CornerRadius = UDim.new(0, 10)

local arrowTitle = Instance.new("TextLabel")
arrowTitle.Size = UDim2.new(1, 0, 0, 25)
arrowTitle.Position = UDim2.new(0, 0, 0, 4)
arrowTitle.Text = "ARROW TYPE"
arrowTitle.TextSize = 14
arrowTitle.Font = Enum.Font.GothamBold
arrowTitle.TextColor3 = Color3.fromRGB(180, 180, 180)
arrowTitle.BackgroundTransparency = 1
arrowTitle.Parent = arrowSelectorFrame

local arrowBtnHolder = Instance.new("Frame")
arrowBtnHolder.Size = UDim2.new(1, -16, 0, 50)
arrowBtnHolder.Position = UDim2.new(0, 8, 0, 32)
arrowBtnHolder.BackgroundTransparency = 1
arrowBtnHolder.Parent = arrowSelectorFrame

local arrowBtnLayout = Instance.new("UIListLayout", arrowBtnHolder)
arrowBtnLayout.FillDirection = Enum.FillDirection.Horizontal
arrowBtnLayout.Padding = UDim.new(0, 8)
arrowBtnLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local arrowButtons = {}

local function updateArrowButtons()
    for _, info in pairs(arrowButtons) do
        if info.name == arrowName then
            info.btn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
            info.btn.TextColor3 = Color3.new(1, 1, 1)
        else
            info.btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            info.btn.TextColor3 = Color3.fromRGB(160, 160, 160)
        end
    end
end

for i, name in ipairs(arrowOptions) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.48, 0, 1, 0)
    btn.Text = (name == "Charged Arrow") and "CHARGED" or "STAND"
    btn.TextSize = 15
    btn.Font = Enum.Font.GothamBold
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    btn.Parent = arrowBtnHolder
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    
    table.insert(arrowButtons, {btn = btn, name = name})
    
    btn.MouseButton1Click:Connect(function()
        arrowName = name
        updateArrowButtons()
    end)
end

updateArrowButtons()

-- === TOGGLE BÊN PHẢI (trong lairContainer) ===
createToggle(lairContainer, "AUTO LAIR", "MainFarm")

-- === AUTO SKILL PAGE (bên phải) ===
_G.AutoSkillE = _G.AutoSkillE or false
_G.AutoSkillR = _G.AutoSkillR or false
_G.AutoSkillT = _G.AutoSkillT or false
_G.AutoSkillF = _G.AutoSkillF or false
_G.AutoSkillZ = _G.AutoSkillZ or false
_G.AutoSkillX = _G.AutoSkillX or false

createToggle(skillContainer, "SKILL E", "AutoSkillE")
createToggle(skillContainer, "SKILL R", "AutoSkillR")
createToggle(skillContainer, "SKILL T", "AutoSkillT")
createToggle(skillContainer, "SKILL F", "AutoSkillF")
createToggle(skillContainer, "SKILL Z", "AutoSkillZ")
createToggle(skillContainer, "SKILL X", "AutoSkillX")

-- ====================== LOGIC BAY (FLY) ======================
local function FlyTo(targetCF)
    local char = player.Character
    if not char then return end 
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then return end
    
    local dist = (hrp.Position - targetCF.Position).Magnitude
    if dist < 3 then 
        if currentTween then currentTween:Cancel() end 
        hrp.CFrame = targetCF 
        return 
    end
    
    if currentTween then currentTween:Cancel() end
    currentTween = TweenService:Create(hrp, TweenInfo.new(dist/flySpeed, Enum.EasingStyle.Linear), {CFrame = targetCF})
    currentTween:Play()
end

-- ====================== VÒNG LẶP AUTO ROLL ======================
task.spawn(function()
    while task.wait(0.6) do
        if _G.AutoRoll then
            pcall(function()
                local char = player.Character
                if not char then return end
                local hum = char:FindFirstChild("Humanoid")
                if not hum or hum.Health <= 0 then return end
                
                local data = player:FindFirstChild("Data")
                if not data then return end
                
                local standData = data:FindFirstChild("Stand")
                local attriData = data:FindFirstChild("Attri")
                
                if standData and (standData.Value == "DIO's The World" or (attriData and keepAttri[attriData.Value])) then 
                    _G.AutoRoll = false 
                    return 
                end
                
                local toolName = (not standData or standData.Value == "" or standData.Value == "None") and arrowName or "Rokakaka"
                local tool = player.Backpack:FindFirstChild(toolName) or char:FindFirstChild(toolName)
                
                if tool and hum then
                    hum:EquipTool(tool)
                    tool:Activate()
                    if toolName == "Rokakaka" then 
                        task.wait(0.4)
                        for _, v in pairs(playerGui:GetDescendants()) do 
                            if v:IsA("TextButton") and v.Visible and (v.Text:lower():find("yes") or v.Text:lower():find("accept")) then 
                                v:Activate() 
                            end 
                        end 
                    end
                end
            end)
        end
    end
end)

-- ====================== SUMMON STAND ======================
local function handleStandLogic(char)
    local aura = char:FindFirstChild("Aura")
    if aura and aura.Value == false then
        if char:FindFirstChild("StandEvents") and char.StandEvents:FindFirstChild("Summon") then
            char.StandEvents.Summon:FireServer()
        end
    end
end

-- ====================== VÒNG LẶP AUTO LAIR ======================
-- Hàm tìm NPC nhanh (không dùng GetDescendants)
local function findNPCModel(npcName, hrp)
    -- Thử tìm trực tiếp trong workspace
    local npc = workspace:FindFirstChild(npcName)
    if npc and npc:IsA("Model") then
        local npcPos = npc:FindFirstChild("HumanoidRootPart")
        if npcPos and (hrp.Position - npcPos.Position).Magnitude < 35 then
            return npc
        end
    end
    -- Thử tìm trong các folder phổ biến
    for _, folderName in ipairs({"NPCs", "NPC", "Living", "Map"}) do
        local folder = workspace:FindFirstChild(folderName)
        if folder then
            local found = folder:FindFirstChild(npcName)
            if found and found:IsA("Model") then
                local fPos = found:FindFirstChild("HumanoidRootPart")
                if fPos and (hrp.Position - fPos.Position).Magnitude < 35 then
                    return found
                end
            end
            -- Tìm sâu 1 cấp nữa
            for _, child in pairs(folder:GetChildren()) do
                if child:IsA("Model") and child.Name == npcName then
                    local cPos = child:FindFirstChild("HumanoidRootPart")
                    if cPos and (hrp.Position - cPos.Position).Magnitude < 35 then
                        return child
                    end
                end
            end
        end
    end
    return nil
end

task.spawn(function()
    local wasFightingBoss = false
    while task.wait(0.35) do
        if _G.MainFarm then
            pcall(function()
                local char = player.Character
                if not char then return end
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local hum = char:FindFirstChild("Humanoid")
                if not hrp or not hum or hum.Health <= 0 then return end

                -- Summon stand nếu chưa có
                handleStandLogic(char)

                local myBoss = nil
                local livingFolder = workspace:FindFirstChild("Living")
                if livingFolder then
                    for _, v in pairs(livingFolder:GetChildren()) do
                        if v.Name == "Boss" and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") then
                            if v.Humanoid.Health > 0 and (hrp.Position - v.HumanoidRootPart.Position).Magnitude < 600 then
                                myBoss = v break
                            end
                        end
                    end
                end

                if myBoss then
                    wasFightingBoss = true
                    hrp.Velocity = Vector3.new(0,0,0)
                    FlyTo(myBoss.HumanoidRootPart.CFrame * CFrame.new(0, -8, 2.5) * CFrame.Angles(math.rad(90), 0, 0))
                    
                    if char:FindFirstChild("StandEvents") then
                        char.StandEvents.M1:FireServer()
                    else
                        VirtualUser:ClickButton1(Vector2.new(0, 0))
                    end
                else
                    if wasFightingBoss then 
                        wasFightingBoss = false
                        task.wait(2) 
                        return 
                    end
                    
                    if SelectedNPCData.Name ~= "NONE" then
                        local p = SelectedNPCData.Name == "i_stabman" and POS_MAIN_STABMAN or POS_APEX
                        if (hrp.Position - p).Magnitude > 20 then 
                            FlyTo(CFrame.new(p) * CFrame.new(0,5,0)) 
                        end
                        -- Tìm NPC nhanh (không dùng GetDescendants)
                        local npc = findNPCModel(SelectedNPCData.Name, hrp)
                        if npc then
                            local r = npc:FindFirstChild("Done") or npc:FindFirstChild("Click") or npc:FindFirstChildOfClass("RemoteEvent")
                            if r then r:FireServer() end
                        end
                        -- Bấm nút accept
                        for _, g in pairs(playerGui:GetDescendants()) do
                            if g:IsA("TextButton") and g.Visible and (g.Text:lower():find("yes") or g.Text:lower():find("accept")) then 
                                g:Activate() 
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- === NÚT CHỌN NPC (trong trang AUTO LAIR) ===
local function npcSelect(name, id)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.92, 0, 0, 50)
    btn.Text = name:upper()
    btn.TextSize = 16
    btn.Font = Enum.Font.GothamBold
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.TextColor3 = Color3.fromRGB(180, 180, 180)
    btn.Parent = lairContainer
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    
    btn.MouseButton1Click:Connect(function()
        for _, v in pairs(lairContainer:GetChildren()) do 
            if v:IsA("TextButton") then 
                v.BackgroundColor3 = Color3.fromRGB(40, 40, 40) 
                v.TextColor3 = Color3.fromRGB(180, 180, 180)
            end 
        end
        btn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
        btn.TextColor3 = Color3.new(1, 1, 1)
        SelectedNPCData.Name = id
    end)
end

npcSelect("Apex LVL 500", "Apex_Lvl500")
npcSelect("Istabman Lvl 200", "i_stabman")

-- Chống va chạm (throttled - mỗi 3 frame 1 lần thay vì mỗi frame)
local noClipTick = 0
RunService.Stepped:Connect(function()
    noClipTick = noClipTick + 1
    if noClipTick < 3 then return end
    noClipTick = 0
    if (_G.MainFarm or _G.AutoRoll) and player.Character then
        for _, v in pairs(player.Character:GetChildren()) do 
            if v:IsA("BasePart") then v.CanCollide = false end 
        end
    end
end)

UserInputService.InputBegan:Connect(function(i, g)
    if not g and i.KeyCode == Enum.KeyCode.L then 
        mainFrame.Visible = not mainFrame.Visible 
    end
end)

-- ====================== VÒNG LẶP AUTO SKILL ======================
local RS = game:GetService("ReplicatedStorage")
local Remotes = RS:FindFirstChild("Remotes")
if not Remotes then
    local t = tick()
    repeat task.wait(0.1); Remotes = RS:FindFirstChild("Remotes") until Remotes or (tick() - t > 3)
end

local hasRemotes = Remotes and Remotes:FindFirstChild("Input") and Remotes:FindFirstChild("InputFunc")
local VIM = game:GetService("VirtualInputManager")

local keyCodeMap = {
    E = Enum.KeyCode.E, R = Enum.KeyCode.R, T = Enum.KeyCode.T,
    F = Enum.KeyCode.F, Z = Enum.KeyCode.Z, X = Enum.KeyCode.X,
}

local function useSkill(key)
    pcall(function()
        if hasRemotes then
            Remotes.Input:FireServer("KEY", key)
            task.wait()
            Remotes.InputFunc:InvokeServer(key)
            task.wait()
            Remotes.Input:FireServer("KEY", "END-" .. key)
            task.wait()
            Remotes.InputFunc:InvokeServer("END-" .. key)
        else
            local kc = keyCodeMap[key]
            if kc then
                VIM:SendKeyEvent(true, kc, false, game)
                task.wait(0.05)
                VIM:SendKeyEvent(false, kc, false, game)
            end
        end
    end)
end

local function holdSkill(key)
    pcall(function()
        if hasRemotes then
            Remotes.Input:FireServer("KEY", key)
            task.wait()
            Remotes.InputFunc:InvokeServer(key)
        else
            local kc = keyCodeMap[key]
            if kc then
                VIM:SendKeyEvent(true, kc, false, game)
            end
        end
    end)
end

local function releaseSkill(key)
    pcall(function()
        if hasRemotes then
            Remotes.Input:FireServer("KEY", "END-" .. key)
            task.wait()
            Remotes.InputFunc:InvokeServer("END-" .. key)
        else
            local kc = keyCodeMap[key]
            if kc then
                VIM:SendKeyEvent(false, kc, false, game)
            end
        end
    end)
end

-- Skill E: giữ liên tục
local eHolding = false
task.spawn(function()
    while task.wait(0.3) do
        local char = player.Character
        local alive = char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0
        
        if _G.AutoSkillE and alive then
            if not eHolding then
                holdSkill("E")
                eHolding = true
            end
        else
            if eHolding then
                releaseSkill("E")
                eHolding = false
            end
        end
    end
end)

-- Các skill khác: bấm rồi nhả
local tapSkills = {
    {key = "R", var = "AutoSkillR"},
    {key = "T", var = "AutoSkillT"},
    {key = "F", var = "AutoSkillF"},
    {key = "Z", var = "AutoSkillZ"},
    {key = "X", var = "AutoSkillX"},
}

task.spawn(function()
    while task.wait(0.5) do
        local char = player.Character
        if not char then continue end
        local hum = char:FindFirstChild("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        
        for _, skill in ipairs(tapSkills) do
            if _G[skill.var] then
                useSkill(skill.key)
                task.wait(0.3)
            end
        end
    end
end)
