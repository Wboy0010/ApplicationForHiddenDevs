
--[[
      
     _____                     ____     ___      _____________     __________     __________        ___
    |   \ \                   /   |\   /   \    |____     ____|\  |  ________|\  |    ___   \      |   \\
     \   \ \                 /   / /  /     \    \___|   |\ ___\| | |\________\| |   | / |   |     |  _//   ___    ___
      \   \ \     ___       /   / /  /   _   \       |   | |      | | |          |   |/ /   /      |   \\  |   |  |  ||
       \   \ \   /   \.    /   / /  /   / \   \      |   | |      | |_|____      |   |/   /\       |___//  |   |  |  ||
        \   \      _      /   / /  /   /_/_\   \     |   | |      |  ______|\    |        \ \       \__\|   \  \  / //
         \   \    / \    /   / /  /    _____    \    |   | |      | |_______\|   |    /\   \ \       ___     \   | //
          \   .  / / \  .   / /  /    / /   \    \   |   | |      | |________    |   | |\   \ \     /   \\    |   ||
           \____/ /   \____/ /  /____/ /     \____\  |___| |      |__________|\  |___| | \___\ \    | | | |   |   ||
            \___\|     \___\|   \_____\|      \____\  \___\|       \___________\| \___\/  \___|/    \___/ /   |___||
                                                  Copyright ⓒ 2023 -> Waterboy                      \___\|    \__\|
                                                  
    [2023 August]
    
    @  .water_boy / (robloxusername)		(Creator)
    
]]

--------------------------------SERVICES----------------------------------------------------------------
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local JumpAffect = SoundService.Master.SoundEffects.Mario_Jump
local MPS = game:GetService("MarketplaceService")

-- // Remotes
local remotes = ReplicatedStorage.Shared.Remotes

local ClientInifiniteJumps = remotes.ClientInifiniteJump

-- Table
local ClientHandler = {}

------------------------------[Default Client]---------------------------------------------------------------
function ClientHandler.Jumps()
	----------------------------------ALL PLAYERS SETUP-----------------------------------------------------
	local function SetupCharacter()
		local Char = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
		
		local HumanoidRootPart = Char:WaitForChild("HumanoidRootPart")
		local humanoid = Char:WaitForChild("Humanoid")
		local RightFoot = Char:WaitForChild("RightFoot")
		local LeftFoot = Char:WaitForChild("LeftFoot")

		local Jumping = Enum.HumanoidStateType.Jumping;
		local falling = Enum.HumanoidStateType.Freefall;
		local landed =  Enum.HumanoidStateType.Landed;

		local DoubleJump = false;
		local JumpCount = 0;


		local cloudEmitter = Instance.new("ParticleEmitter")
		cloudEmitter.Texture = "http://www.roblox.com/asset/?id=149185730"
		cloudEmitter.Lifetime = NumberRange.new(1, 2)
		cloudEmitter.Size = NumberSequence.new(1, 2)
		cloudEmitter.Rate = 50
		cloudEmitter.Speed = NumberRange.new(0, 0)
		cloudEmitter.Rotation = NumberRange.new(0, 360)
		cloudEmitter.SpreadAngle = Vector2.new(360, 360)
		cloudEmitter.Parent = LeftFoot
		cloudEmitter.Enabled = false

		humanoid.StateChanged:Connect(function(old,new)
			if (old == falling) and (new == landed) then -- [Client Character on land]
				DoubleJump = false;
				JumpCount = 0;
				return;
			end

			if (old == Jumping) and (new == falling) then -- [Client Character Falls]
				DoubleJump = true;
				JumpCount = JumpCount + 1
			end

		end)

		UserInputService.InputBegan:Connect(function(inp, gpe)
			if gpe then
				return
			end

			if inp.KeyCode == Enum.KeyCode.Space then
				if(DoubleJump and JumpCount <3) then
					DoubleJump = false;
					warn("PLAYER USED EXTRA JUMPS")
					JumpAffect:Play()
					cloudEmitter.Enabled = true
					cloudEmitter:Emit(5)
					cloudEmitter.Enabled = false
					cloudEmitter.Parent = RightFoot
					-- Jump effect under the player's legs here
					humanoid:ChangeState(Jumping);
				end
			end
		end)
	end
	--------------------------------[End of Default Client functions]---------------------------------------


	----------------------------[Client Four Jumps Product Handler]-----------------------------------------
	function ClientHandler.FourJumps()

		--local function FourJumpsProduct(char)
			
			local char = Players.LocalPlayer.Character
			
			local HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
			local humanoid = char:WaitForChild("Humanoid")
			local RightFoot = char:WaitForChild("RightFoot")
			local LeftFoot = char:WaitForChild("LeftFoot")

			local Jumping = Enum.HumanoidStateType.Jumping;
			local falling = Enum.HumanoidStateType.Freefall;
			local landed =  Enum.HumanoidStateType.Landed;

			local DoubleJump = false;
			local JumpCount = 0;


			local cloudEmitter = Instance.new("ParticleEmitter")
			cloudEmitter.Texture = "http://www.roblox.com/asset/?id=149185730"
			cloudEmitter.Lifetime = NumberRange.new(1, 2)
			cloudEmitter.Size = NumberSequence.new(1, 2)
			cloudEmitter.Rate = 50
			cloudEmitter.Speed = NumberRange.new(0, 0)
			cloudEmitter.Rotation = NumberRange.new(0, 360)
			cloudEmitter.SpreadAngle = Vector2.new(360, 360)
			cloudEmitter.Parent = LeftFoot
			cloudEmitter.Enabled = false

			humanoid.StateChanged:Connect(function(old,new)
				if (old == falling) and (new == landed) then -- [Client Character on land]
					DoubleJump = false;
					JumpCount = 0;
					return;
				end

				if (old == Jumping) and (new == falling) then -- [Client Character Falls]
					DoubleJump = true;
					JumpCount = JumpCount + 1
				end

			end)

			UserInputService.InputBegan:Connect(function(inp, gpe)
				if gpe then
					return
				end

				if inp.KeyCode == Enum.KeyCode.Space then
					if(DoubleJump and JumpCount < 4) then
						DoubleJump = false;
						warn("PLAYER USED EXTRA JUMPS")
						JumpAffect:Play()
						cloudEmitter.Enabled = true
						cloudEmitter:Emit(5)
						cloudEmitter.Enabled = false
						cloudEmitter.Parent = RightFoot
						-- Jump effect under the player's legs here
						humanoid:ChangeState(Jumping);
					end
				end
			end)

		--end

	end
	-------------------------------[END OF Client Four Jumps Product Handler]-------------------------------

	-------------------------------[INFINITE JUMPS PRODUCT HANDLER]-------------------------------------------

	function ClientHandler.InfiniteJumps()

		--local function InfiniteJumpsProduct(char)
			
			local char = Players.LocalPlayer.Character
			
			local HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
			local humanoid = char:WaitForChild("Humanoid")
			local LeftFoot = char:WaitForChild("LeftFoot")

			local Jumping = Enum.HumanoidStateType.Jumping;
			local falling = Enum.HumanoidStateType.Freefall;
			local landed =  Enum.HumanoidStateType.Landed;

			local DoubleJump = false;
			local JumpCount = 0;


			local cloudEmitter = Instance.new("ParticleEmitter")
			cloudEmitter.Texture = "http://www.roblox.com/asset/?id=149185730"
			cloudEmitter.Lifetime = NumberRange.new(1, 2)
			cloudEmitter.Size = NumberSequence.new(1, 2)
			cloudEmitter.Rate = 50
			cloudEmitter.Speed = NumberRange.new(0, 0)
			cloudEmitter.Rotation = NumberRange.new(0, 360)
			cloudEmitter.SpreadAngle = Vector2.new(360, 360)
			cloudEmitter.Parent = LeftFoot
			cloudEmitter.Enabled = false

			humanoid.StateChanged:Connect(function(old,new)
				if (old == falling) and (new == landed) then -- [Client Character on land]
					DoubleJump = false;
					JumpCount = 0;
					return;
				end

				if (old == Jumping) and (new == falling) then -- [Client Character Falls]
					DoubleJump = true;
					JumpCount = JumpCount + 1
				end

			end)

			UserInputService.InputBegan:Connect(function(inp, gpe)
				if gpe then
					return
				end

				if inp.KeyCode == Enum.KeyCode.Space then
					if(DoubleJump and JumpCount < 90*4) then
						DoubleJump = false;
						warn("PLAYER USED EXTRA JUMPS inf")
						JumpAffect:Play()
						cloudEmitter.Enabled = true
						cloudEmitter:Emit(5)
						cloudEmitter.Enabled = false
						cloudEmitter.Parent = LeftFoot
						-- Jump effect under the player's legs here
						humanoid:ChangeState(Jumping);
					end
				end
			end)

		--end

	end	

	-------------------------------[END OF INFINITE JUMPS PRODUCT HANDLER ]-----------------------------------
	
	
	-------------------------------------[CLIENT INIT]----------------------------------------------------
	--for _, player in ipairs(Players:GetPlayers()) do   <-- what the fuck??? this is a client script
	--	player.CharacterAdded:Connect(function(Char)
	--		SetupCharacter(Char)
	--	end)
	--end
	SetupCharacter()
	
	print("waiting")
	ClientInifiniteJumps.OnClientEvent:Connect(function()
		print('got')
		ClientHandler.InfiniteJumps()
	end)


end

return ClientHandler
