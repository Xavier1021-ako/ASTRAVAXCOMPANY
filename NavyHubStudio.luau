-- Navy Hub - Roblox Studio Edition
-- LocalScript: StarterPlayer > StarterPlayerScripts

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local character, humanoid, rootPart
local states = {NoClip=false, InfiniteJump=false, VoidEmperor=false, VoidFlight=false, VoidAbility=false}
local buttons = {}
local flightSpeed = 6

local function setupCharacter(char)
	character = char
	humanoid = char:WaitForChild("Humanoid")
	rootPart = char:WaitForChild("HumanoidRootPart")
end
if player.Character then setupCharacter(player.Character) end
player.CharacterAdded:Connect(setupCharacter)

local old = playerGui:FindFirstChild("NavyHub")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "NavyHub"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.fromOffset(250,330)
main.Position = UDim2.new(0,25,0.5,-165)
main.BackgroundColor3 = Color3.fromRGB(8,10,18)
main.BackgroundTransparency = .08
main.BorderSizePixel = 0
main.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0,10)
corner.Parent = main
local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(105,70,255)
stroke.Thickness = 1.5
stroke.Parent = main

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,-20,0,45)
title.Position = UDim2.fromOffset(10,5)
title.BackgroundTransparency = 1
title.Text = "Navy Hub"
title.TextColor3 = Color3.fromRGB(235,235,255)
title.TextSize = 22
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = main

local container = Instance.new("Frame")
container.Name = "Buttons"
container.Size = UDim2.new(1,-20,1,-60)
container.Position = UDim2.fromOffset(10,52)
container.BackgroundTransparency = 1
container.Parent = main

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0,7)
layout.Parent = container

local function createButton(name, order)
	local b = Instance.new("TextButton")
	b.Name=name
	b.Size=UDim2.new(1,0,0,43)
	b.BackgroundColor3=Color3.fromRGB(18,20,32)
	b.BorderSizePixel=0
	b.Text=name.."  [OFF]"
	b.TextColor3=Color3.fromRGB(220,220,235)
	b.TextSize=14
	b.Font=Enum.Font.GothamMedium
	b.AutoButtonColor=false
	b.LayoutOrder=order
	b.Parent=container
	local c=Instance.new("UICorner")
	c.CornerRadius=UDim.new(0,7)
	c.Parent=b
	local s=Instance.new("UIStroke")
	s.Color=Color3.fromRGB(55,55,80)
	s.Parent=b
	buttons[name]=b
	return b
end

local function setState(name, enabled)
	states[name]=enabled
	local b=buttons[name]
	b.Text=name..(enabled and "  [ON]" or "  [OFF]")
	b.BackgroundColor3=enabled and Color3.fromRGB(45,35,75) or Color3.fromRGB(18,20,32)
end

local noClip=createButton("NoClip",1)
local infiniteJump=createButton("Infinite Jump",2)
local emperor=createButton("VoidEmperor",3)
local flight=createButton("Void Flight",4)
local ability=createButton("Void Ability",5)

noClip.MouseButton1Click:Connect(function() setState("NoClip",not states.NoClip) end)
RunService.Stepped:Connect(function()
	if states.NoClip and character then
		for _,v in ipairs(character:GetDescendants()) do
			if v:IsA("BasePart") then v.CanCollide=false end
		end
	end
end)

infiniteJump.MouseButton1Click:Connect(function() setState("Infinite Jump",not states.InfiniteJump) end)
UserInputService.JumpRequest:Connect(function()
	if states.InfiniteJump and humanoid then humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
end)

emperor.MouseButton1Click:Connect(function()
	setState("VoidEmperor",not states.VoidEmperor)
	if humanoid then humanoid.WalkSpeed=states.VoidEmperor and 24 or 16 end
end)

local flightConnection
local function stopFlight()
	if flightConnection then flightConnection:Disconnect(); flightConnection=nil end
	if humanoid then humanoid.PlatformStand=false end
end
local function startFlight()
	stopFlight()
	flightConnection=RunService.RenderStepped:Connect(function()
		if not states.VoidFlight or not rootPart or not humanoid then return end
		humanoid.PlatformStand=true
		local camera=workspace.CurrentCamera
		local direction=Vector3.zero
		if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction+=camera.CFrame.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction-=camera.CFrame.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction-=camera.CFrame.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction+=camera.CFrame.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then direction+=Vector3.yAxis end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then direction-=Vector3.yAxis end
		rootPart.AssemblyLinearVelocity=direction.Magnitude>0 and direction.Unit*(flightSpeed*10) or Vector3.zero
	end)
end
flight.MouseButton1Click:Connect(function()
	setState("Void Flight",not states.VoidFlight)
	if states.VoidFlight then startFlight() else stopFlight() end
end)

ability.MouseButton1Click:Connect(function()
	setState("Void Ability",not states.VoidAbility)
end)

player.CharacterAdded:Connect(function(char)
	setupCharacter(char)
	if states.VoidFlight then task.wait(.5); startFlight() end
end)
