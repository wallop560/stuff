repeat wait() until game:IsLoaded()
local InactivityForServerHop = getgenv().ServerHopTime

local BoothTxt = getgenv().BoothMsg

local Util = loadstring(game:HttpGet('https://raw.githubusercontent.com/wallop560/Wallops-Admin/main/Util.lua'))()


local HttpRequest = (syn and syn.request) or http and http.request or http_request or (fluxus and fluxus.request) or request
local Players = game:GetService('Players')
local leaderstats = Players.LocalPlayer:WaitForChild('leaderstats')
local Raised = leaderstats:WaitForChild('Raised')
Raised = Raised.Value

local remotes = require(game:GetService('ReplicatedStorage'):WaitForChild('Remotes'))
local httpservice = game:GetService('HttpService')
local VU = game:GetService("VirtualUser")
local TPS = game:GetService('TeleportService')

local url = getgenv().webhook
local ThxMsg = {
    'thanks',
    'ty',
    'tysm',
    'omg thanks',
    'Ty',
    ':D ty',
    'wow thanks'
}
local AFKMsg = {
    'Pls donate',
    'Donations appreciated.',
    'ow',
    'pls',
    'afk til donation'
}

function send(content)
    HttpRequest({
        Url = url,
        Body = [[{
  "username": "wallops admin",
  "avatar_url": "https://i.ebayimg.com/images/g/6dwAAOSwxFVdksUm/s-l500.jpg",
  "content": " ",
  "embeds": [
    {
      "title": "Starving artist donation",
      "color": 1048395,
      "description": "]]..tostring(content)..[[",
      "author": {
        "name": "Wallops admin",
        "icon_url": "https://i.ebayimg.com/images/g/6dwAAOSwxFVdksUm/s-l500.jpg"
      },
      "image": {},
      "thumbnail": {},
      "footer": {
        "text": "wallops admin ¦ made by le birdo#2221"
      },
      "fields": []
    }
  ],
  "components": []
}]],
        Method = "POST",
        Headers = {["content-type"] = "application/json"}
    })
end
local OwnedBooth
for _,v in pairs((((game:GetService("Players").consuary.PlayerGui:WaitForChild('MapUIContainer')):WaitForChild('MapUI')):WaitForChild('BoothUI')):GetChildren()) do
    v:WaitForChild('Details')
    v.Details:WaitForChild('Owner')
    local BoothNumber = tonumber(v.Name:sub(8,#v.Name))
    local Claimed = v.Details.Owner.Text ~= 'unclaimed'
    
    if not Claimed then
        OwnedBooth = BoothNumber
        remotes.Function('ClaimBooth'):InvokeServer(OwnedBooth)
        repeat wait() until v.Details.Owner.Text ~= 'unclaimed'
        game.Players.LocalPlayer.Character.PrimaryPart.CFrame = v.Details.Adornee.CFrame * CFrame.new(-v.Details.Adornee.Size.X-1,0,0) * CFrame.Angles(0,math.rad(90),0)
        remotes.Event('SetBoothText'):FireServer(BoothTxt,'booth')
        break
    end
end
local timer = 0
Players.LocalPlayer.leaderstats.Raised.Changed:Connect(function()
    timer = 0
    local NewRaised = Players.LocalPlayer.leaderstats.Raised.Value
    local dif = NewRaised-Raised
    Raised = NewRaised
    
    spawn(function()
        wait(math.random(80,150)/100)
        local msg = ThxMsg[math.random(1,#ThxMsg)]
        
        game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(msg,'All')
    end)
    
    local LogService = Game:GetService("LogService")
    local logs = LogService:GetLogHistory()
    
    if string.find(logs[#logs].message,game.Players.LocalPlayer.DisplayName) then
        send(logs[#logs].message..' {Total: '..tostring(Raised)..'}')
    else
        send('Someone donated '..tostring(dif)..' {Total: '..tostring(Raised)..'}')
    end
end)

local function serverhop()
    local MinimumPeople = 20
    local TotalServers = Util.GetServers(game.PlaceId)

    local ViableServers = {}

    for _,Server in next,TotalServers do
        if Server and Server.playing >= MinimumPeople then
            table.insert(ViableServers,Server)
        end
    end
    local RandomIndex = math.random(1,#ViableServers)
    local RandomServer = ViableServers[RandomIndex]

    local ServerId = RandomServer.id
    syn.queue_on_teleport('getgenv().BoothMsg = "'..BoothTxt..'" getgenv().ServerHopTime = '..InactivityForServerHop..' getgenv().webhook = "'..getgenv().webhook..'" loadstring(game:HttpGet("https://raw.githubusercontent.com/wallop560/stuff/main/starve.lua"))()')
    TPS:TeleportToPlaceInstance(game.PlaceId,ServerId,Players.LocalPlayer)
end

game.Players.LocalPlayer.Idled:Connect(function()
    VU:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
    wait(.2)
    VU:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
end)

send('Joined new server.')

spawn(function()
    while wait(math.random(30,40)) do
        local msg = AFKMsg[math.random(1,#AFKMsg)]
        game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(msg,'All')
    end
end)

while wait(1) do
    timer = timer<InactivityForServerHop*60 and timer + 1 or serverhop() 
end
