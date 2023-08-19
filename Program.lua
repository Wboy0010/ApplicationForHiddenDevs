--Custom Data Storage

local DataStore = game:GetService("DataStoreService")
local Data = DataStore:GetDataStore("Data00-01")


local function SaveData(player)
    local Kills = player.leaderstats.KILLS.Value

   local success,errormessage = pcall(function()
    Data:SetAsync(player.UserId, Kills)
   end)

 if success then --If data has been saved
    print("DATA HAS BEEN SAVED")
 else --Else if the save fails
    print("DATA SAVE ERROR")
    warn(errormessage)
  end
end


game.Players.PlayerAdded:Connect(function(player)
    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player

    local Kills = Instance.new("IntValue", leaderstats)
    Kills.Name = "KILLS"
    Kills.Value = 0

    local data 
    local succes,errormessage = pcall(function()

        data = Data:GetAsync(player.UserId)

    end)

    if succes and data  then
        Kills.Value = data
        print("GetAsync HAS INIT!")
    else
        warn(errormessage)
    end
    
end)


game.Players.PlayerRemoving:Connect(function(player)
    local success,errormessage = pcall(function()
        SaveData(player)
    end)

    if success then
        print("DATA HAS BEEN SAVED!")
    else
            print("DATA SAVE ERROR! ")
    end

end)


game:BindToClose(function()--When ever the game shutdowns it waits for some time to save player data
    for _, players in pairs(game.Players:GetPlayers()) do --Loop through all the players in server
        local success, errrormessage = pcall(function()
            SaveData(players)
        end)
        if success then
            print("BIND TO CLOSE HAS INIT!")
        else
        print("ERROR IN BIND TO CLOSE FUNCTION!")
        end
    end
end)
