//---------------------------------------------------------------------------------------
//  AUTHOR:  Xymanek
//  PURPOSE: This class is used to remove or hide UIPanels (and children) that are not
//           needed when showing Squad Select for the fake mission
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class SSAAT_ElementRemover extends Object;

var protected UISquadSelect SquadSelect;
var protected SSAAT_SquadSelectConfiguration Configuration;
var protected delegate<UIPanel.OnChildChanged> PrevOnChildAdded;

simulated function InitRemover(SSAAT_SquadSelectConfiguration InitConfiguration)
{
	Configuration = InitConfiguration;
	SquadSelect = UISquadSelect(Outer);

	if (SquadSelect == none)
	{
		`REDSCREEN("SSAAT_ElementRemover is not attached to UISquadSelect - will do nothing");
		`REDSCREEN(GetScriptTrace());
	}
	else
	{
		PrevOnChildAdded = SquadSelect.OnChildAdded;
		SquadSelect.OnChildAdded = OnChildAdded;

		SquadSelect.AddOnInitDelegate(OnScreenInit);
	}
}

simulated protected function OnScreenInit(UIPanel Panel)
{
	// Mission info and launch button need to be hidden via property as they uses auto-generated names
	// They aren't destroyed since that will cause "none accessed errors"
	if(Configuration.ShouldHideMissionInfo()) SquadSelect.m_kMissionInfo.Hide();
	if(!Configuration.ShouldShowLaunchButton()) SquadSelect.LaunchButton.Hide();
}

simulated protected function OnChildAdded(UIPanel Panel)
{
	local array<name> PanelNames;

	if (PrevOnChildAdded != none)
	{
		PrevOnChildAdded(Panel);
	}

	if (Panel.ParentPanel != SquadSelect)
	{
		// Screens own their recursive children. Explicitly check here!
		return;
	}

	PanelNames = Configuration.GetPanelsToRemove();
	if (PanelNames.Find(Panel.MCName) != INDEX_NONE)
	{
		Panel.Remove();
		return;
	}
	
	PanelNames = Configuration.GetPanelsToHide();
	if (PanelNames.Find(Panel.MCName) != INDEX_NONE)
	{
		Panel.Hide();
	}
}