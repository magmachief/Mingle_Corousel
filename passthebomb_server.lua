-- Server script to manage the game logic
local Players = game:GetService("Players")

-- Function to assign the bomb to a random player
local function assignBomb()
    local players = Players:GetPlayers()
    local randomPlayer = players[math.random(1, #players)]
    local bomb = Instance.new("Tool")
    bomb.Name = "Bomb"
    bomb.RequiresHandle = false
    bomb.Parent = randomPlayer.Backpack
    
    -- Add a Timer to the bomb
    local timer = Instance.new("NumberValue")
    timer.Name = "Timer"
    timer.Value = 30 -- Set the initial timer value
    timer.Parent = bomb
    
    return bomb
end

-- Periodically assign the bomb to a random player
while true do
    local bomb = assignBomb()
    wait(30) -- Wait for 30 seconds before reassigning the bomb
    if bomb and bomb.Parent then
        bomb:Destroy() -- Destroy the bomb after the timer expires
    end
end
