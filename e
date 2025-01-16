-- Anti-Stuck Feature
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Variables for detecting stuck state
local checkInterval = 1  -- Time interval between each check (in seconds)
local stuckThreshold = 5  -- Time duration for being stuck (in seconds)

local function isPlayerStuck(player)
    local character = player.Character
    if not character then return false end

    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return false end

    -- Check if the player has moved within the last "stuckThreshold" seconds
    local lastPosition = humanoidRootPart.Position
    local stuckTime = 0

    -- Check periodically if the player has moved
    while true do
        wait(checkInterval)
        if humanoidRootPart.Position == lastPosition then
            stuckTime = stuckTime + checkInterval
        else
            return false  -- Player has moved, so they are no longer stuck
        end

        -- If the player hasn't moved for the "stuckThreshold" duration, they are considered stuck
        if stuckTime >= stuckThreshold then
            return true
        end
    end
end

-- Function to handle unsticking the player
local function unstickPlayer(player)
    local character = player.Character
    if not character then return end

    -- You can implement actions like teleporting the player to a safe location or applying a force
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if humanoidRootPart then
        -- Teleport the player to a random location or a safe spot (e.g., spawn point)
        humanoidRootPart.CFrame = CFrame.new(Vector3.new(0, 100, 0))  -- Change this to the desired location
    end
end

-- Monitor players for being stuck
RunService.Heartbeat:Connect(function()
    for _, player in pairs(Players:GetPlayers()) do
        if isPlayerStuck(player) then
            unstickPlayer(player)
        end
    end
end)