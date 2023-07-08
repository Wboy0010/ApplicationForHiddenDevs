local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.Knit)
local ProfileService = require(ServerScriptService.ServerPackages.ProfileService)
local PetSysPets = ReplicatedStorage.PetSystem.Pets

local ProfileTemplate = {
	RyzinBucks = 100000,
	Pets = { "Unicorn", "Robot 100" },
	PetStats = {
		{ speed = 29, strength = 25, exp = 0, rebirth = 0 },
		{ speed = 9, strength = 6, exp = 0, rebirth = 0 },
	},
	Potions = { exp = { ["Level 5"] = 8 } },
	EquipedPet = "",
}

local DefaultRarityStats = {
	Common = { speed = 9, strength = 6, exp = 0, rebirth = 0 },
	Rare = { speed = 13, strength = 10, exp = 0, rebirth = 0 },
	Epic = { speed = 20, strength = 16, exp = 0, rebirth = 0 },
	Legendary = { speed = 29, strength = 25, exp = 0, rebirth = 0 },
}

local PotionStatsPerLevel = {
	strength = {
		2,
		5,
		9,
		14,
		20,
	},
	speed = {
		3,
		6,
		10,
		15,
		21,
	},
	exp = {
		2,
		4,
		6,
		9,
		12,
	},
}

local DataService = Knit.CreateService({
	Name = "DataService",
	Client = {},
})

DataService.Profiles = {}

local ProfileStore = ProfileService.GetProfileStore("PlayersData", ProfileTemplate)

local function DoSomethingWithALoadedProfile(Player: Player, Profile: table)
	Player.leaderstats.RyzinBucks.Value = Profile.Data.RyzinBucks
end

--- Loads **Player's** Profile And Add's It To The Profiles Table
function DataService:PlayerAdded(Player: Player)
	print("Player added")
	local profile = ProfileStore:LoadProfileAsync(`Player_{Player.UserId}`)
	if profile ~= nil then
		profile:AddUserId(Player.UserId)
		profile:Reconcile()
		profile:ListenToRelease(function()
			self.Profiles[Player] = nil
			Player:Kick()
		end)
		if Player:IsDescendantOf(Players) == true then
			self.Profiles[Player] = profile
			DoSomethingWithALoadedProfile(Player, profile)
		else
			profile:Release()
		end
	else
		Player:Kick()
	end
end

--- Returns Boolean To Check If **Player's** Profile Is Loaded
function DataService:IsPlayerLoaded(Player: Player): boolean
	return self.Profiles[Player] ~= nil
end

----- RyzinBucks -----

--- Returns **Player's** RyzinBucks Data Value
function DataService:GetRyzinBucks(Player: Player): number
	local profileData = self.Profiles[Player].Data
	if profileData.RyzinBucks == nil then
		profileData.RyzinBucks = 0
	end

	return profileData.RyzinBucks
end

--- Set's The Given **Player's** RyzinBucks Data Value To The Given **Amount**
function DataService:SetRyzinBucks(Player: Player, Amount: number?)
	if typeof(Amount) == "number" then
		self.Profiles[Player].Data.RyzinBucks = Amount
		Player.leaderstats.RyzinBucks.Value = Amount
	else
		warn(`{debug.traceback()} type error, number expected, got {typeof(Amount)}`)
	end
end

--- Updates The Given **Player's** RyzinBucks By The Given **Amount**
function DataService:UpdateRyzinBucks(Player: Player, Amount: number?)
	if typeof(Amount) == "number" then
		self:SetRyzinBucks(Player, self:GetRyzinBucks(Player) + Amount)
	else
		warn(`{debug.traceback()} type error, number expected got {typeof(Amount)}`)
	end
end

----- Potions -----

--- Returns **Player's** Potions Table
function DataService:GetPotions(Player: Player): table
	return self.Profiles[Player].Data.Potions
end

--- Returns The Amount Of **Player's** Potions With The Type Of **PotionType** And Level Of *Level**
function DataService:GetPotionsOfLevel(Player: Player, PotionType: string, Level: number): number
	local potions = self.Profiles[Player].Data.Potions[PotionType]
	if potions then
		return potions["Level " .. Level] or 0
	end

	return 0
end

--- Sets The Amount Of **Player's** Potions With The Type Of **PotionType** And Level Of *Level** To The Value Of **Amount**
function DataService:SetPotionsOfLevel(Player: Player, PotionType: string, Level: number, Amount: number)
	local potions = self.Profiles[Player].Data.Potions[PotionType]
	if not potions then
		self.Profiles[Player].Data.Potions[PotionType] = {}
		potions = self.Profiles[Player].Data.Potions[PotionType]
	end
	if Amount <= 0 then
		potions["Level " .. Level] = nil
	else
		potions["Level " .. Level] = Amount
	end
end

--- Adds **Amount** To The Amount Of **Player's** Potions With The Type Of **PotionType** And Level Of *Level**
function DataService:AddPotionOfLevel(Player: Player, PotionType: string, Level: number, Amount: number)
	Amount = Amount or 1

	local current = self:GetPotionsOfLevel(Player, PotionType, Level)
	self:SetPotionsOfLevel(Player, PotionType, Level, current + Amount)
end

--- Returns **Potion's** Stats With The Given **Level*
function DataService:GetPotionStats(PotionType, Level: number): number
	return PotionStatsPerLevel[PotionType][tonumber(Level)]
end
----- Pets -----

--- Returns **Player's** Pets Table
function DataService:GetPets(Player: Player): table
	return self.Profiles[Player].Data.Pets
end

--- Returns **Player's** Pet In The Given Table **Position**
function DataService:GetPetInPos(Player: Player, Position: number): string?
	return self.Profiles[Player].Data.Pets[Position]
end

--- Checks If **Player** Has A Pet With The Name Of **PetName** In The Given Table **Position**
function DataService:HasPetInPos(Player: Player, PetName: string, Position: number): boolean
	local pet = self:GetPetInPos(Player, Position)

	return pet ~= nil and pet == PetName
end

--- Checks If **Player** Has A Pet With The Given **PetName**
function DataService:HasPet(Player: Player, PetName: string): boolean
	return table.find(self.Profiles[Player].Data.Pets, PetName) ~= nil
end

--- Adds A Pet With The Name Of **PetName** To The **Player's** Inventory
function DataService:AddPet(Player: Player, PetName: string)
	local pets = self.Profiles[Player].Data.Pets
	table.insert(pets, PetName)
	table.insert(
		self.Profiles[Player].Data.PetStats,
		table.find(pets, PetName),
		self:GetPetStatsFromRarity(Player, PetName)
	)
end

--- Removes Pet From **Player** At Table Index Of **Position** And Name Of **PetName**
function DataService:RemovePetAtPos(Player: Player, PetName: string, Position: number)
	local pets = self.Profiles[Player].Data.Pets
	local petstats = self.Profiles[Player].Data.PetStats
	table.remove(pets, Position)
	table.remove(petstats, Position)
	if self:GetEquipedPet(Player) == PetName then
		self:UnequipPet(Player)
	end
end

--- Removes Pet From **Player's** Inventory With The Name Of **PetName**
function DataService:RemovePet(Player: Player, PetName: string)
	local pets = self.Profiles[Player].Data.Pets
	local pos = table.find(pets, PetName)

	self:RemovePetAtPos(Player, PetName, pos)
end

--- Returns The Pet's Rarity With The Given **PetName**
function DataService:GetPetRarity(PetName: string): string?
	local petModel = PetSysPets:FindFirstChild(PetName, true)
	if petModel then
		return petModel.Parent.Name
	end
	return nil
end

--- Returns **Player's** Pet With The Name Of **PetName** Default Stats By It's Rarity
function DataService:GetPetStatsFromRarity(Player: Player, PetName: string): table?
	local rarity = self:GetPetRarity(PetName)

	if rarity then
		return DefaultRarityStats[rarity]
	end

	return nil
end

--- Returns **Player's** Pet Stats With The Name Of **PetName**
function DataService:GetPetStats(Player: Player, PetName: string): table?
	local pos = table.find(self.Profiles[Player].Data.Pets, PetName)
	return self.Profiles[Player].Data.PetStats[pos]
end

--- Adds **Amount** Of Exp To The Given **Player's** Pet With The Name Of **PetName**
function DataService:AddPetXp(Player: Player, PetName: string, Amount: number)
	local profileData = self.Profiles[Player].Data
	local pos = table.find(profileData.Pets, PetName)
	local pet = profileData.PetStats[pos]
	pet["exp"] += Amount
	pet["rebirth"] = pet["rebirth"] or 0
	local lvlexp = pet["rebirth"] * 40 + 200
	if pet["exp"] >= lvlexp then
		local rarity = self:GetPetRarity(PetName)

		pet["speed"] += 1
		pet["strength"] += 1
		if rarity == "Epic" or rarity == "Legendary" then
			pet["speed"] += 1
			pet["strength"] += 1
		end
		pet["rebirth"] += 1
		pet["exp"] -= lvlexp
		if pet["rebirth"] % 10 == 0 then
			if rarity == "Common" then
				pet["speed"] += 5
				pet["strength"] += 5
			elseif rarity == "Rare" then
				pet["speed"] += 9
				pet["strength"] += 9
			elseif rarity == "Epic" then
				pet["speed"] += 15
				pet["strength"] += 15
			elseif rarity == "Legendary" then
				pet["speed"] += 20
				pet["strength"] += 20
			end
		end
	end
end

----- Equiped Pets -----

--- Returns The Name Of **Player's** Equipped Pet
function DataService:GetEquipedPet(Player: Player): string
	return self.Profiles[Player].Data.EquipedPet
end

--- Equips Pet With The Name Of **Pet**
function DataService:EquipPet(Player: Player, Pet: string)
	if self:HasPet(Player, Pet) then
		self.Profiles[Player].Data.EquipedPet = Pet
	end
end

--- Unequips Pet From **Player**
function DataService:UnequipPet(Player: Player)
	self.Profiles[Player].Data.EquipedPet = ""
	if Player.Character:FindFirstChild("Pet") then
		Player.Character.Pet:Destroy()
	end
end

------------- CLIENT ----------

----- Pets ------

function DataService.Client:GetPets(Player: Player): table
	return self.Server:GetPets(Player)
end

function DataService.Client:GetPetStats(plr, petName)
	return self.Server:GetPetStats(plr, petName)
end

----- Knit innit -----

function DataService:KnitInit()
	game:GetService("Players").PlayerRemoving:Connect(function(plr)
		local profile = self.Profiles[plr]
		if profile ~= nil then
			profile:Release()
		end
	end)

	for _, plr in ipairs(Players:GetPlayers()) do
		task.spawn(self:PlayerAdded(plr))
	end

	Players.PlayerAdded:Connect(function(plr)
		self:PlayerAdded(plr)
	end)
end

return DataService
