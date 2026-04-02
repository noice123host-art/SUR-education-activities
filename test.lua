local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- Xóa Menu cũ nếu có
if playerGui:FindFirstChild("RebootedMenuV2") then playerGui.RebootedMenuV2:Destroy() end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RebootedMenuV2"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- ====================== BIẾN HỆ THỐNG ======================
local SelectedNPCData = { Name = "NONE" }
local arrowOptions = {"Charged Arrow", "Stand Arrow"}
local arrowName = arrowOptions[1]
local keepAttri = {["Scourge"] = true, ["Hacker"] = true, ["Legendary"] = true, ["Glass Cannon"] = true}
local flySpeed = 150 
local currentTween = nil

-- Tọa độ
local POS_MAIN_STABMAN = Vector3.new(-40.3, 67.1, -468.7) 
local POS_APEX = Vector3.new(-312.9, 66.8, 144.7)

-- ====================== GIAO DIỆN CHÍNH ======================
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 650, 0, 400)
mainFrame.Position = UDim2.new(0.5, -325, 0.5, -200)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)

-- KHUNG BÊN TRÁI (NAVIGATION)
local leftNav = Instance.new("Frame")
leftNav.Size = UDim2.new(0, 180, 1, -20)
leftNav.Position = UDim2.new(0, 10, 0, 10)
leftNav.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
leftNav.Parent = mainFrame
Instance.new("UICorner", leftNav).CornerRadius = UDim.new(0, 8)

local navLayout = Instance.new("UIListLayout", leftNav)
navLayout.Padding = UDim.new(0, 5)
navLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- KHUNG BÊN PHẢI (CONTENT)
local rightContent = Instance.new("Frame")
rightContent.Size = UDim2.new(1, -210, 1, -20)
rightContent.Position = UDim2.new(0, 200, 0, 10)
rightContent.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
rightContent.Parent = mainFrame
Instance.new("UICorner", rightContent).CornerRadius = UDim.new(0, 8)

-- Các trang nội dung
local pages = {}
local function createPage(name)
    local page = Instance.new("Frame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.Name = name
    page.Parent = rightContent
    pages[name] = page
    
    local layout = Instance.new("UIListLayout", page)
    layout.Padding = UDim.new(0, 10)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    return page
end

local rollPage = createPage("RollPage")
local lairPage = createPage("LairPage")

-- Hàm chuyển trang
local function showPage(name)
    for _, p in pairs(pages) do p.Visible = false end
    if pages[name] then pages[name].Visible = true end
end

-- ====================== COMPONENT UI ======================
local function createNavButton(text, targetPage)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 45)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.Parent = leftNav
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
    
    btn.MouseButton1Click:Connect(function()
        showPage(targetPage)
    end)
end

local function createToggle(parent, text, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(0.9, 0, 0, 50)
    container.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    container.Parent = parent
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 5)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.GothamBold
    label.Parent = container

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 60, 0, 25)
    btn.Position = UDim2.new(1, -70, 0.5, -12)
    btn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
    btn.Text = "OFF"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.Parent = container
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)

    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = state and "ON" or "OFF"
        btn.BackgroundColor3 = state and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(150, 50, 50)
        callback(state)
    end)
end

-- ====================== NỘI DUNG TRANG ROLL STAND ======================
createToggle(rollPage, "AUTO ROLL ENABLE", function(s) _G.AutoRoll = s end)

local arrowSelBtn = Instance.new("TextButton")
arrowSelBtn.Size = UDim2.new(0.9, 0, 0, 40)
arrowSelBtn.BackgroundColor3 = Color3.fromRGB(60, 40, 100)
arrowSelBtn.Text = "USING: " .. arrowName
arrowSelBtn.TextColor3 = Color3.fromRGB(255,255,255)
arrowSelBtn.Font = Enum.Font.GothamBold
arrowSelBtn.Parent = rollPage
Instance.new("UICorner", arrowSelBtn).CornerRadius = UDim.new(0, 5)

arrowSelBtn.MouseButton1Click:Connect(function()
    arrowName = (arrowName == arrowOptions[1]) and arrowOptions[2] or arrowOptions[1]
    arrowSelBtn.Text = "USING: " .. arrowName
end)

-- ====================== NỘI DUNG TRANG LAIR ======================
createToggle(lairPage, "AUTO FARM LAIR", function(s) _G.MainFarm = s end)

local function createNPCBtn(displayName, internalName)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.Text = displayName
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.GothamBold
    btn.Parent = lairPage
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)

    btn.MouseButton1Click:Connect(function()
        for _, v in pairs(lairPage:GetChildren()) do
            if v:IsA("TextButton") then v.BackgroundColor3 = Color3.fromRGB(40, 40, 40) end
        end
        btn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
        SelectedNPCData.Name = internalName
    end)
end

createNPCBtn("Apex LVL 500", "Apex_Lvl500")
createNPCBtn("Istabman Lvl 200", "i_stabman")

-- Khởi tạo nút Menu
createNavButton("ROLL STAND", "RollPage")
createNavButton("AUTO LAIR", "LairPage")
showPage("RollPage") -- Mặc định hiện trang Roll

-- ====================== HÀM LOGIC (FLY/ROLL/LAIR) ======================
local function FlyTo(targetCFrame)
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    local distance = (hrp.Position - targetCFrame.Position).Magnitude
    if distance < 3 then if currentTween then currentTween:Cancel() end hrp.CFrame = targetCFrame return end
    if currentTween then currentTween:Cancel() end
    currentTween = TweenService:Create(hrp, TweenInfo.new(distance/flySpeed, Enum.EasingStyle.Linear), {CFrame = targetCFrame})
    currentTween:Play()
end

-- Vòng lặp Auto Roll
task.spawn(function()
    while true do
        if _G.AutoRoll then
            pcall(function()
                local data = player:FindFirstChild("Data")
                if data then
                    if data.Stand.Value == "DIO's The World" or keepAttri[data.Attri.Value] then
                        _G.AutoRoll = false return
                    end
                    local toolName = (data.Stand.Value == "" or data.Stand.Value == "None") and arrowName or "Rokakaka"
                    local tool = player.Backpack:FindFirstChild(toolName) or player.Character:FindFirstChild(toolName)
                    if tool then
                        player.Character.Humanoid:EquipTool(tool)
                        tool:Activate()
                        if toolName == "Rokakaka" then
                            task.wait(0.3)
                            for _, v in pairs(playerGui:GetDescendants()) do
                                if v:IsA("TextButton") and v.Text:lower() == "yes" and v.Visible then v:Activate() end
                            end
                        end
                    end
                end
            end)
        end
        task.wait(0.5)
    end
end)

-- Vòng lặp Auto Lair (Đã tích hợp dừng 1.5s)
task.spawn(function()
    local wasFightingBoss = false
    while true do
        if _G.MainFarm then
            pcall(function()
                local char = player.Character; local hrp = char.HumanoidRootPart
                local myBoss = nil
                local living = workspace:FindFirstChild("Living")
                if living then
                    for _, v in pairs(living:GetChildren()) do
                        if v.Name == "Boss" and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                            if (hrp.Position - v.HumanoidRootPart.Position).Magnitude < 500 then
                                myBoss = v break
                            end
                        end
                    end
                end

                if myBoss then
                    wasFightingBoss = true
                    FlyTo(myBoss.HumanoidRootPart.CFrame * CFrame.new(0, -8, 2.5) * CFrame.Angles(math.rad(90), 0, 0))
                    if char:FindFirstChild("StandEvents") then char.StandEvents.M1:FireServer() end
                else
                    if wasFightingBoss then
                        wasFightingBoss = false
                        task.wait(1.5) -- DỪNG 1.5 GIÂY SAU KHI BOSS CHẾT
                    end
                    
                    if SelectedNPCData.Name ~= "NONE" then
                        if hrp.Position.X < 5000 then
                            local pos = SelectedNPCData.Name == "i_stabman" and POS_MAIN_STABMAN or POS_APEX
                            if (hrp.Position - pos).Magnitude > 15 then FlyTo(CFrame.new(pos)) end
                        else
                            -- Logic trong khu vực Lair
                            for _, v in pairs(workspace:GetDescendants()) do
                                if v:IsA("Model") and v.Name == SelectedNPCData.Name and (hrp.Position - v:GetModelCFrame().Position).Magnitude < 500 then
                                    FlyTo(v:GetModelCFrame() * CFrame.new(0, 2, 3))
                                    local r = v:FindFirstChild("Done") or v:FindFirstChild("Click") or v:FindFirstChildOfClass("RemoteEvent")
                                    if r then r:FireServer() end
                                    break
                                end
                            end
                        end
                        -- Click Yes
                        for _, g in pairs(playerGui:GetDescendants()) do
                            if g:IsA("TextButton") and g.Visible and (g.Text:lower():find("yes") or g.Text:lower():find("accept")) then g:Activate() end
                        end
                    end
                end
            end)
        end
        task.wait(0.2)
    end
end)

-- Noclip & Phím tắt L
RunService.Stepped:Connect(function()
    if (_G.MainFarm or _G.AutoRoll) and player.Character then
        for _, v in pairs(player.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
end)

UserInputService.InputBegan:Connect(function(i, g)
    if not g and i.KeyCode == Enum.KeyCode.L then mainFrame.Visible = not mainFrame.Visible end
end)
