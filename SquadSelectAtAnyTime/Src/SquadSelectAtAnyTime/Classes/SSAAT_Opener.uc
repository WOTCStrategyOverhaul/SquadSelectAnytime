class SSAAT_Opener extends Object;

static function ShowSquadSelect() {
	local XComGameStateHistory History;
	local XComGameState NewGameState;
	local XComGameState_HeadquartersXCom XComHQ;
	local XComGameState_MissionSite MissionState;
	local StateObjectReference MissionReference;
	local XComHQPresentationLayer HQPres;
	
	History = `XCOMHISTORY;
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("SSAAT: Show squad select for fake mission");
	XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));

	MissionState = BuildMissionSite(NewGameState);
	XComHQ = XComGameState_HeadquartersXCom(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersXCom', XComHQ.ObjectID));

	MissionReference.ObjectID = MissionState.ObjectID;
	XComHQ.MissionRef = MissionReference;

	History.AddGameStateToHistory(NewGameState);

	HQPres = `HQPRES;
	HQPres.UISquadSelect();
}

static protected function XComGameState_MissionSite BuildMissionSite(XComGameState NewGameState) 
{
	local X2StrategyElementTemplateManager StratMgr;
	local X2MissionSourceTemplate MissionSource;
	local XComGameState_Reward RewardState;
	local X2RewardTemplate RewardTemplate;
	local XComGameState_MissionSite MissionState;

	// Get Stuff
	StratMgr = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	MissionSource = X2MissionSourceTemplate(StratMgr.FindStrategyElementTemplate('SSAAT_MissionSource_FakeMission'));
	RewardTemplate = X2RewardTemplate(StratMgr.FindStrategyElementTemplate('Reward_None'));

	// Create stuff
	MissionState = XComGameState_MissionSite(NewGameState.CreateNewStateObject(class'XComGameState_MissionSite'));
	RewardState = RewardTemplate.CreateInstanceFromTemplate(NewGameState);

	// Fill in XComGameState_MissionSite
	MissionState.Source = MissionSource.DataName;
	MissionState.Location.x = 0;
	MissionState.Location.y = 0;
	MissionState.Available = true;
	MissionState.Expiring = false;
	MissionState.Rewards.AddItem(RewardState.GetReference());
	MissionState.ManualDifficultySetting = 1;
	MissionState.GeneratedMission.Mission.MissionName = 'SSAAT_FakeMission';
	MissionState.GeneratedMission.BattleOpName = "Squad select (no mission)";

	return MissionState;
}