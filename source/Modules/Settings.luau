local Settings = {}

Settings.MAX_RESOLVE_DEPTH = 5

Settings.SETTINGS_KEYS = {
	Mode = "TracePathMode",
	Types = "TracePathTypes",
	Debugging = "TracePathDebugging",
}

Settings.DEFAULTS = {
	Mode = "Script",
	Types = {
		Object = true,
		Text = true,
		Variable = false,
	},
	Debugging = {
		Prints = false,
	}
}

function Settings.Get(plugin, key)
	local value = plugin:GetSetting(key)
	if value == nil then
		value = plugin:GetSetting(Settings.SETTINGS_KEYS[key])
		return value == nil and Settings.DEFAULTS[key] or value
	end
end

function Settings.Set(plugin, key, value)
	plugin:SetSetting(key, value)
end

return Settings
