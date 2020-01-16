datastore = game:GetService("DataStoreService")
DataTable = {}
BindToClose = {}
PDM = {}
Settings = script.Settings
function PDM:GetStore(Name)
	local Store = datastore:GetDataStore("DATA")
	local Success, Data = xpcall(function() Store:GetAsync(Name)end,function() print("Intial call failed. Retrying once.")Store:GetAsync(Name)end)
	DataTable[Name] = Data
	if Data == nil then DataTable[Name] = {} DataTable[Name][Settings.AutoSaveKey.Value] = os.time() end
end
function PDM:Get(Name,DataName,Default)
	local Data = DataTable[Name]
	if Data == nil then local store = PDM:GetStore(Name) end
		local RData = Data[DataName]
		if RData == nil and Default ~= nil then
			RData = PDM:Set(Data,RData,Default)
		end
		return RData
	end
function PDM:Set(StoreName,Name,Value)
	local Data = DataTable[StoreName]
	if Name == Settings.AutoSaveKey.Value then error("Request matches AutoSaveKey. Please change data name or AutoSaveKey name.",0) return end
	if Data == nil then  local store = PDM:GetStore(StoreName) return end
		Data[Name] = Value
		if Data[Name]["LastSaved"] < os.time() - script.Settings.AutoSaveInterval.Value and Settings.AutoSaveActive.Value == true then
		PDM:Update(StoreName)
	end
	return Data[Name]
end
function PDM:Update(StoreName)
	local Data = DataTable[StoreName]
	if Data == nil then print("Datastore not updated. No update needed") return end
	local Saved = datastore:GetDataStore("DATA")
	local S,D = xpcall(function()Saved:SetAsync(StoreName,Data)end,function()print("Intial call failed. Retrying once.") Saved:SetAsync(StoreName,Data)end)
end
function PDM:Increment(StoreName,Name,Value,Default)
	if typeof(Value) == "number" then
		if typeof(Default) ~= "number" then Default = 0 end
		local Data = PDM:Get(StoreName,Name,Default)
		if typeof(Data)	~= "number" then
			error("Data was not a number. Increment Function",0)
		else
			PDM:Set(StoreName,Name,Data + Value)
			end
	else
		error("Value is not a number",0)
	end
end
function PDM:Clear(StoreName)
	local Data = DataTable[StoreName]
	if not Data then error("Data not found",0) end
	PDM:Update(StoreName)
	Data = nil
end
function PDM:Wipe(Name)
	DataTable[Name] = nil
	if Settings.SaveAfterWipe.Value == true then
	local Store = datastore:GetDataStore("DATA")
	local S,D = xpcall(function()Store:SetAsync(Name,nil)end,function()print("Intial call failed. Retrying once.") Store:SetAsync(Name,nil)end)
	end
end
return PDM
