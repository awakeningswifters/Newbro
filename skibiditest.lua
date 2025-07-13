local player = game.Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/refs/heads/main/Library.lua"))()

local Window = Library:CreateWindow({
    Title = "Ruler Hub | New UI",
    Footer = "v1.0.8 by Swift | UI by deividsleepy (creator of ui) ",
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
local hoopAimbotEnabled = false
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

-- New features UI
LeftGroupbox:AddToggle("BallPredictor", {
    Text = "Ball Predictor",
    Default = false,
    Tooltip = "Shows the predicted landing spot of the ball",
    Callback = function(Value)
        ballPredictorEnabled = Value
    end
})
LeftGroupbox:AddToggle("BallESP", {
    Text = "Ball ESP",
    Default = false,
    Tooltip = "Highlights the ball",
    Callback = function(Value)
        ballESPEnabled = Value
    end
})
LeftGroupbox:AddToggle("HoopAimbot", {
    Text = "Hoop Aimbot",
    Default = false,
    Tooltip = "Automatically aims your shots at the nearest hoop",
    Callback = function(Value)
        hoopAimbotEnabled = Value
    end
})
LeftGroupbox:AddToggle("BallMagnet", {
    Text = "Ball Magnet",
    Default = false,
    Tooltip = "Pulls the ball toward you",
    Callback = function(Value)
        ballMagnetEnabled = Value
    end
})

-- Fly
local FlyToggle = LeftGroupbox:AddToggle("Fly", {
    Text = "Fly",
    Default = false,
    Callback = function(Value)
        flyEnabled = Value
    end
})

local FlySpeedSlider = LeftGroupbox:AddSlider("FlySpeed", {
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
local InfJumpToggle = LeftGroupbox:AddToggle("InfJump", {
    Text = "Infinite Jump",
    Default = false,
    Callback = function(Value)
        infJumpEnabled = Value
    end
})

-- NoClip
local NoClipToggle = LeftGroupbox:AddToggle("NoClip", {
    Text = "NoClip",
    Default = false,
    Callback = function(Value)
        noClipEnabled = Value
    end
})

-- WalkSpeed/JumpPower
local StatsToggle = LeftGroupbox:AddToggle("StatMods", {
    Text = "WalkSpeed/JumpPower Mod",
    Default = false,
    Callback = function(Value)
        statsEnabled = Value
    end
})

local WalkSpeedSlider = LeftGroupbox:AddSlider("WalkSpeed", {
    Text = "WalkSpeed",
    Default = 16,
    Min = 5,
    Max = 200,
    Rounding = 1,
    Callback = function(Value)
        forcedWalkSpeed = Value
    end
})

local JumpPowerSlider = LeftGroupbox:AddSlider("JumpPower", {
    Text = "JumpPower",
    Default = 50,
    Min = 10,
    Max = 200,
    Rounding = 1,
    Callback = function(Value)
        forcedJumpPower = Value
    end
})

local HitboxSlider = LeftGroupbox:AddSlider("HitboxSize", {
    Text = "Ball Hitbox Size",
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

local AutoShootToggle = RightGroupbox:AddToggle("AutoShoot", {
    Text = "Auto Shoot (unavailable)",
    Default = false,
    Callback = function(v)
        autoShootEnabled = v
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

local AutoBlockToggle = RightGroupbox:AddToggle("AutoBlock", {
    Text = "Auto Block (unavailable)",
    Default = false,
    Callback = function(v)
        autoBlockEnabled = v
    end
})

local AutoScoreToggle = RightGroupbox:AddToggle("AutoDunk", {
    Text = "Auto Dunk (unavailable)",
    Default = false,
    Callback = function(v)
        autoDunkEnabled = v
    end
})

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

-- Fly logic
local flyBodyGyro, flyBodyVel
game:GetService("RunService").Heartbeat:Connect(function()
    if flyEnabled then
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        if hrp and humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Physics)
            if not flyBodyGyro then
                flyBodyGyro = Instance.new("BodyGyro", hrp)
                flyBodyGyro.P = 9e4
                flyBodyGyro.MaxTorque = Vector3.new(9e4, 9e4, 9e4)
            end
            if not flyBodyVel then
                flyBodyVel = Instance.new("BodyVelocity", hrp)
                flyBodyVel.MaxForce = Vector3.new(9e4, 9e4, 9e4)
            end
            local cam = workspace.CurrentCamera
            local moveVec = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVec += cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVec -= cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVec -= cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVec += cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveVec += Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveVec -= Vector3.new(0,1,0) end
            flyBodyVel.Velocity = moveVec.Magnitude > 0 and moveVec.Unit * flySpeed or Vector3.new()
            flyBodyGyro.CFrame = cam.CFrame
        end
    else
        if flyBodyGyro then flyBodyGyro:Destroy(); flyBodyGyro = nil end
        if flyBodyVel then flyBodyVel:Destroy(); flyBodyVel = nil end
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

local RunService = game:GetService("RunService")
local player = game.Players.LocalPlayer

-- Enable/Disable the HRP Hoop Aimbot
local hrpAimbotEnabled = true

RunService.Heartbeat:Connect(function()
    if not hrpAimbotEnabled then return end

    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    -- Find farthest hoop
    local farthestHoop = nil
    local maxDist = 0

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name:lower() == "hoop" then
            local dist = (obj.Position - hrp.Position).Magnitude
            if dist > maxDist then
                maxDist = dist
                farthestHoop = obj
            end
        end
    end

    -- Rotate HRP to face farthest hoop
    if farthestHoop then
        local lookVector = (farthestHoop.Position - hrp.Position).Unit
        local flatLook = Vector3.new(lookVector.X, 0, lookVector.Z).Unit
        local newCF = CFrame.new(hrp.Position, hrp.Position + flatLook)
        hrp.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(0, math.atan2(flatLook.X, flatLook.Z), 0)
    end
end)

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
