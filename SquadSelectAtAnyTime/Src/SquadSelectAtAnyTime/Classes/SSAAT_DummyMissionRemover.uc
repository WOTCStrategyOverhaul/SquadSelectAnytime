//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek
//  PURPOSE: This class is used to cleanup after SS for fake mission has been closed.
//           A separate class is required since XComHQ.MissionRef is 0 when SS is being
//           removed and closures aren't a thing in UC
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class SSAAT_DummyMissionRemover extends UIPanel;

var int MissionObjectId;

simulated event Removed()
{
	local XComGameStateHistory History;
	local XComGameState NewGameState;
	local XComGameState_MissionSite MissionState;

	super.Removed();

	History = `XCOMHISTORY;
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("SSAAT: Clean up dummy mission");
	MissionState = XComGameState_MissionSite(History.GetGameStateForObjectID(MissionObjectId));

	NewGameState.RemoveStateObject(MissionObjectId);
	NewGameState.RemoveStateObject(MissionState.Rewards[0].ObjectID); // Get rid of reward as well

	History.AddGameStateToHistory(NewGameState);
}