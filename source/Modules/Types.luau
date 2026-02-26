export type GlobalContext = {
	GetSetting: (string) -> any,
	SetSetting: (string, any) -> (),
	
	DebugPrint: (...any) -> (),
	DebugWarn: (...any) -> (),
}

export type ExpressionResolverContext = {
	MaxDepth: number
}

export type UIControllerContext = {
	SettingsGui: ScreenGui,
	PathGuiTemplate: ScreenGui,
}

export type ActivationControllerContext = {
	PathGuiTemplate: ScreenGui,

	ExpressionResolver: ExpressionResolver,
	DocumentTracker: DocumentTracker,
}

return {}
