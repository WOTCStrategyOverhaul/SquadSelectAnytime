//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek
//  PURPOSE: This class is used to only hold data about the current "session" of SSAAT.
//           It is intended to be attached to UIAvengerHUD to be accessible globaly.
//           It doesn't contain any visual or interactive elements.
//           It also removes the dummy mission when the UISS is closed
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class SSAAT_SessionDataHolder extends UIPanel;

var const name PanelName;

var protectedwrite SSAAT_SquadSelectConfiguration Configuration;
var protectedwrite int MissionObjectId;

function InitDataHolder(SSAAT_SquadSelectConfiguration InConfiguration, int InMissionObjectId)
{
	InitPanel(PanelName);

	Configuration = InConfiguration;
	MissionObjectId = InMissionObjectId;
	
	if (UIAvengerHUD(ParentPanel) == none)
	{
		`REDSCREEN("SSAAT_SessionDataHolder is intended to be attached to UIAvengerHUD, instead attached to" @ ParentPanel.Name);
	}
}

function RegisterOnRemovedCallback(UISquadSelect TheScreen)
{
	TheScreen.AddOnRemovedDelegate(OnSquadSelectRemoved);
}

function protected OnSquadSelectRemoved(UIPanel Panel)
{
	// Shedule our removal in 0.5 seconds so that we are removed after all callbacks have fired
	SetTimer(0.5, false, nameof(DoCleanup));
}

function DoCleanup()
{
	// Get rid of summy mission first

	local XComGameStateHistory History;
	local XComGameState NewGameState;
	local XComGameState_MissionSite MissionState;

	History = `XCOMHISTORY;
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("SSAAT: Clean up dummy mission");
	MissionState = XComGameState_MissionSite(History.GetGameStateForObjectID(MissionObjectId));

	NewGameState.RemoveStateObject(MissionObjectId);
	NewGameState.RemoveStateObject(MissionState.Rewards[0].ObjectID); // Get rid of reward as well

	History.AddGameStateToHistory(NewGameState);

	// Get rid of ourselves
	Remove();
}

defaultproperties
{
	PanelName = "SSAAT_DataHolder";
	bIsNavigable = false;
}