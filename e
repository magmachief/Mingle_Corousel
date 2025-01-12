-- Initialize debounce to prevent multiple touches
local debounce = false

-- Select a random player from 'CurrentlyPlaying' group
local players = workspace.CurrentlyPlaying:GetChildren()
local currentplayer = players[math.random(1, #players)]

-- Clone the bomb from ReplicatedStorage and parent it to the selected player
local bomb = game.ReplicatedStorage.Maps["Pass The Bomb"].Bomb:Clone()
bomb.Parent = currentplayer -- bomb is a BillboardGUI

-- Disable jumping for all players
for _, v in pairs(players) do
    v.Humanoid.JumpPower = 0
end

-- Function to handle bomb explosion after a delay
task.spawn(function()
    while wait(10) do
        local explosion = Instance.new("Explosion", workspace)
        explosion.DestroyJointRadiusPercent = 0
        explosion.ExplosionType = Enum.ExplosionType.NoCraters
        explosion.Position = currentplayer.Torso.Position
        currentplayer.Humanoid.Health = 0
        wait(1)
        explosion:Destroy()
    end
end)

-- This variable will hold the current event connections for the bomb change and player death
local curEvent
local deathEvent

-- Function to handle bomb change when the bomb touches another player
local function bombChange(hit)
    if hit and hit.Parent:FindFirstChild("Humanoid") then
        if debounce == false then
            debounce = true
            currentplayer = hit.Parent
            bomb.Parent = currentplayer
            -- Disconnect previous events
            if curEvent then curEvent:Disconnect() end
            if deathEvent then deathEvent:Disconnect() end
            -- Connect new events
            curEvent = currentplayer.Torso.Touched:Connect(bombChange)
            deathEvent = currentplayer.Humanoid.Died:Connect(onPlayerDied)
            wait(0.5)
            debounce = false
        end
    end
end

-- Function to handle player death
local function onPlayerDied()
    -- Select a new random player
    local players = workspace.CurrentlyPlaying:GetChildren()
    if #players > 1 then
        repeat
            currentplayer = players[math.random(1, #players)]
        until currentplayer ~= nil and currentplayer.Humanoid.Health > 0
        bomb.Parent = currentplayer
        -- Disconnect previous events
        if curEvent then curEvent:Disconnect() end
        if deathEvent then deathEvent:Disconnect() end
        -- Connect new events
        curEvent = currentplayer.Torso.Touched:Connect(bombChange)
        deathEvent = currentplayer.Humanoid.Died:Connect(onPlayerDied)
    end
end

-- Connect the bomb change function to the current player's torso touch event
curEvent = currentplayer.Torso.Touched:Connect(bombChange)

-- Connect the player death function to the current player's Humanoid.Died event
deathEvent = currentplayer.Humanoid.Died:Connect(onPlayerDied)

-- Cleanup the bomb when the current map is destroyed
workspace:FindFirstChild("CurrentMap").Destroying:Connect(function()
    bomb:Destroy()
end)

-- Wait until only one player remains in the 'CurrentlyPlaying' group
repeat wait() until #workspace.CurrentlyPlaying:GetChildren() == 1

-- End the game
game.ReplicatedStorage.Values.EndGame.Value = true

-- Create a GUI to indicate the script is running
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BombCheatGui"
screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Parent = screenGui
titleLabel.Size = UDim2.new(0, 200, 0, 50)
titleLabel.Position = UDim2.new(0.5, -100, 0, 10)
titleLabel.Text = "Pass the Bomb Cheat"
titleLabel.TextColor3 = Color3.new(1, 1, 1)
titleLabel.BackgroundColor3 = Color3.new(0, 0, 0)
titleLabel.TextScaled = true
