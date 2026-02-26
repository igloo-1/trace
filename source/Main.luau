--[[
                                                                                            
  ttt                                                                                       
 tt  ttttttttt           ttt                                                                
 tt  tttttttttt          ttt                                                                
  ttt         tt       tttttttt  tt ttt    ttttt tt    tttttt       ttttt                   
          ttttt          ttt     tttt    ttt    ttt  ttt    ttt  tttt   ttt                 
      tttttt             ttt     tt     tt       tt  tt          tttttttttt                 
      tt         tt      ttt     tt     ttt      tt  tt      tt  ttt                        
      ttttttttttttttt    tttttt  tt      tttttttttt   ttttttttt   ttttttttt                 
        ttttttttttttt      tttt  tt        ttttt tt     ttttt       ttttt                   
                tttt                                                                        
                                                                                                                                                                          
@author: ig1oo1

@description: 
A lightweight Roblox Studio plugin for static object path resolution:
	- Copy the full path of any selected object to clipboard
	- Highlight a path string to instantly select that object
	- Select objects directly from stored variables by highlighting its name

@features:
	- Copy the path of the selected object
	- Select an object from a path string
	- Select an object from a variable
	
	- Copy path from a script's source code
	- Copy path from a text box

@changelog from v1.0.0:
	- Completely refactored the plugin
		- Split each section into it's own module
		- Reserved this Main script for bringing everything together
		- Added a Settings module for easy modification of the plugin
	
@notes:
	- Feel free to examine and modify the script however you want, 
	  but please don't redistribute it!

@version: 2.0.0
@date: 2026-02-25
]]

--===========================================================================--
-- IMPORTS AND PLUGIN SETUP
--===========================================================================--

local CoreGui = game:GetService("CoreGui")

local toolbar = plugin:CreateToolbar("igloo's Tools")
local mainButton = toolbar:CreateButton("trace", "\"trace\" the path of the selected object, string, or variable", "rbxassetid://105078106155206")
local settingsButton = toolbar:CreateButton("trace ⚙️", "Open trace settings", "rbxassetid://11888734334")
mainButton.ClickableWhenViewportHidden = true

--===========================================================================--
-- GUI SETUP
--===========================================================================--

local UIFolder = script.Parent:WaitForChild("UI")
local pathGuiTemplate = UIFolder:WaitForChild("ObjectPathGui")

if CoreGui:FindFirstChild("TraceSettings") then
	CoreGui.TraceSettings:Destroy()
end
local settingsGui = UIFolder:WaitForChild("TraceSettings")
settingsGui.Parent = CoreGui

--===========================================================================--
-- MODULES
--===========================================================================--

local Settings = require("./Modules/Settings")
local Types = require("./Modules/Types")
local Debug = require("./Modules/Debug")

local ExpressionResolver = require("./Modules/ExpressionResolver")
local DocumentTracker = require("./Modules/DocumentTracker")
local UIController = require("./Modules/UIController")
local ActivationController = require("./Modules/ActivationController")

--===========================================================================--
-- HELPER FUNCTIONS
--===========================================================================--

local function merge(dict1, dict2)
	local result = {}
	for k, v in dict1 do
		result[k] = v
	end
	for k, v in dict2 do
		result[k] = v
	end
	return result
end

--===========================================================================--
-- MODULE INITIALIZATION
--===========================================================================--

local pluginSettings = Settings.new(plugin)

local pluginDebug = Debug.new(function()
	return pluginSettings:Get("Debugging")
end)

local GlobalContext: Types.GlobalContext = {
	GetSetting = function(...) return pluginSettings:Get(...) end,
	SetSetting = function(...) return pluginSettings:Set(...) end,
	
	DebugPrint = function(...) return pluginDebug:Print(...) end,
	DebugWarn = function(...) return pluginDebug:Warn(...) end,
}

-- Expression resolver
local ExpressionResolverContext: Types.ExpressionResolverContext = {
	MaxDepth = 5,
}
local resolver = ExpressionResolver.new(merge(ExpressionResolverContext, GlobalContext))

-- Document tracker
local tracker = DocumentTracker.new()

-- UI controller
local UIControllerContext: Types.UIControllerContext = {
	SettingsGui = settingsGui,
	PathGuiTemplate = pathGuiTemplate
}
local ui = UIController.new(merge(UIControllerContext, GlobalContext))

-- Activation controller
local ActivationControllerContext: Types.ActivationControllerContext = {
	PathGuiTemplate = pathGuiTemplate,
	
	ExpressionResolver = resolver,
	DocumentTracker = tracker,
}
local activator = ActivationController.new(merge(ActivationControllerContext, GlobalContext))

--===========================================================================--
-- CONNECTIONS
--===========================================================================--

mainButton.Click:Connect(function()
	activator:Activate()
end)

settingsButton.Click:Connect(function()
	ui:Toggle()
end)

plugin.Unloading:Connect(function()
	tracker:Destroy()
	ui:Destroy()
end)

warn("[trace] Plugin Loaded!")
