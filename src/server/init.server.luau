local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local PETS = {
	{ name = "Moss Mite", rarity = "Common", weight = 55, income = 1 },
	{ name = "Comet Kit", rarity = "Rare", weight = 28, income = 5 },
	{ name = "Nebula Fox", rarity = "Epic", weight = 13, income = 20 },
	{ name = "Solar Dragon", rarity = "Legendary", weight = 4, income = 100 },
}

local RARITY_COLORS = {
	Common = Color3.fromRGB(155, 162, 169),
	Rare = Color3.fromRGB(55, 145, 255),
	Epic = Color3.fromRGB(168, 82, 230),
	Legendary = Color3.fromRGB(255, 205, 48),
}

local COOLDOWN_SECONDS = 1.5
local random = Random.new()
local lastUseAt = {}
local plots = {}
local playerPlots = {}
local initializedPlayers = {}
local selectedPets = {}
local slotByPrompt = {}
local arena

local petAwarded = ReplicatedStorage:FindFirstChild("PetAwarded")
if not petAwarded then
	petAwarded = Instance.new("RemoteEvent")
	petAwarded.Name = "PetAwarded"
	petAwarded.Parent = ReplicatedStorage
end

local selectPet = ReplicatedStorage:FindFirstChild("SelectPet")
if not selectPet then
	selectPet = Instance.new("RemoteEvent")
	selectPet.Name = "SelectPet"
	selectPet.Parent = ReplicatedStorage
end

local function getInventory(player)
	local inventory = player:FindFirstChild("PetInventory")
	if not inventory then
		inventory = Instance.new("Folder")
		inventory.Name = "PetInventory"
		inventory.Parent = player
	end

	return inventory
end

local function findOpenHotbarSlot(inventory)
	local occupiedSlots = {}
	for _, petEntry in inventory:GetChildren() do
		if petEntry:IsA("StringValue") and not petEntry:GetAttribute("Placed") then
			local slotNumber = petEntry:GetAttribute("HotbarSlot")
			if typeof(slotNumber) == "number" and slotNumber >= 1 and slotNumber <= 7 then
				occupiedSlots[slotNumber] = true
			end
		end
	end

	for slotNumber = 1, 7 do
		if not occupiedSlots[slotNumber] then
			return slotNumber
		end
	end
	return nil
end

selectPet.OnServerEvent:Connect(function(player, petName)
	if typeof(petName) ~= "string" then
		return
	end

	local petEntry = getInventory(player):FindFirstChild(petName)
	if not petEntry or not petEntry:IsA("StringValue") or petEntry:GetAttribute("Placed") then
		return
	end

	selectedPets[player] = petEntry
	player:SetAttribute("SelectedPet", petEntry.Name)
end)

local function choosePet()
	local totalWeight = 0
	for _, pet in PETS do
		totalWeight += pet.weight
	end

	local roll = random:NextInteger(1, totalWeight)
	for _, pet in PETS do
		roll -= pet.weight
		if roll <= 0 then
			return pet
		end
	end

	return PETS[1]
end

local function createPart(parent, name, size, position, color, material, transparency)
	local part = Instance.new("Part")
	part.Name = name
	part.Anchored = true
	part.Size = size
	part.Position = position
	part.Color = color
	part.Material = material or Enum.Material.SmoothPlastic
	part.Transparency = transparency or 0
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent
	return part
end

local function createPetTool(player, petEntry)
	local backpack = player:WaitForChild("Backpack")
	local rarity = petEntry:GetAttribute("Rarity") or "Common"
	local tool = Instance.new("Tool")
	tool.Name = petEntry.Name
	tool.ToolTip = petEntry.Value
	tool.RequiresHandle = true
	tool.CanBeDropped = false
	tool:SetAttribute("PetEntryName", petEntry.Name)

	local handle = Instance.new("Part")
	handle.Name = "Handle"
	handle.Shape = Enum.PartType.Ball
	handle.Size = Vector3.new(1.15, 1.15, 1.15)
	handle.Color = RARITY_COLORS[rarity] or RARITY_COLORS.Common
	handle.Material = Enum.Material.Neon
	handle.Anchored = false
	handle.CanCollide = false
	handle.Massless = true
	handle.Parent = tool

	local label = Instance.new("BillboardGui")
	label.Name = "PetName"
	label.Size = UDim2.fromOffset(130, 28)
	label.StudsOffset = Vector3.new(0, 1.1, 0)
	label.AlwaysOnTop = true
	label.Parent = handle

	local text = Instance.new("TextLabel")
	text.Size = UDim2.fromScale(1, 1)
	text.BackgroundTransparency = 1
	text.Font = Enum.Font.GothamBold
	text.Text = petEntry.Value
	text.TextColor3 = Color3.new(1, 1, 1)
	text.TextScaled = true
	text.TextStrokeTransparency = 0.3
	text.Parent = label

	tool.Parent = backpack
	return tool
end

local function removePetTool(player, petEntry)
	for _, container in { player:FindFirstChildOfClass("Backpack"), player.Character } do
		if container then
			for _, child in container:GetChildren() do
				if child:IsA("Tool") and child:GetAttribute("PetEntryName") == petEntry.Name then
					child:Destroy()
				end
			end
		end
	end
end

local function makePrompt(parent, name, action, object, holdDuration)
	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = name
	prompt.ActionText = action
	prompt.ObjectText = object
	prompt.KeyboardKeyCode = Enum.KeyCode.E
	prompt.GamepadKeyCode = Enum.KeyCode.ButtonY
	prompt.HoldDuration = holdDuration
	prompt.MaxActivationDistance = 10
	prompt.Parent = parent
	return prompt
end

local function findNearestPlot(position)
	local nearestPlot
	local nearestDistance = math.huge
	for _, candidate in plots do
		local distance = (candidate.center - position).Magnitude
		if distance < nearestDistance then
			nearestPlot = candidate
			nearestDistance = distance
		end
	end
	return nearestPlot, nearestDistance
end

local function createMachine(parent, plot)
	local machine = parent:WaitForChild("ClawMachine")
	local button = machine:WaitForChild("PlayButton")
	local prompt = button:FindFirstChild("UseClawMachine")
	if not prompt then
		prompt = makePrompt(button, "UseClawMachine", "Get a Pet", "Claw Machine", 0)
	end
	prompt.HoldDuration = 0
	print("Claw prompt ready:", plot.model.Name, "HoldDuration:", prompt.HoldDuration)

	prompt.Triggered:Connect(function(player)
		local interactionPlot, distance = findNearestPlot(button.Position)
		interactionPlot = interactionPlot or plot
		print("Claw prompt triggered:", player.Name, plot.model.Name, "resolved:", interactionPlot.model.Name, "distance:", distance)
		if interactionPlot.owner ~= player then
			warn("Claw prompt rejected: base owner mismatch", player.Name, interactionPlot.model.Name, interactionPlot.owner and interactionPlot.owner.Name or "unowned")
			return
		end
		playerPlots[player] = interactionPlot

		local now = os.clock()
		if now - (lastUseAt[player] or 0) < COOLDOWN_SECONDS then
			return
		end

		lastUseAt[player] = now
		local inventory = getInventory(player)
		local pet = choosePet()
		local petEntry = Instance.new("StringValue")
		petEntry.Name = string.format("Pet%03d", #inventory:GetChildren() + 1)
		petEntry.Value = pet.name
		petEntry:SetAttribute("Rarity", pet.rarity)
		petEntry:SetAttribute("IncomePerSecond", pet.income)
		petEntry:SetAttribute("Placed", false)
		petEntry:SetAttribute("HotbarSlot", findOpenHotbarSlot(inventory))
		petEntry.Parent = inventory
		createPetTool(player, petEntry)
		print("Claw pet awarded:", player.Name, pet.name, pet.rarity)

		petAwarded:FireClient(player, pet.name, pet.rarity, #inventory:GetChildren(), pet.income)
	end)
end

local function createOwnerLabel(plot, displayName)
	local sign = createPart(plot.model, "OwnerSign", Vector3.new(1, 1, 1), plot.center + Vector3.new(0, 14, 10), Color3.new(1, 1, 1), Enum.Material.SmoothPlastic, 1)
	sign.CanCollide = false
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "OwnerLabel"
	billboard.Size = UDim2.fromOffset(300, 56)
	billboard.StudsOffset = Vector3.new(0, 1.5, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = sign
	local label = Instance.new("TextLabel")
	label.Name = "Text"
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundColor3 = Color3.fromRGB(35, 43, 44)
	label.BackgroundTransparency = 0.12
	label.Font = Enum.Font.GothamBold
	label.Text = displayName .. "'s Base"
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextScaled = true
	label.Parent = billboard
	return sign
end

local function createPlot(model, index)
	local baseFloor = model:WaitForChild("BaseFloor")
	local machineMarker = model:WaitForChild("MachineMarker")
	local center = Vector3.new(baseFloor.Position.X, 0, baseFloor.Position.Z)
	local existingSign = model:FindFirstChild("OwnerSign")
	if existingSign then
		existingSign:Destroy()
	end
	local plot = {
		model = model,
		center = center,
		spawnCFrame = baseFloor.CFrame * CFrame.new(0, 4, 8),
		owner = nil,
		ownerSign = nil,
		slots = {},
	}
	createMachine(model, plot)

	local pads = {}
	for _, child in model:GetChildren() do
		if child:IsA("BasePart") and child.Name:match("^PetSlot%d+$") then
			table.insert(pads, child)
		end
	end
	table.sort(pads, function(left, right)
		return left.Name < right.Name
	end)
	for _, pad in pads do
		local prompt = makePrompt(pad, "PlacePet", "Place Pet", "Empty Slot", 0.25)
		local slot = { plot = plot, position = pad.Position, prompt = prompt, petEntry = nil, display = nil }
		table.insert(plot.slots, slot)
		slotByPrompt[prompt] = slot
	end

	return plot
end

arena = Workspace:WaitForChild("PetArena")
for index = 1, 6 do
	local model = arena:WaitForChild(string.format("PlayerBase%d", index))
	table.insert(plots, createPlot(model, index))
end

local function retrievePlacedPet(player, slot)
	local petEntry = slot.petEntry
	if not petEntry then
		return
	end

	local inventory = getInventory(player)
	slot.petEntry = nil
	petEntry:SetAttribute("HotbarSlot", findOpenHotbarSlot(inventory))
	petEntry:SetAttribute("Placed", false)
	if slot.display then
		slot.display:Destroy()
		slot.display = nil
	end
	slot.retrievePrompt = nil
	slot.prompt.Enabled = true
	selectedPets[player] = petEntry
	player:SetAttribute("SelectedPet", petEntry.Name)
	createPetTool(player, petEntry)
end

for prompt, slot in slotByPrompt do
	prompt.Triggered:Connect(function(player)
		local plot = playerPlots[player]
		if not plot or plot ~= slot.plot or plot.owner ~= player then
			return
		end
		local inventory = getInventory(player)

		if slot.petEntry then
			return
		end

		local petEntry = selectedPets[player]
		if petEntry and (petEntry.Parent ~= inventory or petEntry:GetAttribute("Placed")) then
			selectedPets[player] = nil
			petEntry = nil
		end

		local pets = inventory:GetChildren()
		table.sort(pets, function(left, right)
			return left.Name < right.Name
		end)
		if not petEntry then
			for _, candidate in pets do
				if candidate:IsA("StringValue") and not candidate:GetAttribute("Placed") then
					petEntry = candidate
					break
				end
			end
		end
		if not petEntry then
			return
		end

		petEntry:SetAttribute("Placed", true)
		petEntry:SetAttribute("HotbarSlot", nil)
		removePetTool(player, petEntry)
		if selectedPets[player] == petEntry then
			selectedPets[player] = nil
			player:SetAttribute("SelectedPet", "")
		end
		slot.petEntry = petEntry
		slot.prompt.Enabled = false
		local rarity = petEntry:GetAttribute("Rarity") or "Common"
		local income = petEntry:GetAttribute("IncomePerSecond") or 1
		local display = createPart(plot.model, "PlacedPet", Vector3.new(2, 2, 2), slot.position + Vector3.new(0, 1.18, 0), RARITY_COLORS[rarity] or RARITY_COLORS.Common)
		display.CanCollide = false
		slot.display = display
		local retrievePrompt = makePrompt(display, "RetrievePlacedPet", "Retrieve Pet", petEntry.Value, 0)
		slot.retrievePrompt = retrievePrompt
		retrievePrompt.Triggered:Connect(function(retrievingPlayer)
			local retrievingPlot = playerPlots[retrievingPlayer]
			if retrievingPlayer == player and retrievingPlot == slot.plot and slot.plot.owner == retrievingPlayer then
				retrievePlacedPet(retrievingPlayer, slot)
			end
		end)

		local petLabel = Instance.new("BillboardGui")
		petLabel.Name = "PetInfo"
		petLabel.Size = UDim2.fromOffset(180, 54)
		petLabel.StudsOffset = Vector3.new(0, 1.5, 0)
		petLabel.AlwaysOnTop = true
		petLabel.Parent = display
		local text = Instance.new("TextLabel")
		text.Size = UDim2.fromScale(1, 1)
		text.BackgroundTransparency = 1
		text.Font = Enum.Font.GothamBold
		text.Text = string.format("%s\n+%d Coins/s", petEntry.Value, income)
		text.TextColor3 = Color3.new(1, 1, 1)
		text.TextScaled = true
		text.TextStrokeTransparency = 0.35
		text.Parent = petLabel
	end)
end

local function assignPlot(player)
	for _, plot in plots do
		if not plot.owner then
			plot.owner = player
			plot.ownerSign = createOwnerLabel(plot, player.DisplayName)
			playerPlots[player] = plot
			return plot
		end
	end
	return nil
end

local function setupPlayer(player)
	if initializedPlayers[player] then
		return
	end
	initializedPlayers[player] = true

	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player
	local coins = Instance.new("IntValue")
	coins.Name = "Coins"
	coins.Value = 0
	coins.Parent = leaderstats
	getInventory(player)
	player:SetAttribute("SelectedPet", "")

	local plot = assignPlot(player)
	print("Assigned base:", player.Name, plot and plot.model.Name or "none", "spawn:", plot and tostring(plot.spawnCFrame.Position) or "none")
	player.CharacterAdded:Connect(function(character)
		if not plot then
			return
		end
		local root = character:WaitForChild("HumanoidRootPart", 10)
		if root and player.Parent then
			character:PivotTo(plot.spawnCFrame)
			print("Spawned at:", player.Name, plot.model.Name, tostring(character:GetPivot().Position))
		end
	end)
	if player.Character then
		task.spawn(function()
			local root = player.Character:WaitForChild("HumanoidRootPart", 10)
			if root and plot and player.Parent then
				player.Character:PivotTo(plot.spawnCFrame)
				print("Spawned at:", player.Name, plot.model.Name, tostring(player.Character:GetPivot().Position))
			end
		end)
	end
end

Players.PlayerAdded:Connect(setupPlayer)
Players.PlayerRemoving:Connect(function(player)
	initializedPlayers[player] = nil
	local plot = playerPlots[player]
	if plot then
		plot.owner = nil
		if plot.ownerSign then
			plot.ownerSign:Destroy()
			plot.ownerSign = nil
		end
		for _, slot in plot.slots do
			if slot.display then
				slot.display:Destroy()
			end
			slot.display = nil
			slot.petEntry = nil
			slot.retrievePrompt = nil
			slot.prompt.Enabled = true
		end
		playerPlots[player] = nil
	end
	lastUseAt[player] = nil
	selectedPets[player] = nil
end)

for _, player in Players:GetPlayers() do
	setupPlayer(player)
end

task.spawn(function()
	while true do
		task.wait(1)
		for _, player in Players:GetPlayers() do
			local leaderstats = player:FindFirstChild("leaderstats")
			local coins = leaderstats and leaderstats:FindFirstChild("Coins")
			local inventory = player:FindFirstChild("PetInventory")
			if coins and inventory then
				local earned = 0
				for _, pet in inventory:GetChildren() do
					if pet:GetAttribute("Placed") then
						earned += pet:GetAttribute("IncomePerSecond") or 0
					end
				end
				coins.Value += earned
			end
		end
	end
end)
