local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local PET_SPECIES = {
	{ name = "Mite", weight = 12, income = 1, modelScale = 0.9 },
	{ name = "Mouse", weight = 20, income = 1, modelScale = 1 },
	{ name = "Bunny", weight = 8, income = 2, modelScale = 1.15 },
	{ name = "Frog", weight = 5, income = 2, modelScale = 1.08 },
	{ name = "Duck", weight = 4, income = 2, modelScale = 1.12 },
	{ name = "Squirrel", weight = 3, income = 3, modelScale = 1.12 },
	{ name = "Turtle", weight = 2, income = 3, modelScale = 1.15 },
	{ name = "Bee", weight = 1, income = 4, modelScale = 0.85 },
	{ name = "Cat", weight = 8, income = 5, modelScale = 1.15 },
	{ name = "Panther", weight = 5, income = 10, modelScale = 1.28 },
	{ name = "Hare", weight = 5, income = 8, modelScale = 1.16 },
	{ name = "Fox", weight = 4, income = 9, modelScale = 1.2 },
	{ name = "Owl", weight = 3, income = 12, modelScale = 1.18 },
	{ name = "Deer", weight = 3, income = 14, modelScale = 1.34 },
	{ name = "Coyote", weight = 4, income = 20, modelScale = 1.22 },
	{ name = "Wolf", weight = 3, income = 25, modelScale = 1.28 },
	{ name = "Lynx", weight = 2, income = 28, modelScale = 1.22 },
	{ name = "Eagle", weight = 2, income = 32, modelScale = 1.3 },
	{ name = "Serpent", weight = 2, income = 35, modelScale = 1.35 },
	{ name = "Dragon", weight = 1.2, income = 100, modelScale = 1.38 },
	{ name = "Phoenix", weight = 1, income = 120, modelScale = 1.32 },
	{ name = "Tiger", weight = 0.7, income = 110, modelScale = 1.34 },
	{ name = "Kitsune", weight = 0.6, income = 135, modelScale = 1.25 },
	{ name = "Whale", weight = 0.5, income = 150, modelScale = 1.45 },
}

local SPECIES_COLORS = {
	Mite = Color3.fromRGB(112, 145, 91),
	Mouse = Color3.fromRGB(155, 151, 145),
	Bunny = Color3.fromRGB(207, 194, 164),
	Frog = Color3.fromRGB(95, 171, 114),
	Duck = Color3.fromRGB(241, 213, 119),
	Squirrel = Color3.fromRGB(176, 111, 66),
	Turtle = Color3.fromRGB(106, 139, 107),
	Bee = Color3.fromRGB(231, 190, 62),
	Cat = Color3.fromRGB(173, 186, 202),
	Panther = Color3.fromRGB(54, 62, 75),
	Hare = Color3.fromRGB(220, 209, 185),
	Fox = Color3.fromRGB(195, 137, 91),
	Owl = Color3.fromRGB(126, 143, 165),
	Deer = Color3.fromRGB(194, 167, 125),
	Coyote = Color3.fromRGB(152, 111, 190),
	Wolf = Color3.fromRGB(130, 166, 190),
	Lynx = Color3.fromRGB(157, 187, 198),
	Eagle = Color3.fromRGB(193, 155, 75),
	Serpent = Color3.fromRGB(76, 164, 157),
	Dragon = Color3.fromRGB(206, 100, 61),
	Phoenix = Color3.fromRGB(218, 102, 83),
	Tiger = Color3.fromRGB(218, 145, 59),
	Kitsune = Color3.fromRGB(222, 195, 147),
	Whale = Color3.fromRGB(83, 141, 183),
}

local SPECIES_BODY_PROPORTIONS = {
	Mite = Vector3.new(0.88, 0.82, 0.95),
	Mouse = Vector3.new(1, 1, 1),
	Bunny = Vector3.new(1.05, 1, 1.04),
	Frog = Vector3.new(1.12, 0.82, 1.15),
	Duck = Vector3.new(1.12, 0.9, 1.08),
	Squirrel = Vector3.new(0.98, 1, 1),
	Turtle = Vector3.new(1.15, 0.86, 1.12),
	Bee = Vector3.new(0.85, 0.95, 1),
	Cat = Vector3.new(1.05, 0.95, 1),
	Panther = Vector3.new(1.15, 0.95, 1.04),
	Hare = Vector3.new(1.05, 0.9, 1.12),
	Fox = Vector3.new(1.08, 0.92, 1),
	Owl = Vector3.new(1, 1.1, 1.05),
	Deer = Vector3.new(1.1, 0.98, 1.05),
	Coyote = Vector3.new(1.1, 0.9, 1.03),
	Wolf = Vector3.new(1.12, 0.95, 1.06),
	Lynx = Vector3.new(1, 0.94, 1.04),
	Eagle = Vector3.new(1.15, 0.85, 1),
	Serpent = Vector3.new(1, 0.75, 1.35),
	Dragon = Vector3.new(1.25, 1.05, 1.1),
	Phoenix = Vector3.new(1.1, 1, 1.05),
	Tiger = Vector3.new(1.15, 0.95, 1.05),
	Kitsune = Vector3.new(1.04, 0.95, 1),
	Whale = Vector3.new(1.25, 1, 1.4),
}

local RARITIES = {
	{ name = "Common", displayName = "Moss", weight = 55, passivePercent = 5 },
	{ name = "Rare", displayName = "Comet", weight = 28, passivePercent = 10 },
	{ name = "Epic", displayName = "Nebula", weight = 13, passivePercent = 20 },
	{ name = "Legendary", displayName = "Solar", weight = 4, passivePercent = 50 },
}

local RARITY_DISPLAY_NAMES = {
	Common = "Moss",
	Rare = "Comet",
	Epic = "Nebula",
	Legendary = "Solar",
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
local animatedPetModels = {}
local fractionalCoins = {}
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

local function chooseWeighted(entries)
	local totalWeight = 0
	for _, entry in entries do
		totalWeight += entry.weight
	end

	local roll = random:NextNumber(0, totalWeight)
	for _, entry in entries do
		roll -= entry.weight
		if roll < 0 then
			return entry
		end
	end

	return entries[#entries]
end

local function choosePet()
	local species = chooseWeighted(PET_SPECIES)
	local rarity = chooseWeighted(RARITIES)
	return {
		name = species.name,
		rarity = rarity.name,
		displayName = rarity.displayName .. " " .. species.name,
		weight = species.weight,
		rarityWeight = rarity.weight,
		passivePercent = rarity.passivePercent,
		modelScale = species.modelScale,
		income = species.income * (1 + rarity.passivePercent / 100),
	}
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

local function addPetFeature(parent, body, name, size, offset, color, anchored, scale, shape, rotation)
	scale = scale or 1
	local feature = Instance.new(shape == "Wedge" and "WedgePart" or "Part")
	feature.Name = name
	if shape ~= "Wedge" then
		feature.Shape = shape or Enum.PartType.Ball
	end
	feature.Size = size * scale
	feature.Color = color
	feature.Material = Enum.Material.SmoothPlastic
	feature.Anchored = anchored
	feature.CanCollide = false
	feature.CanTouch = false
	feature.CanQuery = false
	feature.Massless = not anchored
	feature.CFrame = body.CFrame * CFrame.new(offset * scale) * (rotation or CFrame.new())
	feature.Parent = parent

	if not anchored then
		local weld = Instance.new("WeldConstraint")
		weld.Part0 = body
		weld.Part1 = feature
		weld.Parent = body
	end
	return feature
end

local function addPetFaceAndLimbs(parent, body, color, anchored, scale, speciesName)
	scale = scale or 1
	local baseSize = body.Size / scale
	local width = baseSize.X
	local height = baseSize.Y
	local depth = baseSize.Z
	local shadowColor = color:Lerp(Color3.fromRGB(25, 34, 48), 0.38)
	local eyeWhite = Color3.fromRGB(244, 244, 231)
	local eyeColor = Color3.fromRGB(24, 31, 43)
	local frontZ = -depth * 0.47
	local earless = speciesName == "Bee" or speciesName == "Turtle" or speciesName == "Serpent" or speciesName == "Whale"
	local bird = speciesName == "Duck" or speciesName == "Owl" or speciesName == "Eagle" or speciesName == "Phoenix"

	if speciesName == "Mouse" or speciesName == "Bunny" or speciesName == "Hare" then
		local earHeight = speciesName == "Mouse" and 0.48 or 0.88
		local earWidth = speciesName == "Mouse" and 0.48 or 0.34
		addPetFeature(parent, body, "LeftEar", Vector3.new(earWidth, earHeight, 0.34), Vector3.new(-width * 0.25, height * 0.46, -depth * 0.08), shadowColor, anchored, scale)
		addPetFeature(parent, body, "RightEar", Vector3.new(earWidth, earHeight, 0.34), Vector3.new(width * 0.25, height * 0.46, -depth * 0.08), shadowColor, anchored, scale)
	elseif not earless then
		local earColor = bird and color:Lerp(Color3.new(1, 1, 1), 0.25) or shadowColor
		addPetFeature(parent, body, "LeftEar", Vector3.new(0.34, 0.58, 0.34), Vector3.new(-width * 0.3, height * 0.42, -depth * 0.05), earColor, anchored, scale, "Wedge")
		addPetFeature(parent, body, "RightEar", Vector3.new(0.34, 0.58, 0.34), Vector3.new(width * 0.3, height * 0.42, -depth * 0.05), earColor, anchored, scale, "Wedge")
	end

	local eyeX = width * 0.18
	local eyeY = height * 0.1
	local eyeSize = Vector3.new(0.2, 0.24, 0.12)
	if speciesName == "Frog" then
		eyeY = height * 0.42
		eyeSize = Vector3.new(0.38, 0.42, 0.3)
	end
	for _, side in { -1, 1 } do
		local eyeOffset = Vector3.new(eyeX * side, eyeY, frontZ - 0.04)
		addPetFeature(parent, body, side < 0 and "LeftEyeWhite" or "RightEyeWhite", eyeSize, eyeOffset, eyeWhite, anchored, scale)
		addPetFeature(parent, body, side < 0 and "LeftEye" or "RightEye", eyeSize * 0.48, eyeOffset + Vector3.new(0, 0, -0.09), eyeColor, anchored, scale)
	end

	if bird then
		local beakColor = speciesName == "Duck" and Color3.fromRGB(243, 174, 54) or Color3.fromRGB(217, 177, 91)
		local beakSize = speciesName == "Duck" and Vector3.new(0.52, 0.27, 0.38) or Vector3.new(0.34, 0.4, 0.46)
		local beakShape = speciesName == "Duck" and Enum.PartType.Block or "Wedge"
		addPetFeature(parent, body, "Beak", beakSize, Vector3.new(0, -height * 0.12, frontZ - 0.22), beakColor, anchored, scale, beakShape)
	elseif speciesName ~= "Frog" and speciesName ~= "Bee" and speciesName ~= "Whale" then
		local muzzleSize = Vector3.new(width * 0.3, height * 0.23, 0.38)
		addPetFeature(parent, body, "Muzzle", muzzleSize, Vector3.new(0, -height * 0.16, frontZ - 0.13), color:Lerp(Color3.new(1, 1, 1), 0.28), anchored, scale)
		addPetFeature(parent, body, "Nose", Vector3.new(0.17, 0.13, 0.12), Vector3.new(0, -height * 0.13, frontZ - 0.34), Color3.fromRGB(43, 37, 43), anchored, scale)
	end

	for _, side in { -1, 1 } do
		for _, front in { -1, 1 } do
			local pawName = string.format("Paw%s%s", side < 0 and "L" or "R", front < 0 and "Front" or "Back")
			addPetFeature(parent, body, pawName, Vector3.new(0.34, 0.28, 0.38), Vector3.new(width * 0.32 * side, -height * 0.42, depth * 0.24 * front), shadowColor, anchored, scale)
		end
	end

	if speciesName == "Turtle" then
		addPetFeature(parent, body, "Shell", Vector3.new(width * 0.82, height * 0.72, depth * 0.55), Vector3.new(0, height * 0.1, depth * 0.25), Color3.fromRGB(76, 107, 76), anchored, scale)
	elseif speciesName == "Bee" then
		for _, side in { -1, 1 } do
			addPetFeature(parent, body, side < 0 and "LeftWing" or "RightWing", Vector3.new(0.52, 0.18, 0.72), Vector3.new(width * 0.42 * side, height * 0.46, 0), Color3.fromRGB(184, 225, 237), anchored, scale)
		end
		for stripeIndex = -1, 1 do
			addPetFeature(parent, body, "Stripe" .. tostring(stripeIndex + 2), Vector3.new(width * 0.84, 0.1, 0.13), Vector3.new(0, stripeIndex * height * 0.2, depth * 0.48), Color3.fromRGB(57, 48, 33), anchored, scale, Enum.PartType.Block)
		end
	elseif bird or speciesName == "Dragon" or speciesName == "Deer" then
		for _, side in { -1, 1 } do
			local wingSize = speciesName == "Dragon" and Vector3.new(0.7, 0.2, 1.05) or Vector3.new(0.46, 0.2, 0.85)
			addPetFeature(parent, body, side < 0 and "LeftWing" or "RightWing", wingSize, Vector3.new(width * 0.52 * side, height * 0.05, depth * 0.08), shadowColor, anchored, scale)
		end
		if speciesName == "Deer" then
			for _, side in { -1, 1 } do
				addPetFeature(parent, body, side < 0 and "LeftAntler" or "RightAntler", Vector3.new(0.2, 0.8, 0.2), Vector3.new(width * 0.28 * side, height * 0.72, 0), Color3.fromRGB(218, 201, 165), anchored, scale, "Wedge")
			end
		end
	elseif speciesName == "Whale" then
		for _, side in { -1, 1 } do
			addPetFeature(parent, body, side < 0 and "LeftFin" or "RightFin", Vector3.new(0.55, 0.2, 0.82), Vector3.new(width * 0.48 * side, -height * 0.12, 0.05), shadowColor, anchored, scale, "Wedge")
		end
		addPetFeature(parent, body, "TailFluke", Vector3.new(0.88, 0.2, 0.52), Vector3.new(0, 0.04, depth * 0.58), shadowColor, anchored, scale)
	elseif speciesName == "Tiger" then
		for stripeIndex = -1, 1 do
			for _, side in { -1, 1 } do
				addPetFeature(parent, body, "Stripe" .. tostring(stripeIndex + 2) .. tostring(side), Vector3.new(0.14, height * 0.65, 0.16), Vector3.new(width * 0.47 * side, stripeIndex * height * 0.28, depth * 0.1), Color3.fromRGB(45, 39, 33), anchored, scale, Enum.PartType.Block)
			end
		end
	else
		local tailLength = speciesName == "Squirrel" and 1.15 or 0.62
		local tailSize = speciesName == "Squirrel" and Vector3.new(0.8, 0.9, 0.85) or Vector3.new(0.34, 0.34, tailLength)
		addPetFeature(parent, body, "Tail", tailSize, Vector3.new(0, height * 0.06, depth * 0.52 + tailLength * 0.28), shadowColor, anchored, scale)
	end
end

local function animatePetModel(model, origin)
	animatedPetModels[model] = {
		origin = origin,
		phase = random:NextNumber(0, math.pi * 2),
	}
end

RunService.Heartbeat:Connect(function()
	local now = os.clock()
	for model, animation in animatedPetModels do
		if not model.Parent then
			animatedPetModels[model] = nil
		else
			local bob = math.sin(now * 2.4 + animation.phase) * 0.12
			local turn = math.sin(now * 1.1 + animation.phase) * 0.12
			model:PivotTo(animation.origin * CFrame.new(0, bob, 0) * CFrame.Angles(0, turn, 0))
		end
	end
end)

local function createPetTool(player, petEntry)
	local backpack = player:WaitForChild("Backpack")
	local rarity = petEntry:GetAttribute("Rarity") or "Common"
	local speciesName = petEntry:GetAttribute("SpeciesName") or petEntry.Value
	local modelScale = petEntry:GetAttribute("ModelScale") or 1
	local proportions = SPECIES_BODY_PROPORTIONS[speciesName] or Vector3.new(1, 1, 1)
	local bodyColor = SPECIES_COLORS[speciesName] or RARITY_COLORS[rarity] or RARITY_COLORS.Common
	local tool = Instance.new("Tool")
	tool.Name = petEntry.Value
	tool.ToolTip = string.format("%s | %s%% species chance | %s%% rarity chance | +%s%% coins/s", petEntry.Value, tostring(petEntry:GetAttribute("SpeciesChancePercent") or "?"), tostring(petEntry:GetAttribute("RarityChancePercent") or "?"), tostring(petEntry:GetAttribute("PassivePercent") or 0))
	tool.RequiresHandle = true
	tool.CanBeDropped = false
	tool:SetAttribute("PetEntryName", petEntry.Name)

	local handle = Instance.new("Part")
	handle.Name = "Handle"
	handle.Shape = Enum.PartType.Ball
	handle.Size = Vector3.new(1.3, 1.2, 1.2) * proportions * modelScale
	handle.Color = bodyColor
	handle.Material = Enum.Material.SmoothPlastic
	handle.Anchored = false
	handle.CanCollide = false
	handle.CanTouch = false
	handle.CanQuery = false
	handle.Massless = true
	handle.Parent = tool
	addPetFaceAndLimbs(tool, handle, handle.Color, false, modelScale, speciesName)

	local label = Instance.new("BillboardGui")
	label.Name = "PetName"
	label.Size = UDim2.fromOffset(130, 28)
	label.StudsOffset = Vector3.new(0, 1.1 * modelScale, 0)
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
	local restingGrip = tool.Grip
	local gripTween
	tool.Equipped:Connect(function()
		if gripTween then
			gripTween:Cancel()
		end
		gripTween = TweenService:Create(tool, TweenInfo.new(0.7, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
			Grip = restingGrip * CFrame.new(0, 0.1, 0) * CFrame.Angles(0, 0, 0.08),
		})
		gripTween:Play()
	end)
	tool.Unequipped:Connect(function()
		if gripTween then
			gripTween:Cancel()
			gripTween = nil
		end
		tool.Grip = restingGrip
	end)
	tool.Destroying:Connect(function()
		if gripTween then
			gripTween:Cancel()
		end
	end)
	tool.Equipped:Connect(function()
		selectedPets[player] = petEntry
		player:SetAttribute("SelectedPet", petEntry.Name)
	end)

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
		petEntry.Value = pet.displayName
		petEntry:SetAttribute("Rarity", pet.rarity)
		petEntry:SetAttribute("SpeciesName", pet.name)
		petEntry:SetAttribute("SpeciesChancePercent", pet.weight)
		petEntry:SetAttribute("RarityChancePercent", pet.rarityWeight)
		petEntry:SetAttribute("PassivePercent", pet.passivePercent)
		petEntry:SetAttribute("ModelScale", pet.modelScale)
		petEntry:SetAttribute("IncomePerSecond", pet.income)
		petEntry:SetAttribute("DropChancePercent", pet.weight)
		petEntry:SetAttribute("Placed", false)
		petEntry:SetAttribute("HotbarSlot", findOpenHotbarSlot(inventory))
		petEntry.Parent = inventory
		createPetTool(player, petEntry)
		print("Claw pet awarded:", player.Name, pet.name, pet.rarity)

		petAwarded:FireClient(player, pet.displayName, pet.rarity, #inventory:GetChildren(), pet.income, pet.passivePercent)
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

local function createPlacedPetModel(plot, slot, petEntry, rarity, income)
	local speciesName = petEntry:GetAttribute("SpeciesName") or petEntry.Value
	local model = Instance.new("Model")
	model.Name = "PlacedPet"
	model.Parent = plot.model

	local body = Instance.new("Part")
	body.Name = "Body"
	body.Shape = Enum.PartType.Ball
	local modelScale = petEntry:GetAttribute("ModelScale") or 1
	local proportions = SPECIES_BODY_PROPORTIONS[speciesName] or Vector3.new(1, 1, 1)
	body.Size = Vector3.new(1.7, 1.5, 1.45) * proportions * modelScale
	local bodyPosition = slot.position + Vector3.new(0, 0.45 + body.Size.Y / 2, 0)
	body.CFrame = CFrame.lookAt(bodyPosition, Vector3.new(plot.center.X, bodyPosition.Y, plot.center.Z))
	body.Color = SPECIES_COLORS[speciesName] or RARITY_COLORS[rarity] or RARITY_COLORS.Common
	body.Material = Enum.Material.SmoothPlastic
	body.Anchored = true
	body.CanCollide = false
	body.CanTouch = false
	body.CanQuery = false
	body.Parent = model
	model.PrimaryPart = body
	addPetFaceAndLimbs(model, body, body.Color, true, modelScale, speciesName)

	local petLabel = Instance.new("BillboardGui")
	petLabel.Name = "PetInfo"
	petLabel.Size = UDim2.fromOffset(180, 54)
	petLabel.StudsOffset = Vector3.new(0, 1.45 * modelScale, 0)
	petLabel.AlwaysOnTop = true
	petLabel.Parent = body
	local text = Instance.new("TextLabel")
	text.Size = UDim2.fromScale(1, 1)
	text.BackgroundTransparency = 1
	text.Font = Enum.Font.GothamBold
	local passivePercent = petEntry:GetAttribute("PassivePercent") or 0
	text.Text = string.format("%s\n+%.2f Coins/s | +%d%% passive", petEntry.Value, income, passivePercent)
	text.TextColor3 = Color3.new(1, 1, 1)
	text.TextScaled = true
	text.TextStrokeTransparency = 0.35
	text.Parent = petLabel

	local retrievePrompt = makePrompt(body, "RetrievePlacedPet", "Retrieve Pet", petEntry.Value, 0)
	animatePetModel(model, body.CFrame)
	return model, retrievePrompt
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
		local display, retrievePrompt = createPlacedPetModel(plot, slot, petEntry, rarity, income)
		slot.display = display
		slot.retrievePrompt = retrievePrompt
		retrievePrompt.Triggered:Connect(function(retrievingPlayer)
			local retrievingPlot = playerPlots[retrievingPlayer]
			if retrievingPlayer == player and retrievingPlot == slot.plot and slot.plot.owner == retrievingPlayer then
				retrievePlacedPet(retrievingPlayer, slot)
			end
		end)

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
	fractionalCoins[player] = nil
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
				local accrued = earned + (fractionalCoins[player] or 0)
				local wholeCoins = math.floor(accrued)
				if wholeCoins > 0 then
					coins.Value += wholeCoins
				end
				fractionalCoins[player] = accrued - wholeCoins
			end
		end
	end
end)
