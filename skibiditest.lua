-- 📦 Load Obsidian UI Library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/refs/heads/main/Library.lua"))()

-- 🎮 Variables & Services
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = game.Players.LocalPlayer
local BALL_NAME = "Basketball"

-- ⚙️ Feature Settings
local settings = {
    alwaysIn = false, aimAssist = false, curveDist = 18, curveStr = 0.37,
    fly = false, flySpeed = 50, infJump = false, noClip = false,
    stats = false, walkSpeed = 16, jumpPower = 50,
    ballSize = 3, ballTrail = false, infDribble = false
}

-- ✨ Create Window
local Window = Library:CreateWindow({
    Title = "Ruler Hub | Basketball: Zero",
    Footer = "v1.0.0",
    ToggleKeybind = Enum.KeyCode.RightShift,
    Center = true,
    AutoShow = true
})

-- 🏷️ Tabs
local mainTab = Window:AddTab("Main", "home")
local modsTab = Window:AddTab("Player Mods", "person")
local visualsTab = Window:AddTab("Visuals", "eye")
local funTab = Window:AddTab("Fun Features", "gamepad")
local creditsTab = Window:AddTab("Credits", "info")

-- 📦 Main Tab Controls
mainTab:AddSection("Main Features + OP")
mainTab:AddToggle("alwaysIn", {Text = "Always In + Aim Assist", Default = settings.alwaysIn})
    :OnChanged(function(v) settings.alwaysIn, settings.aimAssist = v, v end)
mainTab:AddSlider("curveDist", {Text="Curve Distance", Min=1, Max=100, Default=settings.curveDist, Rounding=1})
    :OnChanged(function(v) settings.curveDist = v end)
mainTab:AddSlider("curveStr", {Text="Curve Strength", Min=0, Max=1.5, Default=settings.curveStr, Rounding=0.01})
    :OnChanged(function(v) settings.curveStr = v end)
mainTab:AddButton({Text = "Teleport To Ball", Func = function()
    local ball = workspace:FindFirstChild(BALL_NAME)
    if ball and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = ball.CFrame + Vector3.new(0,3,0)
    end
end})
mainTab:AddSection("Auto Features (Unavailable)")
for _, txt in ipairs({"Auto Dribble", "Auto Dunk", "Auto Shoot", "Auto Steal"}) do
    mainTab:AddToggle(txt:gsub(" ", ""):lower(), {Text = txt.." (unavailable)", Default=false})
end

-- 📦 Player Mods Tab
modsTab:AddSection("Player Mods")
modsTab:AddToggle("noClip", {Text="NoClip", Default=settings.noClip})
modsTab:AddToggle("fly", {Text="Fly", Default=settings.fly})
modsTab:AddSlider("flySpeed", {Text="Fly Speed", Min=10, Max=200, Default=settings.flySpeed, Rounding=1})
modsTab:AddToggle("infJump", {Text="Infinite Jump", Default=settings.infJump})
modsTab:AddToggle("stats", {Text="Enable WalkSpeed/JumpPower", Default=settings.stats})
modsTab:AddSlider("walkSpeed", {Text="Set WalkSpeed", Min=1, Max=200, Default=settings.walkSpeed, Rounding=1})
modsTab:AddSlider("jumpPower", {Text="Set JumpPower", Min=1, Max=200, Default=settings.jumpPower, Rounding=1})

-- (Teleportation section omitted for brevity—could be added similarly with AddButton)

-- 📦 Visuals Tab
visualsTab:AddSection("Visual")
visualsTab:AddSlider("ballSize", {Text="Ball Hitbox Size", Min=1, Max=15, Default=settings.ballSize, Rounding=1})
visualsTab:AddButton({Text="Enable Ball Trail", Func=function() settings.ballTrail = true end})

-- 📦 Fun Features Tab
funTab:AddSection("Fun Features")
funTab:AddButton({Text="Freeze Ball", Func=function() /* freeze logic */ end})
funTab:AddButton({Text="Unfreeze Ball", Func=function() /* unfreeze logic */ end})
funTab:AddToggle("infDribble", {Text="Inf Dribble (Beta)", Default=settings.infDribble})

-- 📦 Credits Tab
creditsTab:AddSection("Credits")
creditsTab:AddButton({Text="Copy Discord Link", Func=function()
    if setclipboard then setclipboard("https://discord.gg/PnbeSdRuC9") end
end})

-- 🌐 Feature Loop Implementation
RunService.Stepped:Connect(function()
    if settings.noClip and player.Character then
        for _, part in ipairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)
RunService.Heartbeat:Connect(function()
    -- Fly
    if settings.fly and player.Character then
        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            if not hrp:FindFirstChild("FlyBG") then
                local bg = Instance.new("BodyGyro", hrp); bg.Name="FlyBG"; bg.MaxTorque=Vector3.new(1e5,1e5,1e5)
                local bv = Instance.new("BodyVelocity", hrp); bv.Name="FlyBV"; bv.MaxForce=bg.MaxTorque
            end
            local bg, bv = hrp.FlyBG, hrp.FlyBV
            local cam = workspace.CurrentCamera
            local move = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then move+=cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then move-=cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then move-=cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then move+=cam.CFrame.RightVector end
            bg.CFrame = cam.CFrame
            bv.Velocity = (move.Magnitude > 0 and move.Unit * settings.flySpeed) or Vector3.new()
        else
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart"):FindFirstChild("FlyBG") then
                player.Character.HumanoidRootPart.FlyBG:Destroy()
                player.Character.HumanoidRootPart.FlyBV:Destroy()
            end
        end
    end
    -- Infinite Jump
    settings.infJump = settings.infJump -- referenced in Input?
end)
UserInputService.JumpRequest:Connect(function()
    if settings.infJump and player.Character then
        player.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)
RunService.RenderStepped:Connect(function()
    if settings.stats and player.Character then
        local hum = player.Character:FindFirstChildOfClass("Humanoid")
        hum.WalkSpeed = settings.walkSpeed
        hum.JumpPower = settings.jumpPower
    end
end)

-- 🎯 Aim Assist / Always In Loop (simplified)
spawn(function()
    while true do
        if settings.aimAssist then
            local ball = workspace:FindFirstChild(BALL_NAME)
            if ball and ball.Velocity.Magnitude > 1 then
                local hoops = {}
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj.Name:lower()=="hoop" and obj:IsA("BasePart") then table.insert(hoops,obj) end
                end
                local closest,dist = nil, math.huge
                for _,h in ipairs(hoops) do
                    local d = (h.Position - ball.Position).Magnitude
                    if d < dist then closest,dist = h,d end
                end
                if closest and dist < settings.curveDist then
                    ball.Velocity = ball.Velocity:Lerp((closest.Position - ball.Position).Unit * ball.Velocity.Magnitude, settings.curveStr)
                    if settings.alwaysIn and dist < (closest.Size.Magnitude/2+ball.Size.Magnitude/2+2) then
                        ball.CFrame = CFrame.new(closest.Position + Vector3.new(0,closest.Size.Y/2+ball.Size.Y/2+2,0))
                        ball.Velocity = Vector3.new(0,-20,0)
                        task.wait(1)
                    end
                end
            end
        end
        task.wait(0.05)
    end
end)
