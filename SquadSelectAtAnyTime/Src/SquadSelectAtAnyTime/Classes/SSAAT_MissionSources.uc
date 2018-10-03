class SSAAT_MissionSources extends X2StrategyElement;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> MissionSources;

	MissionSources.AddItem(CreateFakeMissionSource());

	return MissionSources;
}

static function X2DataTemplate CreateFakeMissionSource()
{
	local X2MissionSourceTemplate Template;

	`CREATE_X2TEMPLATE(class'X2MissionSourceTemplate', Template, 'SSAAT_MissionSource_FakeMission');
	Template.bRequiresSkyrangerTravel = false;
	Template.DifficultyValue = 1;
	Template.CanLaunchMissionFn = CanLaunchFakeMission;

	return Template;
}

static function bool CanLaunchFakeMission(XComGameState_MissionSite MissionState) {
	return false;
}