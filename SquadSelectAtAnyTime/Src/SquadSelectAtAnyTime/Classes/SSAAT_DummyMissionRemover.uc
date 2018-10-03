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