-- 📦 Load Obsidian UI
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/refs/heads/main/Library.lua"))()

-- 🔧 Services & Variables
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = game.Players.LocalPlayer
local BALL = "Basketball"

-- 🧩 Settings
local settings = {
    alwaysIn = false,
    curveDist = 18,
    curveStr = 0.37,
    fly = false,
    flySpeed = 50,
    infJump = false,
    noClip = false,
    stats = false,
    walkSpeed = 16,
    jumpPower = 50,
}

-- 🚀 Setup Window
local Window = Library:CreateWindow({
    Title = "Ruler Hub | Basketball: Zero",
    ToggleKeybind = Enum.KeyCode.RightShift,
    Center = true,
    AutoShow = true
})

-- ✅ Tabs & Elements
local mainTab = Window:AddTab("Main", "home")
mainTab:AddSection("Gameplay Enhancements")
mainTab:AddToggle("alwaysIn", {
    Text = "Always In + Aim Assist",
    Default = settings.alwaysIn,
    Callback = function(v) settings.alwaysIn = v end
})
mainTab:AddSlider("curveDist", {
    Text = "Curve Distance",
    Min = 1,
    Max = 100,
    Default = settings.curveDist,
    Callback = function(v) settings.curveDist = v end
})
mainTab:AddSlider("curveStr", {
    Text = "Curve Strength",
    Min = 0,
    Max = 1,
    Default = settings.curveStr,
    Rounding = 0.01,
    Callback = function(v) settings.curveStr = v end
})
mainTab:AddButton({
    Text = "Teleport To Ball",
    Func = function()
        local ball = workspace:FindFirstChild(BALL)
        if ball and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = ball.CFrame + Vector3.new(0, 3, 0)
        end
    end
})

local modsTab = Window:AddTab("Player Mods", "person")
modsTab:AddToggle("noClip", {
    Text = "NoClip",
    Default = settings.noClip,
    Callback = function(v) settings.noClip = v end
})
modsTab:AddToggle("fly", {
    Text = "Fly",
    Default = settings.fly,
    Callback = function(v) settings.fly = v end
})
modsTab:AddSlider("flySpeed", {
    Text = "Fly Speed",
    Min = 10,
    Max = 200,
    Default = settings.flySpeed,
    Callback = function(v) settings.flySpeed = v end
})
modsTab:AddToggle("infJump", {
    Text = "Infinite Jump",
    Default = settings.infJump,
    Callback = function(v) settings.infJump = v end
})
modsTab:AddToggle("stats", {
    Text = "Enable Walk/Jump",
    Default = settings.stats,
    Callback = function(v) settings.stats = v end
})
modsTab:AddSlider("walkSpeed", {
    Text = "Set WalkSpeed",
    Min = 1,
    Max = 200,
    Default = settings.walkSpeed,
    Callback = function(v) settings.walkSpeed = v end
})
modsTab:AddSlider("jumpPower", {
    Text = "Set JumpPower",
    Min = 1,
    Max = 200,
    Default = settings.jumpPower,
    Callback = function(v) settings.jumpPower = v end
})

local visualsTab = Window:AddTab("Visuals", "eye")
visualsTab:AddSection("Placeholder; expand as needed")

local funTab = Window:AddTab("Fun Features", "gamepad")
funTab:AddSection("Placeholder; expand as needed")

local creditsTab = Window:AddTab("Credits", "info")
creditsTab:AddButton({
    Text = "Copy Discord Link",
    Func = function()
        if setclipboard then setclipboard("https://discord.gg/PnbeSdRuC9") end
    end
})

-- 🔁 Feature Loops
RunService.Stepped:Connect(function()
    if settings.noClip and player.Character then
        for _, p in ipairs(player.Character:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end
end)

-- Fly Mechanic
local flyBG, flyBV
RunService.Heartbeat:Connect(function()
    if settings.fly and player.Character then
        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            if not hrp:FindFirstChild("FlyBG") then
                flyBG = Instance.new("BodyGyro", hrp); flyBG.Name = "FlyBG"; flyBG.MaxTorque = Vector3.new(1e5,1e5,1e5)
                flyBV = Instance.new("BodyVelocity", hrp); flyBV.Name = "FlyBV"; flyBV.MaxForce = flyBG.MaxTorque
            end
            local cam = workspace.CurrentCamera
            local dir = Vector3.new(
                (UserInputService:IsKeyDown(Enum.KeyCode.D) and cam.CFrame.RightVector or Vector3.new()) +
                (UserInputService:IsKeyDown(Enum.KeyCode.A) and -cam.CFrame.RightVector or Vector3.new()) +
                (UserInputService:IsKeyDown(Enum.KeyCode.W) and cam.CFrame.LookVector or Vector3.new()) +
                (UserInputService:IsKeyDown(Enum.KeyCode.S) and -cam.CFrame.LookVector or Vector3.new())
            )
            flyBG.CFrame = cam.CFrame
            flyBV.Velocity = (dir.Magnitude > 0 and dir.Unit * settings.flySpeed) or Vector3.new()
        elseif flyBG then
            flyBG:Destroy(); flyBG, flyBV = nil, nil
        end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if settings.infJump and player.Character then
        local hum = player.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

RunService.RenderStepped:Connect(function()
    if settings.stats and player.Character then
        local hum = player.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = settings.walkSpeed
            hum.JumpPower = settings.jumpPower
        end
    end
end)

-- Always-In + Aim Assist
spawn(function()
    while true do
        if settings.alwaysIn then
            local ball = workspace:FindFirstChild(BALL)
            if ball and ball.Velocity.Magnitude > 1 then
                local closestHoop, dist = nil, math.huge
                for _, part in ipairs(workspace:GetDescendants()) do
                    if part:IsA("BasePart") and part.Name:lower():find("hoop") then
                        local d = (part.Position - ball.Position).Magnitude
                        if d < dist then dist, closestHoop = d, part end
                    end
                end
                if closestHoop and dist < settings.curveDist then
                    ball.Velocity = ball.Velocity:Lerp((closestHoop.Position - ball.Position).Unit * ball.Velocity.Magnitude, settings.curveStr)
                    if dist < 5 then -- small threshold
                        ball.CFrame = CFrame.new(closestHoop.Position + Vector3.new(0, closestHoop.Size.Y/2 + ball.Size.Y/2 +2, 0))
                        ball.Velocity = Vector3.new(0, -20, 0)
                    end
                end
            end
        end
        task.wait(0.05)
    end
end)
