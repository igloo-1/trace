local Types = require("./Types")

local UIController = {}
UIController.__index = UIController

function UIController.new(context: Types.UIControllerContext | Types.GlobalContext)
	local self = setmetatable({}, UIController)

	self.Gui = context.SettingsGui
	self.GetSetting = context.GetSetting
	self.SetSetting = context.SetSetting
	
	self.MainFrame = self.Gui.MainFrame
	self.TraceModeFrame = self.MainFrame.TraceMode
	self.TraceTypesFrame = self.MainFrame.TraceTypes
	self.DebuggingFrame = self.MainFrame.Debugging
	
	-- Trace Mode Frame
	self.ScriptToggleBtn = self.TraceModeFrame.ScriptToggle.CheckContainer.Button
	self.TextBoxToggleBtn = self.TraceModeFrame.TextBoxToggle.CheckContainer.Button
	
	self.ScriptCheck = self.TraceModeFrame.ScriptToggle.CheckContainer.CheckBox.Check
	self.TextBoxCheck = self.TraceModeFrame.TextBoxToggle.CheckContainer.CheckBox.Check
	
	-- Trace Types Frame
	self.ObjectToggleBtn = self.TraceTypesFrame.ObjectToggle.CheckContainer.Button
	self.TextToggleBtn = self.TraceTypesFrame.TextToggle.CheckContainer.Button
	self.VariableToggleBtn = self.TraceTypesFrame.VariableToggle.CheckContainer.Button
	
	self.ObjectCheck = self.TraceTypesFrame.ObjectToggle.CheckContainer.CheckBox.Check
	self.TextCheck = self.TraceTypesFrame.TextToggle.CheckContainer.CheckBox.Check
	self.VariableCheck = self.TraceTypesFrame.VariableToggle.CheckContainer.CheckBox.Check
	
	-- Debugging Frame
	self.PrintsToggleBtn = self.DebuggingFrame.PrintsToggle.CheckContainer.Button
	
	self.PrintsCheck = self.DebuggingFrame.PrintsToggle.CheckContainer.CheckBox.Check
	

	self:_init()

	return self
end

function UIController:_init()
	self.Gui.Enabled = false
	
	self.ScriptToggleBtn.MouseButton1Click:Connect(function()
		self.SetSetting("Mode", "Script")
		self:_refreshChecks()
	end)
	
	self.TextBoxToggleBtn.MouseButton1Click:Connect(function()
		self.SetSetting("Mode", "Textbox")
		self:_refreshChecks()
	end)
	
	self.ObjectToggleBtn.MouseButton1Click:Connect(function()
		local types = self.GetSetting("Types")
		types.Object = not types.Object
		self.SetSetting("Types", types)
		self:_refreshChecks()
	end)
	
	self.TextToggleBtn.MouseButton1Click:Connect(function()
		local types = self.GetSetting("Types")
		types.Text = not types.Text
		self.SetSetting("Types", types)
		self:_refreshChecks()
	end)
	
	self.VariableToggleBtn.MouseButton1Click:Connect(function()
		local types = self.GetSetting("Types")
		types.Variable = not types.Variable
		self.SetSetting("Types", types)
		self:_refreshChecks()
	end)
	
	self.PrintsToggleBtn.MouseButton1Click:Connect(function()
		local debugging = self.GetSetting("Debugging")
		debugging.Prints = not debugging.Prints
		self.SetSetting("Debugging", debugging)
		self:_refreshChecks()
	end)
	
	self:_refreshChecks()
end

function UIController:Toggle()
	self.Gui.Enabled = not self.Gui.Enabled
end

function UIController:_refreshChecks()
	local mode = self.GetSetting("Mode")
	self.ScriptCheck.Visible = (mode == "Script")
	self.TextBoxCheck.Visible = (mode == "Textbox")

	local types = self.GetSetting("Types")
	self.ObjectCheck.Visible = types.Object
	self.TextCheck.Visible = types.Text
	self.VariableCheck.Visible = types.Variable

	local debugging = self.GetSetting("Debugging")
	self.PrintsCheck.Visible = debugging.Prints
end

function UIController:Destroy()
	if self.Gui then
		self.Gui:Destroy()
	end
end

return UIController
