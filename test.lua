local player = game.Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- [QUAN TRỌNG] XÁC ĐỊNH VÙNG AN TOÀN ĐỂ UI KHÔNG BỊ XÓA KHI CHẾT
local uiTarget = pcall(gethui) and gethui() or game:GetService("CoreGui")

-- Xóa Menu cũ nếu đang chạy lại script
if uiTarget:FindFirstChild("RebootedMenu") then uiTarget.RebootedMenu:Destroy() end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RebootedMenu"
screenGui.ResetOnSpawn = false
screenGui.Parent = uiTarget -- Đã chuyển sang vùng an toàn

-- ====================== Biến ======================
local SelectedNPCData = { Name = "NONE", CFrame = nil }
local arrowOptions = {"Charged Arrow", "Stand Arrow"}
local arrowName = arrowOptions[1]
local keepAttri = {["Scourge"] = true, ["Hacker"] = true, ["Legendary"] = true, ["Glass Cannon"] = true}

local flySpeed = 150 
local currentTween = nil
local lastTargetPos = nil

local POS_MAIN_STABMAN = Vector3.new(-40.3, 67.1, -468.7) 
local POS_APEX = Vector3.new(-312.9, 66.8, 144.7)

-- ====================== HÀM KIỂM TRA NHÂN VẬT CÒN SỐNG ======================
local function GetAliveCharacter()
    local char = player.Character
    if not char or not char:FindFirstChild("Humanoid") or char.Humanoid.Health <= 0 then
        char = player.CharacterAdded:Wait()
        char:WaitForChild("HumanoidRootPart", 5)
        task.wait(0.5) 
    end
    return char
end

-- ====================== THIẾT KẾ UI MỚI CỦA BẠN ======================
local mainFrame = Instance.new("Frame")
mainFrame.Parent = screenGui
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
mainFrame.Size = UDim2.new(0, 800, 0, 550)
mainFrame.Position = UDim2.new(0.5, -400, 0.5, -275)
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)

-- KHUNG TRÁI (SETTINGS)
local leftFrame = Instance.new("Frame")
leftFrame.Parent = mainFrame
leftFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
leftFrame.Size = UDim2.new(0, 360, 1, -20)
leftFrame.Position = UDim2.new(0, 10, 0, 10)
Instance.new("UICorner", leftFrame).CornerRadius = UDim.new(0, 8)

local settingsScroll = Instance.new("ScrollingFrame")
settingsScroll.Parent = leftFrame
settingsScroll.Size = UDim2.new(1, -20, 1, -20)
settingsScroll.Position = UDim2.new(0, 10, 0, 10)
settingsScroll.BackgroundTransparency = 1
settingsScroll.ScrollBarThickness = 4
local leftLayout = Instance.new("UIListLayout", settingsScroll); leftLayout.Padding = UDim.new(0, 10)

-- KHUNG PHẢI (SELECTION)
local rightFrame = Instance.new("Frame")
rightFrame.Parent = mainFrame
rightFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
rightFrame.Size = UDim2.new(1, -390, 1, -20)
rightFrame.Position = UDim2.new(0, 380, 0, 10)
Instance.new("UICorner", rightFrame).CornerRadius = UDim.new(0, 12)

local statusHeader = Instance.new("Frame")
statusHeader.Size = UDim2.new(1, -20, 0, 80); statusHeader.Position = UDim2.new(0, 10, 0, 10)
statusHeader.BackgroundColor3 = Color3.fromRGB(35, 35, 35); statusHeader.Parent = rightFrame
Instance.new("UICorner", statusHeader).CornerRadius = UDim.new(0, 8)

local statusText = Instance.new("TextLabel")
statusText.Parent = statusHeader; statusText.Size = UDim2.new(1, 0, 1, 0); statusText.BackgroundTransparency = 1
statusText.Text = "📡 TRẠNG THÁI:\n<font color='#FF5555'>CHƯA CHỌN MỤC TIÊU</font>"; statusText.RichText = true
statusText.TextColor3 = Color3.fromRGB(255, 255, 255); statusText.Font = Enum.Font.GothamBold; statusText.TextSize = 18

local npcListScroll = Instance.new("ScrollingFrame")
npcListScroll.Parent = rightFrame; npcListScroll.Size = UDim2.new(1, -20, 1, -110); npcListScroll.Position = UDim2.new(0, 10, 0, 100)
npcListScroll.BackgroundTransparency = 1; npcListScroll.ScrollBarThickness = 2
local npcLayout = Instance.new("UIListLayout", npcListScroll); npcLayout.Padding = UDim.new(0, 8)

-- ====================== UI COMPONENTS ======================
local function createToggle(text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 60); btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    btn.Text = "  " .. text; btn.TextColor3 = Color3.fromRGB(255, 255, 255); btn.TextXAlignment = 0
    btn.Font = Enum.Font.GothamBold; btn.TextSize = 16; btn.Parent = settingsScroll
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    
    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 40, 0, 20); indicator.Position = UDim2.new(1, -50, 0.5, -10)
    indicator.BackgroundColor3 = Color3.fromRGB(80, 80, 80); indicator.Parent = btn
    Instance.new("UICorner", indicator).CornerRadius = UDim.new(1, 0)

    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        indicator.BackgroundColor3 = state and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(80, 80, 80)
        callback(state)
    end)
end

local function createNPCSelection(displayName, internalName, desc)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -5, 0, 70); btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.Text = ""; btn.Parent = npcListScroll; Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

    local nl = Instance.new("TextLabel")
    nl.Size = UDim2.new(1, -20, 0, 30); nl.Position = UDim2.new(0, 15, 0, 10)
    nl.Text = displayName; nl.TextColor3 = Color3.fromRGB(255,255,255); nl.Font = "GothamBold"; nl.TextSize = 17
    nl.BackgroundTransparency = 1; nl.TextXAlignment = 0; nl.Parent = btn

    local dl = Instance.new("TextLabel")
    dl.Size = UDim2.new(1, -20, 0, 20); dl.Position = UDim2.new(0, 15, 0, 35)
    dl.Text = desc; dl.TextColor3 = Color3.fromRGB(180,180,180); dl.Font = "Gotham"; dl.TextSize = 13
    dl.BackgroundTransparency = 1; dl.TextXAlignment = 0; dl.Parent = btn

    btn.MouseButton1Click:Connect(function()
        for _, v in pairs(npcListScroll:GetChildren()) do if v:IsA("TextButton") then v.BackgroundColor3 = Color3.fromRGB(40, 40, 40) end end
        btn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
        SelectedNPCData.Name = internalName
        statusText.Text = "LAIR:\n<font color='#00FF96'>" .. displayName:upper() .. "</font>"
    end)
end

-- ====================== LOGIC BAY (FLY) ======================
local function FlyTo(targetCFrame)
    local char = GetAliveCharacter()
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if lastTargetPos and (lastTargetPos - targetCFrame.Position).Magnitude < 5 then
        if currentTween and currentTween.PlaybackState == Enum.PlaybackState.Playing then return end
    end

    local distance = (hrp.Position - targetCFrame.Position).Magnitude
    if distance < 3 then 
        if currentTween then currentTween:Cancel() end
        hrp.CFrame = targetCFrame; return 
    end

    if currentTween then currentTween:Cancel() end
    currentTween = TweenService:Create(hrp, TweenInfo.new(distance / flySpeed, Enum.EasingStyle.Linear), {CFrame = targetCFrame})
    currentTween:Play()
    lastTargetPos = targetCFrame.Position
end

-- ====================== LOGIC ROLL & FARM ======================
local arrowBtn = Instance.new("TextButton")
arrowBtn.Size = UDim2.new(1, 0, 0, 50); arrowBtn.BackgroundColor3 = Color3.fromRGB(70, 30, 120)
arrowBtn.Text = "USING: " .. arrowName:upper(); arrowBtn.TextColor3 = Color3.fromRGB(255,255,255)
arrowBtn.Font = "GothamBold"; arrowBtn.Parent = settingsScroll; Instance.new("UICorner", arrowBtn)
arrowBtn.MouseButton1Click:Connect(function()
    arrowName = (arrowName == arrowOptions[1]) and arrowOptions[2] or arrowOptions[1]
    arrowBtn.Text = "USING: " .. arrowName:upper()
end)

createToggle("AUTO ROLL STAND", function(state)
    _G.AutoRoll = state
    task.spawn(function()
        while _G.AutoRoll do
            pcall(function()
                local data = player:FindFirstChild("Data")
                if data.Stand.Value == "DIO's The World" or keepAttri[data.Attri.Value] then _G.AutoRoll = false return end
                
                local char = GetAliveCharacter()
                local toolName = (data.Stand.Value == "" or data.Stand.Value == "None") and arrowName or "Rokakaka"
                local tool = player.Backpack:FindFirstChild(toolName) or char:FindFirstChild(toolName)
                if tool then
                    char.Humanoid:EquipTool(tool)
                    tool:Activate()
                    if toolName == "Rokakaka" then
                        task.wait(0.3)
                        for _, v in pairs(player.PlayerGui:GetDescendants()) do
                            if v:IsA("TextButton") and v.Text:lower() == "yes" and v.Visible then v:Activate() end
                        end
                    end
                end
            end)
            task.wait(0.5)
        end
    end)
end)

createToggle("AUTO FARM LAIR", function(state)
    _G.MainFarm = state
    local wasFightingBoss = false
    task.spawn(function()
        while _G.MainFarm do
            pcall(function()
                local char = GetAliveCharacter()
                local hrp = char.HumanoidRootPart
                local myBoss = nil
                local living = workspace:FindFirstChild("Living")
                if living then
                    for _, v in pairs(living:GetChildren()) do
                        if v.Name == "Boss" and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                            if (hrp.Position - v.HumanoidRootPart.Position).Magnitude < 500 then myBoss = v break end
                        end
                    end
                end

                if myBoss then
                    wasFightingBoss = true
                    FlyTo(myBoss.HumanoidRootPart.CFrame * CFrame.new(0, -8, 2.5) * CFrame.Angles(math.rad(90), 0, 0))
                    if char:FindFirstChild("StandEvents") then char.StandEvents.M1:FireServer() else VirtualUser:ClickButton1(Vector2.new(0,0)) end
                else
                    if wasFightingBoss then wasFightingBoss = false; task.wait(1.5); return end
                    if SelectedNPCData.Name ~= "NONE" then
                        -- Tương tác NPC & Teleport (Logic cũ của bạn giữ nguyên)
                        local targetPos = SelectedNPCData.Name == "i_stabman" and POS_MAIN_STABMAN or POS_APEX
                        if hrp.Position.X < 5000 and (hrp.Position - targetPos).Magnitude > 20 then FlyTo(CFrame.new(targetPos)) end
                        
                        -- Kích hoạt NPC
                        for _, v in pairs(workspace:GetDescendants()) do
                            if v:IsA("Model") and v.Name == SelectedNPCData.Name and (hrp.Position - v:GetPivot().Position).Magnitude < 30 then
                                local r = v:FindFirstChild("Done") or v:FindFirstChild("Click") or v:FindFirstChildOfClass("RemoteEvent")
                                if r then r:FireServer() end
                            end
                        end
                        -- Auto Click Yes
                        for _, g in pairs(player.PlayerGui:GetDescendants()) do
                            if g:IsA("TextButton") and g.Visible and (g.Text:lower():find("yes") or g.Text:lower():find("accept")) then g:Activate() end
                        end
                    end
                end
            end)
            task.wait(0.2)
        end
    end)
end)

-- NPC LIST
createNPCSelection("APEX LEVEL 500", "Apex_Lvl500", "Dio Diary, Anubis")
createNPCSelection("I_STABMAN (RAID)", "i_stabman", "Carrow")

-- NOCLIP & PHÍM TẮT L
RunService.Stepped:Connect(function()
    pcall(function()
        if _G.MainFarm and player.Character then
            for _, v in pairs(player.Character:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end
        end
    end)
end)

UserInputService.InputBegan:Connect(function(i, g)
    if not g and i.KeyCode == Enum.KeyCode.L then screenGui.Enabled = not screenGui.Enabled end
end)
