-- Client-side UI handling
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local updateEvent = ReplicatedStorage:WaitForChild("UpdatePlayerCount")

-- Wait for PlayerGui and ScreenGui to be available
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local screenGui = Instance.new("ScreenGui", playerGui)
local doorLabels = {}

-- Function to create labels for each door
local function createDoorLabel(doorName)
    local label = Instance.new("TextLabel")
    label.Name = doorName
    label.Size = UDim2.new(0, 200, 0, 50)
    label.Position = UDim2.new(0, 10, 0, (#doorLabels * 60) + 10)
    label.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Text = "Door " .. doorName .. ": 0 Players"
    label.Parent = screenGui
    doorLabels[doorName] = label
end

-- Update the UI when receiving data from the server
updateEvent.OnClientEvent:Connect(function(doorName, playerCount)
    if not doorLabels[doorName] then
        createDoorLabel(doorName)
    end
    doorLabels[doorName].Text = "Door " .. doorName .. ": " .. playerCount .. " Players"
end)

-- Notify the user
print("Mingle Carousel script with exact player requirements loaded successfully.")
