local Settings = {}
Settings.__index = Settings

Settings.MAX_RESOLVE_DEPTH = 5

Settings.DEFAULTS = {
	Mode = "Script",
	Types = {
		Object = true,
		Text = true,
		Variable = true,
	},
	Debugging = {
		Prints = false,
	}
}

function Settings.new(plugin)
	local self = setmetatable({}, Settings)
	
	self.Plugin = plugin
	
	return self
end

function Settings:Get(key)
	local value = self.Plugin:GetSetting(key)
	
	if value == nil and Settings.DEFAULTS[key] then
		value = Settings.DEFAULTS[key]
	end
	
	return value
end

function Settings:Set(key, value)
	self.Plugin:SetSetting(key, value)
end

return Settings
