local Types = require("./Types")

local ExpressionResolver = {}
ExpressionResolver.__index = ExpressionResolver

function ExpressionResolver.new(context: Types.ExpressionResolverContext | Types.GlobalContext)
	local self = setmetatable({}, ExpressionResolver)

	self.MaxDepth = context.MaxDepth or 5
	
	self.GetSetting = context.GetSetting
	self.SetSetting = context.SetSetting
	
	self.DebugPrint = context.DebugPrint or function() end
	self.DebugWarn = context.DebugWarn or function() end

	return self
end

function ExpressionResolver:ResolveExpression(expr: string, locals: table, depth: number?)
	depth = depth or 0
	if depth > self.MaxDepth then
		return nil
	end

	expr = expr:match("^%s*(.-)%s*$")
	if not expr or expr == "" then
		return nil
	end
	
	local current
	local remaining = expr

	-- require(...)
	local inner = expr:match("^require%((.+)%)$")
	if inner then
		local moduleInstance = self:ResolveExpression(inner, locals, depth + 1)
		if not moduleInstance then
			self.DebugWarn(`Failed to resolve require expression: {inner}, attempting to parse root`)
			remaining = inner
		else
			return moduleInstance
		end
	end

	-- Handle game:GetService(...) as root
	local serviceName = expr:match('^game:GetService%("([^"]+)"%)')
	if serviceName then
		current = game:GetService(serviceName)
		remaining = expr:sub(#('game:GetService("' .. serviceName .. '")') + 1)
	else
		local root = expr:match("^[%w_]+")
		if not root then
			return nil
		end

		current = locals[root] or (root == "game" and game)
		if not current then
			self.DebugWarn(`Root "{root}" not found in locals`)
			return nil
		end

		remaining = expr:sub(#root + 1)
	end
	
	for segment in remaining:gmatch("%.([%w_]+)") do
		if typeof(current) == "Instance" then
			current = current:FindFirstChild(segment)
		else
			current = current[segment]
		end
		if not current then
			self.DebugWarn(`Segment "{segment}" not found in "{expr}"`)
			return nil
		end
	end

	for segment in remaining:gmatch('%["([^"]+)"%]') do
		if typeof(current) == "Instance" then
			current = current:FindFirstChild(segment)
		else
			current = current[segment]
		end
		if not current then
			self.DebugWarn(`Segment "{segment}" not found in "{expr}"`)
			return nil
		end
	end

	return current
end

function ExpressionResolver:BuildLocalVariableMap(source: string)
	local locals = {}

	for var, expr in source:gmatch("local%s+([%w_]+)%s*=%s*([^\n\r]+)") do
		local resolved = self:ResolveExpression(expr, locals)
		if resolved then
			locals[var] = resolved
		end
	end

	return locals
end

function ExpressionResolver:ResolveScriptSelection(scriptSource: string, selectedText: string)
	if not selectedText or selectedText == "" then
		return nil
	end

	local locals = {}
	
	local copyTypes = self.GetSetting("Types")
	if copyTypes.Variable or copyTypes.Text then
		locals = self:BuildLocalVariableMap(scriptSource)
	end

	if copyTypes.Variable then
		local instance = locals[selectedText]
		if instance then
			self.DebugPrint("Resolved as variable:", selectedText)
			return instance
		else
			instance = self:ResolveExpression(selectedText, locals, 0)
			if instance then
				self.DebugPrint("Resolved as expression:", selectedText)
				return instance
			end
		end
	end

	if copyTypes.Text then
		local instance = self:ResolveExpression(selectedText, {}, 0)
		if typeof(instance) == "Instance" then
			self.DebugPrint("Resolved as path text:", selectedText)
			return instance
		end
	end

	self.DebugWarn("Failed to resolve script selection:", selectedText)
	return nil
end

return ExpressionResolver
