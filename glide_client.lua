local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Player = game:GetService("Players").LocalPlayer

UserInputService.InputBegan:Connect(function(input, boolean)
	if input.KeyCode == Enum.KeyCode.V and boolean == false and CollectionService:HasTag(Player, "CanActivateAbility") then
		print("Activated Ability!")
		
		ReplicatedStorage.ActivateAbility:FireServer()
	end
end)
