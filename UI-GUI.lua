--====================================================
-- SIMPLE GLOBAL SETTINGS UI
--====================================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Prevent double UI
if PlayerGui:FindFirstChild("UCF_UI") then
	PlayerGui.UCF_UI:Destroy()
end

--====================================================
-- UI CREATION
--====================================================

local gui = Instance.new("ScreenGui")
gui.Name = "UCF_UI"
gui.ResetOnSpawn = false
gui.Parent = PlayerGui

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 260, 0, 300)
main.Position = UDim2.new(0.5, -130, 0.5, -150)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
main.BorderSizePixel = 0
main.Parent = gui

Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)

-- Dragging
do
	local dragging, dragStart, startPos
	main.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = i.Position
			startPos = main.Position
		end
	end)
	main.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)
	game:GetService("UserInputService").InputChanged:Connect(function(i)
		if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = i.Position - dragStart
			main.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end)
end

-- Title
local title = Instance.new("TextLabel")
title.Text = "Universal Combat Framework"
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.Parent = main

-- Container
local container = Instance.new("Frame")
container.Position = UDim2.new(0, 10, 0, 50)
container.Size = UDim2.new(1, -20, 1, -60)
container.BackgroundTransparency = 1
container.Parent = main

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 8)
layout.Parent = container

--====================================================
-- TOGGLE CREATOR
--====================================================

local function CreateToggle(text, globalName)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 36)
	btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	btn.Text = ""
	btn.AutoButtonColor = false
	btn.Parent = container
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

	local label = Instance.new("TextLabel")
	label.Text = text
	label.Size = UDim2.new(0.7, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.fromRGB(220, 220, 220)
	label.Font = Enum.Font.Gotham
	label.TextSize = 13
	label.TextXAlignment = Left
	label.Parent = btn

	local state = Instance.new("TextLabel")
	state.Size = UDim2.new(0.3, -10, 1, 0)
	state.Position = UDim2.new(0.7, 10, 0, 0)
	state.BackgroundTransparency = 1
	state.Font = Enum.Font.GothamBold
	state.TextSize = 13
	state.Parent = btn

	local function Refresh()
		local enabled = _G[globalName]
		state.Text = enabled and "ON" or "OFF"
		state.TextColor3 = enabled and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(255, 80, 80)
	end

	btn.MouseButton1Click:Connect(function()
		_G[globalName] = not _G[globalName]
		Refresh()
	end)

	Refresh()
end

--====================================================
-- TOGGLES (HOOKED TO G_ SETTINGS)
--====================================================

CreateToggle("No Recoil", "G_NoRecoil")
CreateToggle("No Spread", "G_NoSpread")
CreateToggle("Wall Check", "G_WallCheck")
CreateToggle("Team Check", "G_TeamCheck")
CreateToggle("Rage Aimbot", "G_Enabled")
CreateToggle("Infinite Jump", "G_InfiniteJump")

--====================================================
-- FOOTER
--====================================================

local footer = Instance.new("TextLabel")
footer.Text = "RMB = Lock | Instant Snap"
footer.Size = UDim2.new(1, 0, 0, 20)
footer.Position = UDim2.new(0, 0, 1, -20)
footer.BackgroundTransparency = 1
footer.TextColor3 = Color3.fromRGB(120, 120, 120)
footer.Font = Enum.Font.Gotham
footer.TextSize = 11
footer.Parent = main

