--// UNIVERSAL COMBAT FRAMEWORK (FULL CORE)
--// Uses external G_* globals ONLY

-- ================= SERVICES =================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local genv = getgenv()

-- ================= GLOBAL HOOK =================
genv.Framework = genv.Framework or {
	Target = nil,
	TargetPos = nil,
	IsLocked = false
}

-- ================= INPUT =================
local locking = false

UserInputService.InputBegan:Connect(function(i, g)
	if g then return end

	if i.UserInputType == Enum.UserInputType.MouseButton2 then
		locking = true
	end

	if i.KeyCode == Enum.KeyCode.Space and genv.G_InfiniteJump then
		local hum = LocalPlayer.Character
			and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		if hum then
			hum:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end
end)

UserInputService.InputEnded:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton2 then
		locking = false
	end
end)

-- ================= TARGETING =================
local function GetTarget()
	local mousePos = UserInputService:GetMouseLocation()
	local closest = genv.G_FOV
	local best = nil

	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and p.Character then
			if genv.G_TeamCheck and p.Team == LocalPlayer.Team then
				continue
			end

			local hum = p.Character:FindFirstChildOfClass("Humanoid")
			local part = p.Character:FindFirstChild(genv.G_HitPart)

			if hum and hum.Health > 0 and part then
				local screen, onScreen =
					Camera:WorldToViewportPoint(part.Position)

				if onScreen then
					local dist =
						(Vector2.new(screen.X, screen.Y) - mousePos).Magnitude

					if dist < closest then
						closest = dist
						best = part
					end
				end
			end
		end
	end

	return best
end

-- ================= ESP =================
local ESP = {}

local function CreateESP(player)
	if player == LocalPlayer then return end

	local function Setup(char)
		local head = char:WaitForChild("Head", 5)
		local root = char:WaitForChild("HumanoidRootPart", 5)
		local hum = char:WaitForChild("Humanoid", 5)
		if not head or not root or not hum then return end

		local data = {}

		-- Highlight
		if genv.G_ESP then
			local hl = Instance.new("Highlight")
			hl.FillTransparency = 1
			hl.OutlineColor = Color3.fromRGB(255, 0, 0)
			hl.Adornee = char
			hl.Parent = char
			data.Highlight = hl
		end

		-- Billboard
		local gui = Instance.new("BillboardGui")
		gui.Size = UDim2.fromOffset(200, 80)
		gui.ExtentsOffset = Vector3.new(0, 3, 0)
		gui.AlwaysOnTop = true
		gui.Adornee = root
		gui.Parent = root

		local frame = Instance.new("Frame", gui)
		frame.BackgroundTransparency = 1
		frame.Size = UDim2.fromScale(1, 1)

		local layout = Instance.new("UIListLayout", frame)
		layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

		local function Label(color)
			local l = Instance.new("TextLabel")
			l.BackgroundTransparency = 1
			l.TextStrokeTransparency = 0
			l.Font = Enum.Font.RobotoMono
			l.TextSize = 14
			l.TextColor3 = color
			l.Size = UDim2.new(1, 0, 0, 18)
			l.Parent = frame
			return l
		end

		data.Name = Label(Color3.new(1,1,1))
		data.Distance = Label(Color3.fromRGB(200,200,200))
		data.Health = Label(Color3.fromRGB(0,255,0))
		data.Gui = gui
		data.Char = char
		data.Root = root
		data.Hum = hum

		-- Head Dot
		if genv.G_HeadDots then
			local hgui = Instance.new("BillboardGui")
			hgui.Size = UDim2.fromOffset(8,8)
			hgui.AlwaysOnTop = true
			hgui.Adornee = head
			hgui.Parent = head

			local dot = Instance.new("Frame", hgui)
			dot.Size = UDim2.fromScale(1,1)
			dot.BackgroundColor3 = Color3.fromRGB(255,0,0)
			dot.BorderSizePixel = 0
			Instance.new("UICorner", dot).CornerRadius = UDim.new(1,0)

			data.HeadDot = hgui
		end

		ESP[player] = data
	end

	player.CharacterAdded:Connect(Setup)
	if player.Character then
		Setup(player.Character)
	end
end

for _, p in ipairs(Players:GetPlayers()) do
	CreateESP(p)
end
Players.PlayerAdded:Connect(CreateESP)

-- ================= MAIN LOOP =================
RunService.RenderStepped:Connect(function()
	if not genv.G_Enabled then
		genv.Framework.IsLocked = false
		return
	end

	-- Movement
	local char = LocalPlayer.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if hum then
		if genv.G_WalkSpeed then hum.WalkSpeed = genv.G_WalkSpeed end
		if genv.G_JumpPower then hum.JumpPower = genv.G_JumpPower end
	end

	-- ESP Update
	for player, esp in pairs(ESP) do
		if not esp.Char.Parent or esp.Hum.Health <= 0 then
			if esp.Gui then esp.Gui:Destroy() end
			if esp.Highlight then esp.Highlight:Destroy() end
			ESP[player] = nil
			continue
		end

		if genv.G_Names then
			esp.Name.Text = player.DisplayName
		else
			esp.Name.Text = ""
		end

		if genv.G_Distance and char and char:FindFirstChild("HumanoidRootPart") then
			esp.Distance.Text =
				math.floor(
					(esp.Root.Position - char.HumanoidRootPart.Position).Magnitude
				) .. " studs"
		else
			esp.Distance.Text = ""
		end

		if genv.G_Health then
			esp.Health.Text = "HP: " .. math.floor(esp.Hum.Health)
			esp.Health.TextColor3 =
				Color3.fromHSV((esp.Hum.Health / esp.Hum.MaxHealth) * 0.3, 1, 1)
		else
			esp.Health.Text = ""
		end
	end

	-- Aim (INSTANT SNAP)
	if not locking then
		genv.Framework.IsLocked = false
		return
	end

	local target = GetTarget()
	if target then
		local aimPos =
			target.Position +
			(target.Velocity * (genv.G_Prediction or 0))

		Camera.CFrame = CFrame.lookAt(
			Camera.CFrame.Position,
			aimPos
		)

		genv.Framework.Target = target
		genv.Framework.TargetPos = aimPos
		genv.Framework.IsLocked = true
	else
		genv.Framework.IsLocked = false
	end
end)

