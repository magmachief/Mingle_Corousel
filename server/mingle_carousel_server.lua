-- Load required services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")

-- Create RemoteEvent for UI updates
local updateEvent = Instance.new("RemoteEvent")
updateEvent.Name = "UpdatePlayerCount"
updateEvent.Parent = ReplicatedStorage

-- Configuration
local totalDoors = 35 -- Total number of doors
local doors = {}
local playerDoorAssignments = {}

-- Initialize doors and load required player data from game
for i = 1, totalDoors do
    local doorName = tostring(i) -- Doors are named numerically
    local door = Workspace:FindFirstChild(doorName)
    if door then
        doors[doorName] = door

        -- Ensure the door has a RequiredPlayers value (e.g., IntValue)
        local requiredPlayers = door:FindFirstChild("RequiredPlayers") or Instance.new("IntValue")
        requiredPlayers.Name = "RequiredPlayers"
        requiredPlayers.Value = math.random(2, 5) -- Random required players between 2 and 5 for each door
        requiredPlayers.Parent = door
        
        -- Create a BoolValue to handle the door open/close state
        local doorClosed = door:FindFirstChild("DoorClosed") or Instance.new("BoolValue")
        doorClosed.Name = "DoorClosed"
        doorClosed.Value = false
        doorClosed.Parent = door
    else
        warn("Door " .. doorName .. " not found in Workspace!")
    end
end

-- Function to find the nearest door for a player
local function getNearestDoor(player)
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        return nil
    end

    local humanoidRootPart = player.Character.HumanoidRootPart
    local nearestDoor = nil
    local shortestDistance = math.huge

    for doorName, door in pairs(doors) do
        local distance = (humanoidRootPart.Position - door.Position).Magnitude
        if distance < shortestDistance then
            shortestDistance = distance
            nearestDoor = doorName
        end
    end

    return nearestDoor
end

-- Function to push players out of a door's area
local function pushPlayersOut(door, players)
    for _, player in pairs(players) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local humanoidRootPart = player.Character.HumanoidRootPart
            local force = Instance.new("BodyVelocity")
            force.MaxForce = Vector3.new(5000, 5000, 5000)
            force.Velocity = (humanoidRootPart.Position - doors[door].Position).Unit * 100 -- Push force
            force.Parent = humanoidRootPart
            Debris:AddItem(force, 0.1)
        end
    end
end

-- Function to close the door
local function closeDoor(door)
    if door:FindFirstChild("DoorClosed") then
        door.DoorClosed.Value = true
        -- Code to visually close the door (e.g., moving parts, changing transparency, etc.)
        -- Example:
        door.Transparency = 1
        for _, part in pairs(door:GetChildren()) do
            if part:IsA("BasePart") then
                part.Transparency = 1
            end
        end
    end
end

-- Main server-side loop for door management
spawn(function()
    while true do
        -- Reset player counts for each door
        local doorPlayerCounts = {}
        local playersToPush = {}

        for doorName in pairs(doors) do
            doorPlayerCounts[doorName] = 0
        end

        -- Reassign players to their nearest door
        for _, player in pairs(Players:GetPlayers()) do
            local nearestDoor = getNearestDoor(player)
            if nearestDoor then
                playerDoorAssignments[player] = nearestDoor
                doorPlayerCounts[nearestDoor] = doorPlayerCounts[nearestDoor] + 1

                -- Check if door exceeds its required players
                local requiredPlayers = doors[nearestDoor]:FindFirstChild("RequiredPlayers")
                if requiredPlayers and doorPlayerCounts[nearestDoor] > requiredPlayers.Value then
                    playersToPush[nearestDoor] = playersToPush[nearestDoor] or {}
                    table.insert(playersToPush[nearestDoor], player)
                end

                -- Close door if required players are met
                if requiredPlayers and doorPlayerCounts[nearestDoor] == requiredPlayers.Value then
                    closeDoor(doors[nearestDoor])
                end
            end
        end

        -- Push players out of overcrowded doors
        for doorName, players in pairs(playersToPush) do
            pushPlayersOut(doorName, players)
        end

        -- Notify clients about player counts
        for doorName, playerCount in pairs(doorPlayerCounts) do
            updateEvent:FireAllClients(doorName, playerCount)
        end

        wait(1) -- Adjust as needed
    end
end)
