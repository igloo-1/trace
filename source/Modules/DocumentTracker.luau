local ScriptEditorService = game:GetService("ScriptEditorService")
local StudioService = game:GetService("StudioService")
local Selection = game:GetService("Selection")
local CoreGui = game:GetService("CoreGui")

local DocumentTracker = {}
DocumentTracker.__index = DocumentTracker

function DocumentTracker.new()
	local self = setmetatable({}, DocumentTracker)

	self.LastSelectionSource = "Explorer"
	self.LastSelectedText = nil

	self._connections = {}
	self._activeDocs = {}
	self._tempDocs = {}

	self:_init()

	return self
end

function DocumentTracker:_init()

	self._connections.SelectionChanged =
		Selection.SelectionChanged:Connect(function()
			self.LastSelectionSource = "Explorer"
		end)

	self._connections.TextDocumentDidOpen =
		ScriptEditorService.TextDocumentDidOpen:Connect(function(doc)
			self:_hookDocument(doc)
		end)

	self._connections.TextDocumentDidClose =
		ScriptEditorService.TextDocumentDidClose:Connect(function(doc)
			if self._activeDocs[doc] then
				self._activeDocs[doc]:Disconnect()
				self._activeDocs[doc] = nil
			end
		end)

	for _, doc in ipairs(ScriptEditorService:GetScriptDocuments()) do
		self:_hookDocument(doc)
	end
end

function DocumentTracker:_hookDocument(doc)
	if self._activeDocs[doc] then
		return
	end

	self._activeDocs[doc] = doc.SelectionChanged:Connect(function()
		if doc:HasSelectedText() then
			local text = doc:GetSelectedText()
			if text and text ~= "" then
				self.LastSelectedText = text
				self.LastSelectionSource = "Script"
			end
		end
	end)
end

function DocumentTracker:CreateTempDocument(source, name)
	local previousScript = StudioService.ActiveScript
	local old = CoreGui:FindFirstChild(name)
	if old then old:Destroy() end
	
	local scr = Instance.new("Script")
	scr.Name = name
	scr.Source = source
	scr.Parent = CoreGui

	ScriptEditorService:OpenScriptDocumentAsync(scr)
	local doc = ScriptEditorService:FindScriptDocument(scr)
	
	local lineText = doc:GetLine(1)
	doc:ForceSetSelectionAsync(1, 1, 1, #lineText + 1)
	
	local conn1, conn2
	conn1 = ScriptEditorService.TextDocumentDidClose:Connect(function(closedDoc)
		if closedDoc == doc then
			if previousScript then
				ScriptEditorService:OpenScriptDocumentAsync(previousScript)
			end
			
			if scr.Parent then scr:Destroy() end
			conn1:Disconnect()
			if conn2 then conn2:Disconnect() end
			
			self._tempDocs[doc] = nil
		end
	end)

	conn2 = scr:GetPropertyChangedSignal("Source"):Connect(function()
		if scr.Source == "" then
			doc:CloseAsync()
			
			if previousScript then
				ScriptEditorService:OpenScriptDocumentAsync(previousScript)
			end
			
			if scr.Parent then scr:Destroy() end
			if conn1 then conn1:Disconnect() end
			conn2:Disconnect()
			
			self._tempDocs[doc] = nil
		end
	end)
	
	self._tempDocs[doc] = {Script = scr, Connections = {conn1, conn2}}
end

function DocumentTracker:Destroy()
	for _, conn in pairs(self._connections) do
		conn:Disconnect()
	end

	for _, conn in pairs(self._activeDocs) do
		conn:Disconnect()
	end
	
	for doc, data in pairs(self._tempDocs) do
		if data.Script then
			if data.Script.Parent then data.Script:Destroy() end
		end
		
		if data.Connections then
			for _, conn in pairs(data.Connections) do
				if conn then conn:Disconnect() end
			end
		end
	end
	
	table.clear(self._connections)
	table.clear(self._activeDocs)
	table.clear(self._tempDocs)
end

return DocumentTracker
