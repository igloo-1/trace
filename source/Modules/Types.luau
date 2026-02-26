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
	CoreGui: CoreGui,
	SettingsGui: ScreenGui,
	PathGuiTemplate: ScreenGui,
}

export type ActivationControllerContext = {
	Selection: Selection,
	ScriptEditorService: ScriptEditorService,
	StudioService: StudioService,
	ChangeHistoryService: ChangeHistoryService,
	
	CoreGui: CoreGui,
	PathGuiTemplate: ScreenGui,

	ExpressionResolver: ExpressionResolver,
	DocumentTracker: DocumentTracker,
}

return {}
