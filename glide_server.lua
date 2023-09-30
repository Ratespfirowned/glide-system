local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--config

local JumpForce = 100 --how high the character jumps
local GlideForce = 2750 --the upward-force that goes against gravity to keep the character gliding
local NormalJumpForce = 50 --default humanoid jump force
local AbilityCooldown = 10 --seconds in between ability activation
----


local OnAbilityCooldown = {}

local AbilityTag = "CanActivateAbility"

 --cooldown for ability

Players.PlayerAdded:Connect(function(player)
	CollectionService:AddTag(player, AbilityTag)
end)

RunService.Heartbeat:Connect(function()
	for i, player in pairs(Players:GetPlayers()) do
		if OnAbilityCooldown[player.Name]  then
			--is on a cooldown
			if CollectionService:HasTag(player, AbilityTag) then
				--has a tag? remove it
				CollectionService:RemoveTag(player, AbilityTag)
			end
			
			if os.time() - OnAbilityCooldown[player.Name] >= AbilityCooldown then
				--cooldown ended, grant ability
				CollectionService:AddTag(player, AbilityTag)
				print("cooldown ended, remove tag")
				OnAbilityCooldown[player.Name] = nil
			end
		end 
	end
end)

ReplicatedStorage.ActivateAbility.OnServerEvent:Connect(function(player)
	if player and CollectionService:HasTag(player, AbilityTag) and OnAbilityCooldown[player.Name] == nil then
		--can activate ability, use it and put player on cooldown
		print(player.Name .. " used the ability, they are now on cooldown!")
		CollectionService:RemoveTag(player, AbilityTag)
		OnAbilityCooldown[player.Name] = os.time()
		
		local char = player.Character
		
		local Force = Instance.new("VectorForce")
		Force.Parent = char.HumanoidRootPart
		Force.Attachment0 = player.Character.HumanoidRootPart.RootAttachment
		Force.Force = Vector3.new(0,0,0)
		
		--make player fly
		
		char.Humanoid.JumpPower = JumpForce
		
		char.Humanoid.Jump = true
		
		local FlyAnim = char.Humanoid:LoadAnimation(ReplicatedStorage.GlideAnimations.Fly)
		FlyAnim:Play()
		
		local GlideAnim = char.Humanoid:LoadAnimation(ReplicatedStorage.GlideAnimations.Glide)
		
		
		local connection
		
		connection = char.Humanoid.StateChanged:Connect(function()
			if char.Humanoid:GetState() == Enum.HumanoidStateType.Freefall then

				print("falling")
				
				char.Humanoid.HipHeight = .7
				
				GlideAnim:Play()
				
				char.Humanoid.JumpPower = NormalJumpForce
				
				wait(.5)
				
				Force.Force = Vector3.new(0,GlideForce,0)
				
				wait(.2)
				
				GlideAnim:AdjustSpeed(0)

				--is falling
				char.Humanoid.StateChanged:Wait()

				print("landed")
				
				Force:Destroy()
				
				GlideAnim:Stop()
				char.Humanoid.HipHeight = 2
				
				char.Humanoid.WalkSpeed = 0
				wait()
				char.Humanoid.WalkSpeed = 16
				
				connection:Disconnect()
			end
		end)
	end
end)
