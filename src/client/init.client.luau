local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local petAwarded = ReplicatedStorage:WaitForChild("PetAwarded")
local selectPetRemote = ReplicatedStorage:WaitForChild("SelectPet")

task.spawn(function()
	for _ = 1, 10 do
		local enabled = pcall(function()
			StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true)
		end)
		if enabled then
			return
		end
		task.wait(0.25)
	end
end)

local screenGui = playerGui:FindFirstChild("ClawMachineGui")
if not screenGui then
	screenGui = Instance.new("ScreenGui")
	screenGui.Name = "ClawMachineGui"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = playerGui
end

local rarityColors = {
	Common = Color3.fromRGB(175, 183, 190),
	Rare = Color3.fromRGB(55, 145, 255),
	Epic = Color3.fromRGB(168, 82, 230),
	Legendary = Color3.fromRGB(255, 205, 48),
}

local rewardLabel = screenGui:FindFirstChild("RewardLabel")
if not rewardLabel then
	rewardLabel = Instance.new("TextLabel")
	rewardLabel.Name = "RewardLabel"
	rewardLabel.AnchorPoint = Vector2.new(0.5, 0)
	rewardLabel.Position = UDim2.new(0.5, 0, 0.08, 0)
	rewardLabel.Size = UDim2.new(0.8, 0, 0, 84)
	rewardLabel.BackgroundColor3 = Color3.fromRGB(24, 30, 42)
	rewardLabel.BackgroundTransparency = 0.08
	rewardLabel.Font = Enum.Font.GothamBold
	rewardLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	rewardLabel.TextSize = 20
	rewardLabel.TextWrapped = true
	rewardLabel.Visible = false
	rewardLabel.Parent = screenGui
end

rewardLabel.Size = UDim2.new(0.72, 0, 0, 96)
rewardLabel.Font = Enum.Font.GothamMedium
rewardLabel.TextColor3 = Color3.fromRGB(232, 238, 240)
rewardLabel.TextSize = 16
rewardLabel.TextWrapped = true
rewardLabel.TextStrokeTransparency = 1
rewardLabel.TextXAlignment = Enum.TextXAlignment.Center
rewardLabel.TextYAlignment = Enum.TextYAlignment.Center
rewardLabel.BackgroundTransparency = 0.16
local rarityStroke = rewardLabel:FindFirstChild("RarityStroke")
if rarityStroke then
	rarityStroke:Destroy()
end

local walletLabel = screenGui:FindFirstChild("WalletLabel")
if not walletLabel then
	walletLabel = Instance.new("TextLabel")
	walletLabel.Name = "WalletLabel"
	walletLabel.AnchorPoint = Vector2.new(1, 0)
	walletLabel.Position = UDim2.new(1, -24, 0, 20)
	walletLabel.Size = UDim2.fromOffset(220, 48)
	walletLabel.BackgroundColor3 = Color3.fromRGB(24, 30, 42)
	walletLabel.BackgroundTransparency = 0.08
	walletLabel.Font = Enum.Font.GothamBold
	walletLabel.TextColor3 = Color3.fromRGB(255, 220, 90)
	walletLabel.TextSize = 22
	walletLabel.Text = "Coins 0"
	walletLabel.Parent = screenGui
end

local coins = player:WaitForChild("leaderstats"):WaitForChild("Coins")
local function updateWallet()
	walletLabel.Text = string.format("Coins %d", coins.Value)
end
updateWallet()
coins:GetPropertyChangedSignal("Value"):Connect(updateWallet)

local petInventory = player:WaitForChild("PetInventory")
local selectedPetName = player:GetAttribute("SelectedPet") or ""
local petHotbar = screenGui:FindFirstChild("PetHotbar")
if not petHotbar then
	petHotbar = Instance.new("Frame")
	petHotbar.Name = "PetHotbar"
	petHotbar.AnchorPoint = Vector2.new(0.5, 1)
	petHotbar.Position = UDim2.new(0.5, 0, 1, -16)
	petHotbar.Size = UDim2.new(0.9, 0, 0, 72)
	petHotbar.BackgroundTransparency = 1
	petHotbar.Parent = screenGui

	local layout = Instance.new("UIGridLayout")
	layout.Name = "SlotLayout"
	layout.CellPadding = UDim2.new(0, 6, 0, 0)
	layout.CellSize = UDim2.new(1 / 7, -6, 1, 0)
	layout.FillDirectionMaxCells = 7
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = petHotbar
end
petHotbar.Visible = false

local rarityColors = {
	Common = Color3.fromRGB(175, 183, 190),
	Rare = Color3.fromRGB(55, 145, 255),
	Epic = Color3.fromRGB(168, 82, 230),
	Legendary = Color3.fromRGB(255, 205, 48),
}

for index = 1, 7 do
	local slotName = string.format("Slot%d", index)
	if not petHotbar:FindFirstChild(slotName) then
		local slot = Instance.new("Frame")
		slot.Name = slotName
		slot.LayoutOrder = index
		slot.BackgroundColor3 = Color3.fromRGB(24, 32, 36)
		slot.BackgroundTransparency = 0.08
		slot.Parent = petHotbar

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 6)
		corner.Parent = slot

		local stroke = Instance.new("UIStroke")
		stroke.Name = "RarityStroke"
		stroke.Color = Color3.fromRGB(74, 88, 91)
		stroke.Thickness = 1
		stroke.Parent = slot

		local keyLabel = Instance.new("TextLabel")
		keyLabel.Name = "Key"
		keyLabel.Position = UDim2.fromOffset(7, 4)
		keyLabel.Size = UDim2.fromOffset(18, 18)
		keyLabel.BackgroundTransparency = 1
		keyLabel.Font = Enum.Font.GothamBold
		keyLabel.Text = tostring(index)
		keyLabel.TextColor3 = Color3.fromRGB(187, 201, 199)
		keyLabel.TextSize = 12
		keyLabel.Parent = slot

		local nameLabel = Instance.new("TextLabel")
		nameLabel.Name = "PetName"
		nameLabel.Position = UDim2.new(0, 4, 0, 23)
		nameLabel.Size = UDim2.new(1, -8, 0, 27)
		nameLabel.BackgroundTransparency = 1
		nameLabel.Font = Enum.Font.GothamBold
		nameLabel.Text = "Empty"
		nameLabel.TextColor3 = Color3.fromRGB(225, 233, 230)
		nameLabel.TextSize = 12
		nameLabel.TextWrapped = true
		nameLabel.Parent = slot

		local rarityLabel = Instance.new("TextLabel")
		rarityLabel.Name = "Rarity"
		rarityLabel.Position = UDim2.new(0, 4, 1, -18)
		rarityLabel.Size = UDim2.new(1, -8, 0, 14)
		rarityLabel.BackgroundTransparency = 1
		rarityLabel.Font = Enum.Font.GothamMedium
		rarityLabel.Text = ""
		rarityLabel.TextColor3 = Color3.fromRGB(187, 201, 199)
		rarityLabel.TextSize = 10
		rarityLabel.Parent = slot
	end
end

local inventoryPanel = screenGui:FindFirstChild("PetInventoryPanel")
local inventoryList
local inventoryCount
local emptyMessage
local rarityFilters = { "All", "Common", "Rare", "Epic", "Legendary" }
local selectedRarityFilter = "All"
local filterButtons = {}
if not inventoryPanel then
	inventoryPanel = Instance.new("Frame")
	inventoryPanel.Name = "PetInventoryPanel"
	inventoryPanel.AnchorPoint = Vector2.new(0.5, 0.5)
	inventoryPanel.Position = UDim2.fromScale(0.5, 0.5)
	inventoryPanel.Size = UDim2.new(0.9, 0, 0.82, 0)
	inventoryPanel.BackgroundColor3 = Color3.fromRGB(22, 30, 33)
	inventoryPanel.Visible = false
	inventoryPanel.Parent = screenGui

	local sizeConstraint = Instance.new("UISizeConstraint")
	sizeConstraint.MinSize = Vector2.new(360, 300)
	sizeConstraint.MaxSize = Vector2.new(820, 680)
	sizeConstraint.Parent = inventoryPanel

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = inventoryPanel

	local panelStroke = Instance.new("UIStroke")
	panelStroke.Color = Color3.fromRGB(75, 98, 91)
	panelStroke.Thickness = 1
	panelStroke.Parent = inventoryPanel

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Position = UDim2.fromOffset(20, 16)
	title.Size = UDim2.new(1, -100, 0, 30)
	title.BackgroundTransparency = 1
	title.Font = Enum.Font.GothamBold
	title.Text = "PET COLLECTION"
	title.TextColor3 = Color3.fromRGB(235, 241, 235)
	title.TextSize = 20
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = inventoryPanel

	inventoryCount = Instance.new("TextLabel")
	inventoryCount.Name = "PetCount"
	inventoryCount.AnchorPoint = Vector2.new(1, 0)
	inventoryCount.Position = UDim2.new(1, -58, 0, 20)
	inventoryCount.Size = UDim2.fromOffset(100, 22)
	inventoryCount.BackgroundTransparency = 1
	inventoryCount.Font = Enum.Font.GothamMedium
	inventoryCount.TextColor3 = Color3.fromRGB(170, 194, 179)
	inventoryCount.TextSize = 12
	inventoryCount.TextXAlignment = Enum.TextXAlignment.Right
	inventoryCount.Parent = inventoryPanel

	local closeButton = Instance.new("TextButton")
	closeButton.Name = "Close"
	closeButton.AnchorPoint = Vector2.new(1, 0)
	closeButton.Position = UDim2.new(1, -14, 0, 12)
	closeButton.Size = UDim2.fromOffset(32, 32)
	closeButton.BackgroundColor3 = Color3.fromRGB(42, 54, 54)
	closeButton.Font = Enum.Font.GothamBold
	closeButton.Text = "X"
	closeButton.TextColor3 = Color3.fromRGB(235, 241, 235)
	closeButton.TextSize = 14
	closeButton.Parent = inventoryPanel

	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(0, 5)
	closeCorner.Parent = closeButton

	inventoryList = Instance.new("ScrollingFrame")
	inventoryList.Name = "PetList"
	inventoryList.Position = UDim2.fromOffset(16, 60)
	inventoryList.Size = UDim2.new(1, -32, 1, -76)
	inventoryList.BackgroundTransparency = 1
	inventoryList.BorderSizePixel = 0
	inventoryList.CanvasSize = UDim2.new()
	inventoryList.AutomaticCanvasSize = Enum.AutomaticSize.Y
	inventoryList.ScrollBarThickness = 5
	inventoryList.ScrollBarImageColor3 = Color3.fromRGB(120, 153, 126)
	inventoryList.Parent = inventoryPanel

	local listLayout = Instance.new("UIListLayout")
	listLayout.Name = "ListLayout"
	listLayout.Padding = UDim.new(0, 7)
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Parent = inventoryList

	emptyMessage = Instance.new("TextLabel")
	emptyMessage.Name = "EmptyMessage"
	emptyMessage.AnchorPoint = Vector2.new(0.5, 0.5)
	emptyMessage.Position = UDim2.fromScale(0.5, 0.5)
	emptyMessage.Size = UDim2.new(1, -32, 0, 42)
	emptyMessage.BackgroundTransparency = 1
	emptyMessage.Font = Enum.Font.GothamMedium
	emptyMessage.Text = "No pets yet"
	emptyMessage.TextColor3 = Color3.fromRGB(170, 184, 178)
	emptyMessage.TextSize = 15
	emptyMessage.Parent = inventoryPanel

	closeButton.Activated:Connect(function()
		inventoryPanel.Visible = false
	end)
else
	inventoryList = inventoryPanel:WaitForChild("PetList")
	inventoryCount = inventoryPanel:WaitForChild("PetCount")
	emptyMessage = inventoryPanel:WaitForChild("EmptyMessage")
end
inventoryPanel.Visible = false

inventoryPanel.Size = UDim2.new(0.9, 0, 0.82, 0)
local panelSizeConstraint = inventoryPanel:FindFirstChildOfClass("UISizeConstraint")
if panelSizeConstraint then
	panelSizeConstraint.MinSize = Vector2.new(360, 300)
	panelSizeConstraint.MaxSize = Vector2.new(820, 680)
end
inventoryList.Position = UDim2.fromOffset(16, 100)
inventoryList.Size = UDim2.new(1, -32, 1, -116)

local filterBar = inventoryPanel:FindFirstChild("RarityFilters")
if not filterBar then
	filterBar = Instance.new("Frame")
	filterBar.Name = "RarityFilters"
	filterBar.Position = UDim2.fromOffset(16, 56)
	filterBar.Size = UDim2.new(1, -32, 0, 34)
	filterBar.BackgroundTransparency = 1
	filterBar.Parent = inventoryPanel

	local filterLayout = Instance.new("UIGridLayout")
	filterLayout.Name = "FilterLayout"
	filterLayout.CellPadding = UDim2.fromOffset(4, 0)
	filterLayout.CellSize = UDim2.new(0.2, -4, 1, 0)
	filterLayout.FillDirectionMaxCells = #rarityFilters
	filterLayout.SortOrder = Enum.SortOrder.LayoutOrder
	filterLayout.Parent = filterBar
end

for index, rarity in rarityFilters do
	local buttonName = "Filter" .. rarity
	local button = filterBar:FindFirstChild(buttonName)
	if not button then
		button = Instance.new("TextButton")
		button.Name = buttonName
		button.LayoutOrder = index
		button.BackgroundColor3 = Color3.fromRGB(37, 50, 48)
		button.Font = Enum.Font.GothamBold
		button.Text = rarity
		button.TextColor3 = Color3.fromRGB(190, 207, 195)
		button.TextSize = 11
		button.AutoButtonColor = true
		button.Parent = filterBar

		local filterCorner = Instance.new("UICorner")
		filterCorner.CornerRadius = UDim.new(0, 5)
		filterCorner.Parent = button
	end
	filterButtons[rarity] = button
end

local function getPets()
	local pets = {}
	for _, child in petInventory:GetChildren() do
		if child:IsA("StringValue") then
			table.insert(pets, child)
		end
	end
	table.sort(pets, function(left, right)
		return left.Name < right.Name
	end)
	return pets
end

local function getHotbarPet(slotNumber)
	for _, pet in getPets() do
		if not pet:GetAttribute("Placed") and pet:GetAttribute("HotbarSlot") == slotNumber then
			return pet
		end
	end
	return nil
end

local function renderPets()
	local pets = getPets()
	for index = 1, 7 do
		local slot = petHotbar:FindFirstChild(string.format("Slot%d", index))
		local pet = getHotbarPet(index)
		local nameLabel = slot:FindFirstChild("PetName")
		local rarityLabel = slot:FindFirstChild("Rarity")
		local stroke = slot:FindFirstChild("RarityStroke")
		if pet then
			local rarity = pet:GetAttribute("Rarity") or "Common"
			nameLabel.Text = pet.Value
			rarityLabel.Text = rarity
			rarityLabel.TextColor3 = rarityColors[rarity] or rarityColors.Common
			stroke.Color = pet.Name == selectedPetName and Color3.fromRGB(255, 224, 138) or rarityColors[rarity] or rarityColors.Common
			stroke.Thickness = pet.Name == selectedPetName and 3 or 1
		else
			nameLabel.Text = "Empty"
			rarityLabel.Text = ""
			stroke.Color = Color3.fromRGB(74, 88, 91)
			stroke.Thickness = 1
		end
	end
	for rarity, button in filterButtons do
		local isSelected = rarity == selectedRarityFilter
		button.BackgroundColor3 = isSelected and Color3.fromRGB(83, 126, 91) or Color3.fromRGB(37, 50, 48)
		button.TextColor3 = isSelected and Color3.fromRGB(250, 255, 246) or Color3.fromRGB(190, 207, 195)
	end

	for _, child in inventoryList:GetChildren() do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end
	inventoryCount.Text = string.format("%d PET%s", #pets, #pets == 1 and "" or "S")
	local matchingPets = 0

	for index, pet in pets do
		local rarity = pet:GetAttribute("Rarity") or "Common"
		if selectedRarityFilter ~= "All" and rarity ~= selectedRarityFilter then
			continue
		end
		matchingPets += 1
		local income = pet:GetAttribute("IncomePerSecond") or 0
		local row = Instance.new("Frame")
		row.Name = "PetRow"
		row.LayoutOrder = index
		row.Size = UDim2.new(1, -8, 0, 60)
		row.BackgroundColor3 = Color3.fromRGB(31, 42, 43)
		row.Parent = inventoryList

		local rowCorner = Instance.new("UICorner")
		rowCorner.CornerRadius = UDim.new(0, 5)
		rowCorner.Parent = row

		local rarityStripe = Instance.new("Frame")
		rarityStripe.Name = "RarityStripe"
		rarityStripe.Size = UDim2.new(0, 4, 1, 0)
		rarityStripe.BackgroundColor3 = rarityColors[rarity] or rarityColors.Common
		rarityStripe.BorderSizePixel = 0
		rarityStripe.Parent = row

		local petName = Instance.new("TextLabel")
		petName.Name = "PetName"
		petName.Position = UDim2.fromOffset(16, 8)
		petName.Size = UDim2.new(1, -110, 0, 22)
		petName.BackgroundTransparency = 1
		petName.Font = Enum.Font.GothamBold
		petName.Text = pet.Value
		petName.TextColor3 = Color3.fromRGB(235, 241, 235)
		petName.TextSize = 14
		petName.TextXAlignment = Enum.TextXAlignment.Left
		petName.Parent = row

		local details = Instance.new("TextLabel")
		details.Name = "Details"
		details.Position = UDim2.fromOffset(16, 32)
		details.Size = UDim2.new(1, -110, 0, 18)
		details.BackgroundTransparency = 1
		details.Font = Enum.Font.GothamMedium
		details.Text = string.format("%s  |  +%d Coins/s", rarity, income)
		details.TextColor3 = rarityColors[rarity] or rarityColors.Common
		details.TextSize = 11
		details.TextXAlignment = Enum.TextXAlignment.Left
		details.Parent = row

		local status = Instance.new("TextLabel")
		status.Name = "Status"
		status.AnchorPoint = Vector2.new(1, 0.5)
		status.Position = UDim2.new(1, -14, 0.5, 0)
		status.Size = UDim2.fromOffset(76, 22)
		status.BackgroundTransparency = 1
		status.Font = Enum.Font.GothamBold
		status.Text = pet.Name == selectedPetName and "SELECTED" or (pet:GetAttribute("Placed") and "PLACED" or "READY")
		status.TextColor3 = pet.Name == selectedPetName and Color3.fromRGB(255, 224, 138) or (pet:GetAttribute("Placed") and Color3.fromRGB(147, 177, 151) or Color3.fromRGB(224, 205, 125))
		status.TextSize = 10
		status.Parent = row
	end

	emptyMessage.Visible = matchingPets == 0
	if #pets == 0 then
		emptyMessage.Text = "No pets yet"
	else
		emptyMessage.Text = string.format("No %s pets", selectedRarityFilter == "All" and "matching" or selectedRarityFilter)
	end
end

local function equipPet(pet)
	task.spawn(function()
		local character = player.Character or player.CharacterAdded:Wait()
		local humanoid = character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid")
		local backpack = player:WaitForChild("Backpack")
		local tool = backpack:FindFirstChild(pet.Name) or character:FindFirstChild(pet.Name)
		if not tool then
			tool = backpack:WaitForChild(pet.Name, 5)
		end
		if tool and tool:IsA("Tool") and humanoid.Parent then
			if tool.Parent == character then
				humanoid:UnequipTools()
			else
				humanoid:EquipTool(tool)
			end
		end
	end)
end

local function selectPetAtIndex(index, equipSelectedPet)
	local pet = getHotbarPet(index)
	if not pet or pet:GetAttribute("Placed") then
		return
	end

	selectedPetName = pet.Name
	selectPetRemote:FireServer(pet.Name)
	if equipSelectedPet then
		equipPet(pet)
	end
	renderPets()
end

local function selectFirstAvailablePet()
	local selectedPet = petInventory:FindFirstChild(selectedPetName)
	if selectedPet and not selectedPet:GetAttribute("Placed") then
		return
	end

	for index = 1, 7 do
		if getHotbarPet(index) then
			selectPetAtIndex(index)
			return
		end
	end

	selectedPetName = ""
	renderPets()
end

local attributeConnections = {}
local function watchPet(pet)
	if not pet:IsA("StringValue") then
		return
	end
	local connections = {}
	for _, attributeName in { "Placed", "HotbarSlot" } do
		table.insert(connections, pet:GetAttributeChangedSignal(attributeName):Connect(renderPets))
	end
	attributeConnections[pet] = connections
end

petInventory.ChildAdded:Connect(function(pet)
	watchPet(pet)
	selectFirstAvailablePet()
	renderPets()
end)
petInventory.ChildRemoved:Connect(function(pet)
	local connections = attributeConnections[pet]
	if connections then
		for _, connection in connections do
			connection:Disconnect()
		end
		attributeConnections[pet] = nil
	end
	renderPets()
end)
for _, pet in petInventory:GetChildren() do
	watchPet(pet)
end
for rarity, button in filterButtons do
	button.Activated:Connect(function()
		selectedRarityFilter = rarity
		renderPets()
	end)
end
renderPets()
selectFirstAvailablePet()
player:GetAttributeChangedSignal("SelectedPet"):Connect(function()
	selectedPetName = player:GetAttribute("SelectedPet") or ""
	renderPets()
end)

local hotbarKeys = {
	[Enum.KeyCode.One] = 1,
	[Enum.KeyCode.Two] = 2,
	[Enum.KeyCode.Three] = 3,
	[Enum.KeyCode.Four] = 4,
	[Enum.KeyCode.Five] = 5,
	[Enum.KeyCode.Six] = 6,
	[Enum.KeyCode.Seven] = 7,
}
ContextActionService:BindActionAtPriority("SelectPetHotbarSlot", function(_, inputState, inputObject)
	if inputState == Enum.UserInputState.Begin then
		selectPetAtIndex(hotbarKeys[inputObject.KeyCode], true)
		return Enum.ContextActionResult.Sink
	end
	return Enum.ContextActionResult.Pass
end, false, Enum.ContextActionPriority.High.Value + 1,
	Enum.KeyCode.One,
	Enum.KeyCode.Two,
	Enum.KeyCode.Three,
	Enum.KeyCode.Four,
	Enum.KeyCode.Five,
	Enum.KeyCode.Six,
	Enum.KeyCode.Seven
)

ContextActionService:BindActionAtPriority("TogglePetInventory", function(_, inputState)
	if inputState == Enum.UserInputState.Begin then
		inventoryPanel.Visible = not inventoryPanel.Visible
		if inventoryPanel.Visible then
			renderPets()
		end
		return Enum.ContextActionResult.Sink
	end
	return Enum.ContextActionResult.Pass
end, false, Enum.ContextActionPriority.High.Value + 1, Enum.KeyCode.Tab, Enum.KeyCode.Backquote)

ContextActionService:BindActionAtPriority("ClosePetInventory", function(_, inputState)
	if inputState == Enum.UserInputState.Begin and inventoryPanel.Visible then
		inventoryPanel.Visible = false
		return Enum.ContextActionResult.Sink
	end
	return Enum.ContextActionResult.Pass
end, false, Enum.ContextActionPriority.High.Value + 1, Enum.KeyCode.Escape)

ContextActionService:UnbindAction("SelectPetHotbarSlot")
ContextActionService:UnbindAction("TogglePetInventory")
ContextActionService:UnbindAction("ClosePetInventory")

local messageNumber = 0
petAwarded.OnClientEvent:Connect(function(petName, _rarity, totalPets, income, passivePercent)
	messageNumber += 1
	local currentMessage = messageNumber

	rewardLabel.Text = string.format("Got %s\n+%.2f coins/s | passive +%d%%", petName, income or 0, passivePercent or 0)
	rewardLabel.Visible = true

	task.delay(3, function()
		if currentMessage == messageNumber then
			rewardLabel.Visible = false
		end
	end)
end)
