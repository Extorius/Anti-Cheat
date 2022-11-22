-- Extorius Anti-Cheat
repeat
    task.wait()
until game:IsLoaded()

-- // Banning System
if not isfolder("Extorius Anti Cheat") then
    makefolder("Extorius Anti Cheat")
end
if not isfolder("Extorius Anti Cheat/Games") then
    makefolder("Extorius Anti Cheat/Games")
end
if not isfile("Extorius Anti Cheat/Games/" .. tostring(game.PlaceId) .. ".txt") then
    writefile("Extorius Anti Cheat/Games/" .. tostring(game.PlaceId) .. ".txt", "false")
else
    if readfile("Extorius Anti Cheat/Games/" .. tostring(game.PlaceId) .. ".txt") == "true" then
        game:GetService("Players").LocalPlayer:Kick("Banned from this game by Extorius Anti Cheat")
    end
end

-- // Services
local HideInHere = {
    ["HideInHere1"] = game:GetService("MessageBusService"),
    ["HideInHere2"] = game:GetService("AvatarEditorService"),
    ["HideInHere3"] = game:GetService("VideoCaptureService"),
    ["HideInHere4"] = game:GetService("ScriptRegistrationService"),
    ["HideInHere5"] = game:GetService("FaceAnimatorService")
}
local Services = {
    ["Workspace"] = game:GetService("Workspace"),
    ["Players"] = game:GetService("Players"),
    ["CoreGui"] = game:GetService("CoreGui"),
    ["ReplicatedStorage"] = game:GetService("ReplicatedStorage"),
    ["Lighting"] = game:GetService("Lighting"),
    ["Debris"] = game:GetService("Debris")
}

HideInHere["HideInHere1"].Name = "Workspace"
HideInHere["HideInHere2"].Name = "CoreGui"
HideInHere["HideInHere3"].Name = "Players"
HideInHere["HideInHere4"].Name = "Lighting"
HideInHere["HideInHere5"].Name = "Debris"
for i, v in pairs(Services) do
    v.Name = " "
end

local function Kick(reason)
    Services["Players"].LocalPlayer:Kick("\nKicked by Extorius Anti-Cheat\nReason: " .. reason)
end
local function Ban(reason)
    Services["Players"].LocalPlayer:Kick("\nBanned by Extorius Anti-Cheat\nReason: " .. reason)
    writefile("Extorius Anti Cheat/Games/" .. tostring(game.PlaceId) .. ".txt", "true")
end
local function AddedTrap()
    Ban("Attempt to add child / descendant to a instance.")
end
local function ChangedTrap()
    Ban("Attempt to change / spoof a instance's properties.")
end

for i, v in pairs(HideInHere) do
    v.Changed:Connect(ChangedTrap)
    v.ChildAdded:Connect(AddedTrap)
    v.DescendantAdded:Connect(AddedTrap)
end

-- // Local Player
local LocalPlayer = Services["Players"].LocalPlayer
local CanCheckHumanoid = false
local CanCheckRootPart = false
spawn(
    function()
        while task.wait() do
            if LocalPlayer.Character then
                CanCheckHumanoid = true
                CanCheckRootPart = true
                LocalPlayer.Character.Changed:Connect(
                    function(property)
                        if property == "Parent" then
                            if LocalPlayer.Character.Parent ~= nil then
                                ChangedTrap()
                            end
                        else
                            ChangedTrap()
                        end
                    end
                )
            else
                CanCheckHumanoid = false
                CanCheckRootPart = false
            end
        end
    end
)
spawn(
    function()
        while CanCheckHumanoid and task.wait() do
            if not LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
                Ban("Humanoid was removed.")
            else
                LocalPlayer.Character:FindFirstChild("Humanoid").Changed:Connect(
                    function(property)
                        if property == "WalkSpeed" then
                            Ban("Changing WalkSpeed.")
                        elseif property == "JumpPower" then
                            Ban("Changing JumpPower.")
                        elseif property == "HipHeight" then
                            Ban("Changing HipHeight.")
                        elseif property == "PlatformStand" then
                            Ban("Fly cheat detected.")
                        elseif property == "Name" then
                            Ban("Attaching cheat detected.")
                        elseif property == "WalkToPart" or property == "WalkToPoint" then
                            Ban("Automatic walking detected.")
                        end
                    end
                )
            end
        end
    end
)
spawn(
    function()
        while CanCheckRootPart and task.wait() do
            if LocalPlayer.Character:FindFirstChild("HumanoidRootPart") == nil then
                Ban("RootPart was removed.")
            else
                LocalPlayer.Character:FindFirstChild("HumanoidRootPart").Changed:Connect(
                    function(property)
                        if property == "Size" then
                            Kick("Possible kill script detected.")
                        end
                    end
                )
            end
        end
    end
)
LocalPlayer.CharacterAdded:Connect(
    function(Character)
        game:GetService("RunService").Heartbeat:Wait()
        local lastPos = nil
        local s
        s =
            game:GetService("RunService").Heartbeat:Connect(
            function()
                if not Character then
                    s:Disconnect()
                    return
                end
                if lastPos == nil then
                    lastPos = Character.HumanoidRootPart.Position
                end
                if (Character.HumanoidRootPart.Position - lastPos).Magnitude >= 10 then
                    Kick("Teleport cheat detected.")
                end
                lastPos = Character.HumanoidRootPart.Position
            end
        )
    end
)

-- // Remote Events
local LoggedRemotes = 0
local namecall
namecall =
    hookmetamethod(
    game,
    "__namecall",
    function(calledon, ...)
        local method = getnamecallmethod()
        local args = {...}
        local args2 = args[2]
        if method == "FireServer" or method == "InvokeServer" then
            LoggedRemotes = LoggedRemotes + 1
            if LoggedRemotes <= 30 then
                return namecall(calledon, ...)
            elseif LoggedRemotes >= 50 then
                Kick("Too many remotes invoked / fired.")
            end
        else
            return namecall(calledon, ...)
        end
    end
)
spawn(
    function()
        while task.wait(60) do
            LoggedRemotes = 0
        end
    end
)

-- // Auto-Clicker
local LoggedClicks = 0
LocalPlayer:GetMouse().Button1Down:Connect(
    function()
        LoggedClicks = LoggedClicks + 1
        if LoggedClicks >= 12 then
            Kick("Auto Clicker detected.")
        end
    end
)

spawn(
    function()
        while task.wait(1) do
            LoggedClicks = 0
        end
    end
)

-- // Detecting Guis
-- Currently working on this, as all of my methods have been easily bypassable and resulted in false-positives.

-- // FPS Unlockers
local FPS=0
game:GetService("RunService").RenderStepped:Connect(
    function()
    	FPS=FPS+1
    	if FPS>=65 then
    		Kick("FPS Unlocker detected.")
		end
    end
)

spawn(function()
	while task.wait(1)do
		FPS=0
	end
end)
