local player = game.Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/refs/heads/main/Library.lua"))()

local Window = Library:CreateWindow({
    Title = "|.Swift |",
    Footer = "Ruler Hub | Basketball: Zero v1.0.85 by Swift |",
    ToggleKeybind = Enum.KeyCode.RightShift,
    Center = true,
    AutoShow = true
})

-- Vars and state
local alwaysInEnabled = false
local aimAssistEnabled = false
local alwaysInCurveDistance = 18
local alwaysInStrength = 0.37
local BALL_NAME = "Basketball"
local flyEnabled = false
local flySpeed = 50
local infJumpEnabled = false
local noClipEnabled = false
local forcedWalkSpeed = 16
local forcedJumpPower = 50
local statsEnabled = false
local autoTPBallEnabled = false
local autoAimEnabled = false
local autoScoreEnabled = false
local hitboxSize = 1

-- New feature states
local ballPredictorEnabled = false
local ballESPEnabled = false
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F then
        hoopAimbotEnabled = not hoopAimbotEnabled
    end
end)

local ballMagnetEnabled = false

-- New state features
local hoopAimbotTriggered = false
local lastBallState = nil

-- Tabs
local MainTab = Window:AddTab("Main", "house")
local LeftGroupbox = MainTab:AddLeftGroupbox("Features")
local RightGroupbox = MainTab:AddRightGroupbox("Auto Features")

-- Always In + Aim Assist
local MyToggle = LeftGroupbox:AddToggle("MyToggle", {
    Text = "Always In",
    Default = false,
    Tooltip = "when enabled, curves the ball to the nearest hoop",
    Callback = function(Value)
        alwaysInEnabled = Value
        aimAssistEnabled = Value
    end
})

local CurveSlider = LeftGroupbox:AddSlider("CurveDist", {
    Text = "Always In Curve Distance",
    Default = 18,
    Min = 1,
    Max = 100,
    Rounding = 0,
    Callback = function(Value)
        alwaysInCurveDistance = Value
    end
})

local StrengthSlider = LeftGroupbox:AddSlider("CurveStrength", {
    Text = "Always In Strength",
    Default = 0.37,
    Min = 0,
    Max = 1.5,
    Rounding = 2,
    Callback = function(Value)
        alwaysInStrength = Value
    end
})

LeftGroupbox:AddButton("Teleport To Ball", function()
    local ball = workspace:FindFirstChild(BALL_NAME, true)
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if ball and hrp then
        hrp.CFrame = ball.CFrame + Vector3.new(0, 3, 0)
    end
end)

-- Always In / Aim Assist logic (existing)
local function getHoops()
    local hoops = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name:lower() == "hoop" and obj:IsA("BasePart") then
            table.insert(hoops, obj)
        end
    end
    return hoops
end
local cachedHoops = getHoops()
workspace.DescendantAdded:Connect(function(obj)
    if obj.Name:lower() == "hoop" and obj:IsA("BasePart") then
        table.insert(cachedHoops, obj)
    end
end)

local cachedBall = nil
local function findBall()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name == BALL_NAME and obj:IsA("BasePart") then
            return obj
        end
    end
    return nil
end
cachedBall = findBall()
workspace.DescendantAdded:Connect(function(obj)
    if obj.Name == BALL_NAME and obj:IsA("BasePart") then
        cachedBall = obj
    end
end)

local function isScored(ball, hoop)
    if not (ball and hoop) then return false end
    local ballY = ball.Position.Y
    local hoopY = hoop.Position.Y
    local deltaXZ = Vector3.new(ball.Position.X, 0, ball.Position.Z) - Vector3.new(hoop.Position.X, 0, hoop.Position.Z)
    local hoopRadius = (hoop.Size.X + hoop.Size.Z)/4
    return (ballY < hoopY) and (deltaXZ.Magnitude < hoopRadius)
end

local scoredRecently = false
task.spawn(function()
    while true do
        if aimAssistEnabled and cachedBall then
            if cachedBall.Velocity.Magnitude > 1 then
                local closestHoop, closestDist = nil, math.huge
                for _, hoop in ipairs(cachedHoops) do
                    local dist = (hoop.Position - cachedBall.Position).Magnitude
                    if dist < closestDist then
                        closestHoop = hoop
                        closestDist = dist
                    end
                end
                if closestHoop and closestDist < alwaysInCurveDistance then
                    local dir = (closestHoop.Position - cachedBall.Position).Unit
                    cachedBall.Velocity = cachedBall.Velocity:Lerp(dir * cachedBall.Velocity.Magnitude, alwaysInStrength)
                    if alwaysInEnabled and closestDist < (closestHoop.Size.Magnitude/2 + cachedBall.Size.Magnitude/2 + 2) and not scoredRecently then
                        local above = closestHoop.Position + Vector3.new(0, closestHoop.Size.Y/2 + 2 + (cachedBall.Size.Y/2), 0)
                        cachedBall.Anchored = false
                        cachedBall.CanCollide = false
                        cachedBall.Velocity = Vector3.new(0, -20, 0)
                        cachedBall.RotVelocity = Vector3.new(0, 0, 0)
                        cachedBall.CFrame = CFrame.new(above)
                        local t = 0
                        while t < 0.7 do
                            if isScored(cachedBall, closestHoop) then
                                cachedBall.Velocity = Vector3.new(0,0,0)
                                scoredRecently = true
                                break
                            end
                            t += 0.04
                            task.wait(0.04)
                        end
                        cachedBall.CanCollide = true
                        task.wait(1.5)
                        scoredRecently = false
                    end
                end
            end
        end
        task.wait(0.07)
    end
end)

task.spawn(function()
    while true do
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")

        if cachedBall then
            -- Auto TP to Ball
            if autoTPBallEnabled and hrp then
                hrp.CFrame = cachedBall.CFrame + Vector3.new(0, 3, 0)
            end

            -- Auto Aim Assist
            if autoAimEnabled and cachedBall.Velocity.Magnitude > 1 then
                local closestHoop, closestDist = nil, math.huge
                for _, hoop in ipairs(cachedHoops) do
                    local dist = (hoop.Position - cachedBall.Position).Magnitude
                    if dist < closestDist then
                        closestHoop = hoop
                        closestDist = dist
                    end
                end
                if closestHoop and closestDist < alwaysInCurveDistance then
                    local dir = (closestHoop.Position - cachedBall.Position).Unit
                    cachedBall.Velocity = cachedBall.Velocity:Lerp(dir * cachedBall.Velocity.Magnitude, alwaysInStrength)
                end
            end

            -- Auto Score (snap above hoop)
            if autoScoreEnabled then
                local closestHoop, closestDist = nil, math.huge
                for _, hoop in ipairs(cachedHoops) do
                    local dist = (hoop.Position - cachedBall.Position).Magnitude
                    if dist < closestDist then
                        closestHoop = hoop
                        closestDist = dist
                    end
                end
                if closestHoop and closestDist < 15 then
                    local above = closestHoop.Position + Vector3.new(0, closestHoop.Size.Y/2 + 2 + (cachedBall.Size.Y/2), 0)
                    cachedBall.Anchored = false
                    cachedBall.CanCollide = false
                    cachedBall.Velocity = Vector3.new(0, -20, 0)
                    cachedBall.RotVelocity = Vector3.new(0, 0, 0)
                    cachedBall.CFrame = CFrame.new(above)
                end
            end
        end

        task.wait(0.15) -- Optimized delay to reduce lag
    end
end)

local xyzLabel = RightGroupbox:AddLabel("Position: Loading...")

task.spawn(function()
    while task.wait(0.1) do
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local pos = hrp.Position
            xyzLabel:SetText("XYZ: " .. math.floor(pos.X) .. ", " .. math.floor(pos.Y) .. ", " .. math.floor(pos.Z))
        else
            xyzLabel:SetText("XYZ: N/A")
        end
    end
end)



LeftGroupbox:AddToggle("BallMagnet", {
    Text = "Ball Magnet",
    Default = false,
    Tooltip = "Pulls the ball toward you",
    Callback = function(Value)
        ballMagnetEnabled = Value
    end
})

-- Ball Magnet logic
game:GetService("RunService").RenderStepped:Connect(function()
    if ballMagnetEnabled then
        local ball = workspace:FindFirstChild(BALL_NAME, true)
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if ball and hrp then
            local dist = (ball.Position - hrp.Position).Magnitude
            if dist > 3 then -- only pull if not already close
                local dir = (hrp.Position - ball.Position).Unit
                ball.Velocity = dir * 45 -- adjust magnet force as needed
            end
        end
    end
end)

local HitboxSlider = LeftGroupbox:AddSlider("HitboxSize", {
    Text = "Ball Hitbox Size (broken)",
    Default = 1,
    Min = 1,
    Max = 10,
    Rounding = 1,
    Callback = function(Value)
        hitboxSize = Value
    end
})

local AutoTPBallToggle = LeftGroupbox:AddToggle("AutoTPBall", {
    Text = "Auto TP to Ball",
    Default = false,
    Callback = function(Value)
        autoTPBallEnabled = Value
    end
})

local AutoAimToggle = LeftGroupbox:AddToggle("AutoAim", {
    Text = "Auto Aim Assist",
    Default = false,
    Callback = function(Value)
        autoAimEnabled = Value
    end
})

local AutoScoreToggle = LeftGroupbox:AddToggle("AutoScore", {
    Text = "Auto Score (Above Rim)",
    Default = false,
    Callback = function(Value)
        autoScoreEnabled = Value
    end
})

local autoShoot = false

RightGroupbox:AddToggle("AutoShootToggle", {
    Text = "Auto Shoot",
    Default = false,
    Callback = function(state)
        autoShoot = state
        if autoShoot then
            task.spawn(function()
                while autoShoot do
                    -- Simulate mouse press & release
                    local VirtualInputManager = game:GetService("VirtualInputManager")
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                    task.wait(0.15)
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                    
                    task.wait(0.2) -- Delay between auto shots
                end
            end)
        end
    end
})

local AutoDribbleToggle = RightGroupbox:AddToggle("AutoDribble", {
    Text = "Auto Dribble (unavailable)",
    Default = false,
    Callback = function(v)
        autoDribbleEnabled = v
    end
})

local AutoStealToggle = RightGroupbox:AddToggle("AutoSteal", {
    Text = "Auto Steal (unavailable)",
    Default = false,
    Callback = function(v)
        autoStealEnabled = v
    end
})

local autoBlock = false
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local blockRemote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("InputEvent")

RightGroupbox:AddToggle("AutoBlockToggle", {
    Text = "Auto Block (Fixed)",
    Default = false,
    Callback = function(state)
        autoBlock = state

        if autoBlock and blockRemote then
            task.spawn(function()
                while autoBlock and task.wait(0.1) do
                    for _, otherPlayer in ipairs(Players:GetPlayers()) do
                        if otherPlayer ~= player and otherPlayer.Team ~= player.Team then
                            local enemyChar = otherPlayer.Character
                            local myChar = player.Character

                            if enemyChar and myChar and myChar:FindFirstChild("HumanoidRootPart") then
                                local ball = enemyChar:FindFirstChild("Basketball")
                                if ball and (ball.Position - myChar.HumanoidRootPart.Position).Magnitude < 15 then
                                    -- Fire block RemoteEvent
                                    pcall(function()
                                        blockRemote:FireServer("Block", true)
                                        task.wait(0.2)
                                        blockRemote:FireServer("Block", false)
                                    end)
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
})

local AutoScoreToggle = RightGroupbox:AddToggle("AutoDunk", {
    Text = "Auto Dunk (unavailable)",
    Default = false,
    Callback = function(v)
        autoDunkEnabled = v
    end
})

local PlayerTab = Window:AddTab("Player Mods", "user")
local LeftGroupbox = PlayerTab:AddLeftGroupbox("Movement")
local RightGroupbox = PlayerTab:AddRightGroupbox("Abilities")

-- Services
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- Vars
local flyEnabled = false
local flySpeed = 50
local infJumpEnabled = false
local noClipEnabled = false
local statsEnabled = false
local forcedWalkSpeed = 16
local forcedJumpPower = 50
local bodyVelocity

-- Fly
RightGroupbox:AddToggle("Fly", {
	Text = "Fly",
	Default = false,
	Callback = function(Value)
		flyEnabled = Value

		if not flyEnabled and bodyVelocity then
			bodyVelocity:Destroy()
			bodyVelocity = nil
		end
	end
})

RightGroupbox:AddSlider("FlySpeed", {
	Text = "Fly Speed",
	Default = 50,
	Min = 10,
	Max = 200,
	Rounding = 1,
	Callback = function(Value)
		flySpeed = Value
	end
})

-- Infinite Jump
RightGroupbox:AddToggle("InfJump", {
	Text = "Infinite Jump",
	Default = false,
	Callback = function(Value)
		infJumpEnabled = Value
	end
})

UserInputService.JumpRequest:Connect(function()
	if infJumpEnabled and player.Character and player.Character:FindFirstChild("Humanoid") then
		player.Character:FindFirstChild("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
	end
end)

-- NoClip
RightGroupbox:AddToggle("NoClip", {
	Text = "NoClip",
	Default = false,
	Callback = function(Value)
		noClipEnabled = Value
	end
})

-- WalkSpeed / JumpPower Mods
LeftGroupbox:AddToggle("StatMods", {
	Text = "WalkSpeed/JumpPower Mod",
	Default = false,
	Callback = function(Value)
		statsEnabled = Value
	end
})

LeftGroupbox:AddSlider("WalkSpeed", {
	Text = "WalkSpeed",
	Default = 16,
	Min = 5,
	Max = 200,
	Rounding = 1,
	Callback = function(Value)
		forcedWalkSpeed = Value
	end
})

LeftGroupbox:AddSlider("JumpPower", {
	Text = "JumpPower",
	Default = 50,
	Min = 10,
	Max = 200,
	Rounding = 1,
	Callback = function(Value)
		forcedJumpPower = Value
	end
})

-- Logic Loop
RunService.RenderStepped:Connect(function()
	local char = player.Character
	if not char then return end

	local hrp = char:FindFirstChild("HumanoidRootPart")
	local humanoid = char:FindFirstChildOfClass("Humanoid")

	-- Fly
	if flyEnabled and hrp then
		if not bodyVelocity then
			bodyVelocity = Instance.new("BodyVelocity")
			bodyVelocity.Velocity = Vector3.zero
			bodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
			bodyVelocity.P = 1e4
			bodyVelocity.Name = "FlyVelocity"
			bodyVelocity.Parent = hrp
		end

		local moveDir = humanoid.MoveDirection
		bodyVelocity.Velocity = moveDir * flySpeed + Vector3.new(0, UserInputService:IsKeyDown(Enum.KeyCode.Space) and flySpeed or 0, 0)
	elseif bodyVelocity then
		bodyVelocity.Velocity = Vector3.zero
	end

	-- NoClip
	if noClipEnabled then
		for _, v in pairs(char:GetDescendants()) do
			if v:IsA("BasePart") and v.CanCollide then
				v.CanCollide = false
			end
		end
	end

	-- WalkSpeed / JumpPower
	if statsEnabled and humanoid then
		humanoid.WalkSpeed = forcedWalkSpeed
		humanoid.JumpPower = forcedJumpPower
	end
end)

-- Reapply Stats on Respawn
player.CharacterAdded:Connect(function(char)
	char:WaitForChild("Humanoid")

	if statsEnabled then
		task.wait(0.2)
		char:FindFirstChildOfClass("Humanoid").WalkSpeed = forcedWalkSpeed
		char:FindFirstChildOfClass("Humanoid").JumpPower = forcedJumpPower
	end
end)

local VisualTab = Window:AddTab("Visuals", "eye")
local VisualGroupbox = VisualTab:AddLeftGroupbox("ESP Options")

local playerESPEnabled = false
VisualGroupbox:AddToggle("PlayerESP", {
    Text = "Player ESP (Names + Color)",
    Default = false,
    Callback = function(state)
        playerESPEnabled = state

        if state then
            task.spawn(function()
                while playerESPEnabled do
                    for _, plr in pairs(game.Players:GetPlayers()) do
                        if plr ~= player and plr.Character and not plr.Character:FindFirstChild("PlayerESP") then
                            local head = plr.Character:FindFirstChild("Head")
                            if head then
                                local esp = Instance.new("BillboardGui", plr.Character)
                                esp.Name = "PlayerESP"
                                esp.Adornee = head
                                esp.Size = UDim2.new(0, 100, 0, 20)
                                esp.StudsOffset = Vector3.new(0, 3, 0)
                                esp.AlwaysOnTop = true

                                local label = Instance.new("TextLabel", esp)
                                label.Size = UDim2.new(1, 0, 1, 0)
                                label.BackgroundTransparency = 1
                                label.Text = plr.Name
                                label.TextScaled = true
                                label.Font = Enum.Font.SourceSansBold
                                label.TextColor3 = (plr.Team == player.Team) and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
                                label.TextStrokeTransparency = 0.5
                            end
                        end
                    end
                    task.wait(1)
                end
            end)
        else
            for _, plr in pairs(game.Players:GetPlayers()) do
                local char = plr.Character
                if char and char:FindFirstChild("PlayerESP") then
                    char.PlayerESP:Destroy()
                end
            end
        end
    end
})

local ballESPEnabled = false
VisualGroupbox:AddToggle("BallESP", {
    Text = "Ball ESP",
    Default = false,
    Callback = function(state)
        ballESPEnabled = state

        local function updateBallESP()
            while ballESPEnabled do
                local ball = workspace:FindFirstChild("Basketball") or workspace:FindFirstChildWhichIsA("MeshPart", true)
                if ball and not ball:FindFirstChild("BallESP") then
                    local esp = Instance.new("BillboardGui", ball)
                    esp.Name = "BallESP"
                    esp.Size = UDim2.new(0, 100, 0, 20)
                    esp.StudsOffset = Vector3.new(0, 3, 0)
                    esp.AlwaysOnTop = true
                    esp.Adornee = ball

                    local label = Instance.new("TextLabel", esp)
                    label.Size = UDim2.new(1, 0, 1, 0)
                    label.BackgroundTransparency = 1
                    label.Text = "BALL"
                    label.TextColor3 = Color3.fromRGB(255, 140, 0)
                    label.Font = Enum.Font.SourceSansBold
                    label.TextScaled = true
                end
                task.wait(1)
            end
        end

        if state then
            task.spawn(updateBallESP)
        else
            local ball = workspace:FindFirstChild("Basketball") or workspace:FindFirstChildWhichIsA("MeshPart", true)
            if ball and ball:FindFirstChild("BallESP") then
                ball.BallESP:Destroy()
            end
        end
    end
})

local hoopESPEnabled = false
VisualGroupbox:AddToggle("HoopESP", {
    Text = "Hoop ESP",
    Default = false,
    Callback = function(state)
        hoopESPEnabled = state

        local function addESPToHoop(hoop)
            if hoop and not hoop:FindFirstChild("HoopESP") then
                local gui = Instance.new("BillboardGui", hoop)
                gui.Name = "HoopESP"
                gui.Size = UDim2.new(0, 100, 0, 20)
                gui.StudsOffset = Vector3.new(0, 5, 0)
                gui.AlwaysOnTop = true
                gui.Adornee = hoop

                local label = Instance.new("TextLabel", gui)
                label.Size = UDim2.new(1, 0, 1, 0)
                label.BackgroundTransparency = 1
                label.Text = "HOOP"
                label.TextColor3 = Color3.fromRGB(0, 200, 255)
                label.Font = Enum.Font.SourceSansBold
                label.TextScaled = true
            end
        end

        if state then
            task.spawn(function()
                while hoopESPEnabled do
                    for _, obj in pairs(workspace:GetDescendants()) do
                        if obj.Name == "Hoop" and obj:IsA("BasePart") then
                            addESPToHoop(obj)
                        end
                    end
                    task.wait(2)
                end
            end)
        else
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") and obj:FindFirstChild("HoopESP") then
                    obj.HoopESP:Destroy()
                end
            end
        end
    end
})

local tracerESPEnabled = false
VisualGroupbox:AddToggle("TracerESP", {
    Text = "Player Distance Tracers",
    Default = false,
    Callback = function(state)
        tracerESPEnabled = state

        if state then
            task.spawn(function()
                while tracerESPEnabled do
                    for _, plr in pairs(game.Players:GetPlayers()) do
                        if plr ~= player and plr.Character and not plr.Character:FindFirstChild("DistanceESP") then
                            local head = plr.Character:FindFirstChild("Head")
                            if head then
                                local gui = Instance.new("BillboardGui", plr.Character)
                                gui.Name = "DistanceESP"
                                gui.Adornee = head
                                gui.Size = UDim2.new(0, 100, 0, 20)
                                gui.StudsOffset = Vector3.new(0, 5, 0)
                                gui.AlwaysOnTop = true

                                local label = Instance.new("TextLabel", gui)
                                label.Size = UDim2.new(1, 0, 1, 0)
                                label.BackgroundTransparency = 1
                                label.TextColor3 = Color3.fromRGB(255, 255, 255)
                                label.Font = Enum.Font.SourceSansBold
                                label.TextScaled = true

                                task.spawn(function()
                                    while gui and gui.Parent and tracerESPEnabled do
                                        local dist = math.floor((plr.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude)
                                        label.Text = dist .. " studs"
                                        task.wait(0.5)
                                    end
                                end)
                            end
                        end
                    end
                    task.wait(2)
                end
            end)
        else
            for _, plr in pairs(game.Players:GetPlayers()) do
                if plr.Character and plr.Character:FindFirstChild("DistanceESP") then
                    plr.Character.DistanceESP:Destroy()
                end
            end
        end
    end
})

-- Ball Predictor (Trajectory Line)
local ballPredictorEnabled = false
VisualGroupbox:AddToggle("BallPredictor", {
    Text = "Ball Predictor (Line)",
    Default = false,
    Callback = function(state)
        ballPredictorEnabled = state

        local RunService = game:GetService("RunService")
        local ballLine = Drawing.new("Line")
        ballLine.Thickness = 2
        ballLine.Color = Color3.fromRGB(255, 255, 0)
        ballLine.Visible = false

        RunService:UnbindFromRenderStep("BallPredictor")

        if state then
            RunService:BindToRenderStep("BallPredictor", Enum.RenderPriority.Camera.Value + 1, function()
                local ball = workspace:FindFirstChild("Basketball")
                if ball and ball:IsA("BasePart") then
                    local cam = workspace.CurrentCamera
                    local origin = ball.Position
                    local velocity = ball.Velocity * 0.1 -- prediction factor

                    local screenPos1, visible1 = cam:WorldToViewportPoint(origin)
                    local screenPos2, visible2 = cam:WorldToViewportPoint(origin + velocity)

                    if visible1 and visible2 then
                        ballLine.From = Vector2.new(screenPos1.X, screenPos1.Y)
                        ballLine.To = Vector2.new(screenPos2.X, screenPos2.Y)
                        ballLine.Visible = true
                    else
                        ballLine.Visible = false
                    end
                else
                    ballLine.Visible = false
                end
            end)
        else
            ballLine.Visible = false
            RunService:UnbindFromRenderStep("BallPredictor")
        end
    end
})

--// State
local smartAlwaysInEnabled = false
local arcHeight = 25
local BALL_NAME = "Basketball"

--// UI Elements
local TeamDropdown = LeftGroupbox:AddDropdown("TeamDropdown", {
    Values = {"home", "away"},
    Default = 1,
    Multi = false,
    Text = "Select Enemy Team",
    Tooltip = "Choose enemy team for hoop targeting",
    Callback = function(value)
        print("Team selected:", value)
    end
})

LeftGroupbox:AddToggle("SmartAlwaysIn", {
    Text = "Always In v2",
    Default = false,
    Tooltip = "Curves the shot Perfectly to Align with the Hoop",
    Callback = function(v)
        smartAlwaysInEnabled = v
        if v then
            setupCurveHitbox()
        else
            destroyCurveHitbox()
        end
    end
})

LeftGroupbox:AddSlider("ArcHeightSlider", {
    Text = "Arc Height",
    Default = 25,
    Min = 5,
    Max = 75,
    Rounding = 1,
    Tooltip = "Controls how high the arc curves",
    Callback = function(value)
        arcHeight = value
    end
})

--// Utility: Team Logic
local function getEnemyTeamName()
    local yourTeam = TeamDropdown.Value or "home"
    return yourTeam == "home" and "away" or "home"
end

local function getClosestEnemyHoop(pos)
    local enemyTeam = getEnemyTeamName():lower()
    local closestHoop, closestDist = nil, math.huge
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name:lower() == "hoop" then
            local fullName = obj:GetFullName():lower()
            if fullName:find(enemyTeam) then
                local dist = (obj.Position - pos).Magnitude
                if dist < closestDist then
                    closestHoop = obj
                    closestDist = dist
                end
            end
        end
    end
    return closestHoop
end

--// Hitbox & Curve Logic
local curveHitbox = nil
local hitboxTouchConn = nil
local renderConn = nil

function setupCurveHitbox()
    destroyCurveHitbox()

    curveHitbox = Instance.new("Part")
    curveHitbox.Name = "CurveHitbox"
    curveHitbox.Size = Vector3.new(100, 100, 100)
    curveHitbox.Anchored = true
    curveHitbox.CanCollide = false
    curveHitbox.Transparency = 1
    curveHitbox.Parent = workspace

    renderConn = RunService.RenderStepped:Connect(function()
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            curveHitbox.Position = hrp.Position + Vector3.new(0, 4, 0)
        else
            curveHitbox.Position = Vector3.new(9999, 9999, 9999)
        end
    end)

    hitboxTouchConn = curveHitbox.Touched:Connect(function(part)
        if not smartAlwaysInEnabled then return end
        if part:IsA("BasePart") and part.Name == BALL_NAME and part:IsDescendantOf(workspace) then
            if not part:IsDescendantOf(player.Character) then
                local ball = part
                local hoop = getClosestEnemyHoop(ball.Position)
                if hoop then
                    -- Calculate smart arc
                    local g = workspace.Gravity
                    local pos = ball.Position
                    local target = hoop.Position + Vector3.new(0, 2.5, 0)
                    local disp = target - pos

                    local dxz = Vector3.new(disp.X, 0, disp.Z).Magnitude
                    local dy = disp.Y
                    local h = arcHeight
                    local vy = math.sqrt(2 * g * h)
                    local t_up = vy / g
                    local t_down = math.sqrt((2 * math.max(h - dy, 1)) / g)
                    local t_total = t_up + t_down
                    local vxz = dxz / t_total
                    local dirXZ = Vector3.new(disp.X, 0, disp.Z).Unit

                    local finalVel = dirXZ * vxz + Vector3.new(0, vy, 0)

                    ball.Velocity = finalVel
                    ball.RotVelocity = Vector3.zero
                    ball.CanCollide = false
                end
            end
        end
    end)
end

function destroyCurveHitbox()
    if renderConn then renderConn:Disconnect() renderConn = nil end
    if hitboxTouchConn then hitboxTouchConn:Disconnect() hitboxTouchConn = nil end
    if curveHitbox then curveHitbox:Destroy() curveHitbox = nil end
end

--// MAIN TAB
local TeleportTab = Window:AddTab("Teleportation", "crosshair")
local LeftGroupbox = TeleportTab:AddLeftGroupbox("Teleport")
local RightGroupbox = TeleportTab:AddRightGroupbox("Gameplay")

--// PLAYER & HRP
local player = game.Players.LocalPlayer
local function GetHRP()
    return player.Character and player.Character:FindFirstChild("HumanoidRootPart")
end

--// TEAM & COURT SETTINGS
LeftGroupbox:AddDropdown("TeamDropdown", {
    Text = "Team",
    Values = { "home", "away" },
    Default = 1,
    Callback = function(value) _G.CurrentTeam = value end
})
_G.CurrentTeam = "home"

LeftGroupbox:AddDropdown("CourtDropdown", {
    Text = "Court",
    Values = { "Normal", "Beach" },
    Default = 1,
    Callback = function(value) _G.CurrentCourt = value end
})
_G.CurrentCourt = "Normal"

--// POSITION DATA
local Positions = {
    Normal = {
        Home3PT = {
            Vector3.new(143.8465, 4.0, -217.9781),
            Vector3.new(51.8576, 4.0, -298.5872),
            Vector3.new(148.7061, 4.0, -374.9094),
        },
        Away3PT = {
            Vector3.new(-52, 3, -298),
            Vector3.new(-147, 3, -220),
            Vector3.new(-147, 3, -378),
        },
        HomeHoop = Vector3.new(146, 4, -298),
        AwayHoop = Vector3.new(-147, 4, -298),
        HomePaint = Vector3.new(123, 4, -298),
        AwayPaint = Vector3.new(-123, 4, -298),
    },
    Beach = {
        Home3PT = {
            Vector3.new(143.8465, 4.0, -217.9781),
            Vector3.new(51.8576, 4.0, -298.5872),
            Vector3.new(148.7061, 4.0, -374.9094),
        },
        Away3PT = {
            Vector3.new(-52, 3, -298),
            Vector3.new(-147, 3, -220),
            Vector3.new(-147, 3, -378),
        },
        HomeHoop = Vector3.new(146, 4, -298),
        AwayHoop = Vector3.new(-147, 4, -298),
        HomePaint = Vector3.new(123, 4, -298),
        AwayPaint = Vector3.new(-123, 4, -298),
    }
}

--// TELEPORT FUNCTION
local function TeleportTo(position)
    local hrp = GetHRP()
    if hrp then hrp.CFrame = CFrame.new(position + Vector3.new(0, 2, 0)) end
end

--// UI BUTTONS
LeftGroupbox:AddButton("TP to 3PT Line", function()
    local team = _G.CurrentTeam
    local court = _G.CurrentCourt
    local data = Positions[court]
    local posList = team == "home" and data.Home3PT or data.Away3PT
    TeleportTo(posList[math.random(1, #posList)])
end)

LeftGroupbox:AddButton("TP to Paint", function()
    local team = _G.CurrentTeam
    local court = _G.CurrentCourt
    local data = Positions[court]
    local pos = team == "home" and data.HomePaint or data.AwayPaint
    TeleportTo(pos)
end)

LeftGroupbox:AddButton("TP Below Hoop", function()
    local team = _G.CurrentTeam
    local court = _G.CurrentCourt
    local data = Positions[court]
    local pos = team == "home" and data.HomeHoop or data.AwayHoop
    TeleportTo(pos)
end)

--// NO ABILITIES COOLDOWN \\--
local noCooldown = false
local hookCooldown = false

RightGroupbox:AddToggle("NoCooldown", {
    Text = "No Abilities Cooldown",
    Default = false,
    Callback = function(state)
        noCooldown = state

        if noCooldown and not hookCooldown then
            hookCooldown = true

            local mt = getrawmetatable(game)
            setreadonly(mt, false)
            local oldNamecall = mt.__namecall

            mt.__namecall = newcclosure(function(self, ...)
                local method = getnamecallmethod()
                local args = { ... }

                if method == "FireServer" and typeof(self) == "Instance" then
                    local remoteName = tostring(self)

                    -- Check if it's a cooldown remote (by name match or argument match)
                    if noCooldown and (remoteName:lower():find("cooldown") or remoteName == "AbilityCooldown") then
                        warn("[Cooldown Blocked]:", remoteName)
                        return nil
                    end
                end

                return oldNamecall(self, ...)
            end)

            setreadonly(mt, true)
            Library:Notify("✔️ Cooldown hook enabled", 3)
        elseif not noCooldown then
            Library:Notify("⚠️ Rejoin to fully remove the cooldown hook.", 5)
        end
    end
})

local CreditsTab = Window:AddTab("Credits", "sparkles")

local LeftCredits = CreditsTab:AddLeftGroupbox("Made By Swift | :)")

LeftCredits:AddLabel("Script by: Ruler Hub")
LeftCredits:AddLabel("Dev: Swift")
LeftCredits:AddLabel("UI Library: i aint tellin")
LeftCredits:AddLabel("Game: Basketball Zero")

LeftCredits:AddDivider()

LeftCredits:AddLabel("Version: v1.0.85")
LeftCredits:AddLabel("Discord: discord.gg/PnbeSdRuC9")
LeftCredits:AddLabel("Thanks for using Ruler Hub!")
LeftCredits:AddLabel("More Features Coming Soon!")

local SettingsTab = Window:AddTab("Settings", "settings")

local LeftGroupbox = SettingsTab:AddLeftGroupbox("Interface")
local RightGroupbox = SettingsTab:AddRightGroupbox("Utilities")

-- // Rejoin & Unload
LeftGroupbox:AddButton("Rejoin Server", function()
    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, game.Players.LocalPlayer)
end)

LeftGroupbox:AddButton("Copy Discord", function()
    setclipboard("https://discord.gg/PnbeSdRuC9")
end)

LeftGroupbox:AddButton("Unload Script", function()
    Library:Unload()
end)

LeftGroupbox:AddToggle("ToggleUI", {
    Text = "Toggle UI (RightShift)",
    Default = true,
    Tooltip = "Show/hide entire UI",
    Callback = function(t)
        Library:ToggleUI(t)
    end
})

-- // FPS Counter
RightGroupbox:AddToggle("FPSCounter", {
    Text = "Show FPS Counter",
    Default = false,
    Callback = function(toggled)
        if toggled then
            if not getgenv().FPSLabel then
                local fpsLabel = Drawing.new("Text")
                fpsLabel.Size = 16
                fpsLabel.Color = Color3.new(1, 1, 1)
                fpsLabel.Position = Vector2.new(10, 10)
                fpsLabel.Outline = true
                fpsLabel.Visible = true
                getgenv().FPSLabel = fpsLabel

                task.spawn(function()
                    while getgenv().FPSLabel and getgenv().FPSLabel.Visible do
                        local fps = math.floor(1 / game:GetService("RunService").RenderStepped:Wait())
                        getgenv().FPSLabel.Text = "FPS: " .. tostring(fps)
                    end
                end)
            else
                getgenv().FPSLabel.Visible = true
            end
        else
            if getgenv().FPSLabel then
                getgenv().FPSLabel.Visible = false
            end
        end
    end
})

-- // Anti-AFK
RightGroupbox:AddToggle("AntiAFK", {
    Text = "Anti-AFK",
    Default = true,
    Tooltip = "Prevents you from getting kicked",
    Callback = function(enabled)
        if enabled then
            getgenv().AntiAFKConn = game:GetService("Players").LocalPlayer.Idled:Connect(function()
                virtualUser = game:GetService("VirtualUser")
                virtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                virtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            end)
        else
            if getgenv().AntiAFKConn then
                getgenv().AntiAFKConn:Disconnect()
            end
        end
    end
})

-- // Keybind Picker
LeftGroupbox:AddKeybind("UI_Keybind", {
    Text = "UI Toggle Key",
    Default = Enum.KeyCode.RightShift,
    Callback = function(key)
        Library.Keybind = key
    end
})

-- // Save / Load Config
RightGroupbox:AddButton("Save UI Config", function()
    Library:SaveConfig("RulerHub_Settings")
end)

RightGroupbox:AddButton("Load UI Config", function()
    Library:LoadConfig("RulerHub_Settings")
end)

-- NoClip logic
game:GetService("RunService").Stepped:Connect(function()
    if noClipEnabled then
        local char = player.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end
end)

-- Infinite Jump logic
UserInputService.JumpRequest:Connect(function()
    if infJumpEnabled then
        local char = player.Character
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- WalkSpeed / JumpPower mod
game:GetService("RunService").RenderStepped:Connect(function()
    if statsEnabled then
        if player.Character then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = forcedWalkSpeed
                humanoid.JumpPower = forcedJumpPower
            end
        end
    end
end)

-- Ball Hitbox Expander Logic
game:GetService("RunService").RenderStepped:Connect(function()
    local ball = workspace:FindFirstChild(BALL_NAME, true)
    if ball and ball:IsA("BasePart") then
        if hitboxSize == 1 then
            ball.Size = Vector3.new(2.2, 2.2, 2.2) -- default size (reset)
        else
            ball.Size = Vector3.new(2.2, 2.2, 2.2) * hitboxSize
        end
        ball.CanCollide = false
        ball.Massless = true
    end
end)

-- Ball ESP logic
local ballESP = nil
game:GetService("RunService").RenderStepped:Connect(function()
    if ballESPEnabled then
        local ball = workspace:FindFirstChild(BALL_NAME, true)
        if ball then
            if not ballESP then
                ballESP = Instance.new("SelectionBox", ball)
                ballESP.Adornee = ball
                ballESP.LineThickness = 0.1
                ballESP.Color3 = Color3.fromRGB(255, 255, 0)
                ballESP.SurfaceTransparency = 0.5
            end
        elseif ballESP then
            ballESP:Destroy()
            ballESP = nil
        end
    elseif ballESP then
        ballESP:Destroy()
        ballESP = nil
    end
end)

-- Better Ball Predictor (parabolic arc preview)
local predictionParts = {}
local NUM_SEGMENTS = 20
local SEGMENT_INTERVAL = 0.12

function clearPrediction()
    for _, p in ipairs(predictionParts) do
        if p then p:Destroy() end
    end
    predictionParts = {}
end

function drawPrediction(ball)
    clearPrediction()

    local pos = ball.Position
    local vel = ball.Velocity
    local gravity = Vector3.new(0, workspace.Gravity, 0)

    for i = 1, NUM_SEGMENTS do
        local t = i * SEGMENT_INTERVAL
        local nextPos = pos + vel * t + 0.5 * gravity * (t^2)

        local part = Instance.new("Part")
        part.Size = Vector3.new(0.3, 0.3, 0.3)
        part.Shape = Enum.PartType.Ball
        part.Material = Enum.Material.Neon
        part.Color = Color3.fromRGB(0, 255, 0)
        part.Anchored = true
        part.CanCollide = false
        part.Transparency = 0.25
        part.Position = nextPos
        part.Parent = workspace

        table.insert(predictionParts, part)
    end
end

-- Ball Predictor render
game:GetService("RunService").RenderStepped:Connect(function()
    if ballPredictorEnabled and cachedBall then
        if cachedBall:IsDescendantOf(workspace) then
            drawPrediction(cachedBall)
        else
            clearPrediction()
        end
    else
        clearPrediction()
    end
end)
