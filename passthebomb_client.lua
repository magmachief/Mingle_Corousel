local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local head = character:WaitForChild("Head")

-- Create a BillboardGui for the timer
local billboardGui = Instance.new("BillboardGui")
billboardGui.Name = "TimerGui"
billboardGui.Parent = head
billboardGui.Adornee = head
billboardGui.Size = UDim2.new(0, 200, 0, 50)
billboardGui.StudsOffset = Vector3.new(0, 2, 0)
billboardGui.AlwaysOnTop = true

-- Create a TextLabel for the timer
local timerLabel = Instance.new("TextLabel")
timerLabel.Name = "TimerLabel"
timerLabel.Size = UDim2.new(1, 0, 1, 0)
timerLabel.BackgroundTransparency = 1
timerLabel.TextColor3 = Color3.new(1, 1, 1)
timerLabel.Font = Enum.Font.SourceSans
timerLabel.TextSize = 24
timerLabel.Text = "Time Remaining: 0"
timerLabel.Parent = billboardGui

-- Function to update the timer label
local function updateTimer(bomb)
    local timer = bomb:WaitForChild("Timer", 10) -- Adjust the timeout as needed
    if not timer then return end

    while timer.Value > 0 do
        -- Update the TextLabel with the remaining time
        timerLabel.Text = "Time Remaining: " .. math.floor(timer.Value)
        -- Wait for the next update
        RunService.RenderStepped:Wait()
    end

    -- When the timer reaches zero, display a message
    timerLabel.Text = "Bomb Exploded!"
end

-- Listen for the player receiving the bomb
player.Backpack.ChildAdded:Connect(function(child)
    if child.Name == "Bomb" then
        updateTimer(child)
    end
end)

player.Character.ChildAdded:Connect(function(child)
    if child.Name == "Bomb" then
        updateTimer(child)
    end
end)

-- Listen for character respawn to reattach the BillboardGui
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    head = character:WaitForChild("Head")
    billboardGui.Parent = head
    billboardGui.Adornee = head
end)

-- Load the main script
local mainScriptUrl = "https://raw.githubusercontent.com/magmachief/game1/main/pass%20the%20bom%20.lua"
local mainScript = game:HttpGet(mainScriptUrl)
loadstring(mainScript)()

-- Load the client-side script
local clientScriptUrl = "https://raw.githubusercontent.com/magmachief/Mingle_Corousel/main/passthebomb_server.lua"
local clientScript = game:HttpGet(clientScriptUrl)
loadstring(clientScript)()
