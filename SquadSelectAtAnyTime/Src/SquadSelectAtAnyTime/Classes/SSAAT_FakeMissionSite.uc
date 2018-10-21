class SSAAT_FakeMissionSite extends XComGameState_MissionSite;

delegate OnLaunchSuper();

function InteractionComplete(bool RTB)
{
    // NOOP to prevent clock from resuming when exiting
}

function bool CanLaunchMission(optional out string FailReason)
{
	local SSAAT_SquadSelectConfiguration Configuration;
	local delegate<SSAAT_SquadSelectConfiguration.CanClickLaunch> CanClickLaunchFn;

	Configuration = class'SSAAT_Helpers'.static.GetCurrentConfiguration();
	if (Configuration == none) return super.CanLaunchMission(FailReason);

	if (!Configuration.ShouldShowLaunchButton()) return false;

	Configuration.GetCanClickLaunchFn(CanClickLaunchFn);
	return CanClickLaunchFn();
}

function SquadSelectionCompleted()
{
	HandleLaunchInternal(super.SquadSelectionCompleted);
}

function ConfirmMission()
{
	HandleLaunchInternal(super.ConfirmMission);
}

protected function HandleLaunchInternal(delegate<OnLaunchSuper> SuperIfConfNotUsed)
{
	local SSAAT_SquadSelectConfiguration Configuration;
	local delegate<SSAAT_SquadSelectConfiguration.OnLaunch> OnLaunchFn;

	Configuration = class'SSAAT_Helpers'.static.GetCurrentConfiguration();
	if (Configuration == none) 
	{
		SuperIfConfNotUsed();
		return;
	}

	Configuration.GetOnLaunchFn(OnLaunchFn);
	if (OnLaunchFn == none) 
	{
		SuperIfConfNotUsed();
		return;
	}

	OnLaunchFn();
}