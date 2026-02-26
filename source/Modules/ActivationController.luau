local StudioService = game:GetService("StudioService")
local Selection = game:GetService("Selection")
local ScriptEditorService = game:GetService("ScriptEditorService")
local CoreGui = game:GetService("CoreGui")
local ChangeHistoryService = game:GetService("ChangeHistoryService")

local Types = require("./Types")

local ActivationController = {}
ActivationController.__index = ActivationController

function ActivationController.new(context: Types.ActivationControllerContext | Types.GlobalContext)
	local self = setmetatable({}, ActivationController)

	self.PathGuiTemplate = context.PathGuiTemplate
	
	self.ExpressionResolver = context.ExpressionResolver
	self.DocumentTracker = context.DocumentTracker
	
	self.GetSetting = context.GetSetting

	return self
end

local function buildObjectPath(object)
	local splits = string.split(object:GetFullName(), ".")
	local path = 'game:GetService("' .. splits[1] .. '")'

	for i = 2, #splits do
		local segment = splits[i]
		if segment:match("[^%w_]") or tonumber(segment:sub(1,1)) then
			path ..= `["{segment}"]`
		else
			path ..= "." .. segment
		end
	end

	return path
end

function ActivationController:Activate()

	if self.DocumentTracker.LastSelectionSource == "Script"
		and self.DocumentTracker.LastSelectedText then

		local activeScript = StudioService.ActiveScript
		if activeScript then
			local instance = self.ExpressionResolver:ResolveScriptSelection(
				activeScript.Source,
				self.DocumentTracker.LastSelectedText
			)

			if instance then
				Selection:Set({instance})
				return
			end
		end
	end

	local sel = Selection:Get()
	if #sel == 0 then
		return
	end

	local path = buildObjectPath(sel[#sel])
	local mode = self.GetSetting("TracePathMode", "Script")

	if mode == "Textbox" then
		local gui = self.PathGuiTemplate:Clone()
		gui.Parent = CoreGui
		gui.Enabled = true

		local box = gui.TextBox
		box.Text = path
		box:CaptureFocus()
	else
		self.DocumentTracker:CreateTempDocument(path, "TracePathTempScript")
	end

	ChangeHistoryService:SetWaypoint("TraceSelection")
end

function ActivationController:Destroy()
	self = nil
	setmetatable(self, nil)
end

return ActivationController
