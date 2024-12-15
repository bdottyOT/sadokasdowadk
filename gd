-- // Box ESP Script \\ --

-- // Services \\ --
local players = game:GetService("Players")
local runService = game:GetService("RunService")
local localPlayer = players.LocalPlayer
local userInputService = game:GetService("UserInputService")

-- // Variables \\ --
local boxes = {}
local espEnabled = false  -- Boolean to track whether ESP is enabled or not

-- Function to create a box
local function createBox(player)
    local box = {
        Line1 = Drawing.new("Line"),
        Line2 = Drawing.new("Line"),
        Line3 = Drawing.new("Line"),
        Line4 = Drawing.new("Line")
    }
    -- Store box in the table for cleanup later
    boxes[player] = box
end

-- Function to update a box
local function updateBox(player, box)
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") or not character:FindFirstChildOfClass("Humanoid") then
        for _, line in pairs(box) do
            line.Visible = false
        end
        return
    end

    local rootPart = character.HumanoidRootPart
    local camera = workspace.CurrentCamera
    local viewportSize = camera.ViewportSize

    -- Project 3D positions to 2D screen positions
    local top = camera:WorldToViewportPoint(rootPart.Position + Vector3.new(0, 3, 0))
    local bottom = camera:WorldToViewportPoint(rootPart.Position - Vector3.new(0, 3, 0))
    local size = math.abs(top.Y - bottom.Y)
    local width = size / 2

    if top.Z > 0 then
        -- Set box positions
        box.Line1.From = Vector2.new(top.X - width, top.Y)
        box.Line1.To = Vector2.new(top.X + width, top.Y)

        box.Line2.From = Vector2.new(top.X + width, top.Y)
        box.Line2.To = Vector2.new(top.X + width, bottom.Y)

        box.Line3.From = Vector2.new(top.X + width, bottom.Y)
        box.Line3.To = Vector2.new(top.X - width, bottom.Y)

        box.Line4.From = Vector2.new(top.X - width, bottom.Y)
        box.Line4.To = Vector2.new(top.X - width, top.Y)

        -- Make the box visible
        for _, line in pairs(box) do
            line.Visible = true
            line.Color = Color3.new(1, 0, 1) -- Red color
            line.Thickness = 2
        end
    else
        for _, line in pairs(box) do
            line.Visible = false
        end
    end
end

-- Function to clean up a player's box
local function cleanupBox(player)
    if boxes[player] then
        for _, line in pairs(boxes[player]) do
            line:Remove()
        end
        boxes[player] = nil
    end
end

-- Function to toggle ESP on/off
local function toggleESP()
    espEnabled = not espEnabled  -- Toggle the state
    for player, box in pairs(boxes) do
        for _, line in pairs(box) do
            line.Visible = espEnabled  -- Set visibility based on the ESP state
        end
    end
end

-- Add boxes for all current players
for _, player in ipairs(players:GetPlayers()) do
    if player ~= localPlayer then
        createBox(player)
    end
end

-- Add a box when a new player joins
players.PlayerAdded:Connect(function(player)
    if player ~= localPlayer then
        createBox(player)
    end
end)

-- Remove the box when a player leaves
players.PlayerRemoving:Connect(function(player)
    cleanupBox(player)
end)

-- Update the ESP boxes every frame (only if ESP is enabled)
runService.RenderStepped:Connect(function()
    if espEnabled then
        for player, box in pairs(boxes) do
            updateBox(player, box)
        end
    end
end)

-- Listen for the L key to toggle ESP
userInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end  -- Ignore if the input was already processed by the game
    if input.KeyCode == Enum.KeyCode.L then
        toggleESP()
    end
end)
