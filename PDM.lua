datastore = game:GetService("DataStoreService")
DataTable = {}
PDM = {}
Settings = script.Settings
function PDM:GetStore(Name)
	local Store = datastore:GetDataStore("DATA")
	local Data = Store:GetAsync(Name)
	DataTable[Name] = Data
	if not Data then DataTable[Name][Settings.AutoSaveKey.Value] = os.time() end
end
function PDM:GetAsync(Default,Name,DataName)
	local Data = DataTable[Name]
	if Data == nil then local store = PDM:GetStore(Name) return end
		local RData = Data[DataName]
		if RData == nil then
			Data[Name] = Default
		end
		return RData
	end
function PDM:Set(StoreName,Name,Value)
	local Data = DataTable[StoreName]
	if Name == Settings.AutoSaveKey.Value then print("Request matches AutoSaveKey. Please change data name or AutoSaveKey name.") return end
	if Data == nil then  local store = PDM:GetStore(StoreName) return end
		Data[Name] = Value
		if Data[Name]["LastSaved"] < os.time() - script.Settings.AutoSaveInterval.Value and Settings.AutoSaveActive.Value == true then
		PDM:Update(StoreName)
	end
	return
end
function PDM:Update(StoreName)
	local Data = DataTable[StoreName]
	if Data == nil then print("Datastore not updated. No update needed") return end
	local Saved = datastore:GetDataStore("DATA")
	Saved:SetAsync(StoreName,Data)
end
function PDM:Clear(StoreName)
	local Data = DataTable[StoreName]
	if not Data then print("Data not found") return end
	PDM:Update(StoreName)
	Data = nil
end
return PDM
