local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService") -- Thêm TweenService

-- Xóa Menu cũ
if playerGui:FindFirstChild("RebootedMenu") then playerGui.RebootedMenu:Destroy() end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RebootedMenu"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- ====================== Biến ======================
local SelectedNPCData = { Name = "NONE", CFrame = nil }
local arrowOptions = {"Charged Arrow", "Stand Arrow"}
local arrowName = arrowOptions[1]
local keepAttri = {["Scourge"] = true, ["Hacker"] = true, ["Legendary"] = true, ["Glass Cannon"] = true}

-- Tốc độ bay (Studs per second) - Bạn có thể tùy chỉnh ở đây
local flySpeed = 150 
local currentTween = nil
local lastTargetPos = nil

-- Tọa độ chuẩn
local POS_MAIN_STABMAN = Vector3.new(-40.3, 67.1, -468.7) 
local POS_LAIR_STABMAN = Vector3.new(28082.2, 47.4, -234.0)
local POS_APEX = Vector3.new(-312.9, 66.8, 144.7)

-- ====================== GIAO DIỆN CHÍNH ======================
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
local leftLayout = Instance.new("UIListLayout", settingsScroll)
leftLayout.Padding = UDim.new(0, 10)

-- KHUNG PHẢI (SELECTION)
local rightFrame = Instance.new("Frame")
rightFrame.Parent = mainFrame
rightFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
rightFrame.Size = UDim2.new(1, -390, 1, -20)
rightFrame.Position = UDim2.new(0, 380, 0, 10)
Instance.new("UICorner", rightFrame).CornerRadius = UDim.new(0, 12)

local statusHeader = Instance.new("Frame")
statusHeader.Size = UDim2.new(1, -20, 0, 80)
statusHeader.Position = UDim2.new(0, 10, 0, 10)
statusHeader.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
statusHeader.Parent = rightFrame
Instance.new("UICorner", statusHeader).CornerRadius = UDim.new(0, 8)

local statusText = Instance.new("TextLabel")
statusText.Parent = statusHeader
statusText.Size = UDim2.new(1, 0, 1, 0)
statusText.BackgroundTransparency = 1
statusText.Text = "📡 TRẠNG THÁI:\n<font color='#FF5555'>CHƯA CHỌN MỤC TIÊU</font>"
statusText.RichText = true
statusText.TextColor3 = Color3.fromRGB(255, 255, 255)
statusText.Font = Enum.Font.GothamBold
statusText.TextSize = 18

local npcListScroll = Instance.new("ScrollingFrame")
npcListScroll.Parent = rightFrame
npcListScroll.Size = UDim2.new(1, -20, 1, -110)
npcListScroll.Position = UDim2.new(0, 10, 0, 100)
npcListScroll.BackgroundTransparency = 1
npcListScroll.ScrollBarThickness = 2
local npcLayout = Instance.new("UIListLayout", npcListScroll)
npcLayout.Padding = UDim.new(0, 8)

-- ====================== UI COMPONENTS ======================
local function createToggle(text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 60)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    btn.Text = "  " .. text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 16
    btn.Parent = settingsScroll
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    
    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 40, 0, 20)
    indicator.Position = UDim2.new(1, -50, 0.5, -10)
    indicator.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    indicator.Parent = btn
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
    btn.Size = UDim2.new(1, -5, 0, 70)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.Text = ""
    btn.Parent = npcListScroll
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

    local nl = Instance.new("TextLabel")
    nl.Size = UDim2.new(1, -20, 0, 30); nl.Position = UDim2.new(0, 15, 0, 10)
    nl.Text = "" .. displayName; nl.TextColor3 = Color3.fromRGB(255,255,255)
    nl.Font = Enum.Font.GothamBold; nl.TextSize = 17; nl.BackgroundTransparency = 1; nl.TextXAlignment = 0; nl.Parent = btn

    local dl = Instance.new("TextLabel")
    dl.Size = UDim2.new(1, -20, 0, 20); dl.Position = UDim2.new(0, 15, 0, 35)
    dl.Text = desc; dl.TextColor3 = Color3.fromRGB(180,180,180)
    dl.Font = Enum.Font.Gotham; dl.TextSize = 13; dl.BackgroundTransparency = 1; dl.TextXAlignment = 0; dl.Parent = btn

    btn.MouseButton1Click:Connect(function()
        for _, v in pairs(npcListScroll:GetChildren()) do if v:IsA("TextButton") then v.BackgroundColor3 = Color3.fromRGB(40, 40, 40) end end
        btn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
        SelectedNPCData.Name = internalName
        SelectedNPCData.CFrame = true
        statusText.Text = "LAIR:\n<font color='#00FF96'>" .. displayName:upper() .. "</font>"
    end)
end

-- ====================== HÀM BAY MƯỢT (TWEEN) ======================
local function FlyTo(targetCFrame)
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart

    -- Kiểm tra nếu mục tiêu không thay đổi nhiều và đang bay thì không tạo Tween mới để tránh giật lag
    if lastTargetPos and (lastTargetPos - targetCFrame.Position).Magnitude < 5 then
        if currentTween and currentTween.PlaybackState == Enum.PlaybackState.Playing then
            return 
        end
    end

    local distance = (hrp.Position - targetCFrame.Position).Magnitude
    local travelTime = distance / flySpeed

    -- Nếu khoảng cách quá gần, dịch chuyển luôn để tiết kiệm tài nguyên
    if distance < 3 then
        if currentTween then currentTween:Cancel() end
        hrp.CFrame = targetCFrame
        return
    end

    if currentTween then currentTween:Cancel() end

    local tweenInfo = TweenInfo.new(travelTime, Enum.EasingStyle.Linear)
    currentTween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
    currentTween:Play()
    lastTargetPos = targetCFrame.Position
end

-- ====================== SUMMON STAND ======================
local function handleStandLogic(char)
    local aura = char:FindFirstChild("Aura")
    if aura and aura.Value == false then
        if char:FindFirstChild("StandEvents") and char.StandEvents:FindFirstChild("Summon") then
            char.StandEvents.Summon:FireServer()
        end
    end
end

-- ====================== AUTO ROLL STAND ======================
local arrowBtn = Instance.new("TextButton")
arrowBtn.Size = UDim2.new(1, 0, 0, 50); arrowBtn.BackgroundColor3 = Color3.fromRGB(70, 30, 120)
arrowBtn.Text = "USING: " .. arrowName:upper(); arrowBtn.TextColor3 = Color3.fromRGB(255,255,255)
arrowBtn.Font = Enum.Font.GothamBold; arrowBtn.Parent = settingsScroll
Instance.new("UICorner", arrowBtn).CornerRadius = UDim.new(0, 8)
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
                if not data then return end
                -- Giữ lại Stand DIO's The World và các Attribute hiếm
                if data.Stand.Value == "DIO's The World" or keepAttri[data.Attri.Value] then
                    _G.AutoRoll = false; return
                end
                local toolName = (data.Stand.Value == "" or data.Stand.Value == "None") and arrowName or "Rokakaka"
                local tool = player.Backpack:FindFirstChild(toolName) or player.Character:FindFirstChild(toolName)
                if tool then
                    player.Character.Humanoid:EquipTool(tool)
                    tool:Activate()
                    if toolName == "Rokakaka" then
                        task.wait(0.2)
                        for _, v in pairs(playerGui:GetDescendants()) do
                            if v:IsA("TextButton") and v.Text:lower() == "yes" and v.Visible then v:Activate() end
                        end
                    end
                end
            end)
            task.wait(0.5)
        end
    end)
end)

--====================== AUTO LAIR ======================
createToggle("AUTO FARM LAIR", function(state)
    _G.MainFarm = state
    local wasFightingBoss = false -- Thêm biến để theo dõi trạng thái đánh boss

    task.spawn(function()
        while _G.MainFarm do
            pcall(function()
                local char = player.Character; local hrp = char.HumanoidRootPart
                
                -- 1. TÌM BOSS (CHỈ TÌM CON NÀO Ở GẦN MÌNH - DƯỚI 500 STUDS)
                local myBoss = nil
                local livingFolder = workspace:FindFirstChild("Living")
                if livingFolder then
                    for _, v in pairs(livingFolder:GetChildren()) do
                        if v.Name == "Boss" and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") then
                            if v.Humanoid.Health > 0 and (hrp.Position - v.HumanoidRootPart.Position).Magnitude < 500 then
                                myBoss = v
                                break
                            end
                        end
                    end
                end

                -- 2. NẾU THẤY BOSS TRONG PHÒNG MÌNH -> ĐẤM
                if myBoss then
                    wasFightingBoss = true -- Đánh dấu là đang trong trận đánh Boss
                    
                    handleStandLogic(char)
                    hrp.Velocity = Vector3.new(0,0,0)
                    
                    -- BAY VÀ BÁM SAU LƯNG BOSS
                    local bossTargetCF = myBoss.HumanoidRootPart.CFrame * CFrame.new(0, -8, 2.5) * CFrame.Angles(math.rad(90), 0, 0)
                    FlyTo(bossTargetCF)

                    if char:FindFirstChild("StandEvents") and char.StandEvents:FindFirstChild("M1") then
                        char.StandEvents.M1:FireServer()
                    else
                        VirtualUser:ClickButton1(Vector2.new(0, 0))
                    end
                
                -- 3. NẾU KHÔNG CÓ BOSS (Boss đã chết hoặc chưa vào phòng)
                else
                    -- KIỂM TRA NẾU BOSS VỪA BỊ GIẾT THÌ DỪNG 1.5 GIÂY
                    if wasFightingBoss then
                        wasFightingBoss = false -- Reset trạng thái
                        task.wait(1.5) -- NGHỈ 1.5 GIÂY Ở ĐÂY SAU KHI BOSS CHẾT
                        return -- Kết thúc vòng lặp hiện tại để sang chu kỳ quét mới cho an toàn
                    end

                    -- ĐI TÌM NPC ĐỂ VÀO TRẬN HOẶC TELE VỀ KHI XONG LAIR
                    if SelectedNPCData.Name ~= "NONE" then
                        if hrp.Position.X < 5000 then 
                            -- Đang ở Map chính: Bay tới vị trí NPC
                            if SelectedNPCData.Name == "i_stabman" then
                                if (hrp.Position - POS_MAIN_STABMAN).Magnitude > 15 then
                                    FlyTo(CFrame.new(POS_MAIN_STABMAN) * CFrame.new(0, 2, 0))
                                end
                            elseif SelectedNPCData.Name == "Apex_Lvl500" then
                                if (hrp.Position - POS_APEX).Magnitude > 15 then
                                    FlyTo(CFrame.new(POS_APEX) * CFrame.new(0, 2, 0))
                                end
                            end
                        else
                            -- Đang ở khu Lair (X >= 5000): Tìm NPC gần mình nhất (Dưới 500 studs) để bắt đầu Lair
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
                                -- Nếu có NPC trong phòng Lair, bay tới và tương tác
                                if (hrp.Position - myNPC:GetModelCFrame().Position).Magnitude > 10 then
                                    FlyTo(myNPC:GetModelCFrame() * CFrame.new(0, 2, 3))
                                end
                            else
                                -- TRƯỜNG HỢP: XONG LAIR (Không có Boss & Không có NPC)
                                -- Dịch chuyển thẳng về map chính để tránh bay quá xa gây lỗi
                                if currentTween then currentTween:Cancel() end
                                if SelectedNPCData.Name == "i_stabman" then
                                    hrp.CFrame = CFrame.new(POS_MAIN_STABMAN) * CFrame.new(0, 5, 0)
                                elseif SelectedNPCData.Name == "Apex_Lvl500" then
                                    hrp.CFrame = CFrame.new(POS_APEX) * CFrame.new(0, 5, 0)
                                end
                                task.wait(1) -- Dừng 1 giây để map chính kịp load
                            end
                        end

                        -- Kích hoạt NPC & Bấm Yes (Chỉ hoạt động khi ở gần NPC)
                        for _, v in pairs(workspace:GetDescendants()) do
                            if v:IsA("Model") and v.Name == SelectedNPCData.Name and (hrp.Position - v:GetModelCFrame().Position).Magnitude < 30 then
                                local r = v:FindFirstChild("Done") or v:FindFirstChild("Click") or v:FindFirstChildOfClass("RemoteEvent")
                                if r then r:FireServer() end
                            end
                        end

                        for _, g in pairs(playerGui:GetDescendants()) do
                            if g:IsA("TextButton") and g.Visible and (g.Text:lower():find("yes") or g.Text:lower():find("accept")) then
                                g:Activate()
                            end
                        end
                    end
                end
            end)
            task.wait(0.15) -- Tốc độ quét 
        end
    end)
end)

-- DANH SÁCH NPC
createNPCSelection("APEX LEVEL 500", "Apex_Lvl500", "Dio Diary,Anubis")
createNPCSelection("I_STABMAN (RAID)", "i_stabman", "Carrow")

-- Noclip & Phím tắt L (Rất quan trọng khi bay xuyên tường)
RunService.Stepped:Connect(function()
    if _G.MainFarm and player.Character then
        for _, v in pairs(player.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
end)

UserInputService.InputBegan:Connect(function(i, g)
    if not g and i.KeyCode == Enum.KeyCode.L then screenGui.Enabled = not screenGui.Enabled end
end)
