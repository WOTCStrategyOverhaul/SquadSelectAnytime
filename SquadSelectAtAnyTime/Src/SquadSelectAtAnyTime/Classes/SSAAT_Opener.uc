//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek
//  PURPOSE: This class contains the logic that creates the fake mission and opens
//           opens the Squad Select screen for said mission
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class SSAAT_Opener extends Object;

static function UISquadSelect ShowSquadSelect(optional SSAAT_SquadSelectConfiguration Configuration) {
	local XComGameStateHistory History;
	local XComGameState NewGameState;

	local XComGameState_HeadquartersXCom XComHQ;
	local XComGameState_MissionSite MissionState;
	local StateObjectReference MissionReference;
	
	local XComHQPresentationLayer HQPres;
	local UISquadSelect TheScreen;
	local SSAAT_SessionDataHolder DataHolder;
	
	History = `XCOMHISTORY;
	HQPres = `HQPRES;

	if (GetSquadSelectFromStack(HQPres) != none)
	{
		`REDSCREEN("SSAAT_Opener called when there is a UISquadSelect already on the stack. I have no idea what you are trying to achieve but I'm not going to do ANYTHING to avoid breaking other stuff");
		return none;
	}

	if (Configuration == none)
	{
		Configuration = class'SSAAT_SquadSelectConfiguration'.static.CreateWithDefaults();
		Configuration.SetFrozen();
	} 

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("SSAAT: Show squad select for fake mission");
	XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));

	MissionState = BuildMissionSite(NewGameState, Configuration);
	XComHQ = XComGameState_HeadquartersXCom(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersXCom', XComHQ.ObjectID));

	MissionReference.ObjectID = MissionState.ObjectID;
	XComHQ.MissionRef = MissionReference;

	History.AddGameStateToHistory(NewGameState);

	// Configure the data holder here, since we will need it for event listener
	ClearExistingDataHolder();
	DataHolder = HQPres.Spawn(class'SSAAT_SessionDataHolder', HQPres.m_kAvengerHUD);
	DataHolder.InitDataHolder(Configuration, MissionState.ObjectID);

	TheScreen = HQPres.Spawn(class'UISquadSelect', HQPres);
	PreSquadSelectInit(TheScreen, Configuration);
	HQPres.ScreenStack.Push(TheScreen);

	PostSquadSelectInit(TheScreen, Configuration);
	DataHolder.RegisterOnRemovedCallback(TheScreen);

	return TheScreen;
}

static protected function XComGameState_MissionSite BuildMissionSite(XComGameState NewGameState, SSAAT_SquadSelectConfiguration Configuration) 
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
	MissionState = XComGameState_MissionSite(NewGameState.CreateNewStateObject(class'SSAAT_FakeMissionSite'));
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
	MissionState.GeneratedMission.Mission.MaxSoldiers = Configuration.GetNumSlots();
	MissionState.GeneratedMission.BattleOpName = "Squad select (no mission)";

	Configuration.CallAugmentFakeMissionSiteFn(MissionState);

	return MissionState;
}

static protected function UISquadSelect GetSquadSelectFromStack(XComHQPresentationLayer HQPres)
{
	return class'SSAAT_Helpers'.static.GetSquadSelectFromStack(HQPres.ScreenStack);
}

static protected function ClearExistingDataHolder()
{
	local SSAAT_SessionDataHolder DataHolder;

	DataHolder = class'SSAAT_Helpers'.static.GetCurrentDataHolder(false);

	if (DataHolder != none)
	{
		`log("Warning: SSAAT_SessionDataHolder existing when opening SS - something went wrong with cleanup?",, 'SSAAT');
		DataHolder.DoCleanup();
	}
}

static protected function PreSquadSelectInit(UISquadSelect SquadSelect, SSAAT_SquadSelectConfiguration Configuration)
{
	if (Configuration.ShouldReplaceLaunchText())
	{
		if (`ISCONTROLLERACTIVE)
		{
			SquadSelect.m_strLaunch = Configuration.GetLauchLabelLine1();
			SquadSelect.m_strMission = Configuration.GetLauchLabelLine2();
		}
		else
		{
			// When using mouse (and the label isn't concatenated into 1 row) the lines are reversed
			SquadSelect.m_strLaunch = Configuration.GetLauchLabelLine2();
			SquadSelect.m_strMission = Configuration.GetLauchLabelLine1();
		}
		
	}
}

static protected function PostSquadSelectInit(UISquadSelect SquadSelect, SSAAT_SquadSelectConfiguration Configuration)
{
	local SSAAT_ElementRemover ElementRemover;

	ElementRemover = new(SquadSelect) class'SSAAT_ElementRemover';
	ElementRemover.InitRemover(Configuration);
	
	if (Configuration.ShouldConfirmLaunch())
	{
		SquadSelect.LaunchButton.OnClickedDelegate = CreateConfirmDialog;
	}
}

simulated function CreateConfirmDialog(UIButton Button)
{
	local SSAAT_SquadSelectConfiguration Configuration;
	local delegate<SSAAT_SquadSelectConfiguration.CanClickLaunch> ShouldShowConfirm;

	Configuration = class'SSAAT_Helpers'.static.GetCurrentConfiguration();
	Configuration.GetShouldShowConfirmFn(ShouldShowConfirm);

	if (Configuration.ShouldConfirmLaunch() && ShouldShowConfirm())
	{
		`Log("DIALOG OPENED!");

		// show dialog with the config's title and text
		// if player clicks yes, call OnLaunchMission
		// if player clicks no, close the dialog
	}
	else
	{
		class'SSAAT_Helpers'.static.GetSquadSelect().OnLaunchMission(Button);
	}
}
