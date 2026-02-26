local Debug = {}
Debug.__index = Debug

function Debug.new(getDebugSettings)
	local self = setmetatable({}, Debug)

	function self:Print(...)
		if getDebugSettings().Prints then
			print(...)
		end
	end

	function self:Warn(...)
		if getDebugSettings().Prints then
			warn(...)
		end
	end

	return self
end

return Debug
