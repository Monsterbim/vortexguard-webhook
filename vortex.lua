if game.PlaceId == 142823291 then
    -- [ Services ] --
    Print("Vortex Inject")
    local Players = game:GetService('Players')
    local CoreGUI = game:GetService('CoreGui')
    local UserInputService = game:GetService("UserInputService")
    local VirtualUser = game:GetService("VirtualUser")
    local TweenService = game:GetService("TweenService")
    local RunService = game:GetService("RunService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")

    -- [ Global Variables ] --
    getgenv().coinFarm = false
    local antiAFK = false
    local espActive = false
    local afkConnection
    local walkSpeed = 30 -- Maximal WalkSpeed
    local roles
    local Sheriff, Murder, Hero
    local espConnections = {}
    local coinFarmThread

    -- [ GUI Setup ] --
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "CoinFarmUI"
    ScreenGui.Parent = CoreGUI
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 250, 0, 200)
    MainFrame.Position = UDim2.new(0.5, -125, 0.5, -100)
    MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 10)
    UICorner.Parent = MainFrame

    -- [ VortexScript Label ] --
    local NameLabel = Instance.new("TextLabel")
    NameLabel.Size = UDim2.new(1, -20, 0, 30)
    NameLabel.Position = UDim2.new(0, 10, 0, 0)
    NameLabel.Text = "VortexScript                 MM2"
    NameLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    NameLabel.TextColor3 = Color3.fromRGB(148, 0, 211)
    NameLabel.Font = Enum.Font.Gotham
    NameLabel.TextSize = 20
    NameLabel.TextStrokeTransparency = 0.8
    NameLabel.TextXAlignment = Enum.TextXAlignment.Left
    NameLabel.Parent = MainFrame

    -- [ Draggable GUI ] --
    local function MakeDraggable(frame)
        local dragging, dragInput, dragStart, startPos

        local function update(input)
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                       startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end

        frame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos = frame.Position

                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)

        frame.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                dragInput = input
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                update(input)
            end
        end)
    end

    MakeDraggable(MainFrame)

    -- [ CoinFarm Button ] --
    local MainButton = Instance.new("TextButton")
    MainButton.Size = UDim2.new(1, -20, 0, 30)
    MainButton.Position = UDim2.new(0, 10, 0, 40)
    MainButton.Text = "CoinFarm: OFF"
    MainButton.BackgroundColor3 = Color3.fromRGB(50, 0, 100)
    MainButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    MainButton.Font = Enum.Font.Gotham
    MainButton.TextSize = 12
    MainButton.Parent = MainFrame

    local MainButtonCorner = Instance.new("UICorner")
    MainButtonCorner.CornerRadius = UDim.new(0, 8)
    MainButtonCorner.Parent = MainButton

    -- [ Anti-AFK Button ] --
    local AntiAFKButton = Instance.new("TextButton")
    AntiAFKButton.Size = UDim2.new(1, -20, 0, 30)
    AntiAFKButton.Position = UDim2.new(0, 10, 0, 80)
    AntiAFKButton.Text = "Anti-AFK: OFF"
    AntiAFKButton.BackgroundColor3 = Color3.fromRGB(150, 100, 255)
    AntiAFKButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    AntiAFKButton.Font = Enum.Font.Gotham
    AntiAFKButton.TextSize = 12
    AntiAFKButton.Parent = MainFrame

    local AntiAFKCorner = Instance.new("UICorner")
    AntiAFKCorner.CornerRadius = UDim.new(0, 8)
    AntiAFKCorner.Parent = AntiAFKButton

    -- [ ESP Button ] --
    local ESPButton = Instance.new("TextButton")
    ESPButton.Size = UDim2.new(1, -20, 0, 30)
    ESPButton.Position = UDim2.new(0, 10, 0, 120)
    ESPButton.Text = "ESP: OFF"
    ESPButton.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
    ESPButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ESPButton.Font = Enum.Font.Gotham
    ESPButton.TextSize = 12
    ESPButton.Parent = MainFrame

    local ESPButtonCorner = Instance.new("UICorner")
    ESPButtonCorner.CornerRadius = UDim.new(0, 8)
    ESPButtonCorner.Parent = ESPButton

    -- [ Anti-AFK Function ] --
    AntiAFKButton.MouseButton1Click:Connect(function()
        antiAFK = not antiAFK
        if antiAFK then
            AntiAFKButton.Text = "Anti-AFK: ON"
            AntiAFKButton.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
            afkConnection = Players.LocalPlayer.Idled:Connect(function()
                VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
                task.wait(1)
                VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
            end)
        else
            AntiAFKButton.Text = "Anti-AFK: OFF"
            AntiAFKButton.BackgroundColor3 = Color3.fromRGB(150, 100, 255)
            if afkConnection then afkConnection:Disconnect() end
        end
    end)

    -- [ New CoinFarm Logic ] --
    MainButton.MouseButton1Click:Connect(function()
        getgenv().coinFarm = not getgenv().coinFarm
        if getgenv().coinFarm then
            MainButton.Text = "CoinFarm: ON"
            MainButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)

            coinFarmThread = task.spawn(function()
                local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear)

                while getgenv().coinFarm do
                    local character = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
                    local root = character:WaitForChild("HumanoidRootPart", 5)
                    if not root then break end

                    local humanoid = character:WaitForChild("Humanoid")
                    humanoid.WalkSpeed = walkSpeed -- Maximal WalkSpeed auf 17 setzen

                    local coins = {}
                    for _, obj in pairs(workspace:GetDescendants()) do
                        if obj:IsA("BasePart") and obj.Name == "Coin_Server" then
                            table.insert(coins, obj)
                        end
                    end

                    table.sort(coins, function(a, b)
                        return (root.Position - a.Position).Magnitude < (root.Position - b.Position).Magnitude
                    end)

                    for _, coin in ipairs(coins) do
                        if not getgenv().coinFarm then break end
                        local direction = (coin.Position - root.Position).unit
                        local newPosition = root.Position + direction * walkSpeed * 0.2  -- Bewege dich mit höherer Geschwindigkeit
                        local goal = { CFrame = CFrame.new(newPosition) }  -- Bewege dich ohne Drehung
                        local tween = TweenService:Create(root, tweenInfo, goal)
                        tween:Play()
                        tween.Completed:Wait()
                        task.wait(0.5)
                    end
                    task.wait(0.2)
                end
            end)
        else
            MainButton.Text = "CoinFarm: OFF"
            MainButton.BackgroundColor3 = Color3.fromRGB(50, 0, 100)
        end
    end)

    -- [ ESP Functionality ] --
    function CreateHighlight()
        for _, v in pairs(Players:GetChildren()) do
            if v ~= Players.LocalPlayer and v.Character and not v.Character:FindFirstChild("Highlight") then
                local highlight = Instance.new("Highlight")
                highlight.Parent = v.Character
            end
        end
    end

    function UpdateHighlights()
        for _, v in pairs(Players:GetChildren()) do
            if v ~= Players.LocalPlayer and v.Character and v.Character:FindFirstChild("Highlight") then
                local Highlight = v.Character:FindFirstChild("Highlight")
                if v.Name == Sheriff then
                    Highlight.FillColor = Color3.fromRGB(0, 0, 225)
                elseif v.Name == Murder then
                    Highlight.FillColor = Color3.fromRGB(225, 0, 0)
                elseif v.Name == Hero then
                    Highlight.FillColor = Color3.fromRGB(255, 250, 0)
                else
                    Highlight.FillColor = Color3.fromRGB(0, 225, 0)
                end
            end
        end
    end

    -- [ ESP Button Logic ] --
    ESPButton.MouseButton1Click:Connect(function()
        espActive = not espActive
        if espActive then
            ESPButton.Text = "ESP: ON"
            ESPButton.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
        else
            ESPButton.Text = "ESP: OFF"
            ESPButton.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
            for _, v in pairs(Players:GetChildren()) do
                if v ~= Players.LocalPlayer and v.Character and v.Character:FindFirstChild("Highlight") then
                    v.Character:FindFirstChild("Highlight"):Destroy()
                end
            end
        end
    end)

    -- [ Update Loop ] --
    RunService.RenderStepped:Connect(function()
        roles = ReplicatedStorage:FindFirstChild("GetPlayerData", true):InvokeServer()

        for i, v in pairs(roles) do
            if v.Role == "Murderer" then
                Murder = i
            elseif v.Role == 'Sheriff' then
                Sheriff = i
            elseif v.Role == 'Hero' then
                Hero = i
            end
        end

        if espActive then
            CreateHighlight()
            UpdateHighlights()
        end
    end)
end
