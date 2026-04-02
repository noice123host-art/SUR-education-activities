local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- Kiểm tra nếu đã có Menu thì không tạo cái mới (tránh bị nhân bản khi chạy lại script)
if playerGui:FindFirstChild("RebootedMenu") then 
    playerGui.RebootedMenu:Destroy() 
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RebootedMenu"
screenGui.ResetOnSpawn = false -- Giữ UI sống sót
screenGui.Parent = playerGui

-- Biến Global để giữ trạng thái qua các lần chết
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
local leftLayout = Instance.new("UIListLayout", leftFrame); leftLayout.Padding = UDim.new(0, 10); leftLayout.HorizontalAlignment = "Center"

local rightFrame = Instance.new("Frame")
rightFrame.Size = UDim2.new(1, -250, 1, -20)
rightFrame.Position = UDim2.new(0, 240, 0, 10)
rightFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
rightFrame.Parent = mainFrame
Instance.new("UICorner", rightFrame).CornerRadius = UDim.new(0, 12)

local rollContainer = Instance.new("Frame")
rollContainer.Size = UDim2.new(1, 0, 1, 0); rollContainer.BackgroundTransparency = 1; rollContainer.Parent = rightFrame; rollContainer.Visible = true
local lairContainer = Instance.new("Frame")
lairContainer.Size = UDim2.new(1, 0, 1, 0); lairContainer.BackgroundTransparency = 1; lairContainer.Parent = rightFrame; lairContainer.Visible = false

local function showPage(page)
    rollContainer.Visible = false; lairContainer.Visible = false; page.Visible = true
end

local function createMenuBtn(txt, target)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 60); btn.Text = txt; btn.TextSize = 22; btn.Font = "GothamBold"
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); btn.TextColor3 = Color3.new(1,1,1)
    btn.Parent = leftFrame
    Instance.new("UICorner", btn)
    btn.MouseButton1Click:Connect(function() showPage(target) end)
end

local function createToggle(parent, txt, globalVar)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.95, 0, 0, 70); btn.Text = "  " .. txt; btn.TextSize = 24; btn.Font = "GothamBold"
    btn.BackgroundColor3 = _G[globalVar] and Color3.fromRGB(0, 150, 80) or Color3.fromRGB(50, 50, 50)
    btn.TextColor3 = Color3.new(1,1,1); btn.TextXAlignment = "Left"; btn.Parent = parent
    Instance.new("UICorner", btn)
    btn.MouseButton1Click:Connect(function()
        _G[globalVar] = not _G[globalVar]
        btn.BackgroundColor3 = _G[globalVar] and Color3.fromRGB(0, 150, 80) or Color3.fromRGB(50, 50, 50)
    end)
    if not parent:FindFirstChildOfClass("UIListLayout") then
        local l = Instance.new("UIListLayout", parent); l.Padding = UDim.new(0, 15); l.HorizontalAlignment = "Center"
    end
end

createMenuBtn("ROLL STAND", rollContainer)
createMenuBtn("AUTO LAIR", lairContainer)
createToggle(rollContainer, "ENABLE ROLL", "AutoRoll")
createToggle(lairContainer, "ENABLE LAIR", "MainFarm")

-- ====================== LOGIC BAY (FLY) ======================
local function FlyTo(targetCF)
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart", 5)
    if not hrp then return end
    
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
    while true do
        if _G.AutoRoll then
            pcall(function()
                local char = player.Character or player.CharacterAdded:Wait()
                local hum = char:WaitForChild("Humanoid", 5)
                local data = player:WaitForChild("Data", 5)
                
                if data.Stand.Value == "DIO's The World" or keepAttri[data.Attri.Value] then 
                    _G.AutoRoll = false return 
                end
                
                local toolName = (data.Stand.Value == "" or data.Stand.Value == "None") and arrowName or "Rokakaka"
                local tool = player.Backpack:FindFirstChild(toolName) or char:FindFirstChild(toolName)
                
                if tool and hum then
                    hum:EquipTool(tool)
                    tool:Activate()
                    if toolName == "Rokakaka" then 
                        task.wait(0.4)
                        for _, v in pairs(playerGui:GetDescendants()) do 
                            if v:IsA("TextButton") and v.Text:lower() == "yes" then v:Activate() end 
                        end 
                    end
                end
            end)
        end
        task.wait(0.6)
    end
end)

-- ====================== VÒNG LẶP AUTO LAIR ======================
task.spawn(function()
    local wasFightingBoss = false
    while true do
        if _G.MainFarm then
            pcall(function()
                local char = player.Character or player.CharacterAdded:Wait()
                local hrp = char:WaitForChild("HumanoidRootPart", 5)
                if not hrp then return end

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
                    if wasFightingBoss then wasFightingBoss = false; task.wait(2); return end
                    if SelectedNPCData.Name ~= "NONE" then
                        -- Tự động quay lại vị trí NPC nếu Boss chết
                        local p = SelectedNPCData.Name == "i_stabman" and POS_MAIN_STABMAN or POS_APEX
                        if (hrp.Position - p).Magnitude > 20 then 
                            FlyTo(CFrame.new(p) * CFrame.new(0,5,0)) 
                        end
                        -- Click NPC
                        for _, v in pairs(workspace:GetDescendants()) do
                            if v:IsA("Model") and v.Name == SelectedNPCData.Name and (hrp.Position - v:GetModelCFrame().Position).Magnitude < 35 then
                                local r = v:FindFirstChild("Done") or v:FindFirstChild("Click") or v:FindFirstChildOfClass("RemoteEvent")
                                if r then r:FireServer() end
                            end
                        end
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

-- Nút chọn NPC
local function npcSelect(name, id)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.95, 0, 0, 60); btn.Text = name:upper(); btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.TextColor3 = Color3.new(0.8, 0.8, 0.8); btn.Font = "GothamBold"; btn.Parent = lairContainer; Instance.new("UICorner", btn)
    btn.MouseButton1Click:Connect(function()
        for _, v in pairs(lairContainer:GetChildren()) do if v:IsA("TextButton") then v.BackgroundColor3 = Color3.fromRGB(40, 40, 40) end end
        btn.BackgroundColor3 = Color3.fromRGB(0, 120, 255); SelectedNPCData.Name = id
    end)
end
npcSelect("Apex LVL 500", "Apex_Lvl500")
npcSelect("Istabman Lvl 200", "i_stabman")

-- Chống va chạm & Phím tắt L
RunService.Stepped:Connect(function()
    pcall(function()
        if (_G.MainFarm or _G.AutoRoll) and player.Character then
            for _, v in pairs(player.Character:GetDescendants()) do 
                if v:IsA("BasePart") then v.CanCollide = false end 
            end
        end
    end)
end)

UserInputService.InputBegan:Connect(function(i, g)
    if not g and i.KeyCode == Enum.KeyCode.L then mainFrame.Visible = not mainFrame.Visible end
end)
